//
//  Generated code. Do not modify.
//  source: limits/v1/limits.proto
//

import "package:connectrpc/connect.dart" as connect;
import "limits.pb.dart" as limitsv1limits;
import "limits.connect.spec.dart" as specs;

extension type LimitsServiceClient (connect.Transport _transport) {
  Future<limitsv1limits.CheckResponse> check(
    limitsv1limits.CheckRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsService.check,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<limitsv1limits.ReserveResponse> reserve(
    limitsv1limits.ReserveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsService.reserve,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<limitsv1limits.CommitResponse> commit(
    limitsv1limits.CommitRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsService.commit,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<limitsv1limits.ReleaseResponse> release(
    limitsv1limits.ReleaseRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsService.release,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<limitsv1limits.ReverseResponse> reverse(
    limitsv1limits.ReverseRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsService.reverse,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
extension type LimitsAdminServiceClient (connect.Transport _transport) {
  Future<limitsv1limits.PolicySaveResponse> policySave(
    limitsv1limits.PolicySaveRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsAdminService.policySave,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<limitsv1limits.PolicyGetResponse> policyGet(
    limitsv1limits.PolicyGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsAdminService.policyGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Stream<limitsv1limits.PolicySearchResponse> policySearch(
    limitsv1limits.PolicySearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LimitsAdminService.policySearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<limitsv1limits.PolicyDeleteResponse> policyDelete(
    limitsv1limits.PolicyDeleteRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsAdminService.policyDelete,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PolicyHistory pages through a policy's immutable version snapshots, newest first.
  Future<limitsv1limits.PolicyHistoryResponse> policyHistory(
    limitsv1limits.PolicyHistoryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsAdminService.policyHistory,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Stream<limitsv1limits.ApprovalRequestListResponse> approvalRequestList(
    limitsv1limits.ApprovalRequestListRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LimitsAdminService.approvalRequestList,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<limitsv1limits.ApprovalRequestGetResponse> approvalRequestGet(
    limitsv1limits.ApprovalRequestGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsAdminService.approvalRequestGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<limitsv1limits.ApprovalRequestDecideResponse> approvalRequestDecide(
    limitsv1limits.ApprovalRequestDecideRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsAdminService.approvalRequestDecide,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Stream<limitsv1limits.LedgerSearchResponse> ledgerSearch(
    limitsv1limits.LedgerSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LimitsAdminService.ledgerSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Stream<limitsv1limits.LimitsAuditSearchResponse> limitsAuditSearch(
    limitsv1limits.LimitsAuditSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.LimitsAdminService.limitsAuditSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// LimitsJobRun runs one pass of a periodic job. Called by the platform
  /// scheduler (trustage); the permission is bound to no role and granted to
  /// the scheduler's service account.
  Future<limitsv1limits.LimitsJobRunResponse> limitsJobRun(
    limitsv1limits.LimitsJobRunRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.LimitsAdminService.limitsJobRun,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
