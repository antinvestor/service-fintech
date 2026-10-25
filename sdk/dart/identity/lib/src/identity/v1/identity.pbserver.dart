// This is a generated file - do not edit.
//
// Generated from identity/v1/identity.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../common/v1/common.pb.dart' as $1;
import 'identity.pb.dart' as $3;
import 'identity.pbjson.dart';

export 'identity.pb.dart';

abstract class IdentityServiceBase extends $pb.GeneratedService {
  $async.Future<$3.OrganizationSaveResponse> organizationSave(
      $pb.ServerContext ctx, $3.OrganizationSaveRequest request);
  $async.Future<$3.OrganizationGetResponse> organizationGet(
      $pb.ServerContext ctx, $3.OrganizationGetRequest request);
  $async.Future<$3.OrganizationSearchResponse> organizationSearch(
      $pb.ServerContext ctx, $1.SearchRequest request);
  $async.Future<$3.OrgUnitSaveResponse> orgUnitSave(
      $pb.ServerContext ctx, $3.OrgUnitSaveRequest request);
  $async.Future<$3.OrgUnitGetResponse> orgUnitGet(
      $pb.ServerContext ctx, $3.OrgUnitGetRequest request);
  $async.Future<$3.OrgUnitSearchResponse> orgUnitSearch(
      $pb.ServerContext ctx, $3.OrgUnitSearchRequest request);
  $async.Future<$3.WorkforceMemberSaveResponse> workforceMemberSave(
      $pb.ServerContext ctx, $3.WorkforceMemberSaveRequest request);
  $async.Future<$3.WorkforceMemberGetResponse> workforceMemberGet(
      $pb.ServerContext ctx, $3.WorkforceMemberGetRequest request);
  $async.Future<$3.WorkforceMemberSearchResponse> workforceMemberSearch(
      $pb.ServerContext ctx, $3.WorkforceMemberSearchRequest request);
  $async.Future<$3.DepartmentSaveResponse> departmentSave(
      $pb.ServerContext ctx, $3.DepartmentSaveRequest request);
  $async.Future<$3.DepartmentGetResponse> departmentGet(
      $pb.ServerContext ctx, $3.DepartmentGetRequest request);
  $async.Future<$3.DepartmentSearchResponse> departmentSearch(
      $pb.ServerContext ctx, $3.DepartmentSearchRequest request);
  $async.Future<$3.PositionSaveResponse> positionSave(
      $pb.ServerContext ctx, $3.PositionSaveRequest request);
  $async.Future<$3.PositionGetResponse> positionGet(
      $pb.ServerContext ctx, $3.PositionGetRequest request);
  $async.Future<$3.PositionSearchResponse> positionSearch(
      $pb.ServerContext ctx, $3.PositionSearchRequest request);
  $async.Future<$3.PositionAssignmentSaveResponse> positionAssignmentSave(
      $pb.ServerContext ctx, $3.PositionAssignmentSaveRequest request);
  $async.Future<$3.PositionAssignmentGetResponse> positionAssignmentGet(
      $pb.ServerContext ctx, $3.PositionAssignmentGetRequest request);
  $async.Future<$3.PositionAssignmentSearchResponse> positionAssignmentSearch(
      $pb.ServerContext ctx, $3.PositionAssignmentSearchRequest request);
  $async.Future<$3.InternalTeamSaveResponse> internalTeamSave(
      $pb.ServerContext ctx, $3.InternalTeamSaveRequest request);
  $async.Future<$3.InternalTeamGetResponse> internalTeamGet(
      $pb.ServerContext ctx, $3.InternalTeamGetRequest request);
  $async.Future<$3.InternalTeamSearchResponse> internalTeamSearch(
      $pb.ServerContext ctx, $3.InternalTeamSearchRequest request);
  $async.Future<$3.TeamMembershipSaveResponse> teamMembershipSave(
      $pb.ServerContext ctx, $3.TeamMembershipSaveRequest request);
  $async.Future<$3.TeamMembershipGetResponse> teamMembershipGet(
      $pb.ServerContext ctx, $3.TeamMembershipGetRequest request);
  $async.Future<$3.TeamMembershipSearchResponse> teamMembershipSearch(
      $pb.ServerContext ctx, $3.TeamMembershipSearchRequest request);
  $async.Future<$3.AccessRoleAssignmentSaveResponse> accessRoleAssignmentSave(
      $pb.ServerContext ctx, $3.AccessRoleAssignmentSaveRequest request);
  $async.Future<$3.AccessRoleAssignmentGetResponse> accessRoleAssignmentGet(
      $pb.ServerContext ctx, $3.AccessRoleAssignmentGetRequest request);
  $async.Future<$3.AccessRoleAssignmentSearchResponse>
      accessRoleAssignmentSearch(
          $pb.ServerContext ctx, $3.AccessRoleAssignmentSearchRequest request);
  $async.Future<$3.InvestorSaveResponse> investorSave(
      $pb.ServerContext ctx, $3.InvestorSaveRequest request);
  $async.Future<$3.InvestorGetResponse> investorGet(
      $pb.ServerContext ctx, $3.InvestorGetRequest request);
  $async.Future<$3.InvestorSearchResponse> investorSearch(
      $pb.ServerContext ctx, $3.InvestorSearchRequest request);
  $async.Future<$3.ClientGroupSaveResponse> clientGroupSave(
      $pb.ServerContext ctx, $3.ClientGroupSaveRequest request);
  $async.Future<$3.ClientGroupGetResponse> clientGroupGet(
      $pb.ServerContext ctx, $3.ClientGroupGetRequest request);
  $async.Future<$3.ClientGroupSearchResponse> clientGroupSearch(
      $pb.ServerContext ctx, $3.ClientGroupSearchRequest request);
  $async.Future<$3.MembershipSaveResponse> membershipSave(
      $pb.ServerContext ctx, $3.MembershipSaveRequest request);
  $async.Future<$3.MembershipGetResponse> membershipGet(
      $pb.ServerContext ctx, $3.MembershipGetRequest request);
  $async.Future<$3.MembershipSearchResponse> membershipSearch(
      $pb.ServerContext ctx, $3.MembershipSearchRequest request);
  $async.Future<$3.InvestorAccountSaveResponse> investorAccountSave(
      $pb.ServerContext ctx, $3.InvestorAccountSaveRequest request);
  $async.Future<$3.InvestorAccountGetResponse> investorAccountGet(
      $pb.ServerContext ctx, $3.InvestorAccountGetRequest request);
  $async.Future<$3.InvestorAccountSearchResponse> investorAccountSearch(
      $pb.ServerContext ctx, $3.InvestorAccountSearchRequest request);
  $async.Future<$3.InvestorDepositResponse> investorDeposit(
      $pb.ServerContext ctx, $3.InvestorDepositRequest request);
  $async.Future<$3.InvestorWithdrawResponse> investorWithdraw(
      $pb.ServerContext ctx, $3.InvestorWithdrawRequest request);
  $async.Future<$3.ClientDataSaveResponse> clientDataSave(
      $pb.ServerContext ctx, $3.ClientDataSaveRequest request);
  $async.Future<$3.ClientDataGetResponse> clientDataGet(
      $pb.ServerContext ctx, $3.ClientDataGetRequest request);
  $async.Future<$3.ClientDataListResponse> clientDataList(
      $pb.ServerContext ctx, $3.ClientDataListRequest request);
  $async.Future<$3.ClientKYCRequirementsResponse> clientKYCRequirements(
      $pb.ServerContext ctx, $3.ClientKYCRequirementsRequest request);
  $async.Future<$3.ClientDataVerifyResponse> clientDataVerify(
      $pb.ServerContext ctx, $3.ClientDataVerifyRequest request);
  $async.Future<$3.ClientDataRejectResponse> clientDataReject(
      $pb.ServerContext ctx, $3.ClientDataRejectRequest request);
  $async.Future<$3.ClientDataRequestInfoResponse> clientDataRequestInfo(
      $pb.ServerContext ctx, $3.ClientDataRequestInfoRequest request);
  $async.Future<$3.ClientDataHistoryResponse> clientDataHistory(
      $pb.ServerContext ctx, $3.ClientDataHistoryRequest request);
  $async.Future<$3.FormTemplateSaveResponse> formTemplateSave(
      $pb.ServerContext ctx, $3.FormTemplateSaveRequest request);
  $async.Future<$3.FormTemplateGetResponse> formTemplateGet(
      $pb.ServerContext ctx, $3.FormTemplateGetRequest request);
  $async.Future<$3.FormTemplateSearchResponse> formTemplateSearch(
      $pb.ServerContext ctx, $3.FormTemplateSearchRequest request);
  $async.Future<$3.FormTemplatePublishResponse> formTemplatePublish(
      $pb.ServerContext ctx, $3.FormTemplatePublishRequest request);
  $async.Future<$3.FormSubmissionSaveResponse> formSubmissionSave(
      $pb.ServerContext ctx, $3.FormSubmissionSaveRequest request);
  $async.Future<$3.FormSubmissionGetResponse> formSubmissionGet(
      $pb.ServerContext ctx, $3.FormSubmissionGetRequest request);
  $async.Future<$3.FormSubmissionSearchResponse> formSubmissionSearch(
      $pb.ServerContext ctx, $3.FormSubmissionSearchRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'OrganizationSave':
        return $3.OrganizationSaveRequest();
      case 'OrganizationGet':
        return $3.OrganizationGetRequest();
      case 'OrganizationSearch':
        return $1.SearchRequest();
      case 'OrgUnitSave':
        return $3.OrgUnitSaveRequest();
      case 'OrgUnitGet':
        return $3.OrgUnitGetRequest();
      case 'OrgUnitSearch':
        return $3.OrgUnitSearchRequest();
      case 'WorkforceMemberSave':
        return $3.WorkforceMemberSaveRequest();
      case 'WorkforceMemberGet':
        return $3.WorkforceMemberGetRequest();
      case 'WorkforceMemberSearch':
        return $3.WorkforceMemberSearchRequest();
      case 'DepartmentSave':
        return $3.DepartmentSaveRequest();
      case 'DepartmentGet':
        return $3.DepartmentGetRequest();
      case 'DepartmentSearch':
        return $3.DepartmentSearchRequest();
      case 'PositionSave':
        return $3.PositionSaveRequest();
      case 'PositionGet':
        return $3.PositionGetRequest();
      case 'PositionSearch':
        return $3.PositionSearchRequest();
      case 'PositionAssignmentSave':
        return $3.PositionAssignmentSaveRequest();
      case 'PositionAssignmentGet':
        return $3.PositionAssignmentGetRequest();
      case 'PositionAssignmentSearch':
        return $3.PositionAssignmentSearchRequest();
      case 'InternalTeamSave':
        return $3.InternalTeamSaveRequest();
      case 'InternalTeamGet':
        return $3.InternalTeamGetRequest();
      case 'InternalTeamSearch':
        return $3.InternalTeamSearchRequest();
      case 'TeamMembershipSave':
        return $3.TeamMembershipSaveRequest();
      case 'TeamMembershipGet':
        return $3.TeamMembershipGetRequest();
      case 'TeamMembershipSearch':
        return $3.TeamMembershipSearchRequest();
      case 'AccessRoleAssignmentSave':
        return $3.AccessRoleAssignmentSaveRequest();
      case 'AccessRoleAssignmentGet':
        return $3.AccessRoleAssignmentGetRequest();
      case 'AccessRoleAssignmentSearch':
        return $3.AccessRoleAssignmentSearchRequest();
      case 'InvestorSave':
        return $3.InvestorSaveRequest();
      case 'InvestorGet':
        return $3.InvestorGetRequest();
      case 'InvestorSearch':
        return $3.InvestorSearchRequest();
      case 'ClientGroupSave':
        return $3.ClientGroupSaveRequest();
      case 'ClientGroupGet':
        return $3.ClientGroupGetRequest();
      case 'ClientGroupSearch':
        return $3.ClientGroupSearchRequest();
      case 'MembershipSave':
        return $3.MembershipSaveRequest();
      case 'MembershipGet':
        return $3.MembershipGetRequest();
      case 'MembershipSearch':
        return $3.MembershipSearchRequest();
      case 'InvestorAccountSave':
        return $3.InvestorAccountSaveRequest();
      case 'InvestorAccountGet':
        return $3.InvestorAccountGetRequest();
      case 'InvestorAccountSearch':
        return $3.InvestorAccountSearchRequest();
      case 'InvestorDeposit':
        return $3.InvestorDepositRequest();
      case 'InvestorWithdraw':
        return $3.InvestorWithdrawRequest();
      case 'ClientDataSave':
        return $3.ClientDataSaveRequest();
      case 'ClientDataGet':
        return $3.ClientDataGetRequest();
      case 'ClientDataList':
        return $3.ClientDataListRequest();
      case 'ClientKYCRequirements':
        return $3.ClientKYCRequirementsRequest();
      case 'ClientDataVerify':
        return $3.ClientDataVerifyRequest();
      case 'ClientDataReject':
        return $3.ClientDataRejectRequest();
      case 'ClientDataRequestInfo':
        return $3.ClientDataRequestInfoRequest();
      case 'ClientDataHistory':
        return $3.ClientDataHistoryRequest();
      case 'FormTemplateSave':
        return $3.FormTemplateSaveRequest();
      case 'FormTemplateGet':
        return $3.FormTemplateGetRequest();
      case 'FormTemplateSearch':
        return $3.FormTemplateSearchRequest();
      case 'FormTemplatePublish':
        return $3.FormTemplatePublishRequest();
      case 'FormSubmissionSave':
        return $3.FormSubmissionSaveRequest();
      case 'FormSubmissionGet':
        return $3.FormSubmissionGetRequest();
      case 'FormSubmissionSearch':
        return $3.FormSubmissionSearchRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'OrganizationSave':
        return organizationSave(ctx, request as $3.OrganizationSaveRequest);
      case 'OrganizationGet':
        return organizationGet(ctx, request as $3.OrganizationGetRequest);
      case 'OrganizationSearch':
        return organizationSearch(ctx, request as $1.SearchRequest);
      case 'OrgUnitSave':
        return orgUnitSave(ctx, request as $3.OrgUnitSaveRequest);
      case 'OrgUnitGet':
        return orgUnitGet(ctx, request as $3.OrgUnitGetRequest);
      case 'OrgUnitSearch':
        return orgUnitSearch(ctx, request as $3.OrgUnitSearchRequest);
      case 'WorkforceMemberSave':
        return workforceMemberSave(
            ctx, request as $3.WorkforceMemberSaveRequest);
      case 'WorkforceMemberGet':
        return workforceMemberGet(ctx, request as $3.WorkforceMemberGetRequest);
      case 'WorkforceMemberSearch':
        return workforceMemberSearch(
            ctx, request as $3.WorkforceMemberSearchRequest);
      case 'DepartmentSave':
        return departmentSave(ctx, request as $3.DepartmentSaveRequest);
      case 'DepartmentGet':
        return departmentGet(ctx, request as $3.DepartmentGetRequest);
      case 'DepartmentSearch':
        return departmentSearch(ctx, request as $3.DepartmentSearchRequest);
      case 'PositionSave':
        return positionSave(ctx, request as $3.PositionSaveRequest);
      case 'PositionGet':
        return positionGet(ctx, request as $3.PositionGetRequest);
      case 'PositionSearch':
        return positionSearch(ctx, request as $3.PositionSearchRequest);
      case 'PositionAssignmentSave':
        return positionAssignmentSave(
            ctx, request as $3.PositionAssignmentSaveRequest);
      case 'PositionAssignmentGet':
        return positionAssignmentGet(
            ctx, request as $3.PositionAssignmentGetRequest);
      case 'PositionAssignmentSearch':
        return positionAssignmentSearch(
            ctx, request as $3.PositionAssignmentSearchRequest);
      case 'InternalTeamSave':
        return internalTeamSave(ctx, request as $3.InternalTeamSaveRequest);
      case 'InternalTeamGet':
        return internalTeamGet(ctx, request as $3.InternalTeamGetRequest);
      case 'InternalTeamSearch':
        return internalTeamSearch(ctx, request as $3.InternalTeamSearchRequest);
      case 'TeamMembershipSave':
        return teamMembershipSave(ctx, request as $3.TeamMembershipSaveRequest);
      case 'TeamMembershipGet':
        return teamMembershipGet(ctx, request as $3.TeamMembershipGetRequest);
      case 'TeamMembershipSearch':
        return teamMembershipSearch(
            ctx, request as $3.TeamMembershipSearchRequest);
      case 'AccessRoleAssignmentSave':
        return accessRoleAssignmentSave(
            ctx, request as $3.AccessRoleAssignmentSaveRequest);
      case 'AccessRoleAssignmentGet':
        return accessRoleAssignmentGet(
            ctx, request as $3.AccessRoleAssignmentGetRequest);
      case 'AccessRoleAssignmentSearch':
        return accessRoleAssignmentSearch(
            ctx, request as $3.AccessRoleAssignmentSearchRequest);
      case 'InvestorSave':
        return investorSave(ctx, request as $3.InvestorSaveRequest);
      case 'InvestorGet':
        return investorGet(ctx, request as $3.InvestorGetRequest);
      case 'InvestorSearch':
        return investorSearch(ctx, request as $3.InvestorSearchRequest);
      case 'ClientGroupSave':
        return clientGroupSave(ctx, request as $3.ClientGroupSaveRequest);
      case 'ClientGroupGet':
        return clientGroupGet(ctx, request as $3.ClientGroupGetRequest);
      case 'ClientGroupSearch':
        return clientGroupSearch(ctx, request as $3.ClientGroupSearchRequest);
      case 'MembershipSave':
        return membershipSave(ctx, request as $3.MembershipSaveRequest);
      case 'MembershipGet':
        return membershipGet(ctx, request as $3.MembershipGetRequest);
      case 'MembershipSearch':
        return membershipSearch(ctx, request as $3.MembershipSearchRequest);
      case 'InvestorAccountSave':
        return investorAccountSave(
            ctx, request as $3.InvestorAccountSaveRequest);
      case 'InvestorAccountGet':
        return investorAccountGet(ctx, request as $3.InvestorAccountGetRequest);
      case 'InvestorAccountSearch':
        return investorAccountSearch(
            ctx, request as $3.InvestorAccountSearchRequest);
      case 'InvestorDeposit':
        return investorDeposit(ctx, request as $3.InvestorDepositRequest);
      case 'InvestorWithdraw':
        return investorWithdraw(ctx, request as $3.InvestorWithdrawRequest);
      case 'ClientDataSave':
        return clientDataSave(ctx, request as $3.ClientDataSaveRequest);
      case 'ClientDataGet':
        return clientDataGet(ctx, request as $3.ClientDataGetRequest);
      case 'ClientDataList':
        return clientDataList(ctx, request as $3.ClientDataListRequest);
      case 'ClientKYCRequirements':
        return clientKYCRequirements(
            ctx, request as $3.ClientKYCRequirementsRequest);
      case 'ClientDataVerify':
        return clientDataVerify(ctx, request as $3.ClientDataVerifyRequest);
      case 'ClientDataReject':
        return clientDataReject(ctx, request as $3.ClientDataRejectRequest);
      case 'ClientDataRequestInfo':
        return clientDataRequestInfo(
            ctx, request as $3.ClientDataRequestInfoRequest);
      case 'ClientDataHistory':
        return clientDataHistory(ctx, request as $3.ClientDataHistoryRequest);
      case 'FormTemplateSave':
        return formTemplateSave(ctx, request as $3.FormTemplateSaveRequest);
      case 'FormTemplateGet':
        return formTemplateGet(ctx, request as $3.FormTemplateGetRequest);
      case 'FormTemplateSearch':
        return formTemplateSearch(ctx, request as $3.FormTemplateSearchRequest);
      case 'FormTemplatePublish':
        return formTemplatePublish(
            ctx, request as $3.FormTemplatePublishRequest);
      case 'FormSubmissionSave':
        return formSubmissionSave(ctx, request as $3.FormSubmissionSaveRequest);
      case 'FormSubmissionGet':
        return formSubmissionGet(ctx, request as $3.FormSubmissionGetRequest);
      case 'FormSubmissionSearch':
        return formSubmissionSearch(
            ctx, request as $3.FormSubmissionSearchRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => IdentityServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => IdentityServiceBase$messageJson;
}
