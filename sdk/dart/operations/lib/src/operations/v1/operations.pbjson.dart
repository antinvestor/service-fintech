//
//  Generated code. Do not modify.
//  source: operations/v1/operations.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../common/v1/common.pbjson.dart' as $8;
import '../../common/v1/money.pbjson.dart' as $7;
import '../../google/protobuf/struct.pbjson.dart' as $6;

@$core.Deprecated('Use transferOrderObjectDescriptor instead')
const TransferOrderObject$json = {
  '1': 'TransferOrderObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'debit_account_ref', '3': 2, '4': 1, '5': 9, '10': 'debitAccountRef'},
    {'1': 'credit_account_ref', '3': 3, '4': 1, '5': 9, '10': 'creditAccountRef'},
    {'1': 'amount', '3': 4, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'amount'},
    {'1': 'order_type', '3': 6, '4': 1, '5': 5, '10': 'orderType'},
    {'1': 'reference', '3': 7, '4': 1, '5': 9, '10': 'reference'},
    {'1': 'description', '3': 8, '4': 1, '5': 9, '10': 'description'},
    {'1': 'extra_data', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'extraData'},
    {'1': 'state', '3': 10, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
  ],
  '9': [
    {'1': 5, '2': 6},
  ],
};

/// Descriptor for `TransferOrderObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOrderObjectDescriptor = $convert.base64Decode(
    'ChNUcmFuc2Zlck9yZGVyT2JqZWN0Eg4KAmlkGAEgASgJUgJpZBIqChFkZWJpdF9hY2NvdW50X3'
    'JlZhgCIAEoCVIPZGViaXRBY2NvdW50UmVmEiwKEmNyZWRpdF9hY2NvdW50X3JlZhgDIAEoCVIQ'
    'Y3JlZGl0QWNjb3VudFJlZhIoCgZhbW91bnQYBCABKAsyEC5jb21tb24udjEuTW9uZXlSBmFtb3'
    'VudBIdCgpvcmRlcl90eXBlGAYgASgFUglvcmRlclR5cGUSHAoJcmVmZXJlbmNlGAcgASgJUgly'
    'ZWZlcmVuY2USIAoLZGVzY3JpcHRpb24YCCABKAlSC2Rlc2NyaXB0aW9uEjYKCmV4dHJhX2RhdG'
    'EYCSABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0UglleHRyYURhdGESJgoFc3RhdGUYCiAB'
    'KA4yEC5jb21tb24udjEuU1RBVEVSBXN0YXRlSgQIBRAG');

@$core.Deprecated('Use transferOrderExecuteRequestDescriptor instead')
const TransferOrderExecuteRequest$json = {
  '1': 'TransferOrderExecuteRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.operations.v1.TransferOrderObject', '10': 'data'},
  ],
};

/// Descriptor for `TransferOrderExecuteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOrderExecuteRequestDescriptor = $convert.base64Decode(
    'ChtUcmFuc2Zlck9yZGVyRXhlY3V0ZVJlcXVlc3QSNgoEZGF0YRgBIAEoCzIiLm9wZXJhdGlvbn'
    'MudjEuVHJhbnNmZXJPcmRlck9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use transferOrderExecuteResponseDescriptor instead')
const TransferOrderExecuteResponse$json = {
  '1': 'TransferOrderExecuteResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.operations.v1.TransferOrderObject', '10': 'data'},
  ],
};

/// Descriptor for `TransferOrderExecuteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOrderExecuteResponseDescriptor = $convert.base64Decode(
    'ChxUcmFuc2Zlck9yZGVyRXhlY3V0ZVJlc3BvbnNlEjYKBGRhdGEYASABKAsyIi5vcGVyYXRpb2'
    '5zLnYxLlRyYW5zZmVyT3JkZXJPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use transferOrderSearchRequestDescriptor instead')
const TransferOrderSearchRequest$json = {
  '1': 'TransferOrderSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'order_type', '3': 2, '4': 1, '5': 5, '10': 'orderType'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `TransferOrderSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOrderSearchRequestDescriptor = $convert.base64Decode(
    'ChpUcmFuc2Zlck9yZGVyU2VhcmNoUmVxdWVzdBIUCgVxdWVyeRgBIAEoCVIFcXVlcnkSHQoKb3'
    'JkZXJfdHlwZRgCIAEoBVIJb3JkZXJUeXBlEi0KBmN1cnNvchgDIAEoCzIVLmNvbW1vbi52MS5Q'
    'YWdlQ3Vyc29yUgZjdXJzb3I=');

@$core.Deprecated('Use transferOrderSearchResponseDescriptor instead')
const TransferOrderSearchResponse$json = {
  '1': 'TransferOrderSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.operations.v1.TransferOrderObject', '10': 'data'},
  ],
};

/// Descriptor for `TransferOrderSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOrderSearchResponseDescriptor = $convert.base64Decode(
    'ChtUcmFuc2Zlck9yZGVyU2VhcmNoUmVzcG9uc2USNgoEZGF0YRgBIAMoCzIiLm9wZXJhdGlvbn'
    'MudjEuVHJhbnNmZXJPcmRlck9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use incomingPaymentNotifyRequestDescriptor instead')
const IncomingPaymentNotifyRequest$json = {
  '1': 'IncomingPaymentNotifyRequest',
  '2': [
    {'1': 'transaction_id', '3': 1, '4': 1, '5': 9, '10': 'transactionId'},
    {'1': 'amount', '3': 2, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'amount'},
    {'1': 'payer_reference', '3': 3, '4': 1, '5': 9, '10': 'payerReference'},
    {'1': 'payer_name', '3': 4, '4': 1, '5': 9, '10': 'payerName'},
    {'1': 'product_id', '3': 5, '4': 1, '5': 9, '10': 'productId'},
    {'1': 'group_id', '3': 6, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'properties', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `IncomingPaymentNotifyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List incomingPaymentNotifyRequestDescriptor = $convert.base64Decode(
    'ChxJbmNvbWluZ1BheW1lbnROb3RpZnlSZXF1ZXN0EiUKDnRyYW5zYWN0aW9uX2lkGAEgASgJUg'
    '10cmFuc2FjdGlvbklkEigKBmFtb3VudBgCIAEoCzIQLmNvbW1vbi52MS5Nb25leVIGYW1vdW50'
    'EicKD3BheWVyX3JlZmVyZW5jZRgDIAEoCVIOcGF5ZXJSZWZlcmVuY2USHQoKcGF5ZXJfbmFtZR'
    'gEIAEoCVIJcGF5ZXJOYW1lEh0KCnByb2R1Y3RfaWQYBSABKAlSCXByb2R1Y3RJZBIZCghncm91'
    'cF9pZBgGIAEoCVIHZ3JvdXBJZBI3Cgpwcm9wZXJ0aWVzGAcgASgLMhcuZ29vZ2xlLnByb3RvYn'
    'VmLlN0cnVjdFIKcHJvcGVydGllcw==');

@$core.Deprecated('Use incomingPaymentNotifyResponseDescriptor instead')
const IncomingPaymentNotifyResponse$json = {
  '1': 'IncomingPaymentNotifyResponse',
  '2': [
    {'1': 'payment_id', '3': 1, '4': 1, '5': 9, '10': 'paymentId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'result', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'result'},
  ],
};

/// Descriptor for `IncomingPaymentNotifyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List incomingPaymentNotifyResponseDescriptor = $convert.base64Decode(
    'Ch1JbmNvbWluZ1BheW1lbnROb3RpZnlSZXNwb25zZRIdCgpwYXltZW50X2lkGAEgASgJUglwYX'
    'ltZW50SWQSFgoGc3RhdHVzGAIgASgJUgZzdGF0dXMSLwoGcmVzdWx0GAMgASgLMhcuZ29vZ2xl'
    'LnByb3RvYnVmLlN0cnVjdFIGcmVzdWx0');

@$core.Deprecated('Use paymentAllocateRequestDescriptor instead')
const PaymentAllocateRequest$json = {
  '1': 'PaymentAllocateRequest',
  '2': [
    {'1': 'payment_id', '3': 1, '4': 1, '5': 9, '10': 'paymentId'},
  ],
};

/// Descriptor for `PaymentAllocateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentAllocateRequestDescriptor = $convert.base64Decode(
    'ChZQYXltZW50QWxsb2NhdGVSZXF1ZXN0Eh0KCnBheW1lbnRfaWQYASABKAlSCXBheW1lbnRJZA'
    '==');

@$core.Deprecated('Use paymentAllocateResponseDescriptor instead')
const PaymentAllocateResponse$json = {
  '1': 'PaymentAllocateResponse',
  '2': [
    {'1': 'result', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'result'},
  ],
};

/// Descriptor for `PaymentAllocateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentAllocateResponseDescriptor = $convert.base64Decode(
    'ChdQYXltZW50QWxsb2NhdGVSZXNwb25zZRIvCgZyZXN1bHQYASABKAsyFy5nb29nbGUucHJvdG'
    '9idWYuU3RydWN0UgZyZXN1bHQ=');

const $core.Map<$core.String, $core.dynamic> OperationsServiceBase$json = {
  '1': 'OperationsService',
  '2': [
    {'1': 'TransferOrderExecute', '2': '.operations.v1.TransferOrderExecuteRequest', '3': '.operations.v1.TransferOrderExecuteResponse', '4': {}},
    {'1': 'TransferOrderSearch', '2': '.operations.v1.TransferOrderSearchRequest', '3': '.operations.v1.TransferOrderSearchResponse', '4': {}, '6': true},
    {'1': 'IncomingPaymentNotify', '2': '.operations.v1.IncomingPaymentNotifyRequest', '3': '.operations.v1.IncomingPaymentNotifyResponse', '4': {}},
    {'1': 'PaymentAllocate', '2': '.operations.v1.PaymentAllocateRequest', '3': '.operations.v1.PaymentAllocateResponse', '4': {}},
  ],
  '3': {},
};

@$core.Deprecated('Use operationsServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> OperationsServiceBase$messageJson = {
  '.operations.v1.TransferOrderExecuteRequest': TransferOrderExecuteRequest$json,
  '.operations.v1.TransferOrderObject': TransferOrderObject$json,
  '.common.v1.Money': $7.Money$json,
  '.google.protobuf.Struct': $6.Struct$json,
  '.google.protobuf.Struct.FieldsEntry': $6.Struct_FieldsEntry$json,
  '.google.protobuf.Value': $6.Value$json,
  '.google.protobuf.ListValue': $6.ListValue$json,
  '.operations.v1.TransferOrderExecuteResponse': TransferOrderExecuteResponse$json,
  '.operations.v1.TransferOrderSearchRequest': TransferOrderSearchRequest$json,
  '.common.v1.PageCursor': $8.PageCursor$json,
  '.operations.v1.TransferOrderSearchResponse': TransferOrderSearchResponse$json,
  '.operations.v1.IncomingPaymentNotifyRequest': IncomingPaymentNotifyRequest$json,
  '.operations.v1.IncomingPaymentNotifyResponse': IncomingPaymentNotifyResponse$json,
  '.operations.v1.PaymentAllocateRequest': PaymentAllocateRequest$json,
  '.operations.v1.PaymentAllocateResponse': PaymentAllocateResponse$json,
};

/// Descriptor for `OperationsService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List operationsServiceDescriptor = $convert.base64Decode(
    'ChFPcGVyYXRpb25zU2VydmljZRKHAQoUVHJhbnNmZXJPcmRlckV4ZWN1dGUSKi5vcGVyYXRpb2'
    '5zLnYxLlRyYW5zZmVyT3JkZXJFeGVjdXRlUmVxdWVzdBorLm9wZXJhdGlvbnMudjEuVHJhbnNm'
    'ZXJPcmRlckV4ZWN1dGVSZXNwb25zZSIWgrUYEgoQdHJhbnNmZXJfZXhlY3V0ZRKDAQoTVHJhbn'
    'NmZXJPcmRlclNlYXJjaBIpLm9wZXJhdGlvbnMudjEuVHJhbnNmZXJPcmRlclNlYXJjaFJlcXVl'
    'c3QaKi5vcGVyYXRpb25zLnYxLlRyYW5zZmVyT3JkZXJTZWFyY2hSZXNwb25zZSITgrUYDwoNdH'
    'JhbnNmZXJfdmlldzABEogBChVJbmNvbWluZ1BheW1lbnROb3RpZnkSKy5vcGVyYXRpb25zLnYx'
    'LkluY29taW5nUGF5bWVudE5vdGlmeVJlcXVlc3QaLC5vcGVyYXRpb25zLnYxLkluY29taW5nUG'
    'F5bWVudE5vdGlmeVJlc3BvbnNlIhSCtRgQCg5wYXltZW50X25vdGlmeRJ4Cg9QYXltZW50QWxs'
    'b2NhdGUSJS5vcGVyYXRpb25zLnYxLlBheW1lbnRBbGxvY2F0ZVJlcXVlc3QaJi5vcGVyYXRpb2'
    '5zLnYxLlBheW1lbnRBbGxvY2F0ZVJlc3BvbnNlIhaCtRgSChBwYXltZW50X2FsbG9jYXRlGp4D'
    'grUYmQMKEnNlcnZpY2Vfb3BlcmF0aW9ucxIQdHJhbnNmZXJfZXhlY3V0ZRINdHJhbnNmZXJfdm'
    'lldxIOcGF5bWVudF9ub3RpZnkSEHBheW1lbnRfYWxsb2NhdGUaRQgBEhB0cmFuc2Zlcl9leGVj'
    'dXRlEg10cmFuc2Zlcl92aWV3Eg5wYXltZW50X25vdGlmeRIQcGF5bWVudF9hbGxvY2F0ZRpFCA'
    'ISEHRyYW5zZmVyX2V4ZWN1dGUSDXRyYW5zZmVyX3ZpZXcSDnBheW1lbnRfbm90aWZ5EhBwYXlt'
    'ZW50X2FsbG9jYXRlGkUIAxIQdHJhbnNmZXJfZXhlY3V0ZRINdHJhbnNmZXJfdmlldxIOcGF5bW'
    'VudF9ub3RpZnkSEHBheW1lbnRfYWxsb2NhdGUaEQgEEg10cmFuc2Zlcl92aWV3GhEIBRINdHJh'
    'bnNmZXJfdmlldxpFCAYSEHRyYW5zZmVyX2V4ZWN1dGUSDXRyYW5zZmVyX3ZpZXcSDnBheW1lbn'
    'Rfbm90aWZ5EhBwYXltZW50X2FsbG9jYXRl');

