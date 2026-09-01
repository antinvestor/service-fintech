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

package main

import (
	"context"
	"net/http"
	"strings"

	"buf.build/gen/go/antinvestor/field/connectrpc/go/field/v1/fieldv1connect"
	fieldpb "buf.build/gen/go/antinvestor/field/protocolbuffers/go/field/v1"
	"buf.build/gen/go/antinvestor/identity/connectrpc/go/identity/v1/identityv1connect"
	identitypb "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"buf.build/gen/go/antinvestor/notification/connectrpc/go/notification/v1/notificationv1connect"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/profile/v1/profilev1connect"
	"buf.build/gen/go/antinvestor/tenancy/connectrpc/go/tenancy/v1/tenancyv1connect"
	"buf.build/gen/go/antinvestor/tenancy/connectrpc/go/tenancy/v2/tenancyv2connect"
	"connectrpc.com/connect"
	"github.com/antinvestor/common/v2"
	"github.com/antinvestor/common/v2/connection"
	"github.com/antinvestor/common/v2/permissions"
	"github.com/antinvestor/common/v2/servicecatalog"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/config"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	fevents "github.com/pitabwire/frame/v2/events"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/frame/v2/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/v2/security/interceptors/connect"
	"github.com/pitabwire/frame/v2/setup"
	"github.com/pitabwire/frame/v2/workerpool"
	"github.com/pitabwire/util"

	"github.com/antinvestor/common/audit"

	aconfig "github.com/antinvestor/service-fintech/apps/identity/config"
	"github.com/antinvestor/service-fintech/apps/identity/service/authz"
	"github.com/antinvestor/service-fintech/apps/identity/service/business"
	identityevents "github.com/antinvestor/service-fintech/apps/identity/service/events"
	"github.com/antinvestor/service-fintech/apps/identity/service/handlers"
	"github.com/antinvestor/service-fintech/apps/identity/service/repository"
)

func main() {
	tmpCtx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.IdentityConfig](tmpCtx)
	if err != nil {
		util.Log(tmpCtx).With("err", err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_identity"
	}

	ctx, svc := frame.NewServiceWithContext(
		tmpCtx,
		frame.WithConfig(&cfg),
		frame.WithDatastore(),
	)

	svc.Setup().RegisterFunc(setup.NameMigrate, func(ctx context.Context) error {
		return repository.Migrate(ctx, svc.DatastoreManager(), cfg.GetDatabaseMigrationPath())
	})
	defer svc.Stop(ctx)
	log := util.Log(ctx)

	// Setup Job path only: migrate + permission manifest. No peer clients,
	// HTTP handlers, or queue consumers — those belong to runtime.
	// FieldService permissions are owned by the service-field SA; do not
	// register them under service-identity (ownership 403).
	identitySD := identitypb.File_identity_v1_identity_proto.Services().ByName("IdentityService")
	if frame.ShouldRunSetup(&cfg) {
		svc.Init(ctx, frame.WithPermissionRegistration(identitySD))
		if setupErr := svc.RunSetupForProcess(ctx, &cfg); setupErr != nil {
			log.WithError(setupErr).Fatal("setup plan failed")
		}
		return
	}

	sm := svc.SecurityManager()
	dbManager := svc.DatastoreManager()
	workMan := svc.WorkManager()
	evtsMan := svc.EventsManager()

	// Runtime: peer clients, handlers, queue consumers only.
	profileCli, err := setupProfileClient(ctx, cfg)
	if err != nil {
		log.WithError(err).Fatal("main -- Could not setup profile client")
	}

	partitionCli, err := setupTenancyClient(ctx, cfg)
	if err != nil {
		log.WithError(err).Fatal("main -- Could not setup partition client")
	}

	authContractCli, err := setupAuthContractClient(ctx, cfg)
	if err != nil {
		log.WithError(err).Fatal("main -- Could not setup auth contract client")
	}

	notificationCli, notifErr := setupNotificationClient(ctx, cfg)
	if notifErr != nil {
		log.WithError(notifErr).
			Warn("main -- Could not setup notification client, agent notifications will be disabled")
	}
	agentNotifier := business.NewAgentNotifier(notificationCli, profileCli, cfg.AgentOnboardingTemplate)

	// Get database pool
	dbPool := dbManager.GetPool(ctx, datastore.DefaultPoolName)
	if dbPool == nil {
		log.Error("Database pool is nil - check DATABASE_PRIMARY_URL environment variable")
		return
	}

	serviceOptions := setupServiceOptions(
		ctx,
		sm,
		evtsMan,
		dbPool,
		workMan,
		cfg,
		agentNotifier,
		partitionCli,
		authContractCli,
		profileCli,
	)

	svc.Init(ctx, serviceOptions...)

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
	}
}

func setupServiceOptions( //nolint:funlen // sequential service wiring
	ctx context.Context,
	sm security.Manager,
	evtsMan fevents.Manager,
	dbPool pool.Pool,
	workMan workerpool.Manager,
	cfg aconfig.IdentityConfig,
	agentNotifier *business.AgentNotifier,
	partitionCli tenancyv1connect.TenancyServiceClient,
	authContractCli tenancyv2connect.AuthContractServiceClient,
	profileCli profilev1connect.ProfileServiceClient,
) []frame.Option {
	organizationRepo := repository.NewOrganizationRepository(ctx, dbPool, workMan)
	orgUnitRepo := repository.NewOrgUnitRepository(ctx, dbPool, workMan)
	branchRepo := repository.NewBranchRepository(ctx, dbPool, workMan)
	agentRepo := repository.NewAgentRepository(ctx, dbPool, workMan)
	agentBranchRepo := repository.NewAgentBranchRepository(ctx, dbPool, workMan)
	clientRepo := repository.NewClientRepository(ctx, dbPool, workMan)
	clientHistoryRepo := repository.NewClientResponsibilityHistoryRepository(ctx, dbPool, workMan)
	clcrRepo := repository.NewCreditLimitChangeRequestRepository(ctx, dbPool, workMan)
	approvalCaseRepo := repository.NewApprovalCaseRepository(ctx, dbPool, workMan)
	groupRepo := repository.NewClientGroupRepository(ctx, dbPool, workMan)
	membershipRepo := repository.NewMembershipRepository(ctx, dbPool, workMan)
	investorRepo := repository.NewInvestorRepository(ctx, dbPool, workMan)
	workforceMemberRepo := repository.NewWorkforceMemberRepository(ctx, dbPool, workMan)
	departmentRepo := repository.NewDepartmentRepository(ctx, dbPool, workMan)
	positionRepo := repository.NewPositionRepository(ctx, dbPool, workMan)
	positionAssignmentRepo := repository.NewPositionAssignmentRepository(ctx, dbPool, workMan)
	internalTeamRepo := repository.NewInternalTeamRepository(ctx, dbPool, workMan)
	teamMembershipRepo := repository.NewTeamMembershipRepository(ctx, dbPool, workMan)
	accessRoleAssignmentRepo := repository.NewAccessRoleAssignmentRepository(ctx, dbPool, workMan)
	clientDataEntryRepo := repository.NewClientDataEntryRepository(ctx, dbPool, workMan)
	clientDataHistoryRepo := repository.NewClientDataEntryHistoryRepository(ctx, dbPool, workMan)

	approvalCaseNotifier := business.NewApprovalCaseNotifier(
		agentNotifier.Client(),
		agentNotifier.ProfileClient(),
		workforceMemberRepo,
		orgUnitRepo,
		clientRepo,
		internalTeamRepo,
		accessRoleAssignmentRepo,
	)
	approvalCaseBusiness := business.NewApprovalCaseBusiness(ctx, evtsMan, approvalCaseRepo, approvalCaseNotifier)
	organizationBusiness := business.NewOrganizationBusiness(ctx, evtsMan, organizationRepo, partitionCli)
	orgUnitBusiness := business.NewOrgUnitBusiness(
		ctx, evtsMan, organizationRepo, orgUnitRepo, partitionCli, approvalCaseBusiness,
	)
	agentBusiness := business.NewAgentBusiness(
		ctx,
		evtsMan,
		cfg.MaxAgentDepth,
		organizationRepo,
		branchRepo,
		agentRepo,
		agentBranchRepo,
		agentNotifier,
	)
	clientBusiness := business.NewClientBusiness(
		ctx,
		evtsMan,
		clientRepo,
		clientHistoryRepo,
		clcrRepo,
		approvalCaseBusiness,
		workforceMemberRepo,
		internalTeamRepo,
		teamMembershipRepo,
	)
	workforceBusiness := business.NewWorkforceBusiness(
		evtsMan,
		organizationRepo,
		orgUnitRepo,
		workforceMemberRepo,
		departmentRepo,
		positionRepo,
		positionAssignmentRepo,
		internalTeamRepo,
		teamMembershipRepo,
		accessRoleAssignmentRepo,
		partitionCli,
	)
	groupBusiness := business.NewClientGroupBusiness(ctx, evtsMan, agentRepo, groupRepo)
	membershipBusiness := business.NewMembershipBusiness(ctx, evtsMan, groupRepo, membershipRepo)
	investorBusiness := business.NewInvestorBusiness(ctx, evtsMan, investorRepo)
	clientDataBusiness := business.NewClientDataBusiness(ctx, evtsMan, clientDataEntryRepo, clientDataHistoryRepo)

	formTemplateRepo := repository.NewFormTemplateRepository(ctx, dbPool, workMan)
	formSubmissionRepo := repository.NewFormSubmissionRepository(ctx, dbPool, workMan)
	formTemplateBusiness := business.NewFormTemplateBusiness(ctx, evtsMan, formTemplateRepo)
	formSubmissionBusiness := business.NewFormSubmissionBusiness(ctx, evtsMan, formSubmissionRepo, formTemplateRepo)

	clientRelationshipRepo := repository.NewClientRelationshipRepository(ctx, dbPool, workMan)
	clientRelationshipBusiness := business.NewClientRelationshipBusiness(ctx, evtsMan, clientRelationshipRepo)

	oauthRedirectURIs := strings.Split(cfg.OAuthRedirectURIs, ",")
	oauthAudiences := strings.Split(cfg.OAuthAudiences, ",")
	loginClientBusiness := business.NewLoginClientBusiness(
		ctx, evtsMan, organizationRepo, branchRepo, partitionCli, authContractCli, oauthRedirectURIs, oauthAudiences,
	)

	connectHandler := setupConnectServer(
		ctx, sm, dbPool,
		organizationBusiness, orgUnitBusiness, workforceBusiness, agentBusiness, clientBusiness,
		groupBusiness, membershipBusiness, investorBusiness,
		loginClientBusiness, clientDataBusiness,
		formTemplateBusiness, formSubmissionBusiness,
		clientRelationshipBusiness,
	)

	// Runtime options only — permissions are registered exclusively in the
	// setup Job path (ShouldRunSetup) before this function is called.
	return []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithRegisterEvents(
			identityevents.NewOrganizationSave(ctx, organizationRepo, profileCli),
			identityevents.NewBranchSave(ctx, branchRepo),
			identityevents.NewAgentSave(ctx, agentRepo),
			identityevents.NewClientSave(ctx, clientRepo),
			identityevents.NewClientGroupSave(ctx, groupRepo),
			identityevents.NewMembershipSave(ctx, membershipRepo),
			identityevents.NewInvestorSave(ctx, investorRepo),
			identityevents.NewCreditLimitChangeRequestSave(ctx, clcrRepo),
			identityevents.NewApprovalCaseSave(ctx, approvalCaseRepo),
			identityevents.NewClientDataEntrySave(ctx, clientDataEntryRepo),
			identityevents.NewClientDataEntryHistorySave(ctx, clientDataHistoryRepo),
			identityevents.NewWorkforceMemberSave(ctx, workforceMemberRepo),
			identityevents.NewInternalTeamSave(ctx, internalTeamRepo),
			identityevents.NewTeamMembershipSave(ctx, teamMembershipRepo),
			identityevents.NewAccessRoleAssignmentSave(ctx, accessRoleAssignmentRepo),
			identityevents.NewFormTemplateSave(ctx, formTemplateRepo),
			identityevents.NewFormSubmissionSave(ctx, formSubmissionRepo),
			identityevents.NewClientRelationshipSave(ctx, clientRelationshipRepo),
			identityevents.NewDepartmentSave(ctx, departmentRepo),
			identityevents.NewPositionSave(ctx, positionRepo),
			identityevents.NewPositionAssignmentSave(ctx, positionAssignmentRepo),
		),
	}
}

func setupProfileClient(
	ctx context.Context,
	cfg aconfig.IdentityConfig,
) (profilev1connect.ProfileServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.ProfileServiceURI,
		WorkloadAPITargetPath: cfg.ProfileServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceProfile,
	}, profilev1connect.NewProfileServiceClient)
}

func setupNotificationClient(
	ctx context.Context,
	cfg aconfig.IdentityConfig,
) (notificationv1connect.NotificationServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.NotificationServiceURI,
		WorkloadAPITargetPath: cfg.NotificationServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceNotification,
	}, notificationv1connect.NewNotificationServiceClient)
}

func setupTenancyClient(
	ctx context.Context,
	cfg aconfig.IdentityConfig,
) (tenancyv1connect.TenancyServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.TenancyServiceURI,
		WorkloadAPITargetPath: cfg.TenancyServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceTenancy,
	}, tenancyv1connect.NewTenancyServiceClient)
}

func setupAuthContractClient(
	ctx context.Context,
	cfg aconfig.IdentityConfig,
) (tenancyv2connect.AuthContractServiceClient, error) {
	return connection.NewServiceClient(ctx, &cfg, common.ServiceTarget{
		Endpoint:              cfg.TenancyServiceURI,
		WorkloadAPITargetPath: cfg.TenancyServiceWorkloadAPITargetPath,
		ServiceID:             servicecatalog.ServiceTenancy,
	}, tenancyv2connect.NewAuthContractServiceClient)
}

func setupConnectServer(
	ctx context.Context,
	sm security.Manager,
	_ pool.Pool,
	organizationBusiness business.OrganizationBusiness,
	orgUnitBusiness business.OrgUnitBusiness,
	workforceBusiness business.WorkforceBusiness,
	agentBusiness business.AgentBusiness,
	clientBusiness business.ClientBusiness,
	groupBusiness business.ClientGroupBusiness,
	membershipBusiness business.MembershipBusiness,
	investorBusiness business.InvestorBusiness,
	loginClientBusiness business.LoginClientBusiness,
	clientDataBusiness business.ClientDataBusiness,
	formTemplateBusiness business.FormTemplateBusiness,
	formSubmissionBusiness business.FormSubmissionBusiness,
	clientRelationshipBusiness business.ClientRelationshipBusiness,
) http.Handler {
	// Create handlers with injected dependencies
	identityHandler := handlers.NewIdentityServer(
		organizationBusiness,
		orgUnitBusiness,
		workforceBusiness,
		groupBusiness,
		membershipBusiness,
		investorBusiness,
		clientDataBusiness,
		formTemplateBusiness,
		formSubmissionBusiness,
	)
	fieldHandler := handlers.NewFieldServer(
		agentBusiness,
		clientBusiness,
		clientRelationshipBusiness,
	)

	auth := sm.GetAuthorizer(ctx)

	// Layer 1: TenancyAccessChecker verifies caller can access the partition
	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)

	// Layer 2: FunctionAccessInterceptor enforces per-RPC permissions from proto annotations.
	// Each service gets its own FunctionChecker with the correct namespace.
	identitySD := identitypb.File_identity_v1_identity_proto.Services().ByName("IdentityService")
	identityProcMap := permissions.BuildProcedureMap(identitySD)
	identitySvcPerms := permissions.ForService(identitySD)
	identityFunctionChecker := authorizer.NewFunctionChecker(auth, identitySvcPerms.Namespace)
	identityFunctionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(
		identityFunctionChecker,
		identityProcMap,
	)

	fieldSD := fieldpb.File_field_v1_field_proto.Services().ByName("FieldService")
	fieldProcMap := permissions.BuildProcedureMap(fieldSD)
	fieldSvcPerms := permissions.ForService(fieldSD)
	fieldFunctionChecker := authorizer.NewFunctionChecker(auth, fieldSvcPerms.Namespace)
	fieldFunctionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(
		fieldFunctionChecker,
		fieldProcMap,
	)

	// Layer 3: Audit interceptor logs all non-idempotent calls and failed reads.
	identityAuditInterceptor := audit.NewInterceptor("service_identity", nil)
	fieldAuditInterceptor := audit.NewInterceptor("service_field", nil)

	identityInterceptorList, err := connectInterceptors.DefaultList(
		ctx,
		sm.GetAuthenticator(ctx),
		tenancyAccessInterceptor,
		identityFunctionAccessInterceptor,
		identityAuditInterceptor,
	)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create identity interceptors")
	}

	fieldInterceptorList, err := connectInterceptors.DefaultList(
		ctx, sm.GetAuthenticator(ctx),
		tenancyAccessInterceptor, fieldFunctionAccessInterceptor, fieldAuditInterceptor)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create field interceptors")
	}

	identityInterceptorOption := connect.WithInterceptors(identityInterceptorList...)
	fieldInterceptorOption := connect.WithInterceptors(fieldInterceptorList...)

	// Register both services on the same mux with their own interceptors
	identityPath, identityServerHandler := identityv1connect.NewIdentityServiceHandler(
		identityHandler,
		identityInterceptorOption,
	)
	fieldPath, fieldServerHandler := fieldv1connect.NewFieldServiceHandler(fieldHandler, fieldInterceptorOption)

	// Login targets endpoint — unauthenticated, no interceptors
	loginTargetsHandler := handlers.NewLoginTargetsHandler(loginClientBusiness)

	mux := http.NewServeMux()
	mux.Handle(identityPath, identityServerHandler)
	mux.Handle(fieldPath, fieldServerHandler)
	mux.Handle("/api/v1/login-targets/", loginTargetsHandler)

	return mux
}
