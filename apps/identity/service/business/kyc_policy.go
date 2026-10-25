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
	"fmt"

	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

// clientFormEntityType is the form template entity type that defines what an
// organization captures and requires of a client.
const clientFormEntityType = "client"

// maxOrganizationDepth bounds the walk up the organization tree, so a
// corrupt parent cycle cannot loop.
const maxOrganizationDepth = 16

// KYCRequirements is what an organization requires of one client and where
// the client stands against it.
type KYCRequirements struct {
	Template     *models.FormTemplate
	Requirements []*identityv1.ClientKYCRequirementStatus
	Complete     bool
}

// KYCPolicy resolves an organization's KYC requirements: the required fields
// of its newest published client form template. An organization without
// one uses its nearest ancestor's; with none anywhere, clients cannot be
// activated until one is published.
type KYCPolicy struct {
	teams     repository.InternalTeamRepository
	orgs      repository.OrganizationRepository
	templates repository.FormTemplateRepository
	entries   repository.ClientDataEntryRepository
}

// NewKYCPolicy builds the policy.
func NewKYCPolicy(
	teams repository.InternalTeamRepository,
	orgs repository.OrganizationRepository,
	templates repository.FormTemplateRepository,
	entries repository.ClientDataEntryRepository,
) *KYCPolicy {
	return &KYCPolicy{teams: teams, orgs: orgs, templates: templates, entries: entries}
}

// TemplateForTeam is the client form template for a client owned by teamID.
func (p *KYCPolicy) TemplateForTeam(ctx context.Context, teamID string) (*models.FormTemplate, error) {
	if p == nil || teamID == "" {
		return nil, ErrClientKYCNotConfigured
	}
	team, err := p.teams.GetByID(ctx, teamID)
	if err != nil || team == nil {
		return nil, ErrInternalTeamNotFound
	}
	orgID := team.OrganizationID
	for range maxOrganizationDepth {
		if orgID == "" {
			break
		}
		tmpl, tmplErr := p.templates.LatestPublished(ctx, orgID, clientFormEntityType)
		if tmplErr != nil {
			return nil, fmt.Errorf("load client form template: %w", tmplErr)
		}
		if tmpl != nil {
			return tmpl, nil
		}
		org, orgErr := p.orgs.GetByID(ctx, orgID)
		if orgErr != nil || org == nil {
			break
		}
		orgID = org.ParentID
	}
	return nil, ErrClientKYCNotConfigured
}

// ForClient is the client's organization's requirements and the status of
// each required field. Complete means every required field is VERIFIED.
func (p *KYCPolicy) ForClient(ctx context.Context, client *models.Client) (*KYCRequirements, error) {
	tmpl, err := p.TemplateForTeam(ctx, client.OwningTeamID)
	if err != nil {
		return nil, err
	}
	statuses, err := p.entryStatuses(ctx, client.GetID())
	if err != nil {
		return nil, err
	}
	out := &KYCRequirements{Template: tmpl, Complete: true}
	for _, field := range models.FieldsToAPI(tmpl.Fields) {
		if !field.GetRequired() {
			continue
		}
		status := statuses[field.GetKey()]
		out.Requirements = append(out.Requirements, &identityv1.ClientKYCRequirementStatus{
			FieldKey: field.GetKey(),
			Label:    field.GetLabel(),
			Status:   status,
		})
		if status != identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_VERIFIED {
			out.Complete = false
		}
	}
	return out, nil
}

func (p *KYCPolicy) entryStatuses(
	ctx context.Context,
	clientID string,
) (map[string]identityv1.DataVerificationStatus, error) {
	const pageSize = 200
	statuses := map[string]identityv1.DataVerificationStatus{}
	for offset := 0; ; offset += pageSize {
		entries, err := p.entries.GetByClientID(ctx, clientID, 0, offset, pageSize)
		if err != nil {
			return nil, fmt.Errorf("list client data: %w", err)
		}
		for _, e := range entries {
			statuses[e.FieldKey] = identityv1.DataVerificationStatus(e.VerificationStatus)
		}
		if len(entries) < pageSize {
			return statuses, nil
		}
	}
}
