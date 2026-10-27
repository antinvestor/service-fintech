// This is a generated file - do not edit.
//
// Generated from limits/v1/limits.proto.

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

import 'package:protobuf/well_known_types/google/protobuf/duration.pbjson.dart'
    as $0;
import 'package:protobuf/well_known_types/google/protobuf/struct.pbjson.dart'
    as $2;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pbjson.dart'
    as $3;

import '../../common/v1/common.pbjson.dart' as $4;
import '../../common/v1/money.pbjson.dart' as $1;

@$core.Deprecated('Use limitActionDescriptor instead')
const LimitAction$json = {
  '1': 'LimitAction',
  '2': [
    {'1': 'LIMIT_ACTION_UNSPECIFIED', '2': 0},
    {'1': 'LIMIT_ACTION_LOAN_DISBURSEMENT', '2': 1},
    {'1': 'LIMIT_ACTION_LOAN_REQUEST', '2': 2},
    {'1': 'LIMIT_ACTION_LOAN_REPAYMENT', '2': 3},
    {'1': 'LIMIT_ACTION_SAVINGS_DEPOSIT', '2': 4},
    {'1': 'LIMIT_ACTION_SAVINGS_WITHDRAWAL', '2': 5},
    {'1': 'LIMIT_ACTION_TRANSFER_ORDER_EXECUTE', '2': 6},
    {'1': 'LIMIT_ACTION_INCOMING_PAYMENT', '2': 7},
    {'1': 'LIMIT_ACTION_FUNDING_INFLOW', '2': 8},
    {'1': 'LIMIT_ACTION_FUNDING_OUTFLOW', '2': 9},
    {'1': 'LIMIT_ACTION_STAWI_CONTRIBUTION', '2': 10},
    {'1': 'LIMIT_ACTION_STAWI_PAYOUT', '2': 11},
  ],
};

/// Descriptor for `LimitAction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List limitActionDescriptor = $convert.base64Decode(
    'CgtMaW1pdEFjdGlvbhIcChhMSU1JVF9BQ1RJT05fVU5TUEVDSUZJRUQQABIiCh5MSU1JVF9BQ1'
    'RJT05fTE9BTl9ESVNCVVJTRU1FTlQQARIdChlMSU1JVF9BQ1RJT05fTE9BTl9SRVFVRVNUEAIS'
    'HwobTElNSVRfQUNUSU9OX0xPQU5fUkVQQVlNRU5UEAMSIAocTElNSVRfQUNUSU9OX1NBVklOR1'
    'NfREVQT1NJVBAEEiMKH0xJTUlUX0FDVElPTl9TQVZJTkdTX1dJVEhEUkFXQUwQBRInCiNMSU1J'
    'VF9BQ1RJT05fVFJBTlNGRVJfT1JERVJfRVhFQ1VURRAGEiEKHUxJTUlUX0FDVElPTl9JTkNPTU'
    'lOR19QQVlNRU5UEAcSHwobTElNSVRfQUNUSU9OX0ZVTkRJTkdfSU5GTE9XEAgSIAocTElNSVRf'
    'QUNUSU9OX0ZVTkRJTkdfT1VURkxPVxAJEiMKH0xJTUlUX0FDVElPTl9TVEFXSV9DT05UUklCVV'
    'RJT04QChIdChlMSU1JVF9BQ1RJT05fU1RBV0lfUEFZT1VUEAs=');

@$core.Deprecated('Use subjectTypeDescriptor instead')
const SubjectType$json = {
  '1': 'SubjectType',
  '2': [
    {'1': 'SUBJECT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SUBJECT_TYPE_CLIENT', '2': 1},
    {'1': 'SUBJECT_TYPE_ACCOUNT', '2': 2},
    {'1': 'SUBJECT_TYPE_PRODUCT', '2': 3},
    {'1': 'SUBJECT_TYPE_ORGANIZATION', '2': 4},
    {'1': 'SUBJECT_TYPE_ORG_UNIT', '2': 5},
    {'1': 'SUBJECT_TYPE_WORKFORCE_MEMBER', '2': 6},
  ],
};

/// Descriptor for `SubjectType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List subjectTypeDescriptor = $convert.base64Decode(
    'CgtTdWJqZWN0VHlwZRIcChhTVUJKRUNUX1RZUEVfVU5TUEVDSUZJRUQQABIXChNTVUJKRUNUX1'
    'RZUEVfQ0xJRU5UEAESGAoUU1VCSkVDVF9UWVBFX0FDQ09VTlQQAhIYChRTVUJKRUNUX1RZUEVf'
    'UFJPRFVDVBADEh0KGVNVQkpFQ1RfVFlQRV9PUkdBTklaQVRJT04QBBIZChVTVUJKRUNUX1RZUE'
    'VfT1JHX1VOSVQQBRIhCh1TVUJKRUNUX1RZUEVfV09SS0ZPUkNFX01FTUJFUhAG');

@$core.Deprecated('Use limitKindDescriptor instead')
const LimitKind$json = {
  '1': 'LimitKind',
  '2': [
    {'1': 'LIMIT_KIND_UNSPECIFIED', '2': 0},
    {'1': 'LIMIT_KIND_PER_TXN_MIN', '2': 1},
    {'1': 'LIMIT_KIND_PER_TXN_MAX', '2': 2},
    {'1': 'LIMIT_KIND_ROLLING_WINDOW_AMOUNT', '2': 3},
    {'1': 'LIMIT_KIND_ROLLING_WINDOW_COUNT', '2': 4},
  ],
};

/// Descriptor for `LimitKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List limitKindDescriptor = $convert.base64Decode(
    'CglMaW1pdEtpbmQSGgoWTElNSVRfS0lORF9VTlNQRUNJRklFRBAAEhoKFkxJTUlUX0tJTkRfUE'
    'VSX1RYTl9NSU4QARIaChZMSU1JVF9LSU5EX1BFUl9UWE5fTUFYEAISJAogTElNSVRfS0lORF9S'
    'T0xMSU5HX1dJTkRPV19BTU9VTlQQAxIjCh9MSU1JVF9LSU5EX1JPTExJTkdfV0lORE9XX0NPVU'
    '5UEAQ=');

@$core.Deprecated('Use policyModeDescriptor instead')
const PolicyMode$json = {
  '1': 'PolicyMode',
  '2': [
    {'1': 'POLICY_MODE_UNSPECIFIED', '2': 0},
    {'1': 'POLICY_MODE_OFF', '2': 1},
    {'1': 'POLICY_MODE_SHADOW', '2': 2},
    {'1': 'POLICY_MODE_ENFORCE', '2': 3},
  ],
};

/// Descriptor for `PolicyMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List policyModeDescriptor = $convert.base64Decode(
    'CgpQb2xpY3lNb2RlEhsKF1BPTElDWV9NT0RFX1VOU1BFQ0lGSUVEEAASEwoPUE9MSUNZX01PRE'
    'VfT0ZGEAESFgoSUE9MSUNZX01PREVfU0hBRE9XEAISFwoTUE9MSUNZX01PREVfRU5GT1JDRRAD');

@$core.Deprecated('Use policyScopeDescriptor instead')
const PolicyScope$json = {
  '1': 'PolicyScope',
  '2': [
    {'1': 'POLICY_SCOPE_UNSPECIFIED', '2': 0},
    {'1': 'POLICY_SCOPE_PLATFORM', '2': 1},
    {'1': 'POLICY_SCOPE_ORG', '2': 2},
    {'1': 'POLICY_SCOPE_ORG_UNIT', '2': 3},
  ],
};

/// Descriptor for `PolicyScope`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List policyScopeDescriptor = $convert.base64Decode(
    'CgtQb2xpY3lTY29wZRIcChhQT0xJQ1lfU0NPUEVfVU5TUEVDSUZJRUQQABIZChVQT0xJQ1lfU0'
    'NPUEVfUExBVEZPUk0QARIUChBQT0xJQ1lfU0NPUEVfT1JHEAISGQoVUE9MSUNZX1NDT1BFX09S'
    'R19VTklUEAM=');

@$core.Deprecated('Use reservationStatusDescriptor instead')
const ReservationStatus$json = {
  '1': 'ReservationStatus',
  '2': [
    {'1': 'RESERVATION_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'RESERVATION_STATUS_ACTIVE', '2': 1},
    {'1': 'RESERVATION_STATUS_PENDING_APPROVAL', '2': 2},
    {'1': 'RESERVATION_STATUS_COMMITTED', '2': 3},
    {'1': 'RESERVATION_STATUS_RELEASED', '2': 4},
    {'1': 'RESERVATION_STATUS_REVERSED', '2': 5},
    {'1': 'RESERVATION_STATUS_EXPIRED', '2': 6},
  ],
};

/// Descriptor for `ReservationStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List reservationStatusDescriptor = $convert.base64Decode(
    'ChFSZXNlcnZhdGlvblN0YXR1cxIiCh5SRVNFUlZBVElPTl9TVEFUVVNfVU5TUEVDSUZJRUQQAB'
    'IdChlSRVNFUlZBVElPTl9TVEFUVVNfQUNUSVZFEAESJwojUkVTRVJWQVRJT05fU1RBVFVTX1BF'
    'TkRJTkdfQVBQUk9WQUwQAhIgChxSRVNFUlZBVElPTl9TVEFUVVNfQ09NTUlUVEVEEAMSHwobUk'
    'VTRVJWQVRJT05fU1RBVFVTX1JFTEVBU0VEEAQSHwobUkVTRVJWQVRJT05fU1RBVFVTX1JFVkVS'
    'U0VEEAUSHgoaUkVTRVJWQVRJT05fU1RBVFVTX0VYUElSRUQQBg==');

@$core.Deprecated('Use approvalStatusDescriptor instead')
const ApprovalStatus$json = {
  '1': 'ApprovalStatus',
  '2': [
    {'1': 'APPROVAL_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'APPROVAL_STATUS_PENDING', '2': 1},
    {'1': 'APPROVAL_STATUS_APPROVED', '2': 2},
    {'1': 'APPROVAL_STATUS_REJECTED', '2': 3},
    {'1': 'APPROVAL_STATUS_EXPIRED', '2': 4},
    {'1': 'APPROVAL_STATUS_AUTO_REJECTED_ON_RECHECK', '2': 5},
  ],
};

/// Descriptor for `ApprovalStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List approvalStatusDescriptor = $convert.base64Decode(
    'Cg5BcHByb3ZhbFN0YXR1cxIfChtBUFBST1ZBTF9TVEFUVVNfVU5TUEVDSUZJRUQQABIbChdBUF'
    'BST1ZBTF9TVEFUVVNfUEVORElORxABEhwKGEFQUFJPVkFMX1NUQVRVU19BUFBST1ZFRBACEhwK'
    'GEFQUFJPVkFMX1NUQVRVU19SRUpFQ1RFRBADEhsKF0FQUFJPVkFMX1NUQVRVU19FWFBJUkVEEA'
    'QSLAooQVBQUk9WQUxfU1RBVFVTX0FVVE9fUkVKRUNURURfT05fUkVDSEVDSxAF');

@$core.Deprecated('Use limitsJobDescriptor instead')
const LimitsJob$json = {
  '1': 'LimitsJob',
  '2': [
    {'1': 'LIMITS_JOB_UNSPECIFIED', '2': 0},
    {'1': 'LIMITS_JOB_RESERVATION_EXPIRY', '2': 1},
    {'1': 'LIMITS_JOB_APPROVAL_EXPIRY', '2': 2},
  ],
};

/// Descriptor for `LimitsJob`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List limitsJobDescriptor = $convert.base64Decode(
    'CglMaW1pdHNKb2ISGgoWTElNSVRTX0pPQl9VTlNQRUNJRklFRBAAEiEKHUxJTUlUU19KT0JfUk'
    'VTRVJWQVRJT05fRVhQSVJZEAESHgoaTElNSVRTX0pPQl9BUFBST1ZBTF9FWFBJUlkQAg==');

@$core.Deprecated('Use subjectRefDescriptor instead')
const SubjectRef$json = {
  '1': 'SubjectRef',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.SubjectType',
      '8': {},
      '10': 'type'
    },
    {'1': 'id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `SubjectRef`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subjectRefDescriptor = $convert.base64Decode(
    'CgpTdWJqZWN0UmVmEjQKBHR5cGUYASABKA4yFi5saW1pdHMudjEuU3ViamVjdFR5cGVCCLpIBY'
    'IBAhABUgR0eXBlEhcKAmlkGAIgASgJQge6SARyAhABUgJpZA==');

@$core.Deprecated('Use approverTierDescriptor instead')
const ApproverTier$json = {
  '1': 'ApproverTier',
  '2': [
    {'1': 'up_to', '3': 1, '4': 1, '5': 3, '10': 'upTo'},
    {'1': 'role', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'role'},
    {'1': 'approvers', '3': 3, '4': 1, '5': 5, '8': {}, '10': 'approvers'},
  ],
};

/// Descriptor for `ApproverTier`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approverTierDescriptor = $convert.base64Decode(
    'CgxBcHByb3ZlclRpZXISEwoFdXBfdG8YASABKANSBHVwVG8SGwoEcm9sZRgCIAEoCUIHukgEcg'
    'IQAVIEcm9sZRInCglhcHByb3ZlcnMYAyABKAVCCbpIBhoEGAsoAVIJYXBwcm92ZXJz');

@$core.Deprecated('Use policyObjectDescriptor instead')
const PolicyObject$json = {
  '1': 'PolicyObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'tenantId'},
    {
      '1': 'scope',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.PolicyScope',
      '8': {},
      '10': 'scope'
    },
    {'1': 'org_unit_id', '3': 4, '4': 1, '5': 9, '10': 'orgUnitId'},
    {
      '1': 'action',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.LimitAction',
      '8': {},
      '10': 'action'
    },
    {
      '1': 'subject_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.SubjectType',
      '8': {},
      '10': 'subjectType'
    },
    {
      '1': 'currency_code',
      '3': 7,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'currencyCode'
    },
    {
      '1': 'limit_kind',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.LimitKind',
      '8': {},
      '10': 'limitKind'
    },
    {
      '1': 'window',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Duration',
      '10': 'window'
    },
    {
      '1': 'cap_amount',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '8': {},
      '10': 'capAmount'
    },
    {'1': 'cap_count', '3': 11, '4': 1, '5': 3, '8': {}, '10': 'capCount'},
    {
      '1': 'mode',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.PolicyMode',
      '8': {},
      '10': 'mode'
    },
    {
      '1': 'attribute_filter',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'attributeFilter'
    },
    {
      '1': 'approver_tiers',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.limits.v1.ApproverTier',
      '10': 'approverTiers'
    },
    {
      '1': 'approval_ttl',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Duration',
      '10': 'approvalTtl'
    },
    {
      '1': 'effective_from',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'effectiveFrom'
    },
    {
      '1': 'effective_to',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'effectiveTo'
    },
    {'1': 'notes', '3': 18, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'version', '3': 19, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'created_at',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'modified_at',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'modifiedAt'
    },
  ],
};

/// Descriptor for `PolicyObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyObjectDescriptor = $convert.base64Decode(
    'CgxQb2xpY3lPYmplY3QSFgoCaWQYASABKAlCBrpIA9gBAVICaWQSJAoJdGVuYW50X2lkGAIgAS'
    'gJQge6SARyAhAAUgh0ZW5hbnRJZBI2CgVzY29wZRgDIAEoDjIWLmxpbWl0cy52MS5Qb2xpY3lT'
    'Y29wZUIIukgFggECEAFSBXNjb3BlEh4KC29yZ191bml0X2lkGAQgASgJUglvcmdVbml0SWQSOA'
    'oGYWN0aW9uGAUgASgOMhYubGltaXRzLnYxLkxpbWl0QWN0aW9uQgi6SAWCAQIQAVIGYWN0aW9u'
    'EkMKDHN1YmplY3RfdHlwZRgGIAEoDjIWLmxpbWl0cy52MS5TdWJqZWN0VHlwZUIIukgFggECEA'
    'FSC3N1YmplY3RUeXBlEiwKDWN1cnJlbmN5X2NvZGUYByABKAlCB7pIBHICGANSDGN1cnJlbmN5'
    'Q29kZRI9CgpsaW1pdF9raW5kGAggASgOMhQubGltaXRzLnYxLkxpbWl0S2luZEIIukgFggECEA'
    'FSCWxpbWl0S2luZBIxCgZ3aW5kb3cYCSABKAsyGS5nb29nbGUucHJvdG9idWYuRHVyYXRpb25S'
    'BndpbmRvdxK4AQoKY2FwX2Ftb3VudBgKIAEoCzIQLmNvbW1vbi52MS5Nb25leUKGAbpIggG6AX'
    '8KGnBvbGljeS5jYXBfYW1vdW50LnBvc2l0aXZlEipjYXBfYW1vdW50IG11c3QgYmUgYXQgbGVh'
    'c3Qgb25lIG1pbm9yIHVuaXQaNXRoaXMudW5pdHMgPiAwIHx8ICh0aGlzLnVuaXRzID09IDAgJi'
    'YgdGhpcy5uYW5vcyA+IDApUgljYXBBbW91bnQSJwoJY2FwX2NvdW50GAsgASgDQgq6SAfYAQEi'
    'AigBUghjYXBDb3VudBIzCgRtb2RlGAwgASgOMhUubGltaXRzLnYxLlBvbGljeU1vZGVCCLpIBY'
    'IBAhABUgRtb2RlEkIKEGF0dHJpYnV0ZV9maWx0ZXIYDSABKAsyFy5nb29nbGUucHJvdG9idWYu'
    'U3RydWN0Ug9hdHRyaWJ1dGVGaWx0ZXISPgoOYXBwcm92ZXJfdGllcnMYDiADKAsyFy5saW1pdH'
    'MudjEuQXBwcm92ZXJUaWVyUg1hcHByb3ZlclRpZXJzEjwKDGFwcHJvdmFsX3R0bBgPIAEoCzIZ'
    'Lmdvb2dsZS5wcm90b2J1Zi5EdXJhdGlvblILYXBwcm92YWxUdGwSQQoOZWZmZWN0aXZlX2Zyb2'
    '0YECABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUg1lZmZlY3RpdmVGcm9tEj0KDGVm'
    'ZmVjdGl2ZV90bxgRIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSC2VmZmVjdGl2ZV'
    'RvEhQKBW5vdGVzGBIgASgJUgVub3RlcxIYCgd2ZXJzaW9uGBMgASgFUgd2ZXJzaW9uEjkKCmNy'
    'ZWF0ZWRfYXQYFCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOw'
    'oLbW9kaWZpZWRfYXQYFSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgptb2RpZmll'
    'ZEF0');

@$core.Deprecated('Use limitIntentDescriptor instead')
const LimitIntent$json = {
  '1': 'LimitIntent',
  '2': [
    {
      '1': 'action',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.LimitAction',
      '8': {},
      '10': 'action'
    },
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'tenantId'},
    {'1': 'org_unit_id', '3': 3, '4': 1, '5': 9, '10': 'orgUnitId'},
    {
      '1': 'amount',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '8': {},
      '10': 'amount'
    },
    {
      '1': 'subjects',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.limits.v1.SubjectRef',
      '8': {},
      '10': 'subjects'
    },
    {'1': 'maker_id', '3': 6, '4': 1, '5': 9, '10': 'makerId'},
  ],
};

/// Descriptor for `LimitIntent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List limitIntentDescriptor = $convert.base64Decode(
    'CgtMaW1pdEludGVudBI4CgZhY3Rpb24YASABKA4yFi5saW1pdHMudjEuTGltaXRBY3Rpb25CCL'
    'pIBYIBAhABUgZhY3Rpb24SJAoJdGVuYW50X2lkGAIgASgJQge6SARyAhADUgh0ZW5hbnRJZBIe'
    'CgtvcmdfdW5pdF9pZBgDIAEoCVIJb3JnVW5pdElkEjAKBmFtb3VudBgEIAEoCzIQLmNvbW1vbi'
    '52MS5Nb25leUIGukgDyAEBUgZhbW91bnQSOwoIc3ViamVjdHMYBSADKAsyFS5saW1pdHMudjEu'
    'U3ViamVjdFJlZkIIukgFkgECCAFSCHN1YmplY3RzEhkKCG1ha2VyX2lkGAYgASgJUgdtYWtlck'
    'lk');

@$core.Deprecated('Use policyVerdictDescriptor instead')
const PolicyVerdict$json = {
  '1': 'PolicyVerdict',
  '2': [
    {'1': 'policy_id', '3': 1, '4': 1, '5': 9, '10': 'policyId'},
    {'1': 'policy_version', '3': 2, '4': 1, '5': 5, '10': 'policyVersion'},
    {'1': 'matched', '3': 3, '4': 1, '5': 8, '10': 'matched'},
    {'1': 'breached', '3': 4, '4': 1, '5': 8, '10': 'breached'},
    {
      '1': 'would_require_approval',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'wouldRequireApproval'
    },
    {
      '1': 'mode',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.PolicyMode',
      '10': 'mode'
    },
    {'1': 'reason', '3': 7, '4': 1, '5': 9, '10': 'reason'},
    {
      '1': 'current_usage',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'currentUsage'
    },
    {
      '1': 'cap_amount',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'capAmount'
    },
    {'1': 'current_count', '3': 10, '4': 1, '5': 3, '10': 'currentCount'},
    {'1': 'cap_count', '3': 11, '4': 1, '5': 3, '10': 'capCount'},
  ],
};

/// Descriptor for `PolicyVerdict`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyVerdictDescriptor = $convert.base64Decode(
    'Cg1Qb2xpY3lWZXJkaWN0EhsKCXBvbGljeV9pZBgBIAEoCVIIcG9saWN5SWQSJQoOcG9saWN5X3'
    'ZlcnNpb24YAiABKAVSDXBvbGljeVZlcnNpb24SGAoHbWF0Y2hlZBgDIAEoCFIHbWF0Y2hlZBIa'
    'CghicmVhY2hlZBgEIAEoCFIIYnJlYWNoZWQSNAoWd291bGRfcmVxdWlyZV9hcHByb3ZhbBgFIA'
    'EoCFIUd291bGRSZXF1aXJlQXBwcm92YWwSKQoEbW9kZRgGIAEoDjIVLmxpbWl0cy52MS5Qb2xp'
    'Y3lNb2RlUgRtb2RlEhYKBnJlYXNvbhgHIAEoCVIGcmVhc29uEjUKDWN1cnJlbnRfdXNhZ2UYCC'
    'ABKAsyEC5jb21tb24udjEuTW9uZXlSDGN1cnJlbnRVc2FnZRIvCgpjYXBfYW1vdW50GAkgASgL'
    'MhAuY29tbW9uLnYxLk1vbmV5UgljYXBBbW91bnQSIwoNY3VycmVudF9jb3VudBgKIAEoA1IMY3'
    'VycmVudENvdW50EhsKCWNhcF9jb3VudBgLIAEoA1IIY2FwQ291bnQ=');

@$core.Deprecated('Use policySaveRequestDescriptor instead')
const PolicySaveRequest$json = {
  '1': 'PolicySaveRequest',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.PolicyObject',
      '8': {},
      '10': 'data'
    },
  ],
};

/// Descriptor for `PolicySaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policySaveRequestDescriptor = $convert.base64Decode(
    'ChFQb2xpY3lTYXZlUmVxdWVzdBIzCgRkYXRhGAEgASgLMhcubGltaXRzLnYxLlBvbGljeU9iam'
    'VjdEIGukgDyAEBUgRkYXRh');

@$core.Deprecated('Use policySaveResponseDescriptor instead')
const PolicySaveResponse$json = {
  '1': 'PolicySaveResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.PolicyObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `PolicySaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policySaveResponseDescriptor = $convert.base64Decode(
    'ChJQb2xpY3lTYXZlUmVzcG9uc2USKwoEZGF0YRgBIAEoCzIXLmxpbWl0cy52MS5Qb2xpY3lPYm'
    'plY3RSBGRhdGE=');

@$core.Deprecated('Use policyGetRequestDescriptor instead')
const PolicyGetRequest$json = {
  '1': 'PolicyGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `PolicyGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyGetRequestDescriptor = $convert.base64Decode(
    'ChBQb2xpY3lHZXRSZXF1ZXN0EhcKAmlkGAEgASgJQge6SARyAhABUgJpZA==');

@$core.Deprecated('Use policyGetResponseDescriptor instead')
const PolicyGetResponse$json = {
  '1': 'PolicyGetResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.PolicyObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `PolicyGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyGetResponseDescriptor = $convert.base64Decode(
    'ChFQb2xpY3lHZXRSZXNwb25zZRIrCgRkYXRhGAEgASgLMhcubGltaXRzLnYxLlBvbGljeU9iam'
    'VjdFIEZGF0YQ==');

@$core.Deprecated('Use policySearchRequestDescriptor instead')
const PolicySearchRequest$json = {
  '1': 'PolicySearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'org_unit_id', '3': 3, '4': 1, '5': 9, '10': 'orgUnitId'},
    {
      '1': 'action',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.LimitAction',
      '10': 'action'
    },
    {
      '1': 'subject_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.SubjectType',
      '10': 'subjectType'
    },
    {
      '1': 'mode',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.PolicyMode',
      '10': 'mode'
    },
    {
      '1': 'cursor',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.common.v1.PageCursor',
      '10': 'cursor'
    },
  ],
};

/// Descriptor for `PolicySearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policySearchRequestDescriptor = $convert.base64Decode(
    'ChNQb2xpY3lTZWFyY2hSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeRIbCgl0ZW5hbnRfaW'
    'QYAiABKAlSCHRlbmFudElkEh4KC29yZ191bml0X2lkGAMgASgJUglvcmdVbml0SWQSLgoGYWN0'
    'aW9uGAQgASgOMhYubGltaXRzLnYxLkxpbWl0QWN0aW9uUgZhY3Rpb24SOQoMc3ViamVjdF90eX'
    'BlGAUgASgOMhYubGltaXRzLnYxLlN1YmplY3RUeXBlUgtzdWJqZWN0VHlwZRIpCgRtb2RlGAYg'
    'ASgOMhUubGltaXRzLnYxLlBvbGljeU1vZGVSBG1vZGUSLQoGY3Vyc29yGAcgASgLMhUuY29tbW'
    '9uLnYxLlBhZ2VDdXJzb3JSBmN1cnNvcg==');

@$core.Deprecated('Use policySearchResponseDescriptor instead')
const PolicySearchResponse$json = {
  '1': 'PolicySearchResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.limits.v1.PolicyObject',
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

/// Descriptor for `PolicySearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policySearchResponseDescriptor = $convert.base64Decode(
    'ChRQb2xpY3lTZWFyY2hSZXNwb25zZRIrCgRkYXRhGAEgAygLMhcubGltaXRzLnYxLlBvbGljeU'
    '9iamVjdFIEZGF0YRI2CgtuZXh0X2N1cnNvchgCIAEoCzIVLmNvbW1vbi52MS5QYWdlQ3Vyc29y'
    'UgpuZXh0Q3Vyc29y');

@$core.Deprecated('Use policyDeleteRequestDescriptor instead')
const PolicyDeleteRequest$json = {
  '1': 'PolicyDeleteRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `PolicyDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyDeleteRequestDescriptor =
    $convert.base64Decode(
        'ChNQb2xpY3lEZWxldGVSZXF1ZXN0EhcKAmlkGAEgASgJQge6SARyAhABUgJpZA==');

@$core.Deprecated('Use policyDeleteResponseDescriptor instead')
const PolicyDeleteResponse$json = {
  '1': 'PolicyDeleteResponse',
};

/// Descriptor for `PolicyDeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyDeleteResponseDescriptor =
    $convert.base64Decode('ChRQb2xpY3lEZWxldGVSZXNwb25zZQ==');

@$core.Deprecated('Use policyVersionObjectDescriptor instead')
const PolicyVersionObject$json = {
  '1': 'PolicyVersionObject',
  '2': [
    {'1': 'policy_id', '3': 1, '4': 1, '5': 9, '10': 'policyId'},
    {'1': 'version', '3': 2, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'snapshot',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.PolicyObject',
      '10': 'snapshot'
    },
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `PolicyVersionObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyVersionObjectDescriptor = $convert.base64Decode(
    'ChNQb2xpY3lWZXJzaW9uT2JqZWN0EhsKCXBvbGljeV9pZBgBIAEoCVIIcG9saWN5SWQSGAoHdm'
    'Vyc2lvbhgCIAEoBVIHdmVyc2lvbhIzCghzbmFwc2hvdBgDIAEoCzIXLmxpbWl0cy52MS5Qb2xp'
    'Y3lPYmplY3RSCHNuYXBzaG90EjkKCmNyZWF0ZWRfYXQYBCABKAsyGi5nb29nbGUucHJvdG9idW'
    'YuVGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use policyHistoryRequestDescriptor instead')
const PolicyHistoryRequest$json = {
  '1': 'PolicyHistoryRequest',
  '2': [
    {'1': 'policy_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'policyId'},
    {
      '1': 'cursor',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.v1.PageCursor',
      '10': 'cursor'
    },
  ],
};

/// Descriptor for `PolicyHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyHistoryRequestDescriptor = $convert.base64Decode(
    'ChRQb2xpY3lIaXN0b3J5UmVxdWVzdBIkCglwb2xpY3lfaWQYASABKAlCB7pIBHICEAFSCHBvbG'
    'ljeUlkEi0KBmN1cnNvchgCIAEoCzIVLmNvbW1vbi52MS5QYWdlQ3Vyc29yUgZjdXJzb3I=');

@$core.Deprecated('Use policyHistoryResponseDescriptor instead')
const PolicyHistoryResponse$json = {
  '1': 'PolicyHistoryResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.limits.v1.PolicyVersionObject',
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

/// Descriptor for `PolicyHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyHistoryResponseDescriptor = $convert.base64Decode(
    'ChVQb2xpY3lIaXN0b3J5UmVzcG9uc2USMgoEZGF0YRgBIAMoCzIeLmxpbWl0cy52MS5Qb2xpY3'
    'lWZXJzaW9uT2JqZWN0UgRkYXRhEjYKC25leHRfY3Vyc29yGAIgASgLMhUuY29tbW9uLnYxLlBh'
    'Z2VDdXJzb3JSCm5leHRDdXJzb3I=');

@$core.Deprecated('Use approvalDecisionObjectDescriptor instead')
const ApprovalDecisionObject$json = {
  '1': 'ApprovalDecisionObject',
  '2': [
    {'1': 'approver_id', '3': 1, '4': 1, '5': 9, '10': 'approverId'},
    {'1': 'decision', '3': 2, '4': 1, '5': 9, '10': 'decision'},
    {'1': 'note', '3': 3, '4': 1, '5': 9, '10': 'note'},
    {
      '1': 'decided_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'decidedAt'
    },
  ],
};

/// Descriptor for `ApprovalDecisionObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approvalDecisionObjectDescriptor = $convert.base64Decode(
    'ChZBcHByb3ZhbERlY2lzaW9uT2JqZWN0Eh8KC2FwcHJvdmVyX2lkGAEgASgJUgphcHByb3Zlck'
    'lkEhoKCGRlY2lzaW9uGAIgASgJUghkZWNpc2lvbhISCgRub3RlGAMgASgJUgRub3RlEjkKCmRl'
    'Y2lkZWRfYXQYBCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglkZWNpZGVkQXQ=');

@$core.Deprecated('Use approvalRequestObjectDescriptor instead')
const ApprovalRequestObject$json = {
  '1': 'ApprovalRequestObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'reservation_id', '3': 2, '4': 1, '5': 9, '10': 'reservationId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'org_unit_id', '3': 4, '4': 1, '5': 9, '10': 'orgUnitId'},
    {
      '1': 'triggering_policy_id',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'triggeringPolicyId'
    },
    {'1': 'policy_version', '3': 6, '4': 1, '5': 5, '10': 'policyVersion'},
    {
      '1': 'action',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.LimitAction',
      '10': 'action'
    },
    {
      '1': 'amount',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
    {'1': 'required_role', '3': 9, '4': 1, '5': 9, '10': 'requiredRole'},
    {'1': 'required_count', '3': 10, '4': 1, '5': 5, '10': 'requiredCount'},
    {'1': 'maker_id', '3': 11, '4': 1, '5': 9, '10': 'makerId'},
    {
      '1': 'status',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.ApprovalStatus',
      '10': 'status'
    },
    {
      '1': 'submitted_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'submittedAt'
    },
    {
      '1': 'expires_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
    {
      '1': 'decided_at',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'decidedAt'
    },
    {
      '1': 'decisions',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.limits.v1.ApprovalDecisionObject',
      '10': 'decisions'
    },
  ],
};

/// Descriptor for `ApprovalRequestObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approvalRequestObjectDescriptor = $convert.base64Decode(
    'ChVBcHByb3ZhbFJlcXVlc3RPYmplY3QSDgoCaWQYASABKAlSAmlkEiUKDnJlc2VydmF0aW9uX2'
    'lkGAIgASgJUg1yZXNlcnZhdGlvbklkEhsKCXRlbmFudF9pZBgDIAEoCVIIdGVuYW50SWQSHgoL'
    'b3JnX3VuaXRfaWQYBCABKAlSCW9yZ1VuaXRJZBIwChR0cmlnZ2VyaW5nX3BvbGljeV9pZBgFIA'
    'EoCVISdHJpZ2dlcmluZ1BvbGljeUlkEiUKDnBvbGljeV92ZXJzaW9uGAYgASgFUg1wb2xpY3lW'
    'ZXJzaW9uEi4KBmFjdGlvbhgHIAEoDjIWLmxpbWl0cy52MS5MaW1pdEFjdGlvblIGYWN0aW9uEi'
    'gKBmFtb3VudBgIIAEoCzIQLmNvbW1vbi52MS5Nb25leVIGYW1vdW50EiMKDXJlcXVpcmVkX3Jv'
    'bGUYCSABKAlSDHJlcXVpcmVkUm9sZRIlCg5yZXF1aXJlZF9jb3VudBgKIAEoBVINcmVxdWlyZW'
    'RDb3VudBIZCghtYWtlcl9pZBgLIAEoCVIHbWFrZXJJZBIxCgZzdGF0dXMYDCABKA4yGS5saW1p'
    'dHMudjEuQXBwcm92YWxTdGF0dXNSBnN0YXR1cxI9CgxzdWJtaXR0ZWRfYXQYDSABKAsyGi5nb2'
    '9nbGUucHJvdG9idWYuVGltZXN0YW1wUgtzdWJtaXR0ZWRBdBI5CgpleHBpcmVzX2F0GA4gASgL'
    'MhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJZXhwaXJlc0F0EjkKCmRlY2lkZWRfYXQYDy'
    'ABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglkZWNpZGVkQXQSPwoJZGVjaXNpb25z'
    'GBAgAygLMiEubGltaXRzLnYxLkFwcHJvdmFsRGVjaXNpb25PYmplY3RSCWRlY2lzaW9ucw==');

@$core.Deprecated('Use approvalRequestListRequestDescriptor instead')
const ApprovalRequestListRequest$json = {
  '1': 'ApprovalRequestListRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.ApprovalStatus',
      '10': 'status'
    },
    {'1': 'required_role', '3': 3, '4': 1, '5': 9, '10': 'requiredRole'},
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

/// Descriptor for `ApprovalRequestListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approvalRequestListRequestDescriptor = $convert.base64Decode(
    'ChpBcHByb3ZhbFJlcXVlc3RMaXN0UmVxdWVzdBIbCgl0ZW5hbnRfaWQYASABKAlSCHRlbmFudE'
    'lkEjEKBnN0YXR1cxgCIAEoDjIZLmxpbWl0cy52MS5BcHByb3ZhbFN0YXR1c1IGc3RhdHVzEiMK'
    'DXJlcXVpcmVkX3JvbGUYAyABKAlSDHJlcXVpcmVkUm9sZRItCgZjdXJzb3IYBCABKAsyFS5jb2'
    '1tb24udjEuUGFnZUN1cnNvclIGY3Vyc29y');

@$core.Deprecated('Use approvalRequestListResponseDescriptor instead')
const ApprovalRequestListResponse$json = {
  '1': 'ApprovalRequestListResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.limits.v1.ApprovalRequestObject',
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

/// Descriptor for `ApprovalRequestListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approvalRequestListResponseDescriptor =
    $convert.base64Decode(
        'ChtBcHByb3ZhbFJlcXVlc3RMaXN0UmVzcG9uc2USNAoEZGF0YRgBIAMoCzIgLmxpbWl0cy52MS'
        '5BcHByb3ZhbFJlcXVlc3RPYmplY3RSBGRhdGESNgoLbmV4dF9jdXJzb3IYAiABKAsyFS5jb21t'
        'b24udjEuUGFnZUN1cnNvclIKbmV4dEN1cnNvcg==');

@$core.Deprecated('Use approvalRequestGetRequestDescriptor instead')
const ApprovalRequestGetRequest$json = {
  '1': 'ApprovalRequestGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `ApprovalRequestGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approvalRequestGetRequestDescriptor =
    $convert.base64Decode(
        'ChlBcHByb3ZhbFJlcXVlc3RHZXRSZXF1ZXN0EhcKAmlkGAEgASgJQge6SARyAhABUgJpZA==');

@$core.Deprecated('Use approvalRequestGetResponseDescriptor instead')
const ApprovalRequestGetResponse$json = {
  '1': 'ApprovalRequestGetResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.ApprovalRequestObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `ApprovalRequestGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approvalRequestGetResponseDescriptor =
    $convert.base64Decode(
        'ChpBcHByb3ZhbFJlcXVlc3RHZXRSZXNwb25zZRI0CgRkYXRhGAEgASgLMiAubGltaXRzLnYxLk'
        'FwcHJvdmFsUmVxdWVzdE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use approvalRequestDecideRequestDescriptor instead')
const ApprovalRequestDecideRequest$json = {
  '1': 'ApprovalRequestDecideRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'decision', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'decision'},
    {'1': 'note', '3': 3, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `ApprovalRequestDecideRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approvalRequestDecideRequestDescriptor =
    $convert.base64Decode(
        'ChxBcHByb3ZhbFJlcXVlc3REZWNpZGVSZXF1ZXN0EhcKAmlkGAEgASgJQge6SARyAhABUgJpZB'
        'IyCghkZWNpc2lvbhgCIAEoCUIWukgTchFSB2FwcHJvdmVSBnJlamVjdFIIZGVjaXNpb24SEgoE'
        'bm90ZRgDIAEoCVIEbm90ZQ==');

@$core.Deprecated('Use approvalRequestDecideResponseDescriptor instead')
const ApprovalRequestDecideResponse$json = {
  '1': 'ApprovalRequestDecideResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.ApprovalRequestObject',
      '10': 'data'
    },
  ],
};

/// Descriptor for `ApprovalRequestDecideResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approvalRequestDecideResponseDescriptor =
    $convert.base64Decode(
        'Ch1BcHByb3ZhbFJlcXVlc3REZWNpZGVSZXNwb25zZRI0CgRkYXRhGAEgASgLMiAubGltaXRzLn'
        'YxLkFwcHJvdmFsUmVxdWVzdE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use ledgerEntryObjectDescriptor instead')
const LedgerEntryObject$json = {
  '1': 'LedgerEntryObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'reservation_id', '3': 2, '4': 1, '5': 9, '10': 'reservationId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'org_unit_id', '3': 4, '4': 1, '5': 9, '10': 'orgUnitId'},
    {
      '1': 'action',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.LimitAction',
      '10': 'action'
    },
    {
      '1': 'subject_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.SubjectType',
      '10': 'subjectType'
    },
    {'1': 'subject_id', '3': 7, '4': 1, '5': 9, '10': 'subjectId'},
    {
      '1': 'amount',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
    {
      '1': 'committed_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'committedAt'
    },
    {
      '1': 'reversed_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'reversedAt'
    },
  ],
};

/// Descriptor for `LedgerEntryObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ledgerEntryObjectDescriptor = $convert.base64Decode(
    'ChFMZWRnZXJFbnRyeU9iamVjdBIOCgJpZBgBIAEoCVICaWQSJQoOcmVzZXJ2YXRpb25faWQYAi'
    'ABKAlSDXJlc2VydmF0aW9uSWQSGwoJdGVuYW50X2lkGAMgASgJUgh0ZW5hbnRJZBIeCgtvcmdf'
    'dW5pdF9pZBgEIAEoCVIJb3JnVW5pdElkEi4KBmFjdGlvbhgFIAEoDjIWLmxpbWl0cy52MS5MaW'
    '1pdEFjdGlvblIGYWN0aW9uEjkKDHN1YmplY3RfdHlwZRgGIAEoDjIWLmxpbWl0cy52MS5TdWJq'
    'ZWN0VHlwZVILc3ViamVjdFR5cGUSHQoKc3ViamVjdF9pZBgHIAEoCVIJc3ViamVjdElkEigKBm'
    'Ftb3VudBgIIAEoCzIQLmNvbW1vbi52MS5Nb25leVIGYW1vdW50Ej0KDGNvbW1pdHRlZF9hdBgJ'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSC2NvbW1pdHRlZEF0EjsKC3JldmVyc2'
    'VkX2F0GAogASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKcmV2ZXJzZWRBdA==');

@$core.Deprecated('Use ledgerSearchRequestDescriptor instead')
const LedgerSearchRequest$json = {
  '1': 'LedgerSearchRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {
      '1': 'action',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.LimitAction',
      '10': 'action'
    },
    {
      '1': 'subject_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.SubjectType',
      '10': 'subjectType'
    },
    {'1': 'subject_id', '3': 4, '4': 1, '5': 9, '10': 'subjectId'},
    {'1': 'currency_code', '3': 5, '4': 1, '5': 9, '10': 'currencyCode'},
    {
      '1': 'from',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'from'
    },
    {
      '1': 'to',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'to'
    },
    {
      '1': 'cursor',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.common.v1.PageCursor',
      '10': 'cursor'
    },
  ],
};

/// Descriptor for `LedgerSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ledgerSearchRequestDescriptor = $convert.base64Decode(
    'ChNMZWRnZXJTZWFyY2hSZXF1ZXN0EhsKCXRlbmFudF9pZBgBIAEoCVIIdGVuYW50SWQSLgoGYW'
    'N0aW9uGAIgASgOMhYubGltaXRzLnYxLkxpbWl0QWN0aW9uUgZhY3Rpb24SOQoMc3ViamVjdF90'
    'eXBlGAMgASgOMhYubGltaXRzLnYxLlN1YmplY3RUeXBlUgtzdWJqZWN0VHlwZRIdCgpzdWJqZW'
    'N0X2lkGAQgASgJUglzdWJqZWN0SWQSIwoNY3VycmVuY3lfY29kZRgFIAEoCVIMY3VycmVuY3lD'
    'b2RlEi4KBGZyb20YBiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgRmcm9tEioKAn'
    'RvGAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFICdG8SLQoGY3Vyc29yGAggASgL'
    'MhUuY29tbW9uLnYxLlBhZ2VDdXJzb3JSBmN1cnNvcg==');

@$core.Deprecated('Use ledgerSearchResponseDescriptor instead')
const LedgerSearchResponse$json = {
  '1': 'LedgerSearchResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.limits.v1.LedgerEntryObject',
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

/// Descriptor for `LedgerSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ledgerSearchResponseDescriptor = $convert.base64Decode(
    'ChRMZWRnZXJTZWFyY2hSZXNwb25zZRIwCgRkYXRhGAEgAygLMhwubGltaXRzLnYxLkxlZGdlck'
    'VudHJ5T2JqZWN0UgRkYXRhEjYKC25leHRfY3Vyc29yGAIgASgLMhUuY29tbW9uLnYxLlBhZ2VD'
    'dXJzb3JSCm5leHRDdXJzb3I=');

@$core.Deprecated('Use limitsAuditEventObjectDescriptor instead')
const LimitsAuditEventObject$json = {
  '1': 'LimitsAuditEventObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'entity_type', '3': 2, '4': 1, '5': 9, '10': 'entityType'},
    {'1': 'entity_id', '3': 3, '4': 1, '5': 9, '10': 'entityId'},
    {'1': 'action', '3': 4, '4': 1, '5': 9, '10': 'action'},
    {'1': 'actor_id', '3': 5, '4': 1, '5': 9, '10': 'actorId'},
    {'1': 'actor_type', '3': 6, '4': 1, '5': 9, '10': 'actorType'},
    {'1': 'reason', '3': 7, '4': 1, '5': 9, '10': 'reason'},
    {
      '1': 'metadata',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'metadata'
    },
    {
      '1': 'occurred_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'occurredAt'
    },
  ],
};

/// Descriptor for `LimitsAuditEventObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List limitsAuditEventObjectDescriptor = $convert.base64Decode(
    'ChZMaW1pdHNBdWRpdEV2ZW50T2JqZWN0Eg4KAmlkGAEgASgJUgJpZBIfCgtlbnRpdHlfdHlwZR'
    'gCIAEoCVIKZW50aXR5VHlwZRIbCgllbnRpdHlfaWQYAyABKAlSCGVudGl0eUlkEhYKBmFjdGlv'
    'bhgEIAEoCVIGYWN0aW9uEhkKCGFjdG9yX2lkGAUgASgJUgdhY3RvcklkEh0KCmFjdG9yX3R5cG'
    'UYBiABKAlSCWFjdG9yVHlwZRIWCgZyZWFzb24YByABKAlSBnJlYXNvbhIzCghtZXRhZGF0YRgI'
    'IAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSCG1ldGFkYXRhEjsKC29jY3VycmVkX2F0GA'
    'kgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKb2NjdXJyZWRBdA==');

@$core.Deprecated('Use limitsAuditSearchRequestDescriptor instead')
const LimitsAuditSearchRequest$json = {
  '1': 'LimitsAuditSearchRequest',
  '2': [
    {'1': 'actions', '3': 1, '4': 3, '5': 9, '10': 'actions'},
    {'1': 'entity_type', '3': 2, '4': 1, '5': 9, '10': 'entityType'},
    {'1': 'entity_id', '3': 3, '4': 1, '5': 9, '10': 'entityId'},
    {'1': 'actor_id', '3': 4, '4': 1, '5': 9, '10': 'actorId'},
    {
      '1': 'from',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'from'
    },
    {
      '1': 'to',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'to'
    },
    {
      '1': 'cursor',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.common.v1.PageCursor',
      '10': 'cursor'
    },
    {'1': 'tenant_id', '3': 8, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `LimitsAuditSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List limitsAuditSearchRequestDescriptor = $convert.base64Decode(
    'ChhMaW1pdHNBdWRpdFNlYXJjaFJlcXVlc3QSGAoHYWN0aW9ucxgBIAMoCVIHYWN0aW9ucxIfCg'
    'tlbnRpdHlfdHlwZRgCIAEoCVIKZW50aXR5VHlwZRIbCgllbnRpdHlfaWQYAyABKAlSCGVudGl0'
    'eUlkEhkKCGFjdG9yX2lkGAQgASgJUgdhY3RvcklkEi4KBGZyb20YBSABKAsyGi5nb29nbGUucH'
    'JvdG9idWYuVGltZXN0YW1wUgRmcm9tEioKAnRvGAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRp'
    'bWVzdGFtcFICdG8SLQoGY3Vyc29yGAcgASgLMhUuY29tbW9uLnYxLlBhZ2VDdXJzb3JSBmN1cn'
    'NvchIbCgl0ZW5hbnRfaWQYCCABKAlSCHRlbmFudElk');

@$core.Deprecated('Use limitsAuditSearchResponseDescriptor instead')
const LimitsAuditSearchResponse$json = {
  '1': 'LimitsAuditSearchResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.limits.v1.LimitsAuditEventObject',
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

/// Descriptor for `LimitsAuditSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List limitsAuditSearchResponseDescriptor = $convert.base64Decode(
    'ChlMaW1pdHNBdWRpdFNlYXJjaFJlc3BvbnNlEjUKBGRhdGEYASADKAsyIS5saW1pdHMudjEuTG'
    'ltaXRzQXVkaXRFdmVudE9iamVjdFIEZGF0YRI2CgtuZXh0X2N1cnNvchgCIAEoCzIVLmNvbW1v'
    'bi52MS5QYWdlQ3Vyc29yUgpuZXh0Q3Vyc29y');

@$core.Deprecated('Use checkRequestDescriptor instead')
const CheckRequest$json = {
  '1': 'CheckRequest',
  '2': [
    {
      '1': 'intent',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.LimitIntent',
      '8': {},
      '10': 'intent'
    },
  ],
};

/// Descriptor for `CheckRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkRequestDescriptor = $convert.base64Decode(
    'CgxDaGVja1JlcXVlc3QSNgoGaW50ZW50GAEgASgLMhYubGltaXRzLnYxLkxpbWl0SW50ZW50Qg'
    'a6SAPIAQFSBmludGVudA==');

@$core.Deprecated('Use checkResponseDescriptor instead')
const CheckResponse$json = {
  '1': 'CheckResponse',
  '2': [
    {'1': 'allowed', '3': 1, '4': 1, '5': 8, '10': 'allowed'},
    {
      '1': 'requires_approval',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'requiresApproval'
    },
    {
      '1': 'required_approvers',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'requiredApprovers'
    },
    {'1': 'required_role', '3': 4, '4': 1, '5': 9, '10': 'requiredRole'},
    {
      '1': 'verdicts',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.limits.v1.PolicyVerdict',
      '10': 'verdicts'
    },
    {
      '1': 'breached_policy_ids',
      '3': 6,
      '4': 3,
      '5': 9,
      '10': 'breachedPolicyIds'
    },
  ],
};

/// Descriptor for `CheckResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkResponseDescriptor = $convert.base64Decode(
    'Cg1DaGVja1Jlc3BvbnNlEhgKB2FsbG93ZWQYASABKAhSB2FsbG93ZWQSKwoRcmVxdWlyZXNfYX'
    'Bwcm92YWwYAiABKAhSEHJlcXVpcmVzQXBwcm92YWwSLQoScmVxdWlyZWRfYXBwcm92ZXJzGAMg'
    'ASgFUhFyZXF1aXJlZEFwcHJvdmVycxIjCg1yZXF1aXJlZF9yb2xlGAQgASgJUgxyZXF1aXJlZF'
    'JvbGUSNAoIdmVyZGljdHMYBSADKAsyGC5saW1pdHMudjEuUG9saWN5VmVyZGljdFIIdmVyZGlj'
    'dHMSLgoTYnJlYWNoZWRfcG9saWN5X2lkcxgGIAMoCVIRYnJlYWNoZWRQb2xpY3lJZHM=');

@$core.Deprecated('Use reservationObjectDescriptor instead')
const ReservationObject$json = {
  '1': 'ReservationObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'idempotency_key', '3': 3, '4': 1, '5': 9, '10': 'idempotencyKey'},
    {'1': 'org_unit_id', '3': 4, '4': 1, '5': 9, '10': 'orgUnitId'},
    {
      '1': 'action',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.LimitAction',
      '10': 'action'
    },
    {
      '1': 'amount',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.common.v1.Money',
      '10': 'amount'
    },
    {
      '1': 'subjects',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.limits.v1.SubjectRef',
      '10': 'subjects'
    },
    {'1': 'maker_id', '3': 8, '4': 1, '5': 9, '10': 'makerId'},
    {
      '1': 'status',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.ReservationStatus',
      '10': 'status'
    },
    {'1': 'is_shadow', '3': 10, '4': 1, '5': 8, '10': 'isShadow'},
    {
      '1': 'reserved_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'reservedAt'
    },
    {
      '1': 'ttl_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'ttlAt'
    },
    {
      '1': 'committed_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'committedAt'
    },
    {
      '1': 'released_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'releasedAt'
    },
    {
      '1': 'reverses_reservation_id',
      '3': 15,
      '4': 1,
      '5': 9,
      '10': 'reversesReservationId'
    },
    {'1': 'notes', '3': 16, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `ReservationObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reservationObjectDescriptor = $convert.base64Decode(
    'ChFSZXNlcnZhdGlvbk9iamVjdBIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUg'
    'h0ZW5hbnRJZBInCg9pZGVtcG90ZW5jeV9rZXkYAyABKAlSDmlkZW1wb3RlbmN5S2V5Eh4KC29y'
    'Z191bml0X2lkGAQgASgJUglvcmdVbml0SWQSLgoGYWN0aW9uGAUgASgOMhYubGltaXRzLnYxLk'
    'xpbWl0QWN0aW9uUgZhY3Rpb24SKAoGYW1vdW50GAYgASgLMhAuY29tbW9uLnYxLk1vbmV5UgZh'
    'bW91bnQSMQoIc3ViamVjdHMYByADKAsyFS5saW1pdHMudjEuU3ViamVjdFJlZlIIc3ViamVjdH'
    'MSGQoIbWFrZXJfaWQYCCABKAlSB21ha2VySWQSNAoGc3RhdHVzGAkgASgOMhwubGltaXRzLnYx'
    'LlJlc2VydmF0aW9uU3RhdHVzUgZzdGF0dXMSGwoJaXNfc2hhZG93GAogASgIUghpc1NoYWRvdx'
    'I7CgtyZXNlcnZlZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCnJlc2Vy'
    'dmVkQXQSMQoGdHRsX2F0GAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIFdHRsQX'
    'QSPQoMY29tbWl0dGVkX2F0GA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILY29t'
    'bWl0dGVkQXQSOwoLcmVsZWFzZWRfYXQYDiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW'
    '1wUgpyZWxlYXNlZEF0EjYKF3JldmVyc2VzX3Jlc2VydmF0aW9uX2lkGA8gASgJUhVyZXZlcnNl'
    'c1Jlc2VydmF0aW9uSWQSFAoFbm90ZXMYECABKAlSBW5vdGVz');

@$core.Deprecated('Use reserveRequestDescriptor instead')
const ReserveRequest$json = {
  '1': 'ReserveRequest',
  '2': [
    {
      '1': 'intent',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.LimitIntent',
      '8': {},
      '10': 'intent'
    },
    {
      '1': 'idempotency_key',
      '3': 2,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'idempotencyKey'
    },
    {
      '1': 'ttl',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Duration',
      '8': {},
      '10': 'ttl'
    },
  ],
};

/// Descriptor for `ReserveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reserveRequestDescriptor = $convert.base64Decode(
    'Cg5SZXNlcnZlUmVxdWVzdBI2CgZpbnRlbnQYASABKAsyFi5saW1pdHMudjEuTGltaXRJbnRlbn'
    'RCBrpIA8gBAVIGaW50ZW50EjAKD2lkZW1wb3RlbmN5X2tleRgCIAEoCUIHukgEcgIQAVIOaWRl'
    'bXBvdGVuY3lLZXkSOAoDdHRsGAMgASgLMhkuZ29vZ2xlLnByb3RvYnVmLkR1cmF0aW9uQgu6SA'
    'iqAQUiAwiQHFIDdHRs');

@$core.Deprecated('Use reserveResponseDescriptor instead')
const ReserveResponse$json = {
  '1': 'ReserveResponse',
  '2': [
    {
      '1': 'reservation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.ReservationObject',
      '10': 'reservation'
    },
    {
      '1': 'check',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.CheckResponse',
      '10': 'check'
    },
  ],
};

/// Descriptor for `ReserveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reserveResponseDescriptor = $convert.base64Decode(
    'Cg9SZXNlcnZlUmVzcG9uc2USPgoLcmVzZXJ2YXRpb24YASABKAsyHC5saW1pdHMudjEuUmVzZX'
    'J2YXRpb25PYmplY3RSC3Jlc2VydmF0aW9uEi4KBWNoZWNrGAIgASgLMhgubGltaXRzLnYxLkNo'
    'ZWNrUmVzcG9uc2VSBWNoZWNr');

@$core.Deprecated('Use commitRequestDescriptor instead')
const CommitRequest$json = {
  '1': 'CommitRequest',
  '2': [
    {
      '1': 'reservation_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'reservationId'
    },
  ],
};

/// Descriptor for `CommitRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commitRequestDescriptor = $convert.base64Decode(
    'Cg1Db21taXRSZXF1ZXN0Ei4KDnJlc2VydmF0aW9uX2lkGAEgASgJQge6SARyAhABUg1yZXNlcn'
    'ZhdGlvbklk');

@$core.Deprecated('Use commitResponseDescriptor instead')
const CommitResponse$json = {
  '1': 'CommitResponse',
  '2': [
    {
      '1': 'reservation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.ReservationObject',
      '10': 'reservation'
    },
  ],
};

/// Descriptor for `CommitResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commitResponseDescriptor = $convert.base64Decode(
    'Cg5Db21taXRSZXNwb25zZRI+CgtyZXNlcnZhdGlvbhgBIAEoCzIcLmxpbWl0cy52MS5SZXNlcn'
    'ZhdGlvbk9iamVjdFILcmVzZXJ2YXRpb24=');

@$core.Deprecated('Use releaseRequestDescriptor instead')
const ReleaseRequest$json = {
  '1': 'ReleaseRequest',
  '2': [
    {
      '1': 'reservation_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'reservationId'
    },
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `ReleaseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List releaseRequestDescriptor = $convert.base64Decode(
    'Cg5SZWxlYXNlUmVxdWVzdBIuCg5yZXNlcnZhdGlvbl9pZBgBIAEoCUIHukgEcgIQAVINcmVzZX'
    'J2YXRpb25JZBIWCgZyZWFzb24YAiABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use releaseResponseDescriptor instead')
const ReleaseResponse$json = {
  '1': 'ReleaseResponse',
  '2': [
    {
      '1': 'reservation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.ReservationObject',
      '10': 'reservation'
    },
  ],
};

/// Descriptor for `ReleaseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List releaseResponseDescriptor = $convert.base64Decode(
    'Cg9SZWxlYXNlUmVzcG9uc2USPgoLcmVzZXJ2YXRpb24YASABKAsyHC5saW1pdHMudjEuUmVzZX'
    'J2YXRpb25PYmplY3RSC3Jlc2VydmF0aW9u');

@$core.Deprecated('Use reverseRequestDescriptor instead')
const ReverseRequest$json = {
  '1': 'ReverseRequest',
  '2': [
    {
      '1': 'reservation_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'reservationId'
    },
    {
      '1': 'idempotency_key',
      '3': 2,
      '4': 1,
      '5': 9,
      '8': {},
      '10': 'idempotencyKey'
    },
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `ReverseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reverseRequestDescriptor = $convert.base64Decode(
    'Cg5SZXZlcnNlUmVxdWVzdBIuCg5yZXNlcnZhdGlvbl9pZBgBIAEoCUIHukgEcgIQAVINcmVzZX'
    'J2YXRpb25JZBIwCg9pZGVtcG90ZW5jeV9rZXkYAiABKAlCB7pIBHICEAFSDmlkZW1wb3RlbmN5'
    'S2V5EhYKBnJlYXNvbhgDIAEoCVIGcmVhc29u');

@$core.Deprecated('Use reverseResponseDescriptor instead')
const ReverseResponse$json = {
  '1': 'ReverseResponse',
  '2': [
    {
      '1': 'original_reservation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.ReservationObject',
      '10': 'originalReservation'
    },
    {
      '1': 'reversal_reservation',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.limits.v1.ReservationObject',
      '10': 'reversalReservation'
    },
  ],
};

/// Descriptor for `ReverseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reverseResponseDescriptor = $convert.base64Decode(
    'Cg9SZXZlcnNlUmVzcG9uc2USTwoUb3JpZ2luYWxfcmVzZXJ2YXRpb24YASABKAsyHC5saW1pdH'
    'MudjEuUmVzZXJ2YXRpb25PYmplY3RSE29yaWdpbmFsUmVzZXJ2YXRpb24STwoUcmV2ZXJzYWxf'
    'cmVzZXJ2YXRpb24YAiABKAsyHC5saW1pdHMudjEuUmVzZXJ2YXRpb25PYmplY3RSE3JldmVyc2'
    'FsUmVzZXJ2YXRpb24=');

@$core.Deprecated('Use limitsJobRunRequestDescriptor instead')
const LimitsJobRunRequest$json = {
  '1': 'LimitsJobRunRequest',
  '2': [
    {
      '1': 'job',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.limits.v1.LimitsJob',
      '10': 'job'
    },
  ],
};

/// Descriptor for `LimitsJobRunRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List limitsJobRunRequestDescriptor = $convert.base64Decode(
    'ChNMaW1pdHNKb2JSdW5SZXF1ZXN0EiYKA2pvYhgBIAEoDjIULmxpbWl0cy52MS5MaW1pdHNKb2'
    'JSA2pvYg==');

@$core.Deprecated('Use limitsJobRunResponseDescriptor instead')
const LimitsJobRunResponse$json = {
  '1': 'LimitsJobRunResponse',
};

/// Descriptor for `LimitsJobRunResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List limitsJobRunResponseDescriptor =
    $convert.base64Decode('ChRMaW1pdHNKb2JSdW5SZXNwb25zZQ==');

const $core.Map<$core.String, $core.dynamic> LimitsServiceBase$json = {
  '1': 'LimitsService',
  '2': [
    {
      '1': 'Check',
      '2': '.limits.v1.CheckRequest',
      '3': '.limits.v1.CheckResponse',
      '4': {}
    },
    {
      '1': 'Reserve',
      '2': '.limits.v1.ReserveRequest',
      '3': '.limits.v1.ReserveResponse',
      '4': {}
    },
    {
      '1': 'Commit',
      '2': '.limits.v1.CommitRequest',
      '3': '.limits.v1.CommitResponse',
      '4': {}
    },
    {
      '1': 'Release',
      '2': '.limits.v1.ReleaseRequest',
      '3': '.limits.v1.ReleaseResponse',
      '4': {}
    },
    {
      '1': 'Reverse',
      '2': '.limits.v1.ReverseRequest',
      '3': '.limits.v1.ReverseResponse',
      '4': {}
    },
  ],
};

@$core.Deprecated('Use limitsServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    LimitsServiceBase$messageJson = {
  '.limits.v1.CheckRequest': CheckRequest$json,
  '.limits.v1.LimitIntent': LimitIntent$json,
  '.common.v1.Money': $1.Money$json,
  '.limits.v1.SubjectRef': SubjectRef$json,
  '.limits.v1.CheckResponse': CheckResponse$json,
  '.limits.v1.PolicyVerdict': PolicyVerdict$json,
  '.limits.v1.ReserveRequest': ReserveRequest$json,
  '.google.protobuf.Duration': $0.Duration$json,
  '.limits.v1.ReserveResponse': ReserveResponse$json,
  '.limits.v1.ReservationObject': ReservationObject$json,
  '.google.protobuf.Timestamp': $3.Timestamp$json,
  '.limits.v1.CommitRequest': CommitRequest$json,
  '.limits.v1.CommitResponse': CommitResponse$json,
  '.limits.v1.ReleaseRequest': ReleaseRequest$json,
  '.limits.v1.ReleaseResponse': ReleaseResponse$json,
  '.limits.v1.ReverseRequest': ReverseRequest$json,
  '.limits.v1.ReverseResponse': ReverseResponse$json,
};

/// Descriptor for `LimitsService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List limitsServiceDescriptor = $convert.base64Decode(
    'Cg1MaW1pdHNTZXJ2aWNlEkwKBUNoZWNrEhcubGltaXRzLnYxLkNoZWNrUmVxdWVzdBoYLmxpbW'
    'l0cy52MS5DaGVja1Jlc3BvbnNlIhCCtRgMCgpsaW1pdHNfdXNlElIKB1Jlc2VydmUSGS5saW1p'
    'dHMudjEuUmVzZXJ2ZVJlcXVlc3QaGi5saW1pdHMudjEuUmVzZXJ2ZVJlc3BvbnNlIhCCtRgMCg'
    'psaW1pdHNfdXNlEk8KBkNvbW1pdBIYLmxpbWl0cy52MS5Db21taXRSZXF1ZXN0GhkubGltaXRz'
    'LnYxLkNvbW1pdFJlc3BvbnNlIhCCtRgMCgpsaW1pdHNfdXNlElIKB1JlbGVhc2USGS5saW1pdH'
    'MudjEuUmVsZWFzZVJlcXVlc3QaGi5saW1pdHMudjEuUmVsZWFzZVJlc3BvbnNlIhCCtRgMCgps'
    'aW1pdHNfdXNlElIKB1JldmVyc2USGS5saW1pdHMudjEuUmV2ZXJzZVJlcXVlc3QaGi5saW1pdH'
    'MudjEuUmV2ZXJzZVJlc3BvbnNlIhCCtRgMCgpsaW1pdHNfdXNl');

const $core.Map<$core.String, $core.dynamic> LimitsAdminServiceBase$json = {
  '1': 'LimitsAdminService',
  '2': [
    {
      '1': 'PolicySave',
      '2': '.limits.v1.PolicySaveRequest',
      '3': '.limits.v1.PolicySaveResponse',
      '4': {}
    },
    {
      '1': 'PolicyGet',
      '2': '.limits.v1.PolicyGetRequest',
      '3': '.limits.v1.PolicyGetResponse',
      '4': {}
    },
    {
      '1': 'PolicySearch',
      '2': '.limits.v1.PolicySearchRequest',
      '3': '.limits.v1.PolicySearchResponse',
      '4': {},
      '6': true
    },
    {
      '1': 'PolicyDelete',
      '2': '.limits.v1.PolicyDeleteRequest',
      '3': '.limits.v1.PolicyDeleteResponse',
      '4': {}
    },
    {
      '1': 'PolicyHistory',
      '2': '.limits.v1.PolicyHistoryRequest',
      '3': '.limits.v1.PolicyHistoryResponse',
      '4': {}
    },
    {
      '1': 'ApprovalRequestList',
      '2': '.limits.v1.ApprovalRequestListRequest',
      '3': '.limits.v1.ApprovalRequestListResponse',
      '4': {},
      '6': true
    },
    {
      '1': 'ApprovalRequestGet',
      '2': '.limits.v1.ApprovalRequestGetRequest',
      '3': '.limits.v1.ApprovalRequestGetResponse',
      '4': {}
    },
    {
      '1': 'ApprovalRequestDecide',
      '2': '.limits.v1.ApprovalRequestDecideRequest',
      '3': '.limits.v1.ApprovalRequestDecideResponse',
      '4': {}
    },
    {
      '1': 'LedgerSearch',
      '2': '.limits.v1.LedgerSearchRequest',
      '3': '.limits.v1.LedgerSearchResponse',
      '4': {},
      '6': true
    },
    {
      '1': 'LimitsAuditSearch',
      '2': '.limits.v1.LimitsAuditSearchRequest',
      '3': '.limits.v1.LimitsAuditSearchResponse',
      '4': {},
      '6': true
    },
    {
      '1': 'LimitsJobRun',
      '2': '.limits.v1.LimitsJobRunRequest',
      '3': '.limits.v1.LimitsJobRunResponse',
      '4': {}
    },
  ],
  '3': {},
};

@$core.Deprecated('Use limitsAdminServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    LimitsAdminServiceBase$messageJson = {
  '.limits.v1.PolicySaveRequest': PolicySaveRequest$json,
  '.limits.v1.PolicyObject': PolicyObject$json,
  '.google.protobuf.Duration': $0.Duration$json,
  '.common.v1.Money': $1.Money$json,
  '.google.protobuf.Struct': $2.Struct$json,
  '.google.protobuf.Struct.FieldsEntry': $2.Struct_FieldsEntry$json,
  '.google.protobuf.Value': $2.Value$json,
  '.google.protobuf.ListValue': $2.ListValue$json,
  '.limits.v1.ApproverTier': ApproverTier$json,
  '.google.protobuf.Timestamp': $3.Timestamp$json,
  '.limits.v1.PolicySaveResponse': PolicySaveResponse$json,
  '.limits.v1.PolicyGetRequest': PolicyGetRequest$json,
  '.limits.v1.PolicyGetResponse': PolicyGetResponse$json,
  '.limits.v1.PolicySearchRequest': PolicySearchRequest$json,
  '.common.v1.PageCursor': $4.PageCursor$json,
  '.limits.v1.PolicySearchResponse': PolicySearchResponse$json,
  '.limits.v1.PolicyDeleteRequest': PolicyDeleteRequest$json,
  '.limits.v1.PolicyDeleteResponse': PolicyDeleteResponse$json,
  '.limits.v1.PolicyHistoryRequest': PolicyHistoryRequest$json,
  '.limits.v1.PolicyHistoryResponse': PolicyHistoryResponse$json,
  '.limits.v1.PolicyVersionObject': PolicyVersionObject$json,
  '.limits.v1.ApprovalRequestListRequest': ApprovalRequestListRequest$json,
  '.limits.v1.ApprovalRequestListResponse': ApprovalRequestListResponse$json,
  '.limits.v1.ApprovalRequestObject': ApprovalRequestObject$json,
  '.limits.v1.ApprovalDecisionObject': ApprovalDecisionObject$json,
  '.limits.v1.ApprovalRequestGetRequest': ApprovalRequestGetRequest$json,
  '.limits.v1.ApprovalRequestGetResponse': ApprovalRequestGetResponse$json,
  '.limits.v1.ApprovalRequestDecideRequest': ApprovalRequestDecideRequest$json,
  '.limits.v1.ApprovalRequestDecideResponse':
      ApprovalRequestDecideResponse$json,
  '.limits.v1.LedgerSearchRequest': LedgerSearchRequest$json,
  '.limits.v1.LedgerSearchResponse': LedgerSearchResponse$json,
  '.limits.v1.LedgerEntryObject': LedgerEntryObject$json,
  '.limits.v1.LimitsAuditSearchRequest': LimitsAuditSearchRequest$json,
  '.limits.v1.LimitsAuditSearchResponse': LimitsAuditSearchResponse$json,
  '.limits.v1.LimitsAuditEventObject': LimitsAuditEventObject$json,
  '.limits.v1.LimitsJobRunRequest': LimitsJobRunRequest$json,
  '.limits.v1.LimitsJobRunResponse': LimitsJobRunResponse$json,
};

/// Descriptor for `LimitsAdminService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List limitsAdminServiceDescriptor = $convert.base64Decode(
    'ChJMaW1pdHNBZG1pblNlcnZpY2USZQoKUG9saWN5U2F2ZRIcLmxpbWl0cy52MS5Qb2xpY3lTYX'
    'ZlUmVxdWVzdBodLmxpbWl0cy52MS5Qb2xpY3lTYXZlUmVzcG9uc2UiGoK1GBYKFGxpbWl0c19w'
    'b2xpY3lfbWFuYWdlEmAKCVBvbGljeUdldBIbLmxpbWl0cy52MS5Qb2xpY3lHZXRSZXF1ZXN0Gh'
    'wubGltaXRzLnYxLlBvbGljeUdldFJlc3BvbnNlIhiCtRgUChJsaW1pdHNfcG9saWN5X3ZpZXcS'
    'awoMUG9saWN5U2VhcmNoEh4ubGltaXRzLnYxLlBvbGljeVNlYXJjaFJlcXVlc3QaHy5saW1pdH'
    'MudjEuUG9saWN5U2VhcmNoUmVzcG9uc2UiGIK1GBQKEmxpbWl0c19wb2xpY3lfdmlldzABEmsK'
    'DFBvbGljeURlbGV0ZRIeLmxpbWl0cy52MS5Qb2xpY3lEZWxldGVSZXF1ZXN0Gh8ubGltaXRzLn'
    'YxLlBvbGljeURlbGV0ZVJlc3BvbnNlIhqCtRgWChRsaW1pdHNfcG9saWN5X21hbmFnZRJsCg1Q'
    'b2xpY3lIaXN0b3J5Eh8ubGltaXRzLnYxLlBvbGljeUhpc3RvcnlSZXF1ZXN0GiAubGltaXRzLn'
    'YxLlBvbGljeUhpc3RvcnlSZXNwb25zZSIYgrUYFAoSbGltaXRzX3BvbGljeV92aWV3EoIBChNB'
    'cHByb3ZhbFJlcXVlc3RMaXN0EiUubGltaXRzLnYxLkFwcHJvdmFsUmVxdWVzdExpc3RSZXF1ZX'
    'N0GiYubGltaXRzLnYxLkFwcHJvdmFsUmVxdWVzdExpc3RSZXNwb25zZSIagrUYFgoUbGltaXRz'
    'X2FwcHJvdmFsX3ZpZXcwARJ9ChJBcHByb3ZhbFJlcXVlc3RHZXQSJC5saW1pdHMudjEuQXBwcm'
    '92YWxSZXF1ZXN0R2V0UmVxdWVzdBolLmxpbWl0cy52MS5BcHByb3ZhbFJlcXVlc3RHZXRSZXNw'
    'b25zZSIagrUYFgoUbGltaXRzX2FwcHJvdmFsX3ZpZXcShQEKFUFwcHJvdmFsUmVxdWVzdERlY2'
    'lkZRInLmxpbWl0cy52MS5BcHByb3ZhbFJlcXVlc3REZWNpZGVSZXF1ZXN0GigubGltaXRzLnYx'
    'LkFwcHJvdmFsUmVxdWVzdERlY2lkZVJlc3BvbnNlIhmCtRgVChNsaW1pdHNfYXBwcm92YWxfYW'
    'N0EmsKDExlZGdlclNlYXJjaBIeLmxpbWl0cy52MS5MZWRnZXJTZWFyY2hSZXF1ZXN0Gh8ubGlt'
    'aXRzLnYxLkxlZGdlclNlYXJjaFJlc3BvbnNlIhiCtRgUChJsaW1pdHNfbGVkZ2VyX3ZpZXcwAR'
    'J5ChFMaW1pdHNBdWRpdFNlYXJjaBIjLmxpbWl0cy52MS5MaW1pdHNBdWRpdFNlYXJjaFJlcXVl'
    'c3QaJC5saW1pdHMudjEuTGltaXRzQXVkaXRTZWFyY2hSZXNwb25zZSIXgrUYEwoRbGltaXRzX2'
    'F1ZGl0X3ZpZXcwARJlCgxMaW1pdHNKb2JSdW4SHi5saW1pdHMudjEuTGltaXRzSm9iUnVuUmVx'
    'dWVzdBofLmxpbWl0cy52MS5MaW1pdHNKb2JSdW5SZXNwb25zZSIUgrUYEAoObGltaXRzX2pvYl'
    '9ydW4ayQaCtRjEBgoOc2VydmljZV9saW1pdHMSCmxpbWl0c191c2USFGxpbWl0c19wb2xpY3lf'
    'bWFuYWdlEhJsaW1pdHNfcG9saWN5X3ZpZXcSFGxpbWl0c19hcHByb3ZhbF92aWV3EhNsaW1pdH'
    'NfYXBwcm92YWxfYWN0EhhsaW1pdHNfYXBwcm92YWxfb3ZlcnJpZGUSEmxpbWl0c19sZWRnZXJf'
    'dmlldxIRbGltaXRzX2F1ZGl0X3ZpZXcSDmxpbWl0c19hcmNoaXZlEg5saW1pdHNfam9iX3J1bh'
    'qkAQgBEgpsaW1pdHNfdXNlEhRsaW1pdHNfcG9saWN5X21hbmFnZRISbGltaXRzX3BvbGljeV92'
    'aWV3EhRsaW1pdHNfYXBwcm92YWxfdmlldxITbGltaXRzX2FwcHJvdmFsX2FjdBIYbGltaXRzX2'
    'FwcHJvdmFsX292ZXJyaWRlEhJsaW1pdHNfbGVkZ2VyX3ZpZXcSEWxpbWl0c19hdWRpdF92aWV3'
    'GqQBCAISCmxpbWl0c191c2USFGxpbWl0c19wb2xpY3lfbWFuYWdlEhJsaW1pdHNfcG9saWN5X3'
    'ZpZXcSFGxpbWl0c19hcHByb3ZhbF92aWV3EhNsaW1pdHNfYXBwcm92YWxfYWN0EhhsaW1pdHNf'
    'YXBwcm92YWxfb3ZlcnJpZGUSEmxpbWl0c19sZWRnZXJfdmlldxIRbGltaXRzX2F1ZGl0X3ZpZX'
    'caaAgDEhJsaW1pdHNfcG9saWN5X3ZpZXcSFGxpbWl0c19hcHByb3ZhbF92aWV3EhNsaW1pdHNf'
    'YXBwcm92YWxfYWN0EhJsaW1pdHNfbGVkZ2VyX3ZpZXcSEWxpbWl0c19hdWRpdF92aWV3GlMIBB'
    'ISbGltaXRzX3BvbGljeV92aWV3EhRsaW1pdHNfYXBwcm92YWxfdmlldxISbGltaXRzX2xlZGdl'
    'cl92aWV3EhFsaW1pdHNfYXVkaXRfdmlldxpTCAUSEmxpbWl0c19wb2xpY3lfdmlldxIUbGltaX'
    'RzX2FwcHJvdmFsX3ZpZXcSEmxpbWl0c19sZWRnZXJfdmlldxIRbGltaXRzX2F1ZGl0X3ZpZXca'
    'DggGEgpsaW1pdHNfdXNl');
