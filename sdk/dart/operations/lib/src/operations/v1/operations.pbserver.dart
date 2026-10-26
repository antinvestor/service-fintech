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

import 'operations.pb.dart' as $4;
import 'operations.pbjson.dart';

export 'operations.pb.dart';

abstract class OperationsServiceBase extends $pb.GeneratedService {
  $async.Future<$4.TransferOrderExecuteResponse> transferOrderExecute(
      $pb.ServerContext ctx, $4.TransferOrderExecuteRequest request);
  $async.Future<$4.TransferOrderSearchResponse> transferOrderSearch(
      $pb.ServerContext ctx, $4.TransferOrderSearchRequest request);
  $async.Future<$4.IncomingPaymentNotifyResponse> incomingPaymentNotify(
      $pb.ServerContext ctx, $4.IncomingPaymentNotifyRequest request);
  $async.Future<$4.PaymentAllocateResponse> paymentAllocate(
      $pb.ServerContext ctx, $4.PaymentAllocateRequest request);
  $async.Future<$4.IncomingPaymentSearchResponse> incomingPaymentSearch(
      $pb.ServerContext ctx, $4.IncomingPaymentSearchRequest request);
  $async.Future<$4.IncomingPaymentAssignResponse> incomingPaymentAssign(
      $pb.ServerContext ctx, $4.IncomingPaymentAssignRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'TransferOrderExecute':
        return $4.TransferOrderExecuteRequest();
      case 'TransferOrderSearch':
        return $4.TransferOrderSearchRequest();
      case 'IncomingPaymentNotify':
        return $4.IncomingPaymentNotifyRequest();
      case 'PaymentAllocate':
        return $4.PaymentAllocateRequest();
      case 'IncomingPaymentSearch':
        return $4.IncomingPaymentSearchRequest();
      case 'IncomingPaymentAssign':
        return $4.IncomingPaymentAssignRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'TransferOrderExecute':
        return transferOrderExecute(
            ctx, request as $4.TransferOrderExecuteRequest);
      case 'TransferOrderSearch':
        return transferOrderSearch(
            ctx, request as $4.TransferOrderSearchRequest);
      case 'IncomingPaymentNotify':
        return incomingPaymentNotify(
            ctx, request as $4.IncomingPaymentNotifyRequest);
      case 'PaymentAllocate':
        return paymentAllocate(ctx, request as $4.PaymentAllocateRequest);
      case 'IncomingPaymentSearch':
        return incomingPaymentSearch(
            ctx, request as $4.IncomingPaymentSearchRequest);
      case 'IncomingPaymentAssign':
        return incomingPaymentAssign(
            ctx, request as $4.IncomingPaymentAssignRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      OperationsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => OperationsServiceBase$messageJson;
}
