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
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/frametests"
	"github.com/pitabwire/frame/v2/frametests/definition"
	"github.com/pitabwire/frame/v2/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v2/frametests/rlstest"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/tenancy"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"

	identityevents "github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

type orgUnitSuite struct {
	frametests.FrameBaseTestSuite
}

type orgUnitTestEnv struct {
	t                *testing.T
	ctx              context.Context
	organizationRepo repository.OrganizationRepository
	orgUnitRepo      repository.OrgUnitRepository
	orgUnitBusiness  OrgUnitBusiness
	orgBusiness      OrganizationBusiness
}

func TestOrgUnitSuite(t *testing.T) {
	suite.Run(t, new(orgUnitSuite))
}

func (s *orgUnitSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"identity_org_unit",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

func (s *orgUnitSuite) newEnv() *orgUnitTestEnv {
	s.T().Helper()

	ctx := s.T().Context()
	ctx = (&security.AuthenticationClaims{
		TenantID:    "tenant-test",
		PartitionID: "partition-test",
		RegisteredClaims: jwt.RegisteredClaims{
			Subject: "profile-requestor",
		},
	}).ClaimsToContext(ctx)

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	// frame enforces tenant isolation via Postgres RLS, and the
	// testcontainer superuser bypasses RLS even with FORCE. rlstest
	// drops every connection to an unprivileged role once Enable is
	// called (after migration + grants below) so business/repository
	// queries run with the same isolation guarantees as production.
	s.Require().NoError(rlstest.CreateRole(ctx, dsn.String()))
	rlsProv := rlstest.New()

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("identity-org-unit-test"),
		frame.WithTenancyProvider(rlsProv),
		frame.WithDatastore(pool.WithConnection(dsn.String(), false)),
	)
	s.T().Cleanup(func() { svc.Stop(ctx) })

	svc.Init(ctx)

	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
	s.Require().NotNil(dbPool)
	workMan := svc.WorkManager()

	migrationModels := []any{
		&models.Organization{},
		&models.Branch{},
		&models.ApprovalCase{},
	}

	superDB := dbPool.DB(ctx, false)
	s.Require().NoError(superDB.AutoMigrate(migrationModels...))

	// Raw AutoMigrate does not run frame's tenancy install, so install
	// the RLS policies explicitly, grant the test role access, then
	// flip queries onto the unprivileged role.
	enrolled, err := tenancy.EnrolledModels(superDB, migrationModels)
	s.Require().NoError(err)
	s.Require().NoError(rlsProv.Install(ctx, superDB, enrolled))
	s.Require().NoError(rlstest.GrantAll(ctx, dsn.String()))
	rlsProv.Enable()

	organizationRepo := repository.NewOrganizationRepository(ctx, dbPool, workMan)
	orgUnitRepo := repository.NewOrgUnitRepository(ctx, dbPool, workMan)
	branchRepo := repository.NewBranchRepository(ctx, dbPool, workMan)
	approvalCaseRepo := repository.NewApprovalCaseRepository(ctx, dbPool, workMan)

	evtsMan := newImmediateEventsManager(
		identityevents.NewOrganizationSave(ctx, organizationRepo, nil),
		identityevents.NewBranchSave(ctx, branchRepo),
		identityevents.NewApprovalCaseSave(ctx, approvalCaseRepo),
	)

	approvalCaseBusiness := NewApprovalCaseBusiness(ctx, evtsMan, approvalCaseRepo, nil)
	orgUnitBusiness := NewOrgUnitBusiness(
		ctx,
		evtsMan,
		organizationRepo,
		orgUnitRepo,
		nil,
		approvalCaseBusiness,
	)
	orgBusiness := NewOrganizationBusiness(ctx, evtsMan, organizationRepo, nil)

	return &orgUnitTestEnv{
		t:                s.T(),
		ctx:              ctx,
		organizationRepo: organizationRepo,
		orgUnitRepo:      orgUnitRepo,
		orgUnitBusiness:  orgUnitBusiness,
		orgBusiness:      orgBusiness,
	}
}

func (s *orgUnitSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

func (e *orgUnitTestEnv) createOrganization(name, code, geoID string) *models.Organization {
	e.t.Helper()
	claims := security.ClaimsFromContext(e.ctx)
	org := &models.Organization{
		Name:       name,
		Code:       code,
		GeoID:      geoID,
		State:      int32(commonv1.STATE_ACTIVE),
		ProfileID:  util.IDString(),
		ClientID:   util.IDString(),
		Properties: data.JSONMap{},
	}
	org.GenID(e.ctx)
	if claims != nil {
		org.TenantID = claims.GetTenantID()
		org.PartitionID = claims.GetPartitionID()
	}
	require.NoError(e.t, e.organizationRepo.Create(e.ctx, org))
	return org
}

func (e *orgUnitTestEnv) createOrgUnit(
	org *models.Organization,
	name, code, geoID, parentID string,
	unitType identityv1.OrgUnitType,
) *models.Branch {
	e.t.Helper()
	claims := security.ClaimsFromContext(e.ctx)
	unit := &models.Branch{
		OrganizationID: org.GetID(),
		ParentID:       parentID,
		Name:           name,
		Code:           code,
		GeoID:          geoID,
		UnitType:       int32(unitType),
		State:          int32(commonv1.STATE_ACTIVE),
		Properties:     data.JSONMap{},
	}
	unit.GenID(e.ctx)
	if claims != nil {
		unit.TenantID = claims.GetTenantID()
		unit.PartitionID = claims.GetPartitionID()
	}
	require.NoError(e.t, e.orgUnitRepo.Create(e.ctx, unit))
	return unit
}

// --- Test 1: OrgUnitSearch rootOnly returns only root org units ---

func (s *orgUnitSuite) TestOrgUnitSearchRootOnlyReturnsOnlyRootUnits() {
	env := s.newEnv()
	org := env.createOrganization("Org Root Search", "org-root-search", "nairobi")

	// Create a root unit (no parent).
	root := env.createOrgUnit(org, "HQ", "hq-root", "nairobi", "", identityv1.OrgUnitType_ORG_UNIT_TYPE_REGION)

	// Create a child unit under the root.
	env.createOrgUnit(
		org,
		"Sub Branch",
		"sub-branch",
		"mombasa",
		root.GetID(),
		identityv1.OrgUnitType_ORG_UNIT_TYPE_BRANCH,
	)

	var results []*identityv1.OrgUnitObject
	err := env.orgUnitBusiness.Search(env.ctx, &identityv1.OrgUnitSearchRequest{
		OrganizationId: org.GetID(),
		RootOnly:       true,
	}, func(_ context.Context, batch []*identityv1.OrgUnitObject) error {
		results = append(results, batch...)
		return nil
	})
	s.Require().NoError(err)

	// Only the root unit should be returned.
	s.Require().Len(results, 1)
	s.Equal(root.GetID(), results[0].GetId())
	s.Equal("HQ", results[0].GetName())
}

func (s *orgUnitSuite) TestOrgUnitSearchWithoutRootOnlyReturnsAllUnits() {
	env := s.newEnv()
	org := env.createOrganization("Org All Search", "org-all-search", "kampala")

	root := env.createOrgUnit(
		org,
		"Head Office",
		"head-office",
		"kampala",
		"",
		identityv1.OrgUnitType_ORG_UNIT_TYPE_REGION,
	)
	env.createOrgUnit(
		org,
		"Field Office",
		"field-office",
		"gulu",
		root.GetID(),
		identityv1.OrgUnitType_ORG_UNIT_TYPE_BRANCH,
	)

	var results []*identityv1.OrgUnitObject
	err := env.orgUnitBusiness.Search(env.ctx, &identityv1.OrgUnitSearchRequest{
		OrganizationId: org.GetID(),
	}, func(_ context.Context, batch []*identityv1.OrgUnitObject) error {
		results = append(results, batch...)
		return nil
	})
	s.Require().NoError(err)

	// Both units should be returned.
	s.Require().Len(results, 2)
}

// --- Test 2: OrganizationSave requires geoId ---

func (s *orgUnitSuite) TestOrganizationSaveWithoutGeoIdReturnsError() {
	env := s.newEnv()

	_, err := env.orgBusiness.Save(env.ctx, &identityv1.OrganizationObject{
		Name: "Missing Geo Org",
		Code: "missing-geo-org",
		// GeoId intentionally omitted.
	})
	s.Require().Error(err)
	s.ErrorIs(err, ErrCoverageAreaRequired)
}

func (s *orgUnitSuite) TestOrganizationSaveWithEmptyGeoIdReturnsError() {
	env := s.newEnv()

	_, err := env.orgBusiness.Save(env.ctx, &identityv1.OrganizationObject{
		Name:  "Empty Geo Org",
		Code:  "empty-geo-org",
		GeoId: "   ", // whitespace-only should also be rejected.
	})
	s.Require().Error(err)
	s.ErrorIs(err, ErrCoverageAreaRequired)
}

func (s *orgUnitSuite) TestOrganizationSaveWithValidGeoIdSucceeds() {
	env := s.newEnv()

	result, err := env.orgBusiness.Save(env.ctx, &identityv1.OrganizationObject{
		Name:  "Valid Geo Org",
		Code:  "valid-geo-org",
		GeoId: "nairobi",
	})
	s.Require().NoError(err)
	s.Require().NotNil(result)
	s.NotEmpty(result.GetId())
	s.Equal("nairobi", result.GetGeoId())
}

// --- Test 3: OrganizationSave with properties round-trips ---

func (s *orgUnitSuite) TestOrganizationSaveWithPropertiesRoundTrips() {
	env := s.newEnv()

	props := propertiesStruct(map[string]any{
		"description": "A leading microfinance institution",
		"contacts":    "info@example.com",
		"address":     "123 Main Street, Nairobi",
	})

	result, err := env.orgBusiness.Save(env.ctx, &identityv1.OrganizationObject{
		Name:       "Props Org",
		Code:       "props-org",
		GeoId:      "nairobi",
		Properties: props,
	})
	s.Require().NoError(err)
	s.Require().NotNil(result)

	// Fetch the saved organization and verify properties are stored.
	fetched, err := env.orgBusiness.Get(env.ctx, result.GetId())
	s.Require().NoError(err)
	s.Require().NotNil(fetched.GetProperties())

	fetchedProps := fetched.GetProperties().AsMap()
	s.Equal("A leading microfinance institution", fetchedProps["description"])
	s.Equal("info@example.com", fetchedProps["contacts"])
	s.Equal("123 Main Street, Nairobi", fetchedProps["address"])
}

// --- Test 4: OrgUnitSave requires geoId ---

func (s *orgUnitSuite) TestOrgUnitSaveWithoutGeoIdReturnsError() {
	env := s.newEnv()
	org := env.createOrganization("Org Unit Geo Test", "org-unit-geo-test", "kampala")

	_, err := env.orgUnitBusiness.Save(env.ctx, &identityv1.OrgUnitObject{
		OrganizationId: org.GetID(),
		Name:           "No Geo Unit",
		Code:           "no-geo-unit",
		Type:           identityv1.OrgUnitType_ORG_UNIT_TYPE_BRANCH,
		// GeoId intentionally omitted.
	})
	s.Require().Error(err)
	s.ErrorIs(err, ErrCoverageAreaRequired)
}

func (s *orgUnitSuite) TestOrgUnitSaveWithEmptyGeoIdReturnsError() {
	env := s.newEnv()
	org := env.createOrganization("Org Unit Empty Geo", "org-unit-empty-geo", "kampala")

	_, err := env.orgUnitBusiness.Save(env.ctx, &identityv1.OrgUnitObject{
		OrganizationId: org.GetID(),
		Name:           "Empty Geo Unit",
		Code:           "empty-geo-unit",
		GeoId:          "  ",
		Type:           identityv1.OrgUnitType_ORG_UNIT_TYPE_BRANCH,
	})
	s.Require().Error(err)
	s.ErrorIs(err, ErrCoverageAreaRequired)
}

func (s *orgUnitSuite) TestOrgUnitSaveWithValidGeoIdSucceeds() {
	env := s.newEnv()
	org := env.createOrganization("Org Unit Valid Geo", "org-unit-valid-geo", "kampala")

	result, err := env.orgUnitBusiness.Save(env.ctx, &identityv1.OrgUnitObject{
		OrganizationId: org.GetID(),
		Name:           "Kampala Branch",
		Code:           "kampala-branch",
		GeoId:          "kampala",
		Type:           identityv1.OrgUnitType_ORG_UNIT_TYPE_BRANCH,
	})
	s.Require().NoError(err)
	s.Require().NotNil(result)
	s.NotEmpty(result.GetId())
	s.Equal("kampala", result.GetGeoId())
}

func (s *orgUnitSuite) TestOrgUnitSaveInheritsOrganizationPartition() {
	env := s.newEnv()
	org := env.createOrganization("Org Inherit Partition", "org-inherit-partition", "kampala")

	result, err := env.orgUnitBusiness.Save(env.ctx, &identityv1.OrgUnitObject{
		OrganizationId: org.GetID(),
		Name:           "Inherited Partition Unit",
		Code:           "inherited-partition-unit",
		GeoId:          "kampala",
		Type:           identityv1.OrgUnitType_ORG_UNIT_TYPE_BRANCH,
	})
	s.Require().NoError(err)
	s.Require().NotNil(result)

	// The org unit should inherit the organization's partition since no partition client is configured.
	s.Equal(org.PartitionID, result.GetPartitionId())
}

// --- Cross-tenant RLS isolation ---

// withTenant layers authentication claims for a different tenant on top
// of the env's service context, so queries hit the same database but
// run under another principal's tenancy scope.
func (e *orgUnitTestEnv) withTenant(tenantID, partitionID, profileID string) context.Context {
	return (&security.AuthenticationClaims{
		TenantID:    tenantID,
		PartitionID: partitionID,
		RegisteredClaims: jwt.RegisteredClaims{
			Subject: profileID,
		},
	}).ClaimsToContext(e.ctx)
}

func (s *orgUnitSuite) TestOrganizationGetByIDCrossTenantReturnsNotFound() {
	env := s.newEnv()
	org := env.createOrganization("Org Tenant A Only", "org-tenant-a-only", "nairobi")

	// Sanity: the owning tenant can read its own organization back.
	got, err := env.organizationRepo.GetByID(env.ctx, org.GetID())
	s.Require().NoError(err)
	s.Require().Equal(org.GetID(), got.GetID())

	// A principal from another tenant must not see the row at all.
	ctxB := env.withTenant("tenant-intruder", "partition-intruder", "profile-intruder")
	_, err = env.organizationRepo.GetByID(ctxB, org.GetID())
	s.Require().Error(err, "cross-tenant GetByID must not return tenant A's organization")
	s.Require().ErrorIs(err, gorm.ErrRecordNotFound)
}

func (s *orgUnitSuite) TestOrgUnitSearchCrossTenantReturnsEmpty() {
	env := s.newEnv()
	org := env.createOrganization("Org Search Isolation", "org-search-isolation", "kampala")
	env.createOrgUnit(
		org,
		"Isolated HQ",
		"isolated-hq",
		"kampala",
		"",
		identityv1.OrgUnitType_ORG_UNIT_TYPE_REGION,
	)

	collect := func(out *[]*identityv1.OrgUnitObject) func(context.Context, []*identityv1.OrgUnitObject) error {
		return func(_ context.Context, batch []*identityv1.OrgUnitObject) error {
			*out = append(*out, batch...)
			return nil
		}
	}

	// Sanity: the owning tenant sees its unit.
	var ownResults []*identityv1.OrgUnitObject
	err := env.orgUnitBusiness.Search(env.ctx, &identityv1.OrgUnitSearchRequest{
		OrganizationId: org.GetID(),
	}, collect(&ownResults))
	s.Require().NoError(err)
	s.Require().Len(ownResults, 1)

	// Another tenant searching with the very same organization id must get nothing.
	ctxB := env.withTenant("tenant-intruder", "partition-intruder", "profile-intruder")
	var intruderResults []*identityv1.OrgUnitObject
	err = env.orgUnitBusiness.Search(ctxB, &identityv1.OrgUnitSearchRequest{
		OrganizationId: org.GetID(),
	}, collect(&intruderResults))
	s.Require().NoError(err)
	s.Empty(intruderResults, "tenant B must not see tenant A's org units")
}
