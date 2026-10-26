// This is a generated file - do not edit.
//
// Generated from limits/v1/limits.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class LimitAction extends $pb.ProtobufEnum {
  static const LimitAction LIMIT_ACTION_UNSPECIFIED =
      LimitAction._(0, _omitEnumNames ? '' : 'LIMIT_ACTION_UNSPECIFIED');
  static const LimitAction LIMIT_ACTION_LOAN_DISBURSEMENT =
      LimitAction._(1, _omitEnumNames ? '' : 'LIMIT_ACTION_LOAN_DISBURSEMENT');
  static const LimitAction LIMIT_ACTION_LOAN_REQUEST =
      LimitAction._(2, _omitEnumNames ? '' : 'LIMIT_ACTION_LOAN_REQUEST');
  static const LimitAction LIMIT_ACTION_LOAN_REPAYMENT =
      LimitAction._(3, _omitEnumNames ? '' : 'LIMIT_ACTION_LOAN_REPAYMENT');
  static const LimitAction LIMIT_ACTION_SAVINGS_DEPOSIT =
      LimitAction._(4, _omitEnumNames ? '' : 'LIMIT_ACTION_SAVINGS_DEPOSIT');
  static const LimitAction LIMIT_ACTION_SAVINGS_WITHDRAWAL =
      LimitAction._(5, _omitEnumNames ? '' : 'LIMIT_ACTION_SAVINGS_WITHDRAWAL');
  static const LimitAction LIMIT_ACTION_TRANSFER_ORDER_EXECUTE = LimitAction._(
      6, _omitEnumNames ? '' : 'LIMIT_ACTION_TRANSFER_ORDER_EXECUTE');
  static const LimitAction LIMIT_ACTION_INCOMING_PAYMENT =
      LimitAction._(7, _omitEnumNames ? '' : 'LIMIT_ACTION_INCOMING_PAYMENT');
  static const LimitAction LIMIT_ACTION_FUNDING_INFLOW =
      LimitAction._(8, _omitEnumNames ? '' : 'LIMIT_ACTION_FUNDING_INFLOW');
  static const LimitAction LIMIT_ACTION_FUNDING_OUTFLOW =
      LimitAction._(9, _omitEnumNames ? '' : 'LIMIT_ACTION_FUNDING_OUTFLOW');
  static const LimitAction LIMIT_ACTION_STAWI_CONTRIBUTION = LimitAction._(
      10, _omitEnumNames ? '' : 'LIMIT_ACTION_STAWI_CONTRIBUTION');
  static const LimitAction LIMIT_ACTION_STAWI_PAYOUT =
      LimitAction._(11, _omitEnumNames ? '' : 'LIMIT_ACTION_STAWI_PAYOUT');

  static const $core.List<LimitAction> values = <LimitAction>[
    LIMIT_ACTION_UNSPECIFIED,
    LIMIT_ACTION_LOAN_DISBURSEMENT,
    LIMIT_ACTION_LOAN_REQUEST,
    LIMIT_ACTION_LOAN_REPAYMENT,
    LIMIT_ACTION_SAVINGS_DEPOSIT,
    LIMIT_ACTION_SAVINGS_WITHDRAWAL,
    LIMIT_ACTION_TRANSFER_ORDER_EXECUTE,
    LIMIT_ACTION_INCOMING_PAYMENT,
    LIMIT_ACTION_FUNDING_INFLOW,
    LIMIT_ACTION_FUNDING_OUTFLOW,
    LIMIT_ACTION_STAWI_CONTRIBUTION,
    LIMIT_ACTION_STAWI_PAYOUT,
  ];

  static final $core.List<LimitAction?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 11);
  static LimitAction? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LimitAction._(super.value, super.name);
}

class SubjectType extends $pb.ProtobufEnum {
  static const SubjectType SUBJECT_TYPE_UNSPECIFIED =
      SubjectType._(0, _omitEnumNames ? '' : 'SUBJECT_TYPE_UNSPECIFIED');
  static const SubjectType SUBJECT_TYPE_CLIENT =
      SubjectType._(1, _omitEnumNames ? '' : 'SUBJECT_TYPE_CLIENT');
  static const SubjectType SUBJECT_TYPE_ACCOUNT =
      SubjectType._(2, _omitEnumNames ? '' : 'SUBJECT_TYPE_ACCOUNT');
  static const SubjectType SUBJECT_TYPE_PRODUCT =
      SubjectType._(3, _omitEnumNames ? '' : 'SUBJECT_TYPE_PRODUCT');
  static const SubjectType SUBJECT_TYPE_ORGANIZATION =
      SubjectType._(4, _omitEnumNames ? '' : 'SUBJECT_TYPE_ORGANIZATION');
  static const SubjectType SUBJECT_TYPE_ORG_UNIT =
      SubjectType._(5, _omitEnumNames ? '' : 'SUBJECT_TYPE_ORG_UNIT');
  static const SubjectType SUBJECT_TYPE_WORKFORCE_MEMBER =
      SubjectType._(6, _omitEnumNames ? '' : 'SUBJECT_TYPE_WORKFORCE_MEMBER');

  static const $core.List<SubjectType> values = <SubjectType>[
    SUBJECT_TYPE_UNSPECIFIED,
    SUBJECT_TYPE_CLIENT,
    SUBJECT_TYPE_ACCOUNT,
    SUBJECT_TYPE_PRODUCT,
    SUBJECT_TYPE_ORGANIZATION,
    SUBJECT_TYPE_ORG_UNIT,
    SUBJECT_TYPE_WORKFORCE_MEMBER,
  ];

  static final $core.List<SubjectType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static SubjectType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SubjectType._(super.value, super.name);
}

class LimitKind extends $pb.ProtobufEnum {
  static const LimitKind LIMIT_KIND_UNSPECIFIED =
      LimitKind._(0, _omitEnumNames ? '' : 'LIMIT_KIND_UNSPECIFIED');
  static const LimitKind LIMIT_KIND_PER_TXN_MIN =
      LimitKind._(1, _omitEnumNames ? '' : 'LIMIT_KIND_PER_TXN_MIN');
  static const LimitKind LIMIT_KIND_PER_TXN_MAX =
      LimitKind._(2, _omitEnumNames ? '' : 'LIMIT_KIND_PER_TXN_MAX');
  static const LimitKind LIMIT_KIND_ROLLING_WINDOW_AMOUNT =
      LimitKind._(3, _omitEnumNames ? '' : 'LIMIT_KIND_ROLLING_WINDOW_AMOUNT');
  static const LimitKind LIMIT_KIND_ROLLING_WINDOW_COUNT =
      LimitKind._(4, _omitEnumNames ? '' : 'LIMIT_KIND_ROLLING_WINDOW_COUNT');

  static const $core.List<LimitKind> values = <LimitKind>[
    LIMIT_KIND_UNSPECIFIED,
    LIMIT_KIND_PER_TXN_MIN,
    LIMIT_KIND_PER_TXN_MAX,
    LIMIT_KIND_ROLLING_WINDOW_AMOUNT,
    LIMIT_KIND_ROLLING_WINDOW_COUNT,
  ];

  static final $core.List<LimitKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static LimitKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LimitKind._(super.value, super.name);
}

class PolicyMode extends $pb.ProtobufEnum {
  static const PolicyMode POLICY_MODE_UNSPECIFIED =
      PolicyMode._(0, _omitEnumNames ? '' : 'POLICY_MODE_UNSPECIFIED');
  static const PolicyMode POLICY_MODE_OFF =
      PolicyMode._(1, _omitEnumNames ? '' : 'POLICY_MODE_OFF');
  static const PolicyMode POLICY_MODE_SHADOW =
      PolicyMode._(2, _omitEnumNames ? '' : 'POLICY_MODE_SHADOW');
  static const PolicyMode POLICY_MODE_ENFORCE =
      PolicyMode._(3, _omitEnumNames ? '' : 'POLICY_MODE_ENFORCE');

  static const $core.List<PolicyMode> values = <PolicyMode>[
    POLICY_MODE_UNSPECIFIED,
    POLICY_MODE_OFF,
    POLICY_MODE_SHADOW,
    POLICY_MODE_ENFORCE,
  ];

  static final $core.List<PolicyMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static PolicyMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PolicyMode._(super.value, super.name);
}

class PolicyScope extends $pb.ProtobufEnum {
  static const PolicyScope POLICY_SCOPE_UNSPECIFIED =
      PolicyScope._(0, _omitEnumNames ? '' : 'POLICY_SCOPE_UNSPECIFIED');
  static const PolicyScope POLICY_SCOPE_PLATFORM =
      PolicyScope._(1, _omitEnumNames ? '' : 'POLICY_SCOPE_PLATFORM');
  static const PolicyScope POLICY_SCOPE_ORG =
      PolicyScope._(2, _omitEnumNames ? '' : 'POLICY_SCOPE_ORG');
  static const PolicyScope POLICY_SCOPE_ORG_UNIT =
      PolicyScope._(3, _omitEnumNames ? '' : 'POLICY_SCOPE_ORG_UNIT');

  static const $core.List<PolicyScope> values = <PolicyScope>[
    POLICY_SCOPE_UNSPECIFIED,
    POLICY_SCOPE_PLATFORM,
    POLICY_SCOPE_ORG,
    POLICY_SCOPE_ORG_UNIT,
  ];

  static final $core.List<PolicyScope?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static PolicyScope? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PolicyScope._(super.value, super.name);
}

class ReservationStatus extends $pb.ProtobufEnum {
  static const ReservationStatus RESERVATION_STATUS_UNSPECIFIED =
      ReservationStatus._(
          0, _omitEnumNames ? '' : 'RESERVATION_STATUS_UNSPECIFIED');
  static const ReservationStatus RESERVATION_STATUS_ACTIVE =
      ReservationStatus._(1, _omitEnumNames ? '' : 'RESERVATION_STATUS_ACTIVE');
  static const ReservationStatus RESERVATION_STATUS_PENDING_APPROVAL =
      ReservationStatus._(
          2, _omitEnumNames ? '' : 'RESERVATION_STATUS_PENDING_APPROVAL');
  static const ReservationStatus RESERVATION_STATUS_COMMITTED =
      ReservationStatus._(
          3, _omitEnumNames ? '' : 'RESERVATION_STATUS_COMMITTED');
  static const ReservationStatus RESERVATION_STATUS_RELEASED =
      ReservationStatus._(
          4, _omitEnumNames ? '' : 'RESERVATION_STATUS_RELEASED');
  static const ReservationStatus RESERVATION_STATUS_REVERSED =
      ReservationStatus._(
          5, _omitEnumNames ? '' : 'RESERVATION_STATUS_REVERSED');
  static const ReservationStatus RESERVATION_STATUS_EXPIRED =
      ReservationStatus._(
          6, _omitEnumNames ? '' : 'RESERVATION_STATUS_EXPIRED');

  static const $core.List<ReservationStatus> values = <ReservationStatus>[
    RESERVATION_STATUS_UNSPECIFIED,
    RESERVATION_STATUS_ACTIVE,
    RESERVATION_STATUS_PENDING_APPROVAL,
    RESERVATION_STATUS_COMMITTED,
    RESERVATION_STATUS_RELEASED,
    RESERVATION_STATUS_REVERSED,
    RESERVATION_STATUS_EXPIRED,
  ];

  static final $core.List<ReservationStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static ReservationStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ReservationStatus._(super.value, super.name);
}

class ApprovalStatus extends $pb.ProtobufEnum {
  static const ApprovalStatus APPROVAL_STATUS_UNSPECIFIED =
      ApprovalStatus._(0, _omitEnumNames ? '' : 'APPROVAL_STATUS_UNSPECIFIED');
  static const ApprovalStatus APPROVAL_STATUS_PENDING =
      ApprovalStatus._(1, _omitEnumNames ? '' : 'APPROVAL_STATUS_PENDING');
  static const ApprovalStatus APPROVAL_STATUS_APPROVED =
      ApprovalStatus._(2, _omitEnumNames ? '' : 'APPROVAL_STATUS_APPROVED');
  static const ApprovalStatus APPROVAL_STATUS_REJECTED =
      ApprovalStatus._(3, _omitEnumNames ? '' : 'APPROVAL_STATUS_REJECTED');
  static const ApprovalStatus APPROVAL_STATUS_EXPIRED =
      ApprovalStatus._(4, _omitEnumNames ? '' : 'APPROVAL_STATUS_EXPIRED');
  static const ApprovalStatus APPROVAL_STATUS_AUTO_REJECTED_ON_RECHECK =
      ApprovalStatus._(
          5, _omitEnumNames ? '' : 'APPROVAL_STATUS_AUTO_REJECTED_ON_RECHECK');

  static const $core.List<ApprovalStatus> values = <ApprovalStatus>[
    APPROVAL_STATUS_UNSPECIFIED,
    APPROVAL_STATUS_PENDING,
    APPROVAL_STATUS_APPROVED,
    APPROVAL_STATUS_REJECTED,
    APPROVAL_STATUS_EXPIRED,
    APPROVAL_STATUS_AUTO_REJECTED_ON_RECHECK,
  ];

  static final $core.List<ApprovalStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ApprovalStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ApprovalStatus._(super.value, super.name);
}

/// LimitsJob names the periodic work the scheduler asks limits to do.
class LimitsJob extends $pb.ProtobufEnum {
  static const LimitsJob LIMITS_JOB_UNSPECIFIED =
      LimitsJob._(0, _omitEnumNames ? '' : 'LIMITS_JOB_UNSPECIFIED');

  /// Expires active reservations past their deadline, returning their hold.
  static const LimitsJob LIMITS_JOB_RESERVATION_EXPIRY =
      LimitsJob._(1, _omitEnumNames ? '' : 'LIMITS_JOB_RESERVATION_EXPIRY');

  /// Expires approval requests nobody decided in time.
  static const LimitsJob LIMITS_JOB_APPROVAL_EXPIRY =
      LimitsJob._(2, _omitEnumNames ? '' : 'LIMITS_JOB_APPROVAL_EXPIRY');

  static const $core.List<LimitsJob> values = <LimitsJob>[
    LIMITS_JOB_UNSPECIFIED,
    LIMITS_JOB_RESERVATION_EXPIRY,
    LIMITS_JOB_APPROVAL_EXPIRY,
  ];

  static final $core.List<LimitsJob?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static LimitsJob? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LimitsJob._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
