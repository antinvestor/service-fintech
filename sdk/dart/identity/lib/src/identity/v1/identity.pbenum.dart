//
//  Generated code. Do not modify.
//  source: identity/v1/identity.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// OrganizationType defines the kind of organization.
class OrganizationType extends $pb.ProtobufEnum {
  static const OrganizationType ORGANIZATION_TYPE_UNSPECIFIED = OrganizationType._(0, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_UNSPECIFIED');
  static const OrganizationType ORGANIZATION_TYPE_BANK = OrganizationType._(1, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_BANK');
  static const OrganizationType ORGANIZATION_TYPE_MICROFINANCE = OrganizationType._(2, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_MICROFINANCE');
  static const OrganizationType ORGANIZATION_TYPE_SACCO = OrganizationType._(3, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_SACCO');
  static const OrganizationType ORGANIZATION_TYPE_FINTECH = OrganizationType._(4, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_FINTECH');
  static const OrganizationType ORGANIZATION_TYPE_COOPERATIVE = OrganizationType._(5, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_COOPERATIVE');
  static const OrganizationType ORGANIZATION_TYPE_NGO = OrganizationType._(6, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_NGO');
  static const OrganizationType ORGANIZATION_TYPE_GOVERNMENT = OrganizationType._(7, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_GOVERNMENT');
  static const OrganizationType ORGANIZATION_TYPE_OTHER = OrganizationType._(8, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_OTHER');
  static const OrganizationType ORGANIZATION_TYPE_TRADING = OrganizationType._(9, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_TRADING');
  static const OrganizationType ORGANIZATION_TYPE_RETAIL = OrganizationType._(10, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_RETAIL');
  static const OrganizationType ORGANIZATION_TYPE_MANUFACTURING = OrganizationType._(11, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_MANUFACTURING');
  static const OrganizationType ORGANIZATION_TYPE_LOGISTICS = OrganizationType._(12, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_LOGISTICS');
  static const OrganizationType ORGANIZATION_TYPE_SERVICES = OrganizationType._(13, _omitEnumNames ? '' : 'ORGANIZATION_TYPE_SERVICES');

  static const $core.List<OrganizationType> values = <OrganizationType> [
    ORGANIZATION_TYPE_UNSPECIFIED,
    ORGANIZATION_TYPE_BANK,
    ORGANIZATION_TYPE_MICROFINANCE,
    ORGANIZATION_TYPE_SACCO,
    ORGANIZATION_TYPE_FINTECH,
    ORGANIZATION_TYPE_COOPERATIVE,
    ORGANIZATION_TYPE_NGO,
    ORGANIZATION_TYPE_GOVERNMENT,
    ORGANIZATION_TYPE_OTHER,
    ORGANIZATION_TYPE_TRADING,
    ORGANIZATION_TYPE_RETAIL,
    ORGANIZATION_TYPE_MANUFACTURING,
    ORGANIZATION_TYPE_LOGISTICS,
    ORGANIZATION_TYPE_SERVICES,
  ];

  static final $core.Map<$core.int, OrganizationType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static OrganizationType? valueOf($core.int value) => _byValue[value];

  const OrganizationType._($core.int v, $core.String n) : super(v, n);
}

/// OrgUnitType defines the typed hierarchy under an organization.
class OrgUnitType extends $pb.ProtobufEnum {
  static const OrgUnitType ORG_UNIT_TYPE_UNSPECIFIED = OrgUnitType._(0, _omitEnumNames ? '' : 'ORG_UNIT_TYPE_UNSPECIFIED');
  static const OrgUnitType ORG_UNIT_TYPE_REGION = OrgUnitType._(1, _omitEnumNames ? '' : 'ORG_UNIT_TYPE_REGION');
  static const OrgUnitType ORG_UNIT_TYPE_ZONE = OrgUnitType._(2, _omitEnumNames ? '' : 'ORG_UNIT_TYPE_ZONE');
  static const OrgUnitType ORG_UNIT_TYPE_AREA = OrgUnitType._(3, _omitEnumNames ? '' : 'ORG_UNIT_TYPE_AREA');
  static const OrgUnitType ORG_UNIT_TYPE_CLUSTER = OrgUnitType._(4, _omitEnumNames ? '' : 'ORG_UNIT_TYPE_CLUSTER');
  static const OrgUnitType ORG_UNIT_TYPE_BRANCH = OrgUnitType._(5, _omitEnumNames ? '' : 'ORG_UNIT_TYPE_BRANCH');
  static const OrgUnitType ORG_UNIT_TYPE_OTHER = OrgUnitType._(6, _omitEnumNames ? '' : 'ORG_UNIT_TYPE_OTHER');

  static const $core.List<OrgUnitType> values = <OrgUnitType> [
    ORG_UNIT_TYPE_UNSPECIFIED,
    ORG_UNIT_TYPE_REGION,
    ORG_UNIT_TYPE_ZONE,
    ORG_UNIT_TYPE_AREA,
    ORG_UNIT_TYPE_CLUSTER,
    ORG_UNIT_TYPE_BRANCH,
    ORG_UNIT_TYPE_OTHER,
  ];

  static final $core.Map<$core.int, OrgUnitType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static OrgUnitType? valueOf($core.int value) => _byValue[value];

  const OrgUnitType._($core.int v, $core.String n) : super(v, n);
}

/// DepartmentKind separates top-level functions from nested departments.
class DepartmentKind extends $pb.ProtobufEnum {
  static const DepartmentKind DEPARTMENT_KIND_UNSPECIFIED = DepartmentKind._(0, _omitEnumNames ? '' : 'DEPARTMENT_KIND_UNSPECIFIED');
  static const DepartmentKind DEPARTMENT_KIND_FUNCTION = DepartmentKind._(1, _omitEnumNames ? '' : 'DEPARTMENT_KIND_FUNCTION');
  static const DepartmentKind DEPARTMENT_KIND_DEPARTMENT = DepartmentKind._(2, _omitEnumNames ? '' : 'DEPARTMENT_KIND_DEPARTMENT');

  static const $core.List<DepartmentKind> values = <DepartmentKind> [
    DEPARTMENT_KIND_UNSPECIFIED,
    DEPARTMENT_KIND_FUNCTION,
    DEPARTMENT_KIND_DEPARTMENT,
  ];

  static final $core.Map<$core.int, DepartmentKind> _byValue = $pb.ProtobufEnum.initByValue(values);
  static DepartmentKind? valueOf($core.int value) => _byValue[value];

  const DepartmentKind._($core.int v, $core.String n) : super(v, n);
}

/// AccessScopeType defines the resource scope of an access role assignment.
class AccessScopeType extends $pb.ProtobufEnum {
  static const AccessScopeType ACCESS_SCOPE_TYPE_UNSPECIFIED = AccessScopeType._(0, _omitEnumNames ? '' : 'ACCESS_SCOPE_TYPE_UNSPECIFIED');
  static const AccessScopeType ACCESS_SCOPE_TYPE_GLOBAL = AccessScopeType._(1, _omitEnumNames ? '' : 'ACCESS_SCOPE_TYPE_GLOBAL');
  static const AccessScopeType ACCESS_SCOPE_TYPE_ORGANIZATION = AccessScopeType._(2, _omitEnumNames ? '' : 'ACCESS_SCOPE_TYPE_ORGANIZATION');
  static const AccessScopeType ACCESS_SCOPE_TYPE_ORG_UNIT = AccessScopeType._(3, _omitEnumNames ? '' : 'ACCESS_SCOPE_TYPE_ORG_UNIT');
  static const AccessScopeType ACCESS_SCOPE_TYPE_TEAM = AccessScopeType._(4, _omitEnumNames ? '' : 'ACCESS_SCOPE_TYPE_TEAM');

  static const $core.List<AccessScopeType> values = <AccessScopeType> [
    ACCESS_SCOPE_TYPE_UNSPECIFIED,
    ACCESS_SCOPE_TYPE_GLOBAL,
    ACCESS_SCOPE_TYPE_ORGANIZATION,
    ACCESS_SCOPE_TYPE_ORG_UNIT,
    ACCESS_SCOPE_TYPE_TEAM,
  ];

  static final $core.Map<$core.int, AccessScopeType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AccessScopeType? valueOf($core.int value) => _byValue[value];

  const AccessScopeType._($core.int v, $core.String n) : super(v, n);
}

/// DataVerificationStatus tracks the verification lifecycle of client KYC data.
class DataVerificationStatus extends $pb.ProtobufEnum {
  static const DataVerificationStatus DATA_VERIFICATION_STATUS_UNSPECIFIED = DataVerificationStatus._(0, _omitEnumNames ? '' : 'DATA_VERIFICATION_STATUS_UNSPECIFIED');
  static const DataVerificationStatus DATA_VERIFICATION_STATUS_COLLECTED = DataVerificationStatus._(1, _omitEnumNames ? '' : 'DATA_VERIFICATION_STATUS_COLLECTED');
  static const DataVerificationStatus DATA_VERIFICATION_STATUS_UNDER_REVIEW = DataVerificationStatus._(2, _omitEnumNames ? '' : 'DATA_VERIFICATION_STATUS_UNDER_REVIEW');
  static const DataVerificationStatus DATA_VERIFICATION_STATUS_VERIFIED = DataVerificationStatus._(3, _omitEnumNames ? '' : 'DATA_VERIFICATION_STATUS_VERIFIED');
  static const DataVerificationStatus DATA_VERIFICATION_STATUS_REJECTED = DataVerificationStatus._(4, _omitEnumNames ? '' : 'DATA_VERIFICATION_STATUS_REJECTED');
  static const DataVerificationStatus DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED = DataVerificationStatus._(5, _omitEnumNames ? '' : 'DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED');
  static const DataVerificationStatus DATA_VERIFICATION_STATUS_EXPIRED = DataVerificationStatus._(6, _omitEnumNames ? '' : 'DATA_VERIFICATION_STATUS_EXPIRED');

  static const $core.List<DataVerificationStatus> values = <DataVerificationStatus> [
    DATA_VERIFICATION_STATUS_UNSPECIFIED,
    DATA_VERIFICATION_STATUS_COLLECTED,
    DATA_VERIFICATION_STATUS_UNDER_REVIEW,
    DATA_VERIFICATION_STATUS_VERIFIED,
    DATA_VERIFICATION_STATUS_REJECTED,
    DATA_VERIFICATION_STATUS_MORE_INFO_NEEDED,
    DATA_VERIFICATION_STATUS_EXPIRED,
  ];

  static final $core.Map<$core.int, DataVerificationStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static DataVerificationStatus? valueOf($core.int value) => _byValue[value];

  const DataVerificationStatus._($core.int v, $core.String n) : super(v, n);
}

/// FormFieldType defines the type of a form field.
class FormFieldType extends $pb.ProtobufEnum {
  static const FormFieldType FORM_FIELD_TYPE_UNSPECIFIED = FormFieldType._(0, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_UNSPECIFIED');
  static const FormFieldType FORM_FIELD_TYPE_TEXT = FormFieldType._(1, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_TEXT');
  static const FormFieldType FORM_FIELD_TYPE_NUMBER = FormFieldType._(2, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_NUMBER');
  static const FormFieldType FORM_FIELD_TYPE_CURRENCY = FormFieldType._(3, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_CURRENCY');
  static const FormFieldType FORM_FIELD_TYPE_PHONE = FormFieldType._(4, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_PHONE');
  static const FormFieldType FORM_FIELD_TYPE_EMAIL = FormFieldType._(5, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_EMAIL');
  static const FormFieldType FORM_FIELD_TYPE_DATE = FormFieldType._(6, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_DATE');
  static const FormFieldType FORM_FIELD_TYPE_SELECT = FormFieldType._(7, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_SELECT');
  static const FormFieldType FORM_FIELD_TYPE_MULTI_SELECT = FormFieldType._(8, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_MULTI_SELECT');
  static const FormFieldType FORM_FIELD_TYPE_PHOTO = FormFieldType._(9, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_PHOTO');
  static const FormFieldType FORM_FIELD_TYPE_FILE = FormFieldType._(10, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_FILE');
  static const FormFieldType FORM_FIELD_TYPE_LOCATION = FormFieldType._(11, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_LOCATION');
  static const FormFieldType FORM_FIELD_TYPE_SIGNATURE = FormFieldType._(12, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_SIGNATURE');
  static const FormFieldType FORM_FIELD_TYPE_CHECKBOX = FormFieldType._(13, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_CHECKBOX');
  static const FormFieldType FORM_FIELD_TYPE_TEXTAREA = FormFieldType._(14, _omitEnumNames ? '' : 'FORM_FIELD_TYPE_TEXTAREA');

  static const $core.List<FormFieldType> values = <FormFieldType> [
    FORM_FIELD_TYPE_UNSPECIFIED,
    FORM_FIELD_TYPE_TEXT,
    FORM_FIELD_TYPE_NUMBER,
    FORM_FIELD_TYPE_CURRENCY,
    FORM_FIELD_TYPE_PHONE,
    FORM_FIELD_TYPE_EMAIL,
    FORM_FIELD_TYPE_DATE,
    FORM_FIELD_TYPE_SELECT,
    FORM_FIELD_TYPE_MULTI_SELECT,
    FORM_FIELD_TYPE_PHOTO,
    FORM_FIELD_TYPE_FILE,
    FORM_FIELD_TYPE_LOCATION,
    FORM_FIELD_TYPE_SIGNATURE,
    FORM_FIELD_TYPE_CHECKBOX,
    FORM_FIELD_TYPE_TEXTAREA,
  ];

  static final $core.Map<$core.int, FormFieldType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static FormFieldType? valueOf($core.int value) => _byValue[value];

  const FormFieldType._($core.int v, $core.String n) : super(v, n);
}

/// FormFieldGroup categorizes fields for display and encryption.
class FormFieldGroup extends $pb.ProtobufEnum {
  static const FormFieldGroup FORM_FIELD_GROUP_UNSPECIFIED = FormFieldGroup._(0, _omitEnumNames ? '' : 'FORM_FIELD_GROUP_UNSPECIFIED');
  static const FormFieldGroup FORM_FIELD_GROUP_PERSONAL = FormFieldGroup._(1, _omitEnumNames ? '' : 'FORM_FIELD_GROUP_PERSONAL');
  static const FormFieldGroup FORM_FIELD_GROUP_FINANCIAL = FormFieldGroup._(2, _omitEnumNames ? '' : 'FORM_FIELD_GROUP_FINANCIAL');
  static const FormFieldGroup FORM_FIELD_GROUP_LEGAL = FormFieldGroup._(3, _omitEnumNames ? '' : 'FORM_FIELD_GROUP_LEGAL');
  static const FormFieldGroup FORM_FIELD_GROUP_DOCUMENTS = FormFieldGroup._(4, _omitEnumNames ? '' : 'FORM_FIELD_GROUP_DOCUMENTS');
  static const FormFieldGroup FORM_FIELD_GROUP_LOCATION = FormFieldGroup._(5, _omitEnumNames ? '' : 'FORM_FIELD_GROUP_LOCATION');

  static const $core.List<FormFieldGroup> values = <FormFieldGroup> [
    FORM_FIELD_GROUP_UNSPECIFIED,
    FORM_FIELD_GROUP_PERSONAL,
    FORM_FIELD_GROUP_FINANCIAL,
    FORM_FIELD_GROUP_LEGAL,
    FORM_FIELD_GROUP_DOCUMENTS,
    FORM_FIELD_GROUP_LOCATION,
  ];

  static final $core.Map<$core.int, FormFieldGroup> _byValue = $pb.ProtobufEnum.initByValue(values);
  static FormFieldGroup? valueOf($core.int value) => _byValue[value];

  const FormFieldGroup._($core.int v, $core.String n) : super(v, n);
}

/// FormTemplateStatus defines the lifecycle state of a form template.
class FormTemplateStatus extends $pb.ProtobufEnum {
  static const FormTemplateStatus FORM_TEMPLATE_STATUS_UNSPECIFIED = FormTemplateStatus._(0, _omitEnumNames ? '' : 'FORM_TEMPLATE_STATUS_UNSPECIFIED');
  static const FormTemplateStatus FORM_TEMPLATE_STATUS_DRAFT = FormTemplateStatus._(1, _omitEnumNames ? '' : 'FORM_TEMPLATE_STATUS_DRAFT');
  static const FormTemplateStatus FORM_TEMPLATE_STATUS_PUBLISHED = FormTemplateStatus._(2, _omitEnumNames ? '' : 'FORM_TEMPLATE_STATUS_PUBLISHED');
  static const FormTemplateStatus FORM_TEMPLATE_STATUS_ARCHIVED = FormTemplateStatus._(3, _omitEnumNames ? '' : 'FORM_TEMPLATE_STATUS_ARCHIVED');

  static const $core.List<FormTemplateStatus> values = <FormTemplateStatus> [
    FORM_TEMPLATE_STATUS_UNSPECIFIED,
    FORM_TEMPLATE_STATUS_DRAFT,
    FORM_TEMPLATE_STATUS_PUBLISHED,
    FORM_TEMPLATE_STATUS_ARCHIVED,
  ];

  static final $core.Map<$core.int, FormTemplateStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static FormTemplateStatus? valueOf($core.int value) => _byValue[value];

  const FormTemplateStatus._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
