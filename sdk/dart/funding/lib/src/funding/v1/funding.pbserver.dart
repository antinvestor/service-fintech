// This is a generated file - do not edit.
//
// Generated from funding/v1/funding.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'funding.pb.dart' as $3;
import 'funding.pbjson.dart';

export 'funding.pb.dart';

abstract class FundingServiceBase extends $pb.GeneratedService {
  $async.Future<$3.InvestorAccountSaveResponse> investorAccountSave(
      $pb.ServerContext ctx, $3.InvestorAccountSaveRequest request);
  $async.Future<$3.InvestorAccountGetResponse> investorAccountGet(
      $pb.ServerContext ctx, $3.InvestorAccountGetRequest request);
  $async.Future<$3.InvestorAccountSearchResponse> investorAccountSearch(
      $pb.ServerContext ctx, $3.InvestorAccountSearchRequest request);
  $async.Future<$3.InvestorStatementResponse> investorStatement(
      $pb.ServerContext ctx, $3.InvestorStatementRequest request);
  $async.Future<$3.InvestorDepositResponse> investorDeposit(
      $pb.ServerContext ctx, $3.InvestorDepositRequest request);
  $async.Future<$3.InvestorWithdrawResponse> investorWithdraw(
      $pb.ServerContext ctx, $3.InvestorWithdrawRequest request);
  $async.Future<$3.FundLoanResponse> fundLoan(
      $pb.ServerContext ctx, $3.FundLoanRequest request);
  $async.Future<$3.AbsorbLossResponse> absorbLoss(
      $pb.ServerContext ctx, $3.AbsorbLossRequest request);
  $async.Future<$3.FundingReleaseResponse> fundingRelease(
      $pb.ServerContext ctx, $3.FundingReleaseRequest request);
  $async.Future<$3.LoanRepaymentApplyResponse> loanRepaymentApply(
      $pb.ServerContext ctx, $3.LoanRepaymentApplyRequest request);
  $async.Future<$3.LoanRecoveryApplyResponse> loanRecoveryApply(
      $pb.ServerContext ctx, $3.LoanRecoveryApplyRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'InvestorAccountSave':
        return $3.InvestorAccountSaveRequest();
      case 'InvestorAccountGet':
        return $3.InvestorAccountGetRequest();
      case 'InvestorAccountSearch':
        return $3.InvestorAccountSearchRequest();
      case 'InvestorStatement':
        return $3.InvestorStatementRequest();
      case 'InvestorDeposit':
        return $3.InvestorDepositRequest();
      case 'InvestorWithdraw':
        return $3.InvestorWithdrawRequest();
      case 'FundLoan':
        return $3.FundLoanRequest();
      case 'AbsorbLoss':
        return $3.AbsorbLossRequest();
      case 'FundingRelease':
        return $3.FundingReleaseRequest();
      case 'LoanRepaymentApply':
        return $3.LoanRepaymentApplyRequest();
      case 'LoanRecoveryApply':
        return $3.LoanRecoveryApplyRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'InvestorAccountSave':
        return investorAccountSave(
            ctx, request as $3.InvestorAccountSaveRequest);
      case 'InvestorAccountGet':
        return investorAccountGet(ctx, request as $3.InvestorAccountGetRequest);
      case 'InvestorAccountSearch':
        return investorAccountSearch(
            ctx, request as $3.InvestorAccountSearchRequest);
      case 'InvestorStatement':
        return investorStatement(ctx, request as $3.InvestorStatementRequest);
      case 'InvestorDeposit':
        return investorDeposit(ctx, request as $3.InvestorDepositRequest);
      case 'InvestorWithdraw':
        return investorWithdraw(ctx, request as $3.InvestorWithdrawRequest);
      case 'FundLoan':
        return fundLoan(ctx, request as $3.FundLoanRequest);
      case 'AbsorbLoss':
        return absorbLoss(ctx, request as $3.AbsorbLossRequest);
      case 'FundingRelease':
        return fundingRelease(ctx, request as $3.FundingReleaseRequest);
      case 'LoanRepaymentApply':
        return loanRepaymentApply(ctx, request as $3.LoanRepaymentApplyRequest);
      case 'LoanRecoveryApply':
        return loanRecoveryApply(ctx, request as $3.LoanRecoveryApplyRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => FundingServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => FundingServiceBase$messageJson;
}
