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
	"strconv"
	"strings"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"buf.build/gen/go/antinvestor/tenancy/connectrpc/go/tenancy/v1/tenancyv1connect"
	tenancyv1 "buf.build/gen/go/antinvestor/tenancy/protocolbuffers/go/tenancy/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	fevents "github.com/pitabwire/frame/events"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

type OrgUnitBusiness interface {
	Save(ctx context.Context, obj *identityv1.OrgUnitObject) (*identityv1.OrgUnitObject, error)
	Get(ctx context.Context, id string) (*identityv1.OrgUnitObject, error)
	Search(
		ctx context.Context,
		req *identityv1.OrgUnitSearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.OrgUnitObject) error,
	) error
}

type orgUnitBusiness struct {
	eventsMan        fevents.Manager
	organizationRepo repository.OrganizationRepository
	orgUnitRepo      repository.OrgUnitRepository
	partitionCli     tenancyv1connect.TenancyServiceClient
	approvalCases    ApprovalCaseBusiness
}

func NewOrgUnitBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	organizationRepo repository.OrganizationRepository,
	orgUnitRepo repository.OrgUnitRepository,
	partitionCli tenancyv1connect.TenancyServiceClient,
	approvalCases ApprovalCaseBusiness,
) OrgUnitBusiness {
	return &orgUnitBusiness{
		eventsMan:        eventsMan,
		organizationRepo: organizationRepo,
		orgUnitRepo:      orgUnitRepo,
		partitionCli:     partitionCli,
		approvalCases:    approvalCases,
	}
}

func (b *orgUnitBusiness) Save(
	ctx context.Context,
	obj *identityv1.OrgUnitObject,
) (*identityv1.OrgUnitObject, error) {
	logger := util.Log(ctx).WithField("method", "OrgUnitBusiness.Save")

	org, err := b.organizationRepo.GetByID(ctx, obj.GetOrganizationId())
	if err != nil {
		logger.WithError(err).Warn("organization not found for org unit")
		return nil, ErrOrganizationNotFound
	}

	orgUnit := models.OrgUnitFromAPI(ctx, obj)
	orgUnit.Properties = entityProperties(orgUnit.Properties)

	if orgUnit.UnitType == int32(identityv1.OrgUnitType_ORG_UNIT_TYPE_UNSPECIFIED) {
		orgUnit.UnitType = int32(identityv1.OrgUnitType_ORG_UNIT_TYPE_BRANCH)
	}

	if parentErr := b.validateParent(ctx, orgUnit); parentErr != nil {
		return nil, parentErr
	}

	if action := caseAction(orgUnit.Properties); action != "" {
		result, actionErr := b.handleApprovalAction(ctx, logger, orgUnit, action)
		if actionErr != nil {
			return nil, actionErr
		}
		return result, nil
	}
	if strings.TrimSpace(orgUnit.GeoID) == "" {
		return nil, ErrCoverageAreaRequired
	}

	isNew := obj.GetId() == ""
	if isNew && orgUnit.State == 0 {
		orgUnit.State = int32(commonv1.STATE_CREATED.Number())
	}

	if isNew {
		commandProps := entityProperties(orgUnit.Properties)
		orgUnit.TenantID = org.TenantID
		orgUnit.PartitionID, err = b.resolveParentPartitionID(ctx, orgUnit)
		if err != nil {
			return nil, err
		}
		stripCaseCommand(orgUnit.Properties)

		if err = b.eventsMan.Emit(ctx, events.BranchSaveEvent, orgUnit); err != nil {
			logger.WithError(err).Error("could not emit org unit save event")
			return nil, err
		}
		if createErr := b.submitOrgUnitCreateCase(
			ctx,
			logger,
			orgUnit,
			caseActorID(commandProps),
			caseComment(commandProps),
		); createErr != nil {
			logger.WithError(createErr).Warn("org unit created without approval case metadata")
		}

		IdentityOrgUnitsCreated.Add(ctx, 1, metric.WithAttributes(
			attribute.String("tenant_id", orgUnit.TenantID),
			attribute.String("partition_id", orgUnit.PartitionID),
		))

		return b.toAPI(ctx, orgUnit)
	}

	existing, err := b.orgUnitRepo.GetByID(ctx, orgUnit.GetID())
	if err != nil {
		logger.WithError(err).Warn("org unit not found for update")
		return nil, ErrOrgUnitNotFound
	}
	orgUnit.TenantID = existing.TenantID
	orgUnit.PartitionID = existing.PartitionID
	stripCaseCommand(orgUnit.Properties)

	if err = b.eventsMan.Emit(ctx, events.BranchSaveEvent, orgUnit); err != nil {
		logger.WithError(err).Error("could not emit org unit save event")
		return nil, err
	}

	return b.toAPI(ctx, orgUnit)
}

func (b *orgUnitBusiness) validateParent(ctx context.Context, orgUnit *models.Branch) error {
	if orgUnit == nil || orgUnit.ParentID == "" {
		return nil
	}
	if orgUnit.GetID() != "" && orgUnit.GetID() == orgUnit.ParentID {
		return ErrOrgUnitNotFound.Extend("org unit cannot be its own parent")
	}

	parent, err := b.orgUnitRepo.GetByID(ctx, orgUnit.ParentID)
	if err != nil {
		return ErrOrgUnitNotFound
	}
	if parent.OrganizationID != orgUnit.OrganizationID {
		return ErrOrgUnitNotInOrganization
	}

	// Detect circular parent chains (max 20 levels deep).
	if orgUnit.GetID() != "" {
		visited := map[string]bool{orgUnit.GetID(): true}
		current := parent
		for depth := 0; depth < 20 && current.ParentID != ""; depth++ {
			if visited[current.ParentID] {
				return ErrCircularParentChain
			}
			visited[current.GetID()] = true
			ancestor, aErr := b.orgUnitRepo.GetByID(ctx, current.ParentID)
			if aErr != nil {
				// Cannot resolve further ancestors; stop walking the chain.
				return nil //nolint:nilerr // partial chain walk is not an error
			}
			current = ancestor
		}
	}

	return nil
}

func (b *orgUnitBusiness) submitOrgUnitCreateCase(
	ctx context.Context,
	logger *util.LogEntry,
	orgUnit *models.Branch,
	actorID, comment string,
) error {
	actorID = resolveCaseActorID(ctx, actorID, orgUnit.CreatedBy)
	requestedState := orgUnit.State
	if requestedState == 0 {
		requestedState = int32(commonv1.STATE_CREATED.Number())
	}

	approvalCase, err := b.approvalCases.Submit(ctx, ApprovalCaseSubmission{
		SubjectType:         approvalCaseSubjectBranch,
		SubjectID:           orgUnit.GetID(),
		CaseType:            approvalCaseTypeBranchCreate,
		Summary:             fmt.Sprintf("Org unit %s requires verification and approval", orgUnit.Name),
		RequestedBy:         actorID,
		Comment:             comment,
		RequireVerification: true,
		Payload: map[string]any{
			"organization_id": orgUnit.OrganizationID,
			"parent_id":       orgUnit.ParentID,
			"requested_state": requestedState,
			"unit_type":       orgUnit.UnitType,
		},
	})
	if err != nil {
		logger.WithError(err).Error("could not create org unit approval case")
		return err
	}

	orgUnit.Properties = applyApprovalCaseSnapshot(orgUnit.Properties, approvalCase)

	if err = b.eventsMan.Emit(ctx, events.BranchSaveEvent, orgUnit); err != nil {
		logger.WithError(err).Error("could not emit org unit save event")
		return err
	}

	return nil
}

func (b *orgUnitBusiness) handleApprovalAction(
	ctx context.Context,
	logger *util.LogEntry,
	orgUnit *models.Branch,
	action string,
) (*identityv1.OrgUnitObject, error) {
	if orgUnit.GetID() == "" {
		return nil, ErrOrgUnitNotFound
	}

	existing, err := b.orgUnitRepo.GetByID(ctx, orgUnit.GetID())
	if err != nil {
		logger.WithError(err).Warn("org unit not found for approval action")
		return nil, ErrOrgUnitNotFound
	}

	props := entityProperties(existing.Properties)
	caseID := openApprovalCaseID(props)
	approvalCase, err := b.resolveApprovalCase(ctx, caseID, existing.GetID())
	if err != nil {
		return nil, err
	}

	actorID := caseActorID(orgUnit.Properties)
	comment := caseComment(orgUnit.Properties)

	approvalCase, err = b.transitionApprovalAction(ctx, logger, existing, approvalCase, action, actorID, comment)
	if err != nil {
		return nil, err
	}

	stripCaseCommand(props)
	existing.Properties = applyApprovalCaseSnapshot(props, approvalCase)
	if err = b.eventsMan.Emit(ctx, events.BranchSaveEvent, existing); err != nil {
		logger.WithError(err).Error("could not persist org unit approval action")
		return nil, err
	}

	logApprovalCaseTransition(ctx, action, approvalCase)
	return b.toAPI(ctx, existing)
}

func (b *orgUnitBusiness) transitionApprovalAction(
	ctx context.Context,
	logger *util.LogEntry,
	existing *models.Branch,
	approvalCase *models.ApprovalCase,
	action, actorID, comment string,
) (*models.ApprovalCase, error) {
	switch action {
	case approvalCaseActionVerify:
		return b.approvalCases.Verify(ctx, approvalCase.GetID(), actorID, comment)
	case approvalCaseActionApprove:
		return b.approveOrgUnitCase(ctx, logger, existing, approvalCase, actorID, comment)
	case approvalCaseActionReject:
		return b.rejectOrgUnitCase(ctx, existing, approvalCase, actorID, comment)
	default:
		return nil, ErrApprovalCaseNotPending.Extend("unsupported case action")
	}
}

func (b *orgUnitBusiness) approveOrgUnitCase(
	ctx context.Context,
	logger *util.LogEntry,
	existing *models.Branch,
	approvalCase *models.ApprovalCase,
	actorID, comment string,
) (*models.ApprovalCase, error) {
	approvedCase, err := b.approvalCases.Approve(ctx, approvalCase.GetID(), actorID, comment)
	if err != nil {
		return nil, err
	}

	parentPartitionID, partitionErr := b.resolveParentPartitionID(ctx, existing)
	if partitionErr != nil {
		return nil, partitionErr
	}
	if existing.PartitionID == "" || existing.PartitionID == parentPartitionID {
		organization, orgErr := b.organizationRepo.GetByID(ctx, existing.OrganizationID)
		if orgErr != nil {
			return nil, ErrOrganizationNotFound
		}
		partitionID, createErr := b.createChildPartition(
			ctx, logger, organization.TenantID, parentPartitionID, existing.Name,
		)
		if createErr != nil {
			return nil, createErr
		}
		existing.PartitionID = partitionID
		existing.TenantID = organization.TenantID
	}

	if requestedState := int32Value(approvedCase.Payload["requested_state"]); requestedState != 0 {
		existing.State = requestedState
	}

	if unitType := int32Value(approvedCase.Payload["unit_type"]); unitType != 0 {
		existing.UnitType = unitType
	}

	return approvedCase, nil
}

func (b *orgUnitBusiness) resolveParentPartitionID(
	ctx context.Context,
	orgUnit *models.Branch,
) (string, error) {
	if orgUnit.ParentID != "" {
		parent, err := b.orgUnitRepo.GetByID(ctx, orgUnit.ParentID)
		if err != nil {
			return "", ErrOrgUnitNotFound
		}
		if parent.PartitionID == "" {
			return "", ErrLoginClientCreationFailed.Extend("parent org unit partition is empty")
		}
		return parent.PartitionID, nil
	}

	org, err := b.organizationRepo.GetByID(ctx, orgUnit.OrganizationID)
	if err != nil {
		return "", ErrOrganizationNotFound
	}
	return org.PartitionID, nil
}

func (b *orgUnitBusiness) rejectOrgUnitCase(
	ctx context.Context,
	existing *models.Branch,
	approvalCase *models.ApprovalCase,
	actorID, comment string,
) (*models.ApprovalCase, error) {
	rejectedCase, err := b.approvalCases.Reject(ctx, approvalCase.GetID(), actorID, comment)
	if err != nil {
		return nil, err
	}
	existing.State = int32(commonv1.STATE_INACTIVE.Number())
	return rejectedCase, nil
}

func (b *orgUnitBusiness) resolveApprovalCase(
	ctx context.Context,
	caseID, orgUnitID string,
) (*models.ApprovalCase, error) {
	if caseID != "" {
		approvalCase, err := b.approvalCases.GetOpenBySubject(
			ctx,
			approvalCaseSubjectBranch,
			orgUnitID,
			approvalCaseTypeBranchCreate,
		)
		if err == nil && approvalCase != nil && approvalCase.GetID() == caseID {
			return approvalCase, nil
		}
	}

	approvalCase, err := b.approvalCases.GetOpenBySubject(
		ctx,
		approvalCaseSubjectBranch,
		orgUnitID,
		approvalCaseTypeBranchCreate,
	)
	if err != nil {
		return nil, ErrApprovalCaseNotFound
	}
	return approvalCase, nil
}

func (b *orgUnitBusiness) createChildPartition(
	ctx context.Context,
	logger *util.LogEntry,
	tenantID, parentID, name string,
) (string, error) {
	if b.partitionCli == nil {
		logger.Warn("partition client is nil")
		return "", ErrLoginClientCreationFailed.Extend("partition client is nil")
	}
	resp, err := b.partitionCli.CreatePartition(ctx, connect.NewRequest(
		&tenancyv1.CreatePartitionRequest{
			TenantId:    tenantID,
			ParentId:    parentID,
			Name:        name,
			Description: "Partition for org unit: " + name,
		},
	))
	if err != nil {
		logger.WithError(err).Warn("failed to create child partition")
		return "", ErrLoginClientCreationFailed.Extend("failed to create child partition")
	}
	return resp.Msg.GetData().GetId(), nil
}

func (b *orgUnitBusiness) Get(ctx context.Context, id string) (*identityv1.OrgUnitObject, error) {
	orgUnit, err := b.orgUnitRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrOrgUnitNotFound
	}
	return b.toAPI(ctx, orgUnit)
}

func (b *orgUnitBusiness) Search(
	ctx context.Context,
	req *identityv1.OrgUnitSearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.OrgUnitObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "OrgUnitBusiness.Search")

	var searchOpts []data.SearchOption

	cursor := req.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

	andQueryVal := map[string]any{}
	if req.GetOrganizationId() != "" {
		andQueryVal["organization_id = ?"] = req.GetOrganizationId()
	}
	if req.GetParentId() != "" {
		andQueryVal["parent_id = ?"] = req.GetParentId()
	}
	if req.GetRootOnly() {
		andQueryVal["parent_id IS NULL OR parent_id = ''"] = ""
	}
	if req.GetType() != identityv1.OrgUnitType_ORG_UNIT_TYPE_UNSPECIFIED {
		andQueryVal["unit_type = ?"] = int32(req.GetType())
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if req.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{searchableTSQuery: req.GetQuery()},
			),
		)
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.orgUnitRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search org units")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.Branch) error {
		apiResults := make([]*identityv1.OrgUnitObject, 0, len(res))
		for _, orgUnit := range res {
			apiObj, convErr := b.toAPI(ctx, orgUnit)
			if convErr != nil {
				return convErr
			}
			apiResults = append(apiResults, apiObj)
		}
		return consumer(ctx, apiResults)
	})
}

func (b *orgUnitBusiness) toAPI(
	ctx context.Context,
	orgUnit *models.Branch,
) (*identityv1.OrgUnitObject, error) {
	hasChildren, err := b.orgUnitRepo.HasChildren(ctx, orgUnit.GetID())
	if err != nil {
		return nil, err
	}
	return orgUnit.ToOrgUnitAPI(hasChildren), nil
}
