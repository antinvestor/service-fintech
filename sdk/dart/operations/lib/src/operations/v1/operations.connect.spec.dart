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
}
