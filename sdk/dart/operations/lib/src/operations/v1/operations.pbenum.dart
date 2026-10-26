// This is a generated file - do not edit.
//
// Generated from operations/v1/operations.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// TransferOrderType classifies a transfer order. The numeric values mirror
/// pkg/constants/transfer_types.go exactly so the enum and the legacy int32
/// order_type fields describe the same order; the int32 fields remain for
/// existing clients and are deprecated.
class TransferOrderType extends $pb.ProtobufEnum {
  static const TransferOrderType TRANSFER_ORDER_TYPE_UNSPECIFIED =
      TransferOrderType._(
          0, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_UNSPECIFIED');
  static const TransferOrderType TRANSFER_ORDER_TYPE_PAYMENT =
      TransferOrderType._(
          1, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_PAYMENT');
  static const TransferOrderType TRANSFER_ORDER_TYPE_PAYMENT_IDENTIFIED =
      TransferOrderType._(
          2, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_PAYMENT_IDENTIFIED');
  static const TransferOrderType TRANSFER_ORDER_TYPE_PAYMENT_ALLOCATED =
      TransferOrderType._(
          3, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_PAYMENT_ALLOCATED');
  static const TransferOrderType TRANSFER_ORDER_TYPE_DISBURSEMENT =
      TransferOrderType._(
          6, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_DISBURSEMENT');
  static const TransferOrderType TRANSFER_ORDER_TYPE_DISBURSEMENT_REVERSAL =
      TransferOrderType._(
          7, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_DISBURSEMENT_REVERSAL');
  static const TransferOrderType
      TRANSFER_ORDER_TYPE_DISBURSEMENT_REVERSAL_REROUTE = TransferOrderType._(
          8,
          _omitEnumNames
              ? ''
              : 'TRANSFER_ORDER_TYPE_DISBURSEMENT_REVERSAL_REROUTE');
  static const TransferOrderType TRANSFER_ORDER_TYPE_TERMINAL_DISBURSEMENT =
      TransferOrderType._(
          9, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_TERMINAL_DISBURSEMENT');
  static const TransferOrderType
      TRANSFER_ORDER_TYPE_TERMINAL_DISBURSEMENT_RECOVERY = TransferOrderType._(
          10,
          _omitEnumNames
              ? ''
              : 'TRANSFER_ORDER_TYPE_TERMINAL_DISBURSEMENT_RECOVERY');
  static const TransferOrderType TRANSFER_ORDER_TYPE_COST =
      TransferOrderType._(11, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_COST');
  static const TransferOrderType TRANSFER_ORDER_TYPE_SERVICE_FEE =
      TransferOrderType._(
          16, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_SERVICE_FEE');
  static const TransferOrderType TRANSFER_ORDER_TYPE_REGISTRATION_FEE =
      TransferOrderType._(
          21, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_REGISTRATION_FEE');
  static const TransferOrderType TRANSFER_ORDER_TYPE_PERIODIC_SAVING =
      TransferOrderType._(
          25, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_PERIODIC_SAVING');
  static const TransferOrderType
      TRANSFER_ORDER_TYPE_PERIODIC_SAVINGS_INTEREST_INCOME_DISTRIBUTION =
      TransferOrderType._(
          26,
          _omitEnumNames
              ? ''
              : 'TRANSFER_ORDER_TYPE_PERIODIC_SAVINGS_INTEREST_INCOME_DISTRIBUTION');
  static const TransferOrderType TRANSFER_ORDER_TYPE_PERIODIC_SAVING_RECOVERY =
      TransferOrderType._(27,
          _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_PERIODIC_SAVING_RECOVERY');
  static const TransferOrderType TRANSFER_ORDER_TYPE_PENALTY =
      TransferOrderType._(
          31, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_PENALTY');
  static const TransferOrderType TRANSFER_ORDER_TYPE_PENALTY_CANCEL =
      TransferOrderType._(
          32, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_PENALTY_CANCEL');
  static const TransferOrderType
      TRANSFER_ORDER_TYPE_PENALTY_INCOME_DISTRIBUTION = TransferOrderType._(
          33,
          _omitEnumNames
              ? ''
              : 'TRANSFER_ORDER_TYPE_PENALTY_INCOME_DISTRIBUTION');
  static const TransferOrderType
      TRANSFER_ORDER_TYPE_LOAN_FUNDING_EXTERNAL_LENDING = TransferOrderType._(
          36,
          _omitEnumNames
              ? ''
              : 'TRANSFER_ORDER_TYPE_LOAN_FUNDING_EXTERNAL_LENDING');
  static const TransferOrderType
      TRANSFER_ORDER_TYPE_LOAN_FUNDING_EXTERNAL_LENDING_PAYBACK =
      TransferOrderType._(
          37,
          _omitEnumNames
              ? ''
              : 'TRANSFER_ORDER_TYPE_LOAN_FUNDING_EXTERNAL_LENDING_PAYBACK');
  static const TransferOrderType TRANSFER_ORDER_TYPE_INVESTOR_DEPLOYMENT =
      TransferOrderType._(
          38, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_INVESTOR_DEPLOYMENT');
  static const TransferOrderType TRANSFER_ORDER_TYPE_INVESTOR_PRINCIPAL_RETURN =
      TransferOrderType._(
          39,
          _omitEnumNames
              ? ''
              : 'TRANSFER_ORDER_TYPE_INVESTOR_PRINCIPAL_RETURN');
  static const TransferOrderType
      TRANSFER_ORDER_TYPE_INVESTOR_INCOME_DISTRIBUTION = TransferOrderType._(
          40,
          _omitEnumNames
              ? ''
              : 'TRANSFER_ORDER_TYPE_INVESTOR_INCOME_DISTRIBUTION');
  static const TransferOrderType TRANSFER_ORDER_TYPE_LOAN =
      TransferOrderType._(41, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_LOAN');
  static const TransferOrderType TRANSFER_ORDER_TYPE_LOAN_REPAYMENT =
      TransferOrderType._(
          42, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_LOAN_REPAYMENT');
  static const TransferOrderType TRANSFER_ORDER_TYPE_SHUTDOWN_LOAN_RECOVERY =
      TransferOrderType._(43,
          _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_SHUTDOWN_LOAN_RECOVERY');
  static const TransferOrderType
      TRANSFER_ORDER_TYPE_PLATFORM_FIRST_LOSS_ABSORPTION = TransferOrderType._(
          44,
          _omitEnumNames
              ? ''
              : 'TRANSFER_ORDER_TYPE_PLATFORM_FIRST_LOSS_ABSORPTION');
  static const TransferOrderType TRANSFER_ORDER_TYPE_INVESTOR_LOSS_ABSORPTION =
      TransferOrderType._(45,
          _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_INVESTOR_LOSS_ABSORPTION');
  static const TransferOrderType TRANSFER_ORDER_TYPE_LOAN_INTEREST =
      TransferOrderType._(
          46, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_LOAN_INTEREST');
  static const TransferOrderType TRANSFER_ORDER_TYPE_LOAN_INTEREST_REPAYMENT =
      TransferOrderType._(47,
          _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_LOAN_INTEREST_REPAYMENT');
  static const TransferOrderType
      TRANSFER_ORDER_TYPE_LOAN_INTEREST_INCOME_DISTRIBUTION =
      TransferOrderType._(
          48,
          _omitEnumNames
              ? ''
              : 'TRANSFER_ORDER_TYPE_LOAN_INTEREST_INCOME_DISTRIBUTION');
  static const TransferOrderType TRANSFER_ORDER_TYPE_LOAN_INSURANCE =
      TransferOrderType._(
          51, _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_LOAN_INSURANCE');
  static const TransferOrderType TRANSFER_ORDER_TYPE_LOAN_INSURANCE_REPAYMENT =
      TransferOrderType._(52,
          _omitEnumNames ? '' : 'TRANSFER_ORDER_TYPE_LOAN_INSURANCE_REPAYMENT');
  static const TransferOrderType
      TRANSFER_ORDER_TYPE_INTER_SUBSCRIPTION_PAYMENT = TransferOrderType._(
          71,
          _omitEnumNames
              ? ''
              : 'TRANSFER_ORDER_TYPE_INTER_SUBSCRIPTION_PAYMENT');

  static const $core.List<TransferOrderType> values = <TransferOrderType>[
    TRANSFER_ORDER_TYPE_UNSPECIFIED,
    TRANSFER_ORDER_TYPE_PAYMENT,
    TRANSFER_ORDER_TYPE_PAYMENT_IDENTIFIED,
    TRANSFER_ORDER_TYPE_PAYMENT_ALLOCATED,
    TRANSFER_ORDER_TYPE_DISBURSEMENT,
    TRANSFER_ORDER_TYPE_DISBURSEMENT_REVERSAL,
    TRANSFER_ORDER_TYPE_DISBURSEMENT_REVERSAL_REROUTE,
    TRANSFER_ORDER_TYPE_TERMINAL_DISBURSEMENT,
    TRANSFER_ORDER_TYPE_TERMINAL_DISBURSEMENT_RECOVERY,
    TRANSFER_ORDER_TYPE_COST,
    TRANSFER_ORDER_TYPE_SERVICE_FEE,
    TRANSFER_ORDER_TYPE_REGISTRATION_FEE,
    TRANSFER_ORDER_TYPE_PERIODIC_SAVING,
    TRANSFER_ORDER_TYPE_PERIODIC_SAVINGS_INTEREST_INCOME_DISTRIBUTION,
    TRANSFER_ORDER_TYPE_PERIODIC_SAVING_RECOVERY,
    TRANSFER_ORDER_TYPE_PENALTY,
    TRANSFER_ORDER_TYPE_PENALTY_CANCEL,
    TRANSFER_ORDER_TYPE_PENALTY_INCOME_DISTRIBUTION,
    TRANSFER_ORDER_TYPE_LOAN_FUNDING_EXTERNAL_LENDING,
    TRANSFER_ORDER_TYPE_LOAN_FUNDING_EXTERNAL_LENDING_PAYBACK,
    TRANSFER_ORDER_TYPE_INVESTOR_DEPLOYMENT,
    TRANSFER_ORDER_TYPE_INVESTOR_PRINCIPAL_RETURN,
    TRANSFER_ORDER_TYPE_INVESTOR_INCOME_DISTRIBUTION,
    TRANSFER_ORDER_TYPE_LOAN,
    TRANSFER_ORDER_TYPE_LOAN_REPAYMENT,
    TRANSFER_ORDER_TYPE_SHUTDOWN_LOAN_RECOVERY,
    TRANSFER_ORDER_TYPE_PLATFORM_FIRST_LOSS_ABSORPTION,
    TRANSFER_ORDER_TYPE_INVESTOR_LOSS_ABSORPTION,
    TRANSFER_ORDER_TYPE_LOAN_INTEREST,
    TRANSFER_ORDER_TYPE_LOAN_INTEREST_REPAYMENT,
    TRANSFER_ORDER_TYPE_LOAN_INTEREST_INCOME_DISTRIBUTION,
    TRANSFER_ORDER_TYPE_LOAN_INSURANCE,
    TRANSFER_ORDER_TYPE_LOAN_INSURANCE_REPAYMENT,
    TRANSFER_ORDER_TYPE_INTER_SUBSCRIPTION_PAYMENT,
  ];

  static final $core.Map<$core.int, TransferOrderType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static TransferOrderType? valueOf($core.int value) => _byValue[value];

  const TransferOrderType._(super.value, super.name);
}

/// OperationsJob names the periodic work the scheduler asks operations to do.
class OperationsJob extends $pb.ProtobufEnum {
  static const OperationsJob OPERATIONS_JOB_UNSPECIFIED =
      OperationsJob._(0, _omitEnumNames ? '' : 'OPERATIONS_JOB_UNSPECIFIED');

  /// Allocates individuals' matched payments whose allocation did not finish
  /// and posts borrower repayment orders raised but never executed.
  static const OperationsJob OPERATIONS_JOB_SETTLE_PAYMENTS = OperationsJob._(
      1, _omitEnumNames ? '' : 'OPERATIONS_JOB_SETTLE_PAYMENTS');

  static const $core.List<OperationsJob> values = <OperationsJob>[
    OPERATIONS_JOB_UNSPECIFIED,
    OPERATIONS_JOB_SETTLE_PAYMENTS,
  ];

  static final $core.List<OperationsJob?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static OperationsJob? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OperationsJob._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
