//
//  Generated code. Do not modify.
//  source: savings/v1/savings.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../common/v1/common.pb.dart' as $8;
import '../../common/v1/common.pbenum.dart' as $8;
import '../../common/v1/money.pb.dart' as $7;
import '../../google/protobuf/struct.pb.dart' as $6;
import 'savings.pbenum.dart';

export 'savings.pbenum.dart';

/// SavingsProductObject defines savings terms, rates, and rules for a bank.
class SavingsProductObject extends $pb.GeneratedMessage {
  factory SavingsProductObject({
    $core.String? id,
    $core.String? organizationId,
    $core.String? name,
    $core.String? code,
    $core.String? description,
    $core.String? currencyCode,
    $core.String? interestRate,
    CompoundingFrequency? compoundingFrequency,
    SavingsPeriodType? periodType,
    $7.Money? minDeposit,
    $7.Money? maxDeposit,
    $6.Struct? withdrawalRules,
    $8.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (code != null) {
      $result.code = code;
    }
    if (description != null) {
      $result.description = description;
    }
    if (currencyCode != null) {
      $result.currencyCode = currencyCode;
    }
    if (interestRate != null) {
      $result.interestRate = interestRate;
    }
    if (compoundingFrequency != null) {
      $result.compoundingFrequency = compoundingFrequency;
    }
    if (periodType != null) {
      $result.periodType = periodType;
    }
    if (minDeposit != null) {
      $result.minDeposit = minDeposit;
    }
    if (maxDeposit != null) {
      $result.maxDeposit = maxDeposit;
    }
    if (withdrawalRules != null) {
      $result.withdrawalRules = withdrawalRules;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  SavingsProductObject._() : super();
  factory SavingsProductObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsProductObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsProductObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'code')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aOS(6, _omitFieldNames ? '' : 'currencyCode')
    ..aOS(7, _omitFieldNames ? '' : 'interestRate')
    ..e<CompoundingFrequency>(8, _omitFieldNames ? '' : 'compoundingFrequency', $pb.PbFieldType.OE, defaultOrMaker: CompoundingFrequency.COMPOUNDING_FREQUENCY_UNSPECIFIED, valueOf: CompoundingFrequency.valueOf, enumValues: CompoundingFrequency.values)
    ..e<SavingsPeriodType>(9, _omitFieldNames ? '' : 'periodType', $pb.PbFieldType.OE, defaultOrMaker: SavingsPeriodType.SAVINGS_PERIOD_TYPE_UNSPECIFIED, valueOf: SavingsPeriodType.valueOf, enumValues: SavingsPeriodType.values)
    ..aOM<$7.Money>(10, _omitFieldNames ? '' : 'minDeposit', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(11, _omitFieldNames ? '' : 'maxDeposit', subBuilder: $7.Money.create)
    ..aOM<$6.Struct>(12, _omitFieldNames ? '' : 'withdrawalRules', subBuilder: $6.Struct.create)
    ..e<$8.STATE>(13, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $8.STATE.CREATED, valueOf: $8.STATE.valueOf, enumValues: $8.STATE.values)
    ..aOM<$6.Struct>(14, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsProductObject clone() => SavingsProductObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsProductObject copyWith(void Function(SavingsProductObject) updates) => super.copyWith((message) => updates(message as SavingsProductObject)) as SavingsProductObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsProductObject create() => SavingsProductObject._();
  SavingsProductObject createEmptyInstance() => create();
  static $pb.PbList<SavingsProductObject> createRepeated() => $pb.PbList<SavingsProductObject>();
  @$core.pragma('dart2js:noInline')
  static SavingsProductObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsProductObject>(create);
  static SavingsProductObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get organizationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set organizationId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOrganizationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrganizationId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get code => $_getSZ(3);
  @$pb.TagNumber(4)
  set code($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearCode() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get currencyCode => $_getSZ(5);
  @$pb.TagNumber(6)
  set currencyCode($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCurrencyCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCurrencyCode() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get interestRate => $_getSZ(6);
  @$pb.TagNumber(7)
  set interestRate($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasInterestRate() => $_has(6);
  @$pb.TagNumber(7)
  void clearInterestRate() => clearField(7);

  @$pb.TagNumber(8)
  CompoundingFrequency get compoundingFrequency => $_getN(7);
  @$pb.TagNumber(8)
  set compoundingFrequency(CompoundingFrequency v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasCompoundingFrequency() => $_has(7);
  @$pb.TagNumber(8)
  void clearCompoundingFrequency() => clearField(8);

  @$pb.TagNumber(9)
  SavingsPeriodType get periodType => $_getN(8);
  @$pb.TagNumber(9)
  set periodType(SavingsPeriodType v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasPeriodType() => $_has(8);
  @$pb.TagNumber(9)
  void clearPeriodType() => clearField(9);

  @$pb.TagNumber(10)
  $7.Money get minDeposit => $_getN(9);
  @$pb.TagNumber(10)
  set minDeposit($7.Money v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasMinDeposit() => $_has(9);
  @$pb.TagNumber(10)
  void clearMinDeposit() => clearField(10);
  @$pb.TagNumber(10)
  $7.Money ensureMinDeposit() => $_ensure(9);

  @$pb.TagNumber(11)
  $7.Money get maxDeposit => $_getN(10);
  @$pb.TagNumber(11)
  set maxDeposit($7.Money v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasMaxDeposit() => $_has(10);
  @$pb.TagNumber(11)
  void clearMaxDeposit() => clearField(11);
  @$pb.TagNumber(11)
  $7.Money ensureMaxDeposit() => $_ensure(10);

  @$pb.TagNumber(12)
  $6.Struct get withdrawalRules => $_getN(11);
  @$pb.TagNumber(12)
  set withdrawalRules($6.Struct v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasWithdrawalRules() => $_has(11);
  @$pb.TagNumber(12)
  void clearWithdrawalRules() => clearField(12);
  @$pb.TagNumber(12)
  $6.Struct ensureWithdrawalRules() => $_ensure(11);

  @$pb.TagNumber(13)
  $8.STATE get state => $_getN(12);
  @$pb.TagNumber(13)
  set state($8.STATE v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasState() => $_has(12);
  @$pb.TagNumber(13)
  void clearState() => clearField(13);

  @$pb.TagNumber(14)
  $6.Struct get properties => $_getN(13);
  @$pb.TagNumber(14)
  set properties($6.Struct v) { setField(14, v); }
  @$pb.TagNumber(14)
  $core.bool hasProperties() => $_has(13);
  @$pb.TagNumber(14)
  void clearProperties() => clearField(14);
  @$pb.TagNumber(14)
  $6.Struct ensureProperties() => $_ensure(13);
}

/// SavingsAccountObject represents an individual or group savings account.
class SavingsAccountObject extends $pb.GeneratedMessage {
  factory SavingsAccountObject({
    $core.String? id,
    $core.String? productId,
    $core.String? ownerId,
    SavingsAccountOwnerType? ownerType,
    $core.String? organizationId,
    $core.String? branchId,
    $core.String? agentId,
    $core.String? currencyCode,
    SavingsAccountStatus? status,
    $core.String? ledgerAccountId,
    $core.String? paymentAccountRef,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (productId != null) {
      $result.productId = productId;
    }
    if (ownerId != null) {
      $result.ownerId = ownerId;
    }
    if (ownerType != null) {
      $result.ownerType = ownerType;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (branchId != null) {
      $result.branchId = branchId;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (currencyCode != null) {
      $result.currencyCode = currencyCode;
    }
    if (status != null) {
      $result.status = status;
    }
    if (ledgerAccountId != null) {
      $result.ledgerAccountId = ledgerAccountId;
    }
    if (paymentAccountRef != null) {
      $result.paymentAccountRef = paymentAccountRef;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  SavingsAccountObject._() : super();
  factory SavingsAccountObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsAccountObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsAccountObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productId')
    ..aOS(3, _omitFieldNames ? '' : 'ownerId')
    ..e<SavingsAccountOwnerType>(4, _omitFieldNames ? '' : 'ownerType', $pb.PbFieldType.OE, defaultOrMaker: SavingsAccountOwnerType.SAVINGS_ACCOUNT_OWNER_TYPE_UNSPECIFIED, valueOf: SavingsAccountOwnerType.valueOf, enumValues: SavingsAccountOwnerType.values)
    ..aOS(5, _omitFieldNames ? '' : 'organizationId')
    ..aOS(6, _omitFieldNames ? '' : 'branchId')
    ..aOS(7, _omitFieldNames ? '' : 'agentId')
    ..aOS(8, _omitFieldNames ? '' : 'currencyCode')
    ..e<SavingsAccountStatus>(9, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: SavingsAccountStatus.SAVINGS_ACCOUNT_STATUS_UNSPECIFIED, valueOf: SavingsAccountStatus.valueOf, enumValues: SavingsAccountStatus.values)
    ..aOS(10, _omitFieldNames ? '' : 'ledgerAccountId')
    ..aOS(11, _omitFieldNames ? '' : 'paymentAccountRef')
    ..aOM<$6.Struct>(12, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsAccountObject clone() => SavingsAccountObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsAccountObject copyWith(void Function(SavingsAccountObject) updates) => super.copyWith((message) => updates(message as SavingsAccountObject)) as SavingsAccountObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsAccountObject create() => SavingsAccountObject._();
  SavingsAccountObject createEmptyInstance() => create();
  static $pb.PbList<SavingsAccountObject> createRepeated() => $pb.PbList<SavingsAccountObject>();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsAccountObject>(create);
  static SavingsAccountObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get productId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProductId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get ownerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ownerId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOwnerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOwnerId() => clearField(3);

  @$pb.TagNumber(4)
  SavingsAccountOwnerType get ownerType => $_getN(3);
  @$pb.TagNumber(4)
  set ownerType(SavingsAccountOwnerType v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasOwnerType() => $_has(3);
  @$pb.TagNumber(4)
  void clearOwnerType() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get organizationId => $_getSZ(4);
  @$pb.TagNumber(5)
  set organizationId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOrganizationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOrganizationId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get branchId => $_getSZ(5);
  @$pb.TagNumber(6)
  set branchId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasBranchId() => $_has(5);
  @$pb.TagNumber(6)
  void clearBranchId() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get agentId => $_getSZ(6);
  @$pb.TagNumber(7)
  set agentId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAgentId() => $_has(6);
  @$pb.TagNumber(7)
  void clearAgentId() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get currencyCode => $_getSZ(7);
  @$pb.TagNumber(8)
  set currencyCode($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCurrencyCode() => $_has(7);
  @$pb.TagNumber(8)
  void clearCurrencyCode() => clearField(8);

  @$pb.TagNumber(9)
  SavingsAccountStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(SavingsAccountStatus v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get ledgerAccountId => $_getSZ(9);
  @$pb.TagNumber(10)
  set ledgerAccountId($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasLedgerAccountId() => $_has(9);
  @$pb.TagNumber(10)
  void clearLedgerAccountId() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get paymentAccountRef => $_getSZ(10);
  @$pb.TagNumber(11)
  set paymentAccountRef($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasPaymentAccountRef() => $_has(10);
  @$pb.TagNumber(11)
  void clearPaymentAccountRef() => clearField(11);

  @$pb.TagNumber(12)
  $6.Struct get properties => $_getN(11);
  @$pb.TagNumber(12)
  set properties($6.Struct v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasProperties() => $_has(11);
  @$pb.TagNumber(12)
  void clearProperties() => clearField(12);
  @$pb.TagNumber(12)
  $6.Struct ensureProperties() => $_ensure(11);
}

/// DepositObject records a deposit into a savings account.
class DepositObject extends $pb.GeneratedMessage {
  factory DepositObject({
    $core.String? id,
    $core.String? savingsAccountId,
    $7.Money? amount,
    DepositStatus? status,
    $core.String? paymentReference,
    $core.String? ledgerTransactionId,
    $core.String? channel,
    $core.String? payerReference,
    $core.String? idempotencyKey,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (savingsAccountId != null) {
      $result.savingsAccountId = savingsAccountId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (status != null) {
      $result.status = status;
    }
    if (paymentReference != null) {
      $result.paymentReference = paymentReference;
    }
    if (ledgerTransactionId != null) {
      $result.ledgerTransactionId = ledgerTransactionId;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (payerReference != null) {
      $result.payerReference = payerReference;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  DepositObject._() : super();
  factory DepositObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepositObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepositObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$7.Money>(3, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..e<DepositStatus>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: DepositStatus.DEPOSIT_STATUS_UNSPECIFIED, valueOf: DepositStatus.valueOf, enumValues: DepositStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(7, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOS(8, _omitFieldNames ? '' : 'channel')
    ..aOS(9, _omitFieldNames ? '' : 'payerReference')
    ..aOS(10, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$6.Struct>(11, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepositObject clone() => DepositObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepositObject copyWith(void Function(DepositObject) updates) => super.copyWith((message) => updates(message as DepositObject)) as DepositObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepositObject create() => DepositObject._();
  DepositObject createEmptyInstance() => create();
  static $pb.PbList<DepositObject> createRepeated() => $pb.PbList<DepositObject>();
  @$core.pragma('dart2js:noInline')
  static DepositObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepositObject>(create);
  static DepositObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get savingsAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set savingsAccountId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSavingsAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSavingsAccountId() => clearField(2);

  @$pb.TagNumber(3)
  $7.Money get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($7.Money v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => clearField(3);
  @$pb.TagNumber(3)
  $7.Money ensureAmount() => $_ensure(2);

  @$pb.TagNumber(5)
  DepositStatus get status => $_getN(3);
  @$pb.TagNumber(5)
  set status(DepositStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get paymentReference => $_getSZ(4);
  @$pb.TagNumber(6)
  set paymentReference($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasPaymentReference() => $_has(4);
  @$pb.TagNumber(6)
  void clearPaymentReference() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get ledgerTransactionId => $_getSZ(5);
  @$pb.TagNumber(7)
  set ledgerTransactionId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(7)
  $core.bool hasLedgerTransactionId() => $_has(5);
  @$pb.TagNumber(7)
  void clearLedgerTransactionId() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get channel => $_getSZ(6);
  @$pb.TagNumber(8)
  set channel($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(8)
  $core.bool hasChannel() => $_has(6);
  @$pb.TagNumber(8)
  void clearChannel() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get payerReference => $_getSZ(7);
  @$pb.TagNumber(9)
  set payerReference($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(9)
  $core.bool hasPayerReference() => $_has(7);
  @$pb.TagNumber(9)
  void clearPayerReference() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get idempotencyKey => $_getSZ(8);
  @$pb.TagNumber(10)
  set idempotencyKey($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(10)
  $core.bool hasIdempotencyKey() => $_has(8);
  @$pb.TagNumber(10)
  void clearIdempotencyKey() => clearField(10);

  @$pb.TagNumber(11)
  $6.Struct get properties => $_getN(9);
  @$pb.TagNumber(11)
  set properties($6.Struct v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasProperties() => $_has(9);
  @$pb.TagNumber(11)
  void clearProperties() => clearField(11);
  @$pb.TagNumber(11)
  $6.Struct ensureProperties() => $_ensure(9);
}

/// WithdrawalObject records a withdrawal from a savings account.
class WithdrawalObject extends $pb.GeneratedMessage {
  factory WithdrawalObject({
    $core.String? id,
    $core.String? savingsAccountId,
    $7.Money? amount,
    WithdrawalStatus? status,
    $core.String? paymentReference,
    $core.String? ledgerTransactionId,
    $core.String? channel,
    $core.String? recipientReference,
    $core.String? reason,
    $core.String? idempotencyKey,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (savingsAccountId != null) {
      $result.savingsAccountId = savingsAccountId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (status != null) {
      $result.status = status;
    }
    if (paymentReference != null) {
      $result.paymentReference = paymentReference;
    }
    if (ledgerTransactionId != null) {
      $result.ledgerTransactionId = ledgerTransactionId;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (recipientReference != null) {
      $result.recipientReference = recipientReference;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  WithdrawalObject._() : super();
  factory WithdrawalObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$7.Money>(3, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..e<WithdrawalStatus>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: WithdrawalStatus.WITHDRAWAL_STATUS_UNSPECIFIED, valueOf: WithdrawalStatus.valueOf, enumValues: WithdrawalStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(7, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOS(8, _omitFieldNames ? '' : 'channel')
    ..aOS(9, _omitFieldNames ? '' : 'recipientReference')
    ..aOS(10, _omitFieldNames ? '' : 'reason')
    ..aOS(11, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$6.Struct>(12, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalObject clone() => WithdrawalObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalObject copyWith(void Function(WithdrawalObject) updates) => super.copyWith((message) => updates(message as WithdrawalObject)) as WithdrawalObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalObject create() => WithdrawalObject._();
  WithdrawalObject createEmptyInstance() => create();
  static $pb.PbList<WithdrawalObject> createRepeated() => $pb.PbList<WithdrawalObject>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalObject>(create);
  static WithdrawalObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get savingsAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set savingsAccountId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSavingsAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSavingsAccountId() => clearField(2);

  @$pb.TagNumber(3)
  $7.Money get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($7.Money v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => clearField(3);
  @$pb.TagNumber(3)
  $7.Money ensureAmount() => $_ensure(2);

  @$pb.TagNumber(5)
  WithdrawalStatus get status => $_getN(3);
  @$pb.TagNumber(5)
  set status(WithdrawalStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get paymentReference => $_getSZ(4);
  @$pb.TagNumber(6)
  set paymentReference($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasPaymentReference() => $_has(4);
  @$pb.TagNumber(6)
  void clearPaymentReference() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get ledgerTransactionId => $_getSZ(5);
  @$pb.TagNumber(7)
  set ledgerTransactionId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(7)
  $core.bool hasLedgerTransactionId() => $_has(5);
  @$pb.TagNumber(7)
  void clearLedgerTransactionId() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get channel => $_getSZ(6);
  @$pb.TagNumber(8)
  set channel($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(8)
  $core.bool hasChannel() => $_has(6);
  @$pb.TagNumber(8)
  void clearChannel() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get recipientReference => $_getSZ(7);
  @$pb.TagNumber(9)
  set recipientReference($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(9)
  $core.bool hasRecipientReference() => $_has(7);
  @$pb.TagNumber(9)
  void clearRecipientReference() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get reason => $_getSZ(8);
  @$pb.TagNumber(10)
  set reason($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(10)
  $core.bool hasReason() => $_has(8);
  @$pb.TagNumber(10)
  void clearReason() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get idempotencyKey => $_getSZ(9);
  @$pb.TagNumber(11)
  set idempotencyKey($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(11)
  $core.bool hasIdempotencyKey() => $_has(9);
  @$pb.TagNumber(11)
  void clearIdempotencyKey() => clearField(11);

  @$pb.TagNumber(12)
  $6.Struct get properties => $_getN(10);
  @$pb.TagNumber(12)
  set properties($6.Struct v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasProperties() => $_has(10);
  @$pb.TagNumber(12)
  void clearProperties() => clearField(12);
  @$pb.TagNumber(12)
  $6.Struct ensureProperties() => $_ensure(10);
}

/// InterestAccrualObject records periodic interest accrued on a savings account.
class InterestAccrualObject extends $pb.GeneratedMessage {
  factory InterestAccrualObject({
    $core.String? id,
    $core.String? savingsAccountId,
    $7.Money? amount,
    $core.String? periodStart,
    $core.String? periodEnd,
    $core.String? rateApplied,
    $7.Money? balanceUsed,
    $core.String? ledgerTransactionId,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (savingsAccountId != null) {
      $result.savingsAccountId = savingsAccountId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (periodStart != null) {
      $result.periodStart = periodStart;
    }
    if (periodEnd != null) {
      $result.periodEnd = periodEnd;
    }
    if (rateApplied != null) {
      $result.rateApplied = rateApplied;
    }
    if (balanceUsed != null) {
      $result.balanceUsed = balanceUsed;
    }
    if (ledgerTransactionId != null) {
      $result.ledgerTransactionId = ledgerTransactionId;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  InterestAccrualObject._() : super();
  factory InterestAccrualObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InterestAccrualObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InterestAccrualObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$7.Money>(3, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..aOS(4, _omitFieldNames ? '' : 'periodStart')
    ..aOS(5, _omitFieldNames ? '' : 'periodEnd')
    ..aOS(6, _omitFieldNames ? '' : 'rateApplied')
    ..aOM<$7.Money>(7, _omitFieldNames ? '' : 'balanceUsed', subBuilder: $7.Money.create)
    ..aOS(8, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOM<$6.Struct>(9, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InterestAccrualObject clone() => InterestAccrualObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InterestAccrualObject copyWith(void Function(InterestAccrualObject) updates) => super.copyWith((message) => updates(message as InterestAccrualObject)) as InterestAccrualObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InterestAccrualObject create() => InterestAccrualObject._();
  InterestAccrualObject createEmptyInstance() => create();
  static $pb.PbList<InterestAccrualObject> createRepeated() => $pb.PbList<InterestAccrualObject>();
  @$core.pragma('dart2js:noInline')
  static InterestAccrualObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InterestAccrualObject>(create);
  static InterestAccrualObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get savingsAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set savingsAccountId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSavingsAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSavingsAccountId() => clearField(2);

  @$pb.TagNumber(3)
  $7.Money get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($7.Money v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => clearField(3);
  @$pb.TagNumber(3)
  $7.Money ensureAmount() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get periodStart => $_getSZ(3);
  @$pb.TagNumber(4)
  set periodStart($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPeriodStart() => $_has(3);
  @$pb.TagNumber(4)
  void clearPeriodStart() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get periodEnd => $_getSZ(4);
  @$pb.TagNumber(5)
  set periodEnd($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPeriodEnd() => $_has(4);
  @$pb.TagNumber(5)
  void clearPeriodEnd() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get rateApplied => $_getSZ(5);
  @$pb.TagNumber(6)
  set rateApplied($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasRateApplied() => $_has(5);
  @$pb.TagNumber(6)
  void clearRateApplied() => clearField(6);

  @$pb.TagNumber(7)
  $7.Money get balanceUsed => $_getN(6);
  @$pb.TagNumber(7)
  set balanceUsed($7.Money v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasBalanceUsed() => $_has(6);
  @$pb.TagNumber(7)
  void clearBalanceUsed() => clearField(7);
  @$pb.TagNumber(7)
  $7.Money ensureBalanceUsed() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get ledgerTransactionId => $_getSZ(7);
  @$pb.TagNumber(8)
  set ledgerTransactionId($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasLedgerTransactionId() => $_has(7);
  @$pb.TagNumber(8)
  void clearLedgerTransactionId() => clearField(8);

  @$pb.TagNumber(9)
  $6.Struct get properties => $_getN(8);
  @$pb.TagNumber(9)
  set properties($6.Struct v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasProperties() => $_has(8);
  @$pb.TagNumber(9)
  void clearProperties() => clearField(9);
  @$pb.TagNumber(9)
  $6.Struct ensureProperties() => $_ensure(8);
}

/// SavingsBalanceObject represents the current balance of a savings account.
class SavingsBalanceObject extends $pb.GeneratedMessage {
  factory SavingsBalanceObject({
    $core.String? savingsAccountId,
    $7.Money? availableBalance,
    $7.Money? totalDeposits,
    $7.Money? totalWithdrawals,
    $7.Money? totalInterest,
    $core.String? lastCalculatedAt,
  }) {
    final $result = create();
    if (savingsAccountId != null) {
      $result.savingsAccountId = savingsAccountId;
    }
    if (availableBalance != null) {
      $result.availableBalance = availableBalance;
    }
    if (totalDeposits != null) {
      $result.totalDeposits = totalDeposits;
    }
    if (totalWithdrawals != null) {
      $result.totalWithdrawals = totalWithdrawals;
    }
    if (totalInterest != null) {
      $result.totalInterest = totalInterest;
    }
    if (lastCalculatedAt != null) {
      $result.lastCalculatedAt = lastCalculatedAt;
    }
    return $result;
  }
  SavingsBalanceObject._() : super();
  factory SavingsBalanceObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsBalanceObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsBalanceObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$7.Money>(2, _omitFieldNames ? '' : 'availableBalance', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(3, _omitFieldNames ? '' : 'totalDeposits', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(4, _omitFieldNames ? '' : 'totalWithdrawals', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(5, _omitFieldNames ? '' : 'totalInterest', subBuilder: $7.Money.create)
    ..aOS(6, _omitFieldNames ? '' : 'lastCalculatedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsBalanceObject clone() => SavingsBalanceObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsBalanceObject copyWith(void Function(SavingsBalanceObject) updates) => super.copyWith((message) => updates(message as SavingsBalanceObject)) as SavingsBalanceObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsBalanceObject create() => SavingsBalanceObject._();
  SavingsBalanceObject createEmptyInstance() => create();
  static $pb.PbList<SavingsBalanceObject> createRepeated() => $pb.PbList<SavingsBalanceObject>();
  @$core.pragma('dart2js:noInline')
  static SavingsBalanceObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsBalanceObject>(create);
  static SavingsBalanceObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => clearField(1);

  @$pb.TagNumber(2)
  $7.Money get availableBalance => $_getN(1);
  @$pb.TagNumber(2)
  set availableBalance($7.Money v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAvailableBalance() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvailableBalance() => clearField(2);
  @$pb.TagNumber(2)
  $7.Money ensureAvailableBalance() => $_ensure(1);

  @$pb.TagNumber(3)
  $7.Money get totalDeposits => $_getN(2);
  @$pb.TagNumber(3)
  set totalDeposits($7.Money v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTotalDeposits() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalDeposits() => clearField(3);
  @$pb.TagNumber(3)
  $7.Money ensureTotalDeposits() => $_ensure(2);

  @$pb.TagNumber(4)
  $7.Money get totalWithdrawals => $_getN(3);
  @$pb.TagNumber(4)
  set totalWithdrawals($7.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasTotalWithdrawals() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalWithdrawals() => clearField(4);
  @$pb.TagNumber(4)
  $7.Money ensureTotalWithdrawals() => $_ensure(3);

  @$pb.TagNumber(5)
  $7.Money get totalInterest => $_getN(4);
  @$pb.TagNumber(5)
  set totalInterest($7.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasTotalInterest() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalInterest() => clearField(5);
  @$pb.TagNumber(5)
  $7.Money ensureTotalInterest() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get lastCalculatedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set lastCalculatedAt($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLastCalculatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastCalculatedAt() => clearField(6);
}

/// SavingsStatementEntry represents a single line in a savings statement.
class SavingsStatementEntry extends $pb.GeneratedMessage {
  factory SavingsStatementEntry({
    $core.String? date,
    $core.String? description,
    $7.Money? debit,
    $7.Money? credit,
    $7.Money? balance,
    $core.String? reference,
  }) {
    final $result = create();
    if (date != null) {
      $result.date = date;
    }
    if (description != null) {
      $result.description = description;
    }
    if (debit != null) {
      $result.debit = debit;
    }
    if (credit != null) {
      $result.credit = credit;
    }
    if (balance != null) {
      $result.balance = balance;
    }
    if (reference != null) {
      $result.reference = reference;
    }
    return $result;
  }
  SavingsStatementEntry._() : super();
  factory SavingsStatementEntry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsStatementEntry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsStatementEntry', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOM<$7.Money>(3, _omitFieldNames ? '' : 'debit', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(4, _omitFieldNames ? '' : 'credit', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(5, _omitFieldNames ? '' : 'balance', subBuilder: $7.Money.create)
    ..aOS(6, _omitFieldNames ? '' : 'reference')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsStatementEntry clone() => SavingsStatementEntry()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsStatementEntry copyWith(void Function(SavingsStatementEntry) updates) => super.copyWith((message) => updates(message as SavingsStatementEntry)) as SavingsStatementEntry;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsStatementEntry create() => SavingsStatementEntry._();
  SavingsStatementEntry createEmptyInstance() => create();
  static $pb.PbList<SavingsStatementEntry> createRepeated() => $pb.PbList<SavingsStatementEntry>();
  @$core.pragma('dart2js:noInline')
  static SavingsStatementEntry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsStatementEntry>(create);
  static SavingsStatementEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);

  @$pb.TagNumber(3)
  $7.Money get debit => $_getN(2);
  @$pb.TagNumber(3)
  set debit($7.Money v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasDebit() => $_has(2);
  @$pb.TagNumber(3)
  void clearDebit() => clearField(3);
  @$pb.TagNumber(3)
  $7.Money ensureDebit() => $_ensure(2);

  @$pb.TagNumber(4)
  $7.Money get credit => $_getN(3);
  @$pb.TagNumber(4)
  set credit($7.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCredit() => $_has(3);
  @$pb.TagNumber(4)
  void clearCredit() => clearField(4);
  @$pb.TagNumber(4)
  $7.Money ensureCredit() => $_ensure(3);

  @$pb.TagNumber(5)
  $7.Money get balance => $_getN(4);
  @$pb.TagNumber(5)
  set balance($7.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasBalance() => $_has(4);
  @$pb.TagNumber(5)
  void clearBalance() => clearField(5);
  @$pb.TagNumber(5)
  $7.Money ensureBalance() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get reference => $_getSZ(5);
  @$pb.TagNumber(6)
  set reference($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReference() => $_has(5);
  @$pb.TagNumber(6)
  void clearReference() => clearField(6);
}

class SavingsProductSaveRequest extends $pb.GeneratedMessage {
  factory SavingsProductSaveRequest({
    SavingsProductObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SavingsProductSaveRequest._() : super();
  factory SavingsProductSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsProductSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsProductSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<SavingsProductObject>(1, _omitFieldNames ? '' : 'data', subBuilder: SavingsProductObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsProductSaveRequest clone() => SavingsProductSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsProductSaveRequest copyWith(void Function(SavingsProductSaveRequest) updates) => super.copyWith((message) => updates(message as SavingsProductSaveRequest)) as SavingsProductSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsProductSaveRequest create() => SavingsProductSaveRequest._();
  SavingsProductSaveRequest createEmptyInstance() => create();
  static $pb.PbList<SavingsProductSaveRequest> createRepeated() => $pb.PbList<SavingsProductSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static SavingsProductSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsProductSaveRequest>(create);
  static SavingsProductSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsProductObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  SavingsProductObject ensureData() => $_ensure(0);
}

class SavingsProductSaveResponse extends $pb.GeneratedMessage {
  factory SavingsProductSaveResponse({
    SavingsProductObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SavingsProductSaveResponse._() : super();
  factory SavingsProductSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsProductSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsProductSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<SavingsProductObject>(1, _omitFieldNames ? '' : 'data', subBuilder: SavingsProductObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsProductSaveResponse clone() => SavingsProductSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsProductSaveResponse copyWith(void Function(SavingsProductSaveResponse) updates) => super.copyWith((message) => updates(message as SavingsProductSaveResponse)) as SavingsProductSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsProductSaveResponse create() => SavingsProductSaveResponse._();
  SavingsProductSaveResponse createEmptyInstance() => create();
  static $pb.PbList<SavingsProductSaveResponse> createRepeated() => $pb.PbList<SavingsProductSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static SavingsProductSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsProductSaveResponse>(create);
  static SavingsProductSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsProductObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  SavingsProductObject ensureData() => $_ensure(0);
}

class SavingsProductGetRequest extends $pb.GeneratedMessage {
  factory SavingsProductGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  SavingsProductGetRequest._() : super();
  factory SavingsProductGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsProductGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsProductGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsProductGetRequest clone() => SavingsProductGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsProductGetRequest copyWith(void Function(SavingsProductGetRequest) updates) => super.copyWith((message) => updates(message as SavingsProductGetRequest)) as SavingsProductGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsProductGetRequest create() => SavingsProductGetRequest._();
  SavingsProductGetRequest createEmptyInstance() => create();
  static $pb.PbList<SavingsProductGetRequest> createRepeated() => $pb.PbList<SavingsProductGetRequest>();
  @$core.pragma('dart2js:noInline')
  static SavingsProductGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsProductGetRequest>(create);
  static SavingsProductGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class SavingsProductGetResponse extends $pb.GeneratedMessage {
  factory SavingsProductGetResponse({
    SavingsProductObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SavingsProductGetResponse._() : super();
  factory SavingsProductGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsProductGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsProductGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<SavingsProductObject>(1, _omitFieldNames ? '' : 'data', subBuilder: SavingsProductObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsProductGetResponse clone() => SavingsProductGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsProductGetResponse copyWith(void Function(SavingsProductGetResponse) updates) => super.copyWith((message) => updates(message as SavingsProductGetResponse)) as SavingsProductGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsProductGetResponse create() => SavingsProductGetResponse._();
  SavingsProductGetResponse createEmptyInstance() => create();
  static $pb.PbList<SavingsProductGetResponse> createRepeated() => $pb.PbList<SavingsProductGetResponse>();
  @$core.pragma('dart2js:noInline')
  static SavingsProductGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsProductGetResponse>(create);
  static SavingsProductGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsProductObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  SavingsProductObject ensureData() => $_ensure(0);
}

class SavingsProductSearchRequest extends $pb.GeneratedMessage {
  factory SavingsProductSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  SavingsProductSearchRequest._() : super();
  factory SavingsProductSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsProductSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsProductSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOM<$8.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsProductSearchRequest clone() => SavingsProductSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsProductSearchRequest copyWith(void Function(SavingsProductSearchRequest) updates) => super.copyWith((message) => updates(message as SavingsProductSearchRequest)) as SavingsProductSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsProductSearchRequest create() => SavingsProductSearchRequest._();
  SavingsProductSearchRequest createEmptyInstance() => create();
  static $pb.PbList<SavingsProductSearchRequest> createRepeated() => $pb.PbList<SavingsProductSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static SavingsProductSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsProductSearchRequest>(create);
  static SavingsProductSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get organizationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set organizationId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOrganizationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrganizationId() => clearField(2);

  @$pb.TagNumber(3)
  $8.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($8.PageCursor v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => clearField(3);
  @$pb.TagNumber(3)
  $8.PageCursor ensureCursor() => $_ensure(2);
}

class SavingsProductSearchResponse extends $pb.GeneratedMessage {
  factory SavingsProductSearchResponse({
    $core.Iterable<SavingsProductObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  SavingsProductSearchResponse._() : super();
  factory SavingsProductSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsProductSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsProductSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..pc<SavingsProductObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: SavingsProductObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsProductSearchResponse clone() => SavingsProductSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsProductSearchResponse copyWith(void Function(SavingsProductSearchResponse) updates) => super.copyWith((message) => updates(message as SavingsProductSearchResponse)) as SavingsProductSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsProductSearchResponse create() => SavingsProductSearchResponse._();
  SavingsProductSearchResponse createEmptyInstance() => create();
  static $pb.PbList<SavingsProductSearchResponse> createRepeated() => $pb.PbList<SavingsProductSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static SavingsProductSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsProductSearchResponse>(create);
  static SavingsProductSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<SavingsProductObject> get data => $_getList(0);
}

class SavingsAccountCreateRequest extends $pb.GeneratedMessage {
  factory SavingsAccountCreateRequest({
    SavingsAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SavingsAccountCreateRequest._() : super();
  factory SavingsAccountCreateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsAccountCreateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsAccountCreateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: SavingsAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsAccountCreateRequest clone() => SavingsAccountCreateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsAccountCreateRequest copyWith(void Function(SavingsAccountCreateRequest) updates) => super.copyWith((message) => updates(message as SavingsAccountCreateRequest)) as SavingsAccountCreateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsAccountCreateRequest create() => SavingsAccountCreateRequest._();
  SavingsAccountCreateRequest createEmptyInstance() => create();
  static $pb.PbList<SavingsAccountCreateRequest> createRepeated() => $pb.PbList<SavingsAccountCreateRequest>();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountCreateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsAccountCreateRequest>(create);
  static SavingsAccountCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  SavingsAccountObject ensureData() => $_ensure(0);
}

class SavingsAccountCreateResponse extends $pb.GeneratedMessage {
  factory SavingsAccountCreateResponse({
    SavingsAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SavingsAccountCreateResponse._() : super();
  factory SavingsAccountCreateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsAccountCreateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsAccountCreateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: SavingsAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsAccountCreateResponse clone() => SavingsAccountCreateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsAccountCreateResponse copyWith(void Function(SavingsAccountCreateResponse) updates) => super.copyWith((message) => updates(message as SavingsAccountCreateResponse)) as SavingsAccountCreateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsAccountCreateResponse create() => SavingsAccountCreateResponse._();
  SavingsAccountCreateResponse createEmptyInstance() => create();
  static $pb.PbList<SavingsAccountCreateResponse> createRepeated() => $pb.PbList<SavingsAccountCreateResponse>();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountCreateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsAccountCreateResponse>(create);
  static SavingsAccountCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  SavingsAccountObject ensureData() => $_ensure(0);
}

class SavingsAccountGetRequest extends $pb.GeneratedMessage {
  factory SavingsAccountGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  SavingsAccountGetRequest._() : super();
  factory SavingsAccountGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsAccountGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsAccountGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsAccountGetRequest clone() => SavingsAccountGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsAccountGetRequest copyWith(void Function(SavingsAccountGetRequest) updates) => super.copyWith((message) => updates(message as SavingsAccountGetRequest)) as SavingsAccountGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsAccountGetRequest create() => SavingsAccountGetRequest._();
  SavingsAccountGetRequest createEmptyInstance() => create();
  static $pb.PbList<SavingsAccountGetRequest> createRepeated() => $pb.PbList<SavingsAccountGetRequest>();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsAccountGetRequest>(create);
  static SavingsAccountGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class SavingsAccountGetResponse extends $pb.GeneratedMessage {
  factory SavingsAccountGetResponse({
    SavingsAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SavingsAccountGetResponse._() : super();
  factory SavingsAccountGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsAccountGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsAccountGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: SavingsAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsAccountGetResponse clone() => SavingsAccountGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsAccountGetResponse copyWith(void Function(SavingsAccountGetResponse) updates) => super.copyWith((message) => updates(message as SavingsAccountGetResponse)) as SavingsAccountGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsAccountGetResponse create() => SavingsAccountGetResponse._();
  SavingsAccountGetResponse createEmptyInstance() => create();
  static $pb.PbList<SavingsAccountGetResponse> createRepeated() => $pb.PbList<SavingsAccountGetResponse>();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsAccountGetResponse>(create);
  static SavingsAccountGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  SavingsAccountObject ensureData() => $_ensure(0);
}

class SavingsAccountSearchRequest extends $pb.GeneratedMessage {
  factory SavingsAccountSearchRequest({
    $core.String? query,
    $core.String? ownerId,
    $core.String? productId,
    $core.String? organizationId,
    SavingsAccountStatus? status,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (ownerId != null) {
      $result.ownerId = ownerId;
    }
    if (productId != null) {
      $result.productId = productId;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  SavingsAccountSearchRequest._() : super();
  factory SavingsAccountSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsAccountSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsAccountSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'ownerId')
    ..aOS(3, _omitFieldNames ? '' : 'productId')
    ..aOS(4, _omitFieldNames ? '' : 'organizationId')
    ..e<SavingsAccountStatus>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: SavingsAccountStatus.SAVINGS_ACCOUNT_STATUS_UNSPECIFIED, valueOf: SavingsAccountStatus.valueOf, enumValues: SavingsAccountStatus.values)
    ..aOM<$8.PageCursor>(6, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsAccountSearchRequest clone() => SavingsAccountSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsAccountSearchRequest copyWith(void Function(SavingsAccountSearchRequest) updates) => super.copyWith((message) => updates(message as SavingsAccountSearchRequest)) as SavingsAccountSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsAccountSearchRequest create() => SavingsAccountSearchRequest._();
  SavingsAccountSearchRequest createEmptyInstance() => create();
  static $pb.PbList<SavingsAccountSearchRequest> createRepeated() => $pb.PbList<SavingsAccountSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsAccountSearchRequest>(create);
  static SavingsAccountSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get ownerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set ownerId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOwnerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOwnerId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get productId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasProductId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get organizationId => $_getSZ(3);
  @$pb.TagNumber(4)
  set organizationId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOrganizationId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrganizationId() => clearField(4);

  @$pb.TagNumber(5)
  SavingsAccountStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(SavingsAccountStatus v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => clearField(5);

  @$pb.TagNumber(6)
  $8.PageCursor get cursor => $_getN(5);
  @$pb.TagNumber(6)
  set cursor($8.PageCursor v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearCursor() => clearField(6);
  @$pb.TagNumber(6)
  $8.PageCursor ensureCursor() => $_ensure(5);
}

class SavingsAccountSearchResponse extends $pb.GeneratedMessage {
  factory SavingsAccountSearchResponse({
    $core.Iterable<SavingsAccountObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  SavingsAccountSearchResponse._() : super();
  factory SavingsAccountSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsAccountSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsAccountSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..pc<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: SavingsAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsAccountSearchResponse clone() => SavingsAccountSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsAccountSearchResponse copyWith(void Function(SavingsAccountSearchResponse) updates) => super.copyWith((message) => updates(message as SavingsAccountSearchResponse)) as SavingsAccountSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsAccountSearchResponse create() => SavingsAccountSearchResponse._();
  SavingsAccountSearchResponse createEmptyInstance() => create();
  static $pb.PbList<SavingsAccountSearchResponse> createRepeated() => $pb.PbList<SavingsAccountSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsAccountSearchResponse>(create);
  static SavingsAccountSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<SavingsAccountObject> get data => $_getList(0);
}

class SavingsAccountFreezeRequest extends $pb.GeneratedMessage {
  factory SavingsAccountFreezeRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  SavingsAccountFreezeRequest._() : super();
  factory SavingsAccountFreezeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsAccountFreezeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsAccountFreezeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsAccountFreezeRequest clone() => SavingsAccountFreezeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsAccountFreezeRequest copyWith(void Function(SavingsAccountFreezeRequest) updates) => super.copyWith((message) => updates(message as SavingsAccountFreezeRequest)) as SavingsAccountFreezeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsAccountFreezeRequest create() => SavingsAccountFreezeRequest._();
  SavingsAccountFreezeRequest createEmptyInstance() => create();
  static $pb.PbList<SavingsAccountFreezeRequest> createRepeated() => $pb.PbList<SavingsAccountFreezeRequest>();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountFreezeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsAccountFreezeRequest>(create);
  static SavingsAccountFreezeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => clearField(2);
}

class SavingsAccountFreezeResponse extends $pb.GeneratedMessage {
  factory SavingsAccountFreezeResponse({
    SavingsAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SavingsAccountFreezeResponse._() : super();
  factory SavingsAccountFreezeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsAccountFreezeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsAccountFreezeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: SavingsAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsAccountFreezeResponse clone() => SavingsAccountFreezeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsAccountFreezeResponse copyWith(void Function(SavingsAccountFreezeResponse) updates) => super.copyWith((message) => updates(message as SavingsAccountFreezeResponse)) as SavingsAccountFreezeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsAccountFreezeResponse create() => SavingsAccountFreezeResponse._();
  SavingsAccountFreezeResponse createEmptyInstance() => create();
  static $pb.PbList<SavingsAccountFreezeResponse> createRepeated() => $pb.PbList<SavingsAccountFreezeResponse>();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountFreezeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsAccountFreezeResponse>(create);
  static SavingsAccountFreezeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  SavingsAccountObject ensureData() => $_ensure(0);
}

class SavingsAccountCloseRequest extends $pb.GeneratedMessage {
  factory SavingsAccountCloseRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  SavingsAccountCloseRequest._() : super();
  factory SavingsAccountCloseRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsAccountCloseRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsAccountCloseRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsAccountCloseRequest clone() => SavingsAccountCloseRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsAccountCloseRequest copyWith(void Function(SavingsAccountCloseRequest) updates) => super.copyWith((message) => updates(message as SavingsAccountCloseRequest)) as SavingsAccountCloseRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsAccountCloseRequest create() => SavingsAccountCloseRequest._();
  SavingsAccountCloseRequest createEmptyInstance() => create();
  static $pb.PbList<SavingsAccountCloseRequest> createRepeated() => $pb.PbList<SavingsAccountCloseRequest>();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountCloseRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsAccountCloseRequest>(create);
  static SavingsAccountCloseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => clearField(2);
}

class SavingsAccountCloseResponse extends $pb.GeneratedMessage {
  factory SavingsAccountCloseResponse({
    SavingsAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SavingsAccountCloseResponse._() : super();
  factory SavingsAccountCloseResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsAccountCloseResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsAccountCloseResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: SavingsAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsAccountCloseResponse clone() => SavingsAccountCloseResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsAccountCloseResponse copyWith(void Function(SavingsAccountCloseResponse) updates) => super.copyWith((message) => updates(message as SavingsAccountCloseResponse)) as SavingsAccountCloseResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsAccountCloseResponse create() => SavingsAccountCloseResponse._();
  SavingsAccountCloseResponse createEmptyInstance() => create();
  static $pb.PbList<SavingsAccountCloseResponse> createRepeated() => $pb.PbList<SavingsAccountCloseResponse>();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountCloseResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsAccountCloseResponse>(create);
  static SavingsAccountCloseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  SavingsAccountObject ensureData() => $_ensure(0);
}

class DepositRecordRequest extends $pb.GeneratedMessage {
  factory DepositRecordRequest({
    $core.String? savingsAccountId,
    $7.Money? amount,
    $core.String? paymentReference,
    $core.String? channel,
    $core.String? payerReference,
    $core.String? idempotencyKey,
  }) {
    final $result = create();
    if (savingsAccountId != null) {
      $result.savingsAccountId = savingsAccountId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (paymentReference != null) {
      $result.paymentReference = paymentReference;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (payerReference != null) {
      $result.payerReference = payerReference;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    return $result;
  }
  DepositRecordRequest._() : super();
  factory DepositRecordRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepositRecordRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepositRecordRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$7.Money>(2, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..aOS(3, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(4, _omitFieldNames ? '' : 'channel')
    ..aOS(5, _omitFieldNames ? '' : 'payerReference')
    ..aOS(6, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepositRecordRequest clone() => DepositRecordRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepositRecordRequest copyWith(void Function(DepositRecordRequest) updates) => super.copyWith((message) => updates(message as DepositRecordRequest)) as DepositRecordRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepositRecordRequest create() => DepositRecordRequest._();
  DepositRecordRequest createEmptyInstance() => create();
  static $pb.PbList<DepositRecordRequest> createRepeated() => $pb.PbList<DepositRecordRequest>();
  @$core.pragma('dart2js:noInline')
  static DepositRecordRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepositRecordRequest>(create);
  static DepositRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => clearField(1);

  @$pb.TagNumber(2)
  $7.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($7.Money v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);
  @$pb.TagNumber(2)
  $7.Money ensureAmount() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get paymentReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set paymentReference($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPaymentReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearPaymentReference() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get channel => $_getSZ(3);
  @$pb.TagNumber(4)
  set channel($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasChannel() => $_has(3);
  @$pb.TagNumber(4)
  void clearChannel() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get payerReference => $_getSZ(4);
  @$pb.TagNumber(5)
  set payerReference($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPayerReference() => $_has(4);
  @$pb.TagNumber(5)
  void clearPayerReference() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get idempotencyKey => $_getSZ(5);
  @$pb.TagNumber(6)
  set idempotencyKey($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIdempotencyKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearIdempotencyKey() => clearField(6);
}

class DepositRecordResponse extends $pb.GeneratedMessage {
  factory DepositRecordResponse({
    DepositObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  DepositRecordResponse._() : super();
  factory DepositRecordResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepositRecordResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepositRecordResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<DepositObject>(1, _omitFieldNames ? '' : 'data', subBuilder: DepositObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepositRecordResponse clone() => DepositRecordResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepositRecordResponse copyWith(void Function(DepositRecordResponse) updates) => super.copyWith((message) => updates(message as DepositRecordResponse)) as DepositRecordResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepositRecordResponse create() => DepositRecordResponse._();
  DepositRecordResponse createEmptyInstance() => create();
  static $pb.PbList<DepositRecordResponse> createRepeated() => $pb.PbList<DepositRecordResponse>();
  @$core.pragma('dart2js:noInline')
  static DepositRecordResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepositRecordResponse>(create);
  static DepositRecordResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DepositObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DepositObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  DepositObject ensureData() => $_ensure(0);
}

class DepositGetRequest extends $pb.GeneratedMessage {
  factory DepositGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DepositGetRequest._() : super();
  factory DepositGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepositGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepositGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepositGetRequest clone() => DepositGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepositGetRequest copyWith(void Function(DepositGetRequest) updates) => super.copyWith((message) => updates(message as DepositGetRequest)) as DepositGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepositGetRequest create() => DepositGetRequest._();
  DepositGetRequest createEmptyInstance() => create();
  static $pb.PbList<DepositGetRequest> createRepeated() => $pb.PbList<DepositGetRequest>();
  @$core.pragma('dart2js:noInline')
  static DepositGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepositGetRequest>(create);
  static DepositGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class DepositGetResponse extends $pb.GeneratedMessage {
  factory DepositGetResponse({
    DepositObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  DepositGetResponse._() : super();
  factory DepositGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepositGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepositGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<DepositObject>(1, _omitFieldNames ? '' : 'data', subBuilder: DepositObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepositGetResponse clone() => DepositGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepositGetResponse copyWith(void Function(DepositGetResponse) updates) => super.copyWith((message) => updates(message as DepositGetResponse)) as DepositGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepositGetResponse create() => DepositGetResponse._();
  DepositGetResponse createEmptyInstance() => create();
  static $pb.PbList<DepositGetResponse> createRepeated() => $pb.PbList<DepositGetResponse>();
  @$core.pragma('dart2js:noInline')
  static DepositGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepositGetResponse>(create);
  static DepositGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DepositObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DepositObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  DepositObject ensureData() => $_ensure(0);
}

class DepositSearchRequest extends $pb.GeneratedMessage {
  factory DepositSearchRequest({
    $core.String? savingsAccountId,
    DepositStatus? status,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (savingsAccountId != null) {
      $result.savingsAccountId = savingsAccountId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  DepositSearchRequest._() : super();
  factory DepositSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepositSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepositSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..e<DepositStatus>(2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: DepositStatus.DEPOSIT_STATUS_UNSPECIFIED, valueOf: DepositStatus.valueOf, enumValues: DepositStatus.values)
    ..aOM<$8.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepositSearchRequest clone() => DepositSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepositSearchRequest copyWith(void Function(DepositSearchRequest) updates) => super.copyWith((message) => updates(message as DepositSearchRequest)) as DepositSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepositSearchRequest create() => DepositSearchRequest._();
  DepositSearchRequest createEmptyInstance() => create();
  static $pb.PbList<DepositSearchRequest> createRepeated() => $pb.PbList<DepositSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static DepositSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepositSearchRequest>(create);
  static DepositSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => clearField(1);

  @$pb.TagNumber(2)
  DepositStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(DepositStatus v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);

  @$pb.TagNumber(3)
  $8.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($8.PageCursor v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => clearField(3);
  @$pb.TagNumber(3)
  $8.PageCursor ensureCursor() => $_ensure(2);
}

class DepositSearchResponse extends $pb.GeneratedMessage {
  factory DepositSearchResponse({
    $core.Iterable<DepositObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  DepositSearchResponse._() : super();
  factory DepositSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepositSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepositSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..pc<DepositObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: DepositObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepositSearchResponse clone() => DepositSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepositSearchResponse copyWith(void Function(DepositSearchResponse) updates) => super.copyWith((message) => updates(message as DepositSearchResponse)) as DepositSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepositSearchResponse create() => DepositSearchResponse._();
  DepositSearchResponse createEmptyInstance() => create();
  static $pb.PbList<DepositSearchResponse> createRepeated() => $pb.PbList<DepositSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static DepositSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepositSearchResponse>(create);
  static DepositSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<DepositObject> get data => $_getList(0);
}

class WithdrawalRequestRequest extends $pb.GeneratedMessage {
  factory WithdrawalRequestRequest({
    $core.String? savingsAccountId,
    $7.Money? amount,
    $core.String? channel,
    $core.String? recipientReference,
    $core.String? reason,
    $core.String? idempotencyKey,
  }) {
    final $result = create();
    if (savingsAccountId != null) {
      $result.savingsAccountId = savingsAccountId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (recipientReference != null) {
      $result.recipientReference = recipientReference;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    return $result;
  }
  WithdrawalRequestRequest._() : super();
  factory WithdrawalRequestRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalRequestRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalRequestRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$7.Money>(2, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..aOS(3, _omitFieldNames ? '' : 'channel')
    ..aOS(4, _omitFieldNames ? '' : 'recipientReference')
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..aOS(6, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalRequestRequest clone() => WithdrawalRequestRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalRequestRequest copyWith(void Function(WithdrawalRequestRequest) updates) => super.copyWith((message) => updates(message as WithdrawalRequestRequest)) as WithdrawalRequestRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalRequestRequest create() => WithdrawalRequestRequest._();
  WithdrawalRequestRequest createEmptyInstance() => create();
  static $pb.PbList<WithdrawalRequestRequest> createRepeated() => $pb.PbList<WithdrawalRequestRequest>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalRequestRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalRequestRequest>(create);
  static WithdrawalRequestRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => clearField(1);

  @$pb.TagNumber(2)
  $7.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($7.Money v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);
  @$pb.TagNumber(2)
  $7.Money ensureAmount() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get channel => $_getSZ(2);
  @$pb.TagNumber(3)
  set channel($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasChannel() => $_has(2);
  @$pb.TagNumber(3)
  void clearChannel() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get recipientReference => $_getSZ(3);
  @$pb.TagNumber(4)
  set recipientReference($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRecipientReference() => $_has(3);
  @$pb.TagNumber(4)
  void clearRecipientReference() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get idempotencyKey => $_getSZ(5);
  @$pb.TagNumber(6)
  set idempotencyKey($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIdempotencyKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearIdempotencyKey() => clearField(6);
}

class WithdrawalRequestResponse extends $pb.GeneratedMessage {
  factory WithdrawalRequestResponse({
    WithdrawalObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  WithdrawalRequestResponse._() : super();
  factory WithdrawalRequestResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalRequestResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalRequestResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<WithdrawalObject>(1, _omitFieldNames ? '' : 'data', subBuilder: WithdrawalObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalRequestResponse clone() => WithdrawalRequestResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalRequestResponse copyWith(void Function(WithdrawalRequestResponse) updates) => super.copyWith((message) => updates(message as WithdrawalRequestResponse)) as WithdrawalRequestResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalRequestResponse create() => WithdrawalRequestResponse._();
  WithdrawalRequestResponse createEmptyInstance() => create();
  static $pb.PbList<WithdrawalRequestResponse> createRepeated() => $pb.PbList<WithdrawalRequestResponse>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalRequestResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalRequestResponse>(create);
  static WithdrawalRequestResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WithdrawalObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WithdrawalObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  WithdrawalObject ensureData() => $_ensure(0);
}

class WithdrawalApproveRequest extends $pb.GeneratedMessage {
  factory WithdrawalApproveRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  WithdrawalApproveRequest._() : super();
  factory WithdrawalApproveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalApproveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalApproveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalApproveRequest clone() => WithdrawalApproveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalApproveRequest copyWith(void Function(WithdrawalApproveRequest) updates) => super.copyWith((message) => updates(message as WithdrawalApproveRequest)) as WithdrawalApproveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalApproveRequest create() => WithdrawalApproveRequest._();
  WithdrawalApproveRequest createEmptyInstance() => create();
  static $pb.PbList<WithdrawalApproveRequest> createRepeated() => $pb.PbList<WithdrawalApproveRequest>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalApproveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalApproveRequest>(create);
  static WithdrawalApproveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class WithdrawalApproveResponse extends $pb.GeneratedMessage {
  factory WithdrawalApproveResponse({
    WithdrawalObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  WithdrawalApproveResponse._() : super();
  factory WithdrawalApproveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalApproveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalApproveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<WithdrawalObject>(1, _omitFieldNames ? '' : 'data', subBuilder: WithdrawalObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalApproveResponse clone() => WithdrawalApproveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalApproveResponse copyWith(void Function(WithdrawalApproveResponse) updates) => super.copyWith((message) => updates(message as WithdrawalApproveResponse)) as WithdrawalApproveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalApproveResponse create() => WithdrawalApproveResponse._();
  WithdrawalApproveResponse createEmptyInstance() => create();
  static $pb.PbList<WithdrawalApproveResponse> createRepeated() => $pb.PbList<WithdrawalApproveResponse>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalApproveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalApproveResponse>(create);
  static WithdrawalApproveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WithdrawalObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WithdrawalObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  WithdrawalObject ensureData() => $_ensure(0);
}

class WithdrawalCancelRequest extends $pb.GeneratedMessage {
  factory WithdrawalCancelRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  WithdrawalCancelRequest._() : super();
  factory WithdrawalCancelRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalCancelRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalCancelRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalCancelRequest clone() => WithdrawalCancelRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalCancelRequest copyWith(void Function(WithdrawalCancelRequest) updates) => super.copyWith((message) => updates(message as WithdrawalCancelRequest)) as WithdrawalCancelRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalCancelRequest create() => WithdrawalCancelRequest._();
  WithdrawalCancelRequest createEmptyInstance() => create();
  static $pb.PbList<WithdrawalCancelRequest> createRepeated() => $pb.PbList<WithdrawalCancelRequest>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalCancelRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalCancelRequest>(create);
  static WithdrawalCancelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => clearField(2);
}

class WithdrawalCancelResponse extends $pb.GeneratedMessage {
  factory WithdrawalCancelResponse({
    WithdrawalObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  WithdrawalCancelResponse._() : super();
  factory WithdrawalCancelResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalCancelResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalCancelResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<WithdrawalObject>(1, _omitFieldNames ? '' : 'data', subBuilder: WithdrawalObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalCancelResponse clone() => WithdrawalCancelResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalCancelResponse copyWith(void Function(WithdrawalCancelResponse) updates) => super.copyWith((message) => updates(message as WithdrawalCancelResponse)) as WithdrawalCancelResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalCancelResponse create() => WithdrawalCancelResponse._();
  WithdrawalCancelResponse createEmptyInstance() => create();
  static $pb.PbList<WithdrawalCancelResponse> createRepeated() => $pb.PbList<WithdrawalCancelResponse>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalCancelResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalCancelResponse>(create);
  static WithdrawalCancelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WithdrawalObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WithdrawalObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  WithdrawalObject ensureData() => $_ensure(0);
}

class WithdrawalGetRequest extends $pb.GeneratedMessage {
  factory WithdrawalGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  WithdrawalGetRequest._() : super();
  factory WithdrawalGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalGetRequest clone() => WithdrawalGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalGetRequest copyWith(void Function(WithdrawalGetRequest) updates) => super.copyWith((message) => updates(message as WithdrawalGetRequest)) as WithdrawalGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalGetRequest create() => WithdrawalGetRequest._();
  WithdrawalGetRequest createEmptyInstance() => create();
  static $pb.PbList<WithdrawalGetRequest> createRepeated() => $pb.PbList<WithdrawalGetRequest>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalGetRequest>(create);
  static WithdrawalGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class WithdrawalGetResponse extends $pb.GeneratedMessage {
  factory WithdrawalGetResponse({
    WithdrawalObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  WithdrawalGetResponse._() : super();
  factory WithdrawalGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<WithdrawalObject>(1, _omitFieldNames ? '' : 'data', subBuilder: WithdrawalObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalGetResponse clone() => WithdrawalGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalGetResponse copyWith(void Function(WithdrawalGetResponse) updates) => super.copyWith((message) => updates(message as WithdrawalGetResponse)) as WithdrawalGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalGetResponse create() => WithdrawalGetResponse._();
  WithdrawalGetResponse createEmptyInstance() => create();
  static $pb.PbList<WithdrawalGetResponse> createRepeated() => $pb.PbList<WithdrawalGetResponse>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalGetResponse>(create);
  static WithdrawalGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WithdrawalObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WithdrawalObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  WithdrawalObject ensureData() => $_ensure(0);
}

class WithdrawalSearchRequest extends $pb.GeneratedMessage {
  factory WithdrawalSearchRequest({
    $core.String? savingsAccountId,
    WithdrawalStatus? status,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (savingsAccountId != null) {
      $result.savingsAccountId = savingsAccountId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  WithdrawalSearchRequest._() : super();
  factory WithdrawalSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..e<WithdrawalStatus>(2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: WithdrawalStatus.WITHDRAWAL_STATUS_UNSPECIFIED, valueOf: WithdrawalStatus.valueOf, enumValues: WithdrawalStatus.values)
    ..aOM<$8.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalSearchRequest clone() => WithdrawalSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalSearchRequest copyWith(void Function(WithdrawalSearchRequest) updates) => super.copyWith((message) => updates(message as WithdrawalSearchRequest)) as WithdrawalSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalSearchRequest create() => WithdrawalSearchRequest._();
  WithdrawalSearchRequest createEmptyInstance() => create();
  static $pb.PbList<WithdrawalSearchRequest> createRepeated() => $pb.PbList<WithdrawalSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalSearchRequest>(create);
  static WithdrawalSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => clearField(1);

  @$pb.TagNumber(2)
  WithdrawalStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(WithdrawalStatus v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);

  @$pb.TagNumber(3)
  $8.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($8.PageCursor v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => clearField(3);
  @$pb.TagNumber(3)
  $8.PageCursor ensureCursor() => $_ensure(2);
}

class WithdrawalSearchResponse extends $pb.GeneratedMessage {
  factory WithdrawalSearchResponse({
    $core.Iterable<WithdrawalObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  WithdrawalSearchResponse._() : super();
  factory WithdrawalSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..pc<WithdrawalObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: WithdrawalObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalSearchResponse clone() => WithdrawalSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalSearchResponse copyWith(void Function(WithdrawalSearchResponse) updates) => super.copyWith((message) => updates(message as WithdrawalSearchResponse)) as WithdrawalSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalSearchResponse create() => WithdrawalSearchResponse._();
  WithdrawalSearchResponse createEmptyInstance() => create();
  static $pb.PbList<WithdrawalSearchResponse> createRepeated() => $pb.PbList<WithdrawalSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalSearchResponse>(create);
  static WithdrawalSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<WithdrawalObject> get data => $_getList(0);
}

class InterestAccrualGetRequest extends $pb.GeneratedMessage {
  factory InterestAccrualGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  InterestAccrualGetRequest._() : super();
  factory InterestAccrualGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InterestAccrualGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InterestAccrualGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InterestAccrualGetRequest clone() => InterestAccrualGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InterestAccrualGetRequest copyWith(void Function(InterestAccrualGetRequest) updates) => super.copyWith((message) => updates(message as InterestAccrualGetRequest)) as InterestAccrualGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InterestAccrualGetRequest create() => InterestAccrualGetRequest._();
  InterestAccrualGetRequest createEmptyInstance() => create();
  static $pb.PbList<InterestAccrualGetRequest> createRepeated() => $pb.PbList<InterestAccrualGetRequest>();
  @$core.pragma('dart2js:noInline')
  static InterestAccrualGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InterestAccrualGetRequest>(create);
  static InterestAccrualGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class InterestAccrualGetResponse extends $pb.GeneratedMessage {
  factory InterestAccrualGetResponse({
    InterestAccrualObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InterestAccrualGetResponse._() : super();
  factory InterestAccrualGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InterestAccrualGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InterestAccrualGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<InterestAccrualObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InterestAccrualObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InterestAccrualGetResponse clone() => InterestAccrualGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InterestAccrualGetResponse copyWith(void Function(InterestAccrualGetResponse) updates) => super.copyWith((message) => updates(message as InterestAccrualGetResponse)) as InterestAccrualGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InterestAccrualGetResponse create() => InterestAccrualGetResponse._();
  InterestAccrualGetResponse createEmptyInstance() => create();
  static $pb.PbList<InterestAccrualGetResponse> createRepeated() => $pb.PbList<InterestAccrualGetResponse>();
  @$core.pragma('dart2js:noInline')
  static InterestAccrualGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InterestAccrualGetResponse>(create);
  static InterestAccrualGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InterestAccrualObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InterestAccrualObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InterestAccrualObject ensureData() => $_ensure(0);
}

class InterestAccrualSearchRequest extends $pb.GeneratedMessage {
  factory InterestAccrualSearchRequest({
    $core.String? savingsAccountId,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (savingsAccountId != null) {
      $result.savingsAccountId = savingsAccountId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  InterestAccrualSearchRequest._() : super();
  factory InterestAccrualSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InterestAccrualSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InterestAccrualSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$8.PageCursor>(2, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InterestAccrualSearchRequest clone() => InterestAccrualSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InterestAccrualSearchRequest copyWith(void Function(InterestAccrualSearchRequest) updates) => super.copyWith((message) => updates(message as InterestAccrualSearchRequest)) as InterestAccrualSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InterestAccrualSearchRequest create() => InterestAccrualSearchRequest._();
  InterestAccrualSearchRequest createEmptyInstance() => create();
  static $pb.PbList<InterestAccrualSearchRequest> createRepeated() => $pb.PbList<InterestAccrualSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static InterestAccrualSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InterestAccrualSearchRequest>(create);
  static InterestAccrualSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => clearField(1);

  @$pb.TagNumber(2)
  $8.PageCursor get cursor => $_getN(1);
  @$pb.TagNumber(2)
  set cursor($8.PageCursor v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => clearField(2);
  @$pb.TagNumber(2)
  $8.PageCursor ensureCursor() => $_ensure(1);
}

class InterestAccrualSearchResponse extends $pb.GeneratedMessage {
  factory InterestAccrualSearchResponse({
    $core.Iterable<InterestAccrualObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  InterestAccrualSearchResponse._() : super();
  factory InterestAccrualSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InterestAccrualSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InterestAccrualSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..pc<InterestAccrualObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: InterestAccrualObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InterestAccrualSearchResponse clone() => InterestAccrualSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InterestAccrualSearchResponse copyWith(void Function(InterestAccrualSearchResponse) updates) => super.copyWith((message) => updates(message as InterestAccrualSearchResponse)) as InterestAccrualSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InterestAccrualSearchResponse create() => InterestAccrualSearchResponse._();
  InterestAccrualSearchResponse createEmptyInstance() => create();
  static $pb.PbList<InterestAccrualSearchResponse> createRepeated() => $pb.PbList<InterestAccrualSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static InterestAccrualSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InterestAccrualSearchResponse>(create);
  static InterestAccrualSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<InterestAccrualObject> get data => $_getList(0);
}

class SavingsBalanceGetRequest extends $pb.GeneratedMessage {
  factory SavingsBalanceGetRequest({
    $core.String? savingsAccountId,
  }) {
    final $result = create();
    if (savingsAccountId != null) {
      $result.savingsAccountId = savingsAccountId;
    }
    return $result;
  }
  SavingsBalanceGetRequest._() : super();
  factory SavingsBalanceGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsBalanceGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsBalanceGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsBalanceGetRequest clone() => SavingsBalanceGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsBalanceGetRequest copyWith(void Function(SavingsBalanceGetRequest) updates) => super.copyWith((message) => updates(message as SavingsBalanceGetRequest)) as SavingsBalanceGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsBalanceGetRequest create() => SavingsBalanceGetRequest._();
  SavingsBalanceGetRequest createEmptyInstance() => create();
  static $pb.PbList<SavingsBalanceGetRequest> createRepeated() => $pb.PbList<SavingsBalanceGetRequest>();
  @$core.pragma('dart2js:noInline')
  static SavingsBalanceGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsBalanceGetRequest>(create);
  static SavingsBalanceGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => clearField(1);
}

class SavingsBalanceGetResponse extends $pb.GeneratedMessage {
  factory SavingsBalanceGetResponse({
    SavingsBalanceObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SavingsBalanceGetResponse._() : super();
  factory SavingsBalanceGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsBalanceGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsBalanceGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<SavingsBalanceObject>(1, _omitFieldNames ? '' : 'data', subBuilder: SavingsBalanceObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsBalanceGetResponse clone() => SavingsBalanceGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsBalanceGetResponse copyWith(void Function(SavingsBalanceGetResponse) updates) => super.copyWith((message) => updates(message as SavingsBalanceGetResponse)) as SavingsBalanceGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsBalanceGetResponse create() => SavingsBalanceGetResponse._();
  SavingsBalanceGetResponse createEmptyInstance() => create();
  static $pb.PbList<SavingsBalanceGetResponse> createRepeated() => $pb.PbList<SavingsBalanceGetResponse>();
  @$core.pragma('dart2js:noInline')
  static SavingsBalanceGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsBalanceGetResponse>(create);
  static SavingsBalanceGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsBalanceObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsBalanceObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  SavingsBalanceObject ensureData() => $_ensure(0);
}

class SavingsStatementRequest extends $pb.GeneratedMessage {
  factory SavingsStatementRequest({
    $core.String? savingsAccountId,
    $core.String? fromDate,
    $core.String? toDate,
  }) {
    final $result = create();
    if (savingsAccountId != null) {
      $result.savingsAccountId = savingsAccountId;
    }
    if (fromDate != null) {
      $result.fromDate = fromDate;
    }
    if (toDate != null) {
      $result.toDate = toDate;
    }
    return $result;
  }
  SavingsStatementRequest._() : super();
  factory SavingsStatementRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsStatementRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsStatementRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOS(2, _omitFieldNames ? '' : 'fromDate')
    ..aOS(3, _omitFieldNames ? '' : 'toDate')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsStatementRequest clone() => SavingsStatementRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsStatementRequest copyWith(void Function(SavingsStatementRequest) updates) => super.copyWith((message) => updates(message as SavingsStatementRequest)) as SavingsStatementRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsStatementRequest create() => SavingsStatementRequest._();
  SavingsStatementRequest createEmptyInstance() => create();
  static $pb.PbList<SavingsStatementRequest> createRepeated() => $pb.PbList<SavingsStatementRequest>();
  @$core.pragma('dart2js:noInline')
  static SavingsStatementRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsStatementRequest>(create);
  static SavingsStatementRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get fromDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set fromDate($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFromDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromDate() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get toDate => $_getSZ(2);
  @$pb.TagNumber(3)
  set toDate($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasToDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearToDate() => clearField(3);
}

class SavingsStatementResponse extends $pb.GeneratedMessage {
  factory SavingsStatementResponse({
    SavingsAccountObject? account,
    SavingsBalanceObject? balance,
    $core.Iterable<SavingsStatementEntry>? entries,
  }) {
    final $result = create();
    if (account != null) {
      $result.account = account;
    }
    if (balance != null) {
      $result.balance = balance;
    }
    if (entries != null) {
      $result.entries.addAll(entries);
    }
    return $result;
  }
  SavingsStatementResponse._() : super();
  factory SavingsStatementResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SavingsStatementResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SavingsStatementResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'), createEmptyInstance: create)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'account', subBuilder: SavingsAccountObject.create)
    ..aOM<SavingsBalanceObject>(2, _omitFieldNames ? '' : 'balance', subBuilder: SavingsBalanceObject.create)
    ..pc<SavingsStatementEntry>(3, _omitFieldNames ? '' : 'entries', $pb.PbFieldType.PM, subBuilder: SavingsStatementEntry.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SavingsStatementResponse clone() => SavingsStatementResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SavingsStatementResponse copyWith(void Function(SavingsStatementResponse) updates) => super.copyWith((message) => updates(message as SavingsStatementResponse)) as SavingsStatementResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavingsStatementResponse create() => SavingsStatementResponse._();
  SavingsStatementResponse createEmptyInstance() => create();
  static $pb.PbList<SavingsStatementResponse> createRepeated() => $pb.PbList<SavingsStatementResponse>();
  @$core.pragma('dart2js:noInline')
  static SavingsStatementResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SavingsStatementResponse>(create);
  static SavingsStatementResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get account => $_getN(0);
  @$pb.TagNumber(1)
  set account(SavingsAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccount() => clearField(1);
  @$pb.TagNumber(1)
  SavingsAccountObject ensureAccount() => $_ensure(0);

  @$pb.TagNumber(2)
  SavingsBalanceObject get balance => $_getN(1);
  @$pb.TagNumber(2)
  set balance(SavingsBalanceObject v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasBalance() => $_has(1);
  @$pb.TagNumber(2)
  void clearBalance() => clearField(2);
  @$pb.TagNumber(2)
  SavingsBalanceObject ensureBalance() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.List<SavingsStatementEntry> get entries => $_getList(2);
}

class SavingsServiceApi {
  $pb.RpcClient _client;
  SavingsServiceApi(this._client);

  $async.Future<SavingsProductSaveResponse> savingsProductSave($pb.ClientContext? ctx, SavingsProductSaveRequest request) =>
    _client.invoke<SavingsProductSaveResponse>(ctx, 'SavingsService', 'SavingsProductSave', request, SavingsProductSaveResponse())
  ;
  $async.Future<SavingsProductGetResponse> savingsProductGet($pb.ClientContext? ctx, SavingsProductGetRequest request) =>
    _client.invoke<SavingsProductGetResponse>(ctx, 'SavingsService', 'SavingsProductGet', request, SavingsProductGetResponse())
  ;
  $async.Future<SavingsProductSearchResponse> savingsProductSearch($pb.ClientContext? ctx, SavingsProductSearchRequest request) =>
    _client.invoke<SavingsProductSearchResponse>(ctx, 'SavingsService', 'SavingsProductSearch', request, SavingsProductSearchResponse())
  ;
  $async.Future<SavingsAccountCreateResponse> savingsAccountCreate($pb.ClientContext? ctx, SavingsAccountCreateRequest request) =>
    _client.invoke<SavingsAccountCreateResponse>(ctx, 'SavingsService', 'SavingsAccountCreate', request, SavingsAccountCreateResponse())
  ;
  $async.Future<SavingsAccountGetResponse> savingsAccountGet($pb.ClientContext? ctx, SavingsAccountGetRequest request) =>
    _client.invoke<SavingsAccountGetResponse>(ctx, 'SavingsService', 'SavingsAccountGet', request, SavingsAccountGetResponse())
  ;
  $async.Future<SavingsAccountSearchResponse> savingsAccountSearch($pb.ClientContext? ctx, SavingsAccountSearchRequest request) =>
    _client.invoke<SavingsAccountSearchResponse>(ctx, 'SavingsService', 'SavingsAccountSearch', request, SavingsAccountSearchResponse())
  ;
  $async.Future<SavingsAccountFreezeResponse> savingsAccountFreeze($pb.ClientContext? ctx, SavingsAccountFreezeRequest request) =>
    _client.invoke<SavingsAccountFreezeResponse>(ctx, 'SavingsService', 'SavingsAccountFreeze', request, SavingsAccountFreezeResponse())
  ;
  $async.Future<SavingsAccountCloseResponse> savingsAccountClose($pb.ClientContext? ctx, SavingsAccountCloseRequest request) =>
    _client.invoke<SavingsAccountCloseResponse>(ctx, 'SavingsService', 'SavingsAccountClose', request, SavingsAccountCloseResponse())
  ;
  $async.Future<DepositRecordResponse> depositRecord($pb.ClientContext? ctx, DepositRecordRequest request) =>
    _client.invoke<DepositRecordResponse>(ctx, 'SavingsService', 'DepositRecord', request, DepositRecordResponse())
  ;
  $async.Future<DepositGetResponse> depositGet($pb.ClientContext? ctx, DepositGetRequest request) =>
    _client.invoke<DepositGetResponse>(ctx, 'SavingsService', 'DepositGet', request, DepositGetResponse())
  ;
  $async.Future<DepositSearchResponse> depositSearch($pb.ClientContext? ctx, DepositSearchRequest request) =>
    _client.invoke<DepositSearchResponse>(ctx, 'SavingsService', 'DepositSearch', request, DepositSearchResponse())
  ;
  $async.Future<WithdrawalRequestResponse> withdrawalRequest($pb.ClientContext? ctx, WithdrawalRequestRequest request) =>
    _client.invoke<WithdrawalRequestResponse>(ctx, 'SavingsService', 'WithdrawalRequest', request, WithdrawalRequestResponse())
  ;
  $async.Future<WithdrawalApproveResponse> withdrawalApprove($pb.ClientContext? ctx, WithdrawalApproveRequest request) =>
    _client.invoke<WithdrawalApproveResponse>(ctx, 'SavingsService', 'WithdrawalApprove', request, WithdrawalApproveResponse())
  ;
  $async.Future<WithdrawalCancelResponse> withdrawalCancel($pb.ClientContext? ctx, WithdrawalCancelRequest request) =>
    _client.invoke<WithdrawalCancelResponse>(ctx, 'SavingsService', 'WithdrawalCancel', request, WithdrawalCancelResponse())
  ;
  $async.Future<WithdrawalGetResponse> withdrawalGet($pb.ClientContext? ctx, WithdrawalGetRequest request) =>
    _client.invoke<WithdrawalGetResponse>(ctx, 'SavingsService', 'WithdrawalGet', request, WithdrawalGetResponse())
  ;
  $async.Future<WithdrawalSearchResponse> withdrawalSearch($pb.ClientContext? ctx, WithdrawalSearchRequest request) =>
    _client.invoke<WithdrawalSearchResponse>(ctx, 'SavingsService', 'WithdrawalSearch', request, WithdrawalSearchResponse())
  ;
  $async.Future<InterestAccrualGetResponse> interestAccrualGet($pb.ClientContext? ctx, InterestAccrualGetRequest request) =>
    _client.invoke<InterestAccrualGetResponse>(ctx, 'SavingsService', 'InterestAccrualGet', request, InterestAccrualGetResponse())
  ;
  $async.Future<InterestAccrualSearchResponse> interestAccrualSearch($pb.ClientContext? ctx, InterestAccrualSearchRequest request) =>
    _client.invoke<InterestAccrualSearchResponse>(ctx, 'SavingsService', 'InterestAccrualSearch', request, InterestAccrualSearchResponse())
  ;
  $async.Future<SavingsBalanceGetResponse> savingsBalanceGet($pb.ClientContext? ctx, SavingsBalanceGetRequest request) =>
    _client.invoke<SavingsBalanceGetResponse>(ctx, 'SavingsService', 'SavingsBalanceGet', request, SavingsBalanceGetResponse())
  ;
  $async.Future<SavingsStatementResponse> savingsStatement($pb.ClientContext? ctx, SavingsStatementRequest request) =>
    _client.invoke<SavingsStatementResponse>(ctx, 'SavingsService', 'SavingsStatement', request, SavingsStatementResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
