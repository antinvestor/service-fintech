//
//  Generated code. Do not modify.
//  source: funding/v1/funding.proto
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

@$core.Deprecated('Use investorAccountObjectDescriptor instead')
const InvestorAccountObject$json = {
  '1': 'InvestorAccountObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'investor_id', '3': 2, '4': 1, '5': 9, '10': 'investorId'},
    {'1': 'account_name', '3': 3, '4': 1, '5': 9, '10': 'accountName'},
    {'1': 'available_balance', '3': 5, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'availableBalance'},
    {'1': 'reserved_balance', '3': 6, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'reservedBalance'},
    {'1': 'total_deployed', '3': 7, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalDeployed'},
    {'1': 'total_returned', '3': 8, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalReturned'},
    {'1': 'max_exposure', '3': 9, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'maxExposure'},
    {'1': 'min_interest_rate', '3': 10, '4': 1, '5': 9, '10': 'minInterestRate'},
    {'1': 'allowed_products', '3': 11, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'allowedProducts'},
    {'1': 'allowed_regions', '3': 12, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'allowedRegions'},
    {'1': 'group_affiliations', '3': 13, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'groupAffiliations'},
    {'1': 'state', '3': 14, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 15, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
  '9': [
    {'1': 4, '2': 5},
  ],
};

/// Descriptor for `InvestorAccountObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountObjectDescriptor = $convert.base64Decode(
    'ChVJbnZlc3RvckFjY291bnRPYmplY3QSDgoCaWQYASABKAlSAmlkEh8KC2ludmVzdG9yX2lkGA'
    'IgASgJUgppbnZlc3RvcklkEiEKDGFjY291bnRfbmFtZRgDIAEoCVILYWNjb3VudE5hbWUSPQoR'
    'YXZhaWxhYmxlX2JhbGFuY2UYBSABKAsyEC5jb21tb24udjEuTW9uZXlSEGF2YWlsYWJsZUJhbG'
    'FuY2USOwoQcmVzZXJ2ZWRfYmFsYW5jZRgGIAEoCzIQLmNvbW1vbi52MS5Nb25leVIPcmVzZXJ2'
    'ZWRCYWxhbmNlEjcKDnRvdGFsX2RlcGxveWVkGAcgASgLMhAuY29tbW9uLnYxLk1vbmV5Ug10b3'
    'RhbERlcGxveWVkEjcKDnRvdGFsX3JldHVybmVkGAggASgLMhAuY29tbW9uLnYxLk1vbmV5Ug10'
    'b3RhbFJldHVybmVkEjMKDG1heF9leHBvc3VyZRgJIAEoCzIQLmNvbW1vbi52MS5Nb25leVILbW'
    'F4RXhwb3N1cmUSKgoRbWluX2ludGVyZXN0X3JhdGUYCiABKAlSD21pbkludGVyZXN0UmF0ZRJC'
    'ChBhbGxvd2VkX3Byb2R1Y3RzGAsgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIPYWxsb3'
    'dlZFByb2R1Y3RzEkAKD2FsbG93ZWRfcmVnaW9ucxgMIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5T'
    'dHJ1Y3RSDmFsbG93ZWRSZWdpb25zEkYKEmdyb3VwX2FmZmlsaWF0aW9ucxgNIAEoCzIXLmdvb2'
    'dsZS5wcm90b2J1Zi5TdHJ1Y3RSEWdyb3VwQWZmaWxpYXRpb25zEiYKBXN0YXRlGA4gASgOMhAu'
    'Y29tbW9uLnYxLlNUQVRFUgVzdGF0ZRI3Cgpwcm9wZXJ0aWVzGA8gASgLMhcuZ29vZ2xlLnByb3'
    'RvYnVmLlN0cnVjdFIKcHJvcGVydGllc0oECAQQBQ==');

@$core.Deprecated('Use fundingAllocationObjectDescriptor instead')
const FundingAllocationObject$json = {
  '1': 'FundingAllocationObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'loan_request_id', '3': 2, '4': 1, '5': 9, '10': 'loanRequestId'},
    {'1': 'source_id', '3': 3, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'source_type', '3': 4, '4': 1, '5': 9, '10': 'sourceType'},
    {'1': 'tranche_level', '3': 5, '4': 1, '5': 5, '10': 'trancheLevel'},
    {'1': 'amount', '3': 6, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'amount'},
    {'1': 'proportion', '3': 8, '4': 1, '5': 9, '10': 'proportion'},
    {'1': 'properties', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
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
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.funding.v1.InvestorAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorAccountSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSaveRequestDescriptor = $convert.base64Decode(
    'ChpJbnZlc3RvckFjY291bnRTYXZlUmVxdWVzdBI1CgRkYXRhGAEgASgLMiEuZnVuZGluZy52MS'
    '5JbnZlc3RvckFjY291bnRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use investorAccountSaveResponseDescriptor instead')
const InvestorAccountSaveResponse$json = {
  '1': 'InvestorAccountSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.funding.v1.InvestorAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorAccountSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSaveResponseDescriptor = $convert.base64Decode(
    'ChtJbnZlc3RvckFjY291bnRTYXZlUmVzcG9uc2USNQoEZGF0YRgBIAEoCzIhLmZ1bmRpbmcudj'
    'EuSW52ZXN0b3JBY2NvdW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use investorAccountGetRequestDescriptor instead')
const InvestorAccountGetRequest$json = {
  '1': 'InvestorAccountGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `InvestorAccountGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountGetRequestDescriptor = $convert.base64Decode(
    'ChlJbnZlc3RvckFjY291bnRHZXRSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use investorAccountGetResponseDescriptor instead')
const InvestorAccountGetResponse$json = {
  '1': 'InvestorAccountGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.funding.v1.InvestorAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorAccountGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountGetResponseDescriptor = $convert.base64Decode(
    'ChpJbnZlc3RvckFjY291bnRHZXRSZXNwb25zZRI1CgRkYXRhGAEgASgLMiEuZnVuZGluZy52MS'
    '5JbnZlc3RvckFjY291bnRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use investorAccountSearchRequestDescriptor instead')
const InvestorAccountSearchRequest$json = {
  '1': 'InvestorAccountSearchRequest',
  '2': [
    {'1': 'investor_id', '3': 1, '4': 1, '5': 9, '10': 'investorId'},
    {'1': 'currency_code', '3': 2, '4': 1, '5': 9, '10': 'currencyCode'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `InvestorAccountSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSearchRequestDescriptor = $convert.base64Decode(
    'ChxJbnZlc3RvckFjY291bnRTZWFyY2hSZXF1ZXN0Eh8KC2ludmVzdG9yX2lkGAEgASgJUgppbn'
    'Zlc3RvcklkEiMKDWN1cnJlbmN5X2NvZGUYAiABKAlSDGN1cnJlbmN5Q29kZRItCgZjdXJzb3IY'
    'AyABKAsyFS5jb21tb24udjEuUGFnZUN1cnNvclIGY3Vyc29y');

@$core.Deprecated('Use investorAccountSearchResponseDescriptor instead')
const InvestorAccountSearchResponse$json = {
  '1': 'InvestorAccountSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.funding.v1.InvestorAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorAccountSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSearchResponseDescriptor = $convert.base64Decode(
    'Ch1JbnZlc3RvckFjY291bnRTZWFyY2hSZXNwb25zZRI1CgRkYXRhGAEgAygLMiEuZnVuZGluZy'
    '52MS5JbnZlc3RvckFjY291bnRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use investorDepositRequestDescriptor instead')
const InvestorDepositRequest$json = {
  '1': 'InvestorDepositRequest',
  '2': [
    {'1': 'account_id', '3': 1, '4': 1, '5': 9, '10': 'accountId'},
    {'1': 'amount', '3': 2, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'amount'},
  ],
  '9': [
    {'1': 3, '2': 4},
  ],
};

/// Descriptor for `InvestorDepositRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorDepositRequestDescriptor = $convert.base64Decode(
    'ChZJbnZlc3RvckRlcG9zaXRSZXF1ZXN0Eh0KCmFjY291bnRfaWQYASABKAlSCWFjY291bnRJZB'
    'IoCgZhbW91bnQYAiABKAsyEC5jb21tb24udjEuTW9uZXlSBmFtb3VudEoECAMQBA==');

@$core.Deprecated('Use investorDepositResponseDescriptor instead')
const InvestorDepositResponse$json = {
  '1': 'InvestorDepositResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.funding.v1.InvestorAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorDepositResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorDepositResponseDescriptor = $convert.base64Decode(
    'ChdJbnZlc3RvckRlcG9zaXRSZXNwb25zZRI1CgRkYXRhGAEgASgLMiEuZnVuZGluZy52MS5Jbn'
    'Zlc3RvckFjY291bnRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use investorWithdrawRequestDescriptor instead')
const InvestorWithdrawRequest$json = {
  '1': 'InvestorWithdrawRequest',
  '2': [
    {'1': 'account_id', '3': 1, '4': 1, '5': 9, '10': 'accountId'},
    {'1': 'amount', '3': 2, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'amount'},
  ],
};

/// Descriptor for `InvestorWithdrawRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorWithdrawRequestDescriptor = $convert.base64Decode(
    'ChdJbnZlc3RvcldpdGhkcmF3UmVxdWVzdBIdCgphY2NvdW50X2lkGAEgASgJUglhY2NvdW50SW'
    'QSKAoGYW1vdW50GAIgASgLMhAuY29tbW9uLnYxLk1vbmV5UgZhbW91bnQ=');

@$core.Deprecated('Use investorWithdrawResponseDescriptor instead')
const InvestorWithdrawResponse$json = {
  '1': 'InvestorWithdrawResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.funding.v1.InvestorAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorWithdrawResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorWithdrawResponseDescriptor = $convert.base64Decode(
    'ChhJbnZlc3RvcldpdGhkcmF3UmVzcG9uc2USNQoEZGF0YRgBIAEoCzIhLmZ1bmRpbmcudjEuSW'
    '52ZXN0b3JBY2NvdW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use fundLoanRequestDescriptor instead')
const FundLoanRequest$json = {
  '1': 'FundLoanRequest',
  '2': [
    {'1': 'loan_request_id', '3': 1, '4': 1, '5': 9, '10': 'loanRequestId'},
  ],
};

/// Descriptor for `FundLoanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fundLoanRequestDescriptor = $convert.base64Decode(
    'Cg9GdW5kTG9hblJlcXVlc3QSJgoPbG9hbl9yZXF1ZXN0X2lkGAEgASgJUg1sb2FuUmVxdWVzdE'
    'lk');

@$core.Deprecated('Use fundLoanResponseDescriptor instead')
const FundLoanResponse$json = {
  '1': 'FundLoanResponse',
  '2': [
    {'1': 'allocations', '3': 1, '4': 3, '5': 11, '6': '.funding.v1.FundingAllocationObject', '10': 'allocations'},
    {'1': 'total_allocated', '3': 2, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalAllocated'},
    {'1': 'deficit', '3': 3, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'deficit'},
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

@$core.Deprecated('Use absorbLossRequestDescriptor instead')
const AbsorbLossRequest$json = {
  '1': 'AbsorbLossRequest',
  '2': [
    {'1': 'loan_request_id', '3': 1, '4': 1, '5': 9, '10': 'loanRequestId'},
    {'1': 'amount', '3': 2, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'amount'},
  ],
};

/// Descriptor for `AbsorbLossRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List absorbLossRequestDescriptor = $convert.base64Decode(
    'ChFBYnNvcmJMb3NzUmVxdWVzdBImCg9sb2FuX3JlcXVlc3RfaWQYASABKAlSDWxvYW5SZXF1ZX'
    'N0SWQSKAoGYW1vdW50GAIgASgLMhAuY29tbW9uLnYxLk1vbmV5UgZhbW91bnQ=');

@$core.Deprecated('Use absorbLossResponseDescriptor instead')
const AbsorbLossResponse$json = {
  '1': 'AbsorbLossResponse',
  '2': [
    {'1': 'absorbed', '3': 1, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'absorbed'},
    {'1': 'unrecoverable', '3': 2, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'unrecoverable'},
  ],
};

/// Descriptor for `AbsorbLossResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List absorbLossResponseDescriptor = $convert.base64Decode(
    'ChJBYnNvcmJMb3NzUmVzcG9uc2USLAoIYWJzb3JiZWQYASABKAsyEC5jb21tb24udjEuTW9uZX'
    'lSCGFic29yYmVkEjYKDXVucmVjb3ZlcmFibGUYAiABKAsyEC5jb21tb24udjEuTW9uZXlSDXVu'
    'cmVjb3ZlcmFibGU=');

const $core.Map<$core.String, $core.dynamic> FundingServiceBase$json = {
  '1': 'FundingService',
  '2': [
    {'1': 'InvestorAccountSave', '2': '.funding.v1.InvestorAccountSaveRequest', '3': '.funding.v1.InvestorAccountSaveResponse', '4': {}},
    {'1': 'InvestorAccountGet', '2': '.funding.v1.InvestorAccountGetRequest', '3': '.funding.v1.InvestorAccountGetResponse', '4': {}},
    {'1': 'InvestorAccountSearch', '2': '.funding.v1.InvestorAccountSearchRequest', '3': '.funding.v1.InvestorAccountSearchResponse', '4': {}, '6': true},
    {'1': 'InvestorDeposit', '2': '.funding.v1.InvestorDepositRequest', '3': '.funding.v1.InvestorDepositResponse', '4': {}},
    {'1': 'InvestorWithdraw', '2': '.funding.v1.InvestorWithdrawRequest', '3': '.funding.v1.InvestorWithdrawResponse', '4': {}},
    {'1': 'FundLoan', '2': '.funding.v1.FundLoanRequest', '3': '.funding.v1.FundLoanResponse', '4': {}},
    {'1': 'AbsorbLoss', '2': '.funding.v1.AbsorbLossRequest', '3': '.funding.v1.AbsorbLossResponse', '4': {}},
  ],
  '3': {},
};

@$core.Deprecated('Use fundingServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> FundingServiceBase$messageJson = {
  '.funding.v1.InvestorAccountSaveRequest': InvestorAccountSaveRequest$json,
  '.funding.v1.InvestorAccountObject': InvestorAccountObject$json,
  '.common.v1.Money': $7.Money$json,
  '.google.protobuf.Struct': $6.Struct$json,
  '.google.protobuf.Struct.FieldsEntry': $6.Struct_FieldsEntry$json,
  '.google.protobuf.Value': $6.Value$json,
  '.google.protobuf.ListValue': $6.ListValue$json,
  '.funding.v1.InvestorAccountSaveResponse': InvestorAccountSaveResponse$json,
  '.funding.v1.InvestorAccountGetRequest': InvestorAccountGetRequest$json,
  '.funding.v1.InvestorAccountGetResponse': InvestorAccountGetResponse$json,
  '.funding.v1.InvestorAccountSearchRequest': InvestorAccountSearchRequest$json,
  '.common.v1.PageCursor': $8.PageCursor$json,
  '.funding.v1.InvestorAccountSearchResponse': InvestorAccountSearchResponse$json,
  '.funding.v1.InvestorDepositRequest': InvestorDepositRequest$json,
  '.funding.v1.InvestorDepositResponse': InvestorDepositResponse$json,
  '.funding.v1.InvestorWithdrawRequest': InvestorWithdrawRequest$json,
  '.funding.v1.InvestorWithdrawResponse': InvestorWithdrawResponse$json,
  '.funding.v1.FundLoanRequest': FundLoanRequest$json,
  '.funding.v1.FundLoanResponse': FundLoanResponse$json,
  '.funding.v1.FundingAllocationObject': FundingAllocationObject$json,
  '.funding.v1.AbsorbLossRequest': AbsorbLossRequest$json,
  '.funding.v1.AbsorbLossResponse': AbsorbLossResponse$json,
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
    'Nwb25zZSIbgrUYFwoVaW52ZXN0b3JfYWNjb3VudF92aWV3MAESeQoPSW52ZXN0b3JEZXBvc2l0'
    'EiIuZnVuZGluZy52MS5JbnZlc3RvckRlcG9zaXRSZXF1ZXN0GiMuZnVuZGluZy52MS5JbnZlc3'
    'RvckRlcG9zaXRSZXNwb25zZSIdgrUYGQoXaW52ZXN0b3JfYWNjb3VudF9tYW5hZ2USfAoQSW52'
    'ZXN0b3JXaXRoZHJhdxIjLmZ1bmRpbmcudjEuSW52ZXN0b3JXaXRoZHJhd1JlcXVlc3QaJC5mdW'
    '5kaW5nLnYxLkludmVzdG9yV2l0aGRyYXdSZXNwb25zZSIdgrUYGQoXaW52ZXN0b3JfYWNjb3Vu'
    'dF9tYW5hZ2USWAoIRnVuZExvYW4SGy5mdW5kaW5nLnYxLkZ1bmRMb2FuUmVxdWVzdBocLmZ1bm'
    'RpbmcudjEuRnVuZExvYW5SZXNwb25zZSIRgrUYDQoLZnVuZF9tYW5hZ2USXgoKQWJzb3JiTG9z'
    'cxIdLmZ1bmRpbmcudjEuQWJzb3JiTG9zc1JlcXVlc3QaHi5mdW5kaW5nLnYxLkFic29yYkxvc3'
    'NSZXNwb25zZSIRgrUYDQoLZnVuZF9tYW5hZ2Ua9AKCtRjvAgoPc2VydmljZV9mdW5kaW5nEhVp'
    'bnZlc3Rvcl9hY2NvdW50X3ZpZXcSF2ludmVzdG9yX2FjY291bnRfbWFuYWdlEgtmdW5kX21hbm'
    'FnZRo/CAESFWludmVzdG9yX2FjY291bnRfdmlldxIXaW52ZXN0b3JfYWNjb3VudF9tYW5hZ2US'
    'C2Z1bmRfbWFuYWdlGj8IAhIVaW52ZXN0b3JfYWNjb3VudF92aWV3EhdpbnZlc3Rvcl9hY2NvdW'
    '50X21hbmFnZRILZnVuZF9tYW5hZ2UaJggDEhVpbnZlc3Rvcl9hY2NvdW50X3ZpZXcSC2Z1bmRf'
    'bWFuYWdlGhkIBBIVaW52ZXN0b3JfYWNjb3VudF92aWV3GhkIBRIVaW52ZXN0b3JfYWNjb3VudF'
    '92aWV3Gj8IBhIVaW52ZXN0b3JfYWNjb3VudF92aWV3EhdpbnZlc3Rvcl9hY2NvdW50X21hbmFn'
    'ZRILZnVuZF9tYW5hZ2U=');

