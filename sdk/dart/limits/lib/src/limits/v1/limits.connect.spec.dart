//
//  Generated code. Do not modify.
//  source: limits/v1/limits.proto
//

import "package:connectrpc/connect.dart" as connect;
import "limits.pb.dart" as limitsv1limits;

abstract final class LimitsService {
  /// Fully-qualified name of the LimitsService service.
  static const name = 'limits.v1.LimitsService';

  static const check = connect.Spec(
    '/$name/Check',
    connect.StreamType.unary,
    limitsv1limits.CheckRequest.new,
    limitsv1limits.CheckResponse.new,
  );

  static const reserve = connect.Spec(
    '/$name/Reserve',
    connect.StreamType.unary,
    limitsv1limits.ReserveRequest.new,
    limitsv1limits.ReserveResponse.new,
  );

  static const commit = connect.Spec(
    '/$name/Commit',
    connect.StreamType.unary,
    limitsv1limits.CommitRequest.new,
    limitsv1limits.CommitResponse.new,
  );

  static const release = connect.Spec(
    '/$name/Release',
    connect.StreamType.unary,
    limitsv1limits.ReleaseRequest.new,
    limitsv1limits.ReleaseResponse.new,
  );

  static const reverse = connect.Spec(
    '/$name/Reverse',
    connect.StreamType.unary,
    limitsv1limits.ReverseRequest.new,
    limitsv1limits.ReverseResponse.new,
  );
}
abstract final class LimitsAdminService {
  /// Fully-qualified name of the LimitsAdminService service.
  static const name = 'limits.v1.LimitsAdminService';

  static const policySave = connect.Spec(
    '/$name/PolicySave',
    connect.StreamType.unary,
    limitsv1limits.PolicySaveRequest.new,
    limitsv1limits.PolicySaveResponse.new,
  );

  static const policyGet = connect.Spec(
    '/$name/PolicyGet',
    connect.StreamType.unary,
    limitsv1limits.PolicyGetRequest.new,
    limitsv1limits.PolicyGetResponse.new,
  );

  static const policySearch = connect.Spec(
    '/$name/PolicySearch',
    connect.StreamType.server,
    limitsv1limits.PolicySearchRequest.new,
    limitsv1limits.PolicySearchResponse.new,
  );

  static const policyDelete = connect.Spec(
    '/$name/PolicyDelete',
    connect.StreamType.unary,
    limitsv1limits.PolicyDeleteRequest.new,
    limitsv1limits.PolicyDeleteResponse.new,
  );

  /// PolicyHistory pages through a policy's immutable version snapshots, newest first.
  static const policyHistory = connect.Spec(
    '/$name/PolicyHistory',
    connect.StreamType.unary,
    limitsv1limits.PolicyHistoryRequest.new,
    limitsv1limits.PolicyHistoryResponse.new,
  );

  static const approvalRequestList = connect.Spec(
    '/$name/ApprovalRequestList',
    connect.StreamType.server,
    limitsv1limits.ApprovalRequestListRequest.new,
    limitsv1limits.ApprovalRequestListResponse.new,
  );

  static const approvalRequestGet = connect.Spec(
    '/$name/ApprovalRequestGet',
    connect.StreamType.unary,
    limitsv1limits.ApprovalRequestGetRequest.new,
    limitsv1limits.ApprovalRequestGetResponse.new,
  );

  static const approvalRequestDecide = connect.Spec(
    '/$name/ApprovalRequestDecide',
    connect.StreamType.unary,
    limitsv1limits.ApprovalRequestDecideRequest.new,
    limitsv1limits.ApprovalRequestDecideResponse.new,
  );

  static const ledgerSearch = connect.Spec(
    '/$name/LedgerSearch',
    connect.StreamType.server,
    limitsv1limits.LedgerSearchRequest.new,
    limitsv1limits.LedgerSearchResponse.new,
  );

  static const limitsAuditSearch = connect.Spec(
    '/$name/LimitsAuditSearch',
    connect.StreamType.server,
    limitsv1limits.LimitsAuditSearchRequest.new,
    limitsv1limits.LimitsAuditSearchResponse.new,
  );
}
