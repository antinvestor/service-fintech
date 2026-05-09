//
//  Generated code. Do not modify.
//  source: loans/v1/loans.proto
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

@$core.Deprecated('Use loanStatusDescriptor instead')
const LoanStatus$json = {
  '1': 'LoanStatus',
  '2': [
    {'1': 'LOAN_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'LOAN_STATUS_PENDING_DISBURSEMENT', '2': 1},
    {'1': 'LOAN_STATUS_ACTIVE', '2': 2},
    {'1': 'LOAN_STATUS_DELINQUENT', '2': 3},
    {'1': 'LOAN_STATUS_DEFAULT', '2': 4},
    {'1': 'LOAN_STATUS_PAID_OFF', '2': 5},
    {'1': 'LOAN_STATUS_RESTRUCTURED', '2': 6},
    {'1': 'LOAN_STATUS_WRITTEN_OFF', '2': 7},
    {'1': 'LOAN_STATUS_CLOSED', '2': 8},
  ],
};

/// Descriptor for `LoanStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List loanStatusDescriptor = $convert.base64Decode(
    'CgpMb2FuU3RhdHVzEhsKF0xPQU5fU1RBVFVTX1VOU1BFQ0lGSUVEEAASJAogTE9BTl9TVEFUVV'
    'NfUEVORElOR19ESVNCVVJTRU1FTlQQARIWChJMT0FOX1NUQVRVU19BQ1RJVkUQAhIaChZMT0FO'
    'X1NUQVRVU19ERUxJTlFVRU5UEAMSFwoTTE9BTl9TVEFUVVNfREVGQVVMVBAEEhgKFExPQU5fU1'
    'RBVFVTX1BBSURfT0ZGEAUSHAoYTE9BTl9TVEFUVVNfUkVTVFJVQ1RVUkVEEAYSGwoXTE9BTl9T'
    'VEFUVVNfV1JJVFRFTl9PRkYQBxIWChJMT0FOX1NUQVRVU19DTE9TRUQQCA==');

@$core.Deprecated('Use disbursementStatusDescriptor instead')
const DisbursementStatus$json = {
  '1': 'DisbursementStatus',
  '2': [
    {'1': 'DISBURSEMENT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'DISBURSEMENT_STATUS_PENDING', '2': 1},
    {'1': 'DISBURSEMENT_STATUS_PROCESSING', '2': 2},
    {'1': 'DISBURSEMENT_STATUS_COMPLETED', '2': 3},
    {'1': 'DISBURSEMENT_STATUS_FAILED', '2': 4},
    {'1': 'DISBURSEMENT_STATUS_REVERSED', '2': 5},
  ],
};

/// Descriptor for `DisbursementStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List disbursementStatusDescriptor = $convert.base64Decode(
    'ChJEaXNidXJzZW1lbnRTdGF0dXMSIwofRElTQlVSU0VNRU5UX1NUQVRVU19VTlNQRUNJRklFRB'
    'AAEh8KG0RJU0JVUlNFTUVOVF9TVEFUVVNfUEVORElORxABEiIKHkRJU0JVUlNFTUVOVF9TVEFU'
    'VVNfUFJPQ0VTU0lORxACEiEKHURJU0JVUlNFTUVOVF9TVEFUVVNfQ09NUExFVEVEEAMSHgoaRE'
    'lTQlVSU0VNRU5UX1NUQVRVU19GQUlMRUQQBBIgChxESVNCVVJTRU1FTlRfU1RBVFVTX1JFVkVS'
    'U0VEEAU=');

@$core.Deprecated('Use repaymentStatusDescriptor instead')
const RepaymentStatus$json = {
  '1': 'RepaymentStatus',
  '2': [
    {'1': 'REPAYMENT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'REPAYMENT_STATUS_PENDING', '2': 1},
    {'1': 'REPAYMENT_STATUS_MATCHED', '2': 2},
    {'1': 'REPAYMENT_STATUS_PARTIAL', '2': 3},
    {'1': 'REPAYMENT_STATUS_OVERPAYMENT', '2': 4},
    {'1': 'REPAYMENT_STATUS_REVERSED', '2': 5},
  ],
};

/// Descriptor for `RepaymentStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List repaymentStatusDescriptor = $convert.base64Decode(
    'Cg9SZXBheW1lbnRTdGF0dXMSIAocUkVQQVlNRU5UX1NUQVRVU19VTlNQRUNJRklFRBAAEhwKGF'
    'JFUEFZTUVOVF9TVEFUVVNfUEVORElORxABEhwKGFJFUEFZTUVOVF9TVEFUVVNfTUFUQ0hFRBAC'
    'EhwKGFJFUEFZTUVOVF9TVEFUVVNfUEFSVElBTBADEiAKHFJFUEFZTUVOVF9TVEFUVVNfT1ZFUl'
    'BBWU1FTlQQBBIdChlSRVBBWU1FTlRfU1RBVFVTX1JFVkVSU0VEEAU=');

@$core.Deprecated('Use scheduleEntryStatusDescriptor instead')
const ScheduleEntryStatus$json = {
  '1': 'ScheduleEntryStatus',
  '2': [
    {'1': 'SCHEDULE_ENTRY_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'SCHEDULE_ENTRY_STATUS_UPCOMING', '2': 1},
    {'1': 'SCHEDULE_ENTRY_STATUS_DUE', '2': 2},
    {'1': 'SCHEDULE_ENTRY_STATUS_PAID', '2': 3},
    {'1': 'SCHEDULE_ENTRY_STATUS_PARTIAL', '2': 4},
    {'1': 'SCHEDULE_ENTRY_STATUS_OVERDUE', '2': 5},
    {'1': 'SCHEDULE_ENTRY_STATUS_WAIVED', '2': 6},
  ],
};

/// Descriptor for `ScheduleEntryStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List scheduleEntryStatusDescriptor = $convert.base64Decode(
    'ChNTY2hlZHVsZUVudHJ5U3RhdHVzEiUKIVNDSEVEVUxFX0VOVFJZX1NUQVRVU19VTlNQRUNJRk'
    'lFRBAAEiIKHlNDSEVEVUxFX0VOVFJZX1NUQVRVU19VUENPTUlORxABEh0KGVNDSEVEVUxFX0VO'
    'VFJZX1NUQVRVU19EVUUQAhIeChpTQ0hFRFVMRV9FTlRSWV9TVEFUVVNfUEFJRBADEiEKHVNDSE'
    'VEVUxFX0VOVFJZX1NUQVRVU19QQVJUSUFMEAQSIQodU0NIRURVTEVfRU5UUllfU1RBVFVTX09W'
    'RVJEVUUQBRIgChxTQ0hFRFVMRV9FTlRSWV9TVEFUVVNfV0FJVkVEEAY=');

@$core.Deprecated('Use penaltyTypeDescriptor instead')
const PenaltyType$json = {
  '1': 'PenaltyType',
  '2': [
    {'1': 'PENALTY_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'PENALTY_TYPE_LATE_PAYMENT', '2': 1},
    {'1': 'PENALTY_TYPE_DEFAULT', '2': 2},
    {'1': 'PENALTY_TYPE_EARLY_REPAYMENT', '2': 3},
    {'1': 'PENALTY_TYPE_BOUNCED_PAYMENT', '2': 4},
  ],
};

/// Descriptor for `PenaltyType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List penaltyTypeDescriptor = $convert.base64Decode(
    'CgtQZW5hbHR5VHlwZRIcChhQRU5BTFRZX1RZUEVfVU5TUEVDSUZJRUQQABIdChlQRU5BTFRZX1'
    'RZUEVfTEFURV9QQVlNRU5UEAESGAoUUEVOQUxUWV9UWVBFX0RFRkFVTFQQAhIgChxQRU5BTFRZ'
    'X1RZUEVfRUFSTFlfUkVQQVlNRU5UEAMSIAocUEVOQUxUWV9UWVBFX0JPVU5DRURfUEFZTUVOVB'
    'AE');

@$core.Deprecated('Use restructureTypeDescriptor instead')
const RestructureType$json = {
  '1': 'RestructureType',
  '2': [
    {'1': 'RESTRUCTURE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'RESTRUCTURE_TYPE_RESCHEDULE', '2': 1},
    {'1': 'RESTRUCTURE_TYPE_REFINANCE', '2': 2},
    {'1': 'RESTRUCTURE_TYPE_RATE_CHANGE', '2': 3},
    {'1': 'RESTRUCTURE_TYPE_PARTIAL_WAIVER', '2': 4},
    {'1': 'RESTRUCTURE_TYPE_WRITE_OFF', '2': 5},
  ],
};

/// Descriptor for `RestructureType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List restructureTypeDescriptor = $convert.base64Decode(
    'Cg9SZXN0cnVjdHVyZVR5cGUSIAocUkVTVFJVQ1RVUkVfVFlQRV9VTlNQRUNJRklFRBAAEh8KG1'
    'JFU1RSVUNUVVJFX1RZUEVfUkVTQ0hFRFVMRRABEh4KGlJFU1RSVUNUVVJFX1RZUEVfUkVGSU5B'
    'TkNFEAISIAocUkVTVFJVQ1RVUkVfVFlQRV9SQVRFX0NIQU5HRRADEiMKH1JFU1RSVUNUVVJFX1'
    'RZUEVfUEFSVElBTF9XQUlWRVIQBBIeChpSRVNUUlVDVFVSRV9UWVBFX1dSSVRFX09GRhAF');

@$core.Deprecated('Use reconciliationStatusDescriptor instead')
const ReconciliationStatus$json = {
  '1': 'ReconciliationStatus',
  '2': [
    {'1': 'RECONCILIATION_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'RECONCILIATION_STATUS_PENDING', '2': 1},
    {'1': 'RECONCILIATION_STATUS_MATCHED', '2': 2},
    {'1': 'RECONCILIATION_STATUS_UNMATCHED', '2': 3},
    {'1': 'RECONCILIATION_STATUS_DISPUTED', '2': 4},
  ],
};

/// Descriptor for `ReconciliationStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List reconciliationStatusDescriptor = $convert.base64Decode(
    'ChRSZWNvbmNpbGlhdGlvblN0YXR1cxIlCiFSRUNPTkNJTElBVElPTl9TVEFUVVNfVU5TUEVDSU'
    'ZJRUQQABIhCh1SRUNPTkNJTElBVElPTl9TVEFUVVNfUEVORElORxABEiEKHVJFQ09OQ0lMSUFU'
    'SU9OX1NUQVRVU19NQVRDSEVEEAISIwofUkVDT05DSUxJQVRJT05fU1RBVFVTX1VOTUFUQ0hFRB'
    'ADEiIKHlJFQ09OQ0lMSUFUSU9OX1NUQVRVU19ESVNQVVRFRBAE');

@$core.Deprecated('Use loanProductTypeDescriptor instead')
const LoanProductType$json = {
  '1': 'LoanProductType',
  '2': [
    {'1': 'LOAN_PRODUCT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'LOAN_PRODUCT_TYPE_TERM', '2': 1},
    {'1': 'LOAN_PRODUCT_TYPE_REVOLVING', '2': 2},
    {'1': 'LOAN_PRODUCT_TYPE_BULLET', '2': 3},
    {'1': 'LOAN_PRODUCT_TYPE_GRADUATED', '2': 4},
  ],
};

/// Descriptor for `LoanProductType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List loanProductTypeDescriptor = $convert.base64Decode(
    'Cg9Mb2FuUHJvZHVjdFR5cGUSIQodTE9BTl9QUk9EVUNUX1RZUEVfVU5TUEVDSUZJRUQQABIaCh'
    'ZMT0FOX1BST0RVQ1RfVFlQRV9URVJNEAESHwobTE9BTl9QUk9EVUNUX1RZUEVfUkVWT0xWSU5H'
    'EAISHAoYTE9BTl9QUk9EVUNUX1RZUEVfQlVMTEVUEAMSHwobTE9BTl9QUk9EVUNUX1RZUEVfR1'
    'JBRFVBVEVEEAQ=');

@$core.Deprecated('Use loanRequestStatusDescriptor instead')
const LoanRequestStatus$json = {
  '1': 'LoanRequestStatus',
  '2': [
    {'1': 'LOAN_REQUEST_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'LOAN_REQUEST_STATUS_DRAFT', '2': 1},
    {'1': 'LOAN_REQUEST_STATUS_SUBMITTED', '2': 2},
    {'1': 'LOAN_REQUEST_STATUS_APPROVED', '2': 3},
    {'1': 'LOAN_REQUEST_STATUS_REJECTED', '2': 4},
    {'1': 'LOAN_REQUEST_STATUS_CANCELLED', '2': 5},
    {'1': 'LOAN_REQUEST_STATUS_EXPIRED', '2': 6},
    {'1': 'LOAN_REQUEST_STATUS_LOAN_CREATED', '2': 7},
  ],
};

/// Descriptor for `LoanRequestStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List loanRequestStatusDescriptor = $convert.base64Decode(
    'ChFMb2FuUmVxdWVzdFN0YXR1cxIjCh9MT0FOX1JFUVVFU1RfU1RBVFVTX1VOU1BFQ0lGSUVEEA'
    'ASHQoZTE9BTl9SRVFVRVNUX1NUQVRVU19EUkFGVBABEiEKHUxPQU5fUkVRVUVTVF9TVEFUVVNf'
    'U1VCTUlUVEVEEAISIAocTE9BTl9SRVFVRVNUX1NUQVRVU19BUFBST1ZFRBADEiAKHExPQU5fUk'
    'VRVUVTVF9TVEFUVVNfUkVKRUNURUQQBBIhCh1MT0FOX1JFUVVFU1RfU1RBVFVTX0NBTkNFTExF'
    'RBAFEh8KG0xPQU5fUkVRVUVTVF9TVEFUVVNfRVhQSVJFRBAGEiQKIExPQU5fUkVRVUVTVF9TVE'
    'FUVVNfTE9BTl9DUkVBVEVEEAc=');

@$core.Deprecated('Use interestMethodDescriptor instead')
const InterestMethod$json = {
  '1': 'InterestMethod',
  '2': [
    {'1': 'INTEREST_METHOD_UNSPECIFIED', '2': 0},
    {'1': 'INTEREST_METHOD_FLAT', '2': 1},
    {'1': 'INTEREST_METHOD_REDUCING_BALANCE', '2': 2},
    {'1': 'INTEREST_METHOD_COMPOUND', '2': 3},
  ],
};

/// Descriptor for `InterestMethod`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List interestMethodDescriptor = $convert.base64Decode(
    'Cg5JbnRlcmVzdE1ldGhvZBIfChtJTlRFUkVTVF9NRVRIT0RfVU5TUEVDSUZJRUQQABIYChRJTl'
    'RFUkVTVF9NRVRIT0RfRkxBVBABEiQKIElOVEVSRVNUX01FVEhPRF9SRURVQ0lOR19CQUxBTkNF'
    'EAISHAoYSU5URVJFU1RfTUVUSE9EX0NPTVBPVU5EEAM=');

@$core.Deprecated('Use repaymentFrequencyDescriptor instead')
const RepaymentFrequency$json = {
  '1': 'RepaymentFrequency',
  '2': [
    {'1': 'REPAYMENT_FREQUENCY_UNSPECIFIED', '2': 0},
    {'1': 'REPAYMENT_FREQUENCY_DAILY', '2': 1},
    {'1': 'REPAYMENT_FREQUENCY_WEEKLY', '2': 2},
    {'1': 'REPAYMENT_FREQUENCY_BIWEEKLY', '2': 3},
    {'1': 'REPAYMENT_FREQUENCY_MONTHLY', '2': 4},
    {'1': 'REPAYMENT_FREQUENCY_QUARTERLY', '2': 5},
  ],
};

/// Descriptor for `RepaymentFrequency`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List repaymentFrequencyDescriptor = $convert.base64Decode(
    'ChJSZXBheW1lbnRGcmVxdWVuY3kSIwofUkVQQVlNRU5UX0ZSRVFVRU5DWV9VTlNQRUNJRklFRB'
    'AAEh0KGVJFUEFZTUVOVF9GUkVRVUVOQ1lfREFJTFkQARIeChpSRVBBWU1FTlRfRlJFUVVFTkNZ'
    'X1dFRUtMWRACEiAKHFJFUEFZTUVOVF9GUkVRVUVOQ1lfQklXRUVLTFkQAxIfChtSRVBBWU1FTl'
    'RfRlJFUVVFTkNZX01PTlRITFkQBBIhCh1SRVBBWU1FTlRfRlJFUVVFTkNZX1FVQVJURVJMWRAF');

@$core.Deprecated('Use productFormRequirementDescriptor instead')
const ProductFormRequirement$json = {
  '1': 'ProductFormRequirement',
  '2': [
    {'1': 'template_id', '3': 1, '4': 1, '5': 9, '10': 'templateId'},
    {'1': 'stage', '3': 2, '4': 1, '5': 9, '10': 'stage'},
    {'1': 'required', '3': 3, '4': 1, '5': 8, '10': 'required'},
    {'1': 'order', '3': 4, '4': 1, '5': 5, '10': 'order'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `ProductFormRequirement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productFormRequirementDescriptor = $convert.base64Decode(
    'ChZQcm9kdWN0Rm9ybVJlcXVpcmVtZW50Eh8KC3RlbXBsYXRlX2lkGAEgASgJUgp0ZW1wbGF0ZU'
    'lkEhQKBXN0YWdlGAIgASgJUgVzdGFnZRIaCghyZXF1aXJlZBgDIAEoCFIIcmVxdWlyZWQSFAoF'
    'b3JkZXIYBCABKAVSBW9yZGVyEiAKC2Rlc2NyaXB0aW9uGAUgASgJUgtkZXNjcmlwdGlvbg==');

@$core.Deprecated('Use loanProductObjectDescriptor instead')
const LoanProductObject$json = {
  '1': 'LoanProductObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'code', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'code'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'product_type', '3': 6, '4': 1, '5': 14, '6': '.loans.v1.LoanProductType', '10': 'productType'},
    {'1': 'currency_code', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'currencyCode'},
    {'1': 'interest_method', '3': 8, '4': 1, '5': 14, '6': '.loans.v1.InterestMethod', '10': 'interestMethod'},
    {'1': 'repayment_frequency', '3': 9, '4': 1, '5': 14, '6': '.loans.v1.RepaymentFrequency', '10': 'repaymentFrequency'},
    {'1': 'min_amount', '3': 10, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'minAmount'},
    {'1': 'max_amount', '3': 11, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'maxAmount'},
    {'1': 'min_term_days', '3': 12, '4': 1, '5': 5, '10': 'minTermDays'},
    {'1': 'max_term_days', '3': 13, '4': 1, '5': 5, '10': 'maxTermDays'},
    {'1': 'annual_interest_rate', '3': 14, '4': 1, '5': 9, '10': 'annualInterestRate'},
    {'1': 'processing_fee_percent', '3': 15, '4': 1, '5': 9, '10': 'processingFeePercent'},
    {'1': 'insurance_fee_percent', '3': 16, '4': 1, '5': 9, '10': 'insuranceFeePercent'},
    {'1': 'late_penalty_rate', '3': 17, '4': 1, '5': 9, '10': 'latePenaltyRate'},
    {'1': 'grace_period_days', '3': 18, '4': 1, '5': 5, '10': 'gracePeriodDays'},
    {'1': 'fee_structure', '3': 19, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'feeStructure'},
    {'1': 'eligibility_criteria', '3': 20, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'eligibilityCriteria'},
    {'1': 'state', '3': 21, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 22, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
    {'1': 'required_forms', '3': 23, '4': 3, '5': 11, '6': '.loans.v1.ProductFormRequirement', '10': 'requiredForms'},
  ],
};

/// Descriptor for `LoanProductObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanProductObjectDescriptor = $convert.base64Decode(
    'ChFMb2FuUHJvZHVjdE9iamVjdBIuCgJpZBgBIAEoCUIeukgb2AEBchYQAxgoMhBbMC05YS16Xy'
    '1dezMsNDB9UgJpZBIyCg9vcmdhbml6YXRpb25faWQYAiABKAlCCbpIBnIEEAMYKFIOb3JnYW5p'
    'emF0aW9uSWQSGwoEbmFtZRgDIAEoCUIHukgEcgIQAVIEbmFtZRIbCgRjb2RlGAQgASgJQge6SA'
    'RyAhABUgRjb2RlEiAKC2Rlc2NyaXB0aW9uGAUgASgJUgtkZXNjcmlwdGlvbhI8Cgxwcm9kdWN0'
    'X3R5cGUYBiABKA4yGS5sb2Fucy52MS5Mb2FuUHJvZHVjdFR5cGVSC3Byb2R1Y3RUeXBlEi0KDW'
    'N1cnJlbmN5X2NvZGUYByABKAlCCLpIBXIDmAEDUgxjdXJyZW5jeUNvZGUSQQoPaW50ZXJlc3Rf'
    'bWV0aG9kGAggASgOMhgubG9hbnMudjEuSW50ZXJlc3RNZXRob2RSDmludGVyZXN0TWV0aG9kEk'
    '0KE3JlcGF5bWVudF9mcmVxdWVuY3kYCSABKA4yHC5sb2Fucy52MS5SZXBheW1lbnRGcmVxdWVu'
    'Y3lSEnJlcGF5bWVudEZyZXF1ZW5jeRIvCgptaW5fYW1vdW50GAogASgLMhAuY29tbW9uLnYxLk'
    '1vbmV5UgltaW5BbW91bnQSLwoKbWF4X2Ftb3VudBgLIAEoCzIQLmNvbW1vbi52MS5Nb25leVIJ'
    'bWF4QW1vdW50EiIKDW1pbl90ZXJtX2RheXMYDCABKAVSC21pblRlcm1EYXlzEiIKDW1heF90ZX'
    'JtX2RheXMYDSABKAVSC21heFRlcm1EYXlzEjAKFGFubnVhbF9pbnRlcmVzdF9yYXRlGA4gASgJ'
    'UhJhbm51YWxJbnRlcmVzdFJhdGUSNAoWcHJvY2Vzc2luZ19mZWVfcGVyY2VudBgPIAEoCVIUcH'
    'JvY2Vzc2luZ0ZlZVBlcmNlbnQSMgoVaW5zdXJhbmNlX2ZlZV9wZXJjZW50GBAgASgJUhNpbnN1'
    'cmFuY2VGZWVQZXJjZW50EioKEWxhdGVfcGVuYWx0eV9yYXRlGBEgASgJUg9sYXRlUGVuYWx0eV'
    'JhdGUSKgoRZ3JhY2VfcGVyaW9kX2RheXMYEiABKAVSD2dyYWNlUGVyaW9kRGF5cxI8Cg1mZWVf'
    'c3RydWN0dXJlGBMgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIMZmVlU3RydWN0dXJlEk'
    'oKFGVsaWdpYmlsaXR5X2NyaXRlcmlhGBQgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIT'
    'ZWxpZ2liaWxpdHlDcml0ZXJpYRImCgVzdGF0ZRgVIAEoDjIQLmNvbW1vbi52MS5TVEFURVIFc3'
    'RhdGUSNwoKcHJvcGVydGllcxgWIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSCnByb3Bl'
    'cnRpZXMSRwoOcmVxdWlyZWRfZm9ybXMYFyADKAsyIC5sb2Fucy52MS5Qcm9kdWN0Rm9ybVJlcX'
    'VpcmVtZW50Ug1yZXF1aXJlZEZvcm1z');

@$core.Deprecated('Use loanRequestObjectDescriptor instead')
const LoanRequestObject$json = {
  '1': 'LoanRequestObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'product_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'productId'},
    {'1': 'client_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'clientId'},
    {'1': 'agent_id', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'agentId'},
    {'1': 'branch_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'branchId'},
    {'1': 'organization_id', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'status', '3': 7, '4': 1, '5': 14, '6': '.loans.v1.LoanRequestStatus', '10': 'status'},
    {'1': 'requested_amount', '3': 8, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'requestedAmount'},
    {'1': 'approved_amount', '3': 9, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'approvedAmount'},
    {'1': 'requested_term_days', '3': 10, '4': 1, '5': 5, '10': 'requestedTermDays'},
    {'1': 'approved_term_days', '3': 11, '4': 1, '5': 5, '10': 'approvedTermDays'},
    {'1': 'interest_rate', '3': 12, '4': 1, '5': 9, '10': 'interestRate'},
    {'1': 'currency_code', '3': 13, '4': 1, '5': 9, '10': 'currencyCode'},
    {'1': 'purpose', '3': 14, '4': 1, '5': 9, '10': 'purpose'},
    {'1': 'rejection_reason', '3': 15, '4': 1, '5': 9, '10': 'rejectionReason'},
    {'1': 'offer_expires_at', '3': 16, '4': 1, '5': 9, '10': 'offerExpiresAt'},
    {'1': 'submitted_at', '3': 17, '4': 1, '5': 9, '10': 'submittedAt'},
    {'1': 'decided_at', '3': 18, '4': 1, '5': 9, '10': 'decidedAt'},
    {'1': 'loan_account_id', '3': 19, '4': 1, '5': 9, '10': 'loanAccountId'},
    {'1': 'source_service', '3': 20, '4': 1, '5': 9, '10': 'sourceService'},
    {'1': 'source_request_id', '3': 21, '4': 1, '5': 9, '10': 'sourceRequestId'},
    {'1': 'idempotency_key', '3': 22, '4': 1, '5': 9, '10': 'idempotencyKey'},
    {'1': 'properties', '3': 23, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `LoanRequestObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestObjectDescriptor = $convert.base64Decode(
    'ChFMb2FuUmVxdWVzdE9iamVjdBIuCgJpZBgBIAEoCUIeukgb2AEBchYQAxgoMhBbMC05YS16Xy'
    '1dezMsNDB9UgJpZBIoCgpwcm9kdWN0X2lkGAIgASgJQgm6SAZyBBADGChSCXByb2R1Y3RJZBIm'
    'CgljbGllbnRfaWQYAyABKAlCCbpIBnIEEAMYKFIIY2xpZW50SWQSJQoIYWdlbnRfaWQYBCABKA'
    'lCCrpIB9gBAXICGChSB2FnZW50SWQSJwoJYnJhbmNoX2lkGAUgASgJQgq6SAfYAQFyAhgoUghi'
    'cmFuY2hJZBIyCg9vcmdhbml6YXRpb25faWQYBiABKAlCCbpIBnIEEAMYKFIOb3JnYW5pemF0aW'
    '9uSWQSMwoGc3RhdHVzGAcgASgOMhsubG9hbnMudjEuTG9hblJlcXVlc3RTdGF0dXNSBnN0YXR1'
    'cxI7ChByZXF1ZXN0ZWRfYW1vdW50GAggASgLMhAuY29tbW9uLnYxLk1vbmV5Ug9yZXF1ZXN0ZW'
    'RBbW91bnQSOQoPYXBwcm92ZWRfYW1vdW50GAkgASgLMhAuY29tbW9uLnYxLk1vbmV5Ug5hcHBy'
    'b3ZlZEFtb3VudBIuChNyZXF1ZXN0ZWRfdGVybV9kYXlzGAogASgFUhFyZXF1ZXN0ZWRUZXJtRG'
    'F5cxIsChJhcHByb3ZlZF90ZXJtX2RheXMYCyABKAVSEGFwcHJvdmVkVGVybURheXMSIwoNaW50'
    'ZXJlc3RfcmF0ZRgMIAEoCVIMaW50ZXJlc3RSYXRlEiMKDWN1cnJlbmN5X2NvZGUYDSABKAlSDG'
    'N1cnJlbmN5Q29kZRIYCgdwdXJwb3NlGA4gASgJUgdwdXJwb3NlEikKEHJlamVjdGlvbl9yZWFz'
    'b24YDyABKAlSD3JlamVjdGlvblJlYXNvbhIoChBvZmZlcl9leHBpcmVzX2F0GBAgASgJUg5vZm'
    'ZlckV4cGlyZXNBdBIhCgxzdWJtaXR0ZWRfYXQYESABKAlSC3N1Ym1pdHRlZEF0Eh0KCmRlY2lk'
    'ZWRfYXQYEiABKAlSCWRlY2lkZWRBdBImCg9sb2FuX2FjY291bnRfaWQYEyABKAlSDWxvYW5BY2'
    'NvdW50SWQSJQoOc291cmNlX3NlcnZpY2UYFCABKAlSDXNvdXJjZVNlcnZpY2USKgoRc291cmNl'
    'X3JlcXVlc3RfaWQYFSABKAlSD3NvdXJjZVJlcXVlc3RJZBInCg9pZGVtcG90ZW5jeV9rZXkYFi'
    'ABKAlSDmlkZW1wb3RlbmN5S2V5EjcKCnByb3BlcnRpZXMYFyABKAsyFy5nb29nbGUucHJvdG9i'
    'dWYuU3RydWN0Ugpwcm9wZXJ0aWVz');

@$core.Deprecated('Use clientProductAccessObjectDescriptor instead')
const ClientProductAccessObject$json = {
  '1': 'ClientProductAccessObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'client_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'clientId'},
    {'1': 'product_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'productId'},
    {'1': 'granted_by', '3': 4, '4': 1, '5': 9, '10': 'grantedBy'},
    {'1': 'state', '3': 5, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
  ],
};

/// Descriptor for `ClientProductAccessObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientProductAccessObjectDescriptor = $convert.base64Decode(
    'ChlDbGllbnRQcm9kdWN0QWNjZXNzT2JqZWN0Ei4KAmlkGAEgASgJQh66SBvYAQFyFhADGCgyEF'
    'swLTlhLXpfLV17Myw0MH1SAmlkEiYKCWNsaWVudF9pZBgCIAEoCUIJukgGcgQQAxgoUghjbGll'
    'bnRJZBIoCgpwcm9kdWN0X2lkGAMgASgJQgm6SAZyBBADGChSCXByb2R1Y3RJZBIdCgpncmFudG'
    'VkX2J5GAQgASgJUglncmFudGVkQnkSJgoFc3RhdGUYBSABKA4yEC5jb21tb24udjEuU1RBVEVS'
    'BXN0YXRl');

@$core.Deprecated('Use loanAccountObjectDescriptor instead')
const LoanAccountObject$json = {
  '1': 'LoanAccountObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'loan_request_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'loanRequestId'},
    {'1': 'product_id', '3': 3, '4': 1, '5': 9, '10': 'productId'},
    {'1': 'client_id', '3': 4, '4': 1, '5': 9, '10': 'clientId'},
    {'1': 'agent_id', '3': 5, '4': 1, '5': 9, '10': 'agentId'},
    {'1': 'branch_id', '3': 6, '4': 1, '5': 9, '10': 'branchId'},
    {'1': 'organization_id', '3': 7, '4': 1, '5': 9, '10': 'organizationId'},
    {'1': 'status', '3': 8, '4': 1, '5': 14, '6': '.loans.v1.LoanStatus', '10': 'status'},
    {'1': 'principal_amount', '3': 10, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'principalAmount'},
    {'1': 'interest_rate', '3': 11, '4': 1, '5': 9, '10': 'interestRate'},
    {'1': 'term_days', '3': 12, '4': 1, '5': 5, '10': 'termDays'},
    {'1': 'interest_method', '3': 13, '4': 1, '5': 14, '6': '.loans.v1.InterestMethod', '10': 'interestMethod'},
    {'1': 'repayment_frequency', '3': 14, '4': 1, '5': 14, '6': '.loans.v1.RepaymentFrequency', '10': 'repaymentFrequency'},
    {'1': 'disbursed_at', '3': 15, '4': 1, '5': 9, '10': 'disbursedAt'},
    {'1': 'maturity_date', '3': 16, '4': 1, '5': 9, '10': 'maturityDate'},
    {'1': 'first_repayment_date', '3': 17, '4': 1, '5': 9, '10': 'firstRepaymentDate'},
    {'1': 'last_repayment_date', '3': 18, '4': 1, '5': 9, '10': 'lastRepaymentDate'},
    {'1': 'days_past_due', '3': 19, '4': 1, '5': 5, '10': 'daysPastDue'},
    {'1': 'ledger_asset_account_id', '3': 20, '4': 1, '5': 9, '10': 'ledgerAssetAccountId'},
    {'1': 'ledger_interest_income_account_id', '3': 21, '4': 1, '5': 9, '10': 'ledgerInterestIncomeAccountId'},
    {'1': 'ledger_fee_income_account_id', '3': 22, '4': 1, '5': 9, '10': 'ledgerFeeIncomeAccountId'},
    {'1': 'ledger_penalty_income_account_id', '3': 23, '4': 1, '5': 9, '10': 'ledgerPenaltyIncomeAccountId'},
    {'1': 'payment_account_ref', '3': 24, '4': 1, '5': 9, '10': 'paymentAccountRef'},
    {'1': 'properties', '3': 25, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `LoanAccountObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanAccountObjectDescriptor = $convert.base64Decode(
    'ChFMb2FuQWNjb3VudE9iamVjdBIuCgJpZBgBIAEoCUIeukgb2AEBchYQAxgoMhBbMC05YS16Xy'
    '1dezMsNDB9UgJpZBIxCg9sb2FuX3JlcXVlc3RfaWQYAiABKAlCCbpIBnIEEAMYKFINbG9hblJl'
    'cXVlc3RJZBIdCgpwcm9kdWN0X2lkGAMgASgJUglwcm9kdWN0SWQSGwoJY2xpZW50X2lkGAQgAS'
    'gJUghjbGllbnRJZBIZCghhZ2VudF9pZBgFIAEoCVIHYWdlbnRJZBIbCglicmFuY2hfaWQYBiAB'
    'KAlSCGJyYW5jaElkEicKD29yZ2FuaXphdGlvbl9pZBgHIAEoCVIOb3JnYW5pemF0aW9uSWQSLA'
    'oGc3RhdHVzGAggASgOMhQubG9hbnMudjEuTG9hblN0YXR1c1IGc3RhdHVzEjsKEHByaW5jaXBh'
    'bF9hbW91bnQYCiABKAsyEC5jb21tb24udjEuTW9uZXlSD3ByaW5jaXBhbEFtb3VudBIjCg1pbn'
    'RlcmVzdF9yYXRlGAsgASgJUgxpbnRlcmVzdFJhdGUSGwoJdGVybV9kYXlzGAwgASgFUgh0ZXJt'
    'RGF5cxJBCg9pbnRlcmVzdF9tZXRob2QYDSABKA4yGC5sb2Fucy52MS5JbnRlcmVzdE1ldGhvZF'
    'IOaW50ZXJlc3RNZXRob2QSTQoTcmVwYXltZW50X2ZyZXF1ZW5jeRgOIAEoDjIcLmxvYW5zLnYx'
    'LlJlcGF5bWVudEZyZXF1ZW5jeVIScmVwYXltZW50RnJlcXVlbmN5EiEKDGRpc2J1cnNlZF9hdB'
    'gPIAEoCVILZGlzYnVyc2VkQXQSIwoNbWF0dXJpdHlfZGF0ZRgQIAEoCVIMbWF0dXJpdHlEYXRl'
    'EjAKFGZpcnN0X3JlcGF5bWVudF9kYXRlGBEgASgJUhJmaXJzdFJlcGF5bWVudERhdGUSLgoTbG'
    'FzdF9yZXBheW1lbnRfZGF0ZRgSIAEoCVIRbGFzdFJlcGF5bWVudERhdGUSIgoNZGF5c19wYXN0'
    'X2R1ZRgTIAEoBVILZGF5c1Bhc3REdWUSNQoXbGVkZ2VyX2Fzc2V0X2FjY291bnRfaWQYFCABKA'
    'lSFGxlZGdlckFzc2V0QWNjb3VudElkEkgKIWxlZGdlcl9pbnRlcmVzdF9pbmNvbWVfYWNjb3Vu'
    'dF9pZBgVIAEoCVIdbGVkZ2VySW50ZXJlc3RJbmNvbWVBY2NvdW50SWQSPgocbGVkZ2VyX2ZlZV'
    '9pbmNvbWVfYWNjb3VudF9pZBgWIAEoCVIYbGVkZ2VyRmVlSW5jb21lQWNjb3VudElkEkYKIGxl'
    'ZGdlcl9wZW5hbHR5X2luY29tZV9hY2NvdW50X2lkGBcgASgJUhxsZWRnZXJQZW5hbHR5SW5jb2'
    '1lQWNjb3VudElkEi4KE3BheW1lbnRfYWNjb3VudF9yZWYYGCABKAlSEXBheW1lbnRBY2NvdW50'
    'UmVmEjcKCnByb3BlcnRpZXMYGSABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0Ugpwcm9wZX'
    'J0aWVz');

@$core.Deprecated('Use repaymentScheduleObjectDescriptor instead')
const RepaymentScheduleObject$json = {
  '1': 'RepaymentScheduleObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'loan_account_id', '3': 2, '4': 1, '5': 9, '10': 'loanAccountId'},
    {'1': 'version', '3': 3, '4': 1, '5': 5, '10': 'version'},
    {'1': 'is_active', '3': 4, '4': 1, '5': 8, '10': 'isActive'},
    {'1': 'generated_at', '3': 5, '4': 1, '5': 9, '10': 'generatedAt'},
    {'1': 'entries', '3': 6, '4': 3, '5': 11, '6': '.loans.v1.ScheduleEntryObject', '10': 'entries'},
    {'1': 'properties', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `RepaymentScheduleObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repaymentScheduleObjectDescriptor = $convert.base64Decode(
    'ChdSZXBheW1lbnRTY2hlZHVsZU9iamVjdBIOCgJpZBgBIAEoCVICaWQSJgoPbG9hbl9hY2NvdW'
    '50X2lkGAIgASgJUg1sb2FuQWNjb3VudElkEhgKB3ZlcnNpb24YAyABKAVSB3ZlcnNpb24SGwoJ'
    'aXNfYWN0aXZlGAQgASgIUghpc0FjdGl2ZRIhCgxnZW5lcmF0ZWRfYXQYBSABKAlSC2dlbmVyYX'
    'RlZEF0EjcKB2VudHJpZXMYBiADKAsyHS5sb2Fucy52MS5TY2hlZHVsZUVudHJ5T2JqZWN0Ugdl'
    'bnRyaWVzEjcKCnByb3BlcnRpZXMYByABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0Ugpwcm'
    '9wZXJ0aWVz');

@$core.Deprecated('Use scheduleEntryObjectDescriptor instead')
const ScheduleEntryObject$json = {
  '1': 'ScheduleEntryObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'schedule_id', '3': 2, '4': 1, '5': 9, '10': 'scheduleId'},
    {'1': 'installment_number', '3': 3, '4': 1, '5': 5, '10': 'installmentNumber'},
    {'1': 'due_date', '3': 4, '4': 1, '5': 9, '10': 'dueDate'},
    {'1': 'principal_due', '3': 5, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'principalDue'},
    {'1': 'interest_due', '3': 6, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'interestDue'},
    {'1': 'fees_due', '3': 7, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'feesDue'},
    {'1': 'total_due', '3': 8, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalDue'},
    {'1': 'principal_paid', '3': 9, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'principalPaid'},
    {'1': 'interest_paid', '3': 10, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'interestPaid'},
    {'1': 'fees_paid', '3': 11, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'feesPaid'},
    {'1': 'total_paid', '3': 12, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalPaid'},
    {'1': 'outstanding', '3': 13, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'outstanding'},
    {'1': 'status', '3': 14, '4': 1, '5': 14, '6': '.loans.v1.ScheduleEntryStatus', '10': 'status'},
    {'1': 'paid_date', '3': 15, '4': 1, '5': 9, '10': 'paidDate'},
    {'1': 'properties', '3': 16, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `ScheduleEntryObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scheduleEntryObjectDescriptor = $convert.base64Decode(
    'ChNTY2hlZHVsZUVudHJ5T2JqZWN0Eg4KAmlkGAEgASgJUgJpZBIfCgtzY2hlZHVsZV9pZBgCIA'
    'EoCVIKc2NoZWR1bGVJZBItChJpbnN0YWxsbWVudF9udW1iZXIYAyABKAVSEWluc3RhbGxtZW50'
    'TnVtYmVyEhkKCGR1ZV9kYXRlGAQgASgJUgdkdWVEYXRlEjUKDXByaW5jaXBhbF9kdWUYBSABKA'
    'syEC5jb21tb24udjEuTW9uZXlSDHByaW5jaXBhbER1ZRIzCgxpbnRlcmVzdF9kdWUYBiABKAsy'
    'EC5jb21tb24udjEuTW9uZXlSC2ludGVyZXN0RHVlEisKCGZlZXNfZHVlGAcgASgLMhAuY29tbW'
    '9uLnYxLk1vbmV5UgdmZWVzRHVlEi0KCXRvdGFsX2R1ZRgIIAEoCzIQLmNvbW1vbi52MS5Nb25l'
    'eVIIdG90YWxEdWUSNwoOcHJpbmNpcGFsX3BhaWQYCSABKAsyEC5jb21tb24udjEuTW9uZXlSDX'
    'ByaW5jaXBhbFBhaWQSNQoNaW50ZXJlc3RfcGFpZBgKIAEoCzIQLmNvbW1vbi52MS5Nb25leVIM'
    'aW50ZXJlc3RQYWlkEi0KCWZlZXNfcGFpZBgLIAEoCzIQLmNvbW1vbi52MS5Nb25leVIIZmVlc1'
    'BhaWQSLwoKdG90YWxfcGFpZBgMIAEoCzIQLmNvbW1vbi52MS5Nb25leVIJdG90YWxQYWlkEjIK'
    'C291dHN0YW5kaW5nGA0gASgLMhAuY29tbW9uLnYxLk1vbmV5UgtvdXRzdGFuZGluZxI1CgZzdG'
    'F0dXMYDiABKA4yHS5sb2Fucy52MS5TY2hlZHVsZUVudHJ5U3RhdHVzUgZzdGF0dXMSGwoJcGFp'
    'ZF9kYXRlGA8gASgJUghwYWlkRGF0ZRI3Cgpwcm9wZXJ0aWVzGBAgASgLMhcuZ29vZ2xlLnByb3'
    'RvYnVmLlN0cnVjdFIKcHJvcGVydGllcw==');

@$core.Deprecated('Use loanBalanceObjectDescriptor instead')
const LoanBalanceObject$json = {
  '1': 'LoanBalanceObject',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '10': 'loanAccountId'},
    {'1': 'principal_outstanding', '3': 2, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'principalOutstanding'},
    {'1': 'interest_accrued', '3': 3, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'interestAccrued'},
    {'1': 'fees_outstanding', '3': 4, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'feesOutstanding'},
    {'1': 'penalties_outstanding', '3': 5, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'penaltiesOutstanding'},
    {'1': 'total_outstanding', '3': 6, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalOutstanding'},
    {'1': 'total_paid', '3': 7, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalPaid'},
    {'1': 'total_disbursed', '3': 8, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalDisbursed'},
    {'1': 'last_calculated_at', '3': 9, '4': 1, '5': 9, '10': 'lastCalculatedAt'},
  ],
};

/// Descriptor for `LoanBalanceObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanBalanceObjectDescriptor = $convert.base64Decode(
    'ChFMb2FuQmFsYW5jZU9iamVjdBImCg9sb2FuX2FjY291bnRfaWQYASABKAlSDWxvYW5BY2NvdW'
    '50SWQSRQoVcHJpbmNpcGFsX291dHN0YW5kaW5nGAIgASgLMhAuY29tbW9uLnYxLk1vbmV5UhRw'
    'cmluY2lwYWxPdXRzdGFuZGluZxI7ChBpbnRlcmVzdF9hY2NydWVkGAMgASgLMhAuY29tbW9uLn'
    'YxLk1vbmV5Ug9pbnRlcmVzdEFjY3J1ZWQSOwoQZmVlc19vdXRzdGFuZGluZxgEIAEoCzIQLmNv'
    'bW1vbi52MS5Nb25leVIPZmVlc091dHN0YW5kaW5nEkUKFXBlbmFsdGllc19vdXRzdGFuZGluZx'
    'gFIAEoCzIQLmNvbW1vbi52MS5Nb25leVIUcGVuYWx0aWVzT3V0c3RhbmRpbmcSPQoRdG90YWxf'
    'b3V0c3RhbmRpbmcYBiABKAsyEC5jb21tb24udjEuTW9uZXlSEHRvdGFsT3V0c3RhbmRpbmcSLw'
    'oKdG90YWxfcGFpZBgHIAEoCzIQLmNvbW1vbi52MS5Nb25leVIJdG90YWxQYWlkEjkKD3RvdGFs'
    'X2Rpc2J1cnNlZBgIIAEoCzIQLmNvbW1vbi52MS5Nb25leVIOdG90YWxEaXNidXJzZWQSLAoSbG'
    'FzdF9jYWxjdWxhdGVkX2F0GAkgASgJUhBsYXN0Q2FsY3VsYXRlZEF0');

@$core.Deprecated('Use disbursementObjectDescriptor instead')
const DisbursementObject$json = {
  '1': 'DisbursementObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'loan_account_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'amount', '3': 3, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'amount'},
    {'1': 'status', '3': 5, '4': 1, '5': 14, '6': '.loans.v1.DisbursementStatus', '10': 'status'},
    {'1': 'payment_reference', '3': 6, '4': 1, '5': 9, '10': 'paymentReference'},
    {'1': 'ledger_transaction_id', '3': 7, '4': 1, '5': 9, '10': 'ledgerTransactionId'},
    {'1': 'disbursed_at', '3': 8, '4': 1, '5': 9, '10': 'disbursedAt'},
    {'1': 'channel', '3': 9, '4': 1, '5': 9, '10': 'channel'},
    {'1': 'recipient_reference', '3': 10, '4': 1, '5': 9, '10': 'recipientReference'},
    {'1': 'failure_reason', '3': 11, '4': 1, '5': 9, '10': 'failureReason'},
    {'1': 'idempotency_key', '3': 12, '4': 1, '5': 9, '10': 'idempotencyKey'},
    {'1': 'properties', '3': 13, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `DisbursementObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disbursementObjectDescriptor = $convert.base64Decode(
    'ChJEaXNidXJzZW1lbnRPYmplY3QSLgoCaWQYASABKAlCHrpIG9gBAXIWEAMYKDIQWzAtOWEtel'
    '8tXXszLDQwfVICaWQSMQoPbG9hbl9hY2NvdW50X2lkGAIgASgJQgm6SAZyBBADGChSDWxvYW5B'
    'Y2NvdW50SWQSKAoGYW1vdW50GAMgASgLMhAuY29tbW9uLnYxLk1vbmV5UgZhbW91bnQSNAoGc3'
    'RhdHVzGAUgASgOMhwubG9hbnMudjEuRGlzYnVyc2VtZW50U3RhdHVzUgZzdGF0dXMSKwoRcGF5'
    'bWVudF9yZWZlcmVuY2UYBiABKAlSEHBheW1lbnRSZWZlcmVuY2USMgoVbGVkZ2VyX3RyYW5zYW'
    'N0aW9uX2lkGAcgASgJUhNsZWRnZXJUcmFuc2FjdGlvbklkEiEKDGRpc2J1cnNlZF9hdBgIIAEo'
    'CVILZGlzYnVyc2VkQXQSGAoHY2hhbm5lbBgJIAEoCVIHY2hhbm5lbBIvChNyZWNpcGllbnRfcm'
    'VmZXJlbmNlGAogASgJUhJyZWNpcGllbnRSZWZlcmVuY2USJQoOZmFpbHVyZV9yZWFzb24YCyAB'
    'KAlSDWZhaWx1cmVSZWFzb24SJwoPaWRlbXBvdGVuY3lfa2V5GAwgASgJUg5pZGVtcG90ZW5jeU'
    'tleRI3Cgpwcm9wZXJ0aWVzGA0gASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIKcHJvcGVy'
    'dGllcw==');

@$core.Deprecated('Use repaymentObjectDescriptor instead')
const RepaymentObject$json = {
  '1': 'RepaymentObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'loan_account_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'amount', '3': 3, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'amount'},
    {'1': 'status', '3': 5, '4': 1, '5': 14, '6': '.loans.v1.RepaymentStatus', '10': 'status'},
    {'1': 'payment_reference', '3': 6, '4': 1, '5': 9, '10': 'paymentReference'},
    {'1': 'ledger_transaction_id', '3': 7, '4': 1, '5': 9, '10': 'ledgerTransactionId'},
    {'1': 'received_at', '3': 8, '4': 1, '5': 9, '10': 'receivedAt'},
    {'1': 'channel', '3': 9, '4': 1, '5': 9, '10': 'channel'},
    {'1': 'payer_reference', '3': 10, '4': 1, '5': 9, '10': 'payerReference'},
    {'1': 'principal_applied', '3': 11, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'principalApplied'},
    {'1': 'interest_applied', '3': 12, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'interestApplied'},
    {'1': 'fees_applied', '3': 13, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'feesApplied'},
    {'1': 'penalties_applied', '3': 14, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'penaltiesApplied'},
    {'1': 'excess_amount', '3': 15, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'excessAmount'},
    {'1': 'idempotency_key', '3': 16, '4': 1, '5': 9, '10': 'idempotencyKey'},
    {'1': 'properties', '3': 17, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `RepaymentObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repaymentObjectDescriptor = $convert.base64Decode(
    'Cg9SZXBheW1lbnRPYmplY3QSLgoCaWQYASABKAlCHrpIG9gBAXIWEAMYKDIQWzAtOWEtel8tXX'
    'szLDQwfVICaWQSMQoPbG9hbl9hY2NvdW50X2lkGAIgASgJQgm6SAZyBBADGChSDWxvYW5BY2Nv'
    'dW50SWQSKAoGYW1vdW50GAMgASgLMhAuY29tbW9uLnYxLk1vbmV5UgZhbW91bnQSMQoGc3RhdH'
    'VzGAUgASgOMhkubG9hbnMudjEuUmVwYXltZW50U3RhdHVzUgZzdGF0dXMSKwoRcGF5bWVudF9y'
    'ZWZlcmVuY2UYBiABKAlSEHBheW1lbnRSZWZlcmVuY2USMgoVbGVkZ2VyX3RyYW5zYWN0aW9uX2'
    'lkGAcgASgJUhNsZWRnZXJUcmFuc2FjdGlvbklkEh8KC3JlY2VpdmVkX2F0GAggASgJUgpyZWNl'
    'aXZlZEF0EhgKB2NoYW5uZWwYCSABKAlSB2NoYW5uZWwSJwoPcGF5ZXJfcmVmZXJlbmNlGAogAS'
    'gJUg5wYXllclJlZmVyZW5jZRI9ChFwcmluY2lwYWxfYXBwbGllZBgLIAEoCzIQLmNvbW1vbi52'
    'MS5Nb25leVIQcHJpbmNpcGFsQXBwbGllZBI7ChBpbnRlcmVzdF9hcHBsaWVkGAwgASgLMhAuY2'
    '9tbW9uLnYxLk1vbmV5Ug9pbnRlcmVzdEFwcGxpZWQSMwoMZmVlc19hcHBsaWVkGA0gASgLMhAu'
    'Y29tbW9uLnYxLk1vbmV5UgtmZWVzQXBwbGllZBI9ChFwZW5hbHRpZXNfYXBwbGllZBgOIAEoCz'
    'IQLmNvbW1vbi52MS5Nb25leVIQcGVuYWx0aWVzQXBwbGllZBI1Cg1leGNlc3NfYW1vdW50GA8g'
    'ASgLMhAuY29tbW9uLnYxLk1vbmV5UgxleGNlc3NBbW91bnQSJwoPaWRlbXBvdGVuY3lfa2V5GB'
    'AgASgJUg5pZGVtcG90ZW5jeUtleRI3Cgpwcm9wZXJ0aWVzGBEgASgLMhcuZ29vZ2xlLnByb3Rv'
    'YnVmLlN0cnVjdFIKcHJvcGVydGllcw==');

@$core.Deprecated('Use penaltyObjectDescriptor instead')
const PenaltyObject$json = {
  '1': 'PenaltyObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'loan_account_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'penalty_type', '3': 3, '4': 1, '5': 14, '6': '.loans.v1.PenaltyType', '10': 'penaltyType'},
    {'1': 'amount', '3': 4, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'amount'},
    {'1': 'reason', '3': 5, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'is_waived', '3': 6, '4': 1, '5': 8, '10': 'isWaived'},
    {'1': 'waived_by', '3': 7, '4': 1, '5': 9, '10': 'waivedBy'},
    {'1': 'waived_reason', '3': 8, '4': 1, '5': 9, '10': 'waivedReason'},
    {'1': 'ledger_transaction_id', '3': 9, '4': 1, '5': 9, '10': 'ledgerTransactionId'},
    {'1': 'applied_at', '3': 10, '4': 1, '5': 9, '10': 'appliedAt'},
    {'1': 'schedule_entry_id', '3': 11, '4': 1, '5': 9, '10': 'scheduleEntryId'},
    {'1': 'properties', '3': 12, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `PenaltyObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List penaltyObjectDescriptor = $convert.base64Decode(
    'Cg1QZW5hbHR5T2JqZWN0Ei4KAmlkGAEgASgJQh66SBvYAQFyFhADGCgyEFswLTlhLXpfLV17My'
    'w0MH1SAmlkEjEKD2xvYW5fYWNjb3VudF9pZBgCIAEoCUIJukgGcgQQAxgoUg1sb2FuQWNjb3Vu'
    'dElkEjgKDHBlbmFsdHlfdHlwZRgDIAEoDjIVLmxvYW5zLnYxLlBlbmFsdHlUeXBlUgtwZW5hbH'
    'R5VHlwZRIoCgZhbW91bnQYBCABKAsyEC5jb21tb24udjEuTW9uZXlSBmFtb3VudBIWCgZyZWFz'
    'b24YBSABKAlSBnJlYXNvbhIbCglpc193YWl2ZWQYBiABKAhSCGlzV2FpdmVkEhsKCXdhaXZlZF'
    '9ieRgHIAEoCVIId2FpdmVkQnkSIwoNd2FpdmVkX3JlYXNvbhgIIAEoCVIMd2FpdmVkUmVhc29u'
    'EjIKFWxlZGdlcl90cmFuc2FjdGlvbl9pZBgJIAEoCVITbGVkZ2VyVHJhbnNhY3Rpb25JZBIdCg'
    'phcHBsaWVkX2F0GAogASgJUglhcHBsaWVkQXQSKgoRc2NoZWR1bGVfZW50cnlfaWQYCyABKAlS'
    'D3NjaGVkdWxlRW50cnlJZBI3Cgpwcm9wZXJ0aWVzGAwgASgLMhcuZ29vZ2xlLnByb3RvYnVmLl'
    'N0cnVjdFIKcHJvcGVydGllcw==');

@$core.Deprecated('Use loanRestructureObjectDescriptor instead')
const LoanRestructureObject$json = {
  '1': 'LoanRestructureObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'loan_account_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'restructure_type', '3': 3, '4': 1, '5': 14, '6': '.loans.v1.RestructureType', '10': 'restructureType'},
    {'1': 'requested_by', '3': 4, '4': 1, '5': 9, '10': 'requestedBy'},
    {'1': 'approved_by', '3': 5, '4': 1, '5': 9, '10': 'approvedBy'},
    {'1': 'reason', '3': 6, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'old_interest_rate', '3': 7, '4': 1, '5': 9, '10': 'oldInterestRate'},
    {'1': 'new_interest_rate', '3': 8, '4': 1, '5': 9, '10': 'newInterestRate'},
    {'1': 'old_term_days', '3': 9, '4': 1, '5': 5, '10': 'oldTermDays'},
    {'1': 'new_term_days', '3': 10, '4': 1, '5': 5, '10': 'newTermDays'},
    {'1': 'waived_amount', '3': 11, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'waivedAmount'},
    {'1': 'old_schedule_id', '3': 12, '4': 1, '5': 9, '10': 'oldScheduleId'},
    {'1': 'new_schedule_id', '3': 13, '4': 1, '5': 9, '10': 'newScheduleId'},
    {'1': 'state', '3': 14, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 15, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `LoanRestructureObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRestructureObjectDescriptor = $convert.base64Decode(
    'ChVMb2FuUmVzdHJ1Y3R1cmVPYmplY3QSLgoCaWQYASABKAlCHrpIG9gBAXIWEAMYKDIQWzAtOW'
    'Etel8tXXszLDQwfVICaWQSMQoPbG9hbl9hY2NvdW50X2lkGAIgASgJQgm6SAZyBBADGChSDWxv'
    'YW5BY2NvdW50SWQSRAoQcmVzdHJ1Y3R1cmVfdHlwZRgDIAEoDjIZLmxvYW5zLnYxLlJlc3RydW'
    'N0dXJlVHlwZVIPcmVzdHJ1Y3R1cmVUeXBlEiEKDHJlcXVlc3RlZF9ieRgEIAEoCVILcmVxdWVz'
    'dGVkQnkSHwoLYXBwcm92ZWRfYnkYBSABKAlSCmFwcHJvdmVkQnkSFgoGcmVhc29uGAYgASgJUg'
    'ZyZWFzb24SKgoRb2xkX2ludGVyZXN0X3JhdGUYByABKAlSD29sZEludGVyZXN0UmF0ZRIqChFu'
    'ZXdfaW50ZXJlc3RfcmF0ZRgIIAEoCVIPbmV3SW50ZXJlc3RSYXRlEiIKDW9sZF90ZXJtX2RheX'
    'MYCSABKAVSC29sZFRlcm1EYXlzEiIKDW5ld190ZXJtX2RheXMYCiABKAVSC25ld1Rlcm1EYXlz'
    'EjUKDXdhaXZlZF9hbW91bnQYCyABKAsyEC5jb21tb24udjEuTW9uZXlSDHdhaXZlZEFtb3VudB'
    'ImCg9vbGRfc2NoZWR1bGVfaWQYDCABKAlSDW9sZFNjaGVkdWxlSWQSJgoPbmV3X3NjaGVkdWxl'
    'X2lkGA0gASgJUg1uZXdTY2hlZHVsZUlkEiYKBXN0YXRlGA4gASgOMhAuY29tbW9uLnYxLlNUQV'
    'RFUgVzdGF0ZRI3Cgpwcm9wZXJ0aWVzGA8gASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIK'
    'cHJvcGVydGllcw==');

@$core.Deprecated('Use loanStatusChangeObjectDescriptor instead')
const LoanStatusChangeObject$json = {
  '1': 'LoanStatusChangeObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'loan_account_id', '3': 2, '4': 1, '5': 9, '10': 'loanAccountId'},
    {'1': 'from_status', '3': 3, '4': 1, '5': 5, '10': 'fromStatus'},
    {'1': 'to_status', '3': 4, '4': 1, '5': 5, '10': 'toStatus'},
    {'1': 'changed_by', '3': 5, '4': 1, '5': 9, '10': 'changedBy'},
    {'1': 'reason', '3': 6, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'changed_at', '3': 7, '4': 1, '5': 9, '10': 'changedAt'},
  ],
};

/// Descriptor for `LoanStatusChangeObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanStatusChangeObjectDescriptor = $convert.base64Decode(
    'ChZMb2FuU3RhdHVzQ2hhbmdlT2JqZWN0Eg4KAmlkGAEgASgJUgJpZBImCg9sb2FuX2FjY291bn'
    'RfaWQYAiABKAlSDWxvYW5BY2NvdW50SWQSHwoLZnJvbV9zdGF0dXMYAyABKAVSCmZyb21TdGF0'
    'dXMSGwoJdG9fc3RhdHVzGAQgASgFUgh0b1N0YXR1cxIdCgpjaGFuZ2VkX2J5GAUgASgJUgljaG'
    'FuZ2VkQnkSFgoGcmVhc29uGAYgASgJUgZyZWFzb24SHQoKY2hhbmdlZF9hdBgHIAEoCVIJY2hh'
    'bmdlZEF0');

@$core.Deprecated('Use reconciliationObjectDescriptor instead')
const ReconciliationObject$json = {
  '1': 'ReconciliationObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'loan_account_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'payment_reference', '3': 3, '4': 1, '5': 9, '10': 'paymentReference'},
    {'1': 'external_reference', '3': 4, '4': 1, '5': 9, '10': 'externalReference'},
    {'1': 'amount', '3': 5, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'amount'},
    {'1': 'status', '3': 7, '4': 1, '5': 14, '6': '.loans.v1.ReconciliationStatus', '10': 'status'},
    {'1': 'matched_repayment_id', '3': 8, '4': 1, '5': 9, '10': 'matchedRepaymentId'},
    {'1': 'notes', '3': 9, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'reconciled_at', '3': 10, '4': 1, '5': 9, '10': 'reconciledAt'},
    {'1': 'reconciled_by', '3': 11, '4': 1, '5': 9, '10': 'reconciledBy'},
    {'1': 'properties', '3': 12, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `ReconciliationObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reconciliationObjectDescriptor = $convert.base64Decode(
    'ChRSZWNvbmNpbGlhdGlvbk9iamVjdBIuCgJpZBgBIAEoCUIeukgb2AEBchYQAxgoMhBbMC05YS'
    '16Xy1dezMsNDB9UgJpZBIxCg9sb2FuX2FjY291bnRfaWQYAiABKAlCCbpIBnIEEAMYKFINbG9h'
    'bkFjY291bnRJZBIrChFwYXltZW50X3JlZmVyZW5jZRgDIAEoCVIQcGF5bWVudFJlZmVyZW5jZR'
    'ItChJleHRlcm5hbF9yZWZlcmVuY2UYBCABKAlSEWV4dGVybmFsUmVmZXJlbmNlEigKBmFtb3Vu'
    'dBgFIAEoCzIQLmNvbW1vbi52MS5Nb25leVIGYW1vdW50EjYKBnN0YXR1cxgHIAEoDjIeLmxvYW'
    '5zLnYxLlJlY29uY2lsaWF0aW9uU3RhdHVzUgZzdGF0dXMSMAoUbWF0Y2hlZF9yZXBheW1lbnRf'
    'aWQYCCABKAlSEm1hdGNoZWRSZXBheW1lbnRJZBIUCgVub3RlcxgJIAEoCVIFbm90ZXMSIwoNcm'
    'Vjb25jaWxlZF9hdBgKIAEoCVIMcmVjb25jaWxlZEF0EiMKDXJlY29uY2lsZWRfYnkYCyABKAlS'
    'DHJlY29uY2lsZWRCeRI3Cgpwcm9wZXJ0aWVzGAwgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cn'
    'VjdFIKcHJvcGVydGllcw==');

@$core.Deprecated('Use loanStatementEntryDescriptor instead')
const LoanStatementEntry$json = {
  '1': 'LoanStatementEntry',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'debit', '3': 3, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'debit'},
    {'1': 'credit', '3': 4, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'credit'},
    {'1': 'balance', '3': 5, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'balance'},
    {'1': 'reference', '3': 6, '4': 1, '5': 9, '10': 'reference'},
  ],
};

/// Descriptor for `LoanStatementEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanStatementEntryDescriptor = $convert.base64Decode(
    'ChJMb2FuU3RhdGVtZW50RW50cnkSEgoEZGF0ZRgBIAEoCVIEZGF0ZRIgCgtkZXNjcmlwdGlvbh'
    'gCIAEoCVILZGVzY3JpcHRpb24SJgoFZGViaXQYAyABKAsyEC5jb21tb24udjEuTW9uZXlSBWRl'
    'Yml0EigKBmNyZWRpdBgEIAEoCzIQLmNvbW1vbi52MS5Nb25leVIGY3JlZGl0EioKB2JhbGFuY2'
    'UYBSABKAsyEC5jb21tb24udjEuTW9uZXlSB2JhbGFuY2USHAoJcmVmZXJlbmNlGAYgASgJUgly'
    'ZWZlcmVuY2U=');

@$core.Deprecated('Use loanAccountCreateRequestDescriptor instead')
const LoanAccountCreateRequest$json = {
  '1': 'LoanAccountCreateRequest',
  '2': [
    {'1': 'loan_request_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanRequestId'},
  ],
};

/// Descriptor for `LoanAccountCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanAccountCreateRequestDescriptor = $convert.base64Decode(
    'ChhMb2FuQWNjb3VudENyZWF0ZVJlcXVlc3QSMQoPbG9hbl9yZXF1ZXN0X2lkGAEgASgJQgm6SA'
    'ZyBBADGChSDWxvYW5SZXF1ZXN0SWQ=');

@$core.Deprecated('Use loanAccountCreateResponseDescriptor instead')
const LoanAccountCreateResponse$json = {
  '1': 'LoanAccountCreateResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanAccountCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanAccountCreateResponseDescriptor = $convert.base64Decode(
    'ChlMb2FuQWNjb3VudENyZWF0ZVJlc3BvbnNlEi8KBGRhdGEYASABKAsyGy5sb2Fucy52MS5Mb2'
    'FuQWNjb3VudE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use loanAccountGetRequestDescriptor instead')
const LoanAccountGetRequest$json = {
  '1': 'LoanAccountGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `LoanAccountGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanAccountGetRequestDescriptor = $convert.base64Decode(
    'ChVMb2FuQWNjb3VudEdldFJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel'
    '8tXXszLDQwfVICaWQ=');

@$core.Deprecated('Use loanAccountGetResponseDescriptor instead')
const LoanAccountGetResponse$json = {
  '1': 'LoanAccountGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanAccountGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanAccountGetResponseDescriptor = $convert.base64Decode(
    'ChZMb2FuQWNjb3VudEdldFJlc3BvbnNlEi8KBGRhdGEYASABKAsyGy5sb2Fucy52MS5Mb2FuQW'
    'Njb3VudE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use loanAccountSearchRequestDescriptor instead')
const LoanAccountSearchRequest$json = {
  '1': 'LoanAccountSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'client_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'clientId'},
    {'1': 'agent_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'agentId'},
    {'1': 'branch_id', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'branchId'},
    {'1': 'organization_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.loans.v1.LoanStatus', '10': 'status'},
    {'1': 'cursor', '3': 7, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `LoanAccountSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanAccountSearchRequestDescriptor = $convert.base64Decode(
    'ChhMb2FuQWNjb3VudFNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EikKCWNsaW'
    'VudF9pZBgCIAEoCUIMukgJ2AEBcgQQAxgoUghjbGllbnRJZBInCghhZ2VudF9pZBgDIAEoCUIM'
    'ukgJ2AEBcgQQAxgoUgdhZ2VudElkEikKCWJyYW5jaF9pZBgEIAEoCUIMukgJ2AEBcgQQAxgoUg'
    'hicmFuY2hJZBI1Cg9vcmdhbml6YXRpb25faWQYBSABKAlCDLpICdgBAXIEEAMYKFIOb3JnYW5p'
    'emF0aW9uSWQSLAoGc3RhdHVzGAYgASgOMhQubG9hbnMudjEuTG9hblN0YXR1c1IGc3RhdHVzEi'
    '0KBmN1cnNvchgHIAEoCzIVLmNvbW1vbi52MS5QYWdlQ3Vyc29yUgZjdXJzb3I=');

@$core.Deprecated('Use loanAccountSearchResponseDescriptor instead')
const LoanAccountSearchResponse$json = {
  '1': 'LoanAccountSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.loans.v1.LoanAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanAccountSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanAccountSearchResponseDescriptor = $convert.base64Decode(
    'ChlMb2FuQWNjb3VudFNlYXJjaFJlc3BvbnNlEi8KBGRhdGEYASADKAsyGy5sb2Fucy52MS5Mb2'
    'FuQWNjb3VudE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use loanBalanceGetRequestDescriptor instead')
const LoanBalanceGetRequest$json = {
  '1': 'LoanBalanceGetRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
  ],
};

/// Descriptor for `LoanBalanceGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanBalanceGetRequestDescriptor = $convert.base64Decode(
    'ChVMb2FuQmFsYW5jZUdldFJlcXVlc3QSMQoPbG9hbl9hY2NvdW50X2lkGAEgASgJQgm6SAZyBB'
    'ADGChSDWxvYW5BY2NvdW50SWQ=');

@$core.Deprecated('Use loanBalanceGetResponseDescriptor instead')
const LoanBalanceGetResponse$json = {
  '1': 'LoanBalanceGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanBalanceObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanBalanceGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanBalanceGetResponseDescriptor = $convert.base64Decode(
    'ChZMb2FuQmFsYW5jZUdldFJlc3BvbnNlEi8KBGRhdGEYASABKAsyGy5sb2Fucy52MS5Mb2FuQm'
    'FsYW5jZU9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use disbursementCreateRequestDescriptor instead')
const DisbursementCreateRequest$json = {
  '1': 'DisbursementCreateRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'channel', '3': 2, '4': 1, '5': 9, '10': 'channel'},
    {'1': 'recipient_reference', '3': 3, '4': 1, '5': 9, '10': 'recipientReference'},
    {'1': 'idempotency_key', '3': 4, '4': 1, '5': 9, '10': 'idempotencyKey'},
  ],
};

/// Descriptor for `DisbursementCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disbursementCreateRequestDescriptor = $convert.base64Decode(
    'ChlEaXNidXJzZW1lbnRDcmVhdGVSZXF1ZXN0EjEKD2xvYW5fYWNjb3VudF9pZBgBIAEoCUIJuk'
    'gGcgQQAxgoUg1sb2FuQWNjb3VudElkEhgKB2NoYW5uZWwYAiABKAlSB2NoYW5uZWwSLwoTcmVj'
    'aXBpZW50X3JlZmVyZW5jZRgDIAEoCVIScmVjaXBpZW50UmVmZXJlbmNlEicKD2lkZW1wb3Rlbm'
    'N5X2tleRgEIAEoCVIOaWRlbXBvdGVuY3lLZXk=');

@$core.Deprecated('Use disbursementCreateResponseDescriptor instead')
const DisbursementCreateResponse$json = {
  '1': 'DisbursementCreateResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.DisbursementObject', '10': 'data'},
  ],
};

/// Descriptor for `DisbursementCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disbursementCreateResponseDescriptor = $convert.base64Decode(
    'ChpEaXNidXJzZW1lbnRDcmVhdGVSZXNwb25zZRIwCgRkYXRhGAEgASgLMhwubG9hbnMudjEuRG'
    'lzYnVyc2VtZW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use disbursementGetRequestDescriptor instead')
const DisbursementGetRequest$json = {
  '1': 'DisbursementGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `DisbursementGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disbursementGetRequestDescriptor = $convert.base64Decode(
    'ChZEaXNidXJzZW1lbnRHZXRSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLX'
    'pfLV17Myw0MH1SAmlk');

@$core.Deprecated('Use disbursementGetResponseDescriptor instead')
const DisbursementGetResponse$json = {
  '1': 'DisbursementGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.DisbursementObject', '10': 'data'},
  ],
};

/// Descriptor for `DisbursementGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disbursementGetResponseDescriptor = $convert.base64Decode(
    'ChdEaXNidXJzZW1lbnRHZXRSZXNwb25zZRIwCgRkYXRhGAEgASgLMhwubG9hbnMudjEuRGlzYn'
    'Vyc2VtZW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use disbursementSearchRequestDescriptor instead')
const DisbursementSearchRequest$json = {
  '1': 'DisbursementSearchRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'status', '3': 2, '4': 1, '5': 14, '6': '.loans.v1.DisbursementStatus', '10': 'status'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `DisbursementSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disbursementSearchRequestDescriptor = $convert.base64Decode(
    'ChlEaXNidXJzZW1lbnRTZWFyY2hSZXF1ZXN0EjEKD2xvYW5fYWNjb3VudF9pZBgBIAEoCUIJuk'
    'gGcgQQAxgoUg1sb2FuQWNjb3VudElkEjQKBnN0YXR1cxgCIAEoDjIcLmxvYW5zLnYxLkRpc2J1'
    'cnNlbWVudFN0YXR1c1IGc3RhdHVzEi0KBmN1cnNvchgDIAEoCzIVLmNvbW1vbi52MS5QYWdlQ3'
    'Vyc29yUgZjdXJzb3I=');

@$core.Deprecated('Use disbursementSearchResponseDescriptor instead')
const DisbursementSearchResponse$json = {
  '1': 'DisbursementSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.loans.v1.DisbursementObject', '10': 'data'},
  ],
};

/// Descriptor for `DisbursementSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disbursementSearchResponseDescriptor = $convert.base64Decode(
    'ChpEaXNidXJzZW1lbnRTZWFyY2hSZXNwb25zZRIwCgRkYXRhGAEgAygLMhwubG9hbnMudjEuRG'
    'lzYnVyc2VtZW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use repaymentRecordRequestDescriptor instead')
const RepaymentRecordRequest$json = {
  '1': 'RepaymentRecordRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'amount', '3': 2, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'amount'},
    {'1': 'payment_reference', '3': 3, '4': 1, '5': 9, '10': 'paymentReference'},
    {'1': 'channel', '3': 4, '4': 1, '5': 9, '10': 'channel'},
    {'1': 'payer_reference', '3': 5, '4': 1, '5': 9, '10': 'payerReference'},
    {'1': 'received_at', '3': 6, '4': 1, '5': 9, '10': 'receivedAt'},
    {'1': 'idempotency_key', '3': 7, '4': 1, '5': 9, '10': 'idempotencyKey'},
  ],
};

/// Descriptor for `RepaymentRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repaymentRecordRequestDescriptor = $convert.base64Decode(
    'ChZSZXBheW1lbnRSZWNvcmRSZXF1ZXN0EjEKD2xvYW5fYWNjb3VudF9pZBgBIAEoCUIJukgGcg'
    'QQAxgoUg1sb2FuQWNjb3VudElkEigKBmFtb3VudBgCIAEoCzIQLmNvbW1vbi52MS5Nb25leVIG'
    'YW1vdW50EisKEXBheW1lbnRfcmVmZXJlbmNlGAMgASgJUhBwYXltZW50UmVmZXJlbmNlEhgKB2'
    'NoYW5uZWwYBCABKAlSB2NoYW5uZWwSJwoPcGF5ZXJfcmVmZXJlbmNlGAUgASgJUg5wYXllclJl'
    'ZmVyZW5jZRIfCgtyZWNlaXZlZF9hdBgGIAEoCVIKcmVjZWl2ZWRBdBInCg9pZGVtcG90ZW5jeV'
    '9rZXkYByABKAlSDmlkZW1wb3RlbmN5S2V5');

@$core.Deprecated('Use repaymentRecordResponseDescriptor instead')
const RepaymentRecordResponse$json = {
  '1': 'RepaymentRecordResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.RepaymentObject', '10': 'data'},
  ],
};

/// Descriptor for `RepaymentRecordResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repaymentRecordResponseDescriptor = $convert.base64Decode(
    'ChdSZXBheW1lbnRSZWNvcmRSZXNwb25zZRItCgRkYXRhGAEgASgLMhkubG9hbnMudjEuUmVwYX'
    'ltZW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use repaymentGetRequestDescriptor instead')
const RepaymentGetRequest$json = {
  '1': 'RepaymentGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `RepaymentGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repaymentGetRequestDescriptor = $convert.base64Decode(
    'ChNSZXBheW1lbnRHZXRSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV'
    '17Myw0MH1SAmlk');

@$core.Deprecated('Use repaymentGetResponseDescriptor instead')
const RepaymentGetResponse$json = {
  '1': 'RepaymentGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.RepaymentObject', '10': 'data'},
  ],
};

/// Descriptor for `RepaymentGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repaymentGetResponseDescriptor = $convert.base64Decode(
    'ChRSZXBheW1lbnRHZXRSZXNwb25zZRItCgRkYXRhGAEgASgLMhkubG9hbnMudjEuUmVwYXltZW'
    '50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use repaymentSearchRequestDescriptor instead')
const RepaymentSearchRequest$json = {
  '1': 'RepaymentSearchRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'status', '3': 2, '4': 1, '5': 14, '6': '.loans.v1.RepaymentStatus', '10': 'status'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `RepaymentSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repaymentSearchRequestDescriptor = $convert.base64Decode(
    'ChZSZXBheW1lbnRTZWFyY2hSZXF1ZXN0EjEKD2xvYW5fYWNjb3VudF9pZBgBIAEoCUIJukgGcg'
    'QQAxgoUg1sb2FuQWNjb3VudElkEjEKBnN0YXR1cxgCIAEoDjIZLmxvYW5zLnYxLlJlcGF5bWVu'
    'dFN0YXR1c1IGc3RhdHVzEi0KBmN1cnNvchgDIAEoCzIVLmNvbW1vbi52MS5QYWdlQ3Vyc29yUg'
    'ZjdXJzb3I=');

@$core.Deprecated('Use repaymentSearchResponseDescriptor instead')
const RepaymentSearchResponse$json = {
  '1': 'RepaymentSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.loans.v1.RepaymentObject', '10': 'data'},
  ],
};

/// Descriptor for `RepaymentSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repaymentSearchResponseDescriptor = $convert.base64Decode(
    'ChdSZXBheW1lbnRTZWFyY2hSZXNwb25zZRItCgRkYXRhGAEgAygLMhkubG9hbnMudjEuUmVwYX'
    'ltZW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use repaymentScheduleGetRequestDescriptor instead')
const RepaymentScheduleGetRequest$json = {
  '1': 'RepaymentScheduleGetRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
  ],
};

/// Descriptor for `RepaymentScheduleGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repaymentScheduleGetRequestDescriptor = $convert.base64Decode(
    'ChtSZXBheW1lbnRTY2hlZHVsZUdldFJlcXVlc3QSMQoPbG9hbl9hY2NvdW50X2lkGAEgASgJQg'
    'm6SAZyBBADGChSDWxvYW5BY2NvdW50SWQ=');

@$core.Deprecated('Use repaymentScheduleGetResponseDescriptor instead')
const RepaymentScheduleGetResponse$json = {
  '1': 'RepaymentScheduleGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.RepaymentScheduleObject', '10': 'data'},
  ],
};

/// Descriptor for `RepaymentScheduleGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repaymentScheduleGetResponseDescriptor = $convert.base64Decode(
    'ChxSZXBheW1lbnRTY2hlZHVsZUdldFJlc3BvbnNlEjUKBGRhdGEYASABKAsyIS5sb2Fucy52MS'
    '5SZXBheW1lbnRTY2hlZHVsZU9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use penaltySaveRequestDescriptor instead')
const PenaltySaveRequest$json = {
  '1': 'PenaltySaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.PenaltyObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `PenaltySaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List penaltySaveRequestDescriptor = $convert.base64Decode(
    'ChJQZW5hbHR5U2F2ZVJlcXVlc3QSMwoEZGF0YRgBIAEoCzIXLmxvYW5zLnYxLlBlbmFsdHlPYm'
    'plY3RCBrpIA8gBAVIEZGF0YQ==');

@$core.Deprecated('Use penaltySaveResponseDescriptor instead')
const PenaltySaveResponse$json = {
  '1': 'PenaltySaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.PenaltyObject', '10': 'data'},
  ],
};

/// Descriptor for `PenaltySaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List penaltySaveResponseDescriptor = $convert.base64Decode(
    'ChNQZW5hbHR5U2F2ZVJlc3BvbnNlEisKBGRhdGEYASABKAsyFy5sb2Fucy52MS5QZW5hbHR5T2'
    'JqZWN0UgRkYXRh');

@$core.Deprecated('Use penaltyWaiveRequestDescriptor instead')
const PenaltyWaiveRequest$json = {
  '1': 'PenaltyWaiveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `PenaltyWaiveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List penaltyWaiveRequestDescriptor = $convert.base64Decode(
    'ChNQZW5hbHR5V2FpdmVSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLXpfLV'
    '17Myw0MH1SAmlkEhYKBnJlYXNvbhgCIAEoCVIGcmVhc29u');

@$core.Deprecated('Use penaltyWaiveResponseDescriptor instead')
const PenaltyWaiveResponse$json = {
  '1': 'PenaltyWaiveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.PenaltyObject', '10': 'data'},
  ],
};

/// Descriptor for `PenaltyWaiveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List penaltyWaiveResponseDescriptor = $convert.base64Decode(
    'ChRQZW5hbHR5V2FpdmVSZXNwb25zZRIrCgRkYXRhGAEgASgLMhcubG9hbnMudjEuUGVuYWx0eU'
    '9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use penaltySearchRequestDescriptor instead')
const PenaltySearchRequest$json = {
  '1': 'PenaltySearchRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'penalty_type', '3': 2, '4': 1, '5': 14, '6': '.loans.v1.PenaltyType', '10': 'penaltyType'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `PenaltySearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List penaltySearchRequestDescriptor = $convert.base64Decode(
    'ChRQZW5hbHR5U2VhcmNoUmVxdWVzdBIxCg9sb2FuX2FjY291bnRfaWQYASABKAlCCbpIBnIEEA'
    'MYKFINbG9hbkFjY291bnRJZBI4CgxwZW5hbHR5X3R5cGUYAiABKA4yFS5sb2Fucy52MS5QZW5h'
    'bHR5VHlwZVILcGVuYWx0eVR5cGUSLQoGY3Vyc29yGAMgASgLMhUuY29tbW9uLnYxLlBhZ2VDdX'
    'Jzb3JSBmN1cnNvcg==');

@$core.Deprecated('Use penaltySearchResponseDescriptor instead')
const PenaltySearchResponse$json = {
  '1': 'PenaltySearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.loans.v1.PenaltyObject', '10': 'data'},
  ],
};

/// Descriptor for `PenaltySearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List penaltySearchResponseDescriptor = $convert.base64Decode(
    'ChVQZW5hbHR5U2VhcmNoUmVzcG9uc2USKwoEZGF0YRgBIAMoCzIXLmxvYW5zLnYxLlBlbmFsdH'
    'lPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use loanRestructureCreateRequestDescriptor instead')
const LoanRestructureCreateRequest$json = {
  '1': 'LoanRestructureCreateRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanRestructureObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `LoanRestructureCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRestructureCreateRequestDescriptor = $convert.base64Decode(
    'ChxMb2FuUmVzdHJ1Y3R1cmVDcmVhdGVSZXF1ZXN0EjsKBGRhdGEYASABKAsyHy5sb2Fucy52MS'
    '5Mb2FuUmVzdHJ1Y3R1cmVPYmplY3RCBrpIA8gBAVIEZGF0YQ==');

@$core.Deprecated('Use loanRestructureCreateResponseDescriptor instead')
const LoanRestructureCreateResponse$json = {
  '1': 'LoanRestructureCreateResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanRestructureObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanRestructureCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRestructureCreateResponseDescriptor = $convert.base64Decode(
    'Ch1Mb2FuUmVzdHJ1Y3R1cmVDcmVhdGVSZXNwb25zZRIzCgRkYXRhGAEgASgLMh8ubG9hbnMudj'
    'EuTG9hblJlc3RydWN0dXJlT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use loanRestructureApproveRequestDescriptor instead')
const LoanRestructureApproveRequest$json = {
  '1': 'LoanRestructureApproveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `LoanRestructureApproveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRestructureApproveRequestDescriptor = $convert.base64Decode(
    'Ch1Mb2FuUmVzdHJ1Y3R1cmVBcHByb3ZlUmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMh'
    'BbMC05YS16Xy1dezMsNDB9UgJpZA==');

@$core.Deprecated('Use loanRestructureApproveResponseDescriptor instead')
const LoanRestructureApproveResponse$json = {
  '1': 'LoanRestructureApproveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanRestructureObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanRestructureApproveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRestructureApproveResponseDescriptor = $convert.base64Decode(
    'Ch5Mb2FuUmVzdHJ1Y3R1cmVBcHByb3ZlUmVzcG9uc2USMwoEZGF0YRgBIAEoCzIfLmxvYW5zLn'
    'YxLkxvYW5SZXN0cnVjdHVyZU9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use loanRestructureRejectRequestDescriptor instead')
const LoanRestructureRejectRequest$json = {
  '1': 'LoanRestructureRejectRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `LoanRestructureRejectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRestructureRejectRequestDescriptor = $convert.base64Decode(
    'ChxMb2FuUmVzdHJ1Y3R1cmVSZWplY3RSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEF'
    'swLTlhLXpfLV17Myw0MH1SAmlkEhYKBnJlYXNvbhgCIAEoCVIGcmVhc29u');

@$core.Deprecated('Use loanRestructureRejectResponseDescriptor instead')
const LoanRestructureRejectResponse$json = {
  '1': 'LoanRestructureRejectResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanRestructureObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanRestructureRejectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRestructureRejectResponseDescriptor = $convert.base64Decode(
    'Ch1Mb2FuUmVzdHJ1Y3R1cmVSZWplY3RSZXNwb25zZRIzCgRkYXRhGAEgASgLMh8ubG9hbnMudj'
    'EuTG9hblJlc3RydWN0dXJlT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use loanRestructureSearchRequestDescriptor instead')
const LoanRestructureSearchRequest$json = {
  '1': 'LoanRestructureSearchRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'cursor', '3': 2, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `LoanRestructureSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRestructureSearchRequestDescriptor = $convert.base64Decode(
    'ChxMb2FuUmVzdHJ1Y3R1cmVTZWFyY2hSZXF1ZXN0EjEKD2xvYW5fYWNjb3VudF9pZBgBIAEoCU'
    'IJukgGcgQQAxgoUg1sb2FuQWNjb3VudElkEi0KBmN1cnNvchgCIAEoCzIVLmNvbW1vbi52MS5Q'
    'YWdlQ3Vyc29yUgZjdXJzb3I=');

@$core.Deprecated('Use loanRestructureSearchResponseDescriptor instead')
const LoanRestructureSearchResponse$json = {
  '1': 'LoanRestructureSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.loans.v1.LoanRestructureObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanRestructureSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRestructureSearchResponseDescriptor = $convert.base64Decode(
    'Ch1Mb2FuUmVzdHJ1Y3R1cmVTZWFyY2hSZXNwb25zZRIzCgRkYXRhGAEgAygLMh8ubG9hbnMudj'
    'EuTG9hblJlc3RydWN0dXJlT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use loanStatementRequestDescriptor instead')
const LoanStatementRequest$json = {
  '1': 'LoanStatementRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'from_date', '3': 2, '4': 1, '5': 9, '10': 'fromDate'},
    {'1': 'to_date', '3': 3, '4': 1, '5': 9, '10': 'toDate'},
  ],
};

/// Descriptor for `LoanStatementRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanStatementRequestDescriptor = $convert.base64Decode(
    'ChRMb2FuU3RhdGVtZW50UmVxdWVzdBIxCg9sb2FuX2FjY291bnRfaWQYASABKAlCCbpIBnIEEA'
    'MYKFINbG9hbkFjY291bnRJZBIbCglmcm9tX2RhdGUYAiABKAlSCGZyb21EYXRlEhcKB3RvX2Rh'
    'dGUYAyABKAlSBnRvRGF0ZQ==');

@$core.Deprecated('Use loanStatementResponseDescriptor instead')
const LoanStatementResponse$json = {
  '1': 'LoanStatementResponse',
  '2': [
    {'1': 'loan', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanAccountObject', '10': 'loan'},
    {'1': 'balance', '3': 2, '4': 1, '5': 11, '6': '.loans.v1.LoanBalanceObject', '10': 'balance'},
    {'1': 'entries', '3': 3, '4': 3, '5': 11, '6': '.loans.v1.LoanStatementEntry', '10': 'entries'},
  ],
};

/// Descriptor for `LoanStatementResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanStatementResponseDescriptor = $convert.base64Decode(
    'ChVMb2FuU3RhdGVtZW50UmVzcG9uc2USLwoEbG9hbhgBIAEoCzIbLmxvYW5zLnYxLkxvYW5BY2'
    'NvdW50T2JqZWN0UgRsb2FuEjUKB2JhbGFuY2UYAiABKAsyGy5sb2Fucy52MS5Mb2FuQmFsYW5j'
    'ZU9iamVjdFIHYmFsYW5jZRI2CgdlbnRyaWVzGAMgAygLMhwubG9hbnMudjEuTG9hblN0YXRlbW'
    'VudEVudHJ5UgdlbnRyaWVz');

@$core.Deprecated('Use reconciliationSaveRequestDescriptor instead')
const ReconciliationSaveRequest$json = {
  '1': 'ReconciliationSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.ReconciliationObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `ReconciliationSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reconciliationSaveRequestDescriptor = $convert.base64Decode(
    'ChlSZWNvbmNpbGlhdGlvblNhdmVSZXF1ZXN0EjoKBGRhdGEYASABKAsyHi5sb2Fucy52MS5SZW'
    'NvbmNpbGlhdGlvbk9iamVjdEIGukgDyAEBUgRkYXRh');

@$core.Deprecated('Use reconciliationSaveResponseDescriptor instead')
const ReconciliationSaveResponse$json = {
  '1': 'ReconciliationSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.ReconciliationObject', '10': 'data'},
  ],
};

/// Descriptor for `ReconciliationSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reconciliationSaveResponseDescriptor = $convert.base64Decode(
    'ChpSZWNvbmNpbGlhdGlvblNhdmVSZXNwb25zZRIyCgRkYXRhGAEgASgLMh4ubG9hbnMudjEuUm'
    'Vjb25jaWxpYXRpb25PYmplY3RSBGRhdGE=');

@$core.Deprecated('Use reconciliationSearchRequestDescriptor instead')
const ReconciliationSearchRequest$json = {
  '1': 'ReconciliationSearchRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'status', '3': 2, '4': 1, '5': 14, '6': '.loans.v1.ReconciliationStatus', '10': 'status'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `ReconciliationSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reconciliationSearchRequestDescriptor = $convert.base64Decode(
    'ChtSZWNvbmNpbGlhdGlvblNlYXJjaFJlcXVlc3QSNAoPbG9hbl9hY2NvdW50X2lkGAEgASgJQg'
    'y6SAnYAQFyBBADGChSDWxvYW5BY2NvdW50SWQSNgoGc3RhdHVzGAIgASgOMh4ubG9hbnMudjEu'
    'UmVjb25jaWxpYXRpb25TdGF0dXNSBnN0YXR1cxItCgZjdXJzb3IYAyABKAsyFS5jb21tb24udj'
    'EuUGFnZUN1cnNvclIGY3Vyc29y');

@$core.Deprecated('Use reconciliationSearchResponseDescriptor instead')
const ReconciliationSearchResponse$json = {
  '1': 'ReconciliationSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.loans.v1.ReconciliationObject', '10': 'data'},
  ],
};

/// Descriptor for `ReconciliationSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reconciliationSearchResponseDescriptor = $convert.base64Decode(
    'ChxSZWNvbmNpbGlhdGlvblNlYXJjaFJlc3BvbnNlEjIKBGRhdGEYASADKAsyHi5sb2Fucy52MS'
    '5SZWNvbmNpbGlhdGlvbk9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use initiateCollectionRequestDescriptor instead')
const InitiateCollectionRequest$json = {
  '1': 'InitiateCollectionRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'amount', '3': 2, '4': 1, '5': 9, '10': 'amount'},
    {'1': 'phone_number', '3': 3, '4': 1, '5': 9, '10': 'phoneNumber'},
    {'1': 'idempotency_key', '3': 4, '4': 1, '5': 9, '10': 'idempotencyKey'},
  ],
};

/// Descriptor for `InitiateCollectionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initiateCollectionRequestDescriptor = $convert.base64Decode(
    'ChlJbml0aWF0ZUNvbGxlY3Rpb25SZXF1ZXN0EjEKD2xvYW5fYWNjb3VudF9pZBgBIAEoCUIJuk'
    'gGcgQQAxgoUg1sb2FuQWNjb3VudElkEhYKBmFtb3VudBgCIAEoCVIGYW1vdW50EiEKDHBob25l'
    'X251bWJlchgDIAEoCVILcGhvbmVOdW1iZXISJwoPaWRlbXBvdGVuY3lfa2V5GAQgASgJUg5pZG'
    'VtcG90ZW5jeUtleQ==');

@$core.Deprecated('Use initiateCollectionResponseDescriptor instead')
const InitiateCollectionResponse$json = {
  '1': 'InitiateCollectionResponse',
  '2': [
    {'1': 'payment_prompt_id', '3': 1, '4': 1, '5': 9, '10': 'paymentPromptId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `InitiateCollectionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initiateCollectionResponseDescriptor = $convert.base64Decode(
    'ChpJbml0aWF0ZUNvbGxlY3Rpb25SZXNwb25zZRIqChFwYXltZW50X3Byb21wdF9pZBgBIAEoCV'
    'IPcGF5bWVudFByb21wdElkEhYKBnN0YXR1cxgCIAEoCVIGc3RhdHVz');

@$core.Deprecated('Use loanStatusChangeSearchRequestDescriptor instead')
const LoanStatusChangeSearchRequest$json = {
  '1': 'LoanStatusChangeSearchRequest',
  '2': [
    {'1': 'loan_account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'loanAccountId'},
    {'1': 'cursor', '3': 2, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `LoanStatusChangeSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanStatusChangeSearchRequestDescriptor = $convert.base64Decode(
    'Ch1Mb2FuU3RhdHVzQ2hhbmdlU2VhcmNoUmVxdWVzdBIxCg9sb2FuX2FjY291bnRfaWQYASABKA'
    'lCCbpIBnIEEAMYKFINbG9hbkFjY291bnRJZBItCgZjdXJzb3IYAiABKAsyFS5jb21tb24udjEu'
    'UGFnZUN1cnNvclIGY3Vyc29y');

@$core.Deprecated('Use loanStatusChangeSearchResponseDescriptor instead')
const LoanStatusChangeSearchResponse$json = {
  '1': 'LoanStatusChangeSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.loans.v1.LoanStatusChangeObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanStatusChangeSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanStatusChangeSearchResponseDescriptor = $convert.base64Decode(
    'Ch5Mb2FuU3RhdHVzQ2hhbmdlU2VhcmNoUmVzcG9uc2USNAoEZGF0YRgBIAMoCzIgLmxvYW5zLn'
    'YxLkxvYW5TdGF0dXNDaGFuZ2VPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use loanProductSaveRequestDescriptor instead')
const LoanProductSaveRequest$json = {
  '1': 'LoanProductSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanProductObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `LoanProductSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanProductSaveRequestDescriptor = $convert.base64Decode(
    'ChZMb2FuUHJvZHVjdFNhdmVSZXF1ZXN0EjcKBGRhdGEYASABKAsyGy5sb2Fucy52MS5Mb2FuUH'
    'JvZHVjdE9iamVjdEIGukgDyAEBUgRkYXRh');

@$core.Deprecated('Use loanProductSaveResponseDescriptor instead')
const LoanProductSaveResponse$json = {
  '1': 'LoanProductSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanProductObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanProductSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanProductSaveResponseDescriptor = $convert.base64Decode(
    'ChdMb2FuUHJvZHVjdFNhdmVSZXNwb25zZRIvCgRkYXRhGAEgASgLMhsubG9hbnMudjEuTG9hbl'
    'Byb2R1Y3RPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use loanProductGetRequestDescriptor instead')
const LoanProductGetRequest$json = {
  '1': 'LoanProductGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `LoanProductGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanProductGetRequestDescriptor = $convert.base64Decode(
    'ChVMb2FuUHJvZHVjdEdldFJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel'
    '8tXXszLDQwfVICaWQ=');

@$core.Deprecated('Use loanProductGetResponseDescriptor instead')
const LoanProductGetResponse$json = {
  '1': 'LoanProductGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanProductObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanProductGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanProductGetResponseDescriptor = $convert.base64Decode(
    'ChZMb2FuUHJvZHVjdEdldFJlc3BvbnNlEi8KBGRhdGEYASABKAsyGy5sb2Fucy52MS5Mb2FuUH'
    'JvZHVjdE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use loanProductSearchRequestDescriptor instead')
const LoanProductSearchRequest$json = {
  '1': 'LoanProductSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'product_type', '3': 3, '4': 1, '5': 14, '6': '.loans.v1.LoanProductType', '10': 'productType'},
    {'1': 'cursor', '3': 4, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `LoanProductSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanProductSearchRequestDescriptor = $convert.base64Decode(
    'ChhMb2FuUHJvZHVjdFNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EjUKD29yZ2'
    'FuaXphdGlvbl9pZBgCIAEoCUIMukgJ2AEBcgQQAxgoUg5vcmdhbml6YXRpb25JZBI8Cgxwcm9k'
    'dWN0X3R5cGUYAyABKA4yGS5sb2Fucy52MS5Mb2FuUHJvZHVjdFR5cGVSC3Byb2R1Y3RUeXBlEi'
    '0KBmN1cnNvchgEIAEoCzIVLmNvbW1vbi52MS5QYWdlQ3Vyc29yUgZjdXJzb3I=');

@$core.Deprecated('Use loanProductSearchResponseDescriptor instead')
const LoanProductSearchResponse$json = {
  '1': 'LoanProductSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.loans.v1.LoanProductObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanProductSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanProductSearchResponseDescriptor = $convert.base64Decode(
    'ChlMb2FuUHJvZHVjdFNlYXJjaFJlc3BvbnNlEi8KBGRhdGEYASADKAsyGy5sb2Fucy52MS5Mb2'
    'FuUHJvZHVjdE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use loanRequestSaveRequestDescriptor instead')
const LoanRequestSaveRequest$json = {
  '1': 'LoanRequestSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanRequestObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `LoanRequestSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestSaveRequestDescriptor = $convert.base64Decode(
    'ChZMb2FuUmVxdWVzdFNhdmVSZXF1ZXN0EjcKBGRhdGEYASABKAsyGy5sb2Fucy52MS5Mb2FuUm'
    'VxdWVzdE9iamVjdEIGukgDyAEBUgRkYXRh');

@$core.Deprecated('Use loanRequestSaveResponseDescriptor instead')
const LoanRequestSaveResponse$json = {
  '1': 'LoanRequestSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanRequestObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanRequestSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestSaveResponseDescriptor = $convert.base64Decode(
    'ChdMb2FuUmVxdWVzdFNhdmVSZXNwb25zZRIvCgRkYXRhGAEgASgLMhsubG9hbnMudjEuTG9hbl'
    'JlcXVlc3RPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use loanRequestGetRequestDescriptor instead')
const LoanRequestGetRequest$json = {
  '1': 'LoanRequestGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `LoanRequestGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestGetRequestDescriptor = $convert.base64Decode(
    'ChVMb2FuUmVxdWVzdEdldFJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel'
    '8tXXszLDQwfVICaWQ=');

@$core.Deprecated('Use loanRequestGetResponseDescriptor instead')
const LoanRequestGetResponse$json = {
  '1': 'LoanRequestGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanRequestObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanRequestGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestGetResponseDescriptor = $convert.base64Decode(
    'ChZMb2FuUmVxdWVzdEdldFJlc3BvbnNlEi8KBGRhdGEYASABKAsyGy5sb2Fucy52MS5Mb2FuUm'
    'VxdWVzdE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use loanRequestSearchRequestDescriptor instead')
const LoanRequestSearchRequest$json = {
  '1': 'LoanRequestSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'client_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'clientId'},
    {'1': 'agent_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'agentId'},
    {'1': 'branch_id', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'branchId'},
    {'1': 'organization_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.loans.v1.LoanRequestStatus', '10': 'status'},
    {'1': 'source_service', '3': 7, '4': 1, '5': 9, '10': 'sourceService'},
    {'1': 'cursor', '3': 8, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `LoanRequestSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestSearchRequestDescriptor = $convert.base64Decode(
    'ChhMb2FuUmVxdWVzdFNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EikKCWNsaW'
    'VudF9pZBgCIAEoCUIMukgJ2AEBcgQQAxgoUghjbGllbnRJZBIlCghhZ2VudF9pZBgDIAEoCUIK'
    'ukgH2AEBcgIYKFIHYWdlbnRJZBInCglicmFuY2hfaWQYBCABKAlCCrpIB9gBAXICGChSCGJyYW'
    '5jaElkEjMKD29yZ2FuaXphdGlvbl9pZBgFIAEoCUIKukgH2AEBcgIYKFIOb3JnYW5pemF0aW9u'
    'SWQSMwoGc3RhdHVzGAYgASgOMhsubG9hbnMudjEuTG9hblJlcXVlc3RTdGF0dXNSBnN0YXR1cx'
    'IlCg5zb3VyY2Vfc2VydmljZRgHIAEoCVINc291cmNlU2VydmljZRItCgZjdXJzb3IYCCABKAsy'
    'FS5jb21tb24udjEuUGFnZUN1cnNvclIGY3Vyc29y');

@$core.Deprecated('Use loanRequestSearchResponseDescriptor instead')
const LoanRequestSearchResponse$json = {
  '1': 'LoanRequestSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.loans.v1.LoanRequestObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanRequestSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestSearchResponseDescriptor = $convert.base64Decode(
    'ChlMb2FuUmVxdWVzdFNlYXJjaFJlc3BvbnNlEi8KBGRhdGEYASADKAsyGy5sb2Fucy52MS5Mb2'
    'FuUmVxdWVzdE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use loanRequestApproveRequestDescriptor instead')
const LoanRequestApproveRequest$json = {
  '1': 'LoanRequestApproveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `LoanRequestApproveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestApproveRequestDescriptor = $convert.base64Decode(
    'ChlMb2FuUmVxdWVzdEFwcHJvdmVSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLT'
    'lhLXpfLV17Myw0MH1SAmlk');

@$core.Deprecated('Use loanRequestApproveResponseDescriptor instead')
const LoanRequestApproveResponse$json = {
  '1': 'LoanRequestApproveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanRequestObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanRequestApproveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestApproveResponseDescriptor = $convert.base64Decode(
    'ChpMb2FuUmVxdWVzdEFwcHJvdmVSZXNwb25zZRIvCgRkYXRhGAEgASgLMhsubG9hbnMudjEuTG'
    '9hblJlcXVlc3RPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use loanRequestRejectRequestDescriptor instead')
const LoanRequestRejectRequest$json = {
  '1': 'LoanRequestRejectRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `LoanRequestRejectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestRejectRequestDescriptor = $convert.base64Decode(
    'ChhMb2FuUmVxdWVzdFJlamVjdFJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOW'
    'Etel8tXXszLDQwfVICaWQSFgoGcmVhc29uGAIgASgJUgZyZWFzb24=');

@$core.Deprecated('Use loanRequestRejectResponseDescriptor instead')
const LoanRequestRejectResponse$json = {
  '1': 'LoanRequestRejectResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanRequestObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanRequestRejectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestRejectResponseDescriptor = $convert.base64Decode(
    'ChlMb2FuUmVxdWVzdFJlamVjdFJlc3BvbnNlEi8KBGRhdGEYASABKAsyGy5sb2Fucy52MS5Mb2'
    'FuUmVxdWVzdE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use loanRequestCancelRequestDescriptor instead')
const LoanRequestCancelRequest$json = {
  '1': 'LoanRequestCancelRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `LoanRequestCancelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestCancelRequestDescriptor = $convert.base64Decode(
    'ChhMb2FuUmVxdWVzdENhbmNlbFJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOW'
    'Etel8tXXszLDQwfVICaWQSFgoGcmVhc29uGAIgASgJUgZyZWFzb24=');

@$core.Deprecated('Use loanRequestCancelResponseDescriptor instead')
const LoanRequestCancelResponse$json = {
  '1': 'LoanRequestCancelResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.LoanRequestObject', '10': 'data'},
  ],
};

/// Descriptor for `LoanRequestCancelResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loanRequestCancelResponseDescriptor = $convert.base64Decode(
    'ChlMb2FuUmVxdWVzdENhbmNlbFJlc3BvbnNlEi8KBGRhdGEYASABKAsyGy5sb2Fucy52MS5Mb2'
    'FuUmVxdWVzdE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use clientProductAccessSaveRequestDescriptor instead')
const ClientProductAccessSaveRequest$json = {
  '1': 'ClientProductAccessSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.ClientProductAccessObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `ClientProductAccessSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientProductAccessSaveRequestDescriptor = $convert.base64Decode(
    'Ch5DbGllbnRQcm9kdWN0QWNjZXNzU2F2ZVJlcXVlc3QSPwoEZGF0YRgBIAEoCzIjLmxvYW5zLn'
    'YxLkNsaWVudFByb2R1Y3RBY2Nlc3NPYmplY3RCBrpIA8gBAVIEZGF0YQ==');

@$core.Deprecated('Use clientProductAccessSaveResponseDescriptor instead')
const ClientProductAccessSaveResponse$json = {
  '1': 'ClientProductAccessSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.ClientProductAccessObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientProductAccessSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientProductAccessSaveResponseDescriptor = $convert.base64Decode(
    'Ch9DbGllbnRQcm9kdWN0QWNjZXNzU2F2ZVJlc3BvbnNlEjcKBGRhdGEYASABKAsyIy5sb2Fucy'
    '52MS5DbGllbnRQcm9kdWN0QWNjZXNzT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use clientProductAccessGetRequestDescriptor instead')
const ClientProductAccessGetRequest$json = {
  '1': 'ClientProductAccessGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `ClientProductAccessGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientProductAccessGetRequestDescriptor = $convert.base64Decode(
    'Ch1DbGllbnRQcm9kdWN0QWNjZXNzR2V0UmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMh'
    'BbMC05YS16Xy1dezMsNDB9UgJpZA==');

@$core.Deprecated('Use clientProductAccessGetResponseDescriptor instead')
const ClientProductAccessGetResponse$json = {
  '1': 'ClientProductAccessGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.ClientProductAccessObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientProductAccessGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientProductAccessGetResponseDescriptor = $convert.base64Decode(
    'Ch5DbGllbnRQcm9kdWN0QWNjZXNzR2V0UmVzcG9uc2USNwoEZGF0YRgBIAEoCzIjLmxvYW5zLn'
    'YxLkNsaWVudFByb2R1Y3RBY2Nlc3NPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use clientProductAccessSearchRequestDescriptor instead')
const ClientProductAccessSearchRequest$json = {
  '1': 'ClientProductAccessSearchRequest',
  '2': [
    {'1': 'client_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'clientId'},
    {'1': 'product_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'productId'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `ClientProductAccessSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientProductAccessSearchRequestDescriptor = $convert.base64Decode(
    'CiBDbGllbnRQcm9kdWN0QWNjZXNzU2VhcmNoUmVxdWVzdBInCgljbGllbnRfaWQYASABKAlCCr'
    'pIB9gBAXICGChSCGNsaWVudElkEikKCnByb2R1Y3RfaWQYAiABKAlCCrpIB9gBAXICGChSCXBy'
    'b2R1Y3RJZBItCgZjdXJzb3IYAyABKAsyFS5jb21tb24udjEuUGFnZUN1cnNvclIGY3Vyc29y');

@$core.Deprecated('Use clientProductAccessSearchResponseDescriptor instead')
const ClientProductAccessSearchResponse$json = {
  '1': 'ClientProductAccessSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.loans.v1.ClientProductAccessObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientProductAccessSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientProductAccessSearchResponseDescriptor = $convert.base64Decode(
    'CiFDbGllbnRQcm9kdWN0QWNjZXNzU2VhcmNoUmVzcG9uc2USNwoEZGF0YRgBIAMoCzIjLmxvYW'
    '5zLnYxLkNsaWVudFByb2R1Y3RBY2Nlc3NPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use portfolioSummaryDescriptor instead')
const PortfolioSummary$json = {
  '1': 'PortfolioSummary',
  '2': [
    {'1': 'total_loans', '3': 1, '4': 1, '5': 5, '10': 'totalLoans'},
    {'1': 'active_loans', '3': 2, '4': 1, '5': 5, '10': 'activeLoans'},
    {'1': 'delinquent_loans', '3': 3, '4': 1, '5': 5, '10': 'delinquentLoans'},
    {'1': 'default_loans', '3': 4, '4': 1, '5': 5, '10': 'defaultLoans'},
    {'1': 'paid_off_loans', '3': 5, '4': 1, '5': 5, '10': 'paidOffLoans'},
    {'1': 'written_off_loans', '3': 6, '4': 1, '5': 5, '10': 'writtenOffLoans'},
    {'1': 'total_disbursed', '3': 7, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalDisbursed'},
    {'1': 'total_outstanding', '3': 8, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalOutstanding'},
    {'1': 'total_collected', '3': 9, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'totalCollected'},
    {'1': 'principal_outstanding', '3': 10, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'principalOutstanding'},
    {'1': 'interest_outstanding', '3': 11, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'interestOutstanding'},
    {'1': 'fees_outstanding', '3': 12, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'feesOutstanding'},
    {'1': 'penalties_outstanding', '3': 13, '4': 1, '5': 11, '6': '.common.v1.Money', '10': 'penaltiesOutstanding'},
    {'1': 'currency_code', '3': 14, '4': 1, '5': 9, '10': 'currencyCode'},
    {'1': 'collection_rate', '3': 15, '4': 1, '5': 9, '10': 'collectionRate'},
    {'1': 'par_30', '3': 16, '4': 1, '5': 9, '10': 'par30'},
  ],
};

/// Descriptor for `PortfolioSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List portfolioSummaryDescriptor = $convert.base64Decode(
    'ChBQb3J0Zm9saW9TdW1tYXJ5Eh8KC3RvdGFsX2xvYW5zGAEgASgFUgp0b3RhbExvYW5zEiEKDG'
    'FjdGl2ZV9sb2FucxgCIAEoBVILYWN0aXZlTG9hbnMSKQoQZGVsaW5xdWVudF9sb2FucxgDIAEo'
    'BVIPZGVsaW5xdWVudExvYW5zEiMKDWRlZmF1bHRfbG9hbnMYBCABKAVSDGRlZmF1bHRMb2Fucx'
    'IkCg5wYWlkX29mZl9sb2FucxgFIAEoBVIMcGFpZE9mZkxvYW5zEioKEXdyaXR0ZW5fb2ZmX2xv'
    'YW5zGAYgASgFUg93cml0dGVuT2ZmTG9hbnMSOQoPdG90YWxfZGlzYnVyc2VkGAcgASgLMhAuY2'
    '9tbW9uLnYxLk1vbmV5Ug50b3RhbERpc2J1cnNlZBI9ChF0b3RhbF9vdXRzdGFuZGluZxgIIAEo'
    'CzIQLmNvbW1vbi52MS5Nb25leVIQdG90YWxPdXRzdGFuZGluZxI5Cg90b3RhbF9jb2xsZWN0ZW'
    'QYCSABKAsyEC5jb21tb24udjEuTW9uZXlSDnRvdGFsQ29sbGVjdGVkEkUKFXByaW5jaXBhbF9v'
    'dXRzdGFuZGluZxgKIAEoCzIQLmNvbW1vbi52MS5Nb25leVIUcHJpbmNpcGFsT3V0c3RhbmRpbm'
    'cSQwoUaW50ZXJlc3Rfb3V0c3RhbmRpbmcYCyABKAsyEC5jb21tb24udjEuTW9uZXlSE2ludGVy'
    'ZXN0T3V0c3RhbmRpbmcSOwoQZmVlc19vdXRzdGFuZGluZxgMIAEoCzIQLmNvbW1vbi52MS5Nb2'
    '5leVIPZmVlc091dHN0YW5kaW5nEkUKFXBlbmFsdGllc19vdXRzdGFuZGluZxgNIAEoCzIQLmNv'
    'bW1vbi52MS5Nb25leVIUcGVuYWx0aWVzT3V0c3RhbmRpbmcSIwoNY3VycmVuY3lfY29kZRgOIA'
    'EoCVIMY3VycmVuY3lDb2RlEicKD2NvbGxlY3Rpb25fcmF0ZRgPIAEoCVIOY29sbGVjdGlvblJh'
    'dGUSFQoGcGFyXzMwGBAgASgJUgVwYXIzMA==');

@$core.Deprecated('Use portfolioSummaryRequestDescriptor instead')
const PortfolioSummaryRequest$json = {
  '1': 'PortfolioSummaryRequest',
  '2': [
    {'1': 'organization_id', '3': 1, '4': 1, '5': 9, '10': 'organizationId'},
    {'1': 'branch_id', '3': 2, '4': 1, '5': 9, '10': 'branchId'},
    {'1': 'agent_id', '3': 3, '4': 1, '5': 9, '10': 'agentId'},
    {'1': 'product_id', '3': 4, '4': 1, '5': 9, '10': 'productId'},
    {'1': 'client_id', '3': 5, '4': 1, '5': 9, '10': 'clientId'},
    {'1': 'currency_code', '3': 6, '4': 1, '5': 9, '10': 'currencyCode'},
  ],
};

/// Descriptor for `PortfolioSummaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List portfolioSummaryRequestDescriptor = $convert.base64Decode(
    'ChdQb3J0Zm9saW9TdW1tYXJ5UmVxdWVzdBInCg9vcmdhbml6YXRpb25faWQYASABKAlSDm9yZ2'
    'FuaXphdGlvbklkEhsKCWJyYW5jaF9pZBgCIAEoCVIIYnJhbmNoSWQSGQoIYWdlbnRfaWQYAyAB'
    'KAlSB2FnZW50SWQSHQoKcHJvZHVjdF9pZBgEIAEoCVIJcHJvZHVjdElkEhsKCWNsaWVudF9pZB'
    'gFIAEoCVIIY2xpZW50SWQSIwoNY3VycmVuY3lfY29kZRgGIAEoCVIMY3VycmVuY3lDb2Rl');

@$core.Deprecated('Use portfolioSummaryResponseDescriptor instead')
const PortfolioSummaryResponse$json = {
  '1': 'PortfolioSummaryResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.loans.v1.PortfolioSummary', '10': 'data'},
  ],
};

/// Descriptor for `PortfolioSummaryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List portfolioSummaryResponseDescriptor = $convert.base64Decode(
    'ChhQb3J0Zm9saW9TdW1tYXJ5UmVzcG9uc2USLgoEZGF0YRgBIAEoCzIaLmxvYW5zLnYxLlBvcn'
    'Rmb2xpb1N1bW1hcnlSBGRhdGE=');

@$core.Deprecated('Use portfolioExportRequestDescriptor instead')
const PortfolioExportRequest$json = {
  '1': 'PortfolioExportRequest',
  '2': [
    {'1': 'organization_id', '3': 1, '4': 1, '5': 9, '10': 'organizationId'},
    {'1': 'branch_id', '3': 2, '4': 1, '5': 9, '10': 'branchId'},
    {'1': 'agent_id', '3': 3, '4': 1, '5': 9, '10': 'agentId'},
    {'1': 'product_id', '3': 4, '4': 1, '5': 9, '10': 'productId'},
    {'1': 'client_id', '3': 5, '4': 1, '5': 9, '10': 'clientId'},
    {'1': 'currency_code', '3': 6, '4': 1, '5': 9, '10': 'currencyCode'},
    {'1': 'format', '3': 7, '4': 1, '5': 9, '10': 'format'},
  ],
};

/// Descriptor for `PortfolioExportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List portfolioExportRequestDescriptor = $convert.base64Decode(
    'ChZQb3J0Zm9saW9FeHBvcnRSZXF1ZXN0EicKD29yZ2FuaXphdGlvbl9pZBgBIAEoCVIOb3JnYW'
    '5pemF0aW9uSWQSGwoJYnJhbmNoX2lkGAIgASgJUghicmFuY2hJZBIZCghhZ2VudF9pZBgDIAEo'
    'CVIHYWdlbnRJZBIdCgpwcm9kdWN0X2lkGAQgASgJUglwcm9kdWN0SWQSGwoJY2xpZW50X2lkGA'
    'UgASgJUghjbGllbnRJZBIjCg1jdXJyZW5jeV9jb2RlGAYgASgJUgxjdXJyZW5jeUNvZGUSFgoG'
    'Zm9ybWF0GAcgASgJUgZmb3JtYXQ=');

@$core.Deprecated('Use portfolioExportResponseDescriptor instead')
const PortfolioExportResponse$json = {
  '1': 'PortfolioExportResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 12, '10': 'data'},
    {'1': 'filename', '3': 2, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'content_type', '3': 3, '4': 1, '5': 9, '10': 'contentType'},
  ],
};

/// Descriptor for `PortfolioExportResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List portfolioExportResponseDescriptor = $convert.base64Decode(
    'ChdQb3J0Zm9saW9FeHBvcnRSZXNwb25zZRISCgRkYXRhGAEgASgMUgRkYXRhEhoKCGZpbGVuYW'
    '1lGAIgASgJUghmaWxlbmFtZRIhCgxjb250ZW50X3R5cGUYAyABKAlSC2NvbnRlbnRUeXBl');

const $core.Map<$core.String, $core.dynamic> LoanManagementServiceBase$json = {
  '1': 'LoanManagementService',
  '2': [
    {'1': 'LoanProductSave', '2': '.loans.v1.LoanProductSaveRequest', '3': '.loans.v1.LoanProductSaveResponse', '4': {}},
    {
      '1': 'LoanProductGet',
      '2': '.loans.v1.LoanProductGetRequest',
      '3': '.loans.v1.LoanProductGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'LoanProductSearch',
      '2': '.loans.v1.LoanProductSearchRequest',
      '3': '.loans.v1.LoanProductSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'LoanRequestSave', '2': '.loans.v1.LoanRequestSaveRequest', '3': '.loans.v1.LoanRequestSaveResponse', '4': {}},
    {
      '1': 'LoanRequestGet',
      '2': '.loans.v1.LoanRequestGetRequest',
      '3': '.loans.v1.LoanRequestGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'LoanRequestSearch',
      '2': '.loans.v1.LoanRequestSearchRequest',
      '3': '.loans.v1.LoanRequestSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'LoanRequestApprove', '2': '.loans.v1.LoanRequestApproveRequest', '3': '.loans.v1.LoanRequestApproveResponse', '4': {}},
    {'1': 'LoanRequestReject', '2': '.loans.v1.LoanRequestRejectRequest', '3': '.loans.v1.LoanRequestRejectResponse', '4': {}},
    {'1': 'LoanRequestCancel', '2': '.loans.v1.LoanRequestCancelRequest', '3': '.loans.v1.LoanRequestCancelResponse', '4': {}},
    {'1': 'ClientProductAccessSave', '2': '.loans.v1.ClientProductAccessSaveRequest', '3': '.loans.v1.ClientProductAccessSaveResponse', '4': {}},
    {
      '1': 'ClientProductAccessGet',
      '2': '.loans.v1.ClientProductAccessGetRequest',
      '3': '.loans.v1.ClientProductAccessGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'ClientProductAccessSearch',
      '2': '.loans.v1.ClientProductAccessSearchRequest',
      '3': '.loans.v1.ClientProductAccessSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'LoanAccountCreate', '2': '.loans.v1.LoanAccountCreateRequest', '3': '.loans.v1.LoanAccountCreateResponse', '4': {}},
    {
      '1': 'LoanAccountGet',
      '2': '.loans.v1.LoanAccountGetRequest',
      '3': '.loans.v1.LoanAccountGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'LoanAccountSearch',
      '2': '.loans.v1.LoanAccountSearchRequest',
      '3': '.loans.v1.LoanAccountSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {
      '1': 'LoanBalanceGet',
      '2': '.loans.v1.LoanBalanceGetRequest',
      '3': '.loans.v1.LoanBalanceGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'LoanStatement',
      '2': '.loans.v1.LoanStatementRequest',
      '3': '.loans.v1.LoanStatementResponse',
      '4': {'34': 1},
    },
    {'1': 'DisbursementCreate', '2': '.loans.v1.DisbursementCreateRequest', '3': '.loans.v1.DisbursementCreateResponse', '4': {}},
    {
      '1': 'DisbursementGet',
      '2': '.loans.v1.DisbursementGetRequest',
      '3': '.loans.v1.DisbursementGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'DisbursementSearch',
      '2': '.loans.v1.DisbursementSearchRequest',
      '3': '.loans.v1.DisbursementSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'RepaymentRecord', '2': '.loans.v1.RepaymentRecordRequest', '3': '.loans.v1.RepaymentRecordResponse', '4': {}},
    {
      '1': 'RepaymentGet',
      '2': '.loans.v1.RepaymentGetRequest',
      '3': '.loans.v1.RepaymentGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'RepaymentSearch',
      '2': '.loans.v1.RepaymentSearchRequest',
      '3': '.loans.v1.RepaymentSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {
      '1': 'RepaymentScheduleGet',
      '2': '.loans.v1.RepaymentScheduleGetRequest',
      '3': '.loans.v1.RepaymentScheduleGetResponse',
      '4': {'34': 1},
    },
    {'1': 'PenaltySave', '2': '.loans.v1.PenaltySaveRequest', '3': '.loans.v1.PenaltySaveResponse', '4': {}},
    {'1': 'PenaltyWaive', '2': '.loans.v1.PenaltyWaiveRequest', '3': '.loans.v1.PenaltyWaiveResponse', '4': {}},
    {
      '1': 'PenaltySearch',
      '2': '.loans.v1.PenaltySearchRequest',
      '3': '.loans.v1.PenaltySearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'LoanRestructureCreate', '2': '.loans.v1.LoanRestructureCreateRequest', '3': '.loans.v1.LoanRestructureCreateResponse', '4': {}},
    {'1': 'LoanRestructureApprove', '2': '.loans.v1.LoanRestructureApproveRequest', '3': '.loans.v1.LoanRestructureApproveResponse', '4': {}},
    {'1': 'LoanRestructureReject', '2': '.loans.v1.LoanRestructureRejectRequest', '3': '.loans.v1.LoanRestructureRejectResponse', '4': {}},
    {
      '1': 'LoanRestructureSearch',
      '2': '.loans.v1.LoanRestructureSearchRequest',
      '3': '.loans.v1.LoanRestructureSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'ReconciliationSave', '2': '.loans.v1.ReconciliationSaveRequest', '3': '.loans.v1.ReconciliationSaveResponse', '4': {}},
    {
      '1': 'ReconciliationSearch',
      '2': '.loans.v1.ReconciliationSearchRequest',
      '3': '.loans.v1.ReconciliationSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'InitiateCollection', '2': '.loans.v1.InitiateCollectionRequest', '3': '.loans.v1.InitiateCollectionResponse', '4': {}},
    {
      '1': 'LoanStatusChangeSearch',
      '2': '.loans.v1.LoanStatusChangeSearchRequest',
      '3': '.loans.v1.LoanStatusChangeSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {
      '1': 'PortfolioSummary',
      '2': '.loans.v1.PortfolioSummaryRequest',
      '3': '.loans.v1.PortfolioSummaryResponse',
      '4': {'34': 1},
    },
    {
      '1': 'PortfolioExport',
      '2': '.loans.v1.PortfolioExportRequest',
      '3': '.loans.v1.PortfolioExportResponse',
      '4': {'34': 1},
    },
  ],
  '3': {},
};

@$core.Deprecated('Use loanManagementServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> LoanManagementServiceBase$messageJson = {
  '.loans.v1.LoanProductSaveRequest': LoanProductSaveRequest$json,
  '.loans.v1.LoanProductObject': LoanProductObject$json,
  '.common.v1.Money': $7.Money$json,
  '.google.protobuf.Struct': $6.Struct$json,
  '.google.protobuf.Struct.FieldsEntry': $6.Struct_FieldsEntry$json,
  '.google.protobuf.Value': $6.Value$json,
  '.google.protobuf.ListValue': $6.ListValue$json,
  '.loans.v1.ProductFormRequirement': ProductFormRequirement$json,
  '.loans.v1.LoanProductSaveResponse': LoanProductSaveResponse$json,
  '.loans.v1.LoanProductGetRequest': LoanProductGetRequest$json,
  '.loans.v1.LoanProductGetResponse': LoanProductGetResponse$json,
  '.loans.v1.LoanProductSearchRequest': LoanProductSearchRequest$json,
  '.common.v1.PageCursor': $8.PageCursor$json,
  '.loans.v1.LoanProductSearchResponse': LoanProductSearchResponse$json,
  '.loans.v1.LoanRequestSaveRequest': LoanRequestSaveRequest$json,
  '.loans.v1.LoanRequestObject': LoanRequestObject$json,
  '.loans.v1.LoanRequestSaveResponse': LoanRequestSaveResponse$json,
  '.loans.v1.LoanRequestGetRequest': LoanRequestGetRequest$json,
  '.loans.v1.LoanRequestGetResponse': LoanRequestGetResponse$json,
  '.loans.v1.LoanRequestSearchRequest': LoanRequestSearchRequest$json,
  '.loans.v1.LoanRequestSearchResponse': LoanRequestSearchResponse$json,
  '.loans.v1.LoanRequestApproveRequest': LoanRequestApproveRequest$json,
  '.loans.v1.LoanRequestApproveResponse': LoanRequestApproveResponse$json,
  '.loans.v1.LoanRequestRejectRequest': LoanRequestRejectRequest$json,
  '.loans.v1.LoanRequestRejectResponse': LoanRequestRejectResponse$json,
  '.loans.v1.LoanRequestCancelRequest': LoanRequestCancelRequest$json,
  '.loans.v1.LoanRequestCancelResponse': LoanRequestCancelResponse$json,
  '.loans.v1.ClientProductAccessSaveRequest': ClientProductAccessSaveRequest$json,
  '.loans.v1.ClientProductAccessObject': ClientProductAccessObject$json,
  '.loans.v1.ClientProductAccessSaveResponse': ClientProductAccessSaveResponse$json,
  '.loans.v1.ClientProductAccessGetRequest': ClientProductAccessGetRequest$json,
  '.loans.v1.ClientProductAccessGetResponse': ClientProductAccessGetResponse$json,
  '.loans.v1.ClientProductAccessSearchRequest': ClientProductAccessSearchRequest$json,
  '.loans.v1.ClientProductAccessSearchResponse': ClientProductAccessSearchResponse$json,
  '.loans.v1.LoanAccountCreateRequest': LoanAccountCreateRequest$json,
  '.loans.v1.LoanAccountCreateResponse': LoanAccountCreateResponse$json,
  '.loans.v1.LoanAccountObject': LoanAccountObject$json,
  '.loans.v1.LoanAccountGetRequest': LoanAccountGetRequest$json,
  '.loans.v1.LoanAccountGetResponse': LoanAccountGetResponse$json,
  '.loans.v1.LoanAccountSearchRequest': LoanAccountSearchRequest$json,
  '.loans.v1.LoanAccountSearchResponse': LoanAccountSearchResponse$json,
  '.loans.v1.LoanBalanceGetRequest': LoanBalanceGetRequest$json,
  '.loans.v1.LoanBalanceGetResponse': LoanBalanceGetResponse$json,
  '.loans.v1.LoanBalanceObject': LoanBalanceObject$json,
  '.loans.v1.LoanStatementRequest': LoanStatementRequest$json,
  '.loans.v1.LoanStatementResponse': LoanStatementResponse$json,
  '.loans.v1.LoanStatementEntry': LoanStatementEntry$json,
  '.loans.v1.DisbursementCreateRequest': DisbursementCreateRequest$json,
  '.loans.v1.DisbursementCreateResponse': DisbursementCreateResponse$json,
  '.loans.v1.DisbursementObject': DisbursementObject$json,
  '.loans.v1.DisbursementGetRequest': DisbursementGetRequest$json,
  '.loans.v1.DisbursementGetResponse': DisbursementGetResponse$json,
  '.loans.v1.DisbursementSearchRequest': DisbursementSearchRequest$json,
  '.loans.v1.DisbursementSearchResponse': DisbursementSearchResponse$json,
  '.loans.v1.RepaymentRecordRequest': RepaymentRecordRequest$json,
  '.loans.v1.RepaymentRecordResponse': RepaymentRecordResponse$json,
  '.loans.v1.RepaymentObject': RepaymentObject$json,
  '.loans.v1.RepaymentGetRequest': RepaymentGetRequest$json,
  '.loans.v1.RepaymentGetResponse': RepaymentGetResponse$json,
  '.loans.v1.RepaymentSearchRequest': RepaymentSearchRequest$json,
  '.loans.v1.RepaymentSearchResponse': RepaymentSearchResponse$json,
  '.loans.v1.RepaymentScheduleGetRequest': RepaymentScheduleGetRequest$json,
  '.loans.v1.RepaymentScheduleGetResponse': RepaymentScheduleGetResponse$json,
  '.loans.v1.RepaymentScheduleObject': RepaymentScheduleObject$json,
  '.loans.v1.ScheduleEntryObject': ScheduleEntryObject$json,
  '.loans.v1.PenaltySaveRequest': PenaltySaveRequest$json,
  '.loans.v1.PenaltyObject': PenaltyObject$json,
  '.loans.v1.PenaltySaveResponse': PenaltySaveResponse$json,
  '.loans.v1.PenaltyWaiveRequest': PenaltyWaiveRequest$json,
  '.loans.v1.PenaltyWaiveResponse': PenaltyWaiveResponse$json,
  '.loans.v1.PenaltySearchRequest': PenaltySearchRequest$json,
  '.loans.v1.PenaltySearchResponse': PenaltySearchResponse$json,
  '.loans.v1.LoanRestructureCreateRequest': LoanRestructureCreateRequest$json,
  '.loans.v1.LoanRestructureObject': LoanRestructureObject$json,
  '.loans.v1.LoanRestructureCreateResponse': LoanRestructureCreateResponse$json,
  '.loans.v1.LoanRestructureApproveRequest': LoanRestructureApproveRequest$json,
  '.loans.v1.LoanRestructureApproveResponse': LoanRestructureApproveResponse$json,
  '.loans.v1.LoanRestructureRejectRequest': LoanRestructureRejectRequest$json,
  '.loans.v1.LoanRestructureRejectResponse': LoanRestructureRejectResponse$json,
  '.loans.v1.LoanRestructureSearchRequest': LoanRestructureSearchRequest$json,
  '.loans.v1.LoanRestructureSearchResponse': LoanRestructureSearchResponse$json,
  '.loans.v1.ReconciliationSaveRequest': ReconciliationSaveRequest$json,
  '.loans.v1.ReconciliationObject': ReconciliationObject$json,
  '.loans.v1.ReconciliationSaveResponse': ReconciliationSaveResponse$json,
  '.loans.v1.ReconciliationSearchRequest': ReconciliationSearchRequest$json,
  '.loans.v1.ReconciliationSearchResponse': ReconciliationSearchResponse$json,
  '.loans.v1.InitiateCollectionRequest': InitiateCollectionRequest$json,
  '.loans.v1.InitiateCollectionResponse': InitiateCollectionResponse$json,
  '.loans.v1.LoanStatusChangeSearchRequest': LoanStatusChangeSearchRequest$json,
  '.loans.v1.LoanStatusChangeSearchResponse': LoanStatusChangeSearchResponse$json,
  '.loans.v1.LoanStatusChangeObject': LoanStatusChangeObject$json,
  '.loans.v1.PortfolioSummaryRequest': PortfolioSummaryRequest$json,
  '.loans.v1.PortfolioSummaryResponse': PortfolioSummaryResponse$json,
  '.loans.v1.PortfolioSummary': PortfolioSummary$json,
  '.loans.v1.PortfolioExportRequest': PortfolioExportRequest$json,
  '.loans.v1.PortfolioExportResponse': PortfolioExportResponse$json,
};

/// Descriptor for `LoanManagementService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List loanManagementServiceDescriptor = $convert.base64Decode(
    'ChVMb2FuTWFuYWdlbWVudFNlcnZpY2US5AEKD0xvYW5Qcm9kdWN0U2F2ZRIgLmxvYW5zLnYxLk'
    'xvYW5Qcm9kdWN0U2F2ZVJlcXVlc3QaIS5sb2Fucy52MS5Mb2FuUHJvZHVjdFNhdmVSZXNwb25z'
    'ZSKLAbpHbwoMTG9hblByb2R1Y3RzEh9DcmVhdGUgb3IgdXBkYXRlIGEgbG9hbiBwcm9kdWN0Gi'
    '1DcmVhdGVzIG9yIHVwZGF0ZXMgYSBsb2FuIHByb2R1Y3QgZGVmaW5pdGlvbi4qD2xvYW5Qcm9k'
    'dWN0U2F2ZYK1GBUKE2xvYW5fcHJvZHVjdF9tYW5hZ2US3wEKDkxvYW5Qcm9kdWN0R2V0Eh8ubG'
    '9hbnMudjEuTG9hblByb2R1Y3RHZXRSZXF1ZXN0GiAubG9hbnMudjEuTG9hblByb2R1Y3RHZXRS'
    'ZXNwb25zZSKJAZACAbpHbAoMTG9hblByb2R1Y3RzEhhHZXQgYSBsb2FuIHByb2R1Y3QgYnkgSU'
    'QaMlJldHJpZXZlcyBhIGxvYW4gcHJvZHVjdCBieSBpdHMgdW5pcXVlIGlkZW50aWZpZXIuKg5s'
    'b2FuUHJvZHVjdEdldIK1GBMKEWxvYW5fcHJvZHVjdF92aWV3EvgBChFMb2FuUHJvZHVjdFNlYX'
    'JjaBIiLmxvYW5zLnYxLkxvYW5Qcm9kdWN0U2VhcmNoUmVxdWVzdBojLmxvYW5zLnYxLkxvYW5Q'
    'cm9kdWN0U2VhcmNoUmVzcG9uc2UilwGQAgG6R3oKDExvYW5Qcm9kdWN0cxIUU2VhcmNoIGxvYW'
    '4gcHJvZHVjdHMaQVNlYXJjaGVzIGZvciBsb2FuIHByb2R1Y3RzIGJ5IG9yZ2FuaXphdGlvbiwg'
    'dHlwZSwgYW5kIHRleHQgcXVlcnkuKhFsb2FuUHJvZHVjdFNlYXJjaIK1GBMKEWxvYW5fcHJvZH'
    'VjdF92aWV3MAESqgIKD0xvYW5SZXF1ZXN0U2F2ZRIgLmxvYW5zLnYxLkxvYW5SZXF1ZXN0U2F2'
    'ZVJlcXVlc3QaIS5sb2Fucy52MS5Mb2FuUmVxdWVzdFNhdmVSZXNwb25zZSLRAbpHtAEKDExvYW'
    '5SZXF1ZXN0cxIfQ3JlYXRlIG9yIHVwZGF0ZSBhIGxvYW4gcmVxdWVzdBpyQ3JlYXRlcyBvciB1'
    'cGRhdGVzIGEgbG9hbiByZXF1ZXN0LiBQcm9kdWN0IHNlcnZpY2VzIGNhbGwgdGhpcyBhZnRlci'
    'Bjb21wbGV0aW5nIGVsaWdpYmlsaXR5LCBLWUMsIGFuZCB1bmRlcndyaXRpbmcuKg9sb2FuUmVx'
    'dWVzdFNhdmWCtRgVChNsb2FuX3JlcXVlc3RfbWFuYWdlEt8BCg5Mb2FuUmVxdWVzdEdldBIfLm'
    'xvYW5zLnYxLkxvYW5SZXF1ZXN0R2V0UmVxdWVzdBogLmxvYW5zLnYxLkxvYW5SZXF1ZXN0R2V0'
    'UmVzcG9uc2UiiQGQAgG6R2wKDExvYW5SZXF1ZXN0cxIYR2V0IGEgbG9hbiByZXF1ZXN0IGJ5IE'
    'lEGjJSZXRyaWV2ZXMgYSBsb2FuIHJlcXVlc3QgYnkgaXRzIHVuaXF1ZSBpZGVudGlmaWVyLioO'
    'bG9hblJlcXVlc3RHZXSCtRgTChFsb2FuX3JlcXVlc3RfdmlldxKCAgoRTG9hblJlcXVlc3RTZW'
    'FyY2gSIi5sb2Fucy52MS5Mb2FuUmVxdWVzdFNlYXJjaFJlcXVlc3QaIy5sb2Fucy52MS5Mb2Fu'
    'UmVxdWVzdFNlYXJjaFJlc3BvbnNlIqEBkAIBukeDAQoMTG9hblJlcXVlc3RzEhRTZWFyY2ggbG'
    '9hbiByZXF1ZXN0cxpKU2VhcmNoZXMgZm9yIGxvYW4gcmVxdWVzdHMgYnkgY2xpZW50LCBwcm9k'
    'dWN0LCBzdGF0dXMsIGFuZCBzb3VyY2Ugc2VydmljZS4qEWxvYW5SZXF1ZXN0U2VhcmNogrUYEw'
    'oRbG9hbl9yZXF1ZXN0X3ZpZXcwARKUAgoSTG9hblJlcXVlc3RBcHByb3ZlEiMubG9hbnMudjEu'
    'TG9hblJlcXVlc3RBcHByb3ZlUmVxdWVzdBokLmxvYW5zLnYxLkxvYW5SZXF1ZXN0QXBwcm92ZV'
    'Jlc3BvbnNlIrIBukeVAQoMTG9hblJlcXVlc3RzEhZBcHByb3ZlIGEgbG9hbiByZXF1ZXN0GllB'
    'cHByb3ZlcyBhIHN1Ym1pdHRlZCBsb2FuIHJlcXVlc3QsIHRyYW5zaXRpb25zIHRvIEFQUFJPVk'
    'VELCBhbmQgY3JlYXRlcyB0aGUgbG9hbiBhY2NvdW50LioSbG9hblJlcXVlc3RBcHByb3ZlgrUY'
    'FQoTbG9hbl9yZXF1ZXN0X21hbmFnZRLZAQoRTG9hblJlcXVlc3RSZWplY3QSIi5sb2Fucy52MS'
    '5Mb2FuUmVxdWVzdFJlamVjdFJlcXVlc3QaIy5sb2Fucy52MS5Mb2FuUmVxdWVzdFJlamVjdFJl'
    'c3BvbnNlInu6R18KDExvYW5SZXF1ZXN0cxIVUmVqZWN0IGEgbG9hbiByZXF1ZXN0GiVSZWplY3'
    'RzIGEgbG9hbiByZXF1ZXN0IHdpdGggYSByZWFzb24uKhFsb2FuUmVxdWVzdFJlamVjdIK1GBUK'
    'E2xvYW5fcmVxdWVzdF9tYW5hZ2US2AEKEUxvYW5SZXF1ZXN0Q2FuY2VsEiIubG9hbnMudjEuTG'
    '9hblJlcXVlc3RDYW5jZWxSZXF1ZXN0GiMubG9hbnMudjEuTG9hblJlcXVlc3RDYW5jZWxSZXNw'
    'b25zZSJ6ukdeCgxMb2FuUmVxdWVzdHMSFUNhbmNlbCBhIGxvYW4gcmVxdWVzdBokQ2FuY2Vscy'
    'BhIG5vbi10ZXJtaW5hbCBsb2FuIHJlcXVlc3QuKhFsb2FuUmVxdWVzdENhbmNlbIK1GBUKE2xv'
    'YW5fcmVxdWVzdF9tYW5hZ2USmwIKF0NsaWVudFByb2R1Y3RBY2Nlc3NTYXZlEigubG9hbnMudj'
    'EuQ2xpZW50UHJvZHVjdEFjY2Vzc1NhdmVSZXF1ZXN0GikubG9hbnMudjEuQ2xpZW50UHJvZHVj'
    'dEFjY2Vzc1NhdmVSZXNwb25zZSKqAbpHhAEKE0NsaWVudFByb2R1Y3RBY2Nlc3MSIEdyYW50IH'
    'Byb2R1Y3QgYWNjZXNzIHRvIGEgY2xpZW50GjJDcmVhdGVzIG9yIHVwZGF0ZXMgYSBjbGllbnQg'
    'cHJvZHVjdCBhY2Nlc3MgcmVjb3JkLioXY2xpZW50UHJvZHVjdEFjY2Vzc1NhdmWCtRgeChxjbG'
    'llbnRfcHJvZHVjdF9hY2Nlc3NfbWFuYWdlEpsCChZDbGllbnRQcm9kdWN0QWNjZXNzR2V0Eicu'
    'bG9hbnMudjEuQ2xpZW50UHJvZHVjdEFjY2Vzc0dldFJlcXVlc3QaKC5sb2Fucy52MS5DbGllbn'
    'RQcm9kdWN0QWNjZXNzR2V0UmVzcG9uc2UirQGQAgG6R4YBChNDbGllbnRQcm9kdWN0QWNjZXNz'
    'EiJHZXQgYSBjbGllbnQgcHJvZHVjdCBhY2Nlc3MgcmVjb3JkGjNSZXRyaWV2ZXMgYSBjbGllbn'
    'QgcHJvZHVjdCBhY2Nlc3MgcmVjb3JkIGJ5IGl0cyBJRC4qFmNsaWVudFByb2R1Y3RBY2Nlc3NH'
    'ZXSCtRgcChpjbGllbnRfcHJvZHVjdF9hY2Nlc3NfdmlldxKxAgoZQ2xpZW50UHJvZHVjdEFjY2'
    'Vzc1NlYXJjaBIqLmxvYW5zLnYxLkNsaWVudFByb2R1Y3RBY2Nlc3NTZWFyY2hSZXF1ZXN0Gisu'
    'bG9hbnMudjEuQ2xpZW50UHJvZHVjdEFjY2Vzc1NlYXJjaFJlc3BvbnNlIrgBkAIBukeRAQoTQ2'
    'xpZW50UHJvZHVjdEFjY2VzcxIcU2VhcmNoIGNsaWVudCBwcm9kdWN0IGFjY2VzcxpBU2VhcmNo'
    'ZXMgZm9yIGNsaWVudCBwcm9kdWN0IGFjY2VzcyByZWNvcmRzIGJ5IGNsaWVudCBhbmQgcHJvZH'
    'VjdC4qGWNsaWVudFByb2R1Y3RBY2Nlc3NTZWFyY2iCtRgcChpjbGllbnRfcHJvZHVjdF9hY2Nl'
    'c3NfdmlldzABEuYBChFMb2FuQWNjb3VudENyZWF0ZRIiLmxvYW5zLnYxLkxvYW5BY2NvdW50Q3'
    'JlYXRlUmVxdWVzdBojLmxvYW5zLnYxLkxvYW5BY2NvdW50Q3JlYXRlUmVzcG9uc2UihwG6R3MK'
    'DExvYW5BY2NvdW50cxIVQ3JlYXRlIGEgbG9hbiBhY2NvdW50GjlDcmVhdGVzIGEgbmV3IGxvYW'
    '4gYWNjb3VudCBmcm9tIGFuIGFwcHJvdmVkIGxvYW4gcmVxdWVzdC4qEWxvYW5BY2NvdW50Q3Jl'
    'YXRlgrUYDQoLbG9hbl9tYW5hZ2US3gEKDkxvYW5BY2NvdW50R2V0Eh8ubG9hbnMudjEuTG9hbk'
    'FjY291bnRHZXRSZXF1ZXN0GiAubG9hbnMudjEuTG9hbkFjY291bnRHZXRSZXNwb25zZSKIAZAC'
    'AbpHcwoMTG9hbkFjY291bnRzEhhHZXQgYSBsb2FuIGFjY291bnQgYnkgSUQaOVJldHJpZXZlcy'
    'BhIGxvYW4gYWNjb3VudCByZWNvcmQgYnkgaXRzIHVuaXF1ZSBpZGVudGlmaWVyLioObG9hbkFj'
    'Y291bnRHZXSCtRgLCglsb2FuX3ZpZXcSkgIKEUxvYW5BY2NvdW50U2VhcmNoEiIubG9hbnMudj'
    'EuTG9hbkFjY291bnRTZWFyY2hSZXF1ZXN0GiMubG9hbnMudjEuTG9hbkFjY291bnRTZWFyY2hS'
    'ZXNwb25zZSKxAZACAbpHmwEKDExvYW5BY2NvdW50cxIUU2VhcmNoIGxvYW4gYWNjb3VudHMaYl'
    'NlYXJjaGVzIGZvciBsb2FuIGFjY291bnRzLiBTdXBwb3J0cyBmaWx0ZXJpbmcgYnkgY2xpZW50'
    'LCBhZ2VudCwgYnJhbmNoLCBvcmdhbml6YXRpb24sIGFuZCBzdGF0dXMuKhFsb2FuQWNjb3VudF'
    'NlYXJjaIK1GAsKCWxvYW5fdmlldzABEtcBCg5Mb2FuQmFsYW5jZUdldBIfLmxvYW5zLnYxLkxv'
    'YW5CYWxhbmNlR2V0UmVxdWVzdBogLmxvYW5zLnYxLkxvYW5CYWxhbmNlR2V0UmVzcG9uc2UigQ'
    'GQAgG6R2wKDExvYW5BY2NvdW50cxIQR2V0IGxvYW4gYmFsYW5jZRo6UmV0cmlldmVzIHRoZSBj'
    'dXJyZW50IGJhbGFuY2Ugc25hcHNob3QgZm9yIGEgbG9hbiBhY2NvdW50LioObG9hbkJhbGFuY2'
    'VHZXSCtRgLCglsb2FuX3ZpZXcS6gEKDUxvYW5TdGF0ZW1lbnQSHi5sb2Fucy52MS5Mb2FuU3Rh'
    'dGVtZW50UmVxdWVzdBofLmxvYW5zLnYxLkxvYW5TdGF0ZW1lbnRSZXNwb25zZSKXAZACAbpHgQ'
    'EKDExvYW5BY2NvdW50cxISR2V0IGxvYW4gc3RhdGVtZW50Gk5HZW5lcmF0ZXMgYSBsb2FuIHN0'
    'YXRlbWVudCB3aXRoIGFsbCB0cmFuc2FjdGlvbnMgZm9yIHRoZSBzcGVjaWZpZWQgZGF0ZSByYW'
    '5nZS4qDWxvYW5TdGF0ZW1lbnSCtRgLCglsb2FuX3ZpZXcSgQIKEkRpc2J1cnNlbWVudENyZWF0'
    'ZRIjLmxvYW5zLnYxLkRpc2J1cnNlbWVudENyZWF0ZVJlcXVlc3QaJC5sb2Fucy52MS5EaXNidX'
    'JzZW1lbnRDcmVhdGVSZXNwb25zZSKfAbpHggEKDURpc2J1cnNlbWVudHMSFUNyZWF0ZSBhIGRp'
    'c2J1cnNlbWVudBpGSW5pdGlhdGVzIGEgbG9hbiBkaXNidXJzZW1lbnQgdG8gdGhlIGNsaWVudC'
    'B2aWEgdGhlIHNwZWNpZmllZCBjaGFubmVsLioSZGlzYnVyc2VtZW50Q3JlYXRlgrUYFQoTZGlz'
    'YnVyc2VtZW50X21hbmFnZRLrAQoPRGlzYnVyc2VtZW50R2V0EiAubG9hbnMudjEuRGlzYnVyc2'
    'VtZW50R2V0UmVxdWVzdBohLmxvYW5zLnYxLkRpc2J1cnNlbWVudEdldFJlc3BvbnNlIpIBkAIB'
    'ukd1Cg1EaXNidXJzZW1lbnRzEhhHZXQgYSBkaXNidXJzZW1lbnQgYnkgSUQaOVJldHJpZXZlcy'
    'BhIGRpc2J1cnNlbWVudCByZWNvcmQgYnkgaXRzIHVuaXF1ZSBpZGVudGlmaWVyLioPZGlzYnVy'
    'c2VtZW50R2V0grUYEwoRZGlzYnVyc2VtZW50X3ZpZXcS6gEKEkRpc2J1cnNlbWVudFNlYXJjaB'
    'IjLmxvYW5zLnYxLkRpc2J1cnNlbWVudFNlYXJjaFJlcXVlc3QaJC5sb2Fucy52MS5EaXNidXJz'
    'ZW1lbnRTZWFyY2hSZXNwb25zZSKGAZACAbpHaQoNRGlzYnVyc2VtZW50cxIUU2VhcmNoIGRpc2'
    'J1cnNlbWVudHMaLlNlYXJjaGVzIGZvciBkaXNidXJzZW1lbnRzIGZvciBhIGxvYW4gYWNjb3Vu'
    'dC4qEmRpc2J1cnNlbWVudFNlYXJjaIK1GBMKEWRpc2J1cnNlbWVudF92aWV3MAES8wEKD1JlcG'
    'F5bWVudFJlY29yZBIgLmxvYW5zLnYxLlJlcGF5bWVudFJlY29yZFJlcXVlc3QaIS5sb2Fucy52'
    'MS5SZXBheW1lbnRSZWNvcmRSZXNwb25zZSKaAbpHgAEKClJlcGF5bWVudHMSElJlY29yZCBhIH'
    'JlcGF5bWVudBpNUmVjb3JkcyBhbiBpbmNvbWluZyBwYXltZW50IGFuZCBhbGxvY2F0ZXMgaXQg'
    'dG8gb3V0c3RhbmRpbmcgc2NoZWR1bGUgZW50cmllcy4qD3JlcGF5bWVudFJlY29yZIK1GBIKEH'
    'JlcGF5bWVudF9tYW5hZ2US0wEKDFJlcGF5bWVudEdldBIdLmxvYW5zLnYxLlJlcGF5bWVudEdl'
    'dFJlcXVlc3QaHi5sb2Fucy52MS5SZXBheW1lbnRHZXRSZXNwb25zZSKDAZACAbpHaQoKUmVwYX'
    'ltZW50cxIVR2V0IGEgcmVwYXltZW50IGJ5IElEGjZSZXRyaWV2ZXMgYSByZXBheW1lbnQgcmVj'
    'b3JkIGJ5IGl0cyB1bmlxdWUgaWRlbnRpZmllci4qDHJlcGF5bWVudEdldIK1GBAKDnJlcGF5bW'
    'VudF92aWV3EtEBCg9SZXBheW1lbnRTZWFyY2gSIC5sb2Fucy52MS5SZXBheW1lbnRTZWFyY2hS'
    'ZXF1ZXN0GiEubG9hbnMudjEuUmVwYXltZW50U2VhcmNoUmVzcG9uc2Uid5ACAbpHXQoKUmVwYX'
    'ltZW50cxIRU2VhcmNoIHJlcGF5bWVudHMaK1NlYXJjaGVzIGZvciByZXBheW1lbnRzIGZvciBh'
    'IGxvYW4gYWNjb3VudC4qD3JlcGF5bWVudFNlYXJjaIK1GBAKDnJlcGF5bWVudF92aWV3MAEShQ'
    'IKFFJlcGF5bWVudFNjaGVkdWxlR2V0EiUubG9hbnMudjEuUmVwYXltZW50U2NoZWR1bGVHZXRS'
    'ZXF1ZXN0GiYubG9hbnMudjEuUmVwYXltZW50U2NoZWR1bGVHZXRSZXNwb25zZSKdAZACAbpHgg'
    'EKElJlcGF5bWVudFNjaGVkdWxlcxIWR2V0IHJlcGF5bWVudCBzY2hlZHVsZRo+UmV0cmlldmVz'
    'IHRoZSBhY3RpdmUgYW1vcnRpemF0aW9uIHNjaGVkdWxlIGZvciBhIGxvYW4gYWNjb3VudC4qFH'
    'JlcGF5bWVudFNjaGVkdWxlR2V0grUYEAoOcmVwYXltZW50X3ZpZXcS0QEKC1BlbmFsdHlTYXZl'
    'EhwubG9hbnMudjEuUGVuYWx0eVNhdmVSZXF1ZXN0Gh0ubG9hbnMudjEuUGVuYWx0eVNhdmVSZX'
    'Nwb25zZSKEAbpHbQoJUGVuYWx0aWVzEhpDcmVhdGUgb3IgdXBkYXRlIGEgcGVuYWx0eRo3Q3Jl'
    'YXRlcyBvciB1cGRhdGVzIGEgcGVuYWx0eSByZWNvcmQgZm9yIGEgbG9hbiBhY2NvdW50LioLcG'
    'VuYWx0eVNhdmWCtRgQCg5wZW5hbHR5X21hbmFnZRKxAQoMUGVuYWx0eVdhaXZlEh0ubG9hbnMu'
    'djEuUGVuYWx0eVdhaXZlUmVxdWVzdBoeLmxvYW5zLnYxLlBlbmFsdHlXYWl2ZVJlc3BvbnNlIm'
    'K6R0sKCVBlbmFsdGllcxIPV2FpdmUgYSBwZW5hbHR5Gh9XYWl2ZXMgYSBwZW5hbHR5IHdpdGgg'
    'YSByZWFzb24uKgxwZW5hbHR5V2FpdmWCtRgQCg5wZW5hbHR5X21hbmFnZRLEAQoNUGVuYWx0eV'
    'NlYXJjaBIeLmxvYW5zLnYxLlBlbmFsdHlTZWFyY2hSZXF1ZXN0Gh8ubG9hbnMudjEuUGVuYWx0'
    'eVNlYXJjaFJlc3BvbnNlInCQAgG6R1gKCVBlbmFsdGllcxIQU2VhcmNoIHBlbmFsdGllcxoqU2'
    'VhcmNoZXMgZm9yIHBlbmFsdGllcyBmb3IgYSBsb2FuIGFjY291bnQuKg1wZW5hbHR5U2VhcmNo'
    'grUYDgoMcGVuYWx0eV92aWV3MAES8gEKFUxvYW5SZXN0cnVjdHVyZUNyZWF0ZRImLmxvYW5zLn'
    'YxLkxvYW5SZXN0cnVjdHVyZUNyZWF0ZVJlcXVlc3QaJy5sb2Fucy52MS5Mb2FuUmVzdHJ1Y3R1'
    'cmVDcmVhdGVSZXNwb25zZSKHAbpHbAoMUmVzdHJ1Y3R1cmVzEhxDcmVhdGUgYSByZXN0cnVjdH'
    'VyZSByZXF1ZXN0GidDcmVhdGVzIGEgbmV3IGxvYW4gcmVzdHJ1Y3R1cmUgcmVxdWVzdC4qFWxv'
    'YW5SZXN0cnVjdHVyZUNyZWF0ZYK1GBQKEnJlc3RydWN0dXJlX21hbmFnZRKhAgoWTG9hblJlc3'
    'RydWN0dXJlQXBwcm92ZRInLmxvYW5zLnYxLkxvYW5SZXN0cnVjdHVyZUFwcHJvdmVSZXF1ZXN0'
    'GigubG9hbnMudjEuTG9hblJlc3RydWN0dXJlQXBwcm92ZVJlc3BvbnNlIrMBukeXAQoMUmVzdH'
    'J1Y3R1cmVzEhVBcHByb3ZlIGEgcmVzdHJ1Y3R1cmUaWEFwcHJvdmVzIGEgcGVuZGluZyBsb2Fu'
    'IHJlc3RydWN0dXJlLCBtb2RpZnlpbmcgbG9hbiB0ZXJtcyBhbmQgcmVnZW5lcmF0aW5nIHRoZS'
    'BzY2hlZHVsZS4qFmxvYW5SZXN0cnVjdHVyZUFwcHJvdmWCtRgUChJyZXN0cnVjdHVyZV9tYW5h'
    'Z2US9AEKFUxvYW5SZXN0cnVjdHVyZVJlamVjdBImLmxvYW5zLnYxLkxvYW5SZXN0cnVjdHVyZV'
    'JlamVjdFJlcXVlc3QaJy5sb2Fucy52MS5Mb2FuUmVzdHJ1Y3R1cmVSZWplY3RSZXNwb25zZSKJ'
    'AbpHbgoMUmVzdHJ1Y3R1cmVzEhRSZWplY3QgYSByZXN0cnVjdHVyZRoxUmVqZWN0cyBhIHBlbm'
    'RpbmcgbG9hbiByZXN0cnVjdHVyZSB3aXRoIGEgcmVhc29uLioVbG9hblJlc3RydWN0dXJlUmVq'
    'ZWN0grUYFAoScmVzdHJ1Y3R1cmVfbWFuYWdlEvkBChVMb2FuUmVzdHJ1Y3R1cmVTZWFyY2gSJi'
    '5sb2Fucy52MS5Mb2FuUmVzdHJ1Y3R1cmVTZWFyY2hSZXF1ZXN0GicubG9hbnMudjEuTG9hblJl'
    'c3RydWN0dXJlU2VhcmNoUmVzcG9uc2UijAGQAgG6R3AKDFJlc3RydWN0dXJlcxITU2VhcmNoIH'
    'Jlc3RydWN0dXJlcxo0U2VhcmNoZXMgZm9yIHJlc3RydWN0dXJlIHJlY29yZHMgZm9yIGEgbG9h'
    'biBhY2NvdW50LioVbG9hblJlc3RydWN0dXJlU2VhcmNogrUYEgoQcmVzdHJ1Y3R1cmVfdmlldz'
    'ABEvwBChJSZWNvbmNpbGlhdGlvblNhdmUSIy5sb2Fucy52MS5SZWNvbmNpbGlhdGlvblNhdmVS'
    'ZXF1ZXN0GiQubG9hbnMudjEuUmVjb25jaWxpYXRpb25TYXZlUmVzcG9uc2UimgG6R3wKDlJlY2'
    '9uY2lsaWF0aW9uEiFDcmVhdGUgb3IgdXBkYXRlIGEgcmVjb25jaWxpYXRpb24aM0NyZWF0ZXMg'
    'b3IgdXBkYXRlcyBhIHBheW1lbnQgcmVjb25jaWxpYXRpb24gcmVjb3JkLioScmVjb25jaWxpYX'
    'Rpb25TYXZlgrUYFwoVcmVjb25jaWxpYXRpb25fbWFuYWdlEpcCChRSZWNvbmNpbGlhdGlvblNl'
    'YXJjaBIlLmxvYW5zLnYxLlJlY29uY2lsaWF0aW9uU2VhcmNoUmVxdWVzdBomLmxvYW5zLnYxLl'
    'JlY29uY2lsaWF0aW9uU2VhcmNoUmVzcG9uc2UirQGQAgG6R4sBCg5SZWNvbmNpbGlhdGlvbhIW'
    'U2VhcmNoIHJlY29uY2lsaWF0aW9ucxpLU2VhcmNoZXMgZm9yIHJlY29uY2lsaWF0aW9uIHJlY2'
    '9yZHMuIFN1cHBvcnRzIGZpbHRlcmluZyBieSBsb2FuIGFuZCBzdGF0dXMuKhRyZWNvbmNpbGlh'
    'dGlvblNlYXJjaIK1GBcKFXJlY29uY2lsaWF0aW9uX21hbmFnZTABEoUCChJJbml0aWF0ZUNvbG'
    'xlY3Rpb24SIy5sb2Fucy52MS5Jbml0aWF0ZUNvbGxlY3Rpb25SZXF1ZXN0GiQubG9hbnMudjEu'
    'SW5pdGlhdGVDb2xsZWN0aW9uUmVzcG9uc2UiowG6R4gBCgpDb2xsZWN0aW9uEhtJbml0aWF0ZS'
    'BwYXltZW50IGNvbGxlY3Rpb24aSVNlbmRzIGFuIFNUSyBwdXNoIG9yIHBheW1lbnQgcHJvbXB0'
    'IHRvIGNvbGxlY3QgYSBwYXltZW50IGZyb20gdGhlIGNsaWVudC4qEmluaXRpYXRlQ29sbGVjdG'
    'lvboK1GBMKEWNvbGxlY3Rpb25fbWFuYWdlEv0BChZMb2FuU3RhdHVzQ2hhbmdlU2VhcmNoEicu'
    'bG9hbnMudjEuTG9hblN0YXR1c0NoYW5nZVNlYXJjaFJlcXVlc3QaKC5sb2Fucy52MS5Mb2FuU3'
    'RhdHVzQ2hhbmdlU2VhcmNoUmVzcG9uc2UijQGQAgG6R3gKBUF1ZGl0EhpTZWFyY2ggbG9hbiBz'
    'dGF0dXMgY2hhbmdlcxo7UmV0cmlldmVzIHRoZSBzdGF0dXMgY2hhbmdlIGF1ZGl0IHRyYWlsIG'
    'ZvciBhIGxvYW4gYWNjb3VudC4qFmxvYW5TdGF0dXNDaGFuZ2VTZWFyY2iCtRgLCglsb2FuX3Zp'
    'ZXcwARLGAgoQUG9ydGZvbGlvU3VtbWFyeRIhLmxvYW5zLnYxLlBvcnRmb2xpb1N1bW1hcnlSZX'
    'F1ZXN0GiIubG9hbnMudjEuUG9ydGZvbGlvU3VtbWFyeVJlc3BvbnNlIuoBkAIBukfPAQoJUG9y'
    'dGZvbGlvEhVHZXQgcG9ydGZvbGlvIHN1bW1hcnkamAFSZXR1cm5zIGFnZ3JlZ2F0ZWQgZmluYW'
    '5jaWFsIG1ldHJpY3MgKHRvdGFscywgY291bnRzLCBjb2xsZWN0aW9uIHJhdGUsIFBBUikgYWNy'
    'b3NzIGxvYW5zLCBmaWx0ZXJhYmxlIGJ5IG9yZ2FuaXphdGlvbiwgYnJhbmNoLCBhZ2VudCwgcH'
    'JvZHVjdCwgb3IgY2xpZW50LioQcG9ydGZvbGlvU3VtbWFyeYK1GBAKDnBvcnRmb2xpb192aWV3'
    'EucBCg9Qb3J0Zm9saW9FeHBvcnQSIC5sb2Fucy52MS5Qb3J0Zm9saW9FeHBvcnRSZXF1ZXN0Gi'
    'EubG9hbnMudjEuUG9ydGZvbGlvRXhwb3J0UmVzcG9uc2UijgGQAgG6R3IKCVBvcnRmb2xpbxIQ'
    'RXhwb3J0IGxvYW4gYm9vaxpCRXhwb3J0cyB0aGUgbG9hbiBib29rIGFzIGEgQ1NWIGZpbGUgZm'
    '9yIHRoZSBmaWx0ZXJlZCBzZXQgb2YgbG9hbnMuKg9wb3J0Zm9saW9FeHBvcnSCtRgSChBwb3J0'
    'Zm9saW9fZXhwb3J0GvwQgrUY9xAKDXNlcnZpY2VfbG9hbnMSEWxvYW5fcHJvZHVjdF92aWV3Eh'
    'Nsb2FuX3Byb2R1Y3RfbWFuYWdlEhFsb2FuX3JlcXVlc3RfdmlldxITbG9hbl9yZXF1ZXN0X21h'
    'bmFnZRITbG9hbl9yZXF1ZXN0X3N1Ym1pdBIaY2xpZW50X3Byb2R1Y3RfYWNjZXNzX3ZpZXcSHG'
    'NsaWVudF9wcm9kdWN0X2FjY2Vzc19tYW5hZ2USCWxvYW5fdmlldxILbG9hbl9tYW5hZ2USEWRp'
    'c2J1cnNlbWVudF92aWV3EhNkaXNidXJzZW1lbnRfbWFuYWdlEg5yZXBheW1lbnRfdmlldxIQcm'
    'VwYXltZW50X21hbmFnZRIMcGVuYWx0eV92aWV3Eg5wZW5hbHR5X21hbmFnZRIQcmVzdHJ1Y3R1'
    'cmVfdmlldxIScmVzdHJ1Y3R1cmVfbWFuYWdlEhVyZWNvbmNpbGlhdGlvbl9tYW5hZ2USEWNvbG'
    'xlY3Rpb25fbWFuYWdlEg5wb3J0Zm9saW9fdmlldxIQcG9ydGZvbGlvX2V4cG9ydBqTAwgBEhFs'
    'b2FuX3Byb2R1Y3RfdmlldxITbG9hbl9wcm9kdWN0X21hbmFnZRIRbG9hbl9yZXF1ZXN0X3ZpZX'
    'cSE2xvYW5fcmVxdWVzdF9tYW5hZ2USE2xvYW5fcmVxdWVzdF9zdWJtaXQSGmNsaWVudF9wcm9k'
    'dWN0X2FjY2Vzc192aWV3EhxjbGllbnRfcHJvZHVjdF9hY2Nlc3NfbWFuYWdlEglsb2FuX3ZpZX'
    'cSC2xvYW5fbWFuYWdlEhFkaXNidXJzZW1lbnRfdmlldxITZGlzYnVyc2VtZW50X21hbmFnZRIO'
    'cmVwYXltZW50X3ZpZXcSEHJlcGF5bWVudF9tYW5hZ2USDHBlbmFsdHlfdmlldxIOcGVuYWx0eV'
    '9tYW5hZ2USEHJlc3RydWN0dXJlX3ZpZXcSEnJlc3RydWN0dXJlX21hbmFnZRIVcmVjb25jaWxp'
    'YXRpb25fbWFuYWdlEhFjb2xsZWN0aW9uX21hbmFnZRIOcG9ydGZvbGlvX3ZpZXcSEHBvcnRmb2'
    'xpb19leHBvcnQakwMIAhIRbG9hbl9wcm9kdWN0X3ZpZXcSE2xvYW5fcHJvZHVjdF9tYW5hZ2US'
    'EWxvYW5fcmVxdWVzdF92aWV3EhNsb2FuX3JlcXVlc3RfbWFuYWdlEhNsb2FuX3JlcXVlc3Rfc3'
    'VibWl0EhpjbGllbnRfcHJvZHVjdF9hY2Nlc3NfdmlldxIcY2xpZW50X3Byb2R1Y3RfYWNjZXNz'
    'X21hbmFnZRIJbG9hbl92aWV3Egtsb2FuX21hbmFnZRIRZGlzYnVyc2VtZW50X3ZpZXcSE2Rpc2'
    'J1cnNlbWVudF9tYW5hZ2USDnJlcGF5bWVudF92aWV3EhByZXBheW1lbnRfbWFuYWdlEgxwZW5h'
    'bHR5X3ZpZXcSDnBlbmFsdHlfbWFuYWdlEhByZXN0cnVjdHVyZV92aWV3EhJyZXN0cnVjdHVyZV'
    '9tYW5hZ2USFXJlY29uY2lsaWF0aW9uX21hbmFnZRIRY29sbGVjdGlvbl9tYW5hZ2USDnBvcnRm'
    'b2xpb192aWV3EhBwb3J0Zm9saW9fZXhwb3J0GvUBCAMSEWxvYW5fcHJvZHVjdF92aWV3EhFsb2'
    'FuX3JlcXVlc3RfdmlldxITbG9hbl9yZXF1ZXN0X21hbmFnZRITbG9hbl9yZXF1ZXN0X3N1Ym1p'
    'dBIaY2xpZW50X3Byb2R1Y3RfYWNjZXNzX3ZpZXcSCWxvYW5fdmlldxIRZGlzYnVyc2VtZW50X3'
    'ZpZXcSDnJlcGF5bWVudF92aWV3EhByZXBheW1lbnRfbWFuYWdlEgxwZW5hbHR5X3ZpZXcSEHJl'
    'c3RydWN0dXJlX3ZpZXcSFXJlY29uY2lsaWF0aW9uX21hbmFnZRIOcG9ydGZvbGlvX3ZpZXcaog'
    'EIBBIRbG9hbl9wcm9kdWN0X3ZpZXcSEWxvYW5fcmVxdWVzdF92aWV3EhpjbGllbnRfcHJvZHVj'
    'dF9hY2Nlc3NfdmlldxIJbG9hbl92aWV3EhFkaXNidXJzZW1lbnRfdmlldxIOcmVwYXltZW50X3'
    'ZpZXcSDHBlbmFsdHlfdmlldxIQcmVzdHJ1Y3R1cmVfdmlldxIOcG9ydGZvbGlvX3ZpZXcadggF'
    'EhFsb2FuX3Byb2R1Y3RfdmlldxIRbG9hbl9yZXF1ZXN0X3ZpZXcSCWxvYW5fdmlldxIRZGlzYn'
    'Vyc2VtZW50X3ZpZXcSDnJlcGF5bWVudF92aWV3EgxwZW5hbHR5X3ZpZXcSEHJlc3RydWN0dXJl'
    'X3ZpZXcakwMIBhIRbG9hbl9wcm9kdWN0X3ZpZXcSE2xvYW5fcHJvZHVjdF9tYW5hZ2USEWxvYW'
    '5fcmVxdWVzdF92aWV3EhNsb2FuX3JlcXVlc3RfbWFuYWdlEhNsb2FuX3JlcXVlc3Rfc3VibWl0'
    'EhpjbGllbnRfcHJvZHVjdF9hY2Nlc3NfdmlldxIcY2xpZW50X3Byb2R1Y3RfYWNjZXNzX21hbm'
    'FnZRIJbG9hbl92aWV3Egtsb2FuX21hbmFnZRIRZGlzYnVyc2VtZW50X3ZpZXcSE2Rpc2J1cnNl'
    'bWVudF9tYW5hZ2USDnJlcGF5bWVudF92aWV3EhByZXBheW1lbnRfbWFuYWdlEgxwZW5hbHR5X3'
    'ZpZXcSDnBlbmFsdHlfbWFuYWdlEhByZXN0cnVjdHVyZV92aWV3EhJyZXN0cnVjdHVyZV9tYW5h'
    'Z2USFXJlY29uY2lsaWF0aW9uX21hbmFnZRIRY29sbGVjdGlvbl9tYW5hZ2USDnBvcnRmb2xpb1'
    '92aWV3EhBwb3J0Zm9saW9fZXhwb3J0');

