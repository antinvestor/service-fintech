// This is a generated file - do not edit.
//
// Generated from operations/v1/operations.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'operations.pb.dart' as $3;
import 'operations.pbjson.dart';

export 'operations.pb.dart';

abstract class OperationsServiceBase extends $pb.GeneratedService {
  $async.Future<$3.TransferOrderExecuteResponse> transferOrderExecute(
      $pb.ServerContext ctx, $3.TransferOrderExecuteRequest request);
  $async.Future<$3.TransferOrderSearchResponse> transferOrderSearch(
      $pb.ServerContext ctx, $3.TransferOrderSearchRequest request);
  $async.Future<$3.IncomingPaymentNotifyResponse> incomingPaymentNotify(
      $pb.ServerContext ctx, $3.IncomingPaymentNotifyRequest request);
  $async.Future<$3.PaymentAllocateResponse> paymentAllocate(
      $pb.ServerContext ctx, $3.PaymentAllocateRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'TransferOrderExecute':
        return $3.TransferOrderExecuteRequest();
      case 'TransferOrderSearch':
        return $3.TransferOrderSearchRequest();
      case 'IncomingPaymentNotify':
        return $3.IncomingPaymentNotifyRequest();
      case 'PaymentAllocate':
        return $3.PaymentAllocateRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'TransferOrderExecute':
        return transferOrderExecute(
            ctx, request as $3.TransferOrderExecuteRequest);
      case 'TransferOrderSearch':
        return transferOrderSearch(
            ctx, request as $3.TransferOrderSearchRequest);
      case 'IncomingPaymentNotify':
        return incomingPaymentNotify(
            ctx, request as $3.IncomingPaymentNotifyRequest);
      case 'PaymentAllocate':
        return paymentAllocate(ctx, request as $3.PaymentAllocateRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      OperationsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => OperationsServiceBase$messageJson;
}
