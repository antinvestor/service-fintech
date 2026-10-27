// This is a generated file - do not edit.
//
// Generated from funding/v1/funding.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// InvestorStatementEntryType is what moved an investor's capital.
class InvestorStatementEntryType extends $pb.ProtobufEnum {
  static const InvestorStatementEntryType
      INVESTOR_STATEMENT_ENTRY_TYPE_UNSPECIFIED = InvestorStatementEntryType._(
          0, _omitEnumNames ? '' : 'INVESTOR_STATEMENT_ENTRY_TYPE_UNSPECIFIED');

  /// Capital the investor paid in.
  static const InvestorStatementEntryType
      INVESTOR_STATEMENT_ENTRY_TYPE_DEPOSIT = InvestorStatementEntryType._(
          1, _omitEnumNames ? '' : 'INVESTOR_STATEMENT_ENTRY_TYPE_DEPOSIT');

  /// Capital paid out to the investor. A withdrawal whose payout is not yet
  /// confirmed is reported with pending = true.
  static const InvestorStatementEntryType
      INVESTOR_STATEMENT_ENTRY_TYPE_WITHDRAWAL = InvestorStatementEntryType._(
          2, _omitEnumNames ? '' : 'INVESTOR_STATEMENT_ENTRY_TYPE_WITHDRAWAL');

  /// Capital committed to a loan.
  static const InvestorStatementEntryType
      INVESTOR_STATEMENT_ENTRY_TYPE_DEPLOYMENT = InvestorStatementEntryType._(
          3, _omitEnumNames ? '' : 'INVESTOR_STATEMENT_ENTRY_TYPE_DEPLOYMENT');

  /// A commitment released because the loan was never disbursed.
  static const InvestorStatementEntryType
      INVESTOR_STATEMENT_ENTRY_TYPE_RELEASE = InvestorStatementEntryType._(
          4, _omitEnumNames ? '' : 'INVESTOR_STATEMENT_ENTRY_TYPE_RELEASE');

  /// Principal a borrower repaid, back to the investor.
  static const InvestorStatementEntryType
      INVESTOR_STATEMENT_ENTRY_TYPE_PRINCIPAL_RETURNED =
      InvestorStatementEntryType._(
          5,
          _omitEnumNames
              ? ''
              : 'INVESTOR_STATEMENT_ENTRY_TYPE_PRINCIPAL_RETURNED');

  /// Interest a borrower paid, net of the platform fee and withholding tax.
  static const InvestorStatementEntryType
      INVESTOR_STATEMENT_ENTRY_TYPE_INTEREST_EARNED =
      InvestorStatementEntryType._(
          6,
          _omitEnumNames
              ? ''
              : 'INVESTOR_STATEMENT_ENTRY_TYPE_INTEREST_EARNED');

  /// Capital lost when a loan was written off.
  static const InvestorStatementEntryType INVESTOR_STATEMENT_ENTRY_TYPE_LOSS =
      InvestorStatementEntryType._(
          7, _omitEnumNames ? '' : 'INVESTOR_STATEMENT_ENTRY_TYPE_LOSS');

  /// Lost capital recovered from a written-off loan.
  static const InvestorStatementEntryType
      INVESTOR_STATEMENT_ENTRY_TYPE_RECOVERY = InvestorStatementEntryType._(
          8, _omitEnumNames ? '' : 'INVESTOR_STATEMENT_ENTRY_TYPE_RECOVERY');

  static const $core.List<InvestorStatementEntryType> values =
      <InvestorStatementEntryType>[
    INVESTOR_STATEMENT_ENTRY_TYPE_UNSPECIFIED,
    INVESTOR_STATEMENT_ENTRY_TYPE_DEPOSIT,
    INVESTOR_STATEMENT_ENTRY_TYPE_WITHDRAWAL,
    INVESTOR_STATEMENT_ENTRY_TYPE_DEPLOYMENT,
    INVESTOR_STATEMENT_ENTRY_TYPE_RELEASE,
    INVESTOR_STATEMENT_ENTRY_TYPE_PRINCIPAL_RETURNED,
    INVESTOR_STATEMENT_ENTRY_TYPE_INTEREST_EARNED,
    INVESTOR_STATEMENT_ENTRY_TYPE_LOSS,
    INVESTOR_STATEMENT_ENTRY_TYPE_RECOVERY,
  ];

  static final $core.List<InvestorStatementEntryType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static InvestorStatementEntryType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const InvestorStatementEntryType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
