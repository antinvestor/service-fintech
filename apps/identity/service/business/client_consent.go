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

package business

import (
	"context"
	"strings"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

// Consent handshake carried in client properties. The first registration
// of an existing person returns consent_verification_id with
// consent_status "pending" and no client id; the agent resubmits the same
// registration with that id and the code the person received.
const (
	consentVerificationIDKey = "consent_verification_id"
	consentCodeKey           = "consent_code"
	consentStatusKey         = "consent_status"
	consentStatusPending     = "pending"
	consentCodeTTL           = 15 * time.Minute
	consentMaxAttempts       = 5
)

type consentProperties struct {
	verificationID string
	code           string
}

// takeConsentProperties removes the handshake keys from props: they are
// never stored on the client.
func takeConsentProperties(props map[string]any) consentProperties {
	c := consentProperties{
		verificationID: strings.TrimSpace(stringValue(props[consentVerificationIDKey])),
		code:           strings.TrimSpace(stringValue(props[consentCodeKey])),
	}
	delete(props, consentVerificationIDKey)
	delete(props, consentCodeKey)
	delete(props, consentStatusKey)
	return c
}

// requireConsent gates binding an existing person to a new client. It
// returns a pending response when a code has just been sent, nil when the
// person consented (or is already a client, which the caller handles), and
// an error when the code is wrong, spent, expired or cannot be sent.
func (b *clientBusiness) requireConsent(
	ctx context.Context,
	client *models.Client,
	profile *profilev1.ProfileObject,
	scope *callerScope,
	consent consentProperties,
) (*fieldv1.ClientObject, error) {
	if existing, err := b.clientRepo.GetByProfileID(ctx, client.ProfileID); err == nil && existing != nil {
		return nil, nil //nolint:nilnil // already a client: the caller applies its scope rules
	}
	if b.consentRepo == nil || b.profiles == nil {
		return nil, ErrClientProfileUnavailable
	}
	now := time.Now().UTC()
	if consent.verificationID == "" {
		return b.startConsent(ctx, client, profile, scope, now)
	}

	challenge, err := b.consentRepo.GetByID(ctx, consent.verificationID)
	if err != nil || challenge.ProfileID != client.ProfileID || challenge.MemberID != scope.member.GetID() ||
		consent.code == "" {
		return nil, ErrClientConsentFailed
	}
	allowed, err := b.consentRepo.TakeAttempt(ctx, challenge.GetID(), consentMaxAttempts, now)
	if err != nil || !allowed {
		return nil, ErrClientConsentFailed
	}
	checked, err := b.profiles.CheckVerification(ctx, &profilev1.CheckVerificationRequest{
		Id: challenge.GetID(), Code: consent.code,
	})
	if err != nil || !checked.GetSuccess() {
		return nil, ErrClientConsentFailed
	}
	used, err := b.consentRepo.MarkUsed(ctx, challenge.GetID(), now)
	if err != nil || !used {
		return nil, ErrClientConsentFailed
	}
	return nil, nil //nolint:nilnil // consent given: the caller binds the client
}

// startConsent sends a code to the person's verified mobile contact and
// records the challenge. The pending response reveals nothing about the
// person: no client id, no profile id, only the opaque challenge id.
func (b *clientBusiness) startConsent(
	ctx context.Context,
	client *models.Client,
	profile *profilev1.ProfileObject,
	scope *callerScope,
	now time.Time,
) (*fieldv1.ClientObject, error) {
	contactID := consentContactID(profile)
	if contactID == "" {
		return nil, ErrClientConsentUnreachable
	}
	challenge := &models.ClientConsentChallenge{
		ProfileID: client.ProfileID,
		ContactID: contactID,
		MemberID:  scope.member.GetID(),
		ExpiresAt: now.Add(consentCodeTTL),
	}
	challenge.GenID(ctx)
	if err := b.consentRepo.Create(ctx, challenge); err != nil {
		return nil, err
	}
	if _, err := b.profiles.CreateContactVerification(ctx, &profilev1.CreateContactVerificationRequest{
		Id:               challenge.GetID(),
		ContactId:        contactID,
		DurationToExpire: consentCodeTTL.String(),
	}); err != nil {
		util.Log(ctx).WithError(err).Warn("could not send the consent code")
		return nil, ErrClientProfileUnavailable
	}
	return &fieldv1.ClientObject{
		Name: client.Name,
		Properties: (&data.JSONMap{
			consentVerificationIDKey: challenge.GetID(),
			consentStatusKey:         consentStatusPending,
		}).ToProtoStruct(),
	}, nil
}

// consentContactID picks the contact the consent code goes to: the
// person's verified, active mobile contact. A person with none is
// registered by staff.
func consentContactID(profile *profilev1.ProfileObject) string {
	for _, c := range profile.GetContacts() {
		if c.GetType() == profilev1.ContactType_MSISDN && c.GetVerified() && c.GetId() != "" &&
			c.GetState() != commonv1.STATE_DELETED && c.GetState() != commonv1.STATE_INACTIVE {
			return c.GetId()
		}
	}
	return ""
}
