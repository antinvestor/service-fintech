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
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/util"

	"github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

type OrganizationBusiness interface {
	Save(ctx context.Context, obj *identityv1.OrganizationObject) (*identityv1.OrganizationObject, error)
	Get(ctx context.Context, id string) (*identityv1.OrganizationObject, error)
	Search(
		ctx context.Context,
		search *commonv1.SearchRequest,
		consumer func(ctx context.Context, batch []*identityv1.OrganizationObject) error,
	) error
}

type organizationBusiness struct {
	eventsMan        fevents.Manager
	organizationRepo repository.OrganizationRepository
	partitionCli     tenancyv1connect.TenancyServiceClient
}

func NewOrganizationBusiness(
	_ context.Context,
	eventsMan fevents.Manager,
	organizationRepo repository.OrganizationRepository,
	partitionCli tenancyv1connect.TenancyServiceClient,
) OrganizationBusiness {
	return &organizationBusiness{
		eventsMan:        eventsMan,
		organizationRepo: organizationRepo,
		partitionCli:     partitionCli,
	}
}

func (b *organizationBusiness) Save(
	ctx context.Context,
	obj *identityv1.OrganizationObject,
) (*identityv1.OrganizationObject, error) {
	logger := util.Log(ctx).WithField("method", "OrganizationBusiness.Save")

	isNew := obj.GetId() == ""
	organization := models.OrganizationFromAPI(ctx, obj)
	if strings.TrimSpace(organization.GeoID) == "" {
		return nil, ErrCoverageAreaRequired
	}

	if isNew && organization.State == 0 {
		organization.State = int32(commonv1.STATE_CREATED.Number())
	}

	if isNew {
		claims := security.ClaimsFromContext(ctx)
		tenantID := claims.GetTenantID()
		parentPartitionID := claims.GetPartitionID()
		organization.TenantID = tenantID
		organization.PartitionID = b.createChildPartition(
			ctx, logger, tenantID, parentPartitionID, organization.Name,
		)
	}

	err := b.eventsMan.Emit(ctx, events.OrganizationSaveEvent, organization)
	if err != nil {
		logger.WithError(err).Error("could not emit organization save event")
		return nil, err
	}

	if isNew {
		IdentityOrganizationsCreated.Add(ctx, 1, metric.WithAttributes(
			attribute.String("tenant_id", organization.TenantID),
			attribute.String("partition_id", organization.PartitionID),
		))
	}

	return organization.ToAPI(), nil
}

func (b *organizationBusiness) createChildPartition(
	ctx context.Context,
	logger *util.LogEntry,
	tenantID, parentID, name string,
) string {
	if b.partitionCli == nil {
		logger.Warn("partition client is nil, using parent partition")
		return parentID
	}
	resp, err := b.partitionCli.CreatePartition(ctx, connect.NewRequest(
		&tenancyv1.CreatePartitionRequest{
			TenantId:    tenantID,
			ParentId:    parentID,
			Name:        name,
			Description: "Partition for organization: " + name,
		},
	))
	if err != nil {
		logger.WithError(err).Warn("failed to create child partition, using parent")
		return parentID
	}
	return resp.Msg.GetData().GetId()
}

func (b *organizationBusiness) Get(ctx context.Context, id string) (*identityv1.OrganizationObject, error) {
	organization, err := b.organizationRepo.GetByID(ctx, id)
	if err != nil {
		return nil, ErrOrganizationNotFound
	}
	return organization.ToAPI(), nil
}

func (b *organizationBusiness) Search(
	ctx context.Context,
	searchQuery *commonv1.SearchRequest,
	consumer func(ctx context.Context, batch []*identityv1.OrganizationObject) error,
) error {
	logger := util.Log(ctx).WithField("method", "OrganizationBusiness.Search")

	var searchOpts []data.SearchOption

	cursor := searchQuery.GetCursor()
	if cursor != nil {
		offset, offsetErr := strconv.Atoi(cursor.GetPage())
		if offsetErr != nil {
			offset = 0
		}
		searchOpts = append(searchOpts, data.WithSearchOffset(offset), data.WithSearchLimit(int(cursor.GetLimit())))
	}

	allowedExtras := map[string]bool{
		"partition_id": true,
		"code":         true,
		"profile_id":   true,
		"parent_id":    true,
	}

	andQueryVal := map[string]any{}
	for k, v := range searchQuery.GetExtras().AsMap() {
		if allowedExtras[k] {
			andQueryVal[fmt.Sprintf("%s = ?", k)] = v
		}
	}

	if searchQuery.GetIdQuery() != "" {
		andQueryVal["id = ?"] = searchQuery.GetIdQuery()
	}

	if len(andQueryVal) > 0 {
		searchOpts = append(searchOpts, data.WithSearchFiltersAndByValue(andQueryVal))
	}

	if searchQuery.GetQuery() != "" {
		searchOpts = append(searchOpts,
			data.WithSearchFiltersOrByValue(
				map[string]any{searchableTSQuery: searchQuery.GetQuery()},
			),
		)
		for _, filter := range searchQuery.GetProperties() {
			if allowedExtras[filter] {
				searchOpts = append(
					searchOpts,
					data.WithSearchFiltersOrByValue(
						map[string]any{fmt.Sprintf("%s = ?", filter): searchQuery.GetQuery()},
					),
				)
			}
		}
	}

	query := data.NewSearchQuery(searchOpts...)
	results, err := b.organizationRepo.Search(ctx, query)
	if err != nil {
		logger.WithError(err).Error("failed to search organizations")
		return err
	}

	return workerpoolConsumeStream(ctx, results, func(res []*models.Organization) error {
		var apiResults []*identityv1.OrganizationObject
		for _, organization := range res {
			apiResults = append(apiResults, organization.ToAPI())
		}
		return consumer(ctx, apiResults)
	})
}
