// This is a generated file - do not edit.
//
// Generated from operations/v1/operations.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'package:protobuf/well_known_types/google/protobuf/struct.pbjson.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pbjson.dart'
    as $3;

import '../../common/v1/common.pbjson.dart' as $2;
import '../../common/v1/money.pbjson.dart' as $0;

@$core.Deprecated('Use transferOrderTypeDescriptor instead')
const TransferOrderType$json = {
  '1': 'TransferOrderType',
  '2': [
    {'1': 'TRANSFER_ORDER_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'TRANSFER_ORDER_TYPE_PAYMENT', '2': 1},
    {'1': 'TRANSFER_ORDER_TYPE_PAYMENT_IDENTIFIED', '2': 2},
    {'1': 'TRANSFER_ORDER_TYPE_PAYMENT_ALLOCATED', '2': 3},
    {'1': 'TRANSFER_ORDER_TYPE_DISBURSEMENT', '2': 6},
    {'1': 'TRANSFER_ORDER_TYPE_DISBURSEMENT_REVERSAL', '2': 7},
    {'1': 'TRANSFER_ORDER_TYPE_DISBURSEMENT_REVERSAL_REROUTE', '2': 8},
    {'1': 'TRANSFER_ORDER_TYPE_TERMINAL_DISBURSEMENT', '2': 9},
    {'1': 'TRANSFER_ORDER_TYPE_TERMINAL_DISBURSEMENT_RECOVERY', '2': 10},
    {'1': 'TRANSFER_ORDER_TYPE_COST', '2': 11},
    {'1': 'TRANSFER_ORDER_TYPE_SERVICE_FEE', '2': 16},
    {'1': 'TRANSFER_ORDER_TYPE_REGISTRATION_FEE', '2': 21},
    {'1': 'TRANSFER_ORDER_TYPE_PERIODIC_SAVING', '2': 25},
    {
      '1': 'TRANSFER_ORDER_TYPE_PERIODIC_SAVINGS_INTEREST_INCOME_DISTRIBUTION',
      '2': 26
    },
    {'1': 'TRANSFER_ORDER_TYPE_PERIODIC_SAVING_RECOVERY', '2': 27},
    {'1': 'TRANSFER_ORDER_TYPE_PENALTY', '2': 31},
    {'1': 'TRANSFER_ORDER_TYPE_PENALTY_CANCEL', '2': 32},
    {'1': 'TRANSFER_ORDER_TYPE_PENALTY_INCOME_DISTRIBUTION', '2': 33},
    {'1': 'TRANSFER_ORDER_TYPE_LOAN_FUNDING_EXTERNAL_LENDING', '2': 36},
    {'1': 'TRANSFER_ORDER_TYPE_LOAN_FUNDING_EXTERNAL_LENDING_PAYBACK', '2': 37},
    {'1': 'TRANSFER_ORDER_TYPE_INVESTOR_DEPLOYMENT', '2': 38},
    {'1': 'TRANSFER_ORDER_TYPE_INVESTOR_PRINCIPAL_RETURN', '2': 39},
    {'1': 'TRANSFER_ORDER_TYPE_INVESTOR_INCOME_DISTRIBUTION', '2': 40},
    {'1': 'TRANSFER_ORDER_TYPE_LOAN', '2': 41},
    {'1': 'TRANSFER_ORDER_TYPE_LOAN_REPAYMENT', '2': 42},
    {'1': 'TRANSFER_ORDER_TYPE_SHUTDOWN_LOAN_RECOVERY', '2': 43},
    {'1': 'TRANSFER_ORDER_TYPE_PLATFORM_FIRST_LOSS_ABSORPTION', '2': 44},
    {'1': 'TRANSFER_ORDER_TYPE_INVESTOR_LOSS_ABSORPTION', '2': 45},
    {'1': 'TRANSFER_ORDER_TYPE_LOAN_INTEREST', '2': 46},
    {'1': 'TRANSFER_ORDER_TYPE_LOAN_INTEREST_REPAYMENT', '2': 47},
    {'1': 'TRANSFER_ORDER_TYPE_LOAN_INTEREST_INCOME_DISTRIBUTION', '2': 48},
    {'1': 'TRANSFER_ORDER_TYPE_LOAN_INSURANCE', '2': 51},
    {'1': 'TRANSFER_ORDER_TYPE_LOAN_INSURANCE_REPAYMENT', '2': 52},
    {'1': 'TRANSFER_ORDER_TYPE_INTER_SUBSCRIPTION_PAYMENT', '2': 71},
  ],
};

/// Descriptor for `TransferOrderType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List transferOrderTypeDescriptor = $convert.base64Decode(
    'ChFUcmFuc2Zlck9yZGVyVHlwZRIjCh9UUkFOU0ZFUl9PUkRFUl9UWVBFX1VOU1BFQ0lGSUVEEA'
    'ASHwobVFJBTlNGRVJfT1JERVJfVFlQRV9QQVlNRU5UEAESKgomVFJBTlNGRVJfT1JERVJfVFlQ'
    'RV9QQVlNRU5UX0lERU5USUZJRUQQAhIpCiVUUkFOU0ZFUl9PUkRFUl9UWVBFX1BBWU1FTlRfQU'
    'xMT0NBVEVEEAMSJAogVFJBTlNGRVJfT1JERVJfVFlQRV9ESVNCVVJTRU1FTlQQBhItCilUUkFO'
    'U0ZFUl9PUkRFUl9UWVBFX0RJU0JVUlNFTUVOVF9SRVZFUlNBTBAHEjUKMVRSQU5TRkVSX09SRE'
    'VSX1RZUEVfRElTQlVSU0VNRU5UX1JFVkVSU0FMX1JFUk9VVEUQCBItCilUUkFOU0ZFUl9PUkRF'
    'Ul9UWVBFX1RFUk1JTkFMX0RJU0JVUlNFTUVOVBAJEjYKMlRSQU5TRkVSX09SREVSX1RZUEVfVE'
    'VSTUlOQUxfRElTQlVSU0VNRU5UX1JFQ09WRVJZEAoSHAoYVFJBTlNGRVJfT1JERVJfVFlQRV9D'
    'T1NUEAsSIwofVFJBTlNGRVJfT1JERVJfVFlQRV9TRVJWSUNFX0ZFRRAQEigKJFRSQU5TRkVSX0'
    '9SREVSX1RZUEVfUkVHSVNUUkFUSU9OX0ZFRRAVEicKI1RSQU5TRkVSX09SREVSX1RZUEVfUEVS'
    'SU9ESUNfU0FWSU5HEBkSRQpBVFJBTlNGRVJfT1JERVJfVFlQRV9QRVJJT0RJQ19TQVZJTkdTX0'
    'lOVEVSRVNUX0lOQ09NRV9ESVNUUklCVVRJT04QGhIwCixUUkFOU0ZFUl9PUkRFUl9UWVBFX1BF'
    'UklPRElDX1NBVklOR19SRUNPVkVSWRAbEh8KG1RSQU5TRkVSX09SREVSX1RZUEVfUEVOQUxUWR'
    'AfEiYKIlRSQU5TRkVSX09SREVSX1RZUEVfUEVOQUxUWV9DQU5DRUwQIBIzCi9UUkFOU0ZFUl9P'
    'UkRFUl9UWVBFX1BFTkFMVFlfSU5DT01FX0RJU1RSSUJVVElPThAhEjUKMVRSQU5TRkVSX09SRE'
    'VSX1RZUEVfTE9BTl9GVU5ESU5HX0VYVEVSTkFMX0xFTkRJTkcQJBI9CjlUUkFOU0ZFUl9PUkRF'
    'Ul9UWVBFX0xPQU5fRlVORElOR19FWFRFUk5BTF9MRU5ESU5HX1BBWUJBQ0sQJRIrCidUUkFOU0'
    'ZFUl9PUkRFUl9UWVBFX0lOVkVTVE9SX0RFUExPWU1FTlQQJhIxCi1UUkFOU0ZFUl9PUkRFUl9U'
    'WVBFX0lOVkVTVE9SX1BSSU5DSVBBTF9SRVRVUk4QJxI0CjBUUkFOU0ZFUl9PUkRFUl9UWVBFX0'
    'lOVkVTVE9SX0lOQ09NRV9ESVNUUklCVVRJT04QKBIcChhUUkFOU0ZFUl9PUkRFUl9UWVBFX0xP'
    'QU4QKRImCiJUUkFOU0ZFUl9PUkRFUl9UWVBFX0xPQU5fUkVQQVlNRU5UECoSLgoqVFJBTlNGRV'
    'JfT1JERVJfVFlQRV9TSFVURE9XTl9MT0FOX1JFQ09WRVJZECsSNgoyVFJBTlNGRVJfT1JERVJf'
    'VFlQRV9QTEFURk9STV9GSVJTVF9MT1NTX0FCU09SUFRJT04QLBIwCixUUkFOU0ZFUl9PUkRFUl'
    '9UWVBFX0lOVkVTVE9SX0xPU1NfQUJTT1JQVElPThAtEiUKIVRSQU5TRkVSX09SREVSX1RZUEVf'
    'TE9BTl9JTlRFUkVTVBAuEi8KK1RSQU5TRkVSX09SREVSX1RZUEVfTE9BTl9JTlRFUkVTVF9SRV'
    'BBWU1FTlQQLxI5CjVUUkFOU0ZFUl9PUkRFUl9UWVBFX0xPQU5fSU5URVJFU1RfSU5DT01FX0RJ'
    'U1RSSUJVVElPThAwEiYKIlRSQU5TRkVSX09SREVSX1RZUEVfTE9BTl9JTlNVUkFOQ0UQMxIwCi'
    'xUUkFOU0ZFUl9PUkRFUl9UWVBFX0xPQU5fSU5TVVJBTkNFX1JFUEFZTUVOVBA0EjIKLlRSQU5T'
    'RkVSX09SREVSX1RZUEVfSU5URVJfU1VCU0NSSVBUSU9OX1BBWU1FTlQQRw==');

@$core.Deprecated('Use operationsJobDescriptor instead')
const OperationsJob$json = {
  '1': 'OperationsJob',
  '2': [
    {'1': 'OPERATIONS_JOB_UNSPECIFIED', '2': 0},
    {'1': 'OPERATIONS_JOB_SETTLE_PAYMENTS', '2': 1},
  ],
};

/// Descriptor for `OperationsJob`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List operationsJobDescriptor = $convert.base64Decode(
    'Cg1PcGVyYXRpb25zSm9iEh4KGk9QRVJBVElPTlNfSk9CX1VOU1BFQ0lGSUVEEAASIgoeT1BFUk'
    'FUSU9OU19KT0JfU0VUVExFX1BBWU1FTlRTEAE=');

@$core.Deprecated('Use transferOrderObjectDescriptor instead')
const TransferOrderObject$json = {
  '1': 'TransferOrderObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'debit_account_ref', '3': 2, '4': 1, '5': 9, '10': 'debitAccountRef'},
    {
      '1': 'credit_account_ref',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'creditAccountRef'
    },
    {
      '1': 'amount',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
    {
      '1': 'order_type',
      '3': 6,
      '4': 1,
      '5': 5,
      '8': {'3': true},
      '10': 'orderType',
    },
    {'1': 'reference', '3': 7, '4': 1, '5': 9, '10': 'reference'},
    {'1': 'description', '3': 8, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'extra_data',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'extraData'
    },
    {
      '1': 'state',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.common.v1.STATE',
      '10': 'state'
    },
    {
      '1': 'transfer_type',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.operations.v1.TransferOrderType',
      '10': 'transferType'
    },
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
    'VudBIhCgpvcmRlcl90eXBlGAYgASgFQgIYAVIJb3JkZXJUeXBlEhwKCXJlZmVyZW5jZRgHIAEo'
    'CVIJcmVmZXJlbmNlEiAKC2Rlc2NyaXB0aW9uGAggASgJUgtkZXNjcmlwdGlvbhI2CgpleHRyYV'
    '9kYXRhGAkgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIJZXh0cmFEYXRhEiYKBXN0YXRl'
    'GAogASgOMhAuY29tbW9uLnYxLlNUQVRFUgVzdGF0ZRJFCg10cmFuc2Zlcl90eXBlGAsgASgOMi'
    'Aub3BlcmF0aW9ucy52MS5UcmFuc2Zlck9yZGVyVHlwZVIMdHJhbnNmZXJUeXBlSgQIBRAG');

@$core.Deprecated('Use transferOrderExecuteRequestDescriptor instead')
const TransferOrderExecuteRequest$json = {
  '1': 'TransferOrderExecuteRequest',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.operations.v1.TransferOrderObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `TransferOrderExecuteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOrderExecuteRequestDescriptor =
    $convert.base64Decode(
        'ChtUcmFuc2Zlck9yZGVyRXhlY3V0ZVJlcXVlc3QSNgoEZGF0YRgBIAEoCzIiLm9wZXJhdGlvbn'
        'MudjEuVHJhbnNmZXJPcmRlck9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use transferOrderExecuteResponseDescriptor instead')
const TransferOrderExecuteResponse$json = {
  '1': 'TransferOrderExecuteResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.operations.v1.TransferOrderObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `TransferOrderExecuteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOrderExecuteResponseDescriptor =
    $convert.base64Decode(
        'ChxUcmFuc2Zlck9yZGVyRXhlY3V0ZVJlc3BvbnNlEjYKBGRhdGEYASABKAsyIi5vcGVyYXRpb2'
        '5zLnYxLlRyYW5zZmVyT3JkZXJPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use transferOrderSearchRequestDescriptor instead')
const TransferOrderSearchRequest$json = {
  '1': 'TransferOrderSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {
      '1': 'order_type',
      '3': 2,
      '4': 1,
      '5': 5,
      '8': {'3': true},
      '10': 'orderType',
    },
    {
      '1': 'cursor',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.v1.PageCursor',
      '10': 'cursor'
    },
    {
      '1': 'transfer_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.operations.v1.TransferOrderType',
      '10': 'transferType'
    },
  ],
};

/// Descriptor for `TransferOrderSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOrderSearchRequestDescriptor = $convert.base64Decode(
    'ChpUcmFuc2Zlck9yZGVyU2VhcmNoUmVxdWVzdBIUCgVxdWVyeRgBIAEoCVIFcXVlcnkSIQoKb3'
    'JkZXJfdHlwZRgCIAEoBUICGAFSCW9yZGVyVHlwZRItCgZjdXJzb3IYAyABKAsyFS5jb21tb24u'
    'djEuUGFnZUN1cnNvclIGY3Vyc29yEkUKDXRyYW5zZmVyX3R5cGUYBCABKA4yIC5vcGVyYXRpb2'
    '5zLnYxLlRyYW5zZmVyT3JkZXJUeXBlUgx0cmFuc2ZlclR5cGU=');

@$core.Deprecated('Use transferOrderSearchResponseDescriptor instead')
const TransferOrderSearchResponse$json = {
  '1': 'TransferOrderSearchResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.operations.v1.TransferOrderObject',
      '10': 'data'
    },
    {'1': 'next_cursor', '3': 2, '4': 1, '5': 9, '10': 'nextCursor'},
  ],
};

/// Descriptor for `TransferOrderSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOrderSearchResponseDescriptor =
    $convert.base64Decode(
        'ChtUcmFuc2Zlck9yZGVyU2VhcmNoUmVzcG9uc2USNgoEZGF0YRgBIAMoCzIiLm9wZXJhdGlvbn'
        'MudjEuVHJhbnNmZXJPcmRlck9iamVjdFIEZGF0YRIfCgtuZXh0X2N1cnNvchgCIAEoCVIKbmV4'
        'dEN1cnNvcg==');

@$core.Deprecated('Use incomingPaymentNotifyRequestDescriptor instead')
const IncomingPaymentNotifyRequest$json = {
  '1': 'IncomingPaymentNotifyRequest',
  '2': [
    {'1': 'transaction_id', '3': 1, '4': 1, '5': 9, '10': 'transactionId'},
    {
      '1': 'amount',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
    {'1': 'payer_reference', '3': 3, '4': 1, '5': 9, '10': 'payerReference'},
    {'1': 'payer_name', '3': 4, '4': 1, '5': 9, '10': 'payerName'},
    {'1': 'product_id', '3': 5, '4': 1, '5': 9, '10': 'productId'},
    {'1': 'group_id', '3': 6, '4': 1, '5': 9, '10': 'groupId'},
    {
      '1': 'properties',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'properties'
    },
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
    {
      '1': 'result',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'result'
    },
  ],
};

/// Descriptor for `IncomingPaymentNotifyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List incomingPaymentNotifyResponseDescriptor =
    $convert.base64Decode(
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
final $typed_data.Uint8List paymentAllocateRequestDescriptor =
    $convert.base64Decode(
        'ChZQYXltZW50QWxsb2NhdGVSZXF1ZXN0Eh0KCnBheW1lbnRfaWQYASABKAlSCXBheW1lbnRJZA'
        '==');

@$core.Deprecated('Use paymentAllocateResponseDescriptor instead')
const PaymentAllocateResponse$json = {
  '1': 'PaymentAllocateResponse',
  '2': [
    {
      '1': 'result',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'result'
    },
  ],
};

/// Descriptor for `PaymentAllocateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paymentAllocateResponseDescriptor =
    $convert.base64Decode(
        'ChdQYXltZW50QWxsb2NhdGVSZXNwb25zZRIvCgZyZXN1bHQYASABKAsyFy5nb29nbGUucHJvdG'
        '9idWYuU3RydWN0UgZyZXN1bHQ=');

@$core.Deprecated('Use incomingPaymentObjectDescriptor instead')
const IncomingPaymentObject$json = {
  '1': 'IncomingPaymentObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'transaction_id', '3': 2, '4': 1, '5': 9, '10': 'transactionId'},
    {
      '1': 'amount',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
    {'1': 'payer_name', '3': 4, '4': 1, '5': 9, '10': 'payerName'},
    {'1': 'reference', '3': 5, '4': 1, '5': 9, '10': 'reference'},
    {'1': 'product_id', '3': 6, '4': 1, '5': 9, '10': 'productId'},
    {'1': 'matched', '3': 7, '4': 1, '5': 8, '10': 'matched'},
    {'1': 'client_id', '3': 8, '4': 1, '5': 9, '10': 'clientId'},
    {'1': 'loan_account_id', '3': 9, '4': 1, '5': 9, '10': 'loanAccountId'},
    {
      '1': 'identification_strategy',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'identificationStrategy'
    },
    {
      '1': 'unallocated',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'unallocated'
    },
    {
      '1': 'state',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.common.v1.STATE',
      '10': 'state'
    },
    {
      '1': 'received_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'receivedAt'
    },
    {'1': 'assigned_by', '3': 14, '4': 1, '5': 9, '10': 'assignedBy'},
    {'1': 'assignment_note', '3': 15, '4': 1, '5': 9, '10': 'assignmentNote'},
    {
      '1': 'savings_account_id',
      '3': 16,
      '4': 1,
      '5': 9,
      '10': 'savingsAccountId'
    },
  ],
};

/// Descriptor for `IncomingPaymentObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List incomingPaymentObjectDescriptor = $convert.base64Decode(
    'ChVJbmNvbWluZ1BheW1lbnRPYmplY3QSDgoCaWQYASABKAlSAmlkEiUKDnRyYW5zYWN0aW9uX2'
    'lkGAIgASgJUg10cmFuc2FjdGlvbklkEigKBmFtb3VudBgDIAEoCzIQLmNvbW1vbi52MS5Nb25l'
    'eVIGYW1vdW50Eh0KCnBheWVyX25hbWUYBCABKAlSCXBheWVyTmFtZRIcCglyZWZlcmVuY2UYBS'
    'ABKAlSCXJlZmVyZW5jZRIdCgpwcm9kdWN0X2lkGAYgASgJUglwcm9kdWN0SWQSGAoHbWF0Y2hl'
    'ZBgHIAEoCFIHbWF0Y2hlZBIbCgljbGllbnRfaWQYCCABKAlSCGNsaWVudElkEiYKD2xvYW5fYW'
    'Njb3VudF9pZBgJIAEoCVINbG9hbkFjY291bnRJZBI3ChdpZGVudGlmaWNhdGlvbl9zdHJhdGVn'
    'eRgKIAEoCVIWaWRlbnRpZmljYXRpb25TdHJhdGVneRIyCgt1bmFsbG9jYXRlZBgLIAEoCzIQLm'
    'NvbW1vbi52MS5Nb25leVILdW5hbGxvY2F0ZWQSJgoFc3RhdGUYDCABKA4yEC5jb21tb24udjEu'
    'U1RBVEVSBXN0YXRlEjsKC3JlY2VpdmVkX2F0GA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbW'
    'VzdGFtcFIKcmVjZWl2ZWRBdBIfCgthc3NpZ25lZF9ieRgOIAEoCVIKYXNzaWduZWRCeRInCg9h'
    'c3NpZ25tZW50X25vdGUYDyABKAlSDmFzc2lnbm1lbnROb3RlEiwKEnNhdmluZ3NfYWNjb3VudF'
    '9pZBgQIAEoCVIQc2F2aW5nc0FjY291bnRJZA==');

@$core.Deprecated('Use incomingPaymentSearchRequestDescriptor instead')
const IncomingPaymentSearchRequest$json = {
  '1': 'IncomingPaymentSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'unmatched_only', '3': 2, '4': 1, '5': 8, '10': 'unmatchedOnly'},
    {'1': 'product_id', '3': 3, '4': 1, '5': 9, '10': 'productId'},
    {
      '1': 'cursor',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.PageCursor',
      '10': 'cursor'
    },
  ],
};

/// Descriptor for `IncomingPaymentSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List incomingPaymentSearchRequestDescriptor = $convert.base64Decode(
    'ChxJbmNvbWluZ1BheW1lbnRTZWFyY2hSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeRIlCg'
    '51bm1hdGNoZWRfb25seRgCIAEoCFINdW5tYXRjaGVkT25seRIdCgpwcm9kdWN0X2lkGAMgASgJ'
    'Uglwcm9kdWN0SWQSLQoGY3Vyc29yGAQgASgLMhUuY29tbW9uLnYxLlBhZ2VDdXJzb3JSBmN1cn'
    'Nvcg==');

@$core.Deprecated('Use incomingPaymentSearchResponseDescriptor instead')
const IncomingPaymentSearchResponse$json = {
  '1': 'IncomingPaymentSearchResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.operations.v1.IncomingPaymentObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `IncomingPaymentSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List incomingPaymentSearchResponseDescriptor =
    $convert.base64Decode(
        'Ch1JbmNvbWluZ1BheW1lbnRTZWFyY2hSZXNwb25zZRI4CgRkYXRhGAEgAygLMiQub3BlcmF0aW'
        '9ucy52MS5JbmNvbWluZ1BheW1lbnRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use incomingPaymentAssignRequestDescriptor instead')
const IncomingPaymentAssignRequest$json = {
  '1': 'IncomingPaymentAssignRequest',
  '2': [
    {'1': 'payment_id', '3': 1, '4': 1, '5': 9, '10': 'paymentId'},
    {'1': 'loan_account_id', '3': 2, '4': 1, '5': 9, '10': 'loanAccountId'},
    {'1': 'note', '3': 3, '4': 1, '5': 9, '10': 'note'},
    {
      '1': 'savings_account_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'savingsAccountId'
    },
  ],
};

/// Descriptor for `IncomingPaymentAssignRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List incomingPaymentAssignRequestDescriptor = $convert.base64Decode(
    'ChxJbmNvbWluZ1BheW1lbnRBc3NpZ25SZXF1ZXN0Eh0KCnBheW1lbnRfaWQYASABKAlSCXBheW'
    '1lbnRJZBImCg9sb2FuX2FjY291bnRfaWQYAiABKAlSDWxvYW5BY2NvdW50SWQSEgoEbm90ZRgD'
    'IAEoCVIEbm90ZRIsChJzYXZpbmdzX2FjY291bnRfaWQYBCABKAlSEHNhdmluZ3NBY2NvdW50SW'
    'Q=');

@$core.Deprecated('Use incomingPaymentAssignResponseDescriptor instead')
const IncomingPaymentAssignResponse$json = {
  '1': 'IncomingPaymentAssignResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.operations.v1.IncomingPaymentObject',
      '10': 'data'
    },
    {
      '1': 'allocation',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'allocation'
    },
  ],
};

/// Descriptor for `IncomingPaymentAssignResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List incomingPaymentAssignResponseDescriptor =
    $convert.base64Decode(
        'Ch1JbmNvbWluZ1BheW1lbnRBc3NpZ25SZXNwb25zZRI4CgRkYXRhGAEgASgLMiQub3BlcmF0aW'
        '9ucy52MS5JbmNvbWluZ1BheW1lbnRPYmplY3RSBGRhdGESNwoKYWxsb2NhdGlvbhgCIAEoCzIX'
        'Lmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSCmFsbG9jYXRpb24=');

@$core.Deprecated('Use operationsJobRunRequestDescriptor instead')
const OperationsJobRunRequest$json = {
  '1': 'OperationsJobRunRequest',
  '2': [
    {
      '1': 'job',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.operations.v1.OperationsJob',
      '10': 'job'
    },
    {'1': 'batch_size', '3': 2, '4': 1, '5': 5, '10': 'batchSize'},
  ],
};

/// Descriptor for `OperationsJobRunRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List operationsJobRunRequestDescriptor =
    $convert.base64Decode(
        'ChdPcGVyYXRpb25zSm9iUnVuUmVxdWVzdBIuCgNqb2IYASABKA4yHC5vcGVyYXRpb25zLnYxLk'
        '9wZXJhdGlvbnNKb2JSA2pvYhIdCgpiYXRjaF9zaXplGAIgASgFUgliYXRjaFNpemU=');

@$core.Deprecated('Use operationsJobRunResponseDescriptor instead')
const OperationsJobRunResponse$json = {
  '1': 'OperationsJobRunResponse',
  '2': [
    {'1': 'processed', '3': 1, '4': 1, '5': 5, '10': 'processed'},
    {'1': 'more', '3': 2, '4': 1, '5': 8, '10': 'more'},
  ],
};

/// Descriptor for `OperationsJobRunResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List operationsJobRunResponseDescriptor =
    $convert.base64Decode(
        'ChhPcGVyYXRpb25zSm9iUnVuUmVzcG9uc2USHAoJcHJvY2Vzc2VkGAEgASgFUglwcm9jZXNzZW'
        'QSEgoEbW9yZRgCIAEoCFIEbW9yZQ==');

const $core.Map<$core.String, $core.dynamic> OperationsServiceBase$json = {
  '1': 'OperationsService',
  '2': [
    {
      '1': 'TransferOrderExecute',
      '2': '.operations.v1.TransferOrderExecuteRequest',
      '3': '.operations.v1.TransferOrderExecuteResponse',
      '4': {}
    },
    {
      '1': 'TransferOrderSearch',
      '2': '.operations.v1.TransferOrderSearchRequest',
      '3': '.operations.v1.TransferOrderSearchResponse',
      '4': {},
      '6': true
    },
    {
      '1': 'IncomingPaymentNotify',
      '2': '.operations.v1.IncomingPaymentNotifyRequest',
      '3': '.operations.v1.IncomingPaymentNotifyResponse',
      '4': {}
    },
    {
      '1': 'PaymentAllocate',
      '2': '.operations.v1.PaymentAllocateRequest',
      '3': '.operations.v1.PaymentAllocateResponse',
      '4': {}
    },
    {
      '1': 'IncomingPaymentSearch',
      '2': '.operations.v1.IncomingPaymentSearchRequest',
      '3': '.operations.v1.IncomingPaymentSearchResponse',
      '4': {},
      '6': true
    },
    {
      '1': 'IncomingPaymentAssign',
      '2': '.operations.v1.IncomingPaymentAssignRequest',
      '3': '.operations.v1.IncomingPaymentAssignResponse',
      '4': {}
    },
    {
      '1': 'OperationsJobRun',
      '2': '.operations.v1.OperationsJobRunRequest',
      '3': '.operations.v1.OperationsJobRunResponse',
      '4': {}
    },
  ],
  '3': {},
};

@$core.Deprecated('Use operationsServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    OperationsServiceBase$messageJson = {
  '.operations.v1.TransferOrderExecuteRequest':
      TransferOrderExecuteRequest$json,
  '.operations.v1.TransferOrderObject': TransferOrderObject$json,
  '.common.v1.Money': $0.Money$json,
  '.google.protobuf.Struct': $1.Struct$json,
  '.google.protobuf.Struct.FieldsEntry': $1.Struct_FieldsEntry$json,
  '.google.protobuf.Value': $1.Value$json,
  '.google.protobuf.ListValue': $1.ListValue$json,
  '.operations.v1.TransferOrderExecuteResponse':
      TransferOrderExecuteResponse$json,
  '.operations.v1.TransferOrderSearchRequest': TransferOrderSearchRequest$json,
  '.common.v1.PageCursor': $2.PageCursor$json,
  '.operations.v1.TransferOrderSearchResponse':
      TransferOrderSearchResponse$json,
  '.operations.v1.IncomingPaymentNotifyRequest':
      IncomingPaymentNotifyRequest$json,
  '.operations.v1.IncomingPaymentNotifyResponse':
      IncomingPaymentNotifyResponse$json,
  '.operations.v1.PaymentAllocateRequest': PaymentAllocateRequest$json,
  '.operations.v1.PaymentAllocateResponse': PaymentAllocateResponse$json,
  '.operations.v1.IncomingPaymentSearchRequest':
      IncomingPaymentSearchRequest$json,
  '.operations.v1.IncomingPaymentSearchResponse':
      IncomingPaymentSearchResponse$json,
  '.operations.v1.IncomingPaymentObject': IncomingPaymentObject$json,
  '.google.protobuf.Timestamp': $3.Timestamp$json,
  '.operations.v1.IncomingPaymentAssignRequest':
      IncomingPaymentAssignRequest$json,
  '.operations.v1.IncomingPaymentAssignResponse':
      IncomingPaymentAssignResponse$json,
  '.operations.v1.OperationsJobRunRequest': OperationsJobRunRequest$json,
  '.operations.v1.OperationsJobRunResponse': OperationsJobRunResponse$json,
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
    '5zLnYxLlBheW1lbnRBbGxvY2F0ZVJlc3BvbnNlIhaCtRgSChBwYXltZW50X2FsbG9jYXRlEogB'
    'ChVJbmNvbWluZ1BheW1lbnRTZWFyY2gSKy5vcGVyYXRpb25zLnYxLkluY29taW5nUGF5bWVudF'
    'NlYXJjaFJlcXVlc3QaLC5vcGVyYXRpb25zLnYxLkluY29taW5nUGF5bWVudFNlYXJjaFJlc3Bv'
    'bnNlIhKCtRgOCgxwYXltZW50X3ZpZXcwARKKAQoVSW5jb21pbmdQYXltZW50QXNzaWduEisub3'
    'BlcmF0aW9ucy52MS5JbmNvbWluZ1BheW1lbnRBc3NpZ25SZXF1ZXN0Giwub3BlcmF0aW9ucy52'
    'MS5JbmNvbWluZ1BheW1lbnRBc3NpZ25SZXNwb25zZSIWgrUYEgoQcGF5bWVudF9hbGxvY2F0ZR'
    'J9ChBPcGVyYXRpb25zSm9iUnVuEiYub3BlcmF0aW9ucy52MS5PcGVyYXRpb25zSm9iUnVuUmVx'
    'dWVzdBonLm9wZXJhdGlvbnMudjEuT3BlcmF0aW9uc0pvYlJ1blJlc3BvbnNlIhiCtRgUChJvcG'
    'VyYXRpb25zX2pvYl9ydW4amgSCtRiVBAoSc2VydmljZV9vcGVyYXRpb25zEhB0cmFuc2Zlcl9l'
    'eGVjdXRlEg10cmFuc2Zlcl92aWV3Eg5wYXltZW50X25vdGlmeRIQcGF5bWVudF9hbGxvY2F0ZR'
    'IMcGF5bWVudF92aWV3EhJvcGVyYXRpb25zX2pvYl9ydW4aUwgBEhB0cmFuc2Zlcl9leGVjdXRl'
    'Eg10cmFuc2Zlcl92aWV3Eg5wYXltZW50X25vdGlmeRIQcGF5bWVudF9hbGxvY2F0ZRIMcGF5bW'
    'VudF92aWV3GlMIAhIQdHJhbnNmZXJfZXhlY3V0ZRINdHJhbnNmZXJfdmlldxIOcGF5bWVudF9u'
    'b3RpZnkSEHBheW1lbnRfYWxsb2NhdGUSDHBheW1lbnRfdmlldxpTCAMSEHRyYW5zZmVyX2V4ZW'
    'N1dGUSDXRyYW5zZmVyX3ZpZXcSDnBheW1lbnRfbm90aWZ5EhBwYXltZW50X2FsbG9jYXRlEgxw'
    'YXltZW50X3ZpZXcaHwgEEg10cmFuc2Zlcl92aWV3EgxwYXltZW50X3ZpZXcaEQgFEg10cmFuc2'
    'Zlcl92aWV3GmcIBhIQdHJhbnNmZXJfZXhlY3V0ZRINdHJhbnNmZXJfdmlldxIOcGF5bWVudF9u'
    'b3RpZnkSEHBheW1lbnRfYWxsb2NhdGUSDHBheW1lbnRfdmlldxISb3BlcmF0aW9uc19qb2Jfcn'
    'Vu');
