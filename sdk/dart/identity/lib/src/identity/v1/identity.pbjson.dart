//
//  Generated code. Do not modify.
//  source: identity/v1/identity.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../common/v1/common.pbjson.dart' as $7;
import '../../common/v1/money.pbjson.dart' as $8;
import '../../google/protobuf/struct.pbjson.dart' as $6;

@$core.Deprecated('Use organizationTypeDescriptor instead')
const OrganizationType$json = {
  '1': 'OrganizationType',
  '2': [
    {'1': 'ORGANIZATION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'ORGANIZATION_TYPE_BANK', '2': 1},
    {'1': 'ORGANIZATION_TYPE_MICROFINANCE', '2': 2},
    {'1': 'ORGANIZATION_TYPE_SACCO', '2': 3},
    {'1': 'ORGANIZATION_TYPE_FINTECH', '2': 4},
    {'1': 'ORGANIZATION_TYPE_COOPERATIVE', '2': 5},
    {'1': 'ORGANIZATION_TYPE_NGO', '2': 6},
    {'1': 'ORGANIZATION_TYPE_GOVERNMENT', '2': 7},
    {'1': 'ORGANIZATION_TYPE_OTHER', '2': 8},
    {'1': 'ORGANIZATION_TYPE_TRADING', '2': 9},
    {'1': 'ORGANIZATION_TYPE_RETAIL', '2': 10},
    {'1': 'ORGANIZATION_TYPE_MANUFACTURING', '2': 11},
    {'1': 'ORGANIZATION_TYPE_LOGISTICS', '2': 12},
    {'1': 'ORGANIZATION_TYPE_SERVICES', '2': 13},
  ],
};

/// Descriptor for `OrganizationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List organizationTypeDescriptor = $convert.base64Decode(
    'ChBPcmdhbml6YXRpb25UeXBlEiEKHU9SR0FOSVpBVElPTl9UWVBFX1VOU1BFQ0lGSUVEEAASGg'
    'oWT1JHQU5JWkFUSU9OX1RZUEVfQkFOSxABEiIKHk9SR0FOSVpBVElPTl9UWVBFX01JQ1JPRklO'
    'QU5DRRACEhsKF09SR0FOSVpBVElPTl9UWVBFX1NBQ0NPEAMSHQoZT1JHQU5JWkFUSU9OX1RZUE'
    'VfRklOVEVDSBAEEiEKHU9SR0FOSVpBVElPTl9UWVBFX0NPT1BFUkFUSVZFEAUSGQoVT1JHQU5J'
    'WkFUSU9OX1RZUEVfTkdPEAYSIAocT1JHQU5JWkFUSU9OX1RZUEVfR09WRVJOTUVOVBAHEhsKF0'
    '9SR0FOSVpBVElPTl9UWVBFX09USEVSEAgSHQoZT1JHQU5JWkFUSU9OX1RZUEVfVFJBRElORxAJ'
    'EhwKGE9SR0FOSVpBVElPTl9UWVBFX1JFVEFJTBAKEiMKH09SR0FOSVpBVElPTl9UWVBFX01BTl'
    'VGQUNUVVJJTkcQCxIfChtPUkdBTklaQVRJT05fVFlQRV9MT0dJU1RJQ1MQDBIeChpPUkdBTkla'
    'QVRJT05fVFlQRV9TRVJWSUNFUxAN');

@$core.Deprecated('Use orgUnitTypeDescriptor instead')
const OrgUnitType$json = {
  '1': 'OrgUnitType',
  '2': [
    {'1': 'ORG_UNIT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'ORG_UNIT_TYPE_REGION', '2': 1},
    {'1': 'ORG_UNIT_TYPE_ZONE', '2': 2},
    {'1': 'ORG_UNIT_TYPE_AREA', '2': 3},
    {'1': 'ORG_UNIT_TYPE_CLUSTER', '2': 4},
    {'1': 'ORG_UNIT_TYPE_BRANCH', '2': 5},
    {'1': 'ORG_UNIT_TYPE_OTHER', '2': 6},
  ],
};

/// Descriptor for `OrgUnitType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List orgUnitTypeDescriptor = $convert.base64Decode(
    'CgtPcmdVbml0VHlwZRIdChlPUkdfVU5JVF9UWVBFX1VOU1BFQ0lGSUVEEAASGAoUT1JHX1VOSV'
    'RfVFlQRV9SRUdJT04QARIWChJPUkdfVU5JVF9UWVBFX1pPTkUQAhIWChJPUkdfVU5JVF9UWVBF'
    'X0FSRUEQAxIZChVPUkdfVU5JVF9UWVBFX0NMVVNURVIQBBIYChRPUkdfVU5JVF9UWVBFX0JSQU'
    '5DSBAFEhcKE09SR19VTklUX1RZUEVfT1RIRVIQBg==');

@$core.Deprecated('Use departmentKindDescriptor instead')
const DepartmentKind$json = {
  '1': 'DepartmentKind',
  '2': [
    {'1': 'DEPARTMENT_KIND_UNSPECIFIED', '2': 0},
    {'1': 'DEPARTMENT_KIND_FUNCTION', '2': 1},
    {'1': 'DEPARTMENT_KIND_DEPARTMENT', '2': 2},
  ],
};

/// Descriptor for `DepartmentKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List departmentKindDescriptor = $convert.base64Decode(
    'Cg5EZXBhcnRtZW50S2luZBIfChtERVBBUlRNRU5UX0tJTkRfVU5TUEVDSUZJRUQQABIcChhERV'
    'BBUlRNRU5UX0tJTkRfRlVOQ1RJT04QARIeChpERVBBUlRNRU5UX0tJTkRfREVQQVJUTUVOVBAC');

@$core.Deprecated('Use accessScopeTypeDescriptor instead')
const AccessScopeType$json = {
  '1': 'AccessScopeType',
  '2': [
    {'1': 'ACCESS_SCOPE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'ACCESS_SCOPE_TYPE_GLOBAL', '2': 1},
    {'1': 'ACCESS_SCOPE_TYPE_ORGANIZATION', '2': 2},
    {'1': 'ACCESS_SCOPE_TYPE_ORG_UNIT', '2': 3},
    {'1': 'ACCESS_SCOPE_TYPE_TEAM', '2': 4},
  ],
};

/// Descriptor for `AccessScopeType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List accessScopeTypeDescriptor = $convert.base64Decode(
    'Cg9BY2Nlc3NTY29wZVR5cGUSIQodQUNDRVNTX1NDT1BFX1RZUEVfVU5TUEVDSUZJRUQQABIcCh'
    'hBQ0NFU1NfU0NPUEVfVFlQRV9HTE9CQUwQARIiCh5BQ0NFU1NfU0NPUEVfVFlQRV9PUkdBTkla'
    'QVRJT04QAhIeChpBQ0NFU1NfU0NPUEVfVFlQRV9PUkdfVU5JVBADEhoKFkFDQ0VTU19TQ09QRV'
    '9UWVBFX1RFQU0QBA==');

@$core.Deprecated('Use dataVerificationStatusDescriptor instead')
const DataVerificationStatus$json = {
  '1': 'DataVerificationStatus',
  '2': [
    {'1': 'DATA_VERIFICATION_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'DATA_VERIFICATION_STATUS_COLLECTED', '2': 1},
    {'1': 'DATA_VERIFICATION_STATUS_UNDER_REVIEW', '2': 2},
    {'1': 'DATA_VERIFICATION_STATUS_VERIFIED', '2': 3},
    {'1': 'DATA_VERIFICATION_STATUS_REJECTED', '2': 4},
    {'1': 'DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED', '2': 5},
    {'1': 'DATA_VERIFICATION_STATUS_EXPIRED', '2': 6},
  ],
};

/// Descriptor for `DataVerificationStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List dataVerificationStatusDescriptor = $convert.base64Decode(
    'ChZEYXRhVmVyaWZpY2F0aW9uU3RhdHVzEigKJERBVEFfVkVSSUZJQ0FUSU9OX1NUQVRVU19VTl'
    'NQRUNJRklFRBAAEiYKIkRBVEFfVkVSSUZJQ0FUSU9OX1NUQVRVU19DT0xMRUNURUQQARIpCiVE'
    'QVRBX1ZFUklGSUNBVElPTl9TVEFUVVNfVU5ERVJfUkVWSUVXEAISJQohREFUQV9WRVJJRklDQV'
    'RJT05fU1RBVFVTX1ZFUklGSUVEEAMSJQohREFUQV9WRVJJRklDQVRJT05fU1RBVFVTX1JFSkVD'
    'VEVEEAQSLQopREFUQV9WRVJJRklDQVRJT05fU1RBVFVTX01PUkVfSU5GT19ORUVERUQQBRIkCi'
    'BEQVRBX1ZFUklGSUNBVElPTl9TVEFUVVNfRVhQSVJFRBAG');

@$core.Deprecated('Use formFieldTypeDescriptor instead')
const FormFieldType$json = {
  '1': 'FormFieldType',
  '2': [
    {'1': 'FORM_FIELD_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'FORM_FIELD_TYPE_TEXT', '2': 1},
    {'1': 'FORM_FIELD_TYPE_NUMBER', '2': 2},
    {'1': 'FORM_FIELD_TYPE_CURRENCY', '2': 3},
    {'1': 'FORM_FIELD_TYPE_PHONE', '2': 4},
    {'1': 'FORM_FIELD_TYPE_EMAIL', '2': 5},
    {'1': 'FORM_FIELD_TYPE_DATE', '2': 6},
    {'1': 'FORM_FIELD_TYPE_SELECT', '2': 7},
    {'1': 'FORM_FIELD_TYPE_MULTI_SELECT', '2': 8},
    {'1': 'FORM_FIELD_TYPE_PHOTO', '2': 9},
    {'1': 'FORM_FIELD_TYPE_FILE', '2': 10},
    {'1': 'FORM_FIELD_TYPE_LOCATION', '2': 11},
    {'1': 'FORM_FIELD_TYPE_SIGNATURE', '2': 12},
    {'1': 'FORM_FIELD_TYPE_CHECKBOX', '2': 13},
    {'1': 'FORM_FIELD_TYPE_TEXTAREA', '2': 14},
  ],
};

/// Descriptor for `FormFieldType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List formFieldTypeDescriptor = $convert.base64Decode(
    'Cg1Gb3JtRmllbGRUeXBlEh8KG0ZPUk1fRklFTERfVFlQRV9VTlNQRUNJRklFRBAAEhgKFEZPUk'
    '1fRklFTERfVFlQRV9URVhUEAESGgoWRk9STV9GSUVMRF9UWVBFX05VTUJFUhACEhwKGEZPUk1f'
    'RklFTERfVFlQRV9DVVJSRU5DWRADEhkKFUZPUk1fRklFTERfVFlQRV9QSE9ORRAEEhkKFUZPUk'
    '1fRklFTERfVFlQRV9FTUFJTBAFEhgKFEZPUk1fRklFTERfVFlQRV9EQVRFEAYSGgoWRk9STV9G'
    'SUVMRF9UWVBFX1NFTEVDVBAHEiAKHEZPUk1fRklFTERfVFlQRV9NVUxUSV9TRUxFQ1QQCBIZCh'
    'VGT1JNX0ZJRUxEX1RZUEVfUEhPVE8QCRIYChRGT1JNX0ZJRUxEX1RZUEVfRklMRRAKEhwKGEZP'
    'Uk1fRklFTERfVFlQRV9MT0NBVElPThALEh0KGUZPUk1fRklFTERfVFlQRV9TSUdOQVRVUkUQDB'
    'IcChhGT1JNX0ZJRUxEX1RZUEVfQ0hFQ0tCT1gQDRIcChhGT1JNX0ZJRUxEX1RZUEVfVEVYVEFS'
    'RUEQDg==');

@$core.Deprecated('Use formFieldGroupDescriptor instead')
const FormFieldGroup$json = {
  '1': 'FormFieldGroup',
  '2': [
    {'1': 'FORM_FIELD_GROUP_UNSPECIFIED', '2': 0},
    {'1': 'FORM_FIELD_GROUP_PERSONAL', '2': 1},
    {'1': 'FORM_FIELD_GROUP_FINANCIAL', '2': 2},
    {'1': 'FORM_FIELD_GROUP_LEGAL', '2': 3},
    {'1': 'FORM_FIELD_GROUP_DOCUMENTS', '2': 4},
    {'1': 'FORM_FIELD_GROUP_LOCATION', '2': 5},
  ],
};

/// Descriptor for `FormFieldGroup`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List formFieldGroupDescriptor = $convert.base64Decode(
    'Cg5Gb3JtRmllbGRHcm91cBIgChxGT1JNX0ZJRUxEX0dST1VQX1VOU1BFQ0lGSUVEEAASHQoZRk'
    '9STV9GSUVMRF9HUk9VUF9QRVJTT05BTBABEh4KGkZPUk1fRklFTERfR1JPVVBfRklOQU5DSUFM'
    'EAISGgoWRk9STV9GSUVMRF9HUk9VUF9MRUdBTBADEh4KGkZPUk1fRklFTERfR1JPVVBfRE9DVU'
    '1FTlRTEAQSHQoZRk9STV9GSUVMRF9HUk9VUF9MT0NBVElPThAF');

@$core.Deprecated('Use formTemplateStatusDescriptor instead')
const FormTemplateStatus$json = {
  '1': 'FormTemplateStatus',
  '2': [
    {'1': 'FORM_TEMPLATE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'FORM_TEMPLATE_STATUS_DRAFT', '2': 1},
    {'1': 'FORM_TEMPLATE_STATUS_PUBLISHED', '2': 2},
    {'1': 'FORM_TEMPLATE_STATUS_ARCHIVED', '2': 3},
  ],
};

/// Descriptor for `FormTemplateStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List formTemplateStatusDescriptor = $convert.base64Decode(
    'ChJGb3JtVGVtcGxhdGVTdGF0dXMSJAogRk9STV9URU1QTEFURV9TVEFUVVNfVU5TUEVDSUZJRU'
    'QQABIeChpGT1JNX1RFTVBMQVRFX1NUQVRVU19EUkFGVBABEiIKHkZPUk1fVEVNUExBVEVfU1RB'
    'VFVTX1BVQkxJU0hFRBACEiEKHUZPUk1fVEVNUExBVEVfU1RBVFVTX0FSQ0hJVkVEEAM=');

@$core.Deprecated('Use organizationObjectDescriptor instead')
const OrganizationObject$json = {
  '1': 'OrganizationObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'partition_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'partitionId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'code', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'code'},
    {'1': 'profile_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
    {'1': 'state', '3': 6, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'organization_type', '3': 7, '4': 1, '5': 14, '6': '.identity.v1.OrganizationType', '10': 'organizationType'},
    {'1': 'properties', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
    {'1': 'client_id', '3': 9, '4': 1, '5': 9, '8': {}, '10': 'clientId'},
    {'1': 'geo_id', '3': 10, '4': 1, '5': 9, '8': {}, '10': 'geoId'},
    {'1': 'parent_id', '3': 11, '4': 1, '5': 9, '8': {}, '10': 'parentId'},
    {'1': 'has_children', '3': 12, '4': 1, '5': 8, '10': 'hasChildren'},
    {'1': 'domain', '3': 13, '4': 1, '5': 9, '8': {}, '10': 'domain'},
  ],
};

/// Descriptor for `OrganizationObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List organizationObjectDescriptor = $convert.base64Decode(
    'ChJPcmdhbml6YXRpb25PYmplY3QSLgoCaWQYASABKAlCHrpIG9gBAXIWEAMYKDIQWzAtOWEtel'
    '8tXXszLDQwfVICaWQSLAoMcGFydGl0aW9uX2lkGAIgASgJQgm6SAZyBBADGChSC3BhcnRpdGlv'
    'bklkEhsKBG5hbWUYAyABKAlCB7pIBHICEAFSBG5hbWUSGwoEY29kZRgEIAEoCUIHukgEcgIQAV'
    'IEY29kZRIrCgpwcm9maWxlX2lkGAUgASgJQgy6SAnYAQFyBBADGChSCXByb2ZpbGVJZBImCgVz'
    'dGF0ZRgGIAEoDjIQLmNvbW1vbi52MS5TVEFURVIFc3RhdGUSSgoRb3JnYW5pemF0aW9uX3R5cG'
    'UYByABKA4yHS5pZGVudGl0eS52MS5Pcmdhbml6YXRpb25UeXBlUhBvcmdhbml6YXRpb25UeXBl'
    'EjcKCnByb3BlcnRpZXMYCCABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0Ugpwcm9wZXJ0aW'
    'VzEicKCWNsaWVudF9pZBgJIAEoCUIKukgH2AEBcgIYKFIIY2xpZW50SWQSIQoGZ2VvX2lkGAog'
    'ASgJQgq6SAfYAQFyAhgoUgVnZW9JZBInCglwYXJlbnRfaWQYCyABKAlCCrpIB9gBAXICGChSCH'
    'BhcmVudElkEiEKDGhhc19jaGlsZHJlbhgMIAEoCFILaGFzQ2hpbGRyZW4SIwoGZG9tYWluGA0g'
    'ASgJQgu6SAjYAQFyAxj/AVIGZG9tYWlu');

@$core.Deprecated('Use orgUnitObjectDescriptor instead')
const OrgUnitObject$json = {
  '1': 'OrgUnitObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'parent_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'parentId'},
    {'1': 'partition_id', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'partitionId'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'code', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'code'},
    {'1': 'geo_id', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'geoId'},
    {'1': 'state', '3': 8, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'type', '3': 9, '4': 1, '5': 14, '6': '.identity.v1.OrgUnitType', '10': 'type'},
    {'1': 'properties', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
    {'1': 'client_id', '3': 11, '4': 1, '5': 9, '8': {}, '10': 'clientId'},
    {'1': 'has_children', '3': 12, '4': 1, '5': 8, '10': 'hasChildren'},
    {'1': 'profile_id', '3': 13, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
  ],
};

/// Descriptor for `OrgUnitObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orgUnitObjectDescriptor = $convert.base64Decode(
    'Cg1PcmdVbml0T2JqZWN0Ei4KAmlkGAEgASgJQh66SBvYAQFyFhADGCgyEFswLTlhLXpfLV17My'
    'w0MH1SAmlkEjIKD29yZ2FuaXphdGlvbl9pZBgCIAEoCUIJukgGcgQQAxgoUg5vcmdhbml6YXRp'
    'b25JZBIpCglwYXJlbnRfaWQYAyABKAlCDLpICdgBAXIEEAMYKFIIcGFyZW50SWQSLwoMcGFydG'
    'l0aW9uX2lkGAQgASgJQgy6SAnYAQFyBBADGChSC3BhcnRpdGlvbklkEhsKBG5hbWUYBSABKAlC'
    'B7pIBHICEAFSBG5hbWUSGwoEY29kZRgGIAEoCUIHukgEcgIQAVIEY29kZRIhCgZnZW9faWQYBy'
    'ABKAlCCrpIB9gBAXICGChSBWdlb0lkEiYKBXN0YXRlGAggASgOMhAuY29tbW9uLnYxLlNUQVRF'
    'UgVzdGF0ZRIsCgR0eXBlGAkgASgOMhguaWRlbnRpdHkudjEuT3JnVW5pdFR5cGVSBHR5cGUSNw'
    'oKcHJvcGVydGllcxgKIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSCnByb3BlcnRpZXMS'
    'JwoJY2xpZW50X2lkGAsgASgJQgq6SAfYAQFyAhgoUghjbGllbnRJZBIhCgxoYXNfY2hpbGRyZW'
    '4YDCABKAhSC2hhc0NoaWxkcmVuEisKCnByb2ZpbGVfaWQYDSABKAlCDLpICdgBAXIEEAMYKFIJ'
    'cHJvZmlsZUlk');

@$core.Deprecated('Use investorObjectDescriptor instead')
const InvestorObject$json = {
  '1': 'InvestorObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'profile_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'state', '3': 4, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `InvestorObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorObjectDescriptor = $convert.base64Decode(
    'Cg5JbnZlc3Rvck9iamVjdBIuCgJpZBgBIAEoCUIeukgb2AEBchYQAxgoMhBbMC05YS16Xy1dez'
    'MsNDB9UgJpZBIoCgpwcm9maWxlX2lkGAIgASgJQgm6SAZyBBADGChSCXByb2ZpbGVJZBIbCgRu'
    'YW1lGAMgASgJQge6SARyAhABUgRuYW1lEiYKBXN0YXRlGAQgASgOMhAuY29tbW9uLnYxLlNUQV'
    'RFUgVzdGF0ZRI3Cgpwcm9wZXJ0aWVzGAUgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIK'
    'cHJvcGVydGllcw==');

@$core.Deprecated('Use workforceMemberObjectDescriptor instead')
const WorkforceMemberObject$json = {
  '1': 'WorkforceMemberObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'profile_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
    {'1': 'engagement_type', '3': 4, '4': 1, '5': 9, '10': 'engagementType'},
    {'1': 'home_org_unit_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'homeOrgUnitId'},
    {'1': 'geo_id', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'geoId'},
    {'1': 'state', '3': 7, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `WorkforceMemberObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workforceMemberObjectDescriptor = $convert.base64Decode(
    'ChVXb3JrZm9yY2VNZW1iZXJPYmplY3QSLgoCaWQYASABKAlCHrpIG9gBAXIWEAMYKDIQWzAtOW'
    'Etel8tXXszLDQwfVICaWQSMgoPb3JnYW5pemF0aW9uX2lkGAIgASgJQgm6SAZyBBADGChSDm9y'
    'Z2FuaXphdGlvbklkEikKCnByb2ZpbGVfaWQYAyABKAlCCrpIB9gBAXICGChSCXByb2ZpbGVJZB'
    'InCg9lbmdhZ2VtZW50X3R5cGUYBCABKAlSDmVuZ2FnZW1lbnRUeXBlEjMKEGhvbWVfb3JnX3Vu'
    'aXRfaWQYBSABKAlCCrpIB9gBAXICGChSDWhvbWVPcmdVbml0SWQSIQoGZ2VvX2lkGAYgASgJQg'
    'q6SAfYAQFyAhgoUgVnZW9JZBImCgVzdGF0ZRgHIAEoDjIQLmNvbW1vbi52MS5TVEFURVIFc3Rh'
    'dGUSNwoKcHJvcGVydGllcxgIIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSCnByb3Blcn'
    'RpZXM=');

@$core.Deprecated('Use departmentObjectDescriptor instead')
const DepartmentObject$json = {
  '1': 'DepartmentObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'parent_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'parentId'},
    {'1': 'kind', '3': 4, '4': 1, '5': 14, '6': '.identity.v1.DepartmentKind', '10': 'kind'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'code', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'code'},
    {'1': 'state', '3': 7, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `DepartmentObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List departmentObjectDescriptor = $convert.base64Decode(
    'ChBEZXBhcnRtZW50T2JqZWN0Ei4KAmlkGAEgASgJQh66SBvYAQFyFhADGCgyEFswLTlhLXpfLV'
    '17Myw0MH1SAmlkEjIKD29yZ2FuaXphdGlvbl9pZBgCIAEoCUIJukgGcgQQAxgoUg5vcmdhbml6'
    'YXRpb25JZBInCglwYXJlbnRfaWQYAyABKAlCCrpIB9gBAXICGChSCHBhcmVudElkEi8KBGtpbm'
    'QYBCABKA4yGy5pZGVudGl0eS52MS5EZXBhcnRtZW50S2luZFIEa2luZBIbCgRuYW1lGAUgASgJ'
    'Qge6SARyAhABUgRuYW1lEhsKBGNvZGUYBiABKAlCB7pIBHICEAFSBGNvZGUSJgoFc3RhdGUYBy'
    'ABKA4yEC5jb21tb24udjEuU1RBVEVSBXN0YXRlEjcKCnByb3BlcnRpZXMYCCABKAsyFy5nb29n'
    'bGUucHJvdG9idWYuU3RydWN0Ugpwcm9wZXJ0aWVz');

@$core.Deprecated('Use positionObjectDescriptor instead')
const PositionObject$json = {
  '1': 'PositionObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'org_unit_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'orgUnitId'},
    {'1': 'department_id', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'departmentId'},
    {'1': 'reports_to_position_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'reportsToPositionId'},
    {'1': 'name', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'code', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'code'},
    {'1': 'state', '3': 8, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `PositionObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionObjectDescriptor = $convert.base64Decode(
    'Cg5Qb3NpdGlvbk9iamVjdBIuCgJpZBgBIAEoCUIeukgb2AEBchYQAxgoMhBbMC05YS16Xy1dez'
    'MsNDB9UgJpZBIyCg9vcmdhbml6YXRpb25faWQYAiABKAlCCbpIBnIEEAMYKFIOb3JnYW5pemF0'
    'aW9uSWQSKgoLb3JnX3VuaXRfaWQYAyABKAlCCrpIB9gBAXICGChSCW9yZ1VuaXRJZBIvCg1kZX'
    'BhcnRtZW50X2lkGAQgASgJQgq6SAfYAQFyAhgoUgxkZXBhcnRtZW50SWQSPwoWcmVwb3J0c190'
    'b19wb3NpdGlvbl9pZBgFIAEoCUIKukgH2AEBcgIYKFITcmVwb3J0c1RvUG9zaXRpb25JZBIbCg'
    'RuYW1lGAYgASgJQge6SARyAhABUgRuYW1lEhsKBGNvZGUYByABKAlCB7pIBHICEAFSBGNvZGUS'
    'JgoFc3RhdGUYCCABKA4yEC5jb21tb24udjEuU1RBVEVSBXN0YXRlEjcKCnByb3BlcnRpZXMYCS'
    'ABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0Ugpwcm9wZXJ0aWVz');

@$core.Deprecated('Use positionAssignmentObjectDescriptor instead')
const PositionAssignmentObject$json = {
  '1': 'PositionAssignmentObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'member_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'memberId'},
    {'1': 'position_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'positionId'},
    {'1': 'is_primary', '3': 4, '4': 1, '5': 8, '10': 'isPrimary'},
    {'1': 'state', '3': 5, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `PositionAssignmentObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionAssignmentObjectDescriptor = $convert.base64Decode(
    'ChhQb3NpdGlvbkFzc2lnbm1lbnRPYmplY3QSLgoCaWQYASABKAlCHrpIG9gBAXIWEAMYKDIQWz'
    'AtOWEtel8tXXszLDQwfVICaWQSJgoJbWVtYmVyX2lkGAIgASgJQgm6SAZyBBADGChSCG1lbWJl'
    'cklkEioKC3Bvc2l0aW9uX2lkGAMgASgJQgm6SAZyBBADGChSCnBvc2l0aW9uSWQSHQoKaXNfcH'
    'JpbWFyeRgEIAEoCFIJaXNQcmltYXJ5EiYKBXN0YXRlGAUgASgOMhAuY29tbW9uLnYxLlNUQVRF'
    'UgVzdGF0ZRI3Cgpwcm9wZXJ0aWVzGAYgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIKcH'
    'JvcGVydGllcw==');

@$core.Deprecated('Use internalTeamObjectDescriptor instead')
const InternalTeamObject$json = {
  '1': 'InternalTeamObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'parent_team_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'parentTeamId'},
    {'1': 'home_org_unit_id', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'homeOrgUnitId'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'code', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'code'},
    {'1': 'team_type', '3': 7, '4': 1, '5': 9, '10': 'teamType'},
    {'1': 'objective', '3': 8, '4': 1, '5': 9, '10': 'objective'},
    {'1': 'geo_id', '3': 9, '4': 1, '5': 9, '8': {}, '10': 'geoId'},
    {'1': 'state', '3': 10, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 11, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `InternalTeamObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List internalTeamObjectDescriptor = $convert.base64Decode(
    'ChJJbnRlcm5hbFRlYW1PYmplY3QSLgoCaWQYASABKAlCHrpIG9gBAXIWEAMYKDIQWzAtOWEtel'
    '8tXXszLDQwfVICaWQSMgoPb3JnYW5pemF0aW9uX2lkGAIgASgJQgm6SAZyBBADGChSDm9yZ2Fu'
    'aXphdGlvbklkEjAKDnBhcmVudF90ZWFtX2lkGAMgASgJQgq6SAfYAQFyAhgoUgxwYXJlbnRUZW'
    'FtSWQSMwoQaG9tZV9vcmdfdW5pdF9pZBgEIAEoCUIKukgH2AEBcgIYKFINaG9tZU9yZ1VuaXRJ'
    'ZBIbCgRuYW1lGAUgASgJQge6SARyAhABUgRuYW1lEhsKBGNvZGUYBiABKAlCB7pIBHICEAFSBG'
    'NvZGUSGwoJdGVhbV90eXBlGAcgASgJUgh0ZWFtVHlwZRIcCglvYmplY3RpdmUYCCABKAlSCW9i'
    'amVjdGl2ZRIhCgZnZW9faWQYCSABKAlCCrpIB9gBAXICGChSBWdlb0lkEiYKBXN0YXRlGAogAS'
    'gOMhAuY29tbW9uLnYxLlNUQVRFUgVzdGF0ZRI3Cgpwcm9wZXJ0aWVzGAsgASgLMhcuZ29vZ2xl'
    'LnByb3RvYnVmLlN0cnVjdFIKcHJvcGVydGllcw==');

@$core.Deprecated('Use teamMembershipObjectDescriptor instead')
const TeamMembershipObject$json = {
  '1': 'TeamMembershipObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'team_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'teamId'},
    {'1': 'member_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'memberId'},
    {'1': 'membership_role', '3': 4, '4': 1, '5': 9, '10': 'membershipRole'},
    {'1': 'is_primary_team', '3': 5, '4': 1, '5': 8, '10': 'isPrimaryTeam'},
    {'1': 'state', '3': 6, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `TeamMembershipObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMembershipObjectDescriptor = $convert.base64Decode(
    'ChRUZWFtTWVtYmVyc2hpcE9iamVjdBIuCgJpZBgBIAEoCUIeukgb2AEBchYQAxgoMhBbMC05YS'
    '16Xy1dezMsNDB9UgJpZBIiCgd0ZWFtX2lkGAIgASgJQgm6SAZyBBADGChSBnRlYW1JZBImCglt'
    'ZW1iZXJfaWQYAyABKAlCCbpIBnIEEAMYKFIIbWVtYmVySWQSJwoPbWVtYmVyc2hpcF9yb2xlGA'
    'QgASgJUg5tZW1iZXJzaGlwUm9sZRImCg9pc19wcmltYXJ5X3RlYW0YBSABKAhSDWlzUHJpbWFy'
    'eVRlYW0SJgoFc3RhdGUYBiABKA4yEC5jb21tb24udjEuU1RBVEVSBXN0YXRlEjcKCnByb3Blcn'
    'RpZXMYByABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0Ugpwcm9wZXJ0aWVz');

@$core.Deprecated('Use accessRoleAssignmentObjectDescriptor instead')
const AccessRoleAssignmentObject$json = {
  '1': 'AccessRoleAssignmentObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'member_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'memberId'},
    {'1': 'role_key', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'roleKey'},
    {'1': 'scope_type', '3': 4, '4': 1, '5': 14, '6': '.identity.v1.AccessScopeType', '10': 'scopeType'},
    {'1': 'scope_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'scopeId'},
    {'1': 'state', '3': 6, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `AccessRoleAssignmentObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessRoleAssignmentObjectDescriptor = $convert.base64Decode(
    'ChpBY2Nlc3NSb2xlQXNzaWdubWVudE9iamVjdBIuCgJpZBgBIAEoCUIeukgb2AEBchYQAxgoMh'
    'BbMC05YS16Xy1dezMsNDB9UgJpZBImCgltZW1iZXJfaWQYAiABKAlCCbpIBnIEEAMYKFIIbWVt'
    'YmVySWQSIgoIcm9sZV9rZXkYAyABKAlCB7pIBHICEAFSB3JvbGVLZXkSOwoKc2NvcGVfdHlwZR'
    'gEIAEoDjIcLmlkZW50aXR5LnYxLkFjY2Vzc1Njb3BlVHlwZVIJc2NvcGVUeXBlEiUKCHNjb3Bl'
    'X2lkGAUgASgJQgq6SAfYAQFyAhgoUgdzY29wZUlkEiYKBXN0YXRlGAYgASgOMhAuY29tbW9uLn'
    'YxLlNUQVRFUgVzdGF0ZRI3Cgpwcm9wZXJ0aWVzGAcgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0'
    'cnVjdFIKcHJvcGVydGllcw==');

@$core.Deprecated('Use organizationSaveRequestDescriptor instead')
const OrganizationSaveRequest$json = {
  '1': 'OrganizationSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.OrganizationObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `OrganizationSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List organizationSaveRequestDescriptor = $convert.base64Decode(
    'ChdPcmdhbml6YXRpb25TYXZlUmVxdWVzdBI7CgRkYXRhGAEgASgLMh8uaWRlbnRpdHkudjEuT3'
    'JnYW5pemF0aW9uT2JqZWN0Qga6SAPIAQFSBGRhdGE=');

@$core.Deprecated('Use organizationSaveResponseDescriptor instead')
const OrganizationSaveResponse$json = {
  '1': 'OrganizationSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.OrganizationObject', '10': 'data'},
  ],
};

/// Descriptor for `OrganizationSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List organizationSaveResponseDescriptor = $convert.base64Decode(
    'ChhPcmdhbml6YXRpb25TYXZlUmVzcG9uc2USMwoEZGF0YRgBIAEoCzIfLmlkZW50aXR5LnYxLk'
    '9yZ2FuaXphdGlvbk9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use organizationGetRequestDescriptor instead')
const OrganizationGetRequest$json = {
  '1': 'OrganizationGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `OrganizationGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List organizationGetRequestDescriptor = $convert.base64Decode(
    'ChZPcmdhbml6YXRpb25HZXRSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLX'
    'pfLV17Myw0MH1SAmlk');

@$core.Deprecated('Use organizationGetResponseDescriptor instead')
const OrganizationGetResponse$json = {
  '1': 'OrganizationGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.OrganizationObject', '10': 'data'},
  ],
};

/// Descriptor for `OrganizationGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List organizationGetResponseDescriptor = $convert.base64Decode(
    'ChdPcmdhbml6YXRpb25HZXRSZXNwb25zZRIzCgRkYXRhGAEgASgLMh8uaWRlbnRpdHkudjEuT3'
    'JnYW5pemF0aW9uT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use organizationSearchResponseDescriptor instead')
const OrganizationSearchResponse$json = {
  '1': 'OrganizationSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.OrganizationObject', '10': 'data'},
  ],
};

/// Descriptor for `OrganizationSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List organizationSearchResponseDescriptor = $convert.base64Decode(
    'ChpPcmdhbml6YXRpb25TZWFyY2hSZXNwb25zZRIzCgRkYXRhGAEgAygLMh8uaWRlbnRpdHkudj'
    'EuT3JnYW5pemF0aW9uT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use orgUnitSaveRequestDescriptor instead')
const OrgUnitSaveRequest$json = {
  '1': 'OrgUnitSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.OrgUnitObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `OrgUnitSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orgUnitSaveRequestDescriptor = $convert.base64Decode(
    'ChJPcmdVbml0U2F2ZVJlcXVlc3QSNgoEZGF0YRgBIAEoCzIaLmlkZW50aXR5LnYxLk9yZ1VuaX'
    'RPYmplY3RCBrpIA8gBAVIEZGF0YQ==');

@$core.Deprecated('Use orgUnitSaveResponseDescriptor instead')
const OrgUnitSaveResponse$json = {
  '1': 'OrgUnitSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.OrgUnitObject', '10': 'data'},
  ],
};

/// Descriptor for `OrgUnitSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orgUnitSaveResponseDescriptor = $convert.base64Decode(
    'ChNPcmdVbml0U2F2ZVJlc3BvbnNlEi4KBGRhdGEYASABKAsyGi5pZGVudGl0eS52MS5PcmdVbm'
    'l0T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use orgUnitGetRequestDescriptor instead')
const OrgUnitGetRequest$json = {
  '1': 'OrgUnitGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `OrgUnitGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orgUnitGetRequestDescriptor = $convert.base64Decode(
    'ChFPcmdVbml0R2V0UmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy1dez'
    'MsNDB9UgJpZA==');

@$core.Deprecated('Use orgUnitGetResponseDescriptor instead')
const OrgUnitGetResponse$json = {
  '1': 'OrgUnitGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.OrgUnitObject', '10': 'data'},
  ],
};

/// Descriptor for `OrgUnitGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orgUnitGetResponseDescriptor = $convert.base64Decode(
    'ChJPcmdVbml0R2V0UmVzcG9uc2USLgoEZGF0YRgBIAEoCzIaLmlkZW50aXR5LnYxLk9yZ1VuaX'
    'RPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use orgUnitSearchRequestDescriptor instead')
const OrgUnitSearchRequest$json = {
  '1': 'OrgUnitSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'parent_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'parentId'},
    {'1': 'root_only', '3': 4, '4': 1, '5': 8, '10': 'rootOnly'},
    {'1': 'type', '3': 5, '4': 1, '5': 14, '6': '.identity.v1.OrgUnitType', '10': 'type'},
    {'1': 'cursor', '3': 6, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `OrgUnitSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orgUnitSearchRequestDescriptor = $convert.base64Decode(
    'ChRPcmdVbml0U2VhcmNoUmVxdWVzdBIUCgVxdWVyeRgBIAEoCVIFcXVlcnkSNQoPb3JnYW5pem'
    'F0aW9uX2lkGAIgASgJQgy6SAnYAQFyBBADGChSDm9yZ2FuaXphdGlvbklkEikKCXBhcmVudF9p'
    'ZBgDIAEoCUIMukgJ2AEBcgQQAxgoUghwYXJlbnRJZBIbCglyb290X29ubHkYBCABKAhSCHJvb3'
    'RPbmx5EiwKBHR5cGUYBSABKA4yGC5pZGVudGl0eS52MS5PcmdVbml0VHlwZVIEdHlwZRItCgZj'
    'dXJzb3IYBiABKAsyFS5jb21tb24udjEuUGFnZUN1cnNvclIGY3Vyc29y');

@$core.Deprecated('Use orgUnitSearchResponseDescriptor instead')
const OrgUnitSearchResponse$json = {
  '1': 'OrgUnitSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.OrgUnitObject', '10': 'data'},
  ],
};

/// Descriptor for `OrgUnitSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orgUnitSearchResponseDescriptor = $convert.base64Decode(
    'ChVPcmdVbml0U2VhcmNoUmVzcG9uc2USLgoEZGF0YRgBIAMoCzIaLmlkZW50aXR5LnYxLk9yZ1'
    'VuaXRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use investorSaveRequestDescriptor instead')
const InvestorSaveRequest$json = {
  '1': 'InvestorSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.InvestorObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `InvestorSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorSaveRequestDescriptor = $convert.base64Decode(
    'ChNJbnZlc3RvclNhdmVSZXF1ZXN0EjcKBGRhdGEYASABKAsyGy5pZGVudGl0eS52MS5JbnZlc3'
    'Rvck9iamVjdEIGukgDyAEBUgRkYXRh');

@$core.Deprecated('Use investorSaveResponseDescriptor instead')
const InvestorSaveResponse$json = {
  '1': 'InvestorSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.InvestorObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorSaveResponseDescriptor = $convert.base64Decode(
    'ChRJbnZlc3RvclNhdmVSZXNwb25zZRIvCgRkYXRhGAEgASgLMhsuaWRlbnRpdHkudjEuSW52ZX'
    'N0b3JPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use investorGetRequestDescriptor instead')
const InvestorGetRequest$json = {
  '1': 'InvestorGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `InvestorGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorGetRequestDescriptor = $convert.base64Decode(
    'ChJJbnZlc3RvckdldFJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXX'
    'szLDQwfVICaWQ=');

@$core.Deprecated('Use investorGetResponseDescriptor instead')
const InvestorGetResponse$json = {
  '1': 'InvestorGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.InvestorObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorGetResponseDescriptor = $convert.base64Decode(
    'ChNJbnZlc3RvckdldFJlc3BvbnNlEi8KBGRhdGEYASABKAsyGy5pZGVudGl0eS52MS5JbnZlc3'
    'Rvck9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use investorSearchRequestDescriptor instead')
const InvestorSearchRequest$json = {
  '1': 'InvestorSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'cursor', '3': 2, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `InvestorSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorSearchRequestDescriptor = $convert.base64Decode(
    'ChVJbnZlc3RvclNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5Ei0KBmN1cnNvch'
    'gCIAEoCzIVLmNvbW1vbi52MS5QYWdlQ3Vyc29yUgZjdXJzb3I=');

@$core.Deprecated('Use investorSearchResponseDescriptor instead')
const InvestorSearchResponse$json = {
  '1': 'InvestorSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.InvestorObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorSearchResponseDescriptor = $convert.base64Decode(
    'ChZJbnZlc3RvclNlYXJjaFJlc3BvbnNlEi8KBGRhdGEYASADKAsyGy5pZGVudGl0eS52MS5Jbn'
    'Zlc3Rvck9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use workforceMemberSaveRequestDescriptor instead')
const WorkforceMemberSaveRequest$json = {
  '1': 'WorkforceMemberSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.WorkforceMemberObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `WorkforceMemberSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workforceMemberSaveRequestDescriptor = $convert.base64Decode(
    'ChpXb3JrZm9yY2VNZW1iZXJTYXZlUmVxdWVzdBI+CgRkYXRhGAEgASgLMiIuaWRlbnRpdHkudj'
    'EuV29ya2ZvcmNlTWVtYmVyT2JqZWN0Qga6SAPIAQFSBGRhdGE=');

@$core.Deprecated('Use workforceMemberSaveResponseDescriptor instead')
const WorkforceMemberSaveResponse$json = {
  '1': 'WorkforceMemberSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.WorkforceMemberObject', '10': 'data'},
  ],
};

/// Descriptor for `WorkforceMemberSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workforceMemberSaveResponseDescriptor = $convert.base64Decode(
    'ChtXb3JrZm9yY2VNZW1iZXJTYXZlUmVzcG9uc2USNgoEZGF0YRgBIAEoCzIiLmlkZW50aXR5Ln'
    'YxLldvcmtmb3JjZU1lbWJlck9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use workforceMemberGetRequestDescriptor instead')
const WorkforceMemberGetRequest$json = {
  '1': 'WorkforceMemberGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `WorkforceMemberGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workforceMemberGetRequestDescriptor = $convert.base64Decode(
    'ChlXb3JrZm9yY2VNZW1iZXJHZXRSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLT'
    'lhLXpfLV17Myw0MH1SAmlk');

@$core.Deprecated('Use workforceMemberGetResponseDescriptor instead')
const WorkforceMemberGetResponse$json = {
  '1': 'WorkforceMemberGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.WorkforceMemberObject', '10': 'data'},
  ],
};

/// Descriptor for `WorkforceMemberGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workforceMemberGetResponseDescriptor = $convert.base64Decode(
    'ChpXb3JrZm9yY2VNZW1iZXJHZXRSZXNwb25zZRI2CgRkYXRhGAEgASgLMiIuaWRlbnRpdHkudj'
    'EuV29ya2ZvcmNlTWVtYmVyT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use workforceMemberSearchRequestDescriptor instead')
const WorkforceMemberSearchRequest$json = {
  '1': 'WorkforceMemberSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'home_org_unit_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'homeOrgUnitId'},
    {'1': 'cursor', '3': 4, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `WorkforceMemberSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workforceMemberSearchRequestDescriptor = $convert.base64Decode(
    'ChxXb3JrZm9yY2VNZW1iZXJTZWFyY2hSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeRIzCg'
    '9vcmdhbml6YXRpb25faWQYAiABKAlCCrpIB9gBAXICGChSDm9yZ2FuaXphdGlvbklkEjMKEGhv'
    'bWVfb3JnX3VuaXRfaWQYAyABKAlCCrpIB9gBAXICGChSDWhvbWVPcmdVbml0SWQSLQoGY3Vyc2'
    '9yGAQgASgLMhUuY29tbW9uLnYxLlBhZ2VDdXJzb3JSBmN1cnNvcg==');

@$core.Deprecated('Use workforceMemberSearchResponseDescriptor instead')
const WorkforceMemberSearchResponse$json = {
  '1': 'WorkforceMemberSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.WorkforceMemberObject', '10': 'data'},
  ],
};

/// Descriptor for `WorkforceMemberSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workforceMemberSearchResponseDescriptor = $convert.base64Decode(
    'Ch1Xb3JrZm9yY2VNZW1iZXJTZWFyY2hSZXNwb25zZRI2CgRkYXRhGAEgAygLMiIuaWRlbnRpdH'
    'kudjEuV29ya2ZvcmNlTWVtYmVyT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use departmentSaveRequestDescriptor instead')
const DepartmentSaveRequest$json = {
  '1': 'DepartmentSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.DepartmentObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `DepartmentSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List departmentSaveRequestDescriptor = $convert.base64Decode(
    'ChVEZXBhcnRtZW50U2F2ZVJlcXVlc3QSOQoEZGF0YRgBIAEoCzIdLmlkZW50aXR5LnYxLkRlcG'
    'FydG1lbnRPYmplY3RCBrpIA8gBAVIEZGF0YQ==');

@$core.Deprecated('Use departmentSaveResponseDescriptor instead')
const DepartmentSaveResponse$json = {
  '1': 'DepartmentSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.DepartmentObject', '10': 'data'},
  ],
};

/// Descriptor for `DepartmentSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List departmentSaveResponseDescriptor = $convert.base64Decode(
    'ChZEZXBhcnRtZW50U2F2ZVJlc3BvbnNlEjEKBGRhdGEYASABKAsyHS5pZGVudGl0eS52MS5EZX'
    'BhcnRtZW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use departmentGetRequestDescriptor instead')
const DepartmentGetRequest$json = {
  '1': 'DepartmentGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `DepartmentGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List departmentGetRequestDescriptor = $convert.base64Decode(
    'ChREZXBhcnRtZW50R2V0UmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy'
    '1dezMsNDB9UgJpZA==');

@$core.Deprecated('Use departmentGetResponseDescriptor instead')
const DepartmentGetResponse$json = {
  '1': 'DepartmentGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.DepartmentObject', '10': 'data'},
  ],
};

/// Descriptor for `DepartmentGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List departmentGetResponseDescriptor = $convert.base64Decode(
    'ChVEZXBhcnRtZW50R2V0UmVzcG9uc2USMQoEZGF0YRgBIAEoCzIdLmlkZW50aXR5LnYxLkRlcG'
    'FydG1lbnRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use departmentSearchRequestDescriptor instead')
const DepartmentSearchRequest$json = {
  '1': 'DepartmentSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'parent_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'parentId'},
    {'1': 'kind', '3': 4, '4': 1, '5': 14, '6': '.identity.v1.DepartmentKind', '10': 'kind'},
    {'1': 'cursor', '3': 5, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `DepartmentSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List departmentSearchRequestDescriptor = $convert.base64Decode(
    'ChdEZXBhcnRtZW50U2VhcmNoUmVxdWVzdBIUCgVxdWVyeRgBIAEoCVIFcXVlcnkSMwoPb3JnYW'
    '5pemF0aW9uX2lkGAIgASgJQgq6SAfYAQFyAhgoUg5vcmdhbml6YXRpb25JZBInCglwYXJlbnRf'
    'aWQYAyABKAlCCrpIB9gBAXICGChSCHBhcmVudElkEi8KBGtpbmQYBCABKA4yGy5pZGVudGl0eS'
    '52MS5EZXBhcnRtZW50S2luZFIEa2luZBItCgZjdXJzb3IYBSABKAsyFS5jb21tb24udjEuUGFn'
    'ZUN1cnNvclIGY3Vyc29y');

@$core.Deprecated('Use departmentSearchResponseDescriptor instead')
const DepartmentSearchResponse$json = {
  '1': 'DepartmentSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.DepartmentObject', '10': 'data'},
  ],
};

/// Descriptor for `DepartmentSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List departmentSearchResponseDescriptor = $convert.base64Decode(
    'ChhEZXBhcnRtZW50U2VhcmNoUmVzcG9uc2USMQoEZGF0YRgBIAMoCzIdLmlkZW50aXR5LnYxLk'
    'RlcGFydG1lbnRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use positionSaveRequestDescriptor instead')
const PositionSaveRequest$json = {
  '1': 'PositionSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.PositionObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `PositionSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionSaveRequestDescriptor = $convert.base64Decode(
    'ChNQb3NpdGlvblNhdmVSZXF1ZXN0EjcKBGRhdGEYASABKAsyGy5pZGVudGl0eS52MS5Qb3NpdG'
    'lvbk9iamVjdEIGukgDyAEBUgRkYXRh');

@$core.Deprecated('Use positionSaveResponseDescriptor instead')
const PositionSaveResponse$json = {
  '1': 'PositionSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.PositionObject', '10': 'data'},
  ],
};

/// Descriptor for `PositionSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionSaveResponseDescriptor = $convert.base64Decode(
    'ChRQb3NpdGlvblNhdmVSZXNwb25zZRIvCgRkYXRhGAEgASgLMhsuaWRlbnRpdHkudjEuUG9zaX'
    'Rpb25PYmplY3RSBGRhdGE=');

@$core.Deprecated('Use positionGetRequestDescriptor instead')
const PositionGetRequest$json = {
  '1': 'PositionGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `PositionGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionGetRequestDescriptor = $convert.base64Decode(
    'ChJQb3NpdGlvbkdldFJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel8tXX'
    'szLDQwfVICaWQ=');

@$core.Deprecated('Use positionGetResponseDescriptor instead')
const PositionGetResponse$json = {
  '1': 'PositionGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.PositionObject', '10': 'data'},
  ],
};

/// Descriptor for `PositionGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionGetResponseDescriptor = $convert.base64Decode(
    'ChNQb3NpdGlvbkdldFJlc3BvbnNlEi8KBGRhdGEYASABKAsyGy5pZGVudGl0eS52MS5Qb3NpdG'
    'lvbk9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use positionSearchRequestDescriptor instead')
const PositionSearchRequest$json = {
  '1': 'PositionSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'org_unit_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'orgUnitId'},
    {'1': 'department_id', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'departmentId'},
    {'1': 'reports_to_position_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'reportsToPositionId'},
    {'1': 'cursor', '3': 6, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `PositionSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionSearchRequestDescriptor = $convert.base64Decode(
    'ChVQb3NpdGlvblNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EjMKD29yZ2FuaX'
    'phdGlvbl9pZBgCIAEoCUIKukgH2AEBcgIYKFIOb3JnYW5pemF0aW9uSWQSKgoLb3JnX3VuaXRf'
    'aWQYAyABKAlCCrpIB9gBAXICGChSCW9yZ1VuaXRJZBIvCg1kZXBhcnRtZW50X2lkGAQgASgJQg'
    'q6SAfYAQFyAhgoUgxkZXBhcnRtZW50SWQSPwoWcmVwb3J0c190b19wb3NpdGlvbl9pZBgFIAEo'
    'CUIKukgH2AEBcgIYKFITcmVwb3J0c1RvUG9zaXRpb25JZBItCgZjdXJzb3IYBiABKAsyFS5jb2'
    '1tb24udjEuUGFnZUN1cnNvclIGY3Vyc29y');

@$core.Deprecated('Use positionSearchResponseDescriptor instead')
const PositionSearchResponse$json = {
  '1': 'PositionSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.PositionObject', '10': 'data'},
  ],
};

/// Descriptor for `PositionSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionSearchResponseDescriptor = $convert.base64Decode(
    'ChZQb3NpdGlvblNlYXJjaFJlc3BvbnNlEi8KBGRhdGEYASADKAsyGy5pZGVudGl0eS52MS5Qb3'
    'NpdGlvbk9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use positionAssignmentSaveRequestDescriptor instead')
const PositionAssignmentSaveRequest$json = {
  '1': 'PositionAssignmentSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.PositionAssignmentObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `PositionAssignmentSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionAssignmentSaveRequestDescriptor = $convert.base64Decode(
    'Ch1Qb3NpdGlvbkFzc2lnbm1lbnRTYXZlUmVxdWVzdBJBCgRkYXRhGAEgASgLMiUuaWRlbnRpdH'
    'kudjEuUG9zaXRpb25Bc3NpZ25tZW50T2JqZWN0Qga6SAPIAQFSBGRhdGE=');

@$core.Deprecated('Use positionAssignmentSaveResponseDescriptor instead')
const PositionAssignmentSaveResponse$json = {
  '1': 'PositionAssignmentSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.PositionAssignmentObject', '10': 'data'},
  ],
};

/// Descriptor for `PositionAssignmentSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionAssignmentSaveResponseDescriptor = $convert.base64Decode(
    'Ch5Qb3NpdGlvbkFzc2lnbm1lbnRTYXZlUmVzcG9uc2USOQoEZGF0YRgBIAEoCzIlLmlkZW50aX'
    'R5LnYxLlBvc2l0aW9uQXNzaWdubWVudE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use positionAssignmentGetRequestDescriptor instead')
const PositionAssignmentGetRequest$json = {
  '1': 'PositionAssignmentGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `PositionAssignmentGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionAssignmentGetRequestDescriptor = $convert.base64Decode(
    'ChxQb3NpdGlvbkFzc2lnbm1lbnRHZXRSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEF'
    'swLTlhLXpfLV17Myw0MH1SAmlk');

@$core.Deprecated('Use positionAssignmentGetResponseDescriptor instead')
const PositionAssignmentGetResponse$json = {
  '1': 'PositionAssignmentGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.PositionAssignmentObject', '10': 'data'},
  ],
};

/// Descriptor for `PositionAssignmentGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionAssignmentGetResponseDescriptor = $convert.base64Decode(
    'Ch1Qb3NpdGlvbkFzc2lnbm1lbnRHZXRSZXNwb25zZRI5CgRkYXRhGAEgASgLMiUuaWRlbnRpdH'
    'kudjEuUG9zaXRpb25Bc3NpZ25tZW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use positionAssignmentSearchRequestDescriptor instead')
const PositionAssignmentSearchRequest$json = {
  '1': 'PositionAssignmentSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'member_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'memberId'},
    {'1': 'position_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'positionId'},
    {'1': 'cursor', '3': 4, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `PositionAssignmentSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionAssignmentSearchRequestDescriptor = $convert.base64Decode(
    'Ch9Qb3NpdGlvbkFzc2lnbm1lbnRTZWFyY2hSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeR'
    'InCgltZW1iZXJfaWQYAiABKAlCCrpIB9gBAXICGChSCG1lbWJlcklkEisKC3Bvc2l0aW9uX2lk'
    'GAMgASgJQgq6SAfYAQFyAhgoUgpwb3NpdGlvbklkEi0KBmN1cnNvchgEIAEoCzIVLmNvbW1vbi'
    '52MS5QYWdlQ3Vyc29yUgZjdXJzb3I=');

@$core.Deprecated('Use positionAssignmentSearchResponseDescriptor instead')
const PositionAssignmentSearchResponse$json = {
  '1': 'PositionAssignmentSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.PositionAssignmentObject', '10': 'data'},
  ],
};

/// Descriptor for `PositionAssignmentSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionAssignmentSearchResponseDescriptor = $convert.base64Decode(
    'CiBQb3NpdGlvbkFzc2lnbm1lbnRTZWFyY2hSZXNwb25zZRI5CgRkYXRhGAEgAygLMiUuaWRlbn'
    'RpdHkudjEuUG9zaXRpb25Bc3NpZ25tZW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use internalTeamSaveRequestDescriptor instead')
const InternalTeamSaveRequest$json = {
  '1': 'InternalTeamSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.InternalTeamObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `InternalTeamSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List internalTeamSaveRequestDescriptor = $convert.base64Decode(
    'ChdJbnRlcm5hbFRlYW1TYXZlUmVxdWVzdBI7CgRkYXRhGAEgASgLMh8uaWRlbnRpdHkudjEuSW'
    '50ZXJuYWxUZWFtT2JqZWN0Qga6SAPIAQFSBGRhdGE=');

@$core.Deprecated('Use internalTeamSaveResponseDescriptor instead')
const InternalTeamSaveResponse$json = {
  '1': 'InternalTeamSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.InternalTeamObject', '10': 'data'},
  ],
};

/// Descriptor for `InternalTeamSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List internalTeamSaveResponseDescriptor = $convert.base64Decode(
    'ChhJbnRlcm5hbFRlYW1TYXZlUmVzcG9uc2USMwoEZGF0YRgBIAEoCzIfLmlkZW50aXR5LnYxLk'
    'ludGVybmFsVGVhbU9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use internalTeamGetRequestDescriptor instead')
const InternalTeamGetRequest$json = {
  '1': 'InternalTeamGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `InternalTeamGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List internalTeamGetRequestDescriptor = $convert.base64Decode(
    'ChZJbnRlcm5hbFRlYW1HZXRSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLX'
    'pfLV17Myw0MH1SAmlk');

@$core.Deprecated('Use internalTeamGetResponseDescriptor instead')
const InternalTeamGetResponse$json = {
  '1': 'InternalTeamGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.InternalTeamObject', '10': 'data'},
  ],
};

/// Descriptor for `InternalTeamGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List internalTeamGetResponseDescriptor = $convert.base64Decode(
    'ChdJbnRlcm5hbFRlYW1HZXRSZXNwb25zZRIzCgRkYXRhGAEgASgLMh8uaWRlbnRpdHkudjEuSW'
    '50ZXJuYWxUZWFtT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use internalTeamSearchRequestDescriptor instead')
const InternalTeamSearchRequest$json = {
  '1': 'InternalTeamSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'home_org_unit_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'homeOrgUnitId'},
    {'1': 'team_type', '3': 4, '4': 1, '5': 9, '10': 'teamType'},
    {'1': 'cursor', '3': 5, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `InternalTeamSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List internalTeamSearchRequestDescriptor = $convert.base64Decode(
    'ChlJbnRlcm5hbFRlYW1TZWFyY2hSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeRIzCg9vcm'
    'dhbml6YXRpb25faWQYAiABKAlCCrpIB9gBAXICGChSDm9yZ2FuaXphdGlvbklkEjMKEGhvbWVf'
    'b3JnX3VuaXRfaWQYAyABKAlCCrpIB9gBAXICGChSDWhvbWVPcmdVbml0SWQSGwoJdGVhbV90eX'
    'BlGAQgASgJUgh0ZWFtVHlwZRItCgZjdXJzb3IYBSABKAsyFS5jb21tb24udjEuUGFnZUN1cnNv'
    'clIGY3Vyc29y');

@$core.Deprecated('Use internalTeamSearchResponseDescriptor instead')
const InternalTeamSearchResponse$json = {
  '1': 'InternalTeamSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.InternalTeamObject', '10': 'data'},
  ],
};

/// Descriptor for `InternalTeamSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List internalTeamSearchResponseDescriptor = $convert.base64Decode(
    'ChpJbnRlcm5hbFRlYW1TZWFyY2hSZXNwb25zZRIzCgRkYXRhGAEgAygLMh8uaWRlbnRpdHkudj'
    'EuSW50ZXJuYWxUZWFtT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use teamMembershipSaveRequestDescriptor instead')
const TeamMembershipSaveRequest$json = {
  '1': 'TeamMembershipSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.TeamMembershipObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `TeamMembershipSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMembershipSaveRequestDescriptor = $convert.base64Decode(
    'ChlUZWFtTWVtYmVyc2hpcFNhdmVSZXF1ZXN0Ej0KBGRhdGEYASABKAsyIS5pZGVudGl0eS52MS'
    '5UZWFtTWVtYmVyc2hpcE9iamVjdEIGukgDyAEBUgRkYXRh');

@$core.Deprecated('Use teamMembershipSaveResponseDescriptor instead')
const TeamMembershipSaveResponse$json = {
  '1': 'TeamMembershipSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.TeamMembershipObject', '10': 'data'},
  ],
};

/// Descriptor for `TeamMembershipSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMembershipSaveResponseDescriptor = $convert.base64Decode(
    'ChpUZWFtTWVtYmVyc2hpcFNhdmVSZXNwb25zZRI1CgRkYXRhGAEgASgLMiEuaWRlbnRpdHkudj'
    'EuVGVhbU1lbWJlcnNoaXBPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use teamMembershipGetRequestDescriptor instead')
const TeamMembershipGetRequest$json = {
  '1': 'TeamMembershipGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `TeamMembershipGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMembershipGetRequestDescriptor = $convert.base64Decode(
    'ChhUZWFtTWVtYmVyc2hpcEdldFJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOW'
    'Etel8tXXszLDQwfVICaWQ=');

@$core.Deprecated('Use teamMembershipGetResponseDescriptor instead')
const TeamMembershipGetResponse$json = {
  '1': 'TeamMembershipGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.TeamMembershipObject', '10': 'data'},
  ],
};

/// Descriptor for `TeamMembershipGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMembershipGetResponseDescriptor = $convert.base64Decode(
    'ChlUZWFtTWVtYmVyc2hpcEdldFJlc3BvbnNlEjUKBGRhdGEYASABKAsyIS5pZGVudGl0eS52MS'
    '5UZWFtTWVtYmVyc2hpcE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use teamMembershipSearchRequestDescriptor instead')
const TeamMembershipSearchRequest$json = {
  '1': 'TeamMembershipSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'team_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'teamId'},
    {'1': 'member_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'memberId'},
    {'1': 'cursor', '3': 4, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `TeamMembershipSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMembershipSearchRequestDescriptor = $convert.base64Decode(
    'ChtUZWFtTWVtYmVyc2hpcFNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EiMKB3'
    'RlYW1faWQYAiABKAlCCrpIB9gBAXICGChSBnRlYW1JZBInCgltZW1iZXJfaWQYAyABKAlCCrpI'
    'B9gBAXICGChSCG1lbWJlcklkEi0KBmN1cnNvchgEIAEoCzIVLmNvbW1vbi52MS5QYWdlQ3Vyc2'
    '9yUgZjdXJzb3I=');

@$core.Deprecated('Use teamMembershipSearchResponseDescriptor instead')
const TeamMembershipSearchResponse$json = {
  '1': 'TeamMembershipSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.TeamMembershipObject', '10': 'data'},
  ],
};

/// Descriptor for `TeamMembershipSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMembershipSearchResponseDescriptor = $convert.base64Decode(
    'ChxUZWFtTWVtYmVyc2hpcFNlYXJjaFJlc3BvbnNlEjUKBGRhdGEYASADKAsyIS5pZGVudGl0eS'
    '52MS5UZWFtTWVtYmVyc2hpcE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use accessRoleAssignmentSaveRequestDescriptor instead')
const AccessRoleAssignmentSaveRequest$json = {
  '1': 'AccessRoleAssignmentSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.AccessRoleAssignmentObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `AccessRoleAssignmentSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessRoleAssignmentSaveRequestDescriptor = $convert.base64Decode(
    'Ch9BY2Nlc3NSb2xlQXNzaWdubWVudFNhdmVSZXF1ZXN0EkMKBGRhdGEYASABKAsyJy5pZGVudG'
    'l0eS52MS5BY2Nlc3NSb2xlQXNzaWdubWVudE9iamVjdEIGukgDyAEBUgRkYXRh');

@$core.Deprecated('Use accessRoleAssignmentSaveResponseDescriptor instead')
const AccessRoleAssignmentSaveResponse$json = {
  '1': 'AccessRoleAssignmentSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.AccessRoleAssignmentObject', '10': 'data'},
  ],
};

/// Descriptor for `AccessRoleAssignmentSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessRoleAssignmentSaveResponseDescriptor = $convert.base64Decode(
    'CiBBY2Nlc3NSb2xlQXNzaWdubWVudFNhdmVSZXNwb25zZRI7CgRkYXRhGAEgASgLMicuaWRlbn'
    'RpdHkudjEuQWNjZXNzUm9sZUFzc2lnbm1lbnRPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use accessRoleAssignmentGetRequestDescriptor instead')
const AccessRoleAssignmentGetRequest$json = {
  '1': 'AccessRoleAssignmentGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `AccessRoleAssignmentGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessRoleAssignmentGetRequestDescriptor = $convert.base64Decode(
    'Ch5BY2Nlc3NSb2xlQXNzaWdubWVudEdldFJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKD'
    'IQWzAtOWEtel8tXXszLDQwfVICaWQ=');

@$core.Deprecated('Use accessRoleAssignmentGetResponseDescriptor instead')
const AccessRoleAssignmentGetResponse$json = {
  '1': 'AccessRoleAssignmentGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.AccessRoleAssignmentObject', '10': 'data'},
  ],
};

/// Descriptor for `AccessRoleAssignmentGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessRoleAssignmentGetResponseDescriptor = $convert.base64Decode(
    'Ch9BY2Nlc3NSb2xlQXNzaWdubWVudEdldFJlc3BvbnNlEjsKBGRhdGEYASABKAsyJy5pZGVudG'
    'l0eS52MS5BY2Nlc3NSb2xlQXNzaWdubWVudE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use accessRoleAssignmentSearchRequestDescriptor instead')
const AccessRoleAssignmentSearchRequest$json = {
  '1': 'AccessRoleAssignmentSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'member_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'memberId'},
    {'1': 'role_key', '3': 3, '4': 1, '5': 9, '10': 'roleKey'},
    {'1': 'scope_type', '3': 4, '4': 1, '5': 14, '6': '.identity.v1.AccessScopeType', '10': 'scopeType'},
    {'1': 'scope_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'scopeId'},
    {'1': 'cursor', '3': 6, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `AccessRoleAssignmentSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessRoleAssignmentSearchRequestDescriptor = $convert.base64Decode(
    'CiFBY2Nlc3NSb2xlQXNzaWdubWVudFNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZX'
    'J5EicKCW1lbWJlcl9pZBgCIAEoCUIKukgH2AEBcgIYKFIIbWVtYmVySWQSGQoIcm9sZV9rZXkY'
    'AyABKAlSB3JvbGVLZXkSOwoKc2NvcGVfdHlwZRgEIAEoDjIcLmlkZW50aXR5LnYxLkFjY2Vzc1'
    'Njb3BlVHlwZVIJc2NvcGVUeXBlEiUKCHNjb3BlX2lkGAUgASgJQgq6SAfYAQFyAhgoUgdzY29w'
    'ZUlkEi0KBmN1cnNvchgGIAEoCzIVLmNvbW1vbi52MS5QYWdlQ3Vyc29yUgZjdXJzb3I=');

@$core.Deprecated('Use accessRoleAssignmentSearchResponseDescriptor instead')
const AccessRoleAssignmentSearchResponse$json = {
  '1': 'AccessRoleAssignmentSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.AccessRoleAssignmentObject', '10': 'data'},
  ],
};

/// Descriptor for `AccessRoleAssignmentSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessRoleAssignmentSearchResponseDescriptor = $convert.base64Decode(
    'CiJBY2Nlc3NSb2xlQXNzaWdubWVudFNlYXJjaFJlc3BvbnNlEjsKBGRhdGEYASADKAsyJy5pZG'
    'VudGl0eS52MS5BY2Nlc3NSb2xlQXNzaWdubWVudE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use clientGroupObjectDescriptor instead')
const ClientGroupObject$json = {
  '1': 'ClientGroupObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'product_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'productId'},
    {'1': 'parent_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'parentId'},
    {'1': 'agent_id', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'agentId'},
    {'1': 'branch_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'branchId'},
    {'1': 'profile_id', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
    {'1': 'name', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'group_type', '3': 8, '4': 1, '5': 5, '10': 'groupType'},
    {'1': 'currency_code', '3': 9, '4': 1, '5': 9, '10': 'currencyCode'},
    {'1': 'saving_amount', '3': 10, '4': 1, '5': 3, '10': 'savingAmount'},
    {'1': 'time_zone', '3': 11, '4': 1, '5': 9, '10': 'timeZone'},
    {'1': 'min_members', '3': 12, '4': 1, '5': 5, '10': 'minMembers'},
    {'1': 'max_members', '3': 13, '4': 1, '5': 5, '10': 'maxMembers'},
    {'1': 'state', '3': 14, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 15, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `ClientGroupObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientGroupObjectDescriptor = $convert.base64Decode(
    'ChFDbGllbnRHcm91cE9iamVjdBIuCgJpZBgBIAEoCUIeukgb2AEBchYQAxgoMhBbMC05YS16Xy'
    '1dezMsNDB9UgJpZBIpCgpwcm9kdWN0X2lkGAIgASgJQgq6SAfYAQFyAhgoUglwcm9kdWN0SWQS'
    'JwoJcGFyZW50X2lkGAMgASgJQgq6SAfYAQFyAhgoUghwYXJlbnRJZBIlCghhZ2VudF9pZBgEIA'
    'EoCUIKukgH2AEBcgIYKFIHYWdlbnRJZBInCglicmFuY2hfaWQYBSABKAlCCrpIB9gBAXICGChS'
    'CGJyYW5jaElkEikKCnByb2ZpbGVfaWQYBiABKAlCCrpIB9gBAXICGChSCXByb2ZpbGVJZBIbCg'
    'RuYW1lGAcgASgJQge6SARyAhABUgRuYW1lEh0KCmdyb3VwX3R5cGUYCCABKAVSCWdyb3VwVHlw'
    'ZRIjCg1jdXJyZW5jeV9jb2RlGAkgASgJUgxjdXJyZW5jeUNvZGUSIwoNc2F2aW5nX2Ftb3VudB'
    'gKIAEoA1IMc2F2aW5nQW1vdW50EhsKCXRpbWVfem9uZRgLIAEoCVIIdGltZVpvbmUSHwoLbWlu'
    'X21lbWJlcnMYDCABKAVSCm1pbk1lbWJlcnMSHwoLbWF4X21lbWJlcnMYDSABKAVSCm1heE1lbW'
    'JlcnMSJgoFc3RhdGUYDiABKA4yEC5jb21tb24udjEuU1RBVEVSBXN0YXRlEjcKCnByb3BlcnRp'
    'ZXMYDyABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0Ugpwcm9wZXJ0aWVz');

@$core.Deprecated('Use clientGroupSaveRequestDescriptor instead')
const ClientGroupSaveRequest$json = {
  '1': 'ClientGroupSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.ClientGroupObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `ClientGroupSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientGroupSaveRequestDescriptor = $convert.base64Decode(
    'ChZDbGllbnRHcm91cFNhdmVSZXF1ZXN0EjoKBGRhdGEYASABKAsyHi5pZGVudGl0eS52MS5DbG'
    'llbnRHcm91cE9iamVjdEIGukgDyAEBUgRkYXRh');

@$core.Deprecated('Use clientGroupSaveResponseDescriptor instead')
const ClientGroupSaveResponse$json = {
  '1': 'ClientGroupSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.ClientGroupObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientGroupSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientGroupSaveResponseDescriptor = $convert.base64Decode(
    'ChdDbGllbnRHcm91cFNhdmVSZXNwb25zZRIyCgRkYXRhGAEgASgLMh4uaWRlbnRpdHkudjEuQ2'
    'xpZW50R3JvdXBPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use clientGroupGetRequestDescriptor instead')
const ClientGroupGetRequest$json = {
  '1': 'ClientGroupGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `ClientGroupGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientGroupGetRequestDescriptor = $convert.base64Decode(
    'ChVDbGllbnRHcm91cEdldFJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOWEtel'
    '8tXXszLDQwfVICaWQ=');

@$core.Deprecated('Use clientGroupGetResponseDescriptor instead')
const ClientGroupGetResponse$json = {
  '1': 'ClientGroupGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.ClientGroupObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientGroupGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientGroupGetResponseDescriptor = $convert.base64Decode(
    'ChZDbGllbnRHcm91cEdldFJlc3BvbnNlEjIKBGRhdGEYASABKAsyHi5pZGVudGl0eS52MS5DbG'
    'llbnRHcm91cE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use clientGroupSearchRequestDescriptor instead')
const ClientGroupSearchRequest$json = {
  '1': 'ClientGroupSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'agent_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'agentId'},
    {'1': 'branch_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'branchId'},
    {'1': 'cursor', '3': 4, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `ClientGroupSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientGroupSearchRequestDescriptor = $convert.base64Decode(
    'ChhDbGllbnRHcm91cFNlYXJjaFJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EiUKCGFnZW'
    '50X2lkGAIgASgJQgq6SAfYAQFyAhgoUgdhZ2VudElkEicKCWJyYW5jaF9pZBgDIAEoCUIKukgH'
    '2AEBcgIYKFIIYnJhbmNoSWQSLQoGY3Vyc29yGAQgASgLMhUuY29tbW9uLnYxLlBhZ2VDdXJzb3'
    'JSBmN1cnNvcg==');

@$core.Deprecated('Use clientGroupSearchResponseDescriptor instead')
const ClientGroupSearchResponse$json = {
  '1': 'ClientGroupSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.ClientGroupObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientGroupSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientGroupSearchResponseDescriptor = $convert.base64Decode(
    'ChlDbGllbnRHcm91cFNlYXJjaFJlc3BvbnNlEjIKBGRhdGEYASADKAsyHi5pZGVudGl0eS52MS'
    '5DbGllbnRHcm91cE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use membershipObjectDescriptor instead')
const MembershipObject$json = {
  '1': 'MembershipObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'groupId'},
    {'1': 'profile_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'contact_id', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'contactId'},
    {'1': 'role', '3': 6, '4': 1, '5': 5, '10': 'role'},
    {'1': 'membership_type', '3': 7, '4': 1, '5': 5, '10': 'membershipType'},
    {'1': 'order_no', '3': 8, '4': 1, '5': 5, '10': 'orderNo'},
    {'1': 'state', '3': 9, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `MembershipObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipObjectDescriptor = $convert.base64Decode(
    'ChBNZW1iZXJzaGlwT2JqZWN0Ei4KAmlkGAEgASgJQh66SBvYAQFyFhADGCgyEFswLTlhLXpfLV'
    '17Myw0MH1SAmlkEiQKCGdyb3VwX2lkGAIgASgJQgm6SAZyBBADGChSB2dyb3VwSWQSKQoKcHJv'
    'ZmlsZV9pZBgDIAEoCUIKukgH2AEBcgIYKFIJcHJvZmlsZUlkEhsKBG5hbWUYBCABKAlCB7pIBH'
    'ICEAFSBG5hbWUSKQoKY29udGFjdF9pZBgFIAEoCUIKukgH2AEBcgIYKFIJY29udGFjdElkEhIK'
    'BHJvbGUYBiABKAVSBHJvbGUSJwoPbWVtYmVyc2hpcF90eXBlGAcgASgFUg5tZW1iZXJzaGlwVH'
    'lwZRIZCghvcmRlcl9ubxgIIAEoBVIHb3JkZXJObxImCgVzdGF0ZRgJIAEoDjIQLmNvbW1vbi52'
    'MS5TVEFURVIFc3RhdGUSNwoKcHJvcGVydGllcxgKIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdH'
    'J1Y3RSCnByb3BlcnRpZXM=');

@$core.Deprecated('Use membershipSaveRequestDescriptor instead')
const MembershipSaveRequest$json = {
  '1': 'MembershipSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.MembershipObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `MembershipSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipSaveRequestDescriptor = $convert.base64Decode(
    'ChVNZW1iZXJzaGlwU2F2ZVJlcXVlc3QSOQoEZGF0YRgBIAEoCzIdLmlkZW50aXR5LnYxLk1lbW'
    'JlcnNoaXBPYmplY3RCBrpIA8gBAVIEZGF0YQ==');

@$core.Deprecated('Use membershipSaveResponseDescriptor instead')
const MembershipSaveResponse$json = {
  '1': 'MembershipSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.MembershipObject', '10': 'data'},
  ],
};

/// Descriptor for `MembershipSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipSaveResponseDescriptor = $convert.base64Decode(
    'ChZNZW1iZXJzaGlwU2F2ZVJlc3BvbnNlEjEKBGRhdGEYASABKAsyHS5pZGVudGl0eS52MS5NZW'
    '1iZXJzaGlwT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use membershipGetRequestDescriptor instead')
const MembershipGetRequest$json = {
  '1': 'MembershipGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `MembershipGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipGetRequestDescriptor = $convert.base64Decode(
    'ChRNZW1iZXJzaGlwR2V0UmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC05YS16Xy'
    '1dezMsNDB9UgJpZA==');

@$core.Deprecated('Use membershipGetResponseDescriptor instead')
const MembershipGetResponse$json = {
  '1': 'MembershipGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.MembershipObject', '10': 'data'},
  ],
};

/// Descriptor for `MembershipGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipGetResponseDescriptor = $convert.base64Decode(
    'ChVNZW1iZXJzaGlwR2V0UmVzcG9uc2USMQoEZGF0YRgBIAEoCzIdLmlkZW50aXR5LnYxLk1lbW'
    'JlcnNoaXBPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use membershipSearchRequestDescriptor instead')
const MembershipSearchRequest$json = {
  '1': 'MembershipSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'groupId'},
    {'1': 'profile_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'profileId'},
    {'1': 'cursor', '3': 4, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `MembershipSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipSearchRequestDescriptor = $convert.base64Decode(
    'ChdNZW1iZXJzaGlwU2VhcmNoUmVxdWVzdBIUCgVxdWVyeRgBIAEoCVIFcXVlcnkSJQoIZ3JvdX'
    'BfaWQYAiABKAlCCrpIB9gBAXICGChSB2dyb3VwSWQSKQoKcHJvZmlsZV9pZBgDIAEoCUIKukgH'
    '2AEBcgIYKFIJcHJvZmlsZUlkEi0KBmN1cnNvchgEIAEoCzIVLmNvbW1vbi52MS5QYWdlQ3Vyc2'
    '9yUgZjdXJzb3I=');

@$core.Deprecated('Use membershipSearchResponseDescriptor instead')
const MembershipSearchResponse$json = {
  '1': 'MembershipSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.MembershipObject', '10': 'data'},
  ],
};

/// Descriptor for `MembershipSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipSearchResponseDescriptor = $convert.base64Decode(
    'ChhNZW1iZXJzaGlwU2VhcmNoUmVzcG9uc2USMQoEZGF0YRgBIAMoCzIdLmlkZW50aXR5LnYxLk'
    '1lbWJlcnNoaXBPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use investorAccountObjectDescriptor instead')
const InvestorAccountObject$json = {
  '1': 'InvestorAccountObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'investor_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'investorId'},
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
    'ChVJbnZlc3RvckFjY291bnRPYmplY3QSLgoCaWQYASABKAlCHrpIG9gBAXIWEAMYKDIQWzAtOW'
    'Etel8tXXszLDQwfVICaWQSKgoLaW52ZXN0b3JfaWQYAiABKAlCCbpIBnIEEAMYKFIKaW52ZXN0'
    'b3JJZBIhCgxhY2NvdW50X25hbWUYAyABKAlSC2FjY291bnROYW1lEj0KEWF2YWlsYWJsZV9iYW'
    'xhbmNlGAUgASgLMhAuY29tbW9uLnYxLk1vbmV5UhBhdmFpbGFibGVCYWxhbmNlEjsKEHJlc2Vy'
    'dmVkX2JhbGFuY2UYBiABKAsyEC5jb21tb24udjEuTW9uZXlSD3Jlc2VydmVkQmFsYW5jZRI3Cg'
    '50b3RhbF9kZXBsb3llZBgHIAEoCzIQLmNvbW1vbi52MS5Nb25leVINdG90YWxEZXBsb3llZBI3'
    'Cg50b3RhbF9yZXR1cm5lZBgIIAEoCzIQLmNvbW1vbi52MS5Nb25leVINdG90YWxSZXR1cm5lZB'
    'IzCgxtYXhfZXhwb3N1cmUYCSABKAsyEC5jb21tb24udjEuTW9uZXlSC21heEV4cG9zdXJlEioK'
    'EW1pbl9pbnRlcmVzdF9yYXRlGAogASgJUg9taW5JbnRlcmVzdFJhdGUSQgoQYWxsb3dlZF9wcm'
    '9kdWN0cxgLIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSD2FsbG93ZWRQcm9kdWN0cxJA'
    'Cg9hbGxvd2VkX3JlZ2lvbnMYDCABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0Ug5hbGxvd2'
    'VkUmVnaW9ucxJGChJncm91cF9hZmZpbGlhdGlvbnMYDSABKAsyFy5nb29nbGUucHJvdG9idWYu'
    'U3RydWN0UhFncm91cEFmZmlsaWF0aW9ucxImCgVzdGF0ZRgOIAEoDjIQLmNvbW1vbi52MS5TVE'
    'FURVIFc3RhdGUSNwoKcHJvcGVydGllcxgPIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RS'
    'CnByb3BlcnRpZXNKBAgEEAU=');

@$core.Deprecated('Use investorAccountSaveRequestDescriptor instead')
const InvestorAccountSaveRequest$json = {
  '1': 'InvestorAccountSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.InvestorAccountObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `InvestorAccountSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSaveRequestDescriptor = $convert.base64Decode(
    'ChpJbnZlc3RvckFjY291bnRTYXZlUmVxdWVzdBI+CgRkYXRhGAEgASgLMiIuaWRlbnRpdHkudj'
    'EuSW52ZXN0b3JBY2NvdW50T2JqZWN0Qga6SAPIAQFSBGRhdGE=');

@$core.Deprecated('Use investorAccountSaveResponseDescriptor instead')
const InvestorAccountSaveResponse$json = {
  '1': 'InvestorAccountSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.InvestorAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorAccountSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSaveResponseDescriptor = $convert.base64Decode(
    'ChtJbnZlc3RvckFjY291bnRTYXZlUmVzcG9uc2USNgoEZGF0YRgBIAEoCzIiLmlkZW50aXR5Ln'
    'YxLkludmVzdG9yQWNjb3VudE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use investorAccountGetRequestDescriptor instead')
const InvestorAccountGetRequest$json = {
  '1': 'InvestorAccountGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `InvestorAccountGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountGetRequestDescriptor = $convert.base64Decode(
    'ChlJbnZlc3RvckFjY291bnRHZXRSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLT'
    'lhLXpfLV17Myw0MH1SAmlk');

@$core.Deprecated('Use investorAccountGetResponseDescriptor instead')
const InvestorAccountGetResponse$json = {
  '1': 'InvestorAccountGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.InvestorAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorAccountGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountGetResponseDescriptor = $convert.base64Decode(
    'ChpJbnZlc3RvckFjY291bnRHZXRSZXNwb25zZRI2CgRkYXRhGAEgASgLMiIuaWRlbnRpdHkudj'
    'EuSW52ZXN0b3JBY2NvdW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use investorAccountSearchRequestDescriptor instead')
const InvestorAccountSearchRequest$json = {
  '1': 'InvestorAccountSearchRequest',
  '2': [
    {'1': 'investor_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'investorId'},
    {'1': 'currency_code', '3': 2, '4': 1, '5': 9, '10': 'currencyCode'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `InvestorAccountSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSearchRequestDescriptor = $convert.base64Decode(
    'ChxJbnZlc3RvckFjY291bnRTZWFyY2hSZXF1ZXN0Ei0KC2ludmVzdG9yX2lkGAEgASgJQgy6SA'
    'nYAQFyBBADGChSCmludmVzdG9ySWQSIwoNY3VycmVuY3lfY29kZRgCIAEoCVIMY3VycmVuY3lD'
    'b2RlEi0KBmN1cnNvchgDIAEoCzIVLmNvbW1vbi52MS5QYWdlQ3Vyc29yUgZjdXJzb3I=');

@$core.Deprecated('Use investorAccountSearchResponseDescriptor instead')
const InvestorAccountSearchResponse$json = {
  '1': 'InvestorAccountSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.InvestorAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorAccountSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorAccountSearchResponseDescriptor = $convert.base64Decode(
    'Ch1JbnZlc3RvckFjY291bnRTZWFyY2hSZXNwb25zZRI2CgRkYXRhGAEgAygLMiIuaWRlbnRpdH'
    'kudjEuSW52ZXN0b3JBY2NvdW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use investorDepositRequestDescriptor instead')
const InvestorDepositRequest$json = {
  '1': 'InvestorDepositRequest',
  '2': [
    {'1': 'account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'accountId'},
    {'1': 'amount', '3': 2, '4': 1, '5': 11, '6': '.common.v1.Money', '8': {}, '10': 'amount'},
  ],
  '9': [
    {'1': 3, '2': 4},
  ],
};

/// Descriptor for `InvestorDepositRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorDepositRequestDescriptor = $convert.base64Decode(
    'ChZJbnZlc3RvckRlcG9zaXRSZXF1ZXN0EigKCmFjY291bnRfaWQYASABKAlCCbpIBnIEEAMYKF'
    'IJYWNjb3VudElkEjAKBmFtb3VudBgCIAEoCzIQLmNvbW1vbi52MS5Nb25leUIGukgDyAEBUgZh'
    'bW91bnRKBAgDEAQ=');

@$core.Deprecated('Use investorDepositResponseDescriptor instead')
const InvestorDepositResponse$json = {
  '1': 'InvestorDepositResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.InvestorAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorDepositResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorDepositResponseDescriptor = $convert.base64Decode(
    'ChdJbnZlc3RvckRlcG9zaXRSZXNwb25zZRI2CgRkYXRhGAEgASgLMiIuaWRlbnRpdHkudjEuSW'
    '52ZXN0b3JBY2NvdW50T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use investorWithdrawRequestDescriptor instead')
const InvestorWithdrawRequest$json = {
  '1': 'InvestorWithdrawRequest',
  '2': [
    {'1': 'account_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'accountId'},
    {'1': 'amount', '3': 2, '4': 1, '5': 11, '6': '.common.v1.Money', '8': {}, '10': 'amount'},
  ],
};

/// Descriptor for `InvestorWithdrawRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorWithdrawRequestDescriptor = $convert.base64Decode(
    'ChdJbnZlc3RvcldpdGhkcmF3UmVxdWVzdBIoCgphY2NvdW50X2lkGAEgASgJQgm6SAZyBBADGC'
    'hSCWFjY291bnRJZBIwCgZhbW91bnQYAiABKAsyEC5jb21tb24udjEuTW9uZXlCBrpIA8gBAVIG'
    'YW1vdW50');

@$core.Deprecated('Use investorWithdrawResponseDescriptor instead')
const InvestorWithdrawResponse$json = {
  '1': 'InvestorWithdrawResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.InvestorAccountObject', '10': 'data'},
  ],
};

/// Descriptor for `InvestorWithdrawResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List investorWithdrawResponseDescriptor = $convert.base64Decode(
    'ChhJbnZlc3RvcldpdGhkcmF3UmVzcG9uc2USNgoEZGF0YRgBIAEoCzIiLmlkZW50aXR5LnYxLk'
    'ludmVzdG9yQWNjb3VudE9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use formFieldDefinitionDescriptor instead')
const FormFieldDefinition$json = {
  '1': 'FormFieldDefinition',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'field_type', '3': 3, '4': 1, '5': 14, '6': '.identity.v1.FormFieldType', '10': 'fieldType'},
    {'1': 'group', '3': 4, '4': 1, '5': 14, '6': '.identity.v1.FormFieldGroup', '10': 'group'},
    {'1': 'required', '3': 5, '4': 1, '5': 8, '10': 'required'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'placeholder', '3': 7, '4': 1, '5': 9, '10': 'placeholder'},
    {'1': 'default_value', '3': 8, '4': 1, '5': 9, '10': 'defaultValue'},
    {'1': 'validation_pattern', '3': 9, '4': 1, '5': 9, '10': 'validationPattern'},
    {'1': 'validation_message', '3': 10, '4': 1, '5': 9, '10': 'validationMessage'},
    {'1': 'options', '3': 11, '4': 3, '5': 9, '10': 'options'},
    {'1': 'min_length', '3': 12, '4': 1, '5': 5, '10': 'minLength'},
    {'1': 'max_length', '3': 13, '4': 1, '5': 5, '10': 'maxLength'},
    {'1': 'min_value', '3': 14, '4': 1, '5': 9, '10': 'minValue'},
    {'1': 'max_value', '3': 15, '4': 1, '5': 9, '10': 'maxValue'},
    {'1': 'order', '3': 16, '4': 1, '5': 5, '10': 'order'},
    {'1': 'section', '3': 17, '4': 1, '5': 9, '10': 'section'},
    {'1': 'encrypted', '3': 18, '4': 1, '5': 8, '10': 'encrypted'},
    {'1': 'properties', '3': 19, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `FormFieldDefinition`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formFieldDefinitionDescriptor = $convert.base64Decode(
    'ChNGb3JtRmllbGREZWZpbml0aW9uEhAKA2tleRgBIAEoCVIDa2V5EhQKBWxhYmVsGAIgASgJUg'
    'VsYWJlbBI5CgpmaWVsZF90eXBlGAMgASgOMhouaWRlbnRpdHkudjEuRm9ybUZpZWxkVHlwZVIJ'
    'ZmllbGRUeXBlEjEKBWdyb3VwGAQgASgOMhsuaWRlbnRpdHkudjEuRm9ybUZpZWxkR3JvdXBSBW'
    'dyb3VwEhoKCHJlcXVpcmVkGAUgASgIUghyZXF1aXJlZBIgCgtkZXNjcmlwdGlvbhgGIAEoCVIL'
    'ZGVzY3JpcHRpb24SIAoLcGxhY2Vob2xkZXIYByABKAlSC3BsYWNlaG9sZGVyEiMKDWRlZmF1bH'
    'RfdmFsdWUYCCABKAlSDGRlZmF1bHRWYWx1ZRItChJ2YWxpZGF0aW9uX3BhdHRlcm4YCSABKAlS'
    'EXZhbGlkYXRpb25QYXR0ZXJuEi0KEnZhbGlkYXRpb25fbWVzc2FnZRgKIAEoCVIRdmFsaWRhdG'
    'lvbk1lc3NhZ2USGAoHb3B0aW9ucxgLIAMoCVIHb3B0aW9ucxIdCgptaW5fbGVuZ3RoGAwgASgF'
    'UgltaW5MZW5ndGgSHQoKbWF4X2xlbmd0aBgNIAEoBVIJbWF4TGVuZ3RoEhsKCW1pbl92YWx1ZR'
    'gOIAEoCVIIbWluVmFsdWUSGwoJbWF4X3ZhbHVlGA8gASgJUghtYXhWYWx1ZRIUCgVvcmRlchgQ'
    'IAEoBVIFb3JkZXISGAoHc2VjdGlvbhgRIAEoCVIHc2VjdGlvbhIcCgllbmNyeXB0ZWQYEiABKA'
    'hSCWVuY3J5cHRlZBI3Cgpwcm9wZXJ0aWVzGBMgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVj'
    'dFIKcHJvcGVydGllcw==');

@$core.Deprecated('Use formTemplateObjectDescriptor instead')
const FormTemplateObject$json = {
  '1': 'FormTemplateObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'version', '3': 5, '4': 1, '5': 5, '10': 'version'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.identity.v1.FormTemplateStatus', '10': 'status'},
    {'1': 'fields', '3': 7, '4': 3, '5': 11, '6': '.identity.v1.FormFieldDefinition', '10': 'fields'},
    {'1': 'sections', '3': 8, '4': 3, '5': 9, '10': 'sections'},
    {'1': 'validation_rules', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'validationRules'},
    {'1': 'properties', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
    {'1': 'entity_type', '3': 11, '4': 1, '5': 9, '10': 'entityType'},
  ],
};

/// Descriptor for `FormTemplateObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formTemplateObjectDescriptor = $convert.base64Decode(
    'ChJGb3JtVGVtcGxhdGVPYmplY3QSLgoCaWQYASABKAlCHrpIG9gBAXIWEAMYKDIQWzAtOWEtel'
    '8tXXszLDQwfVICaWQSMgoPb3JnYW5pemF0aW9uX2lkGAIgASgJQgm6SAZyBBADGChSDm9yZ2Fu'
    'aXphdGlvbklkEhsKBG5hbWUYAyABKAlCB7pIBHICEAFSBG5hbWUSIAoLZGVzY3JpcHRpb24YBC'
    'ABKAlSC2Rlc2NyaXB0aW9uEhgKB3ZlcnNpb24YBSABKAVSB3ZlcnNpb24SNwoGc3RhdHVzGAYg'
    'ASgOMh8uaWRlbnRpdHkudjEuRm9ybVRlbXBsYXRlU3RhdHVzUgZzdGF0dXMSOAoGZmllbGRzGA'
    'cgAygLMiAuaWRlbnRpdHkudjEuRm9ybUZpZWxkRGVmaW5pdGlvblIGZmllbGRzEhoKCHNlY3Rp'
    'b25zGAggAygJUghzZWN0aW9ucxJCChB2YWxpZGF0aW9uX3J1bGVzGAkgASgLMhcuZ29vZ2xlLn'
    'Byb3RvYnVmLlN0cnVjdFIPdmFsaWRhdGlvblJ1bGVzEjcKCnByb3BlcnRpZXMYCiABKAsyFy5n'
    'b29nbGUucHJvdG9idWYuU3RydWN0Ugpwcm9wZXJ0aWVzEh8KC2VudGl0eV90eXBlGAsgASgJUg'
    'plbnRpdHlUeXBl');

@$core.Deprecated('Use formSubmissionObjectDescriptor instead')
const FormSubmissionObject$json = {
  '1': 'FormSubmissionObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'entity_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'entityId'},
    {'1': 'entity_type', '3': 3, '4': 1, '5': 9, '10': 'entityType'},
    {'1': 'template_id', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'templateId'},
    {'1': 'template_version', '3': 5, '4': 1, '5': 5, '10': 'templateVersion'},
    {'1': 'submitted_by', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'submittedBy'},
    {'1': 'data', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'data'},
    {'1': 'file_refs', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'fileRefs'},
    {'1': 'state', '3': 9, '4': 1, '5': 14, '6': '.common.v1.STATE', '10': 'state'},
    {'1': 'properties', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `FormSubmissionObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formSubmissionObjectDescriptor = $convert.base64Decode(
    'ChRGb3JtU3VibWlzc2lvbk9iamVjdBIuCgJpZBgBIAEoCUIeukgb2AEBchYQAxgoMhBbMC05YS'
    '16Xy1dezMsNDB9UgJpZBImCgllbnRpdHlfaWQYAiABKAlCCbpIBnIEEAMYKFIIZW50aXR5SWQS'
    'HwoLZW50aXR5X3R5cGUYAyABKAlSCmVudGl0eVR5cGUSKgoLdGVtcGxhdGVfaWQYBCABKAlCCb'
    'pIBnIEEAMYKFIKdGVtcGxhdGVJZBIpChB0ZW1wbGF0ZV92ZXJzaW9uGAUgASgFUg90ZW1wbGF0'
    'ZVZlcnNpb24SLQoMc3VibWl0dGVkX2J5GAYgASgJQgq6SAfYAQFyAhgoUgtzdWJtaXR0ZWRCeR'
    'IrCgRkYXRhGAcgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIEZGF0YRI0CglmaWxlX3Jl'
    'ZnMYCCABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0UghmaWxlUmVmcxImCgVzdGF0ZRgJIA'
    'EoDjIQLmNvbW1vbi52MS5TVEFURVIFc3RhdGUSNwoKcHJvcGVydGllcxgKIAEoCzIXLmdvb2ds'
    'ZS5wcm90b2J1Zi5TdHJ1Y3RSCnByb3BlcnRpZXM=');

@$core.Deprecated('Use clientDataEntryObjectDescriptor instead')
const ClientDataEntryObject$json = {
  '1': 'ClientDataEntryObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'client_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'clientId'},
    {'1': 'field_key', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'fieldKey'},
    {'1': 'value', '3': 4, '4': 1, '5': 9, '10': 'value'},
    {'1': 'value_type', '3': 5, '4': 1, '5': 9, '10': 'valueType'},
    {'1': 'verification_status', '3': 6, '4': 1, '5': 14, '6': '.identity.v1.DataVerificationStatus', '10': 'verificationStatus'},
    {'1': 'reviewer_id', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'reviewerId'},
    {'1': 'reviewer_comment', '3': 8, '4': 1, '5': 9, '10': 'reviewerComment'},
    {'1': 'source_entity_id', '3': 9, '4': 1, '5': 9, '8': {}, '10': 'sourceEntityId'},
    {'1': 'revision', '3': 10, '4': 1, '5': 5, '10': 'revision'},
    {'1': 'verified_at', '3': 11, '4': 1, '5': 9, '10': 'verifiedAt'},
    {'1': 'expires_at', '3': 12, '4': 1, '5': 9, '10': 'expiresAt'},
    {'1': 'properties', '3': 13, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'properties'},
  ],
};

/// Descriptor for `ClientDataEntryObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataEntryObjectDescriptor = $convert.base64Decode(
    'ChVDbGllbnREYXRhRW50cnlPYmplY3QSLgoCaWQYASABKAlCHrpIG9gBAXIWEAMYKDIQWzAtOW'
    'Etel8tXXszLDQwfVICaWQSJgoJY2xpZW50X2lkGAIgASgJQgm6SAZyBBADGChSCGNsaWVudElk'
    'EiQKCWZpZWxkX2tleRgDIAEoCUIHukgEcgIQAVIIZmllbGRLZXkSFAoFdmFsdWUYBCABKAlSBX'
    'ZhbHVlEh0KCnZhbHVlX3R5cGUYBSABKAlSCXZhbHVlVHlwZRJUChN2ZXJpZmljYXRpb25fc3Rh'
    'dHVzGAYgASgOMiMuaWRlbnRpdHkudjEuRGF0YVZlcmlmaWNhdGlvblN0YXR1c1ISdmVyaWZpY2'
    'F0aW9uU3RhdHVzEisKC3Jldmlld2VyX2lkGAcgASgJQgq6SAfYAQFyAhgoUgpyZXZpZXdlcklk'
    'EikKEHJldmlld2VyX2NvbW1lbnQYCCABKAlSD3Jldmlld2VyQ29tbWVudBI0ChBzb3VyY2VfZW'
    '50aXR5X2lkGAkgASgJQgq6SAfYAQFyAhgoUg5zb3VyY2VFbnRpdHlJZBIaCghyZXZpc2lvbhgK'
    'IAEoBVIIcmV2aXNpb24SHwoLdmVyaWZpZWRfYXQYCyABKAlSCnZlcmlmaWVkQXQSHQoKZXhwaX'
    'Jlc19hdBgMIAEoCVIJZXhwaXJlc0F0EjcKCnByb3BlcnRpZXMYDSABKAsyFy5nb29nbGUucHJv'
    'dG9idWYuU3RydWN0Ugpwcm9wZXJ0aWVz');

@$core.Deprecated('Use clientDataEntryHistoryObjectDescriptor instead')
const ClientDataEntryHistoryObject$json = {
  '1': 'ClientDataEntryHistoryObject',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
    {'1': 'entry_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'entryId'},
    {'1': 'revision', '3': 3, '4': 1, '5': 5, '10': 'revision'},
    {'1': 'value', '3': 4, '4': 1, '5': 9, '10': 'value'},
    {'1': 'action', '3': 5, '4': 1, '5': 9, '10': 'action'},
    {'1': 'actor_id', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'actorId'},
    {'1': 'comment', '3': 7, '4': 1, '5': 9, '10': 'comment'},
    {'1': 'created_at', '3': 8, '4': 1, '5': 9, '10': 'createdAt'},
  ],
};

/// Descriptor for `ClientDataEntryHistoryObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataEntryHistoryObjectDescriptor = $convert.base64Decode(
    'ChxDbGllbnREYXRhRW50cnlIaXN0b3J5T2JqZWN0Ei4KAmlkGAEgASgJQh66SBvYAQFyFhADGC'
    'gyEFswLTlhLXpfLV17Myw0MH1SAmlkEiQKCGVudHJ5X2lkGAIgASgJQgm6SAZyBBADGChSB2Vu'
    'dHJ5SWQSGgoIcmV2aXNpb24YAyABKAVSCHJldmlzaW9uEhQKBXZhbHVlGAQgASgJUgV2YWx1ZR'
    'IWCgZhY3Rpb24YBSABKAlSBmFjdGlvbhIlCghhY3Rvcl9pZBgGIAEoCUIKukgH2AEBcgIYKFIH'
    'YWN0b3JJZBIYCgdjb21tZW50GAcgASgJUgdjb21tZW50Eh0KCmNyZWF0ZWRfYXQYCCABKAlSCW'
    'NyZWF0ZWRBdA==');

@$core.Deprecated('Use clientDataSaveRequestDescriptor instead')
const ClientDataSaveRequest$json = {
  '1': 'ClientDataSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.ClientDataEntryObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `ClientDataSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataSaveRequestDescriptor = $convert.base64Decode(
    'ChVDbGllbnREYXRhU2F2ZVJlcXVlc3QSPgoEZGF0YRgBIAEoCzIiLmlkZW50aXR5LnYxLkNsaW'
    'VudERhdGFFbnRyeU9iamVjdEIGukgDyAEBUgRkYXRh');

@$core.Deprecated('Use clientDataSaveResponseDescriptor instead')
const ClientDataSaveResponse$json = {
  '1': 'ClientDataSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.ClientDataEntryObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientDataSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataSaveResponseDescriptor = $convert.base64Decode(
    'ChZDbGllbnREYXRhU2F2ZVJlc3BvbnNlEjYKBGRhdGEYASABKAsyIi5pZGVudGl0eS52MS5DbG'
    'llbnREYXRhRW50cnlPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use clientDataGetRequestDescriptor instead')
const ClientDataGetRequest$json = {
  '1': 'ClientDataGetRequest',
  '2': [
    {'1': 'client_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'clientId'},
    {'1': 'field_key', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'fieldKey'},
  ],
};

/// Descriptor for `ClientDataGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataGetRequestDescriptor = $convert.base64Decode(
    'ChRDbGllbnREYXRhR2V0UmVxdWVzdBImCgljbGllbnRfaWQYASABKAlCCbpIBnIEEAMYKFIIY2'
    'xpZW50SWQSJAoJZmllbGRfa2V5GAIgASgJQge6SARyAhABUghmaWVsZEtleQ==');

@$core.Deprecated('Use clientDataGetResponseDescriptor instead')
const ClientDataGetResponse$json = {
  '1': 'ClientDataGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.ClientDataEntryObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientDataGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataGetResponseDescriptor = $convert.base64Decode(
    'ChVDbGllbnREYXRhR2V0UmVzcG9uc2USNgoEZGF0YRgBIAEoCzIiLmlkZW50aXR5LnYxLkNsaW'
    'VudERhdGFFbnRyeU9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use clientDataListRequestDescriptor instead')
const ClientDataListRequest$json = {
  '1': 'ClientDataListRequest',
  '2': [
    {'1': 'client_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'clientId'},
    {'1': 'verification_status', '3': 2, '4': 1, '5': 14, '6': '.identity.v1.DataVerificationStatus', '10': 'verificationStatus'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `ClientDataListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataListRequestDescriptor = $convert.base64Decode(
    'ChVDbGllbnREYXRhTGlzdFJlcXVlc3QSJgoJY2xpZW50X2lkGAEgASgJQgm6SAZyBBADGChSCG'
    'NsaWVudElkElQKE3ZlcmlmaWNhdGlvbl9zdGF0dXMYAiABKA4yIy5pZGVudGl0eS52MS5EYXRh'
    'VmVyaWZpY2F0aW9uU3RhdHVzUhJ2ZXJpZmljYXRpb25TdGF0dXMSLQoGY3Vyc29yGAMgASgLMh'
    'UuY29tbW9uLnYxLlBhZ2VDdXJzb3JSBmN1cnNvcg==');

@$core.Deprecated('Use clientDataListResponseDescriptor instead')
const ClientDataListResponse$json = {
  '1': 'ClientDataListResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.ClientDataEntryObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientDataListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataListResponseDescriptor = $convert.base64Decode(
    'ChZDbGllbnREYXRhTGlzdFJlc3BvbnNlEjYKBGRhdGEYASADKAsyIi5pZGVudGl0eS52MS5DbG'
    'llbnREYXRhRW50cnlPYmplY3RSBGRhdGE=');

@$core.Deprecated('Use clientDataVerifyRequestDescriptor instead')
const ClientDataVerifyRequest$json = {
  '1': 'ClientDataVerifyRequest',
  '2': [
    {'1': 'entry_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'entryId'},
    {'1': 'reviewer_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'reviewerId'},
    {'1': 'comment', '3': 3, '4': 1, '5': 9, '10': 'comment'},
  ],
};

/// Descriptor for `ClientDataVerifyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataVerifyRequestDescriptor = $convert.base64Decode(
    'ChdDbGllbnREYXRhVmVyaWZ5UmVxdWVzdBIkCghlbnRyeV9pZBgBIAEoCUIJukgGcgQQAxgoUg'
    'dlbnRyeUlkEioKC3Jldmlld2VyX2lkGAIgASgJQgm6SAZyBBADGChSCnJldmlld2VySWQSGAoH'
    'Y29tbWVudBgDIAEoCVIHY29tbWVudA==');

@$core.Deprecated('Use clientDataVerifyResponseDescriptor instead')
const ClientDataVerifyResponse$json = {
  '1': 'ClientDataVerifyResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.ClientDataEntryObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientDataVerifyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataVerifyResponseDescriptor = $convert.base64Decode(
    'ChhDbGllbnREYXRhVmVyaWZ5UmVzcG9uc2USNgoEZGF0YRgBIAEoCzIiLmlkZW50aXR5LnYxLk'
    'NsaWVudERhdGFFbnRyeU9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use clientDataRejectRequestDescriptor instead')
const ClientDataRejectRequest$json = {
  '1': 'ClientDataRejectRequest',
  '2': [
    {'1': 'entry_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'entryId'},
    {'1': 'reviewer_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'reviewerId'},
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'reason'},
  ],
};

/// Descriptor for `ClientDataRejectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataRejectRequestDescriptor = $convert.base64Decode(
    'ChdDbGllbnREYXRhUmVqZWN0UmVxdWVzdBIkCghlbnRyeV9pZBgBIAEoCUIJukgGcgQQAxgoUg'
    'dlbnRyeUlkEioKC3Jldmlld2VyX2lkGAIgASgJQgm6SAZyBBADGChSCnJldmlld2VySWQSHwoG'
    'cmVhc29uGAMgASgJQge6SARyAhABUgZyZWFzb24=');

@$core.Deprecated('Use clientDataRejectResponseDescriptor instead')
const ClientDataRejectResponse$json = {
  '1': 'ClientDataRejectResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.ClientDataEntryObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientDataRejectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataRejectResponseDescriptor = $convert.base64Decode(
    'ChhDbGllbnREYXRhUmVqZWN0UmVzcG9uc2USNgoEZGF0YRgBIAEoCzIiLmlkZW50aXR5LnYxLk'
    'NsaWVudERhdGFFbnRyeU9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use clientDataRequestInfoRequestDescriptor instead')
const ClientDataRequestInfoRequest$json = {
  '1': 'ClientDataRequestInfoRequest',
  '2': [
    {'1': 'entry_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'entryId'},
    {'1': 'reviewer_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'reviewerId'},
    {'1': 'comment', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'comment'},
  ],
};

/// Descriptor for `ClientDataRequestInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataRequestInfoRequestDescriptor = $convert.base64Decode(
    'ChxDbGllbnREYXRhUmVxdWVzdEluZm9SZXF1ZXN0EiQKCGVudHJ5X2lkGAEgASgJQgm6SAZyBB'
    'ADGChSB2VudHJ5SWQSKgoLcmV2aWV3ZXJfaWQYAiABKAlCCbpIBnIEEAMYKFIKcmV2aWV3ZXJJ'
    'ZBIhCgdjb21tZW50GAMgASgJQge6SARyAhABUgdjb21tZW50');

@$core.Deprecated('Use clientDataRequestInfoResponseDescriptor instead')
const ClientDataRequestInfoResponse$json = {
  '1': 'ClientDataRequestInfoResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.ClientDataEntryObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientDataRequestInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataRequestInfoResponseDescriptor = $convert.base64Decode(
    'Ch1DbGllbnREYXRhUmVxdWVzdEluZm9SZXNwb25zZRI2CgRkYXRhGAEgASgLMiIuaWRlbnRpdH'
    'kudjEuQ2xpZW50RGF0YUVudHJ5T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use clientDataHistoryRequestDescriptor instead')
const ClientDataHistoryRequest$json = {
  '1': 'ClientDataHistoryRequest',
  '2': [
    {'1': 'entry_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'entryId'},
  ],
};

/// Descriptor for `ClientDataHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataHistoryRequestDescriptor = $convert.base64Decode(
    'ChhDbGllbnREYXRhSGlzdG9yeVJlcXVlc3QSJAoIZW50cnlfaWQYASABKAlCCbpIBnIEEAMYKF'
    'IHZW50cnlJZA==');

@$core.Deprecated('Use clientDataHistoryResponseDescriptor instead')
const ClientDataHistoryResponse$json = {
  '1': 'ClientDataHistoryResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.ClientDataEntryHistoryObject', '10': 'data'},
  ],
};

/// Descriptor for `ClientDataHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientDataHistoryResponseDescriptor = $convert.base64Decode(
    'ChlDbGllbnREYXRhSGlzdG9yeVJlc3BvbnNlEj0KBGRhdGEYASADKAsyKS5pZGVudGl0eS52MS'
    '5DbGllbnREYXRhRW50cnlIaXN0b3J5T2JqZWN0UgRkYXRh');

@$core.Deprecated('Use formTemplateSaveRequestDescriptor instead')
const FormTemplateSaveRequest$json = {
  '1': 'FormTemplateSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.FormTemplateObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `FormTemplateSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formTemplateSaveRequestDescriptor = $convert.base64Decode(
    'ChdGb3JtVGVtcGxhdGVTYXZlUmVxdWVzdBI7CgRkYXRhGAEgASgLMh8uaWRlbnRpdHkudjEuRm'
    '9ybVRlbXBsYXRlT2JqZWN0Qga6SAPIAQFSBGRhdGE=');

@$core.Deprecated('Use formTemplateSaveResponseDescriptor instead')
const FormTemplateSaveResponse$json = {
  '1': 'FormTemplateSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.FormTemplateObject', '10': 'data'},
  ],
};

/// Descriptor for `FormTemplateSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formTemplateSaveResponseDescriptor = $convert.base64Decode(
    'ChhGb3JtVGVtcGxhdGVTYXZlUmVzcG9uc2USMwoEZGF0YRgBIAEoCzIfLmlkZW50aXR5LnYxLk'
    'Zvcm1UZW1wbGF0ZU9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use formTemplateGetRequestDescriptor instead')
const FormTemplateGetRequest$json = {
  '1': 'FormTemplateGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `FormTemplateGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formTemplateGetRequestDescriptor = $convert.base64Decode(
    'ChZGb3JtVGVtcGxhdGVHZXRSZXF1ZXN0EisKAmlkGAEgASgJQhu6SBhyFhADGCgyEFswLTlhLX'
    'pfLV17Myw0MH1SAmlk');

@$core.Deprecated('Use formTemplateGetResponseDescriptor instead')
const FormTemplateGetResponse$json = {
  '1': 'FormTemplateGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.FormTemplateObject', '10': 'data'},
  ],
};

/// Descriptor for `FormTemplateGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formTemplateGetResponseDescriptor = $convert.base64Decode(
    'ChdGb3JtVGVtcGxhdGVHZXRSZXNwb25zZRIzCgRkYXRhGAEgASgLMh8uaWRlbnRpdHkudjEuRm'
    '9ybVRlbXBsYXRlT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use formTemplateSearchRequestDescriptor instead')
const FormTemplateSearchRequest$json = {
  '1': 'FormTemplateSearchRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'organization_id', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'organizationId'},
    {'1': 'status', '3': 3, '4': 1, '5': 14, '6': '.identity.v1.FormTemplateStatus', '10': 'status'},
    {'1': 'cursor', '3': 4, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
    {'1': 'entity_type', '3': 5, '4': 1, '5': 9, '10': 'entityType'},
  ],
};

/// Descriptor for `FormTemplateSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formTemplateSearchRequestDescriptor = $convert.base64Decode(
    'ChlGb3JtVGVtcGxhdGVTZWFyY2hSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeRI1Cg9vcm'
    'dhbml6YXRpb25faWQYAiABKAlCDLpICdgBAXIEEAMYKFIOb3JnYW5pemF0aW9uSWQSNwoGc3Rh'
    'dHVzGAMgASgOMh8uaWRlbnRpdHkudjEuRm9ybVRlbXBsYXRlU3RhdHVzUgZzdGF0dXMSLQoGY3'
    'Vyc29yGAQgASgLMhUuY29tbW9uLnYxLlBhZ2VDdXJzb3JSBmN1cnNvchIfCgtlbnRpdHlfdHlw'
    'ZRgFIAEoCVIKZW50aXR5VHlwZQ==');

@$core.Deprecated('Use formTemplateSearchResponseDescriptor instead')
const FormTemplateSearchResponse$json = {
  '1': 'FormTemplateSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.FormTemplateObject', '10': 'data'},
  ],
};

/// Descriptor for `FormTemplateSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formTemplateSearchResponseDescriptor = $convert.base64Decode(
    'ChpGb3JtVGVtcGxhdGVTZWFyY2hSZXNwb25zZRIzCgRkYXRhGAEgAygLMh8uaWRlbnRpdHkudj'
    'EuRm9ybVRlbXBsYXRlT2JqZWN0UgRkYXRh');

@$core.Deprecated('Use formTemplatePublishRequestDescriptor instead')
const FormTemplatePublishRequest$json = {
  '1': 'FormTemplatePublishRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `FormTemplatePublishRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formTemplatePublishRequestDescriptor = $convert.base64Decode(
    'ChpGb3JtVGVtcGxhdGVQdWJsaXNoUmVxdWVzdBIrCgJpZBgBIAEoCUIbukgYchYQAxgoMhBbMC'
    '05YS16Xy1dezMsNDB9UgJpZA==');

@$core.Deprecated('Use formTemplatePublishResponseDescriptor instead')
const FormTemplatePublishResponse$json = {
  '1': 'FormTemplatePublishResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.FormTemplateObject', '10': 'data'},
  ],
};

/// Descriptor for `FormTemplatePublishResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formTemplatePublishResponseDescriptor = $convert.base64Decode(
    'ChtGb3JtVGVtcGxhdGVQdWJsaXNoUmVzcG9uc2USMwoEZGF0YRgBIAEoCzIfLmlkZW50aXR5Ln'
    'YxLkZvcm1UZW1wbGF0ZU9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use formSubmissionSaveRequestDescriptor instead')
const FormSubmissionSaveRequest$json = {
  '1': 'FormSubmissionSaveRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.FormSubmissionObject', '8': {}, '10': 'data'},
  ],
};

/// Descriptor for `FormSubmissionSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formSubmissionSaveRequestDescriptor = $convert.base64Decode(
    'ChlGb3JtU3VibWlzc2lvblNhdmVSZXF1ZXN0Ej0KBGRhdGEYASABKAsyIS5pZGVudGl0eS52MS'
    '5Gb3JtU3VibWlzc2lvbk9iamVjdEIGukgDyAEBUgRkYXRh');

@$core.Deprecated('Use formSubmissionSaveResponseDescriptor instead')
const FormSubmissionSaveResponse$json = {
  '1': 'FormSubmissionSaveResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.FormSubmissionObject', '10': 'data'},
  ],
};

/// Descriptor for `FormSubmissionSaveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formSubmissionSaveResponseDescriptor = $convert.base64Decode(
    'ChpGb3JtU3VibWlzc2lvblNhdmVSZXNwb25zZRI1CgRkYXRhGAEgASgLMiEuaWRlbnRpdHkudj'
    'EuRm9ybVN1Ym1pc3Npb25PYmplY3RSBGRhdGE=');

@$core.Deprecated('Use formSubmissionGetRequestDescriptor instead')
const FormSubmissionGetRequest$json = {
  '1': 'FormSubmissionGetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `FormSubmissionGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formSubmissionGetRequestDescriptor = $convert.base64Decode(
    'ChhGb3JtU3VibWlzc2lvbkdldFJlcXVlc3QSKwoCaWQYASABKAlCG7pIGHIWEAMYKDIQWzAtOW'
    'Etel8tXXszLDQwfVICaWQ=');

@$core.Deprecated('Use formSubmissionGetResponseDescriptor instead')
const FormSubmissionGetResponse$json = {
  '1': 'FormSubmissionGetResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.identity.v1.FormSubmissionObject', '10': 'data'},
  ],
};

/// Descriptor for `FormSubmissionGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formSubmissionGetResponseDescriptor = $convert.base64Decode(
    'ChlGb3JtU3VibWlzc2lvbkdldFJlc3BvbnNlEjUKBGRhdGEYASABKAsyIS5pZGVudGl0eS52MS'
    '5Gb3JtU3VibWlzc2lvbk9iamVjdFIEZGF0YQ==');

@$core.Deprecated('Use formSubmissionSearchRequestDescriptor instead')
const FormSubmissionSearchRequest$json = {
  '1': 'FormSubmissionSearchRequest',
  '2': [
    {'1': 'entity_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'entityId'},
    {'1': 'entity_type', '3': 2, '4': 1, '5': 9, '10': 'entityType'},
    {'1': 'template_id', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'templateId'},
    {'1': 'cursor', '3': 4, '4': 1, '5': 11, '6': '.common.v1.PageCursor', '10': 'cursor'},
  ],
};

/// Descriptor for `FormSubmissionSearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formSubmissionSearchRequestDescriptor = $convert.base64Decode(
    'ChtGb3JtU3VibWlzc2lvblNlYXJjaFJlcXVlc3QSJwoJZW50aXR5X2lkGAEgASgJQgq6SAfYAQ'
    'FyAhgoUghlbnRpdHlJZBIfCgtlbnRpdHlfdHlwZRgCIAEoCVIKZW50aXR5VHlwZRIrCgt0ZW1w'
    'bGF0ZV9pZBgDIAEoCUIKukgH2AEBcgIYKFIKdGVtcGxhdGVJZBItCgZjdXJzb3IYBCABKAsyFS'
    '5jb21tb24udjEuUGFnZUN1cnNvclIGY3Vyc29y');

@$core.Deprecated('Use formSubmissionSearchResponseDescriptor instead')
const FormSubmissionSearchResponse$json = {
  '1': 'FormSubmissionSearchResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 3, '5': 11, '6': '.identity.v1.FormSubmissionObject', '10': 'data'},
  ],
};

/// Descriptor for `FormSubmissionSearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formSubmissionSearchResponseDescriptor = $convert.base64Decode(
    'ChxGb3JtU3VibWlzc2lvblNlYXJjaFJlc3BvbnNlEjUKBGRhdGEYASADKAsyIS5pZGVudGl0eS'
    '52MS5Gb3JtU3VibWlzc2lvbk9iamVjdFIEZGF0YQ==');

const $core.Map<$core.String, $core.dynamic> IdentityServiceBase$json = {
  '1': 'IdentityService',
  '2': [
    {'1': 'OrganizationSave', '2': '.identity.v1.OrganizationSaveRequest', '3': '.identity.v1.OrganizationSaveResponse', '4': {}},
    {
      '1': 'OrganizationGet',
      '2': '.identity.v1.OrganizationGetRequest',
      '3': '.identity.v1.OrganizationGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'OrganizationSearch',
      '2': '.common.v1.SearchRequest',
      '3': '.identity.v1.OrganizationSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'OrgUnitSave', '2': '.identity.v1.OrgUnitSaveRequest', '3': '.identity.v1.OrgUnitSaveResponse', '4': {}},
    {
      '1': 'OrgUnitGet',
      '2': '.identity.v1.OrgUnitGetRequest',
      '3': '.identity.v1.OrgUnitGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'OrgUnitSearch',
      '2': '.identity.v1.OrgUnitSearchRequest',
      '3': '.identity.v1.OrgUnitSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'WorkforceMemberSave', '2': '.identity.v1.WorkforceMemberSaveRequest', '3': '.identity.v1.WorkforceMemberSaveResponse', '4': {}},
    {
      '1': 'WorkforceMemberGet',
      '2': '.identity.v1.WorkforceMemberGetRequest',
      '3': '.identity.v1.WorkforceMemberGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'WorkforceMemberSearch',
      '2': '.identity.v1.WorkforceMemberSearchRequest',
      '3': '.identity.v1.WorkforceMemberSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'DepartmentSave', '2': '.identity.v1.DepartmentSaveRequest', '3': '.identity.v1.DepartmentSaveResponse', '4': {}},
    {
      '1': 'DepartmentGet',
      '2': '.identity.v1.DepartmentGetRequest',
      '3': '.identity.v1.DepartmentGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'DepartmentSearch',
      '2': '.identity.v1.DepartmentSearchRequest',
      '3': '.identity.v1.DepartmentSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'PositionSave', '2': '.identity.v1.PositionSaveRequest', '3': '.identity.v1.PositionSaveResponse', '4': {}},
    {
      '1': 'PositionGet',
      '2': '.identity.v1.PositionGetRequest',
      '3': '.identity.v1.PositionGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'PositionSearch',
      '2': '.identity.v1.PositionSearchRequest',
      '3': '.identity.v1.PositionSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'PositionAssignmentSave', '2': '.identity.v1.PositionAssignmentSaveRequest', '3': '.identity.v1.PositionAssignmentSaveResponse', '4': {}},
    {
      '1': 'PositionAssignmentGet',
      '2': '.identity.v1.PositionAssignmentGetRequest',
      '3': '.identity.v1.PositionAssignmentGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'PositionAssignmentSearch',
      '2': '.identity.v1.PositionAssignmentSearchRequest',
      '3': '.identity.v1.PositionAssignmentSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'InternalTeamSave', '2': '.identity.v1.InternalTeamSaveRequest', '3': '.identity.v1.InternalTeamSaveResponse', '4': {}},
    {
      '1': 'InternalTeamGet',
      '2': '.identity.v1.InternalTeamGetRequest',
      '3': '.identity.v1.InternalTeamGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'InternalTeamSearch',
      '2': '.identity.v1.InternalTeamSearchRequest',
      '3': '.identity.v1.InternalTeamSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'TeamMembershipSave', '2': '.identity.v1.TeamMembershipSaveRequest', '3': '.identity.v1.TeamMembershipSaveResponse', '4': {}},
    {
      '1': 'TeamMembershipGet',
      '2': '.identity.v1.TeamMembershipGetRequest',
      '3': '.identity.v1.TeamMembershipGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'TeamMembershipSearch',
      '2': '.identity.v1.TeamMembershipSearchRequest',
      '3': '.identity.v1.TeamMembershipSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'AccessRoleAssignmentSave', '2': '.identity.v1.AccessRoleAssignmentSaveRequest', '3': '.identity.v1.AccessRoleAssignmentSaveResponse', '4': {}},
    {
      '1': 'AccessRoleAssignmentGet',
      '2': '.identity.v1.AccessRoleAssignmentGetRequest',
      '3': '.identity.v1.AccessRoleAssignmentGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'AccessRoleAssignmentSearch',
      '2': '.identity.v1.AccessRoleAssignmentSearchRequest',
      '3': '.identity.v1.AccessRoleAssignmentSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'InvestorSave', '2': '.identity.v1.InvestorSaveRequest', '3': '.identity.v1.InvestorSaveResponse', '4': {}},
    {
      '1': 'InvestorGet',
      '2': '.identity.v1.InvestorGetRequest',
      '3': '.identity.v1.InvestorGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'InvestorSearch',
      '2': '.identity.v1.InvestorSearchRequest',
      '3': '.identity.v1.InvestorSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'ClientGroupSave', '2': '.identity.v1.ClientGroupSaveRequest', '3': '.identity.v1.ClientGroupSaveResponse', '4': {}},
    {
      '1': 'ClientGroupGet',
      '2': '.identity.v1.ClientGroupGetRequest',
      '3': '.identity.v1.ClientGroupGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'ClientGroupSearch',
      '2': '.identity.v1.ClientGroupSearchRequest',
      '3': '.identity.v1.ClientGroupSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'MembershipSave', '2': '.identity.v1.MembershipSaveRequest', '3': '.identity.v1.MembershipSaveResponse', '4': {}},
    {
      '1': 'MembershipGet',
      '2': '.identity.v1.MembershipGetRequest',
      '3': '.identity.v1.MembershipGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'MembershipSearch',
      '2': '.identity.v1.MembershipSearchRequest',
      '3': '.identity.v1.MembershipSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'InvestorAccountSave', '2': '.identity.v1.InvestorAccountSaveRequest', '3': '.identity.v1.InvestorAccountSaveResponse', '4': {}},
    {
      '1': 'InvestorAccountGet',
      '2': '.identity.v1.InvestorAccountGetRequest',
      '3': '.identity.v1.InvestorAccountGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'InvestorAccountSearch',
      '2': '.identity.v1.InvestorAccountSearchRequest',
      '3': '.identity.v1.InvestorAccountSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'InvestorDeposit', '2': '.identity.v1.InvestorDepositRequest', '3': '.identity.v1.InvestorDepositResponse', '4': {}},
    {'1': 'InvestorWithdraw', '2': '.identity.v1.InvestorWithdrawRequest', '3': '.identity.v1.InvestorWithdrawResponse', '4': {}},
    {'1': 'ClientDataSave', '2': '.identity.v1.ClientDataSaveRequest', '3': '.identity.v1.ClientDataSaveResponse', '4': {}},
    {
      '1': 'ClientDataGet',
      '2': '.identity.v1.ClientDataGetRequest',
      '3': '.identity.v1.ClientDataGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'ClientDataList',
      '2': '.identity.v1.ClientDataListRequest',
      '3': '.identity.v1.ClientDataListResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'ClientDataVerify', '2': '.identity.v1.ClientDataVerifyRequest', '3': '.identity.v1.ClientDataVerifyResponse', '4': {}},
    {'1': 'ClientDataReject', '2': '.identity.v1.ClientDataRejectRequest', '3': '.identity.v1.ClientDataRejectResponse', '4': {}},
    {'1': 'ClientDataRequestInfo', '2': '.identity.v1.ClientDataRequestInfoRequest', '3': '.identity.v1.ClientDataRequestInfoResponse', '4': {}},
    {
      '1': 'ClientDataHistory',
      '2': '.identity.v1.ClientDataHistoryRequest',
      '3': '.identity.v1.ClientDataHistoryResponse',
      '4': {'34': 1},
    },
    {'1': 'FormTemplateSave', '2': '.identity.v1.FormTemplateSaveRequest', '3': '.identity.v1.FormTemplateSaveResponse', '4': {}},
    {
      '1': 'FormTemplateGet',
      '2': '.identity.v1.FormTemplateGetRequest',
      '3': '.identity.v1.FormTemplateGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'FormTemplateSearch',
      '2': '.identity.v1.FormTemplateSearchRequest',
      '3': '.identity.v1.FormTemplateSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
    {'1': 'FormTemplatePublish', '2': '.identity.v1.FormTemplatePublishRequest', '3': '.identity.v1.FormTemplatePublishResponse', '4': {}},
    {'1': 'FormSubmissionSave', '2': '.identity.v1.FormSubmissionSaveRequest', '3': '.identity.v1.FormSubmissionSaveResponse', '4': {}},
    {
      '1': 'FormSubmissionGet',
      '2': '.identity.v1.FormSubmissionGetRequest',
      '3': '.identity.v1.FormSubmissionGetResponse',
      '4': {'34': 1},
    },
    {
      '1': 'FormSubmissionSearch',
      '2': '.identity.v1.FormSubmissionSearchRequest',
      '3': '.identity.v1.FormSubmissionSearchResponse',
      '4': {'34': 1},
      '6': true,
    },
  ],
  '3': {},
};

@$core.Deprecated('Use identityServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> IdentityServiceBase$messageJson = {
  '.identity.v1.OrganizationSaveRequest': OrganizationSaveRequest$json,
  '.identity.v1.OrganizationObject': OrganizationObject$json,
  '.google.protobuf.Struct': $6.Struct$json,
  '.google.protobuf.Struct.FieldsEntry': $6.Struct_FieldsEntry$json,
  '.google.protobuf.Value': $6.Value$json,
  '.google.protobuf.ListValue': $6.ListValue$json,
  '.identity.v1.OrganizationSaveResponse': OrganizationSaveResponse$json,
  '.identity.v1.OrganizationGetRequest': OrganizationGetRequest$json,
  '.identity.v1.OrganizationGetResponse': OrganizationGetResponse$json,
  '.common.v1.SearchRequest': $7.SearchRequest$json,
  '.common.v1.PageCursor': $7.PageCursor$json,
  '.identity.v1.OrganizationSearchResponse': OrganizationSearchResponse$json,
  '.identity.v1.OrgUnitSaveRequest': OrgUnitSaveRequest$json,
  '.identity.v1.OrgUnitObject': OrgUnitObject$json,
  '.identity.v1.OrgUnitSaveResponse': OrgUnitSaveResponse$json,
  '.identity.v1.OrgUnitGetRequest': OrgUnitGetRequest$json,
  '.identity.v1.OrgUnitGetResponse': OrgUnitGetResponse$json,
  '.identity.v1.OrgUnitSearchRequest': OrgUnitSearchRequest$json,
  '.identity.v1.OrgUnitSearchResponse': OrgUnitSearchResponse$json,
  '.identity.v1.WorkforceMemberSaveRequest': WorkforceMemberSaveRequest$json,
  '.identity.v1.WorkforceMemberObject': WorkforceMemberObject$json,
  '.identity.v1.WorkforceMemberSaveResponse': WorkforceMemberSaveResponse$json,
  '.identity.v1.WorkforceMemberGetRequest': WorkforceMemberGetRequest$json,
  '.identity.v1.WorkforceMemberGetResponse': WorkforceMemberGetResponse$json,
  '.identity.v1.WorkforceMemberSearchRequest': WorkforceMemberSearchRequest$json,
  '.identity.v1.WorkforceMemberSearchResponse': WorkforceMemberSearchResponse$json,
  '.identity.v1.DepartmentSaveRequest': DepartmentSaveRequest$json,
  '.identity.v1.DepartmentObject': DepartmentObject$json,
  '.identity.v1.DepartmentSaveResponse': DepartmentSaveResponse$json,
  '.identity.v1.DepartmentGetRequest': DepartmentGetRequest$json,
  '.identity.v1.DepartmentGetResponse': DepartmentGetResponse$json,
  '.identity.v1.DepartmentSearchRequest': DepartmentSearchRequest$json,
  '.identity.v1.DepartmentSearchResponse': DepartmentSearchResponse$json,
  '.identity.v1.PositionSaveRequest': PositionSaveRequest$json,
  '.identity.v1.PositionObject': PositionObject$json,
  '.identity.v1.PositionSaveResponse': PositionSaveResponse$json,
  '.identity.v1.PositionGetRequest': PositionGetRequest$json,
  '.identity.v1.PositionGetResponse': PositionGetResponse$json,
  '.identity.v1.PositionSearchRequest': PositionSearchRequest$json,
  '.identity.v1.PositionSearchResponse': PositionSearchResponse$json,
  '.identity.v1.PositionAssignmentSaveRequest': PositionAssignmentSaveRequest$json,
  '.identity.v1.PositionAssignmentObject': PositionAssignmentObject$json,
  '.identity.v1.PositionAssignmentSaveResponse': PositionAssignmentSaveResponse$json,
  '.identity.v1.PositionAssignmentGetRequest': PositionAssignmentGetRequest$json,
  '.identity.v1.PositionAssignmentGetResponse': PositionAssignmentGetResponse$json,
  '.identity.v1.PositionAssignmentSearchRequest': PositionAssignmentSearchRequest$json,
  '.identity.v1.PositionAssignmentSearchResponse': PositionAssignmentSearchResponse$json,
  '.identity.v1.InternalTeamSaveRequest': InternalTeamSaveRequest$json,
  '.identity.v1.InternalTeamObject': InternalTeamObject$json,
  '.identity.v1.InternalTeamSaveResponse': InternalTeamSaveResponse$json,
  '.identity.v1.InternalTeamGetRequest': InternalTeamGetRequest$json,
  '.identity.v1.InternalTeamGetResponse': InternalTeamGetResponse$json,
  '.identity.v1.InternalTeamSearchRequest': InternalTeamSearchRequest$json,
  '.identity.v1.InternalTeamSearchResponse': InternalTeamSearchResponse$json,
  '.identity.v1.TeamMembershipSaveRequest': TeamMembershipSaveRequest$json,
  '.identity.v1.TeamMembershipObject': TeamMembershipObject$json,
  '.identity.v1.TeamMembershipSaveResponse': TeamMembershipSaveResponse$json,
  '.identity.v1.TeamMembershipGetRequest': TeamMembershipGetRequest$json,
  '.identity.v1.TeamMembershipGetResponse': TeamMembershipGetResponse$json,
  '.identity.v1.TeamMembershipSearchRequest': TeamMembershipSearchRequest$json,
  '.identity.v1.TeamMembershipSearchResponse': TeamMembershipSearchResponse$json,
  '.identity.v1.AccessRoleAssignmentSaveRequest': AccessRoleAssignmentSaveRequest$json,
  '.identity.v1.AccessRoleAssignmentObject': AccessRoleAssignmentObject$json,
  '.identity.v1.AccessRoleAssignmentSaveResponse': AccessRoleAssignmentSaveResponse$json,
  '.identity.v1.AccessRoleAssignmentGetRequest': AccessRoleAssignmentGetRequest$json,
  '.identity.v1.AccessRoleAssignmentGetResponse': AccessRoleAssignmentGetResponse$json,
  '.identity.v1.AccessRoleAssignmentSearchRequest': AccessRoleAssignmentSearchRequest$json,
  '.identity.v1.AccessRoleAssignmentSearchResponse': AccessRoleAssignmentSearchResponse$json,
  '.identity.v1.InvestorSaveRequest': InvestorSaveRequest$json,
  '.identity.v1.InvestorObject': InvestorObject$json,
  '.identity.v1.InvestorSaveResponse': InvestorSaveResponse$json,
  '.identity.v1.InvestorGetRequest': InvestorGetRequest$json,
  '.identity.v1.InvestorGetResponse': InvestorGetResponse$json,
  '.identity.v1.InvestorSearchRequest': InvestorSearchRequest$json,
  '.identity.v1.InvestorSearchResponse': InvestorSearchResponse$json,
  '.identity.v1.ClientGroupSaveRequest': ClientGroupSaveRequest$json,
  '.identity.v1.ClientGroupObject': ClientGroupObject$json,
  '.identity.v1.ClientGroupSaveResponse': ClientGroupSaveResponse$json,
  '.identity.v1.ClientGroupGetRequest': ClientGroupGetRequest$json,
  '.identity.v1.ClientGroupGetResponse': ClientGroupGetResponse$json,
  '.identity.v1.ClientGroupSearchRequest': ClientGroupSearchRequest$json,
  '.identity.v1.ClientGroupSearchResponse': ClientGroupSearchResponse$json,
  '.identity.v1.MembershipSaveRequest': MembershipSaveRequest$json,
  '.identity.v1.MembershipObject': MembershipObject$json,
  '.identity.v1.MembershipSaveResponse': MembershipSaveResponse$json,
  '.identity.v1.MembershipGetRequest': MembershipGetRequest$json,
  '.identity.v1.MembershipGetResponse': MembershipGetResponse$json,
  '.identity.v1.MembershipSearchRequest': MembershipSearchRequest$json,
  '.identity.v1.MembershipSearchResponse': MembershipSearchResponse$json,
  '.identity.v1.InvestorAccountSaveRequest': InvestorAccountSaveRequest$json,
  '.identity.v1.InvestorAccountObject': InvestorAccountObject$json,
  '.common.v1.Money': $8.Money$json,
  '.identity.v1.InvestorAccountSaveResponse': InvestorAccountSaveResponse$json,
  '.identity.v1.InvestorAccountGetRequest': InvestorAccountGetRequest$json,
  '.identity.v1.InvestorAccountGetResponse': InvestorAccountGetResponse$json,
  '.identity.v1.InvestorAccountSearchRequest': InvestorAccountSearchRequest$json,
  '.identity.v1.InvestorAccountSearchResponse': InvestorAccountSearchResponse$json,
  '.identity.v1.InvestorDepositRequest': InvestorDepositRequest$json,
  '.identity.v1.InvestorDepositResponse': InvestorDepositResponse$json,
  '.identity.v1.InvestorWithdrawRequest': InvestorWithdrawRequest$json,
  '.identity.v1.InvestorWithdrawResponse': InvestorWithdrawResponse$json,
  '.identity.v1.ClientDataSaveRequest': ClientDataSaveRequest$json,
  '.identity.v1.ClientDataEntryObject': ClientDataEntryObject$json,
  '.identity.v1.ClientDataSaveResponse': ClientDataSaveResponse$json,
  '.identity.v1.ClientDataGetRequest': ClientDataGetRequest$json,
  '.identity.v1.ClientDataGetResponse': ClientDataGetResponse$json,
  '.identity.v1.ClientDataListRequest': ClientDataListRequest$json,
  '.identity.v1.ClientDataListResponse': ClientDataListResponse$json,
  '.identity.v1.ClientDataVerifyRequest': ClientDataVerifyRequest$json,
  '.identity.v1.ClientDataVerifyResponse': ClientDataVerifyResponse$json,
  '.identity.v1.ClientDataRejectRequest': ClientDataRejectRequest$json,
  '.identity.v1.ClientDataRejectResponse': ClientDataRejectResponse$json,
  '.identity.v1.ClientDataRequestInfoRequest': ClientDataRequestInfoRequest$json,
  '.identity.v1.ClientDataRequestInfoResponse': ClientDataRequestInfoResponse$json,
  '.identity.v1.ClientDataHistoryRequest': ClientDataHistoryRequest$json,
  '.identity.v1.ClientDataHistoryResponse': ClientDataHistoryResponse$json,
  '.identity.v1.ClientDataEntryHistoryObject': ClientDataEntryHistoryObject$json,
  '.identity.v1.FormTemplateSaveRequest': FormTemplateSaveRequest$json,
  '.identity.v1.FormTemplateObject': FormTemplateObject$json,
  '.identity.v1.FormFieldDefinition': FormFieldDefinition$json,
  '.identity.v1.FormTemplateSaveResponse': FormTemplateSaveResponse$json,
  '.identity.v1.FormTemplateGetRequest': FormTemplateGetRequest$json,
  '.identity.v1.FormTemplateGetResponse': FormTemplateGetResponse$json,
  '.identity.v1.FormTemplateSearchRequest': FormTemplateSearchRequest$json,
  '.identity.v1.FormTemplateSearchResponse': FormTemplateSearchResponse$json,
  '.identity.v1.FormTemplatePublishRequest': FormTemplatePublishRequest$json,
  '.identity.v1.FormTemplatePublishResponse': FormTemplatePublishResponse$json,
  '.identity.v1.FormSubmissionSaveRequest': FormSubmissionSaveRequest$json,
  '.identity.v1.FormSubmissionObject': FormSubmissionObject$json,
  '.identity.v1.FormSubmissionSaveResponse': FormSubmissionSaveResponse$json,
  '.identity.v1.FormSubmissionGetRequest': FormSubmissionGetRequest$json,
  '.identity.v1.FormSubmissionGetResponse': FormSubmissionGetResponse$json,
  '.identity.v1.FormSubmissionSearchRequest': FormSubmissionSearchRequest$json,
  '.identity.v1.FormSubmissionSearchResponse': FormSubmissionSearchResponse$json,
};

/// Descriptor for `IdentityService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List identityServiceDescriptor = $convert.base64Decode(
    'Cg9JZGVudGl0eVNlcnZpY2USvwIKEE9yZ2FuaXphdGlvblNhdmUSJC5pZGVudGl0eS52MS5Pcm'
    'dhbml6YXRpb25TYXZlUmVxdWVzdBolLmlkZW50aXR5LnYxLk9yZ2FuaXphdGlvblNhdmVSZXNw'
    'b25zZSLdAbpHwAEKDU9yZ2FuaXphdGlvbnMSIENyZWF0ZSBvciB1cGRhdGUgYW4gb3JnYW5pem'
    'F0aW9uGntDcmVhdGVzIGEgbmV3IG9yZ2FuaXphdGlvbiBvciB1cGRhdGVzIGFuIGV4aXN0aW5n'
    'IG9uZS4gT3JnYW5pemF0aW9ucyByZXByZXNlbnQgdG9wLWxldmVsIGluc3RpdHV0aW9ucyBtYX'
    'BwZWQgdG8gcGFydGl0aW9ucy4qEG9yZ2FuaXphdGlvblNhdmWCtRgVChNvcmdhbml6YXRpb25f'
    'bWFuYWdlEvMBCg9Pcmdhbml6YXRpb25HZXQSIy5pZGVudGl0eS52MS5Pcmdhbml6YXRpb25HZX'
    'RSZXF1ZXN0GiQuaWRlbnRpdHkudjEuT3JnYW5pemF0aW9uR2V0UmVzcG9uc2UilAGQAgG6R3cK'
    'DU9yZ2FuaXphdGlvbnMSGUdldCBhbiBvcmdhbml6YXRpb24gYnkgSUQaOlJldHJpZXZlcyBhbi'
    'Bvcmdhbml6YXRpb24gcmVjb3JkIGJ5IGl0cyB1bmlxdWUgaWRlbnRpZmllci4qD29yZ2FuaXph'
    'dGlvbkdldIK1GBMKEW9yZ2FuaXphdGlvbl92aWV3Ep8CChJPcmdhbml6YXRpb25TZWFyY2gSGC'
    '5jb21tb24udjEuU2VhcmNoUmVxdWVzdBonLmlkZW50aXR5LnYxLk9yZ2FuaXphdGlvblNlYXJj'
    'aFJlc3BvbnNlIsMBkAIBukelAQoNT3JnYW5pemF0aW9ucxIUU2VhcmNoIG9yZ2FuaXphdGlvbn'
    'MaalNlYXJjaGVzIGZvciBvcmdhbml6YXRpb25zIG1hdGNoaW5nIHNwZWNpZmllZCBjcml0ZXJp'
    'YS4gUmV0dXJucyBhIHN0cmVhbSBvZiBtYXRjaGluZyBvcmdhbml6YXRpb24gcmVjb3Jkcy4qEm'
    '9yZ2FuaXphdGlvblNlYXJjaIK1GBMKEW9yZ2FuaXphdGlvbl92aWV3MAESlQIKC09yZ1VuaXRT'
    'YXZlEh8uaWRlbnRpdHkudjEuT3JnVW5pdFNhdmVSZXF1ZXN0GiAuaWRlbnRpdHkudjEuT3JnVW'
    '5pdFNhdmVSZXNwb25zZSLCAbpHqwEKCU9yZyBVbml0cxIcQ3JlYXRlIG9yIHVwZGF0ZSBhbiBv'
    'cmcgdW5pdBpzQ3JlYXRlcyBhIG5ldyBvcmcgdW5pdCBvciB1cGRhdGVzIGFuIGV4aXN0aW5nIG'
    '9uZS4gT3JnIHVuaXRzIGFyZSB0eXBlZCBoaWVyYXJjaGljYWwgc3ViLWRpdmlzaW9ucyBvZiBv'
    'cmdhbml6YXRpb25zLioLb3JnVW5pdFNhdmWCtRgPCg1icmFuY2hfbWFuYWdlEswBCgpPcmdVbm'
    'l0R2V0Eh4uaWRlbnRpdHkudjEuT3JnVW5pdEdldFJlcXVlc3QaHy5pZGVudGl0eS52MS5PcmdV'
    'bml0R2V0UmVzcG9uc2UifZACAbpHZgoJT3JnIFVuaXRzEhVHZXQgYW4gb3JnIHVuaXQgYnkgSU'
    'QaNlJldHJpZXZlcyBhbiBvcmcgdW5pdCByZWNvcmQgYnkgaXRzIHVuaXF1ZSBpZGVudGlmaWVy'
    'LioKb3JnVW5pdEdldIK1GA0KC2JyYW5jaF92aWV3EpsCCg1PcmdVbml0U2VhcmNoEiEuaWRlbn'
    'RpdHkudjEuT3JnVW5pdFNlYXJjaFJlcXVlc3QaIi5pZGVudGl0eS52MS5PcmdVbml0U2VhcmNo'
    'UmVzcG9uc2UiwAGQAgG6R6gBCglPcmcgVW5pdHMSEFNlYXJjaCBvcmcgdW5pdHMaelNlYXJjaG'
    'VzIGZvciBvcmcgdW5pdHMgbWF0Y2hpbmcgc3BlY2lmaWVkIGNyaXRlcmlhLiBTdXBwb3J0cyBm'
    'aWx0ZXJpbmcgYnkgb3JnYW5pemF0aW9uLCBwYXJlbnQgdW5pdCwgcm9vdCB1bml0cywgYW5kIH'
    'R5cGUuKg1vcmdVbml0U2VhcmNogrUYDQoLYnJhbmNoX3ZpZXcwARKHAQoTV29ya2ZvcmNlTWVt'
    'YmVyU2F2ZRInLmlkZW50aXR5LnYxLldvcmtmb3JjZU1lbWJlclNhdmVSZXF1ZXN0GiguaWRlbn'
    'RpdHkudjEuV29ya2ZvcmNlTWVtYmVyU2F2ZVJlc3BvbnNlIh2CtRgZChd3b3JrZm9yY2VfbWVt'
    'YmVyX21hbmFnZRKFAQoSV29ya2ZvcmNlTWVtYmVyR2V0EiYuaWRlbnRpdHkudjEuV29ya2Zvcm'
    'NlTWVtYmVyR2V0UmVxdWVzdBonLmlkZW50aXR5LnYxLldvcmtmb3JjZU1lbWJlckdldFJlc3Bv'
    'bnNlIh6QAgGCtRgXChV3b3JrZm9yY2VfbWVtYmVyX3ZpZXcSkAEKFVdvcmtmb3JjZU1lbWJlcl'
    'NlYXJjaBIpLmlkZW50aXR5LnYxLldvcmtmb3JjZU1lbWJlclNlYXJjaFJlcXVlc3QaKi5pZGVu'
    'dGl0eS52MS5Xb3JrZm9yY2VNZW1iZXJTZWFyY2hSZXNwb25zZSIekAIBgrUYFwoVd29ya2Zvcm'
    'NlX21lbWJlcl92aWV3MAEScgoORGVwYXJ0bWVudFNhdmUSIi5pZGVudGl0eS52MS5EZXBhcnRt'
    'ZW50U2F2ZVJlcXVlc3QaIy5pZGVudGl0eS52MS5EZXBhcnRtZW50U2F2ZVJlc3BvbnNlIheCtR'
    'gTChFkZXBhcnRtZW50X21hbmFnZRJwCg1EZXBhcnRtZW50R2V0EiEuaWRlbnRpdHkudjEuRGVw'
    'YXJ0bWVudEdldFJlcXVlc3QaIi5pZGVudGl0eS52MS5EZXBhcnRtZW50R2V0UmVzcG9uc2UiGJ'
    'ACAYK1GBEKD2RlcGFydG1lbnRfdmlldxJ7ChBEZXBhcnRtZW50U2VhcmNoEiQuaWRlbnRpdHku'
    'djEuRGVwYXJ0bWVudFNlYXJjaFJlcXVlc3QaJS5pZGVudGl0eS52MS5EZXBhcnRtZW50U2Vhcm'
    'NoUmVzcG9uc2UiGJACAYK1GBEKD2RlcGFydG1lbnRfdmlldzABEmoKDFBvc2l0aW9uU2F2ZRIg'
    'LmlkZW50aXR5LnYxLlBvc2l0aW9uU2F2ZVJlcXVlc3QaIS5pZGVudGl0eS52MS5Qb3NpdGlvbl'
    'NhdmVSZXNwb25zZSIVgrUYEQoPcG9zaXRpb25fbWFuYWdlEmgKC1Bvc2l0aW9uR2V0Eh8uaWRl'
    'bnRpdHkudjEuUG9zaXRpb25HZXRSZXF1ZXN0GiAuaWRlbnRpdHkudjEuUG9zaXRpb25HZXRSZX'
    'Nwb25zZSIWkAIBgrUYDwoNcG9zaXRpb25fdmlldxJzCg5Qb3NpdGlvblNlYXJjaBIiLmlkZW50'
    'aXR5LnYxLlBvc2l0aW9uU2VhcmNoUmVxdWVzdBojLmlkZW50aXR5LnYxLlBvc2l0aW9uU2Vhcm'
    'NoUmVzcG9uc2UiFpACAYK1GA8KDXBvc2l0aW9uX3ZpZXcwARKTAQoWUG9zaXRpb25Bc3NpZ25t'
    'ZW50U2F2ZRIqLmlkZW50aXR5LnYxLlBvc2l0aW9uQXNzaWdubWVudFNhdmVSZXF1ZXN0GisuaW'
    'RlbnRpdHkudjEuUG9zaXRpb25Bc3NpZ25tZW50U2F2ZVJlc3BvbnNlIiCCtRgcChpwb3NpdGlv'
    'bl9hc3NpZ25tZW50X21hbmFnZRKRAQoVUG9zaXRpb25Bc3NpZ25tZW50R2V0EikuaWRlbnRpdH'
    'kudjEuUG9zaXRpb25Bc3NpZ25tZW50R2V0UmVxdWVzdBoqLmlkZW50aXR5LnYxLlBvc2l0aW9u'
    'QXNzaWdubWVudEdldFJlc3BvbnNlIiGQAgGCtRgaChhwb3NpdGlvbl9hc3NpZ25tZW50X3ZpZX'
    'cSnAEKGFBvc2l0aW9uQXNzaWdubWVudFNlYXJjaBIsLmlkZW50aXR5LnYxLlBvc2l0aW9uQXNz'
    'aWdubWVudFNlYXJjaFJlcXVlc3QaLS5pZGVudGl0eS52MS5Qb3NpdGlvbkFzc2lnbm1lbnRTZW'
    'FyY2hSZXNwb25zZSIhkAIBgrUYGgoYcG9zaXRpb25fYXNzaWdubWVudF92aWV3MAEScgoQSW50'
    'ZXJuYWxUZWFtU2F2ZRIkLmlkZW50aXR5LnYxLkludGVybmFsVGVhbVNhdmVSZXF1ZXN0GiUuaW'
    'RlbnRpdHkudjEuSW50ZXJuYWxUZWFtU2F2ZVJlc3BvbnNlIhGCtRgNCgt0ZWFtX21hbmFnZRJw'
    'Cg9JbnRlcm5hbFRlYW1HZXQSIy5pZGVudGl0eS52MS5JbnRlcm5hbFRlYW1HZXRSZXF1ZXN0Gi'
    'QuaWRlbnRpdHkudjEuSW50ZXJuYWxUZWFtR2V0UmVzcG9uc2UiEpACAYK1GAsKCXRlYW1fdmll'
    'dxJ7ChJJbnRlcm5hbFRlYW1TZWFyY2gSJi5pZGVudGl0eS52MS5JbnRlcm5hbFRlYW1TZWFyY2'
    'hSZXF1ZXN0GicuaWRlbnRpdHkudjEuSW50ZXJuYWxUZWFtU2VhcmNoUmVzcG9uc2UiEpACAYK1'
    'GAsKCXRlYW1fdmlldzABEoMBChJUZWFtTWVtYmVyc2hpcFNhdmUSJi5pZGVudGl0eS52MS5UZW'
    'FtTWVtYmVyc2hpcFNhdmVSZXF1ZXN0GicuaWRlbnRpdHkudjEuVGVhbU1lbWJlcnNoaXBTYXZl'
    'UmVzcG9uc2UiHIK1GBgKFnRlYW1fbWVtYmVyc2hpcF9tYW5hZ2USgQEKEVRlYW1NZW1iZXJzaG'
    'lwR2V0EiUuaWRlbnRpdHkudjEuVGVhbU1lbWJlcnNoaXBHZXRSZXF1ZXN0GiYuaWRlbnRpdHku'
    'djEuVGVhbU1lbWJlcnNoaXBHZXRSZXNwb25zZSIdkAIBgrUYFgoUdGVhbV9tZW1iZXJzaGlwX3'
    'ZpZXcSjAEKFFRlYW1NZW1iZXJzaGlwU2VhcmNoEiguaWRlbnRpdHkudjEuVGVhbU1lbWJlcnNo'
    'aXBTZWFyY2hSZXF1ZXN0GikuaWRlbnRpdHkudjEuVGVhbU1lbWJlcnNoaXBTZWFyY2hSZXNwb2'
    '5zZSIdkAIBgrUYFgoUdGVhbV9tZW1iZXJzaGlwX3ZpZXcwARKcAQoYQWNjZXNzUm9sZUFzc2ln'
    'bm1lbnRTYXZlEiwuaWRlbnRpdHkudjEuQWNjZXNzUm9sZUFzc2lnbm1lbnRTYXZlUmVxdWVzdB'
    'otLmlkZW50aXR5LnYxLkFjY2Vzc1JvbGVBc3NpZ25tZW50U2F2ZVJlc3BvbnNlIiOCtRgfCh1h'
    'Y2Nlc3Nfcm9sZV9hc3NpZ25tZW50X21hbmFnZRKaAQoXQWNjZXNzUm9sZUFzc2lnbm1lbnRHZX'
    'QSKy5pZGVudGl0eS52MS5BY2Nlc3NSb2xlQXNzaWdubWVudEdldFJlcXVlc3QaLC5pZGVudGl0'
    'eS52MS5BY2Nlc3NSb2xlQXNzaWdubWVudEdldFJlc3BvbnNlIiSQAgGCtRgdChthY2Nlc3Nfcm'
    '9sZV9hc3NpZ25tZW50X3ZpZXcSpQEKGkFjY2Vzc1JvbGVBc3NpZ25tZW50U2VhcmNoEi4uaWRl'
    'bnRpdHkudjEuQWNjZXNzUm9sZUFzc2lnbm1lbnRTZWFyY2hSZXF1ZXN0Gi8uaWRlbnRpdHkudj'
    'EuQWNjZXNzUm9sZUFzc2lnbm1lbnRTZWFyY2hSZXNwb25zZSIkkAIBgrUYHQobYWNjZXNzX3Jv'
    'bGVfYXNzaWdubWVudF92aWV3MAESkgIKDEludmVzdG9yU2F2ZRIgLmlkZW50aXR5LnYxLkludm'
    'VzdG9yU2F2ZVJlcXVlc3QaIS5pZGVudGl0eS52MS5JbnZlc3RvclNhdmVSZXNwb25zZSK8AbpH'
    'owEKCUludmVzdG9ycxIcQ3JlYXRlIG9yIHVwZGF0ZSBhbiBpbnZlc3RvchpqQ3JlYXRlcyBhIG'
    '5ldyBpbnZlc3RvciBvciB1cGRhdGVzIGFuIGV4aXN0aW5nIG9uZS4gSW52ZXN0b3JzIGFyZSBp'
    'bmRlcGVuZGVudCBlbnRpdGllcyBsaW5rZWQgdG8gYSBwcm9maWxlLioMaW52ZXN0b3JTYXZlgr'
    'UYEQoPaW52ZXN0b3JfbWFuYWdlEtUBCgtJbnZlc3RvckdldBIfLmlkZW50aXR5LnYxLkludmVz'
    'dG9yR2V0UmVxdWVzdBogLmlkZW50aXR5LnYxLkludmVzdG9yR2V0UmVzcG9uc2UiggGQAgG6R2'
    'kKCUludmVzdG9ycxIVR2V0IGFuIGludmVzdG9yIGJ5IElEGjhSZXRyaWV2ZXMgYW4gaW52ZXN0'
    'b3IgcmVjb3JkIGJ5IHRoZWlyIHVuaXF1ZSBpZGVudGlmaWVyLioLaW52ZXN0b3JHZXSCtRgPCg'
    '1pbnZlc3Rvcl92aWV3EokCCg5JbnZlc3RvclNlYXJjaBIiLmlkZW50aXR5LnYxLkludmVzdG9y'
    'U2VhcmNoUmVxdWVzdBojLmlkZW50aXR5LnYxLkludmVzdG9yU2VhcmNoUmVzcG9uc2UiqwGQAg'
    'G6R5EBCglJbnZlc3RvcnMSEFNlYXJjaCBpbnZlc3RvcnMaYlNlYXJjaGVzIGZvciBpbnZlc3Rv'
    'cnMgbWF0Y2hpbmcgc3BlY2lmaWVkIGNyaXRlcmlhLiBSZXR1cm5zIGEgc3RyZWFtIG9mIG1hdG'
    'NoaW5nIGludmVzdG9yIHJlY29yZHMuKg5pbnZlc3RvclNlYXJjaIK1GA8KDWludmVzdG9yX3Zp'
    'ZXcwARLQAgoPQ2xpZW50R3JvdXBTYXZlEiMuaWRlbnRpdHkudjEuQ2xpZW50R3JvdXBTYXZlUm'
    'VxdWVzdBokLmlkZW50aXR5LnYxLkNsaWVudEdyb3VwU2F2ZVJlc3BvbnNlIvEBukfUAQoMQ2xp'
    'ZW50R3JvdXBzEh9DcmVhdGUgb3IgdXBkYXRlIGEgY2xpZW50IGdyb3VwGpEBQ3JlYXRlcyBhIG'
    '5ldyBjbGllbnQgZ3JvdXAgb3IgdXBkYXRlcyBhbiBleGlzdGluZyBvbmUuIENsaWVudCBncm91'
    'cHMgcmVwcmVzZW50IGNvbGxlY3RpdmUgZW50aXRpZXMgc3VjaCBhcyBTQUNDTyBncm91cHMgaW'
    '4gdGhlIGxlbmRpbmcgaGllcmFyY2h5LioPY2xpZW50R3JvdXBTYXZlgrUYFQoTY2xpZW50X2dy'
    'b3VwX21hbmFnZRLsAQoOQ2xpZW50R3JvdXBHZXQSIi5pZGVudGl0eS52MS5DbGllbnRHcm91cE'
    'dldFJlcXVlc3QaIy5pZGVudGl0eS52MS5DbGllbnRHcm91cEdldFJlc3BvbnNlIpABkAIBukdz'
    'CgxDbGllbnRHcm91cHMSGEdldCBhIGNsaWVudCBncm91cCBieSBJRBo5UmV0cmlldmVzIGEgY2'
    'xpZW50IGdyb3VwIHJlY29yZCBieSBpdHMgdW5pcXVlIGlkZW50aWZpZXIuKg5jbGllbnRHcm91'
    'cEdldIK1GBMKEWNsaWVudF9ncm91cF92aWV3EtECChFDbGllbnRHcm91cFNlYXJjaBIlLmlkZW'
    '50aXR5LnYxLkNsaWVudEdyb3VwU2VhcmNoUmVxdWVzdBomLmlkZW50aXR5LnYxLkNsaWVudEdy'
    'b3VwU2VhcmNoUmVzcG9uc2Ui6gGQAgG6R8wBCgxDbGllbnRHcm91cHMSFFNlYXJjaCBjbGllbn'
    'QgZ3JvdXBzGpIBU2VhcmNoZXMgZm9yIGNsaWVudCBncm91cHMgbWF0Y2hpbmcgc3BlY2lmaWVk'
    'IGNyaXRlcmlhLiBTdXBwb3J0cyBmaWx0ZXJpbmcgYnkgYWdlbnQgYW5kIGJyYW5jaC4gUmV0dX'
    'JucyBhIHN0cmVhbSBvZiBtYXRjaGluZyBjbGllbnQgZ3JvdXAgcmVjb3Jkcy4qEWNsaWVudEdy'
    'b3VwU2VhcmNogrUYEwoRY2xpZW50X2dyb3VwX3ZpZXcwARKoAgoOTWVtYmVyc2hpcFNhdmUSIi'
    '5pZGVudGl0eS52MS5NZW1iZXJzaGlwU2F2ZVJlcXVlc3QaIy5pZGVudGl0eS52MS5NZW1iZXJz'
    'aGlwU2F2ZVJlc3BvbnNlIswBukexAQoLTWVtYmVyc2hpcHMSHUNyZWF0ZSBvciB1cGRhdGUgYS'
    'BtZW1iZXJzaGlwGnNDcmVhdGVzIGEgbmV3IG1lbWJlcnNoaXAgb3IgdXBkYXRlcyBhbiBleGlz'
    'dGluZyBvbmUuIE1lbWJlcnNoaXBzIHRyYWNrIGEgcHJvZmlsZSdzIGFmZmlsaWF0aW9uIHdpdG'
    'ggYSBjbGllbnQgZ3JvdXAuKg5tZW1iZXJzaGlwU2F2ZYK1GBMKEW1lbWJlcnNoaXBfbWFuYWdl'
    'EuEBCg1NZW1iZXJzaGlwR2V0EiEuaWRlbnRpdHkudjEuTWVtYmVyc2hpcEdldFJlcXVlc3QaIi'
    '5pZGVudGl0eS52MS5NZW1iZXJzaGlwR2V0UmVzcG9uc2UiiAGQAgG6R20KC01lbWJlcnNoaXBz'
    'EhZHZXQgYSBtZW1iZXJzaGlwIGJ5IElEGjdSZXRyaWV2ZXMgYSBtZW1iZXJzaGlwIHJlY29yZC'
    'BieSBpdHMgdW5pcXVlIGlkZW50aWZpZXIuKg1tZW1iZXJzaGlwR2V0grUYEQoPbWVtYmVyc2hp'
    'cF92aWV3EsUCChBNZW1iZXJzaGlwU2VhcmNoEiQuaWRlbnRpdHkudjEuTWVtYmVyc2hpcFNlYX'
    'JjaFJlcXVlc3QaJS5pZGVudGl0eS52MS5NZW1iZXJzaGlwU2VhcmNoUmVzcG9uc2Ui4QGQAgG6'
    'R8UBCgtNZW1iZXJzaGlwcxISU2VhcmNoIG1lbWJlcnNoaXBzGo8BU2VhcmNoZXMgZm9yIG1lbW'
    'JlcnNoaXBzIG1hdGNoaW5nIHNwZWNpZmllZCBjcml0ZXJpYS4gU3VwcG9ydHMgZmlsdGVyaW5n'
    'IGJ5IGdyb3VwIGFuZCBwcm9maWxlLiBSZXR1cm5zIGEgc3RyZWFtIG9mIG1hdGNoaW5nIG1lbW'
    'JlcnNoaXAgcmVjb3Jkcy4qEG1lbWJlcnNoaXBTZWFyY2iCtRgRCg9tZW1iZXJzaGlwX3ZpZXcw'
    'ARLoAgoTSW52ZXN0b3JBY2NvdW50U2F2ZRInLmlkZW50aXR5LnYxLkludmVzdG9yQWNjb3VudF'
    'NhdmVSZXF1ZXN0GiguaWRlbnRpdHkudjEuSW52ZXN0b3JBY2NvdW50U2F2ZVJlc3BvbnNlIv0B'
    'ukfcAQoQSW52ZXN0b3JBY2NvdW50cxIkQ3JlYXRlIG9yIHVwZGF0ZSBhbiBpbnZlc3RvciBhY2'
    'NvdW50GowBQ3JlYXRlcyBhIG5ldyBpbnZlc3RvciBjYXBpdGFsIGFjY291bnQgb3IgdXBkYXRl'
    'cyBhbiBleGlzdGluZyBvbmUuIEludmVzdG9yIGFjY291bnRzIHRyYWNrIHByZS1mdW5kZWQgY2'
    'FwaXRhbCBhdmFpbGFibGUgZm9yIGxvYW4gZGVwbG95bWVudC4qE2ludmVzdG9yQWNjb3VudFNh'
    'dmWCtRgZChdpbnZlc3Rvcl9hY2NvdW50X21hbmFnZRKQAgoSSW52ZXN0b3JBY2NvdW50R2V0Ei'
    'YuaWRlbnRpdHkudjEuSW52ZXN0b3JBY2NvdW50R2V0UmVxdWVzdBonLmlkZW50aXR5LnYxLklu'
    'dmVzdG9yQWNjb3VudEdldFJlc3BvbnNlIqgBkAIBukeGAQoQSW52ZXN0b3JBY2NvdW50cxIdR2'
    'V0IGFuIGludmVzdG9yIGFjY291bnQgYnkgSUQaP1JldHJpZXZlcyBhbiBpbnZlc3RvciBjYXBp'
    'dGFsIGFjY291bnQgYnkgaXRzIHVuaXF1ZSBpZGVudGlmaWVyLioSaW52ZXN0b3JBY2NvdW50R2'
    'V0grUYFwoVaW52ZXN0b3JfYWNjb3VudF92aWV3EsoCChVJbnZlc3RvckFjY291bnRTZWFyY2gS'
    'KS5pZGVudGl0eS52MS5JbnZlc3RvckFjY291bnRTZWFyY2hSZXF1ZXN0GiouaWRlbnRpdHkudj'
    'EuSW52ZXN0b3JBY2NvdW50U2VhcmNoUmVzcG9uc2Ui1wGQAgG6R7UBChBJbnZlc3RvckFjY291'
    'bnRzEhhTZWFyY2ggaW52ZXN0b3IgYWNjb3VudHMacFNlYXJjaGVzIGZvciBpbnZlc3RvciBhY2'
    'NvdW50cyBtYXRjaGluZyBzcGVjaWZpZWQgY3JpdGVyaWEuIFN1cHBvcnRzIGZpbHRlcmluZyBi'
    'eSBpbnZlc3RvciBJRCBhbmQgY3VycmVuY3kgY29kZS4qFWludmVzdG9yQWNjb3VudFNlYXJjaI'
    'K1GBcKFWludmVzdG9yX2FjY291bnRfdmlldzABEqcCCg9JbnZlc3RvckRlcG9zaXQSIy5pZGVu'
    'dGl0eS52MS5JbnZlc3RvckRlcG9zaXRSZXF1ZXN0GiQuaWRlbnRpdHkudjEuSW52ZXN0b3JEZX'
    'Bvc2l0UmVzcG9uc2UiyAG6R6cBChBJbnZlc3RvckFjY291bnRzEiZEZXBvc2l0IGZ1bmRzIGlu'
    'dG8gYW4gaW52ZXN0b3IgYWNjb3VudBpaQWRkcyBjYXBpdGFsIHRvIGFuIGludmVzdG9yIGFjY2'
    '91bnQsIGluY3JlYXNpbmcgdGhlIGF2YWlsYWJsZSBiYWxhbmNlIGZvciBsb2FuIGRlcGxveW1l'
    'bnQuKg9pbnZlc3RvckRlcG9zaXSCtRgZChdpbnZlc3Rvcl9hY2NvdW50X21hbmFnZRKpAgoQSW'
    '52ZXN0b3JXaXRoZHJhdxIkLmlkZW50aXR5LnYxLkludmVzdG9yV2l0aGRyYXdSZXF1ZXN0GiUu'
    'aWRlbnRpdHkudjEuSW52ZXN0b3JXaXRoZHJhd1Jlc3BvbnNlIscBukemAQoQSW52ZXN0b3JBY2'
    'NvdW50cxInV2l0aGRyYXcgZnVuZHMgZnJvbSBhbiBpbnZlc3RvciBhY2NvdW50GldSZW1vdmVz'
    'IGNhcGl0YWwgZnJvbSBhbiBpbnZlc3RvciBhY2NvdW50IGlmIHN1ZmZpY2llbnQgdW5yZXNlcn'
    'ZlZCBiYWxhbmNlIGlzIGF2YWlsYWJsZS4qEGludmVzdG9yV2l0aGRyYXeCtRgZChdpbnZlc3Rv'
    'cl9hY2NvdW50X21hbmFnZRLQAgoOQ2xpZW50RGF0YVNhdmUSIi5pZGVudGl0eS52MS5DbGllbn'
    'REYXRhU2F2ZVJlcXVlc3QaIy5pZGVudGl0eS52MS5DbGllbnREYXRhU2F2ZVJlc3BvbnNlIvQB'
    'ukfYAQoKQ2xpZW50RGF0YRIUU2F2ZSBjbGllbnQgS1lDIGRhdGEaowFDcmVhdGVzIG9yIHVwZG'
    'F0ZXMgYSBzaW5nbGUgY2xpZW50IGRhdGEgZW50cnkuIElmIGFuIGVudHJ5IGFscmVhZHkgZXhp'
    'c3RzIGZvciB0aGUgc2FtZSBjbGllbnRfaWQgKyBmaWVsZF9rZXksIHRoZSByZXZpc2lvbiBpcy'
    'BpbmNyZW1lbnRlZCBhbmQgdGhlIHZhbHVlIGlzIHVwZGF0ZWQuKg5jbGllbnREYXRhU2F2ZYK1'
    'GBQKEmNsaWVudF9kYXRhX21hbmFnZRLrAQoNQ2xpZW50RGF0YUdldBIhLmlkZW50aXR5LnYxLk'
    'NsaWVudERhdGFHZXRSZXF1ZXN0GiIuaWRlbnRpdHkudjEuQ2xpZW50RGF0YUdldFJlc3BvbnNl'
    'IpIBkAIBukd2CgpDbGllbnREYXRhEhdHZXQgYSBjbGllbnQgZGF0YSBlbnRyeRpAUmV0cmlldm'
    'VzIGEgc2luZ2xlIGNsaWVudCBkYXRhIGVudHJ5IGJ5IGNsaWVudCBJRCBhbmQgZmllbGQga2V5'
    'LioNY2xpZW50RGF0YUdldIK1GBIKEGNsaWVudF9kYXRhX3ZpZXcSgwIKDkNsaWVudERhdGFMaX'
    'N0EiIuaWRlbnRpdHkudjEuQ2xpZW50RGF0YUxpc3RSZXF1ZXN0GiMuaWRlbnRpdHkudjEuQ2xp'
    'ZW50RGF0YUxpc3RSZXNwb25zZSKlAZACAbpHiAEKCkNsaWVudERhdGESGExpc3QgY2xpZW50IG'
    'RhdGEgZW50cmllcxpQTGlzdHMgYWxsIGRhdGEgZW50cmllcyBmb3IgYSBjbGllbnQsIG9wdGlv'
    'bmFsbHkgZmlsdGVyZWQgYnkgdmVyaWZpY2F0aW9uIHN0YXR1cy4qDmNsaWVudERhdGFMaXN0gr'
    'UYEgoQY2xpZW50X2RhdGFfdmlldzABEu0BChBDbGllbnREYXRhVmVyaWZ5EiQuaWRlbnRpdHku'
    'djEuQ2xpZW50RGF0YVZlcmlmeVJlcXVlc3QaJS5pZGVudGl0eS52MS5DbGllbnREYXRhVmVyaW'
    'Z5UmVzcG9uc2UiiwG6R3AKCkNsaWVudERhdGESGlZlcmlmeSBhIGNsaWVudCBkYXRhIGVudHJ5'
    'GjRNYXJrcyBhIGNsaWVudCBkYXRhIGVudHJ5IGFzIHZlcmlmaWVkIGJ5IGEgcmV2aWV3ZXIuKh'
    'BjbGllbnREYXRhVmVyaWZ5grUYFAoSY2xpZW50X2RhdGFfdmVyaWZ5EoUCChBDbGllbnREYXRh'
    'UmVqZWN0EiQuaWRlbnRpdHkudjEuQ2xpZW50RGF0YVJlamVjdFJlcXVlc3QaJS5pZGVudGl0eS'
    '52MS5DbGllbnREYXRhUmVqZWN0UmVzcG9uc2UiowG6R4cBCgpDbGllbnREYXRhEhpSZWplY3Qg'
    'YSBjbGllbnQgZGF0YSBlbnRyeRpLTWFya3MgYSBjbGllbnQgZGF0YSBlbnRyeSBhcyByZWplY3'
    'RlZCBieSBhIHJldmlld2VyIHdpdGggYSByZXF1aXJlZCByZWFzb24uKhBjbGllbnREYXRhUmVq'
    'ZWN0grUYFAoSY2xpZW50X2RhdGFfdmVyaWZ5EqsCChVDbGllbnREYXRhUmVxdWVzdEluZm8SKS'
    '5pZGVudGl0eS52MS5DbGllbnREYXRhUmVxdWVzdEluZm9SZXF1ZXN0GiouaWRlbnRpdHkudjEu'
    'Q2xpZW50RGF0YVJlcXVlc3RJbmZvUmVzcG9uc2UiugG6R54BCgpDbGllbnREYXRhEilSZXF1ZX'
    'N0IG1vcmUgaW5mbyBmb3IgYSBjbGllbnQgZGF0YSBlbnRyeRpOTWFya3MgYSBjbGllbnQgZGF0'
    'YSBlbnRyeSBhcyBuZWVkaW5nIG1vcmUgaW5mb3JtYXRpb24gd2l0aCBhIHJlcXVpcmVkIGNvbW'
    '1lbnQuKhVjbGllbnREYXRhUmVxdWVzdEluZm+CtRgUChJjbGllbnRfZGF0YV92ZXJpZnkS/wEK'
    'EUNsaWVudERhdGFIaXN0b3J5EiUuaWRlbnRpdHkudjEuQ2xpZW50RGF0YUhpc3RvcnlSZXF1ZX'
    'N0GiYuaWRlbnRpdHkudjEuQ2xpZW50RGF0YUhpc3RvcnlSZXNwb25zZSKaAZACAbpHfgoKQ2xp'
    'ZW50RGF0YRIfR2V0IGRhdGEgZW50cnkgcmV2aXNpb24gaGlzdG9yeRo8UmV0cmlldmVzIHRoZS'
    'BmdWxsIHJldmlzaW9uIGhpc3RvcnkgZm9yIGEgY2xpZW50IGRhdGEgZW50cnkuKhFjbGllbnRE'
    'YXRhSGlzdG9yeYK1GBIKEGNsaWVudF9kYXRhX3ZpZXcSjQIKEEZvcm1UZW1wbGF0ZVNhdmUSJC'
    '5pZGVudGl0eS52MS5Gb3JtVGVtcGxhdGVTYXZlUmVxdWVzdBolLmlkZW50aXR5LnYxLkZvcm1U'
    'ZW1wbGF0ZVNhdmVSZXNwb25zZSKrAbpHjQEKDUZvcm1UZW1wbGF0ZXMSIENyZWF0ZSBvciB1cG'
    'RhdGUgYSBmb3JtIHRlbXBsYXRlGkhDcmVhdGVzIG9yIHVwZGF0ZXMgYSByZXVzYWJsZSBmb3Jt'
    'IHRlbXBsYXRlIGZvciBkeW5hbWljIGRhdGEgY29sbGVjdGlvbi4qEGZvcm1UZW1wbGF0ZVNhdm'
    'WCtRgWChRmb3JtX3RlbXBsYXRlX21hbmFnZRLtAQoPRm9ybVRlbXBsYXRlR2V0EiMuaWRlbnRp'
    'dHkudjEuRm9ybVRlbXBsYXRlR2V0UmVxdWVzdBokLmlkZW50aXR5LnYxLkZvcm1UZW1wbGF0ZU'
    'dldFJlc3BvbnNlIo4BkAIBukdwCg1Gb3JtVGVtcGxhdGVzEhlHZXQgYSBmb3JtIHRlbXBsYXRl'
    'IGJ5IElEGjNSZXRyaWV2ZXMgYSBmb3JtIHRlbXBsYXRlIGJ5IGl0cyB1bmlxdWUgaWRlbnRpZm'
    'llci4qD2Zvcm1UZW1wbGF0ZUdldIK1GBQKEmZvcm1fdGVtcGxhdGVfdmlldxKWAgoSRm9ybVRl'
    'bXBsYXRlU2VhcmNoEiYuaWRlbnRpdHkudjEuRm9ybVRlbXBsYXRlU2VhcmNoUmVxdWVzdBonLm'
    'lkZW50aXR5LnYxLkZvcm1UZW1wbGF0ZVNlYXJjaFJlc3BvbnNlIqwBkAIBukeNAQoNRm9ybVRl'
    'bXBsYXRlcxIVU2VhcmNoIGZvcm0gdGVtcGxhdGVzGlFTZWFyY2hlcyBmb3IgZm9ybSB0ZW1wbG'
    'F0ZXMgYnkgb3JnYW5pemF0aW9uLCBzdGF0dXMsIGVudGl0eSB0eXBlLCBhbmQgdGV4dCBxdWVy'
    'eS4qEmZvcm1UZW1wbGF0ZVNlYXJjaIK1GBQKEmZvcm1fdGVtcGxhdGVfdmlldzABEpQCChNGb3'
    'JtVGVtcGxhdGVQdWJsaXNoEicuaWRlbnRpdHkudjEuRm9ybVRlbXBsYXRlUHVibGlzaFJlcXVl'
    'c3QaKC5pZGVudGl0eS52MS5Gb3JtVGVtcGxhdGVQdWJsaXNoUmVzcG9uc2UiqQG6R4sBCg1Gb3'
    'JtVGVtcGxhdGVzEhdQdWJsaXNoIGEgZm9ybSB0ZW1wbGF0ZRpMVHJhbnNpdGlvbnMgYSBkcmFm'
    'dCBmb3JtIHRlbXBsYXRlIHRvIHB1Ymxpc2hlZCwgbWFraW5nIGl0IGF2YWlsYWJsZSBmb3IgdX'
    'NlLioTZm9ybVRlbXBsYXRlUHVibGlzaIK1GBYKFGZvcm1fdGVtcGxhdGVfbWFuYWdlEo4CChJG'
    'b3JtU3VibWlzc2lvblNhdmUSJi5pZGVudGl0eS52MS5Gb3JtU3VibWlzc2lvblNhdmVSZXF1ZX'
    'N0GicuaWRlbnRpdHkudjEuRm9ybVN1Ym1pc3Npb25TYXZlUmVzcG9uc2UipgG6R4YBCg9Gb3Jt'
    'U3VibWlzc2lvbnMSFlNhdmUgYSBmb3JtIHN1Ym1pc3Npb24aR0NyZWF0ZXMgb3IgdXBkYXRlcy'
    'BhIGZvcm0gc3VibWlzc2lvbiB3aXRoIGNvbGxlY3RlZCBkYXRhIGZvciBhbiBlbnRpdHkuKhJm'
    'b3JtU3VibWlzc2lvblNhdmWCtRgYChZmb3JtX3N1Ym1pc3Npb25fbWFuYWdlEv0BChFGb3JtU3'
    'VibWlzc2lvbkdldBIlLmlkZW50aXR5LnYxLkZvcm1TdWJtaXNzaW9uR2V0UmVxdWVzdBomLmlk'
    'ZW50aXR5LnYxLkZvcm1TdWJtaXNzaW9uR2V0UmVzcG9uc2UimAGQAgG6R3gKD0Zvcm1TdWJtaX'
    'NzaW9ucxIbR2V0IGEgZm9ybSBzdWJtaXNzaW9uIGJ5IElEGjVSZXRyaWV2ZXMgYSBmb3JtIHN1'
    'Ym1pc3Npb24gYnkgaXRzIHVuaXF1ZSBpZGVudGlmaWVyLioRZm9ybVN1Ym1pc3Npb25HZXSCtR'
    'gWChRmb3JtX3N1Ym1pc3Npb25fdmlldxKWAgoURm9ybVN1Ym1pc3Npb25TZWFyY2gSKC5pZGVu'
    'dGl0eS52MS5Gb3JtU3VibWlzc2lvblNlYXJjaFJlcXVlc3QaKS5pZGVudGl0eS52MS5Gb3JtU3'
    'VibWlzc2lvblNlYXJjaFJlc3BvbnNlIqYBkAIBukeFAQoPRm9ybVN1Ym1pc3Npb25zEhdTZWFy'
    'Y2ggZm9ybSBzdWJtaXNzaW9ucxpDU2VhcmNoZXMgZm9yIGZvcm0gc3VibWlzc2lvbnMgYnkgZW'
    '50aXR5LCB0ZW1wbGF0ZSwgYW5kIGVudGl0eSB0eXBlLioUZm9ybVN1Ym1pc3Npb25TZWFyY2iC'
    'tRgWChRmb3JtX3N1Ym1pc3Npb25fdmlldzABGosfgrUYhh8KEHNlcnZpY2VfaWRlbnRpdHkSEW'
    '9yZ2FuaXphdGlvbl92aWV3EhNvcmdhbml6YXRpb25fbWFuYWdlEgticmFuY2hfdmlldxINYnJh'
    'bmNoX21hbmFnZRIVd29ya2ZvcmNlX21lbWJlcl92aWV3Ehd3b3JrZm9yY2VfbWVtYmVyX21hbm'
    'FnZRIPZGVwYXJ0bWVudF92aWV3EhFkZXBhcnRtZW50X21hbmFnZRINcG9zaXRpb25fdmlldxIP'
    'cG9zaXRpb25fbWFuYWdlEhhwb3NpdGlvbl9hc3NpZ25tZW50X3ZpZXcSGnBvc2l0aW9uX2Fzc2'
    'lnbm1lbnRfbWFuYWdlEgl0ZWFtX3ZpZXcSC3RlYW1fbWFuYWdlEhR0ZWFtX21lbWJlcnNoaXBf'
    'dmlldxIWdGVhbV9tZW1iZXJzaGlwX21hbmFnZRIbYWNjZXNzX3JvbGVfYXNzaWdubWVudF92aW'
    'V3Eh1hY2Nlc3Nfcm9sZV9hc3NpZ25tZW50X21hbmFnZRINaW52ZXN0b3JfdmlldxIPaW52ZXN0'
    'b3JfbWFuYWdlEhFjbGllbnRfZ3JvdXBfdmlldxITY2xpZW50X2dyb3VwX21hbmFnZRIPbWVtYm'
    'Vyc2hpcF92aWV3EhFtZW1iZXJzaGlwX21hbmFnZRIVaW52ZXN0b3JfYWNjb3VudF92aWV3Ehdp'
    'bnZlc3Rvcl9hY2NvdW50X21hbmFnZRIQY2xpZW50X2RhdGFfdmlldxISY2xpZW50X2RhdGFfbW'
    'FuYWdlEhJjbGllbnRfZGF0YV92ZXJpZnkSEmZvcm1fdGVtcGxhdGVfdmlldxIUZm9ybV90ZW1w'
    'bGF0ZV9tYW5hZ2USFGZvcm1fc3VibWlzc2lvbl92aWV3EhZmb3JtX3N1Ym1pc3Npb25fbWFuYW'
    'dlGqAFCAESEW9yZ2FuaXphdGlvbl92aWV3EhNvcmdhbml6YXRpb25fbWFuYWdlEgticmFuY2hf'
    'dmlldxINYnJhbmNoX21hbmFnZRIVd29ya2ZvcmNlX21lbWJlcl92aWV3Ehd3b3JrZm9yY2VfbW'
    'VtYmVyX21hbmFnZRIPZGVwYXJ0bWVudF92aWV3EhFkZXBhcnRtZW50X21hbmFnZRINcG9zaXRp'
    'b25fdmlldxIPcG9zaXRpb25fbWFuYWdlEhhwb3NpdGlvbl9hc3NpZ25tZW50X3ZpZXcSGnBvc2'
    'l0aW9uX2Fzc2lnbm1lbnRfbWFuYWdlEgl0ZWFtX3ZpZXcSC3RlYW1fbWFuYWdlEhR0ZWFtX21l'
    'bWJlcnNoaXBfdmlldxIWdGVhbV9tZW1iZXJzaGlwX21hbmFnZRIbYWNjZXNzX3JvbGVfYXNzaW'
    'dubWVudF92aWV3Eh1hY2Nlc3Nfcm9sZV9hc3NpZ25tZW50X21hbmFnZRINaW52ZXN0b3Jfdmll'
    'dxIPaW52ZXN0b3JfbWFuYWdlEhFjbGllbnRfZ3JvdXBfdmlldxITY2xpZW50X2dyb3VwX21hbm'
    'FnZRIPbWVtYmVyc2hpcF92aWV3EhFtZW1iZXJzaGlwX21hbmFnZRIVaW52ZXN0b3JfYWNjb3Vu'
    'dF92aWV3EhdpbnZlc3Rvcl9hY2NvdW50X21hbmFnZRIQY2xpZW50X2RhdGFfdmlldxISY2xpZW'
    '50X2RhdGFfbWFuYWdlEhJjbGllbnRfZGF0YV92ZXJpZnkSEmZvcm1fdGVtcGxhdGVfdmlldxIU'
    'Zm9ybV90ZW1wbGF0ZV9tYW5hZ2USFGZvcm1fc3VibWlzc2lvbl92aWV3EhZmb3JtX3N1Ym1pc3'
    'Npb25fbWFuYWdlGqAFCAISEW9yZ2FuaXphdGlvbl92aWV3EhNvcmdhbml6YXRpb25fbWFuYWdl'
    'EgticmFuY2hfdmlldxINYnJhbmNoX21hbmFnZRIVd29ya2ZvcmNlX21lbWJlcl92aWV3Ehd3b3'
    'JrZm9yY2VfbWVtYmVyX21hbmFnZRIPZGVwYXJ0bWVudF92aWV3EhFkZXBhcnRtZW50X21hbmFn'
    'ZRINcG9zaXRpb25fdmlldxIPcG9zaXRpb25fbWFuYWdlEhhwb3NpdGlvbl9hc3NpZ25tZW50X3'
    'ZpZXcSGnBvc2l0aW9uX2Fzc2lnbm1lbnRfbWFuYWdlEgl0ZWFtX3ZpZXcSC3RlYW1fbWFuYWdl'
    'EhR0ZWFtX21lbWJlcnNoaXBfdmlldxIWdGVhbV9tZW1iZXJzaGlwX21hbmFnZRIbYWNjZXNzX3'
    'JvbGVfYXNzaWdubWVudF92aWV3Eh1hY2Nlc3Nfcm9sZV9hc3NpZ25tZW50X21hbmFnZRINaW52'
    'ZXN0b3JfdmlldxIPaW52ZXN0b3JfbWFuYWdlEhFjbGllbnRfZ3JvdXBfdmlldxITY2xpZW50X2'
    'dyb3VwX21hbmFnZRIPbWVtYmVyc2hpcF92aWV3EhFtZW1iZXJzaGlwX21hbmFnZRIVaW52ZXN0'
    'b3JfYWNjb3VudF92aWV3EhdpbnZlc3Rvcl9hY2NvdW50X21hbmFnZRIQY2xpZW50X2RhdGFfdm'
    'lldxISY2xpZW50X2RhdGFfbWFuYWdlEhJjbGllbnRfZGF0YV92ZXJpZnkSEmZvcm1fdGVtcGxh'
    'dGVfdmlldxIUZm9ybV90ZW1wbGF0ZV9tYW5hZ2USFGZvcm1fc3VibWlzc2lvbl92aWV3EhZmb3'
    'JtX3N1Ym1pc3Npb25fbWFuYWdlGvYECAMSEW9yZ2FuaXphdGlvbl92aWV3EhNvcmdhbml6YXRp'
    'b25fbWFuYWdlEgticmFuY2hfdmlldxINYnJhbmNoX21hbmFnZRIVd29ya2ZvcmNlX21lbWJlcl'
    '92aWV3Ehd3b3JrZm9yY2VfbWVtYmVyX21hbmFnZRIPZGVwYXJ0bWVudF92aWV3EhFkZXBhcnRt'
    'ZW50X21hbmFnZRINcG9zaXRpb25fdmlldxIPcG9zaXRpb25fbWFuYWdlEhhwb3NpdGlvbl9hc3'
    'NpZ25tZW50X3ZpZXcSGnBvc2l0aW9uX2Fzc2lnbm1lbnRfbWFuYWdlEgl0ZWFtX3ZpZXcSC3Rl'
    'YW1fbWFuYWdlEhR0ZWFtX21lbWJlcnNoaXBfdmlldxIWdGVhbV9tZW1iZXJzaGlwX21hbmFnZR'
    'IbYWNjZXNzX3JvbGVfYXNzaWdubWVudF92aWV3Eh1hY2Nlc3Nfcm9sZV9hc3NpZ25tZW50X21h'
    'bmFnZRINaW52ZXN0b3JfdmlldxIVaW52ZXN0b3JfYWNjb3VudF92aWV3EhFjbGllbnRfZ3JvdX'
    'BfdmlldxITY2xpZW50X2dyb3VwX21hbmFnZRIPbWVtYmVyc2hpcF92aWV3EhFtZW1iZXJzaGlw'
    'X21hbmFnZRIQY2xpZW50X2RhdGFfdmlldxISY2xpZW50X2RhdGFfbWFuYWdlEhJjbGllbnRfZG'
    'F0YV92ZXJpZnkSEmZvcm1fdGVtcGxhdGVfdmlldxIUZm9ybV90ZW1wbGF0ZV9tYW5hZ2USFGZv'
    'cm1fc3VibWlzc2lvbl92aWV3EhZmb3JtX3N1Ym1pc3Npb25fbWFuYWdlGrcCCAQSEW9yZ2FuaX'
    'phdGlvbl92aWV3EgticmFuY2hfdmlldxIVd29ya2ZvcmNlX21lbWJlcl92aWV3Eg9kZXBhcnRt'
    'ZW50X3ZpZXcSDXBvc2l0aW9uX3ZpZXcSGHBvc2l0aW9uX2Fzc2lnbm1lbnRfdmlldxIJdGVhbV'
    '92aWV3EhR0ZWFtX21lbWJlcnNoaXBfdmlldxIbYWNjZXNzX3JvbGVfYXNzaWdubWVudF92aWV3'
    'Eg1pbnZlc3Rvcl92aWV3EhVpbnZlc3Rvcl9hY2NvdW50X3ZpZXcSEWNsaWVudF9ncm91cF92aW'
    'V3Eg9tZW1iZXJzaGlwX3ZpZXcSEGNsaWVudF9kYXRhX3ZpZXcSEmZvcm1fdGVtcGxhdGVfdmll'
    'dxIUZm9ybV9zdWJtaXNzaW9uX3ZpZXcatwIIBRIRb3JnYW5pemF0aW9uX3ZpZXcSC2JyYW5jaF'
    '92aWV3EhV3b3JrZm9yY2VfbWVtYmVyX3ZpZXcSD2RlcGFydG1lbnRfdmlldxINcG9zaXRpb25f'
    'dmlldxIYcG9zaXRpb25fYXNzaWdubWVudF92aWV3Egl0ZWFtX3ZpZXcSFHRlYW1fbWVtYmVyc2'
    'hpcF92aWV3EhthY2Nlc3Nfcm9sZV9hc3NpZ25tZW50X3ZpZXcSDWludmVzdG9yX3ZpZXcSFWlu'
    'dmVzdG9yX2FjY291bnRfdmlldxIRY2xpZW50X2dyb3VwX3ZpZXcSD21lbWJlcnNoaXBfdmlldx'
    'IQY2xpZW50X2RhdGFfdmlldxISZm9ybV90ZW1wbGF0ZV92aWV3EhRmb3JtX3N1Ym1pc3Npb25f'
    'dmlldxqgBQgGEhFvcmdhbml6YXRpb25fdmlldxITb3JnYW5pemF0aW9uX21hbmFnZRILYnJhbm'
    'NoX3ZpZXcSDWJyYW5jaF9tYW5hZ2USFXdvcmtmb3JjZV9tZW1iZXJfdmlldxIXd29ya2ZvcmNl'
    'X21lbWJlcl9tYW5hZ2USD2RlcGFydG1lbnRfdmlldxIRZGVwYXJ0bWVudF9tYW5hZ2USDXBvc2'
    'l0aW9uX3ZpZXcSD3Bvc2l0aW9uX21hbmFnZRIYcG9zaXRpb25fYXNzaWdubWVudF92aWV3Ehpw'
    'b3NpdGlvbl9hc3NpZ25tZW50X21hbmFnZRIJdGVhbV92aWV3Egt0ZWFtX21hbmFnZRIUdGVhbV'
    '9tZW1iZXJzaGlwX3ZpZXcSFnRlYW1fbWVtYmVyc2hpcF9tYW5hZ2USG2FjY2Vzc19yb2xlX2Fz'
    'c2lnbm1lbnRfdmlldxIdYWNjZXNzX3JvbGVfYXNzaWdubWVudF9tYW5hZ2USDWludmVzdG9yX3'
    'ZpZXcSD2ludmVzdG9yX21hbmFnZRIRY2xpZW50X2dyb3VwX3ZpZXcSE2NsaWVudF9ncm91cF9t'
    'YW5hZ2USD21lbWJlcnNoaXBfdmlldxIRbWVtYmVyc2hpcF9tYW5hZ2USFWludmVzdG9yX2FjY2'
    '91bnRfdmlldxIXaW52ZXN0b3JfYWNjb3VudF9tYW5hZ2USEGNsaWVudF9kYXRhX3ZpZXcSEmNs'
    'aWVudF9kYXRhX21hbmFnZRISY2xpZW50X2RhdGFfdmVyaWZ5EhJmb3JtX3RlbXBsYXRlX3ZpZX'
    'cSFGZvcm1fdGVtcGxhdGVfbWFuYWdlEhRmb3JtX3N1Ym1pc3Npb25fdmlldxIWZm9ybV9zdWJt'
    'aXNzaW9uX21hbmFnZQ==');

