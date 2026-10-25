//
//  Generated code. Do not modify.
//  source: identity/v1/identity.proto
//

import "package:connectrpc/connect.dart" as connect;
import "identity.pb.dart" as identityv1identity;
import "../../common/v1/common.pb.dart" as commonv1common;

/// IdentityService manages organizations, org units, workforce members, form templates,
/// and data collection for the platform.
/// Canonical workforce, hierarchy, team, and access-control concepts live here.
/// All RPCs require authentication via Bearer token.
/// IdentityService still binds investor_account_* to its roles although the
/// investor account RPCs are served by funding: tenancy refuses to drop a
/// role binding through registration, so removing them needs a deliberate
/// tenancy-side change rather than a manifest edit.
abstract final class IdentityService {
  /// Fully-qualified name of the IdentityService service.
  static const name = 'identity.v1.IdentityService';

  /// OrganizationSave creates or updates an organization record.
  static const organizationSave = connect.Spec(
    '/$name/OrganizationSave',
    connect.StreamType.unary,
    identityv1identity.OrganizationSaveRequest.new,
    identityv1identity.OrganizationSaveResponse.new,
  );

  /// OrganizationGet retrieves an organization by its ID.
  static const organizationGet = connect.Spec(
    '/$name/OrganizationGet',
    connect.StreamType.unary,
    identityv1identity.OrganizationGetRequest.new,
    identityv1identity.OrganizationGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// OrganizationSearch finds organizations matching search criteria.
  static const organizationSearch = connect.Spec(
    '/$name/OrganizationSearch',
    connect.StreamType.server,
    commonv1common.SearchRequest.new,
    identityv1identity.OrganizationSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// OrgUnitSave creates or updates a hierarchical org unit record.
  static const orgUnitSave = connect.Spec(
    '/$name/OrgUnitSave',
    connect.StreamType.unary,
    identityv1identity.OrgUnitSaveRequest.new,
    identityv1identity.OrgUnitSaveResponse.new,
  );

  /// OrgUnitGet retrieves an org unit by its ID.
  static const orgUnitGet = connect.Spec(
    '/$name/OrgUnitGet',
    connect.StreamType.unary,
    identityv1identity.OrgUnitGetRequest.new,
    identityv1identity.OrgUnitGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// OrgUnitSearch finds org units matching search criteria.
  static const orgUnitSearch = connect.Spec(
    '/$name/OrgUnitSearch',
    connect.StreamType.server,
    identityv1identity.OrgUnitSearchRequest.new,
    identityv1identity.OrgUnitSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const workforceMemberSave = connect.Spec(
    '/$name/WorkforceMemberSave',
    connect.StreamType.unary,
    identityv1identity.WorkforceMemberSaveRequest.new,
    identityv1identity.WorkforceMemberSaveResponse.new,
  );

  static const workforceMemberGet = connect.Spec(
    '/$name/WorkforceMemberGet',
    connect.StreamType.unary,
    identityv1identity.WorkforceMemberGetRequest.new,
    identityv1identity.WorkforceMemberGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const workforceMemberSearch = connect.Spec(
    '/$name/WorkforceMemberSearch',
    connect.StreamType.server,
    identityv1identity.WorkforceMemberSearchRequest.new,
    identityv1identity.WorkforceMemberSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const departmentSave = connect.Spec(
    '/$name/DepartmentSave',
    connect.StreamType.unary,
    identityv1identity.DepartmentSaveRequest.new,
    identityv1identity.DepartmentSaveResponse.new,
  );

  static const departmentGet = connect.Spec(
    '/$name/DepartmentGet',
    connect.StreamType.unary,
    identityv1identity.DepartmentGetRequest.new,
    identityv1identity.DepartmentGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const departmentSearch = connect.Spec(
    '/$name/DepartmentSearch',
    connect.StreamType.server,
    identityv1identity.DepartmentSearchRequest.new,
    identityv1identity.DepartmentSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const positionSave = connect.Spec(
    '/$name/PositionSave',
    connect.StreamType.unary,
    identityv1identity.PositionSaveRequest.new,
    identityv1identity.PositionSaveResponse.new,
  );

  static const positionGet = connect.Spec(
    '/$name/PositionGet',
    connect.StreamType.unary,
    identityv1identity.PositionGetRequest.new,
    identityv1identity.PositionGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const positionSearch = connect.Spec(
    '/$name/PositionSearch',
    connect.StreamType.server,
    identityv1identity.PositionSearchRequest.new,
    identityv1identity.PositionSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const positionAssignmentSave = connect.Spec(
    '/$name/PositionAssignmentSave',
    connect.StreamType.unary,
    identityv1identity.PositionAssignmentSaveRequest.new,
    identityv1identity.PositionAssignmentSaveResponse.new,
  );

  static const positionAssignmentGet = connect.Spec(
    '/$name/PositionAssignmentGet',
    connect.StreamType.unary,
    identityv1identity.PositionAssignmentGetRequest.new,
    identityv1identity.PositionAssignmentGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const positionAssignmentSearch = connect.Spec(
    '/$name/PositionAssignmentSearch',
    connect.StreamType.server,
    identityv1identity.PositionAssignmentSearchRequest.new,
    identityv1identity.PositionAssignmentSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const internalTeamSave = connect.Spec(
    '/$name/InternalTeamSave',
    connect.StreamType.unary,
    identityv1identity.InternalTeamSaveRequest.new,
    identityv1identity.InternalTeamSaveResponse.new,
  );

  static const internalTeamGet = connect.Spec(
    '/$name/InternalTeamGet',
    connect.StreamType.unary,
    identityv1identity.InternalTeamGetRequest.new,
    identityv1identity.InternalTeamGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const internalTeamSearch = connect.Spec(
    '/$name/InternalTeamSearch',
    connect.StreamType.server,
    identityv1identity.InternalTeamSearchRequest.new,
    identityv1identity.InternalTeamSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const teamMembershipSave = connect.Spec(
    '/$name/TeamMembershipSave',
    connect.StreamType.unary,
    identityv1identity.TeamMembershipSaveRequest.new,
    identityv1identity.TeamMembershipSaveResponse.new,
  );

  static const teamMembershipGet = connect.Spec(
    '/$name/TeamMembershipGet',
    connect.StreamType.unary,
    identityv1identity.TeamMembershipGetRequest.new,
    identityv1identity.TeamMembershipGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const teamMembershipSearch = connect.Spec(
    '/$name/TeamMembershipSearch',
    connect.StreamType.server,
    identityv1identity.TeamMembershipSearchRequest.new,
    identityv1identity.TeamMembershipSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const accessRoleAssignmentSave = connect.Spec(
    '/$name/AccessRoleAssignmentSave',
    connect.StreamType.unary,
    identityv1identity.AccessRoleAssignmentSaveRequest.new,
    identityv1identity.AccessRoleAssignmentSaveResponse.new,
  );

  static const accessRoleAssignmentGet = connect.Spec(
    '/$name/AccessRoleAssignmentGet',
    connect.StreamType.unary,
    identityv1identity.AccessRoleAssignmentGetRequest.new,
    identityv1identity.AccessRoleAssignmentGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const accessRoleAssignmentSearch = connect.Spec(
    '/$name/AccessRoleAssignmentSearch',
    connect.StreamType.server,
    identityv1identity.AccessRoleAssignmentSearchRequest.new,
    identityv1identity.AccessRoleAssignmentSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// InvestorSave creates or updates an investor record.
  static const investorSave = connect.Spec(
    '/$name/InvestorSave',
    connect.StreamType.unary,
    identityv1identity.InvestorSaveRequest.new,
    identityv1identity.InvestorSaveResponse.new,
  );

  /// InvestorGet retrieves an investor by their ID.
  static const investorGet = connect.Spec(
    '/$name/InvestorGet',
    connect.StreamType.unary,
    identityv1identity.InvestorGetRequest.new,
    identityv1identity.InvestorGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// InvestorSearch finds investors matching search criteria.
  static const investorSearch = connect.Spec(
    '/$name/InvestorSearch',
    connect.StreamType.server,
    identityv1identity.InvestorSearchRequest.new,
    identityv1identity.InvestorSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// ClientGroupSave creates or updates a client group record.
  static const clientGroupSave = connect.Spec(
    '/$name/ClientGroupSave',
    connect.StreamType.unary,
    identityv1identity.ClientGroupSaveRequest.new,
    identityv1identity.ClientGroupSaveResponse.new,
  );

  /// ClientGroupGet retrieves a client group by its ID.
  static const clientGroupGet = connect.Spec(
    '/$name/ClientGroupGet',
    connect.StreamType.unary,
    identityv1identity.ClientGroupGetRequest.new,
    identityv1identity.ClientGroupGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// ClientGroupSearch finds client groups matching search criteria.
  static const clientGroupSearch = connect.Spec(
    '/$name/ClientGroupSearch',
    connect.StreamType.server,
    identityv1identity.ClientGroupSearchRequest.new,
    identityv1identity.ClientGroupSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// MembershipSave creates or updates a membership record.
  static const membershipSave = connect.Spec(
    '/$name/MembershipSave',
    connect.StreamType.unary,
    identityv1identity.MembershipSaveRequest.new,
    identityv1identity.MembershipSaveResponse.new,
  );

  /// MembershipGet retrieves a membership by its ID.
  static const membershipGet = connect.Spec(
    '/$name/MembershipGet',
    connect.StreamType.unary,
    identityv1identity.MembershipGetRequest.new,
    identityv1identity.MembershipGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// MembershipSearch finds memberships matching search criteria.
  static const membershipSearch = connect.Spec(
    '/$name/MembershipSearch',
    connect.StreamType.server,
    identityv1identity.MembershipSearchRequest.new,
    identityv1identity.MembershipSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// InvestorAccountSave creates or updates an investor capital account.
  /// Deprecated: use funding.v1.FundingService instead.
  static const investorAccountSave = connect.Spec(
    '/$name/InvestorAccountSave',
    connect.StreamType.unary,
    identityv1identity.InvestorAccountSaveRequest.new,
    identityv1identity.InvestorAccountSaveResponse.new,
  );

  /// InvestorAccountGet retrieves an investor account by its ID.
  /// Deprecated: use funding.v1.FundingService instead.
  static const investorAccountGet = connect.Spec(
    '/$name/InvestorAccountGet',
    connect.StreamType.unary,
    identityv1identity.InvestorAccountGetRequest.new,
    identityv1identity.InvestorAccountGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// InvestorAccountSearch finds investor accounts matching search criteria.
  /// Deprecated: use funding.v1.FundingService instead.
  static const investorAccountSearch = connect.Spec(
    '/$name/InvestorAccountSearch',
    connect.StreamType.server,
    identityv1identity.InvestorAccountSearchRequest.new,
    identityv1identity.InvestorAccountSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// InvestorDeposit adds funds to an investor capital account.
  /// Deprecated: use funding.v1.FundingService instead.
  static const investorDeposit = connect.Spec(
    '/$name/InvestorDeposit',
    connect.StreamType.unary,
    identityv1identity.InvestorDepositRequest.new,
    identityv1identity.InvestorDepositResponse.new,
  );

  /// InvestorWithdraw removes funds from an investor capital account.
  /// Deprecated: use funding.v1.FundingService instead.
  static const investorWithdraw = connect.Spec(
    '/$name/InvestorWithdraw',
    connect.StreamType.unary,
    identityv1identity.InvestorWithdrawRequest.new,
    identityv1identity.InvestorWithdrawResponse.new,
  );

  /// ClientDataSave creates or updates a client data entry.
  static const clientDataSave = connect.Spec(
    '/$name/ClientDataSave',
    connect.StreamType.unary,
    identityv1identity.ClientDataSaveRequest.new,
    identityv1identity.ClientDataSaveResponse.new,
  );

  /// ClientDataGet retrieves a single data entry by client_id and field_key.
  static const clientDataGet = connect.Spec(
    '/$name/ClientDataGet',
    connect.StreamType.unary,
    identityv1identity.ClientDataGetRequest.new,
    identityv1identity.ClientDataGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// ClientDataList lists all data entries for a client with optional status filter.
  static const clientDataList = connect.Spec(
    '/$name/ClientDataList',
    connect.StreamType.server,
    identityv1identity.ClientDataListRequest.new,
    identityv1identity.ClientDataListResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// ClientKYCRequirements returns what an organization requires of a
  /// client: its published client form template, whose required fields must
  /// be VERIFIED before the client is activated. Each organization sets its
  /// own; a child organization without one uses its parent's.
  static const clientKYCRequirements = connect.Spec(
    '/$name/ClientKYCRequirements',
    connect.StreamType.unary,
    identityv1identity.ClientKYCRequirementsRequest.new,
    identityv1identity.ClientKYCRequirementsResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// ClientDataStartReview takes a data entry for review.
  static const clientDataStartReview = connect.Spec(
    '/$name/ClientDataStartReview',
    connect.StreamType.unary,
    identityv1identity.ClientDataStartReviewRequest.new,
    identityv1identity.ClientDataStartReviewResponse.new,
  );

  /// ClientDataVerify marks a data entry as verified.
  static const clientDataVerify = connect.Spec(
    '/$name/ClientDataVerify',
    connect.StreamType.unary,
    identityv1identity.ClientDataVerifyRequest.new,
    identityv1identity.ClientDataVerifyResponse.new,
  );

  /// ClientDataReject marks a data entry as rejected.
  static const clientDataReject = connect.Spec(
    '/$name/ClientDataReject',
    connect.StreamType.unary,
    identityv1identity.ClientDataRejectRequest.new,
    identityv1identity.ClientDataRejectResponse.new,
  );

  /// ClientDataRequestInfo requests more information for a data entry.
  static const clientDataRequestInfo = connect.Spec(
    '/$name/ClientDataRequestInfo',
    connect.StreamType.unary,
    identityv1identity.ClientDataRequestInfoRequest.new,
    identityv1identity.ClientDataRequestInfoResponse.new,
  );

  /// ClientDataHistory retrieves the revision history for a data entry.
  static const clientDataHistory = connect.Spec(
    '/$name/ClientDataHistory',
    connect.StreamType.unary,
    identityv1identity.ClientDataHistoryRequest.new,
    identityv1identity.ClientDataHistoryResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// FormTemplateSave creates or updates a form template.
  static const formTemplateSave = connect.Spec(
    '/$name/FormTemplateSave',
    connect.StreamType.unary,
    identityv1identity.FormTemplateSaveRequest.new,
    identityv1identity.FormTemplateSaveResponse.new,
  );

  /// FormTemplateGet retrieves a form template by its ID.
  static const formTemplateGet = connect.Spec(
    '/$name/FormTemplateGet',
    connect.StreamType.unary,
    identityv1identity.FormTemplateGetRequest.new,
    identityv1identity.FormTemplateGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// FormTemplateSearch finds form templates matching search criteria.
  static const formTemplateSearch = connect.Spec(
    '/$name/FormTemplateSearch',
    connect.StreamType.server,
    identityv1identity.FormTemplateSearchRequest.new,
    identityv1identity.FormTemplateSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// FormTemplatePublish transitions a draft form template to published.
  static const formTemplatePublish = connect.Spec(
    '/$name/FormTemplatePublish',
    connect.StreamType.unary,
    identityv1identity.FormTemplatePublishRequest.new,
    identityv1identity.FormTemplatePublishResponse.new,
  );

  /// FormSubmissionSave creates or updates a form submission.
  static const formSubmissionSave = connect.Spec(
    '/$name/FormSubmissionSave',
    connect.StreamType.unary,
    identityv1identity.FormSubmissionSaveRequest.new,
    identityv1identity.FormSubmissionSaveResponse.new,
  );

  /// FormSubmissionGet retrieves a form submission by its ID.
  static const formSubmissionGet = connect.Spec(
    '/$name/FormSubmissionGet',
    connect.StreamType.unary,
    identityv1identity.FormSubmissionGetRequest.new,
    identityv1identity.FormSubmissionGetResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  /// FormSubmissionSearch finds form submissions matching search criteria.
  static const formSubmissionSearch = connect.Spec(
    '/$name/FormSubmissionSearch',
    connect.StreamType.server,
    identityv1identity.FormSubmissionSearchRequest.new,
    identityv1identity.FormSubmissionSearchResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );
}
