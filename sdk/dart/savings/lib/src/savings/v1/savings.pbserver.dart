// This is a generated file - do not edit.
//
// Generated from savings/v1/savings.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'savings.pb.dart' as $3;
import 'savings.pbjson.dart';

export 'savings.pb.dart';

abstract class SavingsServiceBase extends $pb.GeneratedService {
  $async.Future<$3.SavingsProductSaveResponse> savingsProductSave(
      $pb.ServerContext ctx, $3.SavingsProductSaveRequest request);
  $async.Future<$3.SavingsProductGetResponse> savingsProductGet(
      $pb.ServerContext ctx, $3.SavingsProductGetRequest request);
  $async.Future<$3.SavingsProductSearchResponse> savingsProductSearch(
      $pb.ServerContext ctx, $3.SavingsProductSearchRequest request);
  $async.Future<$3.SavingsAccountCreateResponse> savingsAccountCreate(
      $pb.ServerContext ctx, $3.SavingsAccountCreateRequest request);
  $async.Future<$3.SavingsAccountGetResponse> savingsAccountGet(
      $pb.ServerContext ctx, $3.SavingsAccountGetRequest request);
  $async.Future<$3.SavingsAccountSearchResponse> savingsAccountSearch(
      $pb.ServerContext ctx, $3.SavingsAccountSearchRequest request);
  $async.Future<$3.SavingsAccountFreezeResponse> savingsAccountFreeze(
      $pb.ServerContext ctx, $3.SavingsAccountFreezeRequest request);
  $async.Future<$3.SavingsAccountCloseResponse> savingsAccountClose(
      $pb.ServerContext ctx, $3.SavingsAccountCloseRequest request);
  $async.Future<$3.DepositRecordResponse> depositRecord(
      $pb.ServerContext ctx, $3.DepositRecordRequest request);
  $async.Future<$3.DepositGetResponse> depositGet(
      $pb.ServerContext ctx, $3.DepositGetRequest request);
  $async.Future<$3.DepositSearchResponse> depositSearch(
      $pb.ServerContext ctx, $3.DepositSearchRequest request);
  $async.Future<$3.WithdrawalRequestResponse> withdrawalRequest(
      $pb.ServerContext ctx, $3.WithdrawalRequestRequest request);
  $async.Future<$3.WithdrawalApproveResponse> withdrawalApprove(
      $pb.ServerContext ctx, $3.WithdrawalApproveRequest request);
  $async.Future<$3.WithdrawalCancelResponse> withdrawalCancel(
      $pb.ServerContext ctx, $3.WithdrawalCancelRequest request);
  $async.Future<$3.WithdrawalGetResponse> withdrawalGet(
      $pb.ServerContext ctx, $3.WithdrawalGetRequest request);
  $async.Future<$3.WithdrawalSearchResponse> withdrawalSearch(
      $pb.ServerContext ctx, $3.WithdrawalSearchRequest request);
  $async.Future<$3.InterestAccrualGetResponse> interestAccrualGet(
      $pb.ServerContext ctx, $3.InterestAccrualGetRequest request);
  $async.Future<$3.InterestAccrualSearchResponse> interestAccrualSearch(
      $pb.ServerContext ctx, $3.InterestAccrualSearchRequest request);
  $async.Future<$3.SavingsBalanceGetResponse> savingsBalanceGet(
      $pb.ServerContext ctx, $3.SavingsBalanceGetRequest request);
  $async.Future<$3.SavingsStatementResponse> savingsStatement(
      $pb.ServerContext ctx, $3.SavingsStatementRequest request);
  $async.Future<$3.PayoutFailedApplyResponse> payoutFailedApply(
      $pb.ServerContext ctx, $3.PayoutFailedApplyRequest request);
  $async.Future<$3.SavingsJobRunResponse> savingsJobRun(
      $pb.ServerContext ctx, $3.SavingsJobRunRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SavingsProductSave':
        return $3.SavingsProductSaveRequest();
      case 'SavingsProductGet':
        return $3.SavingsProductGetRequest();
      case 'SavingsProductSearch':
        return $3.SavingsProductSearchRequest();
      case 'SavingsAccountCreate':
        return $3.SavingsAccountCreateRequest();
      case 'SavingsAccountGet':
        return $3.SavingsAccountGetRequest();
      case 'SavingsAccountSearch':
        return $3.SavingsAccountSearchRequest();
      case 'SavingsAccountFreeze':
        return $3.SavingsAccountFreezeRequest();
      case 'SavingsAccountClose':
        return $3.SavingsAccountCloseRequest();
      case 'DepositRecord':
        return $3.DepositRecordRequest();
      case 'DepositGet':
        return $3.DepositGetRequest();
      case 'DepositSearch':
        return $3.DepositSearchRequest();
      case 'WithdrawalRequest':
        return $3.WithdrawalRequestRequest();
      case 'WithdrawalApprove':
        return $3.WithdrawalApproveRequest();
      case 'WithdrawalCancel':
        return $3.WithdrawalCancelRequest();
      case 'WithdrawalGet':
        return $3.WithdrawalGetRequest();
      case 'WithdrawalSearch':
        return $3.WithdrawalSearchRequest();
      case 'InterestAccrualGet':
        return $3.InterestAccrualGetRequest();
      case 'InterestAccrualSearch':
        return $3.InterestAccrualSearchRequest();
      case 'SavingsBalanceGet':
        return $3.SavingsBalanceGetRequest();
      case 'SavingsStatement':
        return $3.SavingsStatementRequest();
      case 'PayoutFailedApply':
        return $3.PayoutFailedApplyRequest();
      case 'SavingsJobRun':
        return $3.SavingsJobRunRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SavingsProductSave':
        return savingsProductSave(ctx, request as $3.SavingsProductSaveRequest);
      case 'SavingsProductGet':
        return savingsProductGet(ctx, request as $3.SavingsProductGetRequest);
      case 'SavingsProductSearch':
        return savingsProductSearch(
            ctx, request as $3.SavingsProductSearchRequest);
      case 'SavingsAccountCreate':
        return savingsAccountCreate(
            ctx, request as $3.SavingsAccountCreateRequest);
      case 'SavingsAccountGet':
        return savingsAccountGet(ctx, request as $3.SavingsAccountGetRequest);
      case 'SavingsAccountSearch':
        return savingsAccountSearch(
            ctx, request as $3.SavingsAccountSearchRequest);
      case 'SavingsAccountFreeze':
        return savingsAccountFreeze(
            ctx, request as $3.SavingsAccountFreezeRequest);
      case 'SavingsAccountClose':
        return savingsAccountClose(
            ctx, request as $3.SavingsAccountCloseRequest);
      case 'DepositRecord':
        return depositRecord(ctx, request as $3.DepositRecordRequest);
      case 'DepositGet':
        return depositGet(ctx, request as $3.DepositGetRequest);
      case 'DepositSearch':
        return depositSearch(ctx, request as $3.DepositSearchRequest);
      case 'WithdrawalRequest':
        return withdrawalRequest(ctx, request as $3.WithdrawalRequestRequest);
      case 'WithdrawalApprove':
        return withdrawalApprove(ctx, request as $3.WithdrawalApproveRequest);
      case 'WithdrawalCancel':
        return withdrawalCancel(ctx, request as $3.WithdrawalCancelRequest);
      case 'WithdrawalGet':
        return withdrawalGet(ctx, request as $3.WithdrawalGetRequest);
      case 'WithdrawalSearch':
        return withdrawalSearch(ctx, request as $3.WithdrawalSearchRequest);
      case 'InterestAccrualGet':
        return interestAccrualGet(ctx, request as $3.InterestAccrualGetRequest);
      case 'InterestAccrualSearch':
        return interestAccrualSearch(
            ctx, request as $3.InterestAccrualSearchRequest);
      case 'SavingsBalanceGet':
        return savingsBalanceGet(ctx, request as $3.SavingsBalanceGetRequest);
      case 'SavingsStatement':
        return savingsStatement(ctx, request as $3.SavingsStatementRequest);
      case 'PayoutFailedApply':
        return payoutFailedApply(ctx, request as $3.PayoutFailedApplyRequest);
      case 'SavingsJobRun':
        return savingsJobRun(ctx, request as $3.SavingsJobRunRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SavingsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SavingsServiceBase$messageJson;
}
