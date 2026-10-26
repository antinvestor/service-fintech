//
//  Generated code. Do not modify.
//  source: operations/v1/operations.proto
//

import "package:connectrpc/connect.dart" as connect;
import "operations.pb.dart" as operationsv1operations;

abstract final class OperationsService {
  /// Fully-qualified name of the OperationsService service.
  static const name = 'operations.v1.OperationsService';

  static const transferOrderExecute = connect.Spec(
    '/$name/TransferOrderExecute',
    connect.StreamType.unary,
    operationsv1operations.TransferOrderExecuteRequest.new,
    operationsv1operations.TransferOrderExecuteResponse.new,
  );

  static const transferOrderSearch = connect.Spec(
    '/$name/TransferOrderSearch',
    connect.StreamType.server,
    operationsv1operations.TransferOrderSearchRequest.new,
    operationsv1operations.TransferOrderSearchResponse.new,
  );

  static const incomingPaymentNotify = connect.Spec(
    '/$name/IncomingPaymentNotify',
    connect.StreamType.unary,
    operationsv1operations.IncomingPaymentNotifyRequest.new,
    operationsv1operations.IncomingPaymentNotifyResponse.new,
  );

  static const paymentAllocate = connect.Spec(
    '/$name/PaymentAllocate',
    connect.StreamType.unary,
    operationsv1operations.PaymentAllocateRequest.new,
    operationsv1operations.PaymentAllocateResponse.new,
  );

  /// IncomingPaymentSearch lists received payments, for staff to find the
  /// ones that matched nobody.
  static const incomingPaymentSearch = connect.Spec(
    '/$name/IncomingPaymentSearch',
    connect.StreamType.server,
    operationsv1operations.IncomingPaymentSearchRequest.new,
    operationsv1operations.IncomingPaymentSearchResponse.new,
  );

  /// IncomingPaymentAssign ties an unmatched payment to its loan and
  /// allocates it.
  static const incomingPaymentAssign = connect.Spec(
    '/$name/IncomingPaymentAssign',
    connect.StreamType.unary,
    operationsv1operations.IncomingPaymentAssignRequest.new,
    operationsv1operations.IncomingPaymentAssignResponse.new,
  );

  /// OperationsJobRun runs one batch of a periodic job. Called by the
  /// platform scheduler (trustage); only service accounts hold the permission.
  static const operationsJobRun = connect.Spec(
    '/$name/OperationsJobRun',
    connect.StreamType.unary,
    operationsv1operations.OperationsJobRunRequest.new,
    operationsv1operations.OperationsJobRunResponse.new,
  );

  /// GroupObligationsRaise raises a group period's savings obligations and
  /// applies money the members already paid. Called by the group service; only
  /// service accounts hold the permission. Retrying raises nothing new.
  static const groupObligationsRaise = connect.Spec(
    '/$name/GroupObligationsRaise',
    connect.StreamType.unary,
    operationsv1operations.GroupObligationsRaiseRequest.new,
    operationsv1operations.GroupObligationsRaiseResponse.new,
  );

  /// GroupPeriodClose applies money members paid, charges the penalty to
  /// each member still owing, and reports the period's statement. Called by
  /// the group service; retrying charges no second penalty.
  static const groupPeriodClose = connect.Spec(
    '/$name/GroupPeriodClose',
    connect.StreamType.unary,
    operationsv1operations.GroupPeriodCloseRequest.new,
    operationsv1operations.GroupPeriodCloseResponse.new,
  );
}
