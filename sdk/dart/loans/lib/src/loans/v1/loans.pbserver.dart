// This is a generated file - do not edit.
//
// Generated from loans/v1/loans.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'loans.pb.dart' as $3;
import 'loans.pbjson.dart';

export 'loans.pb.dart';

abstract class LoanManagementServiceBase extends $pb.GeneratedService {
  $async.Future<$3.LoanProductSaveResponse> loanProductSave(
      $pb.ServerContext ctx, $3.LoanProductSaveRequest request);
  $async.Future<$3.LoanProductGetResponse> loanProductGet(
      $pb.ServerContext ctx, $3.LoanProductGetRequest request);
  $async.Future<$3.LoanProductSearchResponse> loanProductSearch(
      $pb.ServerContext ctx, $3.LoanProductSearchRequest request);
  $async.Future<$3.LoanRequestSaveResponse> loanRequestSave(
      $pb.ServerContext ctx, $3.LoanRequestSaveRequest request);
  $async.Future<$3.LoanRequestGetResponse> loanRequestGet(
      $pb.ServerContext ctx, $3.LoanRequestGetRequest request);
  $async.Future<$3.LoanRequestSearchResponse> loanRequestSearch(
      $pb.ServerContext ctx, $3.LoanRequestSearchRequest request);
  $async.Future<$3.LoanRequestApproveResponse> loanRequestApprove(
      $pb.ServerContext ctx, $3.LoanRequestApproveRequest request);
  $async.Future<$3.LoanRequestRejectResponse> loanRequestReject(
      $pb.ServerContext ctx, $3.LoanRequestRejectRequest request);
  $async.Future<$3.LoanRequestCancelResponse> loanRequestCancel(
      $pb.ServerContext ctx, $3.LoanRequestCancelRequest request);
  $async.Future<$3.ClientProductAccessSaveResponse> clientProductAccessSave(
      $pb.ServerContext ctx, $3.ClientProductAccessSaveRequest request);
  $async.Future<$3.ClientProductAccessGetResponse> clientProductAccessGet(
      $pb.ServerContext ctx, $3.ClientProductAccessGetRequest request);
  $async.Future<$3.ClientProductAccessSearchResponse> clientProductAccessSearch(
      $pb.ServerContext ctx, $3.ClientProductAccessSearchRequest request);
  $async.Future<$3.LoanAccountCreateResponse> loanAccountCreate(
      $pb.ServerContext ctx, $3.LoanAccountCreateRequest request);
  $async.Future<$3.LoanAccountCancelResponse> loanAccountCancel(
      $pb.ServerContext ctx, $3.LoanAccountCancelRequest request);
  $async.Future<$3.LoanAccountGetResponse> loanAccountGet(
      $pb.ServerContext ctx, $3.LoanAccountGetRequest request);
  $async.Future<$3.LoanAccountSearchResponse> loanAccountSearch(
      $pb.ServerContext ctx, $3.LoanAccountSearchRequest request);
  $async.Future<$3.LoanBalanceGetResponse> loanBalanceGet(
      $pb.ServerContext ctx, $3.LoanBalanceGetRequest request);
  $async.Future<$3.LoanStatementResponse> loanStatement(
      $pb.ServerContext ctx, $3.LoanStatementRequest request);
  $async.Future<$3.DisbursementCreateResponse> disbursementCreate(
      $pb.ServerContext ctx, $3.DisbursementCreateRequest request);
  $async.Future<$3.DisbursementGetResponse> disbursementGet(
      $pb.ServerContext ctx, $3.DisbursementGetRequest request);
  $async.Future<$3.DisbursementSearchResponse> disbursementSearch(
      $pb.ServerContext ctx, $3.DisbursementSearchRequest request);
  $async.Future<$3.RepaymentRecordResponse> repaymentRecord(
      $pb.ServerContext ctx, $3.RepaymentRecordRequest request);
  $async.Future<$3.RepaymentGetResponse> repaymentGet(
      $pb.ServerContext ctx, $3.RepaymentGetRequest request);
  $async.Future<$3.RepaymentSearchResponse> repaymentSearch(
      $pb.ServerContext ctx, $3.RepaymentSearchRequest request);
  $async.Future<$3.RepaymentScheduleGetResponse> repaymentScheduleGet(
      $pb.ServerContext ctx, $3.RepaymentScheduleGetRequest request);
  $async.Future<$3.PenaltySaveResponse> penaltySave(
      $pb.ServerContext ctx, $3.PenaltySaveRequest request);
  $async.Future<$3.PenaltyWaiveResponse> penaltyWaive(
      $pb.ServerContext ctx, $3.PenaltyWaiveRequest request);
  $async.Future<$3.PenaltySearchResponse> penaltySearch(
      $pb.ServerContext ctx, $3.PenaltySearchRequest request);
  $async.Future<$3.LoanRestructureCreateResponse> loanRestructureCreate(
      $pb.ServerContext ctx, $3.LoanRestructureCreateRequest request);
  $async.Future<$3.LoanRestructureApproveResponse> loanRestructureApprove(
      $pb.ServerContext ctx, $3.LoanRestructureApproveRequest request);
  $async.Future<$3.LoanRestructureRejectResponse> loanRestructureReject(
      $pb.ServerContext ctx, $3.LoanRestructureRejectRequest request);
  $async.Future<$3.LoanRestructureSearchResponse> loanRestructureSearch(
      $pb.ServerContext ctx, $3.LoanRestructureSearchRequest request);
  $async.Future<$3.ReconciliationSaveResponse> reconciliationSave(
      $pb.ServerContext ctx, $3.ReconciliationSaveRequest request);
  $async.Future<$3.ReconciliationSearchResponse> reconciliationSearch(
      $pb.ServerContext ctx, $3.ReconciliationSearchRequest request);
  $async.Future<$3.InitiateCollectionResponse> initiateCollection(
      $pb.ServerContext ctx, $3.InitiateCollectionRequest request);
  $async.Future<$3.TeamCommissionSearchResponse> teamCommissionSearch(
      $pb.ServerContext ctx, $3.TeamCommissionSearchRequest request);
  $async.Future<$3.TeamCommissionPayoutResponse> teamCommissionPayout(
      $pb.ServerContext ctx, $3.TeamCommissionPayoutRequest request);
  $async.Future<$3.TeamCommissionPayoutSearchResponse>
      teamCommissionPayoutSearch(
          $pb.ServerContext ctx, $3.TeamCommissionPayoutSearchRequest request);
  $async.Future<$3.LoanJobRunResponse> loanJobRun(
      $pb.ServerContext ctx, $3.LoanJobRunRequest request);
  $async.Future<$3.PayoutFailedApplyResponse> payoutFailedApply(
      $pb.ServerContext ctx, $3.PayoutFailedApplyRequest request);
  $async.Future<$3.LoanStatusChangeSearchResponse> loanStatusChangeSearch(
      $pb.ServerContext ctx, $3.LoanStatusChangeSearchRequest request);
  $async.Future<$3.PortfolioSummaryResponse> portfolioSummary(
      $pb.ServerContext ctx, $3.PortfolioSummaryRequest request);
  $async.Future<$3.PortfolioExportResponse> portfolioExport(
      $pb.ServerContext ctx, $3.PortfolioExportRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'LoanProductSave':
        return $3.LoanProductSaveRequest();
      case 'LoanProductGet':
        return $3.LoanProductGetRequest();
      case 'LoanProductSearch':
        return $3.LoanProductSearchRequest();
      case 'LoanRequestSave':
        return $3.LoanRequestSaveRequest();
      case 'LoanRequestGet':
        return $3.LoanRequestGetRequest();
      case 'LoanRequestSearch':
        return $3.LoanRequestSearchRequest();
      case 'LoanRequestApprove':
        return $3.LoanRequestApproveRequest();
      case 'LoanRequestReject':
        return $3.LoanRequestRejectRequest();
      case 'LoanRequestCancel':
        return $3.LoanRequestCancelRequest();
      case 'ClientProductAccessSave':
        return $3.ClientProductAccessSaveRequest();
      case 'ClientProductAccessGet':
        return $3.ClientProductAccessGetRequest();
      case 'ClientProductAccessSearch':
        return $3.ClientProductAccessSearchRequest();
      case 'LoanAccountCreate':
        return $3.LoanAccountCreateRequest();
      case 'LoanAccountCancel':
        return $3.LoanAccountCancelRequest();
      case 'LoanAccountGet':
        return $3.LoanAccountGetRequest();
      case 'LoanAccountSearch':
        return $3.LoanAccountSearchRequest();
      case 'LoanBalanceGet':
        return $3.LoanBalanceGetRequest();
      case 'LoanStatement':
        return $3.LoanStatementRequest();
      case 'DisbursementCreate':
        return $3.DisbursementCreateRequest();
      case 'DisbursementGet':
        return $3.DisbursementGetRequest();
      case 'DisbursementSearch':
        return $3.DisbursementSearchRequest();
      case 'RepaymentRecord':
        return $3.RepaymentRecordRequest();
      case 'RepaymentGet':
        return $3.RepaymentGetRequest();
      case 'RepaymentSearch':
        return $3.RepaymentSearchRequest();
      case 'RepaymentScheduleGet':
        return $3.RepaymentScheduleGetRequest();
      case 'PenaltySave':
        return $3.PenaltySaveRequest();
      case 'PenaltyWaive':
        return $3.PenaltyWaiveRequest();
      case 'PenaltySearch':
        return $3.PenaltySearchRequest();
      case 'LoanRestructureCreate':
        return $3.LoanRestructureCreateRequest();
      case 'LoanRestructureApprove':
        return $3.LoanRestructureApproveRequest();
      case 'LoanRestructureReject':
        return $3.LoanRestructureRejectRequest();
      case 'LoanRestructureSearch':
        return $3.LoanRestructureSearchRequest();
      case 'ReconciliationSave':
        return $3.ReconciliationSaveRequest();
      case 'ReconciliationSearch':
        return $3.ReconciliationSearchRequest();
      case 'InitiateCollection':
        return $3.InitiateCollectionRequest();
      case 'TeamCommissionSearch':
        return $3.TeamCommissionSearchRequest();
      case 'TeamCommissionPayout':
        return $3.TeamCommissionPayoutRequest();
      case 'TeamCommissionPayoutSearch':
        return $3.TeamCommissionPayoutSearchRequest();
      case 'LoanJobRun':
        return $3.LoanJobRunRequest();
      case 'PayoutFailedApply':
        return $3.PayoutFailedApplyRequest();
      case 'LoanStatusChangeSearch':
        return $3.LoanStatusChangeSearchRequest();
      case 'PortfolioSummary':
        return $3.PortfolioSummaryRequest();
      case 'PortfolioExport':
        return $3.PortfolioExportRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'LoanProductSave':
        return loanProductSave(ctx, request as $3.LoanProductSaveRequest);
      case 'LoanProductGet':
        return loanProductGet(ctx, request as $3.LoanProductGetRequest);
      case 'LoanProductSearch':
        return loanProductSearch(ctx, request as $3.LoanProductSearchRequest);
      case 'LoanRequestSave':
        return loanRequestSave(ctx, request as $3.LoanRequestSaveRequest);
      case 'LoanRequestGet':
        return loanRequestGet(ctx, request as $3.LoanRequestGetRequest);
      case 'LoanRequestSearch':
        return loanRequestSearch(ctx, request as $3.LoanRequestSearchRequest);
      case 'LoanRequestApprove':
        return loanRequestApprove(ctx, request as $3.LoanRequestApproveRequest);
      case 'LoanRequestReject':
        return loanRequestReject(ctx, request as $3.LoanRequestRejectRequest);
      case 'LoanRequestCancel':
        return loanRequestCancel(ctx, request as $3.LoanRequestCancelRequest);
      case 'ClientProductAccessSave':
        return clientProductAccessSave(
            ctx, request as $3.ClientProductAccessSaveRequest);
      case 'ClientProductAccessGet':
        return clientProductAccessGet(
            ctx, request as $3.ClientProductAccessGetRequest);
      case 'ClientProductAccessSearch':
        return clientProductAccessSearch(
            ctx, request as $3.ClientProductAccessSearchRequest);
      case 'LoanAccountCreate':
        return loanAccountCreate(ctx, request as $3.LoanAccountCreateRequest);
      case 'LoanAccountCancel':
        return loanAccountCancel(ctx, request as $3.LoanAccountCancelRequest);
      case 'LoanAccountGet':
        return loanAccountGet(ctx, request as $3.LoanAccountGetRequest);
      case 'LoanAccountSearch':
        return loanAccountSearch(ctx, request as $3.LoanAccountSearchRequest);
      case 'LoanBalanceGet':
        return loanBalanceGet(ctx, request as $3.LoanBalanceGetRequest);
      case 'LoanStatement':
        return loanStatement(ctx, request as $3.LoanStatementRequest);
      case 'DisbursementCreate':
        return disbursementCreate(ctx, request as $3.DisbursementCreateRequest);
      case 'DisbursementGet':
        return disbursementGet(ctx, request as $3.DisbursementGetRequest);
      case 'DisbursementSearch':
        return disbursementSearch(ctx, request as $3.DisbursementSearchRequest);
      case 'RepaymentRecord':
        return repaymentRecord(ctx, request as $3.RepaymentRecordRequest);
      case 'RepaymentGet':
        return repaymentGet(ctx, request as $3.RepaymentGetRequest);
      case 'RepaymentSearch':
        return repaymentSearch(ctx, request as $3.RepaymentSearchRequest);
      case 'RepaymentScheduleGet':
        return repaymentScheduleGet(
            ctx, request as $3.RepaymentScheduleGetRequest);
      case 'PenaltySave':
        return penaltySave(ctx, request as $3.PenaltySaveRequest);
      case 'PenaltyWaive':
        return penaltyWaive(ctx, request as $3.PenaltyWaiveRequest);
      case 'PenaltySearch':
        return penaltySearch(ctx, request as $3.PenaltySearchRequest);
      case 'LoanRestructureCreate':
        return loanRestructureCreate(
            ctx, request as $3.LoanRestructureCreateRequest);
      case 'LoanRestructureApprove':
        return loanRestructureApprove(
            ctx, request as $3.LoanRestructureApproveRequest);
      case 'LoanRestructureReject':
        return loanRestructureReject(
            ctx, request as $3.LoanRestructureRejectRequest);
      case 'LoanRestructureSearch':
        return loanRestructureSearch(
            ctx, request as $3.LoanRestructureSearchRequest);
      case 'ReconciliationSave':
        return reconciliationSave(ctx, request as $3.ReconciliationSaveRequest);
      case 'ReconciliationSearch':
        return reconciliationSearch(
            ctx, request as $3.ReconciliationSearchRequest);
      case 'InitiateCollection':
        return initiateCollection(ctx, request as $3.InitiateCollectionRequest);
      case 'TeamCommissionSearch':
        return teamCommissionSearch(
            ctx, request as $3.TeamCommissionSearchRequest);
      case 'TeamCommissionPayout':
        return teamCommissionPayout(
            ctx, request as $3.TeamCommissionPayoutRequest);
      case 'TeamCommissionPayoutSearch':
        return teamCommissionPayoutSearch(
            ctx, request as $3.TeamCommissionPayoutSearchRequest);
      case 'LoanJobRun':
        return loanJobRun(ctx, request as $3.LoanJobRunRequest);
      case 'PayoutFailedApply':
        return payoutFailedApply(ctx, request as $3.PayoutFailedApplyRequest);
      case 'LoanStatusChangeSearch':
        return loanStatusChangeSearch(
            ctx, request as $3.LoanStatusChangeSearchRequest);
      case 'PortfolioSummary':
        return portfolioSummary(ctx, request as $3.PortfolioSummaryRequest);
      case 'PortfolioExport':
        return portfolioExport(ctx, request as $3.PortfolioExportRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      LoanManagementServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => LoanManagementServiceBase$messageJson;
}
