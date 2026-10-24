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

	fieldv1 "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"github.com/pitabwire/frame/v3/data"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
	"github.com/antinvestor/service-fintech/pkg/apperrors"
)

type ClientRelationshipBusiness interface {
	Save(ctx context.Context, obj *fieldv1.ClientRelationshipObject) (*fieldv1.ClientRelationshipObject, error)
	Get(ctx context.Context, id string) (*fieldv1.ClientRelationshipObject, error)
	Search(
		ctx context.Context,
		req *fieldv1.ClientRelationshipSearchRequest,
		consumer func(ctx context.Context, batch []*fieldv1.ClientRelationshipObject) error,
	) error
}

type clientRelationshipBusiness struct {
	eventsMan          fevents.Manager
	crRepo             repository.ClientRelationshipRepository
	clientRepo         repository.ClientRepository
	workforceRepo      repository.WorkforceMemberRepository
	teamMembershipRepo repository.TeamMembershipRepository
}

func NewClientRelationshipBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	crRepo repository.ClientRelationshipRepository,
	opts ...Option,
) ClientRelationshipBusiness {
	o := applyOptions(opts)
	return &clientRelationshipBusiness{
		eventsMan:          eventsMan,
		crRepo:             crRepo,
		clientRepo:         o.clientRepo,
		workforceRepo:      o.workforceRepo,
		teamMembershipRepo: o.teamMembershipRepo,
	}
}

func (b *clientRelationshipBusiness) Save(
	ctx context.Context,
	obj *fieldv1.ClientRelationshipObject,
) (*fieldv1.ClientRelationshipObject, error) {
	logger := util.Log(ctx).WithField("method", "ClientRelationshipBusiness.Save")

	cr := models.ClientRelationshipFromAPI(ctx, obj)
	if err := carryStoredTenancy(ctx, b.crRepo, cr); err != nil {
		return nil, err
	}

	if err := b.validateRelationship(ctx, cr); err != nil {
		return nil, err
	}
	if err := b.requireClientInScope(ctx, cr.ClientID); err != nil {
		return nil, err
	}
	if obj.GetId() != "" {
		// An edit by id must be of a relationship on a client in scope too,
		// not only name one in its payload.
		stored, getErr := b.crRepo.GetByID(ctx, cr.GetID())
		if getErr != nil {
			return nil, ErrClientRelationshipNotFound
		}
		if err := b.requireClientInScope(ctx, stored.ClientID); err != nil {
			return nil, err
		}
	}

	return b.persistRelationship(ctx, logger, cr, obj.GetId() == "")
}

// persistRelationship writes the relationship synchronously: a collision
// with an existing (client, member) pair or a missing row fails here, not in
// a queue consumer after the caller was told it succeeded.
func (b *clientRelationshipBusiness) persistRelationship(
	ctx context.Context,
	logger *util.LogEntry,
	cr *models.ClientRelationship,
	isNew bool,
) (*fieldv1.ClientRelationshipObject, error) {
	if cr.IsPrimary {
		existing, _ := b.crRepo.GetPrimaryForClient(ctx, cr.ClientID)
		if existing != nil && existing.GetID() != cr.GetID() {
			existing.IsPrimary = false
			if _, err := b.crRepo.Update(ctx, existing, "is_primary"); err != nil {
				logger.WithError(err).Error("could not clear previous primary relationship")
				return nil, err
			}
		}
	}

	if isNew {
		if err := b.crRepo.Create(ctx, cr); err != nil {
			if data.ErrorIsDuplicateKey(err) {
				return nil, apperrors.NewError(
					apperrors.Conflict,
					"this member already has a relationship with the client",
				)
			}
			logger.WithError(err).Error("could not create client relationship")
			return nil, err
		}
		return cr.ToAPI(), nil
	}
	rows, err := b.crRepo.Update(ctx, cr)
	if err != nil {
		logger.WithError(err).Error("could not update client relationship")
		return nil, err
	}
	if rows == 0 {
		return nil, ErrClientRelationshipNotFound
	}
	return cr.ToAPI(), nil
}

func (b *clientRelationshipBusiness) Get(ctx context.Context, id string) (*fieldv1.ClientRelationshipObject, error) {
	cr, err := b.crRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrClientRelationshipNotFound
	}
	if scopeErr := b.requireClientInScope(ctx, cr.ClientID); scopeErr != nil {
		return nil, scopeErr
	}
	return cr.ToAPI(), nil
}

func (b *clientRelationshipBusiness) Search(
	ctx context.Context,
	req *fieldv1.ClientRelationshipSearchRequest,
	consumer func(ctx context.Context, batch []*fieldv1.ClientRelationshipObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "ClientRelationshipBusiness.Search")

	var searchOpts []data.SearchOption

	cursorOpts, cursorErr := cursorSearchOptions(req.GetCursor())
	if cursorErr != nil {
		return cursorErr
	}
	searchOpts = append(searchOpts, cursorOpts...)

	andQueryVal := map[string]any{}
	if req.GetClientId() != "" {
		andQueryVal["client_id = ?"] = req.GetClientId()
	}
	if req.GetMemberId() != "" {
		andQueryVal["member_id = ?"] = req.GetMemberId()
	}

	// A field agent sees only their own relationships.
	if !callerIsStaff(ctx) {
		scope, scopeErr := resolveCallerScope(ctx, b.workforceRepo, b.teamMembershipRepo)
		if scopeErr != nil {
			return scopeErr
		}
		andQueryVal["member_id = ?"] = scope.member.GetID()
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.crRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search client relationships")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.ClientRelationship) error {
		var apiResults []*fieldv1.ClientRelationshipObject
		for _, cr := range res {
			apiResults = append(apiResults, cr.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}

// validateRelationship checks the client exists, the member exists and the
// member actively belongs to the client's owning team. Without the look-ups
// (local development, tests) nothing is checked.
func (b *clientRelationshipBusiness) validateRelationship(ctx context.Context, cr *models.ClientRelationship) error {
	if cr.ClientID == "" || cr.MemberID == "" {
		return apperrors.NewError(apperrors.BadRequest, "client and member are required")
	}
	if b.clientRepo == nil || b.workforceRepo == nil || b.teamMembershipRepo == nil {
		return nil
	}
	client, err := b.clientRepo.GetByID(ctx, cr.ClientID)
	if err != nil {
		return ErrClientNotFound
	}
	if _, err = b.workforceRepo.GetByID(ctx, cr.MemberID); err != nil {
		return ErrWorkforceMemberNotFound
	}
	if client.OwningTeamID != "" {
		if _, err = b.teamMembershipRepo.GetActiveMembership(ctx, client.OwningTeamID, cr.MemberID); err != nil {
			return ErrMemberNotInTeam
		}
	}
	return nil
}

// requireClientInScope refuses a non-staff caller acting on a relationship
// of a client outside their teams and relationships. Without the look-ups
// (tests, local development) a non-staff caller is refused outright.
func (b *clientRelationshipBusiness) requireClientInScope(ctx context.Context, clientID string) error {
	if callerIsStaff(ctx) {
		return nil
	}
	scope, err := resolveCallerScope(ctx, b.workforceRepo, b.teamMembershipRepo)
	if err != nil {
		return err
	}
	if b.clientRepo == nil {
		return ErrClientOutsideCallerScope
	}
	client, err := b.clientRepo.GetByID(ctx, clientID)
	if err != nil {
		return ErrClientNotFound
	}
	if !clientInCallerScope(ctx, client, scope, b.crRepo) {
		return ErrClientOutsideCallerScope
	}
	return nil
}
