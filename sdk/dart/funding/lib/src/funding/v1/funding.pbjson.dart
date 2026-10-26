// This is a generated file - do not edit.
//
// Generated from funding/v1/funding.proto.

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

import '../../common/v1/common.pbjson.dart' as $2;
import '../../common/v1/money.pbjson.dart' as $0;

@$core.Deprecated('Use investorStatementEntryTypeDescriptor instead')
const InvestorStatementEntryType$json = {
  '1': 'InvestorStatementEntryType',
  '2': [
    {'1': 'INVESTOR_STATEMENT_ENTRY_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'INVESTOR_STATEMENT_ENTRY_TYPE_DEPOSIT', '2': 1},
    {'1': 'INVESTOR_STATEMENT_ENTRY_TYPE_WITHDRAWAL', '2': 2},
    {'1': 'INVESTOR_STATEMENT_ENTRY_TYPE_DEPLOYMENT', '2': 3},
    {'1': 'INVESTOR_STATEMENT_ENTRY_TYPE_RELEASE', '2': 4},
    {'1': 'INVESTOR_STATEMENT_ENTRY_TYPE_PRINCIPAL_RETURNED', '2': 5},
    {'1': 'INVESTOR_STATEMENT_ENTRY_TYPE_INTEREST_EARNED', '2': 6},
    {'1': 'INVESTOR_STATEMENT_ENTRY_TYPE_LOSS', '2': 7},
    {'1': 'INVESTOR_STATEMENT_ENTRY_TYPE_RECOVERY', '2': 8},
  ],
};

/// Descriptor for `InvestorStatementEntryType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List investorStatementEntryTypeDescriptor = $convert.base64Decode(
    'ChpJbnZlc3RvclN0YXRlbWVudEVudHJ5VHlwZRItCilJTlZFU1RPUl9TVEFURU1FTlRfRU5UUl'
    'lfVFlQRV9VTlNQRUNJRklFRBAAEikKJUlOVkVTVE9SX1NUQVRFTUVOVF9FTlRSWV9UWVBFX0RF'
    'UE9TSVQQARIsCihJTlZFU1RPUl9TVEFURU1FTlRfRU5UUllfVFlQRV9XSVRIRFJBV0FMEAISLA'
    'ooSU5WRVNUT1JfU1RBVEVNRU5UX0VOVFJZX1RZUEVfREVQTE9ZTUVOVBADEikKJUlOVkVTVE9S'
    'X1NUQVRFTUVOVF9FTlRSWV9UWVBFX1JFTEVBU0UQBBI0CjBJTlZFU1RPUl9TVEFURU1FTlRfRU'
    '5UUllfVFlQRV9QUklOQ0lQQUxfUkVUVVJORUQQBRIxCi1JTlZFU1RPUl9TVEFURU1FTlRfRU5U'
    'UllfVFlQRV9JTlRFUkVTVF9FQVJORUQQBhImCiJJTlZFU1RPUl9TVEFURU1FTlRfRU5UUllfVF'
    'lQRV9MT1NTEAcSKgomSU5WRVNUT1JfU1RBVEVNRU5UX0VOVFJZX1RZUEVfUkVDT1ZFUlkQCA==');

@$core.Deprecated('Use investorAccountObjectDescriptor instead')
const InvestorAccountObject$json = {
  '1': 'InvestorAccountObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'investor_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'investorId'},
    {'1': 'account_name', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'accountName'},
    {
      '1': 'available_balance',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'availableBalance'
    },
    {
      '1': 'reserved_balance',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'reservedBalance'
    },
    {
      '1': 'total_deployed',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'totalDeployed'
    },
    {
      '1': 'total_returned',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'totalReturned'
    },
    {
      '1': 'max_exposure',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'maxExposure'
    },
    {
      '1': 'min_interest_rate',
      '3': 10,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'minInterestRate'
    },
    {
      '1': 'allowed_products',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'allowedProducts'
    },
    {
      '1': 'allowed_regions',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'allowedRegions'
    },
    {
      '1': 'group_affiliations',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'groupAffiliations'
    },
    {
      '1': 'state',
      '3': 14,
      '4': 1,
      '5': 14,
      '6': '.common.v1.STATE',
      '10': 'state'
    },
    {
      '1': 'properties',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'properties'
    },
    {
      '1': 'currency_code',
      '3': 16,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'currencyCode'
    },
  ],
  '9': [
    {'1': 4, '2': 5},
  ],
};

/// Descriptor for `InvestorAccountObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountObjectDescriptor = $convert.base64Decode(
    'ChVJbnZlc3RvckFjY291bnRPYmplY3QSHAoCaWQYASABKAlCDLpICdgBAXIEEAMYKFICaWQSKg'
    'oLaW52ZXN0b3JfaWQYAiABKAlCCbpIBnIEEAMYKFIKaW52ZXN0b3JJZBIrCgxhY2NvdW50X25h'
    'bWUYAyABKAlCCLpIBXIDGMgBUgthY2NvdW50TmFtZRI9ChFhdmFpbGFibGVfYmFsYW5jZRgFIA'
    'EoCzIQLmNvbW1vbi52MS5Nb25leVIQYXZhaWxhYmxlQmFsYW5jZRI7ChByZXNlcnZlZF9iYWxh'
    'bmNlGAYgASgLMhAuY29tbW9uLnYxLk1vbmV5Ug9yZXNlcnZlZEJhbGFuY2USNwoOdG90YWxfZG'
    'VwbG95ZWQYByABKAsyEC5jb21tb24udjEuTW9uZXlSDXRvdGFsRGVwbG95ZWQSNwoOdG90YWxf'
    'cmV0dXJuZWQYCCABKAsyEC5jb21tb24udjEuTW9uZXlSDXRvdGFsUmV0dXJuZWQSMwoMbWF4X2'
    'V4cG9zdXJlGAkgASgLMhAuY29tbW9uLnYxLk1vbmV5UgttYXhFeHBvc3VyZRJJChFtaW5faW50'
    'ZXJlc3RfcmF0ZRgKIAEoCUIdukga2AEBchUyE15bMC05XSsoXC5bMC05XSspPyRSD21pbkludG'
    'VyZXN0UmF0ZRJCChBhbGxvd2VkX3Byb2R1Y3RzGAsgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0'
    'cnVjdFIPYWxsb3dlZFByb2R1Y3RzEkAKD2FsbG93ZWRfcmVnaW9ucxgMIAEoCzIXLmdvb2dsZS'
    '5wcm90b2J1Zi5TdHJ1Y3RSDmFsbG93ZWRSZWdpb25zEkYKEmdyb3VwX2FmZmlsaWF0aW9ucxgN'
    'IAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSEWdyb3VwQWZmaWxpYXRpb25zEiYKBXN0YX'
    'RlGA4gASgOMhAuY29tbW9uLnYxLlNUQVRFUgVzdGF0ZRI3Cgpwcm9wZXJ0aWVzGA8gASgLMhcu'
    'Z29vZ2xlLnByb3RvYnVmLlN0cnVjdFIKcHJvcGVydGllcxIwCg1jdXJyZW5jeV9jb2RlGBAgAS'
    'gJQgu6SAjYAQFyA5gBA1IMY3VycmVuY3lDb2RlSgQIBBAF');

@$core.Deprecated('Use fundingAllocationObjectDescriptor instead')
const FundingAllocationObject$json = {
  '1': 'FundingAllocationObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'loan_request_id', '3': 2, '4': 1, '5': 9, '10': 'loanRequestId'},
    {'1': 'source_id', '3': 3, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'source_type', '3': 4, '4': 1, '5': 9, '10': 'sourceType'},
    {'1': 'tranche_level', '3': 5, '4': 1, '5': 5, '10': 'trancheLevel'},
    {
      '1': 'amount',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
    {'1': 'proportion', '3': 8, '4': 1, '5': 9, '10': 'proportion'},
    {
      '1': 'properties',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'properties'
    },
  ],
  '9': [
    {'1': 7, '2': 8},
  ],
};

/// Descriptor for `FundingAllocationObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fundingAllocationObjectDescriptor = $convert.base64Decode(
    'ChdGdW5kaW5nQWxsb2NhdGlvbk9iamVjdBIOCgJpZBgBIAEoCVICaWQSJgoPbG9hbl9yZXF1ZX'
    'N0X2lkGAIgASgJUg1sb2FuUmVxdWVzdElkEhsKCXNvdXJjZV9pZBgDIAEoCVIIc291cmNlSWQS'
    'HwoLc291cmNlX3R5cGUYBCABKAlSCnNvdXJjZVR5cGUSIwoNdHJhbmNoZV9sZXZlbBgFIAEoBV'
    'IMdHJhbmNoZUxldmVsEigKBmFtb3VudBgGIAEoCzIQLmNvbW1vbi52MS5Nb25leVIGYW1vdW50'
    'Eh4KCnByb3BvcnRpb24YCCABKAlSCnByb3BvcnRpb24SNwoKcHJvcGVydGllcxgJIAEoCzIXLm'
    'dvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSCnByb3BlcnRpZXNKBAgHEAg=');

@$core.Deprecated('Use investorAccountSaveRequestDescriptor instead')
const InvestorAccountSaveRequest$json = {
  '1': 'InvestorAccountSaveRequest',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.funding.v1.InvestorAccountObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `InvestorAccountSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSaveRequestDescriptor =
    $convert.base64Decode(
        'ChpJbnZlc3RvckFjY291bnRTYXZlUmVxdWVzdBI1CgRkYXRhGAEgASgLMiEuZnVuZGluZy52MS'
        '5JbnZlc3RvckFjY291bnRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use investorAccountSaveResponseDescriptor instead')
const InvestorAccountSaveResponse$json = {
  '1': 'InvestorAccountSaveResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.funding.v1.InvestorAccountObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `InvestorAccountSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSaveResponseDescriptor =
    $convert.base64Decode(
        'ChtJbnZlc3RvckFjY291bnRTYXZlUmVzcG9uc2USNQoEZGF0YRgBIAEoCzIhLmZ1bmRpbmcudj'
        'EuSW52ZXN0b3JBY2NvdW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use investorAccountGetRequestDescriptor instead')
const InvestorAccountGetRequest$json = {
  '1': 'InvestorAccountGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `InvestorAccountGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountGetRequestDescriptor =
    $convert.base64Decode(
        'ChlJbnZlc3RvckFjY291bnRHZXRSZXF1ZXN0EhkKAmlkGAEgASgJQgm6SAZyBBADGChSAmlk');

@$core.Deprecated('Use investorAccountGetResponseDescriptor instead')
const InvestorAccountGetResponse$json = {
  '1': 'InvestorAccountGetResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.funding.v1.InvestorAccountObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `InvestorAccountGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountGetResponseDescriptor =
    $convert.base64Decode(
        'ChpJbnZlc3RvckFjY291bnRHZXRSZXNwb25zZRI1CgRkYXRhGAEgASgLMiEuZnVuZGluZy52MS'
        '5JbnZlc3RvckFjY291bnRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use investorStatementEntryDescriptor instead')
const InvestorStatementEntry$json = {
  '1': 'InvestorStatementEntry',
  '2': [
    {'1': 'occurred_at', '3': 1, '4': 1, '5': 9, '10': 'occurredAt'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.funding.v1.InvestorStatementEntryType',
      '10': 'type'
    },
    {
      '1': 'amount',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
    {'1': 'loan_request_id', '3': 4, '4': 1, '5': 9, '10': 'loanRequestId'},
    {
      '1': 'interest_gross',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'interestGross'
    },
    {
      '1': 'platform_fee',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'platformFee'
    },
    {
      '1': 'withholding_tax',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'withholdingTax'
    },
    {'1': 'pending', '3': 8, '4': 1, '5': 8, '10': 'pending'},
    {'1': 'reference', '3': 9, '4': 1, '5': 9, '10': 'reference'},
  ],
};

/// Descriptor for `InvestorStatementEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorStatementEntryDescriptor = $convert.base64Decode(
    'ChZJbnZlc3RvclN0YXRlbWVudEVudHJ5Eh8KC29jY3VycmVkX2F0GAEgASgJUgpvY2N1cnJlZE'
    'F0EjoKBHR5cGUYAiABKA4yJi5mdW5kaW5nLnYxLkludmVzdG9yU3RhdGVtZW50RW50cnlUeXBl'
    'UgR0eXBlEigKBmFtb3VudBgDIAEoCzIQLmNvbW1vbi52MS5Nb25leVIGYW1vdW50EiYKD2xvYW'
    '5fcmVxdWVzdF9pZBgEIAEoCVINbG9hblJlcXVlc3RJZBI3Cg5pbnRlcmVzdF9ncm9zcxgFIAEo'
    'CzIQLmNvbW1vbi52MS5Nb25leVINaW50ZXJlc3RHcm9zcxIzCgxwbGF0Zm9ybV9mZWUYBiABKA'
    'syEC5jb21tb24udjEuTW9uZXlSC3BsYXRmb3JtRmVlEjkKD3dpdGhob2xkaW5nX3RheBgHIAEo'
    'CzIQLmNvbW1vbi52MS5Nb25leVIOd2l0aGhvbGRpbmdUYXgSGAoHcGVuZGluZxgIIAEoCFIHcG'
    'VuZGluZxIcCglyZWZlcmVuY2UYCSABKAlSCXJlZmVyZW5jZQ==');

@$core.Deprecated('Use investorStatementTotalsDescriptor instead')
const InvestorStatementTotals$json = {
  '1': 'InvestorStatementTotals',
  '2': [
    {
      '1': 'deposits',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'deposits'
    },
    {
      '1': 'withdrawals',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'withdrawals'
    },
    {
      '1': 'deployed',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'deployed'
    },
    {
      '1': 'released',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'released'
    },
    {
      '1': 'principal_returned',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'principalReturned'
    },
    {
      '1': 'interest_earned',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'interestEarned'
    },
    {
      '1': 'platform_fees',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'platformFees'
    },
    {
      '1': 'withholding_tax',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'withholdingTax'
    },
    {
      '1': 'losses',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'losses'
    },
    {
      '1': 'recoveries',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'recoveries'
    },
  ],
};

/// Descriptor for `InvestorStatementTotals`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorStatementTotalsDescriptor = $convert.base64Decode(
    'ChdJbnZlc3RvclN0YXRlbWVudFRvdGFscxIsCghkZXBvc2l0cxgBIAEoCzIQLmNvbW1vbi52MS'
    '5Nb25leVIIZGVwb3NpdHMSMgoLd2l0aGRyYXdhbHMYAiABKAsyEC5jb21tb24udjEuTW9uZXlS'
    'C3dpdGhkcmF3YWxzEiwKCGRlcGxveWVkGAMgASgLMhAuY29tbW9uLnYxLk1vbmV5UghkZXBsb3'
    'llZBIsCghyZWxlYXNlZBgEIAEoCzIQLmNvbW1vbi52MS5Nb25leVIIcmVsZWFzZWQSPwoScHJp'
    'bmNpcGFsX3JldHVybmVkGAUgASgLMhAuY29tbW9uLnYxLk1vbmV5UhFwcmluY2lwYWxSZXR1cm'
    '5lZBI5Cg9pbnRlcmVzdF9lYXJuZWQYBiABKAsyEC5jb21tb24udjEuTW9uZXlSDmludGVyZXN0'
    'RWFybmVkEjUKDXBsYXRmb3JtX2ZlZXMYByABKAsyEC5jb21tb24udjEuTW9uZXlSDHBsYXRmb3'
    'JtRmVlcxI5Cg93aXRoaG9sZGluZ190YXgYCCABKAsyEC5jb21tb24udjEuTW9uZXlSDndpdGho'
    'b2xkaW5nVGF4EigKBmxvc3NlcxgJIAEoCzIQLmNvbW1vbi52MS5Nb25leVIGbG9zc2VzEjAKCn'
    'JlY292ZXJpZXMYCiABKAsyEC5jb21tb24udjEuTW9uZXlSCnJlY292ZXJpZXM=');

@$core.Deprecated('Use investorStatementRequestDescriptor instead')
const InvestorStatementRequest$json = {
  '1': 'InvestorStatementRequest',
  '2': [
    {
      '1': 'investor_account_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'investorAccountId'
    },
    {'1': 'from', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'from'},
    {'1': 'to', '3': 3, '4': 1, '5': 9, '10': 'to'},
  ],
};

/// Descriptor for `InvestorStatementRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorStatementRequestDescriptor = $convert.base64Decode(
    'ChhJbnZlc3RvclN0YXRlbWVudFJlcXVlc3QSOQoTaW52ZXN0b3JfYWNjb3VudF9pZBgBIAEoCU'
    'IJukgGcgQQAxgoUhFpbnZlc3RvckFjY291bnRJZBIbCgRmcm9tGAIgASgJQge6SARyAhABUgRm'
    'cm9tEg4KAnRvGAMgASgJUgJ0bw==');

@$core.Deprecated('Use investorStatementResponseDescriptor instead')
const InvestorStatementResponse$json = {
  '1': 'InvestorStatementResponse',
  '2': [
    {
      '1': 'account',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.funding.v1.InvestorAccountObject',
      '10': 'account'
    },
    {'1': 'from', '3': 2, '4': 1, '5': 9, '10': 'from'},
    {'1': 'to', '3': 3, '4': 1, '5': 9, '10': 'to'},
    {
      '1': 'entries',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.funding.v1.InvestorStatementEntry',
      '10': 'entries'
    },
    {
      '1': 'totals',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.funding.v1.InvestorStatementTotals',
      '10': 'totals'
    },
    {'1': 'truncated', '3': 6, '4': 1, '5': 8, '10': 'truncated'},
  ],
};

/// Descriptor for `InvestorStatementResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorStatementResponseDescriptor = $convert.base64Decode(
    'ChlJbnZlc3RvclN0YXRlbWVudFJlc3BvbnNlEjsKB2FjY291bnQYASABKAsyIS5mdW5kaW5nLn'
    'YxLkludmVzdG9yQWNjb3VudE9iamVjdFIHYWNjb3VudBISCgRmcm9tGAIgASgJUgRmcm9tEg4K'
    'AnRvGAMgASgJUgJ0bxI8CgdlbnRyaWVzGAQgAygLMiIuZnVuZGluZy52MS5JbnZlc3RvclN0YX'
    'RlbWVudEVudHJ5UgdlbnRyaWVzEjsKBnRvdGFscxgFIAEoCzIjLmZ1bmRpbmcudjEuSW52ZXN0'
    'b3JTdGF0ZW1lbnRUb3RhbHNSBnRvdGFscxIcCgl0cnVuY2F0ZWQYBiABKAhSCXRydW5jYXRlZA'
    '==');

@$core.Deprecated('Use investorAccountSearchRequestDescriptor instead')
const InvestorAccountSearchRequest$json = {
  '1': 'InvestorAccountSearchRequest',
  '2': [
    {'1': 'investor_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'investorId'},
    {
      '1': 'currency_code',
      '3': 2,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'currencyCode'
    },
    {
      '1': 'cursor',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.v1.PageCursor',
      '10': 'cursor'
    },
  ],
};

/// Descriptor for `InvestorAccountSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSearchRequestDescriptor = $convert.base64Decode(
    'ChxJbnZlc3RvckFjY291bnRTZWFyY2hSZXF1ZXN0Ei0KC2ludmVzdG9yX2lkGAEgASgJQgy6SA'
    'nYAQFyBBADGChSCmludmVzdG9ySWQSMAoNY3VycmVuY3lfY29kZRgCIAEoCUILukgI2AEBcgOY'
    'AQNSDGN1cnJlbmN5Q29kZRItCgZjdXJzb3IYAyABKAsyFS5jb21tb24udjEuUGFnZUN1cnNvcl'
    'IGY3Vyc29y');

@$core.Deprecated('Use investorAccountSearchResponseDescriptor instead')
const InvestorAccountSearchResponse$json = {
  '1': 'InvestorAccountSearchResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.funding.v1.InvestorAccountObject',
      '10': 'data'
    },
    {
      '1': 'next_cursor',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.PageCursor',
      '10': 'nextCursor'
    },
  ],
};

/// Descriptor for `InvestorAccountSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSearchResponseDescriptor =
    $convert.base64Decode(
        'Ch1JbnZlc3RvckFjY291bnRTZWFyY2hSZXNwb25zZRI1CgRkYXRhGAEgAygLMiEuZnVuZGluZy'
        '52MS5JbnZlc3RvckFjY291bnRPYmplY3RSBGRhdGESNgoLbmV4dF9jdXJzb3IYAiABKAsyFS5j'
        'b21tb24udjEuUGFnZUN1cnNvclIKbmV4dEN1cnNvcg==');

@$core.Deprecated('Use investorDepositRequestDescriptor instead')
const InvestorDepositRequest$json = {
  '1': 'InvestorDepositRequest',
  '2': [
    {'1': 'account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'accountId'},
    {
      '1': 'amount',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '8': {},
      '10': 'amount'
    },
    {
      '1': 'idempotency_key',
      '3': 4,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'idempotencyKey'
    },
  ],
  '9': [
    {'1': 3, '2': 4},
  ],
};

/// Descriptor for `InvestorDepositRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorDepositRequestDescriptor = $convert.base64Decode(
    'ChZJbnZlc3RvckRlcG9zaXRSZXF1ZXN0EigKCmFjY291bnRfaWQYASABKAlCCbpIBnIEEAMYKF'
    'IJYWNjb3VudElkEjAKBmFtb3VudBgCIAEoCzIQLmNvbW1vbi52MS5Nb25leUIGukgDyAEBUgZh'
    'bW91bnQSNgoPaWRlbXBvdGVuY3lfa2V5GAQgASgJQg26SArYAQFyBRAIGIABUg5pZGVtcG90ZW'
    '5jeUtleUoECAMQBA==');

@$core.Deprecated('Use investorDepositResponseDescriptor instead')
const InvestorDepositResponse$json = {
  '1': 'InvestorDepositResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.funding.v1.InvestorAccountObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `InvestorDepositResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorDepositResponseDescriptor =
    $convert.base64Decode(
        'ChdJbnZlc3RvckRlcG9zaXRSZXNwb25zZRI1CgRkYXRhGAEgASgLMiEuZnVuZGluZy52MS5Jbn'
        'Zlc3RvckFjY291bnRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use investorWithdrawRequestDescriptor instead')
const InvestorWithdrawRequest$json = {
  '1': 'InvestorWithdrawRequest',
  '2': [
    {'1': 'account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'accountId'},
    {
      '1': 'amount',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '8': {},
      '10': 'amount'
    },
    {
      '1': 'idempotency_key',
      '3': 3,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'idempotencyKey'
    },
  ],
};

/// Descriptor for `InvestorWithdrawRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorWithdrawRequestDescriptor = $convert.base64Decode(
    'ChdJbnZlc3RvcldpdGhkcmF3UmVxdWVzdBIoCgphY2NvdW50X2lkGAEgASgJQgm6SAZyBBADGC'
    'hSCWFjY291bnRJZBIwCgZhbW91bnQYAiABKAsyEC5jb21tb24udjEuTW9uZXlCBrpIA8gBAVIG'
    'YW1vdW50EjYKD2lkZW1wb3RlbmN5X2tleRgDIAEoCUINukgK2AEBcgUQCBiAAVIOaWRlbXBvdG'
    'VuY3lLZXk=');

@$core.Deprecated('Use investorWithdrawResponseDescriptor instead')
const InvestorWithdrawResponse$json = {
  '1': 'InvestorWithdrawResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.funding.v1.InvestorAccountObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `InvestorWithdrawResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorWithdrawResponseDescriptor =
    $convert.base64Decode(
        'ChhJbnZlc3RvcldpdGhkcmF3UmVzcG9uc2USNQoEZGF0YRgBIAEoCzIhLmZ1bmRpbmcudjEuSW'
        '52ZXN0b3JBY2NvdW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use fundLoanRequestDescriptor instead')
const FundLoanRequest$json = {
  '1': 'FundLoanRequest',
  '2': [
    {
      '1': 'loan_request_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'loanRequestId'
    },
  ],
};

/// Descriptor for `FundLoanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fundLoanRequestDescriptor = $convert.base64Decode(
    'Cg9GdW5kTG9hblJlcXVlc3QSMQoPbG9hbl9yZXF1ZXN0X2lkGAEgASgJQgm6SAZyBBADGChSDW'
    'xvYW5SZXF1ZXN0SWQ=');

@$core.Deprecated('Use fundLoanResponseDescriptor instead')
const FundLoanResponse$json = {
  '1': 'FundLoanResponse',
  '2': [
    {
      '1': 'allocations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.funding.v1.FundingAllocationObject',
      '10': 'allocations'
    },
    {
      '1': 'total_allocated',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'totalAllocated'
    },
    {
      '1': 'deficit',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'deficit'
    },
    {'1': 'fully_funded', '3': 4, '4': 1, '5': 8, '10': 'fullyFunded'},
  ],
};

/// Descriptor for `FundLoanResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fundLoanResponseDescriptor = $convert.base64Decode(
    'ChBGdW5kTG9hblJlc3BvbnNlEkUKC2FsbG9jYXRpb25zGAEgAygLMiMuZnVuZGluZy52MS5GdW'
    '5kaW5nQWxsb2NhdGlvbk9iamVjdFILYWxsb2NhdGlvbnMSOQoPdG90YWxfYWxsb2NhdGVkGAIg'
    'ASgLMhAuY29tbW9uLnYxLk1vbmV5Ug50b3RhbEFsbG9jYXRlZBIqCgdkZWZpY2l0GAMgASgLMh'
    'AuY29tbW9uLnYxLk1vbmV5UgdkZWZpY2l0EiEKDGZ1bGx5X2Z1bmRlZBgEIAEoCFILZnVsbHlG'
    'dW5kZWQ=');

@$core.Deprecated('Use fundingReleaseRequestDescriptor instead')
const FundingReleaseRequest$json = {
  '1': 'FundingReleaseRequest',
  '2': [
    {
      '1': 'loan_request_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'loanRequestId'
    },
  ],
};

/// Descriptor for `FundingReleaseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fundingReleaseRequestDescriptor = $convert.base64Decode(
    'ChVGdW5kaW5nUmVsZWFzZVJlcXVlc3QSMQoPbG9hbl9yZXF1ZXN0X2lkGAEgASgJQgm6SAZyBB'
    'ADGChSDWxvYW5SZXF1ZXN0SWQ=');

@$core.Deprecated('Use fundingReleaseResponseDescriptor instead')
const FundingReleaseResponse$json = {
  '1': 'FundingReleaseResponse',
  '2': [
    {
      '1': 'released',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'released'
    },
  ],
};

/// Descriptor for `FundingReleaseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fundingReleaseResponseDescriptor =
    $convert.base64Decode(
        'ChZGdW5kaW5nUmVsZWFzZVJlc3BvbnNlEiwKCHJlbGVhc2VkGAEgASgLMhAuY29tbW9uLnYxLk'
        '1vbmV5UghyZWxlYXNlZA==');

@$core.Deprecated('Use absorbLossRequestDescriptor instead')
const AbsorbLossRequest$json = {
  '1': 'AbsorbLossRequest',
  '2': [
    {
      '1': 'loan_request_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'loanRequestId'
    },
    {
      '1': 'amount',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '8': {},
      '10': 'amount'
    },
    {
      '1': 'loss_reference',
      '3': 3,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'lossReference'
    },
    {'1': 'product_id', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'productId'},
  ],
};

/// Descriptor for `AbsorbLossRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List absorbLossRequestDescriptor = $convert.base64Decode(
    'ChFBYnNvcmJMb3NzUmVxdWVzdBIxCg9sb2FuX3JlcXVlc3RfaWQYASABKAlCCbpIBnIEEAMYKF'
    'INbG9hblJlcXVlc3RJZBIwCgZhbW91bnQYAiABKAsyEC5jb21tb24udjEuTW9uZXlCBrpIA8gB'
    'AVIGYW1vdW50EjQKDmxvc3NfcmVmZXJlbmNlGAMgASgJQg26SArYAQFyBRADGIABUg1sb3NzUm'
    'VmZXJlbmNlEisKCnByb2R1Y3RfaWQYBCABKAlCDLpICdgBAXIEEAMYKFIJcHJvZHVjdElk');

@$core.Deprecated('Use absorbLossResponseDescriptor instead')
const AbsorbLossResponse$json = {
  '1': 'AbsorbLossResponse',
  '2': [
    {
      '1': 'absorbed',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'absorbed'
    },
    {
      '1': 'unrecoverable',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'unrecoverable'
    },
    {'1': 'settled', '3': 3, '4': 1, '5': 8, '10': 'settled'},
  ],
};

/// Descriptor for `AbsorbLossResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List absorbLossResponseDescriptor = $convert.base64Decode(
    'ChJBYnNvcmJMb3NzUmVzcG9uc2USLAoIYWJzb3JiZWQYASABKAsyEC5jb21tb24udjEuTW9uZX'
    'lSCGFic29yYmVkEjYKDXVucmVjb3ZlcmFibGUYAiABKAsyEC5jb21tb24udjEuTW9uZXlSDXVu'
    'cmVjb3ZlcmFibGUSGAoHc2V0dGxlZBgDIAEoCFIHc2V0dGxlZA==');

@$core.Deprecated('Use loanRepaymentApplyRequestDescriptor instead')
const LoanRepaymentApplyRequest$json = {
  '1': 'LoanRepaymentApplyRequest',
  '2': [
    {
      '1': 'loan_request_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'loanRequestId'
    },
    {
      '1': 'loan_account_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'loanAccountId'
    },
    {'1': 'product_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'productId'},
    {
      '1': 'repayment_reference',
      '3': 4,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'repaymentReference'
    },
    {
      '1': 'principal',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '8': {},
      '10': 'principal'
    },
    {
      '1': 'interest',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '8': {},
      '10': 'interest'
    },
  ],
};

/// Descriptor for `LoanRepaymentApplyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRepaymentApplyRequestDescriptor = $convert.base64Decode(
    'ChlMb2FuUmVwYXltZW50QXBwbHlSZXF1ZXN0EjEKD2xvYW5fcmVxdWVzdF9pZBgBIAEoCUIJuk'
    'gGcgQQAxgoUg1sb2FuUmVxdWVzdElkEjEKD2xvYW5fYWNjb3VudF9pZBgCIAEoCUIJukgGcgQQ'
    'AxgoUg1sb2FuQWNjb3VudElkEigKCnByb2R1Y3RfaWQYAyABKAlCCbpIBnIEEAMYKFIJcHJvZH'
    'VjdElkEjsKE3JlcGF5bWVudF9yZWZlcmVuY2UYBCABKAlCCrpIB3IFEAMYgAFSEnJlcGF5bWVu'
    'dFJlZmVyZW5jZRI2CglwcmluY2lwYWwYBSABKAsyEC5jb21tb24udjEuTW9uZXlCBrpIA8gBAV'
    'IJcHJpbmNpcGFsEjQKCGludGVyZXN0GAYgASgLMhAuY29tbW9uLnYxLk1vbmV5Qga6SAPIAQFS'
    'CGludGVyZXN0');

@$core.Deprecated('Use loanRecoveryApplyRequestDescriptor instead')
const LoanRecoveryApplyRequest$json = {
  '1': 'LoanRecoveryApplyRequest',
  '2': [
    {
      '1': 'loan_request_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'loanRequestId'
    },
    {'1': 'product_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'productId'},
    {
      '1': 'recovery_reference',
      '3': 3,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'recoveryReference'
    },
    {
      '1': 'principal',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '8': {},
      '10': 'principal'
    },
  ],
};

/// Descriptor for `LoanRecoveryApplyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRecoveryApplyRequestDescriptor = $convert.base64Decode(
    'ChhMb2FuUmVjb3ZlcnlBcHBseVJlcXVlc3QSMQoPbG9hbl9yZXF1ZXN0X2lkGAEgASgJQgm6SA'
    'ZyBBADGChSDWxvYW5SZXF1ZXN0SWQSKAoKcHJvZHVjdF9pZBgCIAEoCUIJukgGcgQQAxgoUglw'
    'cm9kdWN0SWQSOQoScmVjb3ZlcnlfcmVmZXJlbmNlGAMgASgJQgq6SAdyBRADGIABUhFyZWNvdm'
    'VyeVJlZmVyZW5jZRI2CglwcmluY2lwYWwYBCABKAsyEC5jb21tb24udjEuTW9uZXlCBrpIA8gB'
    'AVIJcHJpbmNpcGFs');

@$core.Deprecated('Use loanRecoveryApplyResponseDescriptor instead')
const LoanRecoveryApplyResponse$json = {
  '1': 'LoanRecoveryApplyResponse',
  '2': [
    {
      '1': 'recovered',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'recovered'
    },
    {'1': 'settled', '3': 2, '4': 1, '5': 8, '10': 'settled'},
  ],
};

/// Descriptor for `LoanRecoveryApplyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRecoveryApplyResponseDescriptor =
    $convert.base64Decode(
        'ChlMb2FuUmVjb3ZlcnlBcHBseVJlc3BvbnNlEi4KCXJlY292ZXJlZBgBIAEoCzIQLmNvbW1vbi'
        '52MS5Nb25leVIJcmVjb3ZlcmVkEhgKB3NldHRsZWQYAiABKAhSB3NldHRsZWQ=');

@$core.Deprecated('Use repaymentShareObjectDescriptor instead')
const RepaymentShareObject$json = {
  '1': 'RepaymentShareObject',
  '2': [
    {'1': 'source_id', '3': 1, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'source_type', '3': 2, '4': 1, '5': 9, '10': 'sourceType'},
    {'1': 'tranche_level', '3': 3, '4': 1, '5': 5, '10': 'trancheLevel'},
    {
      '1': 'principal',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'principal'
    },
    {
      '1': 'interest',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'interest'
    },
    {
      '1': 'platform_fee',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'platformFee'
    },
    {
      '1': 'withholding_tax',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'withholdingTax'
    },
  ],
};

/// Descriptor for `RepaymentShareObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repaymentShareObjectDescriptor = $convert.base64Decode(
    'ChRSZXBheW1lbnRTaGFyZU9iamVjdBIbCglzb3VyY2VfaWQYASABKAlSCHNvdXJjZUlkEh8KC3'
    'NvdXJjZV90eXBlGAIgASgJUgpzb3VyY2VUeXBlEiMKDXRyYW5jaGVfbGV2ZWwYAyABKAVSDHRy'
    'YW5jaGVMZXZlbBIuCglwcmluY2lwYWwYBCABKAsyEC5jb21tb24udjEuTW9uZXlSCXByaW5jaX'
    'BhbBIsCghpbnRlcmVzdBgFIAEoCzIQLmNvbW1vbi52MS5Nb25leVIIaW50ZXJlc3QSMwoMcGxh'
    'dGZvcm1fZmVlGAYgASgLMhAuY29tbW9uLnYxLk1vbmV5UgtwbGF0Zm9ybUZlZRI5Cg93aXRoaG'
    '9sZGluZ190YXgYByABKAsyEC5jb21tb24udjEuTW9uZXlSDndpdGhob2xkaW5nVGF4');

@$core.Deprecated('Use loanRepaymentApplyResponseDescriptor instead')
const LoanRepaymentApplyResponse$json = {
  '1': 'LoanRepaymentApplyResponse',
  '2': [
    {
      '1': 'shares',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.funding.v1.RepaymentShareObject',
      '10': 'shares'
    },
    {'1': 'settled', '3': 2, '4': 1, '5': 8, '10': 'settled'},
  ],
};

/// Descriptor for `LoanRepaymentApplyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRepaymentApplyResponseDescriptor =
    $convert.base64Decode(
        'ChpMb2FuUmVwYXltZW50QXBwbHlSZXNwb25zZRI4CgZzaGFyZXMYASADKAsyIC5mdW5kaW5nLn'
        'YxLlJlcGF5bWVudFNoYXJlT2JqZWN0UgZzaGFyZXMSGAoHc2V0dGxlZBgCIAEoCFIHc2V0dGxl'
        'ZA==');

const $core.Map<$core.String, $core.dynamic> FundingServiceBase$json = {
  '1': 'FundingService',
  '2': [
    {
      '1': 'InvestorAccountSave',
      '2': '.funding.v1.InvestorAccountSaveRequest',
      '3': '.funding.v1.InvestorAccountSaveResponse',
      '4': {}
    },
    {
      '1': 'InvestorAccountGet',
      '2': '.funding.v1.InvestorAccountGetRequest',
      '3': '.funding.v1.InvestorAccountGetResponse',
      '4': {}
    },
    {
      '1': 'InvestorAccountSearch',
      '2': '.funding.v1.InvestorAccountSearchRequest',
      '3': '.funding.v1.InvestorAccountSearchResponse',
      '4': {},
      '6': true
    },
    {
      '1': 'InvestorStatement',
      '2': '.funding.v1.InvestorStatementRequest',
      '3': '.funding.v1.InvestorStatementResponse',
      '4': {'34': 1},
    },
    {
      '1': 'InvestorDeposit',
      '2': '.funding.v1.InvestorDepositRequest',
      '3': '.funding.v1.InvestorDepositResponse',
      '4': {}
    },
    {
      '1': 'InvestorWithdraw',
      '2': '.funding.v1.InvestorWithdrawRequest',
      '3': '.funding.v1.InvestorWithdrawResponse',
      '4': {}
    },
    {
      '1': 'FundLoan',
      '2': '.funding.v1.FundLoanRequest',
      '3': '.funding.v1.FundLoanResponse',
      '4': {}
    },
    {
      '1': 'AbsorbLoss',
      '2': '.funding.v1.AbsorbLossRequest',
      '3': '.funding.v1.AbsorbLossResponse',
      '4': {}
    },
    {
      '1': 'FundingRelease',
      '2': '.funding.v1.FundingReleaseRequest',
      '3': '.funding.v1.FundingReleaseResponse',
      '4': {}
    },
    {
      '1': 'LoanRepaymentApply',
      '2': '.funding.v1.LoanRepaymentApplyRequest',
      '3': '.funding.v1.LoanRepaymentApplyResponse',
      '4': {}
    },
    {
      '1': 'LoanRecoveryApply',
      '2': '.funding.v1.LoanRecoveryApplyRequest',
      '3': '.funding.v1.LoanRecoveryApplyResponse',
      '4': {}
    },
  ],
  '3': {},
};

@$core.Deprecated('Use fundingServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    FundingServiceBase$messageJson = {
  '.funding.v1.InvestorAccountSaveRequest': InvestorAccountSaveRequest$json,
  '.funding.v1.InvestorAccountObject': InvestorAccountObject$json,
  '.common.v1.Money': $0.Money$json,
  '.google.protobuf.Struct': $1.Struct$json,
  '.google.protobuf.Struct.FieldsEntry': $1.Struct_FieldsEntry$json,
  '.google.protobuf.Value': $1.Value$json,
  '.google.protobuf.ListValue': $1.ListValue$json,
  '.funding.v1.InvestorAccountSaveResponse': InvestorAccountSaveResponse$json,
  '.funding.v1.InvestorAccountGetRequest': InvestorAccountGetRequest$json,
  '.funding.v1.InvestorAccountGetResponse': InvestorAccountGetResponse$json,
  '.funding.v1.InvestorAccountSearchRequest': InvestorAccountSearchRequest$json,
  '.common.v1.PageCursor': $2.PageCursor$json,
  '.funding.v1.InvestorAccountSearchResponse':
      InvestorAccountSearchResponse$json,
  '.funding.v1.InvestorStatementRequest': InvestorStatementRequest$json,
  '.funding.v1.InvestorStatementResponse': InvestorStatementResponse$json,
  '.funding.v1.InvestorStatementEntry': InvestorStatementEntry$json,
  '.funding.v1.InvestorStatementTotals': InvestorStatementTotals$json,
  '.funding.v1.InvestorDepositRequest': InvestorDepositRequest$json,
  '.funding.v1.InvestorDepositResponse': InvestorDepositResponse$json,
  '.funding.v1.InvestorWithdrawRequest': InvestorWithdrawRequest$json,
  '.funding.v1.InvestorWithdrawResponse': InvestorWithdrawResponse$json,
  '.funding.v1.FundLoanRequest': FundLoanRequest$json,
  '.funding.v1.FundLoanResponse': FundLoanResponse$json,
  '.funding.v1.FundingAllocationObject': FundingAllocationObject$json,
  '.funding.v1.AbsorbLossRequest': AbsorbLossRequest$json,
  '.funding.v1.AbsorbLossResponse': AbsorbLossResponse$json,
  '.funding.v1.FundingReleaseRequest': FundingReleaseRequest$json,
  '.funding.v1.FundingReleaseResponse': FundingReleaseResponse$json,
  '.funding.v1.LoanRepaymentApplyRequest': LoanRepaymentApplyRequest$json,
  '.funding.v1.LoanRepaymentApplyResponse': LoanRepaymentApplyResponse$json,
  '.funding.v1.RepaymentShareObject': RepaymentShareObject$json,
  '.funding.v1.LoanRecoveryApplyRequest': LoanRecoveryApplyRequest$json,
  '.funding.v1.LoanRecoveryApplyResponse': LoanRecoveryApplyResponse$json,
};

/// Descriptor for `FundingService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List fundingServiceDescriptor = $convert.base64Decode(
    'Cg5GdW5kaW5nU2VydmljZRKFAQoTSW52ZXN0b3JBY2NvdW50U2F2ZRImLmZ1bmRpbmcudjEuSW'
    '52ZXN0b3JBY2NvdW50U2F2ZVJlcXVlc3QaJy5mdW5kaW5nLnYxLkludmVzdG9yQWNjb3VudFNh'
    'dmVSZXNwb25zZSIdgrUYGQoXaW52ZXN0b3JfYWNjb3VudF9tYW5hZ2USgAEKEkludmVzdG9yQW'
    'Njb3VudEdldBIlLmZ1bmRpbmcudjEuSW52ZXN0b3JBY2NvdW50R2V0UmVxdWVzdBomLmZ1bmRp'
    'bmcudjEuSW52ZXN0b3JBY2NvdW50R2V0UmVzcG9uc2UiG4K1GBcKFWludmVzdG9yX2FjY291bn'
    'RfdmlldxKLAQoVSW52ZXN0b3JBY2NvdW50U2VhcmNoEiguZnVuZGluZy52MS5JbnZlc3RvckFj'
    'Y291bnRTZWFyY2hSZXF1ZXN0GikuZnVuZGluZy52MS5JbnZlc3RvckFjY291bnRTZWFyY2hSZX'
    'Nwb25zZSIbgrUYFwoVaW52ZXN0b3JfYWNjb3VudF92aWV3MAESgAEKEUludmVzdG9yU3RhdGVt'
    'ZW50EiQuZnVuZGluZy52MS5JbnZlc3RvclN0YXRlbWVudFJlcXVlc3QaJS5mdW5kaW5nLnYxLk'
    'ludmVzdG9yU3RhdGVtZW50UmVzcG9uc2UiHpACAYK1GBcKFWludmVzdG9yX2FjY291bnRfdmll'
    'dxJ5Cg9JbnZlc3RvckRlcG9zaXQSIi5mdW5kaW5nLnYxLkludmVzdG9yRGVwb3NpdFJlcXVlc3'
    'QaIy5mdW5kaW5nLnYxLkludmVzdG9yRGVwb3NpdFJlc3BvbnNlIh2CtRgZChdpbnZlc3Rvcl9h'
    'Y2NvdW50X21hbmFnZRJ8ChBJbnZlc3RvcldpdGhkcmF3EiMuZnVuZGluZy52MS5JbnZlc3Rvcl'
    'dpdGhkcmF3UmVxdWVzdBokLmZ1bmRpbmcudjEuSW52ZXN0b3JXaXRoZHJhd1Jlc3BvbnNlIh2C'
    'tRgZChdpbnZlc3Rvcl9hY2NvdW50X21hbmFnZRJYCghGdW5kTG9hbhIbLmZ1bmRpbmcudjEuRn'
    'VuZExvYW5SZXF1ZXN0GhwuZnVuZGluZy52MS5GdW5kTG9hblJlc3BvbnNlIhGCtRgNCgtmdW5k'
    'X21hbmFnZRJeCgpBYnNvcmJMb3NzEh0uZnVuZGluZy52MS5BYnNvcmJMb3NzUmVxdWVzdBoeLm'
    'Z1bmRpbmcudjEuQWJzb3JiTG9zc1Jlc3BvbnNlIhGCtRgNCgtmdW5kX21hbmFnZRJqCg5GdW5k'
    'aW5nUmVsZWFzZRIhLmZ1bmRpbmcudjEuRnVuZGluZ1JlbGVhc2VSZXF1ZXN0GiIuZnVuZGluZy'
    '52MS5GdW5kaW5nUmVsZWFzZVJlc3BvbnNlIhGCtRgNCgtmdW5kX21hbmFnZRJ2ChJMb2FuUmVw'
    'YXltZW50QXBwbHkSJS5mdW5kaW5nLnYxLkxvYW5SZXBheW1lbnRBcHBseVJlcXVlc3QaJi5mdW'
    '5kaW5nLnYxLkxvYW5SZXBheW1lbnRBcHBseVJlc3BvbnNlIhGCtRgNCgtmdW5kX21hbmFnZRJz'
    'ChFMb2FuUmVjb3ZlcnlBcHBseRIkLmZ1bmRpbmcudjEuTG9hblJlY292ZXJ5QXBwbHlSZXF1ZX'
    'N0GiUuZnVuZGluZy52MS5Mb2FuUmVjb3ZlcnlBcHBseVJlc3BvbnNlIhGCtRgNCgtmdW5kX21h'
    'bmFnZRr0AoK1GO8CCg9zZXJ2aWNlX2Z1bmRpbmcSFWludmVzdG9yX2FjY291bnRfdmlldxIXaW'
    '52ZXN0b3JfYWNjb3VudF9tYW5hZ2USC2Z1bmRfbWFuYWdlGj8IARIVaW52ZXN0b3JfYWNjb3Vu'
    'dF92aWV3EhdpbnZlc3Rvcl9hY2NvdW50X21hbmFnZRILZnVuZF9tYW5hZ2UaPwgCEhVpbnZlc3'
    'Rvcl9hY2NvdW50X3ZpZXcSF2ludmVzdG9yX2FjY291bnRfbWFuYWdlEgtmdW5kX21hbmFnZRom'
    'CAMSFWludmVzdG9yX2FjY291bnRfdmlldxILZnVuZF9tYW5hZ2UaGQgEEhVpbnZlc3Rvcl9hY2'
    'NvdW50X3ZpZXcaGQgFEhVpbnZlc3Rvcl9hY2NvdW50X3ZpZXcaPwgGEhVpbnZlc3Rvcl9hY2Nv'
    'dW50X3ZpZXcSF2ludmVzdG9yX2FjY291bnRfbWFuYWdlEgtmdW5kX21hbmFnZQ==');
