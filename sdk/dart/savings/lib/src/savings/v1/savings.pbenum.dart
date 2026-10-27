// This is a generated file - do not edit.
//
// Generated from savings/v1/savings.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// SavingsPeriodType defines the savings collection frequency.
class SavingsPeriodType extends $pb.ProtobufEnum {
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_UNSPECIFIED =
      SavingsPeriodType._(
          0, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_UNSPECIFIED');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_DAILY =
      SavingsPeriodType._(1, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_DAILY');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_WEEKLY =
      SavingsPeriodType._(
          2, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_WEEKLY');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_BIWEEKLY =
      SavingsPeriodType._(
          3, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_BIWEEKLY');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_MONTHLY =
      SavingsPeriodType._(
          4, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_MONTHLY');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_QUARTERLY =
      SavingsPeriodType._(
          5, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_QUARTERLY');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_ANNUALLY =
      SavingsPeriodType._(
          6, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_ANNUALLY');

  static const $core.List<SavingsPeriodType> values = <SavingsPeriodType>[
    SAVINGS_PERIOD_TYPE_UNSPECIFIED,
    SAVINGS_PERIOD_TYPE_DAILY,
    SAVINGS_PERIOD_TYPE_WEEKLY,
    SAVINGS_PERIOD_TYPE_BIWEEKLY,
    SAVINGS_PERIOD_TYPE_MONTHLY,
    SAVINGS_PERIOD_TYPE_QUARTERLY,
    SAVINGS_PERIOD_TYPE_ANNUALLY,
  ];

  static final $core.List<SavingsPeriodType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static SavingsPeriodType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SavingsPeriodType._(super.value, super.name);
}

/// CompoundingFrequency defines how often interest is compounded.
class CompoundingFrequency extends $pb.ProtobufEnum {
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_UNSPECIFIED =
      CompoundingFrequency._(
          0, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_UNSPECIFIED');
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_DAILY =
      CompoundingFrequency._(
          1, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_DAILY');
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_WEEKLY =
      CompoundingFrequency._(
          2, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_WEEKLY');
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_MONTHLY =
      CompoundingFrequency._(
          3, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_MONTHLY');
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_QUARTERLY =
      CompoundingFrequency._(
          4, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_QUARTERLY');
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_ANNUALLY =
      CompoundingFrequency._(
          5, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_ANNUALLY');

  static const $core.List<CompoundingFrequency> values = <CompoundingFrequency>[
    COMPOUNDING_FREQUENCY_UNSPECIFIED,
    COMPOUNDING_FREQUENCY_DAILY,
    COMPOUNDING_FREQUENCY_WEEKLY,
    COMPOUNDING_FREQUENCY_MONTHLY,
    COMPOUNDING_FREQUENCY_QUARTERLY,
    COMPOUNDING_FREQUENCY_ANNUALLY,
  ];

  static final $core.List<CompoundingFrequency?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static CompoundingFrequency? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CompoundingFrequency._(super.value, super.name);
}

/// SavingsAccountOwnerType defines the type of account owner.
class SavingsAccountOwnerType extends $pb.ProtobufEnum {
  static const SavingsAccountOwnerType SAVINGS_ACCOUNT_OWNER_TYPE_UNSPECIFIED =
      SavingsAccountOwnerType._(
          0, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_OWNER_TYPE_UNSPECIFIED');
  static const SavingsAccountOwnerType SAVINGS_ACCOUNT_OWNER_TYPE_INDIVIDUAL =
      SavingsAccountOwnerType._(
          1, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_OWNER_TYPE_INDIVIDUAL');
  static const SavingsAccountOwnerType SAVINGS_ACCOUNT_OWNER_TYPE_GROUP =
      SavingsAccountOwnerType._(
          2, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_OWNER_TYPE_GROUP');

  static const $core.List<SavingsAccountOwnerType> values =
      <SavingsAccountOwnerType>[
    SAVINGS_ACCOUNT_OWNER_TYPE_UNSPECIFIED,
    SAVINGS_ACCOUNT_OWNER_TYPE_INDIVIDUAL,
    SAVINGS_ACCOUNT_OWNER_TYPE_GROUP,
  ];

  static final $core.List<SavingsAccountOwnerType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SavingsAccountOwnerType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SavingsAccountOwnerType._(super.value, super.name);
}

/// SavingsAccountStatus defines the status of a savings account.
class SavingsAccountStatus extends $pb.ProtobufEnum {
  static const SavingsAccountStatus SAVINGS_ACCOUNT_STATUS_UNSPECIFIED =
      SavingsAccountStatus._(
          0, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_STATUS_UNSPECIFIED');
  static const SavingsAccountStatus SAVINGS_ACCOUNT_STATUS_ACTIVE =
      SavingsAccountStatus._(
          1, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_STATUS_ACTIVE');
  static const SavingsAccountStatus SAVINGS_ACCOUNT_STATUS_FROZEN =
      SavingsAccountStatus._(
          2, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_STATUS_FROZEN');
  static const SavingsAccountStatus SAVINGS_ACCOUNT_STATUS_CLOSED =
      SavingsAccountStatus._(
          3, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_STATUS_CLOSED');

  static const $core.List<SavingsAccountStatus> values = <SavingsAccountStatus>[
    SAVINGS_ACCOUNT_STATUS_UNSPECIFIED,
    SAVINGS_ACCOUNT_STATUS_ACTIVE,
    SAVINGS_ACCOUNT_STATUS_FROZEN,
    SAVINGS_ACCOUNT_STATUS_CLOSED,
  ];

  static final $core.List<SavingsAccountStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SavingsAccountStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SavingsAccountStatus._(super.value, super.name);
}

/// DepositStatus defines the status of a deposit.
class DepositStatus extends $pb.ProtobufEnum {
  static const DepositStatus DEPOSIT_STATUS_UNSPECIFIED =
      DepositStatus._(0, _omitEnumNames ? '' : 'DEPOSIT_STATUS_UNSPECIFIED');
  static const DepositStatus DEPOSIT_STATUS_PENDING =
      DepositStatus._(1, _omitEnumNames ? '' : 'DEPOSIT_STATUS_PENDING');
  static const DepositStatus DEPOSIT_STATUS_COMPLETED =
      DepositStatus._(2, _omitEnumNames ? '' : 'DEPOSIT_STATUS_COMPLETED');
  static const DepositStatus DEPOSIT_STATUS_REVERSED =
      DepositStatus._(3, _omitEnumNames ? '' : 'DEPOSIT_STATUS_REVERSED');

  static const $core.List<DepositStatus> values = <DepositStatus>[
    DEPOSIT_STATUS_UNSPECIFIED,
    DEPOSIT_STATUS_PENDING,
    DEPOSIT_STATUS_COMPLETED,
    DEPOSIT_STATUS_REVERSED,
  ];

  static final $core.List<DepositStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static DepositStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DepositStatus._(super.value, super.name);
}

/// WithdrawalStatus defines the status of a withdrawal.
class WithdrawalStatus extends $pb.ProtobufEnum {
  static const WithdrawalStatus WITHDRAWAL_STATUS_UNSPECIFIED =
      WithdrawalStatus._(
          0, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_UNSPECIFIED');
  static const WithdrawalStatus WITHDRAWAL_STATUS_PENDING =
      WithdrawalStatus._(1, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_PENDING');
  static const WithdrawalStatus WITHDRAWAL_STATUS_APPROVED =
      WithdrawalStatus._(2, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_APPROVED');
  static const WithdrawalStatus WITHDRAWAL_STATUS_COMPLETED =
      WithdrawalStatus._(
          3, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_COMPLETED');
  static const WithdrawalStatus WITHDRAWAL_STATUS_REJECTED =
      WithdrawalStatus._(4, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_REJECTED');
  static const WithdrawalStatus WITHDRAWAL_STATUS_REVERSED =
      WithdrawalStatus._(5, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_REVERSED');

  static const $core.List<WithdrawalStatus> values = <WithdrawalStatus>[
    WITHDRAWAL_STATUS_UNSPECIFIED,
    WITHDRAWAL_STATUS_PENDING,
    WITHDRAWAL_STATUS_APPROVED,
    WITHDRAWAL_STATUS_COMPLETED,
    WITHDRAWAL_STATUS_REJECTED,
    WITHDRAWAL_STATUS_REVERSED,
  ];

  static final $core.List<WithdrawalStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static WithdrawalStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const WithdrawalStatus._(super.value, super.name);
}

/// SavingsJob is a periodic job the platform scheduler runs.
class SavingsJob extends $pb.ProtobufEnum {
  static const SavingsJob SAVINGS_JOB_UNSPECIFIED =
      SavingsJob._(0, _omitEnumNames ? '' : 'SAVINGS_JOB_UNSPECIFIED');

  /// Accrues the most recently closed day's interest on active accounts not
  /// yet accrued for it.
  static const SavingsJob SAVINGS_JOB_ACCRUE_INTEREST =
      SavingsJob._(1, _omitEnumNames ? '' : 'SAVINGS_JOB_ACCRUE_INTEREST');

  static const $core.List<SavingsJob> values = <SavingsJob>[
    SAVINGS_JOB_UNSPECIFIED,
    SAVINGS_JOB_ACCRUE_INTEREST,
  ];

  static final $core.List<SavingsJob?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static SavingsJob? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SavingsJob._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
