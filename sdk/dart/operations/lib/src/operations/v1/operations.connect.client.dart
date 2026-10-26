//
//  Generated code. Do not modify.
//  source: operations/v1/operations.proto
//

import "package:connectrpc/connect.dart" as connect;
import "operations.pb.dart" as operationsv1operations;
import "operations.connect.spec.dart" as specs;

extension type OperationsServiceClient (connect.Transport _transport) {
  Future<operationsv1operations.TransferOrderExecuteResponse> transferOrderExecute(
    operationsv1operations.TransferOrderExecuteRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OperationsService.transferOrderExecute,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Stream<operationsv1operations.TransferOrderSearchResponse> transferOrderSearch(
    operationsv1operations.TransferOrderSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.OperationsService.transferOrderSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<operationsv1operations.IncomingPaymentNotifyResponse> incomingPaymentNotify(
    operationsv1operations.IncomingPaymentNotifyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OperationsService.incomingPaymentNotify,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<operationsv1operations.PaymentAllocateResponse> paymentAllocate(
    operationsv1operations.PaymentAllocateRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OperationsService.paymentAllocate,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// IncomingPaymentSearch lists received payments, for staff to find the
  /// ones that matched nobody.
  Stream<operationsv1operations.IncomingPaymentSearchResponse> incomingPaymentSearch(
    operationsv1operations.IncomingPaymentSearchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.OperationsService.incomingPaymentSearch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// IncomingPaymentAssign ties an unmatched payment to its loan and
  /// allocates it.
  Future<operationsv1operations.IncomingPaymentAssignResponse> incomingPaymentAssign(
    operationsv1operations.IncomingPaymentAssignRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OperationsService.incomingPaymentAssign,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
