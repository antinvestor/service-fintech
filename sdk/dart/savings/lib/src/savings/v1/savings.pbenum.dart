//
//  Generated code. Do not modify.
//  source: savings/v1/savings.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// SavingsPeriodType defines the savings collection frequency.
class SavingsPeriodType extends $pb.ProtobufEnum {
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_UNSPECIFIED = SavingsPeriodType._(0, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_UNSPECIFIED');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_DAILY = SavingsPeriodType._(1, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_DAILY');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_WEEKLY = SavingsPeriodType._(2, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_WEEKLY');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_BIWEEKLY = SavingsPeriodType._(3, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_BIWEEKLY');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_MONTHLY = SavingsPeriodType._(4, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_MONTHLY');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_QUARTERLY = SavingsPeriodType._(5, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_QUARTERLY');
  static const SavingsPeriodType SAVINGS_PERIOD_TYPE_ANNUALLY = SavingsPeriodType._(6, _omitEnumNames ? '' : 'SAVINGS_PERIOD_TYPE_ANNUALLY');

  static const $core.List<SavingsPeriodType> values = <SavingsPeriodType> [
    SAVINGS_PERIOD_TYPE_UNSPECIFIED,
    SAVINGS_PERIOD_TYPE_DAILY,
    SAVINGS_PERIOD_TYPE_WEEKLY,
    SAVINGS_PERIOD_TYPE_BIWEEKLY,
    SAVINGS_PERIOD_TYPE_MONTHLY,
    SAVINGS_PERIOD_TYPE_QUARTERLY,
    SAVINGS_PERIOD_TYPE_ANNUALLY,
  ];

  static final $core.Map<$core.int, SavingsPeriodType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SavingsPeriodType? valueOf($core.int value) => _byValue[value];

  const SavingsPeriodType._($core.int v, $core.String n) : super(v, n);
}

/// CompoundingFrequency defines how often interest is compounded.
class CompoundingFrequency extends $pb.ProtobufEnum {
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_UNSPECIFIED = CompoundingFrequency._(0, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_UNSPECIFIED');
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_DAILY = CompoundingFrequency._(1, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_DAILY');
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_WEEKLY = CompoundingFrequency._(2, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_WEEKLY');
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_MONTHLY = CompoundingFrequency._(3, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_MONTHLY');
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_QUARTERLY = CompoundingFrequency._(4, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_QUARTERLY');
  static const CompoundingFrequency COMPOUNDING_FREQUENCY_ANNUALLY = CompoundingFrequency._(5, _omitEnumNames ? '' : 'COMPOUNDING_FREQUENCY_ANNUALLY');

  static const $core.List<CompoundingFrequency> values = <CompoundingFrequency> [
    COMPOUNDING_FREQUENCY_UNSPECIFIED,
    COMPOUNDING_FREQUENCY_DAILY,
    COMPOUNDING_FREQUENCY_WEEKLY,
    COMPOUNDING_FREQUENCY_MONTHLY,
    COMPOUNDING_FREQUENCY_QUARTERLY,
    COMPOUNDING_FREQUENCY_ANNUALLY,
  ];

  static final $core.Map<$core.int, CompoundingFrequency> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CompoundingFrequency? valueOf($core.int value) => _byValue[value];

  const CompoundingFrequency._($core.int v, $core.String n) : super(v, n);
}

/// SavingsAccountOwnerType defines the type of account owner.
class SavingsAccountOwnerType extends $pb.ProtobufEnum {
  static const SavingsAccountOwnerType SAVINGS_ACCOUNT_OWNER_TYPE_UNSPECIFIED = SavingsAccountOwnerType._(0, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_OWNER_TYPE_UNSPECIFIED');
  static const SavingsAccountOwnerType SAVINGS_ACCOUNT_OWNER_TYPE_INDIVIDUAL = SavingsAccountOwnerType._(1, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_OWNER_TYPE_INDIVIDUAL');
  static const SavingsAccountOwnerType SAVINGS_ACCOUNT_OWNER_TYPE_GROUP = SavingsAccountOwnerType._(2, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_OWNER_TYPE_GROUP');

  static const $core.List<SavingsAccountOwnerType> values = <SavingsAccountOwnerType> [
    SAVINGS_ACCOUNT_OWNER_TYPE_UNSPECIFIED,
    SAVINGS_ACCOUNT_OWNER_TYPE_INDIVIDUAL,
    SAVINGS_ACCOUNT_OWNER_TYPE_GROUP,
  ];

  static final $core.Map<$core.int, SavingsAccountOwnerType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SavingsAccountOwnerType? valueOf($core.int value) => _byValue[value];

  const SavingsAccountOwnerType._($core.int v, $core.String n) : super(v, n);
}

/// SavingsAccountStatus defines the status of a savings account.
class SavingsAccountStatus extends $pb.ProtobufEnum {
  static const SavingsAccountStatus SAVINGS_ACCOUNT_STATUS_UNSPECIFIED = SavingsAccountStatus._(0, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_STATUS_UNSPECIFIED');
  static const SavingsAccountStatus SAVINGS_ACCOUNT_STATUS_ACTIVE = SavingsAccountStatus._(1, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_STATUS_ACTIVE');
  static const SavingsAccountStatus SAVINGS_ACCOUNT_STATUS_FROZEN = SavingsAccountStatus._(2, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_STATUS_FROZEN');
  static const SavingsAccountStatus SAVINGS_ACCOUNT_STATUS_CLOSED = SavingsAccountStatus._(3, _omitEnumNames ? '' : 'SAVINGS_ACCOUNT_STATUS_CLOSED');

  static const $core.List<SavingsAccountStatus> values = <SavingsAccountStatus> [
    SAVINGS_ACCOUNT_STATUS_UNSPECIFIED,
    SAVINGS_ACCOUNT_STATUS_ACTIVE,
    SAVINGS_ACCOUNT_STATUS_FROZEN,
    SAVINGS_ACCOUNT_STATUS_CLOSED,
  ];

  static final $core.Map<$core.int, SavingsAccountStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SavingsAccountStatus? valueOf($core.int value) => _byValue[value];

  const SavingsAccountStatus._($core.int v, $core.String n) : super(v, n);
}

/// DepositStatus defines the status of a deposit.
class DepositStatus extends $pb.ProtobufEnum {
  static const DepositStatus DEPOSIT_STATUS_UNSPECIFIED = DepositStatus._(0, _omitEnumNames ? '' : 'DEPOSIT_STATUS_UNSPECIFIED');
  static const DepositStatus DEPOSIT_STATUS_PENDING = DepositStatus._(1, _omitEnumNames ? '' : 'DEPOSIT_STATUS_PENDING');
  static const DepositStatus DEPOSIT_STATUS_COMPLETED = DepositStatus._(2, _omitEnumNames ? '' : 'DEPOSIT_STATUS_COMPLETED');
  static const DepositStatus DEPOSIT_STATUS_REVERSED = DepositStatus._(3, _omitEnumNames ? '' : 'DEPOSIT_STATUS_REVERSED');

  static const $core.List<DepositStatus> values = <DepositStatus> [
    DEPOSIT_STATUS_UNSPECIFIED,
    DEPOSIT_STATUS_PENDING,
    DEPOSIT_STATUS_COMPLETED,
    DEPOSIT_STATUS_REVERSED,
  ];

  static final $core.Map<$core.int, DepositStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static DepositStatus? valueOf($core.int value) => _byValue[value];

  const DepositStatus._($core.int v, $core.String n) : super(v, n);
}

/// WithdrawalStatus defines the status of a withdrawal.
class WithdrawalStatus extends $pb.ProtobufEnum {
  static const WithdrawalStatus WITHDRAWAL_STATUS_UNSPECIFIED = WithdrawalStatus._(0, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_UNSPECIFIED');
  static const WithdrawalStatus WITHDRAWAL_STATUS_PENDING = WithdrawalStatus._(1, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_PENDING');
  static const WithdrawalStatus WITHDRAWAL_STATUS_APPROVED = WithdrawalStatus._(2, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_APPROVED');
  static const WithdrawalStatus WITHDRAWAL_STATUS_COMPLETED = WithdrawalStatus._(3, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_COMPLETED');
  static const WithdrawalStatus WITHDRAWAL_STATUS_REJECTED = WithdrawalStatus._(4, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_REJECTED');
  static const WithdrawalStatus WITHDRAWAL_STATUS_REVERSED = WithdrawalStatus._(5, _omitEnumNames ? '' : 'WITHDRAWAL_STATUS_REVERSED');

  static const $core.List<WithdrawalStatus> values = <WithdrawalStatus> [
    WITHDRAWAL_STATUS_UNSPECIFIED,
    WITHDRAWAL_STATUS_PENDING,
    WITHDRAWAL_STATUS_APPROVED,
    WITHDRAWAL_STATUS_COMPLETED,
    WITHDRAWAL_STATUS_REJECTED,
    WITHDRAWAL_STATUS_REVERSED,
  ];

  static final $core.Map<$core.int, WithdrawalStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static WithdrawalStatus? valueOf($core.int value) => _byValue[value];

  const WithdrawalStatus._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
