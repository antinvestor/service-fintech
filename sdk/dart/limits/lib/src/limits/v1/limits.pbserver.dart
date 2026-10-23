//
//  Generated code. Do not modify.
//  source: limits/v1/limits.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'limits.pb.dart' as $9;
import 'limits.pbjson.dart';

export 'limits.pb.dart';

abstract class LimitsServiceBase extends $pb.GeneratedService {
  $async.Future<$9.CheckResponse> check($pb.ServerContext ctx, $9.CheckRequest request);
  $async.Future<$9.ReserveResponse> reserve($pb.ServerContext ctx, $9.ReserveRequest request);
  $async.Future<$9.CommitResponse> commit($pb.ServerContext ctx, $9.CommitRequest request);
  $async.Future<$9.ReleaseResponse> release($pb.ServerContext ctx, $9.ReleaseRequest request);
  $async.Future<$9.ReverseResponse> reverse($pb.ServerContext ctx, $9.ReverseRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Check': return $9.CheckRequest();
      case 'Reserve': return $9.ReserveRequest();
      case 'Commit': return $9.CommitRequest();
      case 'Release': return $9.ReleaseRequest();
      case 'Reverse': return $9.ReverseRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Check': return this.check(ctx, request as $9.CheckRequest);
      case 'Reserve': return this.reserve(ctx, request as $9.ReserveRequest);
      case 'Commit': return this.commit(ctx, request as $9.CommitRequest);
      case 'Release': return this.release(ctx, request as $9.ReleaseRequest);
      case 'Reverse': return this.reverse(ctx, request as $9.ReverseRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => LimitsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => LimitsServiceBase$messageJson;
}

abstract class LimitsAdminServiceBase extends $pb.GeneratedService {
  $async.Future<$9.PolicySaveResponse> policySave($pb.ServerContext ctx, $9.PolicySaveRequest request);
  $async.Future<$9.PolicyGetResponse> policyGet($pb.ServerContext ctx, $9.PolicyGetRequest request);
  $async.Future<$9.PolicySearchResponse> policySearch($pb.ServerContext ctx, $9.PolicySearchRequest request);
  $async.Future<$9.PolicyDeleteResponse> policyDelete($pb.ServerContext ctx, $9.PolicyDeleteRequest request);
  $async.Future<$9.PolicyHistoryResponse> policyHistory($pb.ServerContext ctx, $9.PolicyHistoryRequest request);
  $async.Future<$9.ApprovalRequestListResponse> approvalRequestList($pb.ServerContext ctx, $9.ApprovalRequestListRequest request);
  $async.Future<$9.ApprovalRequestGetResponse> approvalRequestGet($pb.ServerContext ctx, $9.ApprovalRequestGetRequest request);
  $async.Future<$9.ApprovalRequestDecideResponse> approvalRequestDecide($pb.ServerContext ctx, $9.ApprovalRequestDecideRequest request);
  $async.Future<$9.LedgerSearchResponse> ledgerSearch($pb.ServerContext ctx, $9.LedgerSearchRequest request);
  $async.Future<$9.LimitsAuditSearchResponse> limitsAuditSearch($pb.ServerContext ctx, $9.LimitsAuditSearchRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'PolicySave': return $9.PolicySaveRequest();
      case 'PolicyGet': return $9.PolicyGetRequest();
      case 'PolicySearch': return $9.PolicySearchRequest();
      case 'PolicyDelete': return $9.PolicyDeleteRequest();
      case 'PolicyHistory': return $9.PolicyHistoryRequest();
      case 'ApprovalRequestList': return $9.ApprovalRequestListRequest();
      case 'ApprovalRequestGet': return $9.ApprovalRequestGetRequest();
      case 'ApprovalRequestDecide': return $9.ApprovalRequestDecideRequest();
      case 'LedgerSearch': return $9.LedgerSearchRequest();
      case 'LimitsAuditSearch': return $9.LimitsAuditSearchRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'PolicySave': return this.policySave(ctx, request as $9.PolicySaveRequest);
      case 'PolicyGet': return this.policyGet(ctx, request as $9.PolicyGetRequest);
      case 'PolicySearch': return this.policySearch(ctx, request as $9.PolicySearchRequest);
      case 'PolicyDelete': return this.policyDelete(ctx, request as $9.PolicyDeleteRequest);
      case 'PolicyHistory': return this.policyHistory(ctx, request as $9.PolicyHistoryRequest);
      case 'ApprovalRequestList': return this.approvalRequestList(ctx, request as $9.ApprovalRequestListRequest);
      case 'ApprovalRequestGet': return this.approvalRequestGet(ctx, request as $9.ApprovalRequestGetRequest);
      case 'ApprovalRequestDecide': return this.approvalRequestDecide(ctx, request as $9.ApprovalRequestDecideRequest);
      case 'LedgerSearch': return this.ledgerSearch(ctx, request as $9.LedgerSearchRequest);
      case 'LimitsAuditSearch': return this.limitsAuditSearch(ctx, request as $9.LimitsAuditSearchRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => LimitsAdminServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => LimitsAdminServiceBase$messageJson;
}

