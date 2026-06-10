// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package events

import (
	"context"
	"errors"
	"fmt"

	"buf.build/gen/go/antinvestor/profile/connectrpc/go/profile/v1/profilev1connect"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const OrganizationSaveEvent = "organization.save"

type OrganizationSave struct {
	organizationRepo repository.OrganizationRepository
	profileClient    profilev1connect.ProfileServiceClient
}

func NewOrganizationSave(
	_ context.Context,
	organizationRepo repository.OrganizationRepository,
	profileClient profilev1connect.ProfileServiceClient,
) *OrganizationSave {
	return &OrganizationSave{
		organizationRepo: organizationRepo,
		profileClient:    profileClient,
	}
}

func (e *OrganizationSave) Name() string     { return OrganizationSaveEvent }
func (e *OrganizationSave) PayloadType() any { return &models.Organization{} }

func (e *OrganizationSave) Validate(_ context.Context, payload any) error {
	organization, ok := payload.(*models.Organization)
	if !ok {
		return errors.New("payload is not of type models.Organization")
	}
	if organization.GetID() == "" {
		return errors.New("organization ID should already have been set")
	}
	return nil
}

func (e *OrganizationSave) Execute(ctx context.Context, payload any) error {
	organization, ok := payload.(*models.Organization)
	if !ok {
		return errors.New("payload is not of type models.Organization")
	}

	logger := util.Log(ctx).
		WithFields(map[string]any{logFieldType: e.Name(), "organization_id": organization.GetID()})
	defer logger.Release()

	existing, getErr := e.organizationRepo.GetByID(ctx, organization.GetID())
	if getErr == nil && existing != nil {
		if _, err := e.organizationRepo.Update(ctx, organization); err != nil {
			logger.WithError(err).Error("could not update organization in db")
			return err
		}
	} else {
		if err := e.organizationRepo.Create(ctx, organization); err != nil && !data.ErrorIsDuplicateKey(err) {
			logger.WithError(err).Error("could not create organization in db")
			return err
		}
	}

	// If this organization has a parent, mark the parent as having children.
	if organization.ParentID != "" {
		parent, parentErr := e.organizationRepo.GetByID(ctx, organization.ParentID)
		if parentErr == nil && parent != nil && !parent.HasChildren {
			parent.HasChildren = true
			if _, err := e.organizationRepo.Update(ctx, parent); err != nil {
				logger.WithError(err).Warn("could not update parent organization has_children flag")
			}
		}
	}

	// After save, sync profile from properties.
	if err := e.syncProfile(ctx, logger, organization); err != nil {
		logger.WithError(err).Warn("could not sync organization profile")
		// Don't fail the save — profile sync is best-effort
	}

	return nil
}

// syncProfile creates or updates a profile for the organization using data
// extracted from organization.Properties. The sync is best-effort: errors are
// returned but should not fail the org save.
func (e *OrganizationSave) syncProfile(
	ctx context.Context,
	logger *util.LogEntry,
	organization *models.Organization,
) error {
	if e.profileClient == nil {
		return nil
	}

	props := organization.Properties
	if props == nil {
		return nil
	}

	description, _ := props["description"].(string)
	logoContentURI, _ := props["logo_content_uri"].(string)
	domainName, _ := props["domain_name"].(string)
	addressStreet, _ := props["address_street"].(string)
	addressCity, _ := props["address_city"].(string)
	addressCountry, _ := props["address_country"].(string)
	addressPostalCode, _ := props["address_postal_code"].(string)

	// Extract contacts from properties.
	contacts := extractContacts(props)

	// Find the first email contact for profile creation.
	firstEmail := ""
	for _, c := range contacts {
		if c.contactType == "email" && c.value != "" {
			firstEmail = c.value
			break
		}
	}

	if organization.ProfileID == "" {
		profileID, err := e.createProfile(
			ctx,
			logger,
			organization,
			description,
			logoContentURI,
			domainName,
			firstEmail,
		)
		if err != nil {
			return err
		}
		organization.ProfileID = profileID
	} else {
		if err := e.updateProfile(
			ctx,
			logger,
			organization.ProfileID,
			description,
			logoContentURI,
			domainName,
		); err != nil {
			return err
		}
	}

	// Sync contacts to the profile.
	for _, c := range contacts {
		if c.value == "" {
			continue
		}
		if err := e.addContact(ctx, logger, organization.ProfileID, c); err != nil {
			logger.WithError(err).WithField("contact_value", c.value).
				Warn("could not add contact to profile")
		}
	}

	// Sync address if any address field is present.
	if addressStreet != "" || addressCity != "" || addressCountry != "" || addressPostalCode != "" {
		if err := e.addAddress(
			ctx,
			logger,
			organization.ProfileID,
			addressStreet,
			addressCity,
			addressCountry,
			addressPostalCode,
		); err != nil {
			logger.WithError(err).Warn("could not add address to profile")
		}
	}

	return nil
}

// createProfile creates a new profile for the organization and persists the
// returned profile ID back to the organization record.
func (e *OrganizationSave) createProfile(
	ctx context.Context,
	logger *util.LogEntry,
	organization *models.Organization,
	description, logoContentURI, domainName, contactEmail string,
) (string, error) {
	profileProps := buildProfileProperties(
		organization.Name,
		description,
		logoContentURI,
		domainName,
	)
	props, err := structpb.NewStruct(profileProps)
	if err != nil {
		return "", fmt.Errorf("building profile properties: %w", err)
	}

	contact := contactEmail
	if contact == "" {
		// Use org name as a fallback identifier when no email is available.
		contact = organization.Name
	}

	resp, err := e.profileClient.Create(ctx, connect.NewRequest(&profilev1.CreateRequest{
		Type:       profilev1.ProfileType_INSTITUTION,
		Contact:    contact,
		Properties: props,
	}))
	if err != nil {
		return "", fmt.Errorf("creating profile: %w", err)
	}

	profileID := resp.Msg.GetData().GetId()
	if profileID == "" {
		return "", errors.New("profile service returned empty profile ID")
	}

	logger.WithField("profile_id", profileID).Info("created profile for organization")

	// Persist the new profile ID on the organization.
	organization.ProfileID = profileID
	if _, updateErr := e.organizationRepo.Update(ctx, organization); updateErr != nil {
		logger.WithError(updateErr).Error("could not update organization with new profile ID")
		return profileID, fmt.Errorf("updating organization profile ID: %w", updateErr)
	}

	return profileID, nil
}

// updateProfile updates the properties of an existing profile.
func (e *OrganizationSave) updateProfile(
	ctx context.Context,
	logger *util.LogEntry,
	profileID, description, logoContentURI, domainName string,
) error {
	// Fetch current profile to get the name for merging.
	currentName := ""
	getResp, err := e.profileClient.GetById(
		ctx,
		connect.NewRequest(&profilev1.GetByIdRequest{Id: profileID}),
	)
	if err == nil && getResp.Msg.GetData() != nil {
		if p := getResp.Msg.GetData().GetProperties(); p != nil {
			if v, ok := p.AsMap()["name"].(string); ok {
				currentName = v
			}
		}
	}

	profileProps := buildProfileProperties(currentName, description, logoContentURI, domainName)
	props, err := structpb.NewStruct(profileProps)
	if err != nil {
		return fmt.Errorf("building profile properties: %w", err)
	}

	if _, updateErr := e.profileClient.Update(ctx, connect.NewRequest(profilev1.UpdateRequest_builder{
		Id:         profileID,
		Properties: props,
	}.Build())); updateErr != nil {
		logger.WithError(updateErr).WithField("profile_id", profileID).
			Warn("could not update profile")
		return fmt.Errorf("updating profile: %w", updateErr)
	}

	return nil
}

// addContact adds a single contact to the profile.
func (e *OrganizationSave) addContact(
	ctx context.Context,
	logger *util.LogEntry,
	profileID string,
	c orgContact,
) error {
	extras, err := structpb.NewStruct(map[string]any{
		"purpose": c.purpose,
		"type":    c.contactType,
	})
	if err != nil {
		return fmt.Errorf("building contact extras: %w", err)
	}

	if _, addErr := e.profileClient.AddContact(ctx, connect.NewRequest(profilev1.AddContactRequest_builder{
		Id:      profileID,
		Contact: c.value,
		Extras:  extras,
	}.Build())); addErr != nil {
		return fmt.Errorf("adding contact %s: %w", c.value, addErr)
	}

	logger.WithFields(map[string]any{
		"profile_id":   profileID,
		"contact_type": c.contactType,
	}).Info("added contact to profile")

	return nil
}

// addAddress adds an address to the profile.
func (e *OrganizationSave) addAddress(
	ctx context.Context,
	logger *util.LogEntry,
	profileID, street, city, country, postalCode string,
) error {
	if _, err := e.profileClient.AddAddress(ctx, connect.NewRequest(profilev1.AddAddressRequest_builder{
		Id: profileID,
		Address: profilev1.AddressObject_builder{
			Street:   street,
			City:     city,
			Country:  country,
			Postcode: postalCode,
		}.Build(),
	}.Build())); err != nil {
		return fmt.Errorf("adding address: %w", err)
	}

	logger.WithField("profile_id", profileID).Info("added address to profile")
	return nil
}

// orgContact represents a contact extracted from organization properties.
type orgContact struct {
	purpose     string
	contactType string
	value       string
}

// extractContacts reads the "contacts" key from properties and returns
// structured contact entries. Each contact is expected to be a map with
// "purpose", "type", and "value" keys.
func extractContacts(props data.JSONMap) []orgContact {
	rawContacts, ok := props["contacts"]
	if !ok {
		return nil
	}

	contactList, isList := rawContacts.([]any)
	if !isList {
		return nil
	}

	contacts := make([]orgContact, 0, len(contactList))
	for _, item := range contactList {
		m, isMap := item.(map[string]any)
		if !isMap {
			continue
		}
		purpose, _ := m["purpose"].(string)
		contactType, _ := m["type"].(string)
		value, _ := m["value"].(string)
		if value == "" {
			continue
		}
		contacts = append(contacts, orgContact{
			purpose:     purpose,
			contactType: contactType,
			value:       value,
		})
	}

	return contacts
}

// buildProfileProperties assembles the properties map for profile create/update.
func buildProfileProperties(name, description, logoContentURI, domainName string) map[string]any {
	props := map[string]any{}
	if name != "" {
		props["name"] = name
	}
	if description != "" {
		props["description"] = description
	}
	if logoContentURI != "" {
		props["avatar"] = logoContentURI
	}
	if domainName != "" {
		props["domain_name"] = domainName
	}
	return props
}
