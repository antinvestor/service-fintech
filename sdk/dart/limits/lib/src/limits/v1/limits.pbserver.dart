// This is a generated file - do not edit.
//
// Generated from limits/v1/limits.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'limits.pb.dart' as $5;
import 'limits.pbjson.dart';

export 'limits.pb.dart';

abstract class LimitsServiceBase extends $pb.GeneratedService {
  $async.Future<$5.CheckResponse> check(
      $pb.ServerContext ctx, $5.CheckRequest request);
  $async.Future<$5.ReserveResponse> reserve(
      $pb.ServerContext ctx, $5.ReserveRequest request);
  $async.Future<$5.CommitResponse> commit(
      $pb.ServerContext ctx, $5.CommitRequest request);
  $async.Future<$5.ReleaseResponse> release(
      $pb.ServerContext ctx, $5.ReleaseRequest request);
  $async.Future<$5.ReverseResponse> reverse(
      $pb.ServerContext ctx, $5.ReverseRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Check':
        return $5.CheckRequest();
      case 'Reserve':
        return $5.ReserveRequest();
      case 'Commit':
        return $5.CommitRequest();
      case 'Release':
        return $5.ReleaseRequest();
      case 'Reverse':
        return $5.ReverseRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Check':
        return check(ctx, request as $5.CheckRequest);
      case 'Reserve':
        return reserve(ctx, request as $5.ReserveRequest);
      case 'Commit':
        return commit(ctx, request as $5.CommitRequest);
      case 'Release':
        return release(ctx, request as $5.ReleaseRequest);
      case 'Reverse':
        return reverse(ctx, request as $5.ReverseRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => LimitsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => LimitsServiceBase$messageJson;
}

abstract class LimitsAdminServiceBase extends $pb.GeneratedService {
  $async.Future<$5.PolicySaveResponse> policySave(
      $pb.ServerContext ctx, $5.PolicySaveRequest request);
  $async.Future<$5.PolicyGetResponse> policyGet(
      $pb.ServerContext ctx, $5.PolicyGetRequest request);
  $async.Future<$5.PolicySearchResponse> policySearch(
      $pb.ServerContext ctx, $5.PolicySearchRequest request);
  $async.Future<$5.PolicyDeleteResponse> policyDelete(
      $pb.ServerContext ctx, $5.PolicyDeleteRequest request);
  $async.Future<$5.PolicyHistoryResponse> policyHistory(
      $pb.ServerContext ctx, $5.PolicyHistoryRequest request);
  $async.Future<$5.ApprovalRequestListResponse> approvalRequestList(
      $pb.ServerContext ctx, $5.ApprovalRequestListRequest request);
  $async.Future<$5.ApprovalRequestGetResponse> approvalRequestGet(
      $pb.ServerContext ctx, $5.ApprovalRequestGetRequest request);
  $async.Future<$5.ApprovalRequestDecideResponse> approvalRequestDecide(
      $pb.ServerContext ctx, $5.ApprovalRequestDecideRequest request);
  $async.Future<$5.LedgerSearchResponse> ledgerSearch(
      $pb.ServerContext ctx, $5.LedgerSearchRequest request);
  $async.Future<$5.LimitsAuditSearchResponse> limitsAuditSearch(
      $pb.ServerContext ctx, $5.LimitsAuditSearchRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'PolicySave':
        return $5.PolicySaveRequest();
      case 'PolicyGet':
        return $5.PolicyGetRequest();
      case 'PolicySearch':
        return $5.PolicySearchRequest();
      case 'PolicyDelete':
        return $5.PolicyDeleteRequest();
      case 'PolicyHistory':
        return $5.PolicyHistoryRequest();
      case 'ApprovalRequestList':
        return $5.ApprovalRequestListRequest();
      case 'ApprovalRequestGet':
        return $5.ApprovalRequestGetRequest();
      case 'ApprovalRequestDecide':
        return $5.ApprovalRequestDecideRequest();
      case 'LedgerSearch':
        return $5.LedgerSearchRequest();
      case 'LimitsAuditSearch':
        return $5.LimitsAuditSearchRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'PolicySave':
        return policySave(ctx, request as $5.PolicySaveRequest);
      case 'PolicyGet':
        return policyGet(ctx, request as $5.PolicyGetRequest);
      case 'PolicySearch':
        return policySearch(ctx, request as $5.PolicySearchRequest);
      case 'PolicyDelete':
        return policyDelete(ctx, request as $5.PolicyDeleteRequest);
      case 'PolicyHistory':
        return policyHistory(ctx, request as $5.PolicyHistoryRequest);
      case 'ApprovalRequestList':
        return approvalRequestList(
            ctx, request as $5.ApprovalRequestListRequest);
      case 'ApprovalRequestGet':
        return approvalRequestGet(ctx, request as $5.ApprovalRequestGetRequest);
      case 'ApprovalRequestDecide':
        return approvalRequestDecide(
            ctx, request as $5.ApprovalRequestDecideRequest);
      case 'LedgerSearch':
        return ledgerSearch(ctx, request as $5.LedgerSearchRequest);
      case 'LimitsAuditSearch':
        return limitsAuditSearch(ctx, request as $5.LimitsAuditSearchRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      LimitsAdminServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => LimitsAdminServiceBase$messageJson;
}
