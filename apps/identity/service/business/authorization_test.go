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
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
	fevents "github.com/pitabwire/frame/v3/events"
	"github.com/pitabwire/frame/v3/frametests"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/v3/frametests/rlstest"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/tenancy"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/suite"

	identityevents "github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/models"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

const (
	testTenantID     = "tenant-authz"
	testPartitionID  = "partition-authz"
	testSubmitterID  = "profile-submitter"
	testReviewerID   = "profile-reviewer"
	testForeignPart  = "partition-intruder"
	testGeoID        = "kampala"
	testOrgUnitGeoID = "gulu"
)

type authorizationSuite struct {
	frametests.FrameBaseTestSuite
}

type authorizationEnv struct {
	t   *testing.T
	ctx context.Context

	organizationRepo repository.OrganizationRepository
	orgUnitRepo      repository.OrgUnitRepository
	workforceRepo    repository.WorkforceMemberRepository
	accessRoleRepo   repository.AccessRoleAssignmentRepository
	groupRepo        repository.ClientGroupRepository
	entryRepo        repository.ClientDataEntryRepository
	formTemplateRepo repository.FormTemplateRepository
	clientRepo       repository.ClientRepository

	eventsMan fevents.Manager

	orgBusiness          OrganizationBusiness
	workforceBusiness    WorkforceBusiness
	groupBusiness        ClientGroupBusiness
	clientDataBusiness   ClientDataBusiness
	formTemplateBusiness FormTemplateBusiness
}

func TestAuthorizationSuite(t *testing.T) {
	suite.Run(t, new(authorizationSuite))
}

func (s *authorizationSuite) SetupSuite() {
	s.InitResourceFunc = func(_ context.Context) []definition.TestResource {
		return []definition.TestResource{
			testpostgres.NewWithOpts(
				"identity_authorization",
				definition.WithUserName("ant"),
				definition.WithCredential("s3cr3t"),
				definition.WithEnableLogging(false),
			),
		}
	}
	s.FrameBaseTestSuite.SetupSuite()
}

// --- F1: every update must actually land -----------------------------------

func (s *authorizationSuite) TestOrganizationSaveTwicePersistsTheSecondName() {
	env := s.newEnv()

	created, err := env.orgBusiness.Save(env.ctx, &identityv1.OrganizationObject{
		Name:  "First Name",
		Code:  "double-save-org",
		GeoId: testGeoID,
	})
	s.Require().NoError(err)
	s.Require().NotEmpty(created.GetId())

	_, err = env.orgBusiness.Save(env.ctx, &identityv1.OrganizationObject{
		Id:    created.GetId(),
		Name:  "Second Name",
		Code:  "double-save-org",
		GeoId: testGeoID,
	})
	s.Require().NoError(err)

	stored, err := env.organizationRepo.GetByID(env.ctx, created.GetId())
	s.Require().NoError(err)
	s.Equal("Second Name", stored.Name, "the second save must be visible in the database")
}

func (s *authorizationSuite) TestWorkforceMemberSaveTwicePersistsTheSecondEngagement() {
	env := s.newEnv()
	org := env.createOrganization("Workforce Org", "workforce-double-save")

	created, err := env.workforceBusiness.WorkforceMemberSave(env.ctx, &identityv1.WorkforceMemberObject{
		OrganizationId: org.GetID(),
		ProfileId:      "profile-member-double",
		EngagementType: "employee",
	})
	s.Require().NoError(err)

	_, err = env.workforceBusiness.WorkforceMemberSave(env.ctx, &identityv1.WorkforceMemberObject{
		Id:             created.GetId(),
		OrganizationId: org.GetID(),
		ProfileId:      "profile-member-double",
		EngagementType: "contractor",
	})
	s.Require().NoError(err)

	stored, err := env.workforceRepo.GetByID(env.ctx, created.GetId())
	s.Require().NoError(err)
	s.Equal("contractor", stored.EngagementType)
}

// --- F1b: the domain version no longer shadows the optimistic lock ----------

func (s *authorizationSuite) TestFormTemplateDraftStaysUpdatable() {
	env := s.newEnv()

	created, err := env.formTemplateBusiness.Save(env.ctx, &identityv1.FormTemplateObject{
		Name:           "KYC Intake",
		EntityType:     "client",
		OrganizationId: "org-kyc",
	})
	s.Require().NoError(err)

	// A stale or invented domain version in the request neither blocks the
	// write nor changes the stored version.
	_, err = env.formTemplateBusiness.Save(env.ctx, &identityv1.FormTemplateObject{
		Id:             created.GetId(),
		Name:           "KYC Intake v2",
		EntityType:     "client",
		OrganizationId: "org-kyc",
		Version:        7,
	})
	s.Require().NoError(err)

	stored, err := env.formTemplateRepo.GetByID(env.ctx, created.GetId())
	s.Require().NoError(err)
	s.Equal("KYC Intake v2", stored.Name)
	s.Equal(int32(0), stored.TemplateVersion, "the domain version must not be the lock column")
}

func (s *authorizationSuite) TestPublishedFormTemplateIsNotRewritten() {
	env := s.newEnv()

	created, err := env.formTemplateBusiness.Save(env.ctx, &identityv1.FormTemplateObject{
		Name:           "KYC Intake",
		EntityType:     "client",
		OrganizationId: "org-kyc",
	})
	s.Require().NoError(err)
	published, err := env.formTemplateBusiness.Publish(env.ctx, created.GetId())
	s.Require().NoError(err)
	s.Equal(int32(1), published.GetVersion())

	_, err = env.formTemplateBusiness.Save(env.ctx, &identityv1.FormTemplateObject{
		Id:             created.GetId(),
		Name:           "KYC Intake v2",
		EntityType:     "client",
		OrganizationId: "org-kyc",
	})
	s.Require().ErrorIs(err, ErrFormTemplateNotDraft)

	stored, err := env.formTemplateRepo.GetByID(env.ctx, created.GetId())
	s.Require().NoError(err)
	s.Equal("KYC Intake", stored.Name)
}

func (s *authorizationSuite) TestFormTemplateSaveIgnoresRequestedStatus() {
	env := s.newEnv()

	created, err := env.formTemplateBusiness.Save(env.ctx, &identityv1.FormTemplateObject{
		Name:           "KYC Intake",
		EntityType:     "client",
		OrganizationId: "org-kyc",
		Status:         identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_PUBLISHED,
	})
	s.Require().NoError(err)
	s.Equal(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_DRAFT, created.GetStatus())

	stored, err := env.formTemplateRepo.GetByID(env.ctx, created.GetId())
	s.Require().NoError(err)
	s.Equal(int32(identityv1.FormTemplateStatus_FORM_TEMPLATE_STATUS_DRAFT), stored.Status)
}

func (s *authorizationSuite) TestFormTemplateSaveValidatesFields() {
	env := s.newEnv()
	text := identityv1.FormFieldType_FORM_FIELD_TYPE_TEXT

	tests := []struct {
		name   string
		fields []*identityv1.FormFieldDefinition
		want   error
	}{
		{"phone is kept on the profile", []*identityv1.FormFieldDefinition{
			{Key: "mobile", Label: "Mobile", FieldType: identityv1.FormFieldType_FORM_FIELD_TYPE_PHONE},
		}, ErrFormTemplateContactField},
		{"email is kept on the profile", []*identityv1.FormFieldDefinition{
			{Key: "email", Label: "Email", FieldType: identityv1.FormFieldType_FORM_FIELD_TYPE_EMAIL},
		}, ErrFormTemplateContactField},
		{"duplicate key", []*identityv1.FormFieldDefinition{
			{Key: "name", Label: "Name", FieldType: text},
			{Key: "name", Label: "Other", FieldType: text},
		}, ErrFormTemplateDuplicateField},
		{"select without options", []*identityv1.FormFieldDefinition{
			{Key: "kind", Label: "Kind", FieldType: identityv1.FormFieldType_FORM_FIELD_TYPE_SELECT},
		}, ErrFormTemplateInvalid},
		{"field without a type", []*identityv1.FormFieldDefinition{
			{Key: "x", Label: "X"},
		}, ErrFormTemplateInvalid},
	}
	for _, tc := range tests {
		s.Run(tc.name, func() {
			_, err := env.formTemplateBusiness.Save(env.ctx, &identityv1.FormTemplateObject{
				Name: "KYC", EntityType: "client", OrganizationId: "org-kyc", Fields: tc.fields,
			})
			s.Require().ErrorIs(err, tc.want)
		})
	}

	_, err := env.formTemplateBusiness.Save(env.ctx, &identityv1.FormTemplateObject{
		Name: "KYC", EntityType: "client",
	})
	s.Require().ErrorIs(err, ErrFormTemplateInvalid, "an organization is required")
}

// --- F3: the caller may not choose the partition it writes into ------------

func (s *authorizationSuite) TestOrganizationCreateIgnoresRequestPartition() {
	env := s.newEnv()

	created, err := env.orgBusiness.Save(env.ctx, &identityv1.OrganizationObject{
		Name:        "Planted Org",
		Code:        "planted-org",
		GeoId:       testGeoID,
		PartitionId: testForeignPart,
	})
	s.Require().NoError(err)

	stored, err := env.organizationRepo.GetByID(env.ctx, created.GetId())
	s.Require().NoError(err)
	s.Equal(testPartitionID, stored.PartitionID)
	s.NotEqual(testForeignPart, stored.PartitionID)
}

func (s *authorizationSuite) TestOrgUnitCreateIgnoresRequestPartition() {
	env := s.newEnv()
	org := env.createOrganization("Partition Org", "partition-org")

	unit := models.OrgUnitFromAPI(env.ctx, &identityv1.OrgUnitObject{
		OrganizationId: org.GetID(),
		Name:           "Planted Unit",
		Code:           "planted-unit",
		GeoId:          testOrgUnitGeoID,
		PartitionId:    testForeignPart,
	})
	s.Equal(testPartitionID, unit.PartitionID)
}

// --- F4: role keys and GLOBAL scope ----------------------------------------

func (s *authorizationSuite) TestAccessRoleAssignmentRejectsUnknownRoleKey() {
	env := s.newEnv()
	org := env.createOrganization("Role Org", "role-org")
	member := env.createWorkforceMember(org, "profile-target-unknown-role")

	_, err := env.workforceBusiness.AccessRoleAssignmentSave(env.ctx, &identityv1.AccessRoleAssignmentObject{
		MemberId:  member.GetID(),
		RoleKey:   "platform_admin",
		ScopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_ORGANIZATION,
		ScopeId:   org.GetID(),
	})
	s.Require().ErrorIs(err, ErrInvalidRoleKey)
}

func (s *authorizationSuite) TestAccessRoleAssignmentRejectsGlobalScopeForNonAdministrator() {
	env := s.newEnv()
	org := env.createOrganization("Global Org", "global-org")
	member := env.createWorkforceMember(org, "profile-target-global")

	_, err := env.workforceBusiness.AccessRoleAssignmentSave(env.ctx, &identityv1.AccessRoleAssignmentObject{
		MemberId:  member.GetID(),
		RoleKey:   AccessRoleKeyIdentityAdministrator,
		ScopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL,
	})
	s.Require().ErrorIs(err, ErrGlobalScopeForbidden)
}

func (s *authorizationSuite) TestAccessRoleAssignmentAllowsGlobalScopeForExistingAdministrator() {
	env := s.newEnv()
	org := env.createOrganization("Global Admin Org", "global-admin-org")
	adminMember := env.createWorkforceMember(org, testSubmitterID)
	target := env.createWorkforceMember(org, "profile-target-promotion")
	env.grantGlobalAdministrator(adminMember)

	granted, err := env.workforceBusiness.AccessRoleAssignmentSave(env.ctx, &identityv1.AccessRoleAssignmentObject{
		MemberId:  target.GetID(),
		RoleKey:   AccessRoleKeyIdentityAdministrator,
		ScopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL,
	})
	s.Require().NoError(err)
	s.Equal(target.GetID(), granted.GetMemberId())
}

func (s *authorizationSuite) TestAccessRoleAssignmentRejectsSelfGrant() {
	env := s.newEnv()
	org := env.createOrganization("Self Grant Org", "self-grant-org")
	member := env.createWorkforceMember(org, testSubmitterID)

	_, err := env.workforceBusiness.AccessRoleAssignmentSave(env.ctx, &identityv1.AccessRoleAssignmentObject{
		MemberId:  member.GetID(),
		RoleKey:   AccessRoleKeyIdentityAdministrator,
		ScopeType: identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_ORGANIZATION,
		ScopeId:   org.GetID(),
	})
	s.Require().ErrorIs(err, ErrSelfRoleGrant)
}

// --- F0b: platform_role is not free text -----------------------------------

func (s *authorizationSuite) TestWorkforceMemberSaveRejectsUnknownPlatformRole() {
	env := s.newEnv()
	org := env.createOrganization("Platform Role Org", "platform-role-org")

	_, err := env.workforceBusiness.WorkforceMemberSave(env.ctx, &identityv1.WorkforceMemberObject{
		OrganizationId: org.GetID(),
		ProfileId:      "profile-platform-role",
		Properties:     propertiesStruct(map[string]any{PropertyPlatformRole: "superuser"}),
	})
	s.Require().ErrorIs(err, ErrInvalidPlatformRole)
}

func (s *authorizationSuite) TestWorkforceMemberSaveAcceptsKnownPlatformRole() {
	env := s.newEnv()
	org := env.createOrganization("Platform Role Ok Org", "platform-role-ok-org")

	_, err := env.workforceBusiness.WorkforceMemberSave(env.ctx, &identityv1.WorkforceMemberObject{
		OrganizationId: org.GetID(),
		ProfileId:      "profile-platform-role-ok",
		Properties:     propertiesStruct(map[string]any{PropertyPlatformRole: "operator"}),
	})
	s.Require().NoError(err)
}

// --- F6: KYC review identity, state machine and separation of duties -------

func (s *authorizationSuite) TestClientDataReviewerComesFromClaimsNotTheRequest() {
	env := s.newEnv()
	entry := env.submitClientData("client-kyc-1", "national_id", "value-1")

	verified, err := env.clientDataBusiness.Verify(env.asProfile(testReviewerID), entry.GetID(), "checked")
	s.Require().NoError(err)
	s.Equal(testReviewerID, verified.ReviewerID)
}

func (s *authorizationSuite) TestClientDataVerifyRejectedForSubmitter() {
	env := s.newEnv()
	entry := env.submitClientData("client-kyc-2", "national_id", "value-2")

	_, err := env.clientDataBusiness.Verify(env.asProfile(testSubmitterID), entry.GetID(), "self approval")
	s.Require().ErrorIs(err, ErrReviewerIsSubmitter)
}

func (s *authorizationSuite) TestClientDataCannotBeVerifiedTwice() {
	env := s.newEnv()
	entry := env.submitClientData("client-kyc-3", "national_id", "value-3")

	_, err := env.clientDataBusiness.Verify(env.asProfile(testReviewerID), entry.GetID(), "checked")
	s.Require().NoError(err)

	_, err = env.clientDataBusiness.Verify(env.asProfile("profile-other-reviewer"), entry.GetID(), "again")
	s.Require().ErrorIs(err, ErrClientDataEntryNotReviewable)
}

func (s *authorizationSuite) TestClientDataCannotBeVerifiedAfterRejection() {
	env := s.newEnv()
	entry := env.submitClientData("client-kyc-4", "national_id", "value-4")

	_, err := env.clientDataBusiness.Reject(env.asProfile(testReviewerID), entry.GetID(), "illegible")
	s.Require().NoError(err)

	_, err = env.clientDataBusiness.Verify(env.asProfile("profile-other-reviewer"), entry.GetID(), "looks fine")
	s.Require().ErrorIs(err, ErrClientDataEntryNotReviewable)
}

func (s *authorizationSuite) TestClientDataRequestInfoKeepsEntryReviewable() {
	env := s.newEnv()
	entry := env.submitClientData("client-kyc-5", "national_id", "value-5")

	_, err := env.clientDataBusiness.RequestInfo(env.asProfile(testReviewerID), entry.GetID(), "send a clearer scan")
	s.Require().NoError(err)

	verified, err := env.clientDataBusiness.Verify(env.asProfile("profile-other-reviewer"), entry.GetID(), "now clear")
	s.Require().NoError(err)
	s.Equal(
		int32(identityv1.DataVerificationStatus_DATA_VERIFICATION_STATUS_VERIFIED),
		verified.VerificationStatus,
	)
}

// --- F2: client groups no longer depend on the retired agent model ---------

func (s *authorizationSuite) TestClientGroupSaveUsesWorkforceMemberOwner() {
	env := s.newEnv()
	org := env.createOrganization("Group Org", "group-org")
	owner := env.createWorkforceMember(org, "profile-group-owner")

	group := &models.ClientGroup{
		AgentID: owner.GetID(),
		Name:    "Kampala Savings Circle",
	}
	saved, err := env.groupBusiness.Save(env.ctx, group)
	s.Require().NoError(err)
	s.Require().NotEmpty(saved.GetID())

	stored, err := env.groupRepo.GetByID(env.ctx, saved.GetID())
	s.Require().NoError(err)
	s.Equal("Kampala Savings Circle", stored.Name)
}

func (s *authorizationSuite) TestClientGroupSaveRejectsMissingOwner() {
	env := s.newEnv()

	_, err := env.groupBusiness.Save(env.ctx, &models.ClientGroup{Name: "Ownerless"})
	s.Require().ErrorIs(err, ErrGroupOwnerRequired)
}

// --- F8/F9: page cursors are bounded and validated -------------------------

func (s *authorizationSuite) TestSearchLimitIsClamped() {
	s.Equal(defaultSearchLimit, clampSearchLimit(0))
	s.Equal(defaultSearchLimit, clampSearchLimit(-10))
	s.Equal(1, clampSearchLimit(1))
	s.Equal(maxSearchLimit, clampSearchLimit(100_000_000))
	s.Equal(maxSearchLimit, clampSearchLimit(maxSearchLimit))
}

func (s *authorizationSuite) TestCursorSearchOptionsRejectsMalformedPage() {
	_, err := cursorSearchOptions(&commonv1.PageCursor{Page: "12abc", Limit: 10})
	s.Require().ErrorIs(err, ErrInvalidPageToken)

	_, err = cursorSearchOptions(&commonv1.PageCursor{Page: "-1", Limit: 10})
	s.Require().ErrorIs(err, ErrInvalidPageToken)

	opts, err := cursorSearchOptions(&commonv1.PageCursor{Page: "", Limit: 10})
	s.Require().NoError(err)
	s.Len(opts, 2)
}

// --- env -------------------------------------------------------------------

func (s *authorizationSuite) newEnv() *authorizationEnv {
	s.T().Helper()

	ctx := s.T().Context()
	ctx = (&security.AuthenticationClaims{
		TenantID:    testTenantID,
		PartitionID: testPartitionID,
		RegisteredClaims: jwt.RegisteredClaims{
			Subject: testSubmitterID,
		},
	}).ClaimsToContext(ctx)

	db := s.databaseResource(ctx)
	dsn, cleanup, err := db.GetRandomisedDS(ctx, util.RandomAlphaNumericString(8))
	s.Require().NoError(err)
	s.T().Cleanup(func() { cleanup(ctx) })

	s.Require().NoError(rlstest.CreateRole(ctx, dsn.String()))
	rlsProv := rlstest.New()

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithName("identity-authorization-test"),
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
		&models.WorkforceMember{},
		&models.Department{},
		&models.Position{},
		&models.PositionAssignment{},
		&models.InternalTeam{},
		&models.TeamMembership{},
		&models.AccessRoleAssignment{},
		&models.ClientGroup{},
		&models.ClientDataEntry{},
		&models.ClientDataEntryHistory{},
		&models.FormTemplate{},
		&models.Client{},
	}

	superDB := dbPool.DB(ctx, false)
	s.Require().NoError(superDB.AutoMigrate(migrationModels...))

	enrolled, err := tenancy.EnrolledModels(superDB, migrationModels)
	s.Require().NoError(err)
	s.Require().NoError(rlsProv.Install(ctx, superDB, enrolled))
	s.Require().NoError(rlstest.GrantAll(ctx, dsn.String()))
	rlsProv.Enable()

	organizationRepo := repository.NewOrganizationRepository(ctx, dbPool, workMan)
	orgUnitRepo := repository.NewOrgUnitRepository(ctx, dbPool, workMan)
	branchRepo := repository.NewBranchRepository(ctx, dbPool, workMan)
	workforceRepo := repository.NewWorkforceMemberRepository(ctx, dbPool, workMan)
	departmentRepo := repository.NewDepartmentRepository(ctx, dbPool, workMan)
	positionRepo := repository.NewPositionRepository(ctx, dbPool, workMan)
	positionAssignmentRepo := repository.NewPositionAssignmentRepository(ctx, dbPool, workMan)
	internalTeamRepo := repository.NewInternalTeamRepository(ctx, dbPool, workMan)
	teamMembershipRepo := repository.NewTeamMembershipRepository(ctx, dbPool, workMan)
	accessRoleRepo := repository.NewAccessRoleAssignmentRepository(ctx, dbPool, workMan)
	groupRepo := repository.NewClientGroupRepository(ctx, dbPool, workMan)
	entryRepo := repository.NewClientDataEntryRepository(ctx, dbPool, workMan)
	historyRepo := repository.NewClientDataEntryHistoryRepository(ctx, dbPool, workMan)
	formTemplateRepo := repository.NewFormTemplateRepository(ctx, dbPool, workMan)
	clientRepo := repository.NewClientRepository(ctx, dbPool, workMan)

	evtsMan := newImmediateEventsManager(
		identityevents.NewOrganizationSave(ctx, organizationRepo, nil),
		identityevents.NewBranchSave(ctx, branchRepo),
		identityevents.NewWorkforceMemberSave(ctx, workforceRepo),
		identityevents.NewAccessRoleAssignmentSave(ctx, accessRoleRepo),
		identityevents.NewClientGroupSave(ctx, groupRepo),
		identityevents.NewClientDataEntrySave(ctx, entryRepo),
		identityevents.NewClientDataEntryHistorySave(ctx, historyRepo),
		identityevents.NewFormTemplateSave(ctx, formTemplateRepo),
	)

	return &authorizationEnv{
		t:                s.T(),
		ctx:              ctx,
		organizationRepo: organizationRepo,
		orgUnitRepo:      orgUnitRepo,
		workforceRepo:    workforceRepo,
		accessRoleRepo:   accessRoleRepo,
		groupRepo:        groupRepo,
		entryRepo:        entryRepo,
		clientRepo:       clientRepo,
		formTemplateRepo: formTemplateRepo,
		eventsMan:        evtsMan,
		orgBusiness:      NewOrganizationBusiness(ctx, evtsMan, organizationRepo, nil),
		workforceBusiness: NewWorkforceBusiness(
			evtsMan,
			organizationRepo,
			orgUnitRepo,
			workforceRepo,
			departmentRepo,
			positionRepo,
			positionAssignmentRepo,
			internalTeamRepo,
			teamMembershipRepo,
			accessRoleRepo,
			nil,
		),
		groupBusiness: NewClientGroupBusiness(ctx, evtsMan, workforceRepo, orgUnitRepo, groupRepo),
		clientDataBusiness: NewClientDataBusiness(ctx, evtsMan, entryRepo, historyRepo,
			WithClientGuard(clientRepo, workforceRepo, teamMembershipRepo, nil)),
		formTemplateBusiness: NewFormTemplateBusiness(ctx, evtsMan, formTemplateRepo),
	}
}

func (s *authorizationSuite) databaseResource(ctx context.Context) definition.DependancyConn {
	s.T().Helper()
	for _, resource := range s.Resources() {
		if resource.Name() == testpostgres.PostgresqlDBImage && resource.GetDS(ctx).IsDB() {
			return resource
		}
	}
	s.T().Fatal("postgres test resource not found")
	return nil
}

// asProfile returns the env context acting as a different profile in the same
// tenant and partition.
// asProfile is a member of staff (an operator) signed in as profileID.
func (e *authorizationEnv) asProfile(profileID string) context.Context {
	return (&security.AuthenticationClaims{
		TenantID:    testTenantID,
		PartitionID: testPartitionID,
		Roles:       []string{platformRoleOperator},
		RegisteredClaims: jwt.RegisteredClaims{
			Subject: profileID,
		},
	}).ClaimsToContext(e.ctx)
}

func (e *authorizationEnv) createOrganization(name, code string) *models.Organization {
	e.t.Helper()
	org := &models.Organization{
		Name:       name,
		Code:       code,
		GeoID:      testGeoID,
		State:      int32(commonv1.STATE_ACTIVE),
		ProfileID:  util.IDString(),
		ClientID:   util.IDString(),
		Properties: data.JSONMap{},
	}
	org.GenID(e.ctx)
	if err := e.organizationRepo.Create(e.ctx, org); err != nil {
		e.t.Fatalf("create organization: %v", err)
	}
	return org
}

func (e *authorizationEnv) createWorkforceMember(
	org *models.Organization,
	profileID string,
) *models.WorkforceMember {
	e.t.Helper()
	member := &models.WorkforceMember{
		OrganizationID: org.GetID(),
		ProfileID:      profileID,
		EngagementType: "employee",
		State:          int32(commonv1.STATE_ACTIVE),
		Properties:     data.JSONMap{},
	}
	member.GenID(e.ctx)
	if err := e.workforceRepo.Create(e.ctx, member); err != nil {
		e.t.Fatalf("create workforce member: %v", err)
	}
	return member
}

// grantGlobalAdministrator writes the GLOBAL identity_administrator assignment
// directly, standing in for the out of band bootstrap that seeds the first
// global administrator.
func (e *authorizationEnv) grantGlobalAdministrator(member *models.WorkforceMember) {
	e.t.Helper()
	assignment := &models.AccessRoleAssignment{
		MemberID:  member.GetID(),
		RoleKey:   AccessRoleKeyIdentityAdministrator,
		ScopeType: int32(identityv1.AccessScopeType_ACCESS_SCOPE_TYPE_GLOBAL),
		State:     int32(commonv1.STATE_ACTIVE),
	}
	assignment.GenID(e.ctx)
	if err := e.accessRoleRepo.Create(e.ctx, assignment); err != nil {
		e.t.Fatalf("create access role assignment: %v", err)
	}
}

func (e *authorizationEnv) submitClientData(clientID, fieldKey, value string) *models.ClientDataEntry {
	e.t.Helper()
	if _, err := e.clientRepo.GetByID(e.ctx, clientID); err != nil {
		client := &models.Client{Name: clientID}
		client.GenID(e.ctx)
		client.ID = clientID
		client.TenantID, client.PartitionID = testTenantID, testPartitionID
		if createErr := e.clientRepo.Create(e.ctx, client); createErr != nil {
			e.t.Fatalf("create client: %v", createErr)
		}
	}
	entry, err := e.clientDataBusiness.Save(e.asProfile(testSubmitterID), &models.ClientDataEntry{
		ClientID:  clientID,
		FieldKey:  fieldKey,
		Value:     value,
		ValueType: "string",
	})
	if err != nil {
		e.t.Fatalf("save client data entry: %v", err)
	}
	return entry
}
