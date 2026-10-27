// This is a generated file - do not edit.
//
// Generated from savings/v1/savings.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $1;

import '../../common/v1/common.pb.dart' as $2;
import '../../common/v1/money.pb.dart' as $0;
import 'savings.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'savings.pbenum.dart';

class SavingsJobRunRequest extends $pb.GeneratedMessage {
  factory SavingsJobRunRequest({
    SavingsJob? job,
    $core.int? batchSize,
  }) {
    final result = SavingsJobRunRequest._();
    if (job != null) result.job = job;
    if (batchSize != null) result.batchSize = batchSize;
    return result;
  }

  SavingsJobRunRequest._();

  factory SavingsJobRunRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsJobRunRequest()..mergeFromBuffer(data, registry);
  factory SavingsJobRunRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsJobRunRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsJobRunRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsJobRunRequest.$_createMessage)
    ..aE<SavingsJob>(1, _omitFieldNames ? '' : 'job',
        enumValues: SavingsJob.values)
    ..aI(2, _omitFieldNames ? '' : 'batchSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsJobRunRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsJobRunRequest copyWith(void Function(SavingsJobRunRequest) updates) =>
      super.copyWith((message) => updates(message as SavingsJobRunRequest))
          as SavingsJobRunRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsJobRunRequest() / SavingsJobRunRequest.new instead')
  static SavingsJobRunRequest create() => SavingsJobRunRequest._();
  static $pb.GeneratedMessage $_createMessage() => SavingsJobRunRequest._();
  @$core.override
  SavingsJobRunRequest createEmptyInstance() => SavingsJobRunRequest._();
  @$core.pragma('dart2js:noInline')
  static SavingsJobRunRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsJobRunRequest>(
          SavingsJobRunRequest.$_createMessage);
  static SavingsJobRunRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsJob get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(SavingsJob value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);

  /// Most items to process in this run. 0 uses the service default.
  @$pb.TagNumber(2)
  $core.int get batchSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set batchSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBatchSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearBatchSize() => $_clearField(2);
}

class SavingsJobRunResponse extends $pb.GeneratedMessage {
  factory SavingsJobRunResponse({
    $core.int? processed,
    $core.bool? more,
  }) {
    final result = SavingsJobRunResponse._();
    if (processed != null) result.processed = processed;
    if (more != null) result.more = more;
    return result;
  }

  SavingsJobRunResponse._();

  factory SavingsJobRunResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsJobRunResponse()..mergeFromBuffer(data, registry);
  factory SavingsJobRunResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsJobRunResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsJobRunResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsJobRunResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'processed')
    ..aOB(2, _omitFieldNames ? '' : 'more')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsJobRunResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsJobRunResponse copyWith(
          void Function(SavingsJobRunResponse) updates) =>
      super.copyWith((message) => updates(message as SavingsJobRunResponse))
          as SavingsJobRunResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsJobRunResponse() / SavingsJobRunResponse.new instead')
  static SavingsJobRunResponse create() => SavingsJobRunResponse._();
  static $pb.GeneratedMessage $_createMessage() => SavingsJobRunResponse._();
  @$core.override
  SavingsJobRunResponse createEmptyInstance() => SavingsJobRunResponse._();
  @$core.pragma('dart2js:noInline')
  static SavingsJobRunResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsJobRunResponse>(
          SavingsJobRunResponse.$_createMessage);
  static SavingsJobRunResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get processed => $_getIZ(0);
  @$pb.TagNumber(1)
  set processed($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProcessed() => $_has(0);
  @$pb.TagNumber(1)
  void clearProcessed() => $_clearField(1);

  /// True when the batch was full and more work may be waiting.
  @$pb.TagNumber(2)
  $core.bool get more => $_getBF(1);
  @$pb.TagNumber(2)
  set more($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMore() => $_has(1);
  @$pb.TagNumber(2)
  void clearMore() => $_clearField(2);
}

/// PayoutFailedApplyRequest tells the service that originated a payout that
/// the payment rail failed it after accepting it. Operations has already
/// reversed the ledger leg; the originator undoes its own record. Applying
/// it again changes nothing.
class PayoutFailedApplyRequest extends $pb.GeneratedMessage {
  factory PayoutFailedApplyRequest({
    $core.String? reference,
    $core.String? reason,
  }) {
    final result = PayoutFailedApplyRequest._();
    if (reference != null) result.reference = reference;
    if (reason != null) result.reason = reason;
    return result;
  }

  PayoutFailedApplyRequest._();

  factory PayoutFailedApplyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PayoutFailedApplyRequest()..mergeFromBuffer(data, registry);
  factory PayoutFailedApplyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PayoutFailedApplyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PayoutFailedApplyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: PayoutFailedApplyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'reference')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PayoutFailedApplyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PayoutFailedApplyRequest copyWith(
          void Function(PayoutFailedApplyRequest) updates) =>
      super.copyWith((message) => updates(message as PayoutFailedApplyRequest))
          as PayoutFailedApplyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PayoutFailedApplyRequest() / PayoutFailedApplyRequest.new instead')
  static PayoutFailedApplyRequest create() => PayoutFailedApplyRequest._();
  static $pb.GeneratedMessage $_createMessage() => PayoutFailedApplyRequest._();
  @$core.override
  PayoutFailedApplyRequest createEmptyInstance() =>
      PayoutFailedApplyRequest._();
  @$core.pragma('dart2js:noInline')
  static PayoutFailedApplyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PayoutFailedApplyRequest>(
          PayoutFailedApplyRequest.$_createMessage);
  static PayoutFailedApplyRequest? _defaultInstance;

  /// The transfer order reference the originator gave the payout.
  @$pb.TagNumber(1)
  $core.String get reference => $_getSZ(0);
  @$pb.TagNumber(1)
  set reference($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReference() => $_has(0);
  @$pb.TagNumber(1)
  void clearReference() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class PayoutFailedApplyResponse extends $pb.GeneratedMessage {
  factory PayoutFailedApplyResponse({
    $core.bool? applied,
  }) {
    final result = PayoutFailedApplyResponse._();
    if (applied != null) result.applied = applied;
    return result;
  }

  PayoutFailedApplyResponse._();

  factory PayoutFailedApplyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PayoutFailedApplyResponse()..mergeFromBuffer(data, registry);
  factory PayoutFailedApplyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PayoutFailedApplyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PayoutFailedApplyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: PayoutFailedApplyResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'applied')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PayoutFailedApplyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PayoutFailedApplyResponse copyWith(
          void Function(PayoutFailedApplyResponse) updates) =>
      super.copyWith((message) => updates(message as PayoutFailedApplyResponse))
          as PayoutFailedApplyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PayoutFailedApplyResponse() / PayoutFailedApplyResponse.new instead')
  static PayoutFailedApplyResponse create() => PayoutFailedApplyResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      PayoutFailedApplyResponse._();
  @$core.override
  PayoutFailedApplyResponse createEmptyInstance() =>
      PayoutFailedApplyResponse._();
  @$core.pragma('dart2js:noInline')
  static PayoutFailedApplyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PayoutFailedApplyResponse>(
          PayoutFailedApplyResponse.$_createMessage);
  static PayoutFailedApplyResponse? _defaultInstance;

  /// True when this call undid the record; false when it was already undone
  /// or the reference is not this service's.
  @$pb.TagNumber(1)
  $core.bool get applied => $_getBF(0);
  @$pb.TagNumber(1)
  set applied($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasApplied() => $_has(0);
  @$pb.TagNumber(1)
  void clearApplied() => $_clearField(1);
}

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
    $0.Money? minDeposit,
    $0.Money? maxDeposit,
    $1.Struct? withdrawalRules,
    $2.STATE? state,
    $1.Struct? properties,
  }) {
    final result = SavingsProductObject._();
    if (id != null) result.id = id;
    if (organizationId != null) result.organizationId = organizationId;
    if (name != null) result.name = name;
    if (code != null) result.code = code;
    if (description != null) result.description = description;
    if (currencyCode != null) result.currencyCode = currencyCode;
    if (interestRate != null) result.interestRate = interestRate;
    if (compoundingFrequency != null)
      result.compoundingFrequency = compoundingFrequency;
    if (periodType != null) result.periodType = periodType;
    if (minDeposit != null) result.minDeposit = minDeposit;
    if (maxDeposit != null) result.maxDeposit = maxDeposit;
    if (withdrawalRules != null) result.withdrawalRules = withdrawalRules;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  SavingsProductObject._();

  factory SavingsProductObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductObject()..mergeFromBuffer(data, registry);
  factory SavingsProductObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsProductObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsProductObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'code')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aOS(6, _omitFieldNames ? '' : 'currencyCode')
    ..aOS(7, _omitFieldNames ? '' : 'interestRate')
    ..aE<CompoundingFrequency>(8, _omitFieldNames ? '' : 'compoundingFrequency',
        enumValues: CompoundingFrequency.values)
    ..aE<SavingsPeriodType>(9, _omitFieldNames ? '' : 'periodType',
        enumValues: SavingsPeriodType.values)
    ..aOM<$0.Money>(10, _omitFieldNames ? '' : 'minDeposit',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(11, _omitFieldNames ? '' : 'maxDeposit',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$1.Struct>(12, _omitFieldNames ? '' : 'withdrawalRules',
        subBuilder: $1.Struct.$_createMessage)
    ..aE<$2.STATE>(13, _omitFieldNames ? '' : 'state',
        enumValues: $2.STATE.values)
    ..aOM<$1.Struct>(14, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductObject copyWith(void Function(SavingsProductObject) updates) =>
      super.copyWith((message) => updates(message as SavingsProductObject))
          as SavingsProductObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsProductObject() / SavingsProductObject.new instead')
  static SavingsProductObject create() => SavingsProductObject._();
  static $pb.GeneratedMessage $_createMessage() => SavingsProductObject._();
  @$core.override
  SavingsProductObject createEmptyInstance() => SavingsProductObject._();
  @$core.pragma('dart2js:noInline')
  static SavingsProductObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsProductObject>(
          SavingsProductObject.$_createMessage);
  static SavingsProductObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get organizationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set organizationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOrganizationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrganizationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get code => $_getSZ(3);
  @$pb.TagNumber(4)
  set code($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearCode() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get currencyCode => $_getSZ(5);
  @$pb.TagNumber(6)
  set currencyCode($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCurrencyCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCurrencyCode() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get interestRate => $_getSZ(6);
  @$pb.TagNumber(7)
  set interestRate($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasInterestRate() => $_has(6);
  @$pb.TagNumber(7)
  void clearInterestRate() => $_clearField(7);

  @$pb.TagNumber(8)
  CompoundingFrequency get compoundingFrequency => $_getN(7);
  @$pb.TagNumber(8)
  set compoundingFrequency(CompoundingFrequency value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCompoundingFrequency() => $_has(7);
  @$pb.TagNumber(8)
  void clearCompoundingFrequency() => $_clearField(8);

  @$pb.TagNumber(9)
  SavingsPeriodType get periodType => $_getN(8);
  @$pb.TagNumber(9)
  set periodType(SavingsPeriodType value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPeriodType() => $_has(8);
  @$pb.TagNumber(9)
  void clearPeriodType() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Money get minDeposit => $_getN(9);
  @$pb.TagNumber(10)
  set minDeposit($0.Money value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasMinDeposit() => $_has(9);
  @$pb.TagNumber(10)
  void clearMinDeposit() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Money ensureMinDeposit() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Money get maxDeposit => $_getN(10);
  @$pb.TagNumber(11)
  set maxDeposit($0.Money value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasMaxDeposit() => $_has(10);
  @$pb.TagNumber(11)
  void clearMaxDeposit() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Money ensureMaxDeposit() => $_ensure(10);

  @$pb.TagNumber(12)
  $1.Struct get withdrawalRules => $_getN(11);
  @$pb.TagNumber(12)
  set withdrawalRules($1.Struct value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasWithdrawalRules() => $_has(11);
  @$pb.TagNumber(12)
  void clearWithdrawalRules() => $_clearField(12);
  @$pb.TagNumber(12)
  $1.Struct ensureWithdrawalRules() => $_ensure(11);

  @$pb.TagNumber(13)
  $2.STATE get state => $_getN(12);
  @$pb.TagNumber(13)
  set state($2.STATE value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasState() => $_has(12);
  @$pb.TagNumber(13)
  void clearState() => $_clearField(13);

  @$pb.TagNumber(14)
  $1.Struct get properties => $_getN(13);
  @$pb.TagNumber(14)
  set properties($1.Struct value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasProperties() => $_has(13);
  @$pb.TagNumber(14)
  void clearProperties() => $_clearField(14);
  @$pb.TagNumber(14)
  $1.Struct ensureProperties() => $_ensure(13);
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
    $1.Struct? properties,
  }) {
    final result = SavingsAccountObject._();
    if (id != null) result.id = id;
    if (productId != null) result.productId = productId;
    if (ownerId != null) result.ownerId = ownerId;
    if (ownerType != null) result.ownerType = ownerType;
    if (organizationId != null) result.organizationId = organizationId;
    if (branchId != null) result.branchId = branchId;
    if (agentId != null) result.agentId = agentId;
    if (currencyCode != null) result.currencyCode = currencyCode;
    if (status != null) result.status = status;
    if (ledgerAccountId != null) result.ledgerAccountId = ledgerAccountId;
    if (paymentAccountRef != null) result.paymentAccountRef = paymentAccountRef;
    if (properties != null) result.properties = properties;
    return result;
  }

  SavingsAccountObject._();

  factory SavingsAccountObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountObject()..mergeFromBuffer(data, registry);
  factory SavingsAccountObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsAccountObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsAccountObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productId')
    ..aOS(3, _omitFieldNames ? '' : 'ownerId')
    ..aE<SavingsAccountOwnerType>(4, _omitFieldNames ? '' : 'ownerType',
        enumValues: SavingsAccountOwnerType.values)
    ..aOS(5, _omitFieldNames ? '' : 'organizationId')
    ..aOS(6, _omitFieldNames ? '' : 'branchId')
    ..aOS(7, _omitFieldNames ? '' : 'agentId')
    ..aOS(8, _omitFieldNames ? '' : 'currencyCode')
    ..aE<SavingsAccountStatus>(9, _omitFieldNames ? '' : 'status',
        enumValues: SavingsAccountStatus.values)
    ..aOS(10, _omitFieldNames ? '' : 'ledgerAccountId')
    ..aOS(11, _omitFieldNames ? '' : 'paymentAccountRef')
    ..aOM<$1.Struct>(12, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountObject copyWith(void Function(SavingsAccountObject) updates) =>
      super.copyWith((message) => updates(message as SavingsAccountObject))
          as SavingsAccountObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsAccountObject() / SavingsAccountObject.new instead')
  static SavingsAccountObject create() => SavingsAccountObject._();
  static $pb.GeneratedMessage $_createMessage() => SavingsAccountObject._();
  @$core.override
  SavingsAccountObject createEmptyInstance() => SavingsAccountObject._();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsAccountObject>(
          SavingsAccountObject.$_createMessage);
  static SavingsAccountObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get productId => $_getSZ(1);
  @$pb.TagNumber(2)
  set productId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ownerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ownerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOwnerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOwnerId() => $_clearField(3);

  @$pb.TagNumber(4)
  SavingsAccountOwnerType get ownerType => $_getN(3);
  @$pb.TagNumber(4)
  set ownerType(SavingsAccountOwnerType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasOwnerType() => $_has(3);
  @$pb.TagNumber(4)
  void clearOwnerType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get organizationId => $_getSZ(4);
  @$pb.TagNumber(5)
  set organizationId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOrganizationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOrganizationId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get branchId => $_getSZ(5);
  @$pb.TagNumber(6)
  set branchId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBranchId() => $_has(5);
  @$pb.TagNumber(6)
  void clearBranchId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get agentId => $_getSZ(6);
  @$pb.TagNumber(7)
  set agentId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAgentId() => $_has(6);
  @$pb.TagNumber(7)
  void clearAgentId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get currencyCode => $_getSZ(7);
  @$pb.TagNumber(8)
  set currencyCode($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCurrencyCode() => $_has(7);
  @$pb.TagNumber(8)
  void clearCurrencyCode() => $_clearField(8);

  @$pb.TagNumber(9)
  SavingsAccountStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(SavingsAccountStatus value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get ledgerAccountId => $_getSZ(9);
  @$pb.TagNumber(10)
  set ledgerAccountId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasLedgerAccountId() => $_has(9);
  @$pb.TagNumber(10)
  void clearLedgerAccountId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get paymentAccountRef => $_getSZ(10);
  @$pb.TagNumber(11)
  set paymentAccountRef($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPaymentAccountRef() => $_has(10);
  @$pb.TagNumber(11)
  void clearPaymentAccountRef() => $_clearField(11);

  @$pb.TagNumber(12)
  $1.Struct get properties => $_getN(11);
  @$pb.TagNumber(12)
  set properties($1.Struct value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasProperties() => $_has(11);
  @$pb.TagNumber(12)
  void clearProperties() => $_clearField(12);
  @$pb.TagNumber(12)
  $1.Struct ensureProperties() => $_ensure(11);
}

/// DepositObject records a deposit into a savings account.
class DepositObject extends $pb.GeneratedMessage {
  factory DepositObject({
    $core.String? id,
    $core.String? savingsAccountId,
    $0.Money? amount,
    DepositStatus? status,
    $core.String? paymentReference,
    $core.String? ledgerTransactionId,
    $core.String? channel,
    $core.String? payerReference,
    $core.String? idempotencyKey,
    $1.Struct? properties,
  }) {
    final result = DepositObject._();
    if (id != null) result.id = id;
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    if (amount != null) result.amount = amount;
    if (status != null) result.status = status;
    if (paymentReference != null) result.paymentReference = paymentReference;
    if (ledgerTransactionId != null)
      result.ledgerTransactionId = ledgerTransactionId;
    if (channel != null) result.channel = channel;
    if (payerReference != null) result.payerReference = payerReference;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (properties != null) result.properties = properties;
    return result;
  }

  DepositObject._();

  factory DepositObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositObject()..mergeFromBuffer(data, registry);
  factory DepositObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepositObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: DepositObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aE<DepositStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: DepositStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(7, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOS(8, _omitFieldNames ? '' : 'channel')
    ..aOS(9, _omitFieldNames ? '' : 'payerReference')
    ..aOS(10, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$1.Struct>(11, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositObject copyWith(void Function(DepositObject) updates) =>
      super.copyWith((message) => updates(message as DepositObject))
          as DepositObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DepositObject() / DepositObject.new instead')
  static DepositObject create() => DepositObject._();
  static $pb.GeneratedMessage $_createMessage() => DepositObject._();
  @$core.override
  DepositObject createEmptyInstance() => DepositObject._();
  @$core.pragma('dart2js:noInline')
  static DepositObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepositObject>(
          DepositObject.$_createMessage);
  static DepositObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get savingsAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set savingsAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSavingsAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSavingsAccountId() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Money get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensureAmount() => $_ensure(2);

  @$pb.TagNumber(5)
  DepositStatus get status => $_getN(3);
  @$pb.TagNumber(5)
  set status(DepositStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get paymentReference => $_getSZ(4);
  @$pb.TagNumber(6)
  set paymentReference($core.String value) => $_setString(4, value);
  @$pb.TagNumber(6)
  $core.bool hasPaymentReference() => $_has(4);
  @$pb.TagNumber(6)
  void clearPaymentReference() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get ledgerTransactionId => $_getSZ(5);
  @$pb.TagNumber(7)
  set ledgerTransactionId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(7)
  $core.bool hasLedgerTransactionId() => $_has(5);
  @$pb.TagNumber(7)
  void clearLedgerTransactionId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get channel => $_getSZ(6);
  @$pb.TagNumber(8)
  set channel($core.String value) => $_setString(6, value);
  @$pb.TagNumber(8)
  $core.bool hasChannel() => $_has(6);
  @$pb.TagNumber(8)
  void clearChannel() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get payerReference => $_getSZ(7);
  @$pb.TagNumber(9)
  set payerReference($core.String value) => $_setString(7, value);
  @$pb.TagNumber(9)
  $core.bool hasPayerReference() => $_has(7);
  @$pb.TagNumber(9)
  void clearPayerReference() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get idempotencyKey => $_getSZ(8);
  @$pb.TagNumber(10)
  set idempotencyKey($core.String value) => $_setString(8, value);
  @$pb.TagNumber(10)
  $core.bool hasIdempotencyKey() => $_has(8);
  @$pb.TagNumber(10)
  void clearIdempotencyKey() => $_clearField(10);

  @$pb.TagNumber(11)
  $1.Struct get properties => $_getN(9);
  @$pb.TagNumber(11)
  set properties($1.Struct value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasProperties() => $_has(9);
  @$pb.TagNumber(11)
  void clearProperties() => $_clearField(11);
  @$pb.TagNumber(11)
  $1.Struct ensureProperties() => $_ensure(9);
}

/// WithdrawalObject records a withdrawal from a savings account.
class WithdrawalObject extends $pb.GeneratedMessage {
  factory WithdrawalObject({
    $core.String? id,
    $core.String? savingsAccountId,
    $0.Money? amount,
    WithdrawalStatus? status,
    $core.String? paymentReference,
    $core.String? ledgerTransactionId,
    $core.String? channel,
    $core.String? recipientReference,
    $core.String? reason,
    $core.String? idempotencyKey,
    $1.Struct? properties,
  }) {
    final result = WithdrawalObject._();
    if (id != null) result.id = id;
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    if (amount != null) result.amount = amount;
    if (status != null) result.status = status;
    if (paymentReference != null) result.paymentReference = paymentReference;
    if (ledgerTransactionId != null)
      result.ledgerTransactionId = ledgerTransactionId;
    if (channel != null) result.channel = channel;
    if (recipientReference != null)
      result.recipientReference = recipientReference;
    if (reason != null) result.reason = reason;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (properties != null) result.properties = properties;
    return result;
  }

  WithdrawalObject._();

  factory WithdrawalObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalObject()..mergeFromBuffer(data, registry);
  factory WithdrawalObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawalObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: WithdrawalObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aE<WithdrawalStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: WithdrawalStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(7, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOS(8, _omitFieldNames ? '' : 'channel')
    ..aOS(9, _omitFieldNames ? '' : 'recipientReference')
    ..aOS(10, _omitFieldNames ? '' : 'reason')
    ..aOS(11, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$1.Struct>(12, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalObject copyWith(void Function(WithdrawalObject) updates) =>
      super.copyWith((message) => updates(message as WithdrawalObject))
          as WithdrawalObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WithdrawalObject() / WithdrawalObject.new instead')
  static WithdrawalObject create() => WithdrawalObject._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalObject._();
  @$core.override
  WithdrawalObject createEmptyInstance() => WithdrawalObject._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalObject>(
          WithdrawalObject.$_createMessage);
  static WithdrawalObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get savingsAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set savingsAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSavingsAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSavingsAccountId() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Money get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensureAmount() => $_ensure(2);

  @$pb.TagNumber(5)
  WithdrawalStatus get status => $_getN(3);
  @$pb.TagNumber(5)
  set status(WithdrawalStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get paymentReference => $_getSZ(4);
  @$pb.TagNumber(6)
  set paymentReference($core.String value) => $_setString(4, value);
  @$pb.TagNumber(6)
  $core.bool hasPaymentReference() => $_has(4);
  @$pb.TagNumber(6)
  void clearPaymentReference() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get ledgerTransactionId => $_getSZ(5);
  @$pb.TagNumber(7)
  set ledgerTransactionId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(7)
  $core.bool hasLedgerTransactionId() => $_has(5);
  @$pb.TagNumber(7)
  void clearLedgerTransactionId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get channel => $_getSZ(6);
  @$pb.TagNumber(8)
  set channel($core.String value) => $_setString(6, value);
  @$pb.TagNumber(8)
  $core.bool hasChannel() => $_has(6);
  @$pb.TagNumber(8)
  void clearChannel() => $_clearField(8);

  /// recipient_reference is the contact id of the owner's verified mobile
  /// contact to pay out to; never a number. Empty lets the rail choose.
  @$pb.TagNumber(9)
  $core.String get recipientReference => $_getSZ(7);
  @$pb.TagNumber(9)
  set recipientReference($core.String value) => $_setString(7, value);
  @$pb.TagNumber(9)
  $core.bool hasRecipientReference() => $_has(7);
  @$pb.TagNumber(9)
  void clearRecipientReference() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get reason => $_getSZ(8);
  @$pb.TagNumber(10)
  set reason($core.String value) => $_setString(8, value);
  @$pb.TagNumber(10)
  $core.bool hasReason() => $_has(8);
  @$pb.TagNumber(10)
  void clearReason() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get idempotencyKey => $_getSZ(9);
  @$pb.TagNumber(11)
  set idempotencyKey($core.String value) => $_setString(9, value);
  @$pb.TagNumber(11)
  $core.bool hasIdempotencyKey() => $_has(9);
  @$pb.TagNumber(11)
  void clearIdempotencyKey() => $_clearField(11);

  @$pb.TagNumber(12)
  $1.Struct get properties => $_getN(10);
  @$pb.TagNumber(12)
  set properties($1.Struct value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasProperties() => $_has(10);
  @$pb.TagNumber(12)
  void clearProperties() => $_clearField(12);
  @$pb.TagNumber(12)
  $1.Struct ensureProperties() => $_ensure(10);
}

/// InterestAccrualObject records periodic interest accrued on a savings account.
class InterestAccrualObject extends $pb.GeneratedMessage {
  factory InterestAccrualObject({
    $core.String? id,
    $core.String? savingsAccountId,
    $0.Money? amount,
    $core.String? periodStart,
    $core.String? periodEnd,
    $core.String? rateApplied,
    $0.Money? balanceUsed,
    $core.String? ledgerTransactionId,
    $1.Struct? properties,
  }) {
    final result = InterestAccrualObject._();
    if (id != null) result.id = id;
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    if (amount != null) result.amount = amount;
    if (periodStart != null) result.periodStart = periodStart;
    if (periodEnd != null) result.periodEnd = periodEnd;
    if (rateApplied != null) result.rateApplied = rateApplied;
    if (balanceUsed != null) result.balanceUsed = balanceUsed;
    if (ledgerTransactionId != null)
      result.ledgerTransactionId = ledgerTransactionId;
    if (properties != null) result.properties = properties;
    return result;
  }

  InterestAccrualObject._();

  factory InterestAccrualObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterestAccrualObject()..mergeFromBuffer(data, registry);
  factory InterestAccrualObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterestAccrualObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InterestAccrualObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: InterestAccrualObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'periodStart')
    ..aOS(5, _omitFieldNames ? '' : 'periodEnd')
    ..aOS(6, _omitFieldNames ? '' : 'rateApplied')
    ..aOM<$0.Money>(7, _omitFieldNames ? '' : 'balanceUsed',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'ledgerTransactionId')
    ..aOM<$1.Struct>(9, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterestAccrualObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterestAccrualObject copyWith(
          void Function(InterestAccrualObject) updates) =>
      super.copyWith((message) => updates(message as InterestAccrualObject))
          as InterestAccrualObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InterestAccrualObject() / InterestAccrualObject.new instead')
  static InterestAccrualObject create() => InterestAccrualObject._();
  static $pb.GeneratedMessage $_createMessage() => InterestAccrualObject._();
  @$core.override
  InterestAccrualObject createEmptyInstance() => InterestAccrualObject._();
  @$core.pragma('dart2js:noInline')
  static InterestAccrualObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InterestAccrualObject>(
          InterestAccrualObject.$_createMessage);
  static InterestAccrualObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get savingsAccountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set savingsAccountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSavingsAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSavingsAccountId() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Money get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensureAmount() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get periodStart => $_getSZ(3);
  @$pb.TagNumber(4)
  set periodStart($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPeriodStart() => $_has(3);
  @$pb.TagNumber(4)
  void clearPeriodStart() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get periodEnd => $_getSZ(4);
  @$pb.TagNumber(5)
  set periodEnd($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPeriodEnd() => $_has(4);
  @$pb.TagNumber(5)
  void clearPeriodEnd() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get rateApplied => $_getSZ(5);
  @$pb.TagNumber(6)
  set rateApplied($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRateApplied() => $_has(5);
  @$pb.TagNumber(6)
  void clearRateApplied() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Money get balanceUsed => $_getN(6);
  @$pb.TagNumber(7)
  set balanceUsed($0.Money value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasBalanceUsed() => $_has(6);
  @$pb.TagNumber(7)
  void clearBalanceUsed() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Money ensureBalanceUsed() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get ledgerTransactionId => $_getSZ(7);
  @$pb.TagNumber(8)
  set ledgerTransactionId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLedgerTransactionId() => $_has(7);
  @$pb.TagNumber(8)
  void clearLedgerTransactionId() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.Struct get properties => $_getN(8);
  @$pb.TagNumber(9)
  set properties($1.Struct value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasProperties() => $_has(8);
  @$pb.TagNumber(9)
  void clearProperties() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Struct ensureProperties() => $_ensure(8);
}

/// SavingsBalanceObject represents the current balance of a savings account.
class SavingsBalanceObject extends $pb.GeneratedMessage {
  factory SavingsBalanceObject({
    $core.String? savingsAccountId,
    $0.Money? availableBalance,
    $0.Money? totalDeposits,
    $0.Money? totalWithdrawals,
    $0.Money? totalInterest,
    $core.String? lastCalculatedAt,
  }) {
    final result = SavingsBalanceObject._();
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    if (availableBalance != null) result.availableBalance = availableBalance;
    if (totalDeposits != null) result.totalDeposits = totalDeposits;
    if (totalWithdrawals != null) result.totalWithdrawals = totalWithdrawals;
    if (totalInterest != null) result.totalInterest = totalInterest;
    if (lastCalculatedAt != null) result.lastCalculatedAt = lastCalculatedAt;
    return result;
  }

  SavingsBalanceObject._();

  factory SavingsBalanceObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsBalanceObject()..mergeFromBuffer(data, registry);
  factory SavingsBalanceObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsBalanceObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsBalanceObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsBalanceObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'availableBalance',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'totalDeposits',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(4, _omitFieldNames ? '' : 'totalWithdrawals',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(5, _omitFieldNames ? '' : 'totalInterest',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'lastCalculatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsBalanceObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsBalanceObject copyWith(void Function(SavingsBalanceObject) updates) =>
      super.copyWith((message) => updates(message as SavingsBalanceObject))
          as SavingsBalanceObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsBalanceObject() / SavingsBalanceObject.new instead')
  static SavingsBalanceObject create() => SavingsBalanceObject._();
  static $pb.GeneratedMessage $_createMessage() => SavingsBalanceObject._();
  @$core.override
  SavingsBalanceObject createEmptyInstance() => SavingsBalanceObject._();
  @$core.pragma('dart2js:noInline')
  static SavingsBalanceObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsBalanceObject>(
          SavingsBalanceObject.$_createMessage);
  static SavingsBalanceObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Money get availableBalance => $_getN(1);
  @$pb.TagNumber(2)
  set availableBalance($0.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAvailableBalance() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvailableBalance() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Money ensureAvailableBalance() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Money get totalDeposits => $_getN(2);
  @$pb.TagNumber(3)
  set totalDeposits($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalDeposits() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalDeposits() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensureTotalDeposits() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Money get totalWithdrawals => $_getN(3);
  @$pb.TagNumber(4)
  set totalWithdrawals($0.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalWithdrawals() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalWithdrawals() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Money ensureTotalWithdrawals() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Money get totalInterest => $_getN(4);
  @$pb.TagNumber(5)
  set totalInterest($0.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalInterest() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalInterest() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Money ensureTotalInterest() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get lastCalculatedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set lastCalculatedAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLastCalculatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastCalculatedAt() => $_clearField(6);
}

/// SavingsStatementEntry represents a single line in a savings statement.
class SavingsStatementEntry extends $pb.GeneratedMessage {
  factory SavingsStatementEntry({
    $core.String? date,
    $core.String? description,
    $0.Money? debit,
    $0.Money? credit,
    $0.Money? balance,
    $core.String? reference,
  }) {
    final result = SavingsStatementEntry._();
    if (date != null) result.date = date;
    if (description != null) result.description = description;
    if (debit != null) result.debit = debit;
    if (credit != null) result.credit = credit;
    if (balance != null) result.balance = balance;
    if (reference != null) result.reference = reference;
    return result;
  }

  SavingsStatementEntry._();

  factory SavingsStatementEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsStatementEntry()..mergeFromBuffer(data, registry);
  factory SavingsStatementEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsStatementEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsStatementEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsStatementEntry.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'debit',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(4, _omitFieldNames ? '' : 'credit',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(5, _omitFieldNames ? '' : 'balance',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'reference')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsStatementEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsStatementEntry copyWith(
          void Function(SavingsStatementEntry) updates) =>
      super.copyWith((message) => updates(message as SavingsStatementEntry))
          as SavingsStatementEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsStatementEntry() / SavingsStatementEntry.new instead')
  static SavingsStatementEntry create() => SavingsStatementEntry._();
  static $pb.GeneratedMessage $_createMessage() => SavingsStatementEntry._();
  @$core.override
  SavingsStatementEntry createEmptyInstance() => SavingsStatementEntry._();
  @$core.pragma('dart2js:noInline')
  static SavingsStatementEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsStatementEntry>(
          SavingsStatementEntry.$_createMessage);
  static SavingsStatementEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Money get debit => $_getN(2);
  @$pb.TagNumber(3)
  set debit($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDebit() => $_has(2);
  @$pb.TagNumber(3)
  void clearDebit() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensureDebit() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Money get credit => $_getN(3);
  @$pb.TagNumber(4)
  set credit($0.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCredit() => $_has(3);
  @$pb.TagNumber(4)
  void clearCredit() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Money ensureCredit() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Money get balance => $_getN(4);
  @$pb.TagNumber(5)
  set balance($0.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasBalance() => $_has(4);
  @$pb.TagNumber(5)
  void clearBalance() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Money ensureBalance() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get reference => $_getSZ(5);
  @$pb.TagNumber(6)
  set reference($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReference() => $_has(5);
  @$pb.TagNumber(6)
  void clearReference() => $_clearField(6);
}

class SavingsProductSaveRequest extends $pb.GeneratedMessage {
  factory SavingsProductSaveRequest({
    SavingsProductObject? data,
  }) {
    final result = SavingsProductSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  SavingsProductSaveRequest._();

  factory SavingsProductSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductSaveRequest()..mergeFromBuffer(data, registry);
  factory SavingsProductSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsProductSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsProductSaveRequest.$_createMessage)
    ..aOM<SavingsProductObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: SavingsProductObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductSaveRequest copyWith(
          void Function(SavingsProductSaveRequest) updates) =>
      super.copyWith((message) => updates(message as SavingsProductSaveRequest))
          as SavingsProductSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsProductSaveRequest() / SavingsProductSaveRequest.new instead')
  static SavingsProductSaveRequest create() => SavingsProductSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsProductSaveRequest._();
  @$core.override
  SavingsProductSaveRequest createEmptyInstance() =>
      SavingsProductSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static SavingsProductSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsProductSaveRequest>(
          SavingsProductSaveRequest.$_createMessage);
  static SavingsProductSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsProductObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  SavingsProductObject ensureData() => $_ensure(0);
}

class SavingsProductSaveResponse extends $pb.GeneratedMessage {
  factory SavingsProductSaveResponse({
    SavingsProductObject? data,
  }) {
    final result = SavingsProductSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  SavingsProductSaveResponse._();

  factory SavingsProductSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductSaveResponse()..mergeFromBuffer(data, registry);
  factory SavingsProductSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsProductSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsProductSaveResponse.$_createMessage)
    ..aOM<SavingsProductObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: SavingsProductObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductSaveResponse copyWith(
          void Function(SavingsProductSaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SavingsProductSaveResponse))
          as SavingsProductSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsProductSaveResponse() / SavingsProductSaveResponse.new instead')
  static SavingsProductSaveResponse create() => SavingsProductSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsProductSaveResponse._();
  @$core.override
  SavingsProductSaveResponse createEmptyInstance() =>
      SavingsProductSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static SavingsProductSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsProductSaveResponse>(
          SavingsProductSaveResponse.$_createMessage);
  static SavingsProductSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsProductObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  SavingsProductObject ensureData() => $_ensure(0);
}

class SavingsProductGetRequest extends $pb.GeneratedMessage {
  factory SavingsProductGetRequest({
    $core.String? id,
  }) {
    final result = SavingsProductGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  SavingsProductGetRequest._();

  factory SavingsProductGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductGetRequest()..mergeFromBuffer(data, registry);
  factory SavingsProductGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsProductGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsProductGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductGetRequest copyWith(
          void Function(SavingsProductGetRequest) updates) =>
      super.copyWith((message) => updates(message as SavingsProductGetRequest))
          as SavingsProductGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsProductGetRequest() / SavingsProductGetRequest.new instead')
  static SavingsProductGetRequest create() => SavingsProductGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => SavingsProductGetRequest._();
  @$core.override
  SavingsProductGetRequest createEmptyInstance() =>
      SavingsProductGetRequest._();
  @$core.pragma('dart2js:noInline')
  static SavingsProductGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsProductGetRequest>(
          SavingsProductGetRequest.$_createMessage);
  static SavingsProductGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class SavingsProductGetResponse extends $pb.GeneratedMessage {
  factory SavingsProductGetResponse({
    SavingsProductObject? data,
  }) {
    final result = SavingsProductGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  SavingsProductGetResponse._();

  factory SavingsProductGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductGetResponse()..mergeFromBuffer(data, registry);
  factory SavingsProductGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsProductGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsProductGetResponse.$_createMessage)
    ..aOM<SavingsProductObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: SavingsProductObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductGetResponse copyWith(
          void Function(SavingsProductGetResponse) updates) =>
      super.copyWith((message) => updates(message as SavingsProductGetResponse))
          as SavingsProductGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsProductGetResponse() / SavingsProductGetResponse.new instead')
  static SavingsProductGetResponse create() => SavingsProductGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsProductGetResponse._();
  @$core.override
  SavingsProductGetResponse createEmptyInstance() =>
      SavingsProductGetResponse._();
  @$core.pragma('dart2js:noInline')
  static SavingsProductGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsProductGetResponse>(
          SavingsProductGetResponse.$_createMessage);
  static SavingsProductGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsProductObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsProductObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  SavingsProductObject ensureData() => $_ensure(0);
}

class SavingsProductSearchRequest extends $pb.GeneratedMessage {
  factory SavingsProductSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    $2.PageCursor? cursor,
  }) {
    final result = SavingsProductSearchRequest._();
    if (query != null) result.query = query;
    if (organizationId != null) result.organizationId = organizationId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  SavingsProductSearchRequest._();

  factory SavingsProductSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductSearchRequest()..mergeFromBuffer(data, registry);
  factory SavingsProductSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsProductSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsProductSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOM<$2.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductSearchRequest copyWith(
          void Function(SavingsProductSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SavingsProductSearchRequest))
          as SavingsProductSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsProductSearchRequest() / SavingsProductSearchRequest.new instead')
  static SavingsProductSearchRequest create() =>
      SavingsProductSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsProductSearchRequest._();
  @$core.override
  SavingsProductSearchRequest createEmptyInstance() =>
      SavingsProductSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static SavingsProductSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsProductSearchRequest>(
          SavingsProductSearchRequest.$_createMessage);
  static SavingsProductSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get organizationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set organizationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOrganizationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrganizationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($2.PageCursor value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.PageCursor ensureCursor() => $_ensure(2);
}

class SavingsProductSearchResponse extends $pb.GeneratedMessage {
  factory SavingsProductSearchResponse({
    $core.Iterable<SavingsProductObject>? data,
  }) {
    final result = SavingsProductSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  SavingsProductSearchResponse._();

  factory SavingsProductSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductSearchResponse()..mergeFromBuffer(data, registry);
  factory SavingsProductSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsProductSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsProductSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsProductSearchResponse.$_createMessage)
    ..pPM<SavingsProductObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: SavingsProductObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsProductSearchResponse copyWith(
          void Function(SavingsProductSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SavingsProductSearchResponse))
          as SavingsProductSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsProductSearchResponse() / SavingsProductSearchResponse.new instead')
  static SavingsProductSearchResponse create() =>
      SavingsProductSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsProductSearchResponse._();
  @$core.override
  SavingsProductSearchResponse createEmptyInstance() =>
      SavingsProductSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static SavingsProductSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsProductSearchResponse>(
          SavingsProductSearchResponse.$_createMessage);
  static SavingsProductSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SavingsProductObject> get data => $_getList(0);
}

class SavingsAccountCreateRequest extends $pb.GeneratedMessage {
  factory SavingsAccountCreateRequest({
    SavingsAccountObject? data,
  }) {
    final result = SavingsAccountCreateRequest._();
    if (data != null) result.data = data;
    return result;
  }

  SavingsAccountCreateRequest._();

  factory SavingsAccountCreateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountCreateRequest()..mergeFromBuffer(data, registry);
  factory SavingsAccountCreateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountCreateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsAccountCreateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsAccountCreateRequest.$_createMessage)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: SavingsAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountCreateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountCreateRequest copyWith(
          void Function(SavingsAccountCreateRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SavingsAccountCreateRequest))
          as SavingsAccountCreateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsAccountCreateRequest() / SavingsAccountCreateRequest.new instead')
  static SavingsAccountCreateRequest create() =>
      SavingsAccountCreateRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsAccountCreateRequest._();
  @$core.override
  SavingsAccountCreateRequest createEmptyInstance() =>
      SavingsAccountCreateRequest._();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountCreateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsAccountCreateRequest>(
          SavingsAccountCreateRequest.$_createMessage);
  static SavingsAccountCreateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  SavingsAccountObject ensureData() => $_ensure(0);
}

class SavingsAccountCreateResponse extends $pb.GeneratedMessage {
  factory SavingsAccountCreateResponse({
    SavingsAccountObject? data,
  }) {
    final result = SavingsAccountCreateResponse._();
    if (data != null) result.data = data;
    return result;
  }

  SavingsAccountCreateResponse._();

  factory SavingsAccountCreateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountCreateResponse()..mergeFromBuffer(data, registry);
  factory SavingsAccountCreateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountCreateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsAccountCreateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsAccountCreateResponse.$_createMessage)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: SavingsAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountCreateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountCreateResponse copyWith(
          void Function(SavingsAccountCreateResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SavingsAccountCreateResponse))
          as SavingsAccountCreateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsAccountCreateResponse() / SavingsAccountCreateResponse.new instead')
  static SavingsAccountCreateResponse create() =>
      SavingsAccountCreateResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsAccountCreateResponse._();
  @$core.override
  SavingsAccountCreateResponse createEmptyInstance() =>
      SavingsAccountCreateResponse._();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountCreateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsAccountCreateResponse>(
          SavingsAccountCreateResponse.$_createMessage);
  static SavingsAccountCreateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  SavingsAccountObject ensureData() => $_ensure(0);
}

class SavingsAccountGetRequest extends $pb.GeneratedMessage {
  factory SavingsAccountGetRequest({
    $core.String? id,
  }) {
    final result = SavingsAccountGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  SavingsAccountGetRequest._();

  factory SavingsAccountGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountGetRequest()..mergeFromBuffer(data, registry);
  factory SavingsAccountGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsAccountGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsAccountGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountGetRequest copyWith(
          void Function(SavingsAccountGetRequest) updates) =>
      super.copyWith((message) => updates(message as SavingsAccountGetRequest))
          as SavingsAccountGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsAccountGetRequest() / SavingsAccountGetRequest.new instead')
  static SavingsAccountGetRequest create() => SavingsAccountGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => SavingsAccountGetRequest._();
  @$core.override
  SavingsAccountGetRequest createEmptyInstance() =>
      SavingsAccountGetRequest._();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsAccountGetRequest>(
          SavingsAccountGetRequest.$_createMessage);
  static SavingsAccountGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class SavingsAccountGetResponse extends $pb.GeneratedMessage {
  factory SavingsAccountGetResponse({
    SavingsAccountObject? data,
  }) {
    final result = SavingsAccountGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  SavingsAccountGetResponse._();

  factory SavingsAccountGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountGetResponse()..mergeFromBuffer(data, registry);
  factory SavingsAccountGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsAccountGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsAccountGetResponse.$_createMessage)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: SavingsAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountGetResponse copyWith(
          void Function(SavingsAccountGetResponse) updates) =>
      super.copyWith((message) => updates(message as SavingsAccountGetResponse))
          as SavingsAccountGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsAccountGetResponse() / SavingsAccountGetResponse.new instead')
  static SavingsAccountGetResponse create() => SavingsAccountGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsAccountGetResponse._();
  @$core.override
  SavingsAccountGetResponse createEmptyInstance() =>
      SavingsAccountGetResponse._();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsAccountGetResponse>(
          SavingsAccountGetResponse.$_createMessage);
  static SavingsAccountGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
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
    $2.PageCursor? cursor,
  }) {
    final result = SavingsAccountSearchRequest._();
    if (query != null) result.query = query;
    if (ownerId != null) result.ownerId = ownerId;
    if (productId != null) result.productId = productId;
    if (organizationId != null) result.organizationId = organizationId;
    if (status != null) result.status = status;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  SavingsAccountSearchRequest._();

  factory SavingsAccountSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountSearchRequest()..mergeFromBuffer(data, registry);
  factory SavingsAccountSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsAccountSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsAccountSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'ownerId')
    ..aOS(3, _omitFieldNames ? '' : 'productId')
    ..aOS(4, _omitFieldNames ? '' : 'organizationId')
    ..aE<SavingsAccountStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: SavingsAccountStatus.values)
    ..aOM<$2.PageCursor>(6, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountSearchRequest copyWith(
          void Function(SavingsAccountSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SavingsAccountSearchRequest))
          as SavingsAccountSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsAccountSearchRequest() / SavingsAccountSearchRequest.new instead')
  static SavingsAccountSearchRequest create() =>
      SavingsAccountSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsAccountSearchRequest._();
  @$core.override
  SavingsAccountSearchRequest createEmptyInstance() =>
      SavingsAccountSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsAccountSearchRequest>(
          SavingsAccountSearchRequest.$_createMessage);
  static SavingsAccountSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ownerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set ownerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOwnerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOwnerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get productId => $_getSZ(2);
  @$pb.TagNumber(3)
  set productId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProductId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get organizationId => $_getSZ(3);
  @$pb.TagNumber(4)
  set organizationId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrganizationId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrganizationId() => $_clearField(4);

  @$pb.TagNumber(5)
  SavingsAccountStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(SavingsAccountStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $2.PageCursor get cursor => $_getN(5);
  @$pb.TagNumber(6)
  set cursor($2.PageCursor value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearCursor() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.PageCursor ensureCursor() => $_ensure(5);
}

class SavingsAccountSearchResponse extends $pb.GeneratedMessage {
  factory SavingsAccountSearchResponse({
    $core.Iterable<SavingsAccountObject>? data,
  }) {
    final result = SavingsAccountSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  SavingsAccountSearchResponse._();

  factory SavingsAccountSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountSearchResponse()..mergeFromBuffer(data, registry);
  factory SavingsAccountSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsAccountSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsAccountSearchResponse.$_createMessage)
    ..pPM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: SavingsAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountSearchResponse copyWith(
          void Function(SavingsAccountSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SavingsAccountSearchResponse))
          as SavingsAccountSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsAccountSearchResponse() / SavingsAccountSearchResponse.new instead')
  static SavingsAccountSearchResponse create() =>
      SavingsAccountSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsAccountSearchResponse._();
  @$core.override
  SavingsAccountSearchResponse createEmptyInstance() =>
      SavingsAccountSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsAccountSearchResponse>(
          SavingsAccountSearchResponse.$_createMessage);
  static SavingsAccountSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SavingsAccountObject> get data => $_getList(0);
}

class SavingsAccountFreezeRequest extends $pb.GeneratedMessage {
  factory SavingsAccountFreezeRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = SavingsAccountFreezeRequest._();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  SavingsAccountFreezeRequest._();

  factory SavingsAccountFreezeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountFreezeRequest()..mergeFromBuffer(data, registry);
  factory SavingsAccountFreezeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountFreezeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsAccountFreezeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsAccountFreezeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountFreezeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountFreezeRequest copyWith(
          void Function(SavingsAccountFreezeRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SavingsAccountFreezeRequest))
          as SavingsAccountFreezeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsAccountFreezeRequest() / SavingsAccountFreezeRequest.new instead')
  static SavingsAccountFreezeRequest create() =>
      SavingsAccountFreezeRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsAccountFreezeRequest._();
  @$core.override
  SavingsAccountFreezeRequest createEmptyInstance() =>
      SavingsAccountFreezeRequest._();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountFreezeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsAccountFreezeRequest>(
          SavingsAccountFreezeRequest.$_createMessage);
  static SavingsAccountFreezeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class SavingsAccountFreezeResponse extends $pb.GeneratedMessage {
  factory SavingsAccountFreezeResponse({
    SavingsAccountObject? data,
  }) {
    final result = SavingsAccountFreezeResponse._();
    if (data != null) result.data = data;
    return result;
  }

  SavingsAccountFreezeResponse._();

  factory SavingsAccountFreezeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountFreezeResponse()..mergeFromBuffer(data, registry);
  factory SavingsAccountFreezeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountFreezeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsAccountFreezeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsAccountFreezeResponse.$_createMessage)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: SavingsAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountFreezeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountFreezeResponse copyWith(
          void Function(SavingsAccountFreezeResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SavingsAccountFreezeResponse))
          as SavingsAccountFreezeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsAccountFreezeResponse() / SavingsAccountFreezeResponse.new instead')
  static SavingsAccountFreezeResponse create() =>
      SavingsAccountFreezeResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsAccountFreezeResponse._();
  @$core.override
  SavingsAccountFreezeResponse createEmptyInstance() =>
      SavingsAccountFreezeResponse._();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountFreezeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsAccountFreezeResponse>(
          SavingsAccountFreezeResponse.$_createMessage);
  static SavingsAccountFreezeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  SavingsAccountObject ensureData() => $_ensure(0);
}

class SavingsAccountCloseRequest extends $pb.GeneratedMessage {
  factory SavingsAccountCloseRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = SavingsAccountCloseRequest._();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  SavingsAccountCloseRequest._();

  factory SavingsAccountCloseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountCloseRequest()..mergeFromBuffer(data, registry);
  factory SavingsAccountCloseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountCloseRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsAccountCloseRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsAccountCloseRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountCloseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountCloseRequest copyWith(
          void Function(SavingsAccountCloseRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SavingsAccountCloseRequest))
          as SavingsAccountCloseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsAccountCloseRequest() / SavingsAccountCloseRequest.new instead')
  static SavingsAccountCloseRequest create() => SavingsAccountCloseRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsAccountCloseRequest._();
  @$core.override
  SavingsAccountCloseRequest createEmptyInstance() =>
      SavingsAccountCloseRequest._();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountCloseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsAccountCloseRequest>(
          SavingsAccountCloseRequest.$_createMessage);
  static SavingsAccountCloseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class SavingsAccountCloseResponse extends $pb.GeneratedMessage {
  factory SavingsAccountCloseResponse({
    SavingsAccountObject? data,
  }) {
    final result = SavingsAccountCloseResponse._();
    if (data != null) result.data = data;
    return result;
  }

  SavingsAccountCloseResponse._();

  factory SavingsAccountCloseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountCloseResponse()..mergeFromBuffer(data, registry);
  factory SavingsAccountCloseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsAccountCloseResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsAccountCloseResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsAccountCloseResponse.$_createMessage)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: SavingsAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountCloseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsAccountCloseResponse copyWith(
          void Function(SavingsAccountCloseResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SavingsAccountCloseResponse))
          as SavingsAccountCloseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsAccountCloseResponse() / SavingsAccountCloseResponse.new instead')
  static SavingsAccountCloseResponse create() =>
      SavingsAccountCloseResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsAccountCloseResponse._();
  @$core.override
  SavingsAccountCloseResponse createEmptyInstance() =>
      SavingsAccountCloseResponse._();
  @$core.pragma('dart2js:noInline')
  static SavingsAccountCloseResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsAccountCloseResponse>(
          SavingsAccountCloseResponse.$_createMessage);
  static SavingsAccountCloseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  SavingsAccountObject ensureData() => $_ensure(0);
}

class DepositRecordRequest extends $pb.GeneratedMessage {
  factory DepositRecordRequest({
    $core.String? savingsAccountId,
    $0.Money? amount,
    $core.String? paymentReference,
    $core.String? channel,
    $core.String? payerReference,
    $core.String? idempotencyKey,
  }) {
    final result = DepositRecordRequest._();
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    if (amount != null) result.amount = amount;
    if (paymentReference != null) result.paymentReference = paymentReference;
    if (channel != null) result.channel = channel;
    if (payerReference != null) result.payerReference = payerReference;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    return result;
  }

  DepositRecordRequest._();

  factory DepositRecordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositRecordRequest()..mergeFromBuffer(data, registry);
  factory DepositRecordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositRecordRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepositRecordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: DepositRecordRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(4, _omitFieldNames ? '' : 'channel')
    ..aOS(5, _omitFieldNames ? '' : 'payerReference')
    ..aOS(6, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositRecordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositRecordRequest copyWith(void Function(DepositRecordRequest) updates) =>
      super.copyWith((message) => updates(message as DepositRecordRequest))
          as DepositRecordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DepositRecordRequest() / DepositRecordRequest.new instead')
  static DepositRecordRequest create() => DepositRecordRequest._();
  static $pb.GeneratedMessage $_createMessage() => DepositRecordRequest._();
  @$core.override
  DepositRecordRequest createEmptyInstance() => DepositRecordRequest._();
  @$core.pragma('dart2js:noInline')
  static DepositRecordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DepositRecordRequest>(
          DepositRecordRequest.$_createMessage);
  static DepositRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($0.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Money ensureAmount() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get paymentReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set paymentReference($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPaymentReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearPaymentReference() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get channel => $_getSZ(3);
  @$pb.TagNumber(4)
  set channel($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChannel() => $_has(3);
  @$pb.TagNumber(4)
  void clearChannel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get payerReference => $_getSZ(4);
  @$pb.TagNumber(5)
  set payerReference($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPayerReference() => $_has(4);
  @$pb.TagNumber(5)
  void clearPayerReference() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get idempotencyKey => $_getSZ(5);
  @$pb.TagNumber(6)
  set idempotencyKey($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIdempotencyKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearIdempotencyKey() => $_clearField(6);
}

class DepositRecordResponse extends $pb.GeneratedMessage {
  factory DepositRecordResponse({
    DepositObject? data,
  }) {
    final result = DepositRecordResponse._();
    if (data != null) result.data = data;
    return result;
  }

  DepositRecordResponse._();

  factory DepositRecordResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositRecordResponse()..mergeFromBuffer(data, registry);
  factory DepositRecordResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositRecordResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepositRecordResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: DepositRecordResponse.$_createMessage)
    ..aOM<DepositObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: DepositObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositRecordResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositRecordResponse copyWith(
          void Function(DepositRecordResponse) updates) =>
      super.copyWith((message) => updates(message as DepositRecordResponse))
          as DepositRecordResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DepositRecordResponse() / DepositRecordResponse.new instead')
  static DepositRecordResponse create() => DepositRecordResponse._();
  static $pb.GeneratedMessage $_createMessage() => DepositRecordResponse._();
  @$core.override
  DepositRecordResponse createEmptyInstance() => DepositRecordResponse._();
  @$core.pragma('dart2js:noInline')
  static DepositRecordResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DepositRecordResponse>(
          DepositRecordResponse.$_createMessage);
  static DepositRecordResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DepositObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DepositObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  DepositObject ensureData() => $_ensure(0);
}

class DepositGetRequest extends $pb.GeneratedMessage {
  factory DepositGetRequest({
    $core.String? id,
  }) {
    final result = DepositGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  DepositGetRequest._();

  factory DepositGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositGetRequest()..mergeFromBuffer(data, registry);
  factory DepositGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepositGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: DepositGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositGetRequest copyWith(void Function(DepositGetRequest) updates) =>
      super.copyWith((message) => updates(message as DepositGetRequest))
          as DepositGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DepositGetRequest() / DepositGetRequest.new instead')
  static DepositGetRequest create() => DepositGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => DepositGetRequest._();
  @$core.override
  DepositGetRequest createEmptyInstance() => DepositGetRequest._();
  @$core.pragma('dart2js:noInline')
  static DepositGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepositGetRequest>(
          DepositGetRequest.$_createMessage);
  static DepositGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DepositGetResponse extends $pb.GeneratedMessage {
  factory DepositGetResponse({
    DepositObject? data,
  }) {
    final result = DepositGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  DepositGetResponse._();

  factory DepositGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositGetResponse()..mergeFromBuffer(data, registry);
  factory DepositGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepositGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: DepositGetResponse.$_createMessage)
    ..aOM<DepositObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: DepositObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositGetResponse copyWith(void Function(DepositGetResponse) updates) =>
      super.copyWith((message) => updates(message as DepositGetResponse))
          as DepositGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DepositGetResponse() / DepositGetResponse.new instead')
  static DepositGetResponse create() => DepositGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => DepositGetResponse._();
  @$core.override
  DepositGetResponse createEmptyInstance() => DepositGetResponse._();
  @$core.pragma('dart2js:noInline')
  static DepositGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DepositGetResponse>(
          DepositGetResponse.$_createMessage);
  static DepositGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DepositObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DepositObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  DepositObject ensureData() => $_ensure(0);
}

class DepositSearchRequest extends $pb.GeneratedMessage {
  factory DepositSearchRequest({
    $core.String? savingsAccountId,
    DepositStatus? status,
    $2.PageCursor? cursor,
  }) {
    final result = DepositSearchRequest._();
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    if (status != null) result.status = status;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  DepositSearchRequest._();

  factory DepositSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositSearchRequest()..mergeFromBuffer(data, registry);
  factory DepositSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepositSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: DepositSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aE<DepositStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: DepositStatus.values)
    ..aOM<$2.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositSearchRequest copyWith(void Function(DepositSearchRequest) updates) =>
      super.copyWith((message) => updates(message as DepositSearchRequest))
          as DepositSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DepositSearchRequest() / DepositSearchRequest.new instead')
  static DepositSearchRequest create() => DepositSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => DepositSearchRequest._();
  @$core.override
  DepositSearchRequest createEmptyInstance() => DepositSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static DepositSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DepositSearchRequest>(
          DepositSearchRequest.$_createMessage);
  static DepositSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  DepositStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(DepositStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($2.PageCursor value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.PageCursor ensureCursor() => $_ensure(2);
}

class DepositSearchResponse extends $pb.GeneratedMessage {
  factory DepositSearchResponse({
    $core.Iterable<DepositObject>? data,
  }) {
    final result = DepositSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  DepositSearchResponse._();

  factory DepositSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositSearchResponse()..mergeFromBuffer(data, registry);
  factory DepositSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepositSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepositSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: DepositSearchResponse.$_createMessage)
    ..pPM<DepositObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: DepositObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepositSearchResponse copyWith(
          void Function(DepositSearchResponse) updates) =>
      super.copyWith((message) => updates(message as DepositSearchResponse))
          as DepositSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DepositSearchResponse() / DepositSearchResponse.new instead')
  static DepositSearchResponse create() => DepositSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => DepositSearchResponse._();
  @$core.override
  DepositSearchResponse createEmptyInstance() => DepositSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static DepositSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DepositSearchResponse>(
          DepositSearchResponse.$_createMessage);
  static DepositSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DepositObject> get data => $_getList(0);
}

class WithdrawalRequestRequest extends $pb.GeneratedMessage {
  factory WithdrawalRequestRequest({
    $core.String? savingsAccountId,
    $0.Money? amount,
    $core.String? channel,
    $core.String? recipientReference,
    $core.String? reason,
    $core.String? idempotencyKey,
  }) {
    final result = WithdrawalRequestRequest._();
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    if (amount != null) result.amount = amount;
    if (channel != null) result.channel = channel;
    if (recipientReference != null)
      result.recipientReference = recipientReference;
    if (reason != null) result.reason = reason;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    return result;
  }

  WithdrawalRequestRequest._();

  factory WithdrawalRequestRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalRequestRequest()..mergeFromBuffer(data, registry);
  factory WithdrawalRequestRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalRequestRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawalRequestRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: WithdrawalRequestRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'channel')
    ..aOS(4, _omitFieldNames ? '' : 'recipientReference')
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..aOS(6, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalRequestRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalRequestRequest copyWith(
          void Function(WithdrawalRequestRequest) updates) =>
      super.copyWith((message) => updates(message as WithdrawalRequestRequest))
          as WithdrawalRequestRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WithdrawalRequestRequest() / WithdrawalRequestRequest.new instead')
  static WithdrawalRequestRequest create() => WithdrawalRequestRequest._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalRequestRequest._();
  @$core.override
  WithdrawalRequestRequest createEmptyInstance() =>
      WithdrawalRequestRequest._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalRequestRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalRequestRequest>(
          WithdrawalRequestRequest.$_createMessage);
  static WithdrawalRequestRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($0.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Money ensureAmount() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get channel => $_getSZ(2);
  @$pb.TagNumber(3)
  set channel($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChannel() => $_has(2);
  @$pb.TagNumber(3)
  void clearChannel() => $_clearField(3);

  /// recipient_reference is the contact id of the owner's verified mobile
  /// contact to pay out to; never a number. Empty lets the rail choose.
  @$pb.TagNumber(4)
  $core.String get recipientReference => $_getSZ(3);
  @$pb.TagNumber(4)
  set recipientReference($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRecipientReference() => $_has(3);
  @$pb.TagNumber(4)
  void clearRecipientReference() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get idempotencyKey => $_getSZ(5);
  @$pb.TagNumber(6)
  set idempotencyKey($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIdempotencyKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearIdempotencyKey() => $_clearField(6);
}

class WithdrawalRequestResponse extends $pb.GeneratedMessage {
  factory WithdrawalRequestResponse({
    WithdrawalObject? data,
  }) {
    final result = WithdrawalRequestResponse._();
    if (data != null) result.data = data;
    return result;
  }

  WithdrawalRequestResponse._();

  factory WithdrawalRequestResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalRequestResponse()..mergeFromBuffer(data, registry);
  factory WithdrawalRequestResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalRequestResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawalRequestResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: WithdrawalRequestResponse.$_createMessage)
    ..aOM<WithdrawalObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: WithdrawalObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalRequestResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalRequestResponse copyWith(
          void Function(WithdrawalRequestResponse) updates) =>
      super.copyWith((message) => updates(message as WithdrawalRequestResponse))
          as WithdrawalRequestResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WithdrawalRequestResponse() / WithdrawalRequestResponse.new instead')
  static WithdrawalRequestResponse create() => WithdrawalRequestResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      WithdrawalRequestResponse._();
  @$core.override
  WithdrawalRequestResponse createEmptyInstance() =>
      WithdrawalRequestResponse._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalRequestResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalRequestResponse>(
          WithdrawalRequestResponse.$_createMessage);
  static WithdrawalRequestResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WithdrawalObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WithdrawalObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  WithdrawalObject ensureData() => $_ensure(0);
}

class WithdrawalApproveRequest extends $pb.GeneratedMessage {
  factory WithdrawalApproveRequest({
    $core.String? id,
  }) {
    final result = WithdrawalApproveRequest._();
    if (id != null) result.id = id;
    return result;
  }

  WithdrawalApproveRequest._();

  factory WithdrawalApproveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalApproveRequest()..mergeFromBuffer(data, registry);
  factory WithdrawalApproveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalApproveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawalApproveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: WithdrawalApproveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalApproveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalApproveRequest copyWith(
          void Function(WithdrawalApproveRequest) updates) =>
      super.copyWith((message) => updates(message as WithdrawalApproveRequest))
          as WithdrawalApproveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WithdrawalApproveRequest() / WithdrawalApproveRequest.new instead')
  static WithdrawalApproveRequest create() => WithdrawalApproveRequest._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalApproveRequest._();
  @$core.override
  WithdrawalApproveRequest createEmptyInstance() =>
      WithdrawalApproveRequest._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalApproveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalApproveRequest>(
          WithdrawalApproveRequest.$_createMessage);
  static WithdrawalApproveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class WithdrawalApproveResponse extends $pb.GeneratedMessage {
  factory WithdrawalApproveResponse({
    WithdrawalObject? data,
  }) {
    final result = WithdrawalApproveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  WithdrawalApproveResponse._();

  factory WithdrawalApproveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalApproveResponse()..mergeFromBuffer(data, registry);
  factory WithdrawalApproveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalApproveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawalApproveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: WithdrawalApproveResponse.$_createMessage)
    ..aOM<WithdrawalObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: WithdrawalObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalApproveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalApproveResponse copyWith(
          void Function(WithdrawalApproveResponse) updates) =>
      super.copyWith((message) => updates(message as WithdrawalApproveResponse))
          as WithdrawalApproveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WithdrawalApproveResponse() / WithdrawalApproveResponse.new instead')
  static WithdrawalApproveResponse create() => WithdrawalApproveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      WithdrawalApproveResponse._();
  @$core.override
  WithdrawalApproveResponse createEmptyInstance() =>
      WithdrawalApproveResponse._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalApproveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalApproveResponse>(
          WithdrawalApproveResponse.$_createMessage);
  static WithdrawalApproveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WithdrawalObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WithdrawalObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  WithdrawalObject ensureData() => $_ensure(0);
}

class WithdrawalCancelRequest extends $pb.GeneratedMessage {
  factory WithdrawalCancelRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = WithdrawalCancelRequest._();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  WithdrawalCancelRequest._();

  factory WithdrawalCancelRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalCancelRequest()..mergeFromBuffer(data, registry);
  factory WithdrawalCancelRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalCancelRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawalCancelRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: WithdrawalCancelRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalCancelRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalCancelRequest copyWith(
          void Function(WithdrawalCancelRequest) updates) =>
      super.copyWith((message) => updates(message as WithdrawalCancelRequest))
          as WithdrawalCancelRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WithdrawalCancelRequest() / WithdrawalCancelRequest.new instead')
  static WithdrawalCancelRequest create() => WithdrawalCancelRequest._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalCancelRequest._();
  @$core.override
  WithdrawalCancelRequest createEmptyInstance() => WithdrawalCancelRequest._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalCancelRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalCancelRequest>(
          WithdrawalCancelRequest.$_createMessage);
  static WithdrawalCancelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class WithdrawalCancelResponse extends $pb.GeneratedMessage {
  factory WithdrawalCancelResponse({
    WithdrawalObject? data,
  }) {
    final result = WithdrawalCancelResponse._();
    if (data != null) result.data = data;
    return result;
  }

  WithdrawalCancelResponse._();

  factory WithdrawalCancelResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalCancelResponse()..mergeFromBuffer(data, registry);
  factory WithdrawalCancelResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalCancelResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawalCancelResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: WithdrawalCancelResponse.$_createMessage)
    ..aOM<WithdrawalObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: WithdrawalObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalCancelResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalCancelResponse copyWith(
          void Function(WithdrawalCancelResponse) updates) =>
      super.copyWith((message) => updates(message as WithdrawalCancelResponse))
          as WithdrawalCancelResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WithdrawalCancelResponse() / WithdrawalCancelResponse.new instead')
  static WithdrawalCancelResponse create() => WithdrawalCancelResponse._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalCancelResponse._();
  @$core.override
  WithdrawalCancelResponse createEmptyInstance() =>
      WithdrawalCancelResponse._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalCancelResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalCancelResponse>(
          WithdrawalCancelResponse.$_createMessage);
  static WithdrawalCancelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WithdrawalObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WithdrawalObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  WithdrawalObject ensureData() => $_ensure(0);
}

class WithdrawalGetRequest extends $pb.GeneratedMessage {
  factory WithdrawalGetRequest({
    $core.String? id,
  }) {
    final result = WithdrawalGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  WithdrawalGetRequest._();

  factory WithdrawalGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalGetRequest()..mergeFromBuffer(data, registry);
  factory WithdrawalGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawalGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: WithdrawalGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalGetRequest copyWith(void Function(WithdrawalGetRequest) updates) =>
      super.copyWith((message) => updates(message as WithdrawalGetRequest))
          as WithdrawalGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WithdrawalGetRequest() / WithdrawalGetRequest.new instead')
  static WithdrawalGetRequest create() => WithdrawalGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalGetRequest._();
  @$core.override
  WithdrawalGetRequest createEmptyInstance() => WithdrawalGetRequest._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalGetRequest>(
          WithdrawalGetRequest.$_createMessage);
  static WithdrawalGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class WithdrawalGetResponse extends $pb.GeneratedMessage {
  factory WithdrawalGetResponse({
    WithdrawalObject? data,
  }) {
    final result = WithdrawalGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  WithdrawalGetResponse._();

  factory WithdrawalGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalGetResponse()..mergeFromBuffer(data, registry);
  factory WithdrawalGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawalGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: WithdrawalGetResponse.$_createMessage)
    ..aOM<WithdrawalObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: WithdrawalObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalGetResponse copyWith(
          void Function(WithdrawalGetResponse) updates) =>
      super.copyWith((message) => updates(message as WithdrawalGetResponse))
          as WithdrawalGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WithdrawalGetResponse() / WithdrawalGetResponse.new instead')
  static WithdrawalGetResponse create() => WithdrawalGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalGetResponse._();
  @$core.override
  WithdrawalGetResponse createEmptyInstance() => WithdrawalGetResponse._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalGetResponse>(
          WithdrawalGetResponse.$_createMessage);
  static WithdrawalGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WithdrawalObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WithdrawalObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  WithdrawalObject ensureData() => $_ensure(0);
}

class WithdrawalSearchRequest extends $pb.GeneratedMessage {
  factory WithdrawalSearchRequest({
    $core.String? savingsAccountId,
    WithdrawalStatus? status,
    $2.PageCursor? cursor,
  }) {
    final result = WithdrawalSearchRequest._();
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    if (status != null) result.status = status;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  WithdrawalSearchRequest._();

  factory WithdrawalSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalSearchRequest()..mergeFromBuffer(data, registry);
  factory WithdrawalSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawalSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: WithdrawalSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aE<WithdrawalStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: WithdrawalStatus.values)
    ..aOM<$2.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalSearchRequest copyWith(
          void Function(WithdrawalSearchRequest) updates) =>
      super.copyWith((message) => updates(message as WithdrawalSearchRequest))
          as WithdrawalSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WithdrawalSearchRequest() / WithdrawalSearchRequest.new instead')
  static WithdrawalSearchRequest create() => WithdrawalSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalSearchRequest._();
  @$core.override
  WithdrawalSearchRequest createEmptyInstance() => WithdrawalSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalSearchRequest>(
          WithdrawalSearchRequest.$_createMessage);
  static WithdrawalSearchRequest? _defaultInstance;

  /// Optional: when empty, withdrawals across every account the caller can
  /// see are returned (e.g. an approval queue filtered by status).
  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  WithdrawalStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(WithdrawalStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($2.PageCursor value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.PageCursor ensureCursor() => $_ensure(2);
}

class WithdrawalSearchResponse extends $pb.GeneratedMessage {
  factory WithdrawalSearchResponse({
    $core.Iterable<WithdrawalObject>? data,
  }) {
    final result = WithdrawalSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  WithdrawalSearchResponse._();

  factory WithdrawalSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalSearchResponse()..mergeFromBuffer(data, registry);
  factory WithdrawalSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawalSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: WithdrawalSearchResponse.$_createMessage)
    ..pPM<WithdrawalObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: WithdrawalObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalSearchResponse copyWith(
          void Function(WithdrawalSearchResponse) updates) =>
      super.copyWith((message) => updates(message as WithdrawalSearchResponse))
          as WithdrawalSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WithdrawalSearchResponse() / WithdrawalSearchResponse.new instead')
  static WithdrawalSearchResponse create() => WithdrawalSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalSearchResponse._();
  @$core.override
  WithdrawalSearchResponse createEmptyInstance() =>
      WithdrawalSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalSearchResponse>(
          WithdrawalSearchResponse.$_createMessage);
  static WithdrawalSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WithdrawalObject> get data => $_getList(0);
}

class InterestAccrualGetRequest extends $pb.GeneratedMessage {
  factory InterestAccrualGetRequest({
    $core.String? id,
  }) {
    final result = InterestAccrualGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  InterestAccrualGetRequest._();

  factory InterestAccrualGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterestAccrualGetRequest()..mergeFromBuffer(data, registry);
  factory InterestAccrualGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterestAccrualGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InterestAccrualGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: InterestAccrualGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterestAccrualGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterestAccrualGetRequest copyWith(
          void Function(InterestAccrualGetRequest) updates) =>
      super.copyWith((message) => updates(message as InterestAccrualGetRequest))
          as InterestAccrualGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InterestAccrualGetRequest() / InterestAccrualGetRequest.new instead')
  static InterestAccrualGetRequest create() => InterestAccrualGetRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      InterestAccrualGetRequest._();
  @$core.override
  InterestAccrualGetRequest createEmptyInstance() =>
      InterestAccrualGetRequest._();
  @$core.pragma('dart2js:noInline')
  static InterestAccrualGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InterestAccrualGetRequest>(
          InterestAccrualGetRequest.$_createMessage);
  static InterestAccrualGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class InterestAccrualGetResponse extends $pb.GeneratedMessage {
  factory InterestAccrualGetResponse({
    InterestAccrualObject? data,
  }) {
    final result = InterestAccrualGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  InterestAccrualGetResponse._();

  factory InterestAccrualGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterestAccrualGetResponse()..mergeFromBuffer(data, registry);
  factory InterestAccrualGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterestAccrualGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InterestAccrualGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: InterestAccrualGetResponse.$_createMessage)
    ..aOM<InterestAccrualObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InterestAccrualObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterestAccrualGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterestAccrualGetResponse copyWith(
          void Function(InterestAccrualGetResponse) updates) =>
      super.copyWith(
              (message) => updates(message as InterestAccrualGetResponse))
          as InterestAccrualGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InterestAccrualGetResponse() / InterestAccrualGetResponse.new instead')
  static InterestAccrualGetResponse create() => InterestAccrualGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      InterestAccrualGetResponse._();
  @$core.override
  InterestAccrualGetResponse createEmptyInstance() =>
      InterestAccrualGetResponse._();
  @$core.pragma('dart2js:noInline')
  static InterestAccrualGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InterestAccrualGetResponse>(
          InterestAccrualGetResponse.$_createMessage);
  static InterestAccrualGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InterestAccrualObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InterestAccrualObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InterestAccrualObject ensureData() => $_ensure(0);
}

class InterestAccrualSearchRequest extends $pb.GeneratedMessage {
  factory InterestAccrualSearchRequest({
    $core.String? savingsAccountId,
    $2.PageCursor? cursor,
  }) {
    final result = InterestAccrualSearchRequest._();
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  InterestAccrualSearchRequest._();

  factory InterestAccrualSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterestAccrualSearchRequest()..mergeFromBuffer(data, registry);
  factory InterestAccrualSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterestAccrualSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InterestAccrualSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: InterestAccrualSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOM<$2.PageCursor>(2, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterestAccrualSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterestAccrualSearchRequest copyWith(
          void Function(InterestAccrualSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as InterestAccrualSearchRequest))
          as InterestAccrualSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InterestAccrualSearchRequest() / InterestAccrualSearchRequest.new instead')
  static InterestAccrualSearchRequest create() =>
      InterestAccrualSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      InterestAccrualSearchRequest._();
  @$core.override
  InterestAccrualSearchRequest createEmptyInstance() =>
      InterestAccrualSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static InterestAccrualSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InterestAccrualSearchRequest>(
          InterestAccrualSearchRequest.$_createMessage);
  static InterestAccrualSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.PageCursor get cursor => $_getN(1);
  @$pb.TagNumber(2)
  set cursor($2.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.PageCursor ensureCursor() => $_ensure(1);
}

class InterestAccrualSearchResponse extends $pb.GeneratedMessage {
  factory InterestAccrualSearchResponse({
    $core.Iterable<InterestAccrualObject>? data,
  }) {
    final result = InterestAccrualSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  InterestAccrualSearchResponse._();

  factory InterestAccrualSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterestAccrualSearchResponse()..mergeFromBuffer(data, registry);
  factory InterestAccrualSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterestAccrualSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InterestAccrualSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: InterestAccrualSearchResponse.$_createMessage)
    ..pPM<InterestAccrualObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InterestAccrualObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterestAccrualSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterestAccrualSearchResponse copyWith(
          void Function(InterestAccrualSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as InterestAccrualSearchResponse))
          as InterestAccrualSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InterestAccrualSearchResponse() / InterestAccrualSearchResponse.new instead')
  static InterestAccrualSearchResponse create() =>
      InterestAccrualSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      InterestAccrualSearchResponse._();
  @$core.override
  InterestAccrualSearchResponse createEmptyInstance() =>
      InterestAccrualSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static InterestAccrualSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InterestAccrualSearchResponse>(
          InterestAccrualSearchResponse.$_createMessage);
  static InterestAccrualSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<InterestAccrualObject> get data => $_getList(0);
}

class SavingsBalanceGetRequest extends $pb.GeneratedMessage {
  factory SavingsBalanceGetRequest({
    $core.String? savingsAccountId,
  }) {
    final result = SavingsBalanceGetRequest._();
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    return result;
  }

  SavingsBalanceGetRequest._();

  factory SavingsBalanceGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsBalanceGetRequest()..mergeFromBuffer(data, registry);
  factory SavingsBalanceGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsBalanceGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsBalanceGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsBalanceGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsBalanceGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsBalanceGetRequest copyWith(
          void Function(SavingsBalanceGetRequest) updates) =>
      super.copyWith((message) => updates(message as SavingsBalanceGetRequest))
          as SavingsBalanceGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsBalanceGetRequest() / SavingsBalanceGetRequest.new instead')
  static SavingsBalanceGetRequest create() => SavingsBalanceGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => SavingsBalanceGetRequest._();
  @$core.override
  SavingsBalanceGetRequest createEmptyInstance() =>
      SavingsBalanceGetRequest._();
  @$core.pragma('dart2js:noInline')
  static SavingsBalanceGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsBalanceGetRequest>(
          SavingsBalanceGetRequest.$_createMessage);
  static SavingsBalanceGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => $_clearField(1);
}

class SavingsBalanceGetResponse extends $pb.GeneratedMessage {
  factory SavingsBalanceGetResponse({
    SavingsBalanceObject? data,
  }) {
    final result = SavingsBalanceGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  SavingsBalanceGetResponse._();

  factory SavingsBalanceGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsBalanceGetResponse()..mergeFromBuffer(data, registry);
  factory SavingsBalanceGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsBalanceGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsBalanceGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsBalanceGetResponse.$_createMessage)
    ..aOM<SavingsBalanceObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: SavingsBalanceObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsBalanceGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsBalanceGetResponse copyWith(
          void Function(SavingsBalanceGetResponse) updates) =>
      super.copyWith((message) => updates(message as SavingsBalanceGetResponse))
          as SavingsBalanceGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsBalanceGetResponse() / SavingsBalanceGetResponse.new instead')
  static SavingsBalanceGetResponse create() => SavingsBalanceGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      SavingsBalanceGetResponse._();
  @$core.override
  SavingsBalanceGetResponse createEmptyInstance() =>
      SavingsBalanceGetResponse._();
  @$core.pragma('dart2js:noInline')
  static SavingsBalanceGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsBalanceGetResponse>(
          SavingsBalanceGetResponse.$_createMessage);
  static SavingsBalanceGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsBalanceObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(SavingsBalanceObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  SavingsBalanceObject ensureData() => $_ensure(0);
}

class SavingsStatementRequest extends $pb.GeneratedMessage {
  factory SavingsStatementRequest({
    $core.String? savingsAccountId,
    $core.String? fromDate,
    $core.String? toDate,
    $2.PageCursor? cursor,
  }) {
    final result = SavingsStatementRequest._();
    if (savingsAccountId != null) result.savingsAccountId = savingsAccountId;
    if (fromDate != null) result.fromDate = fromDate;
    if (toDate != null) result.toDate = toDate;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  SavingsStatementRequest._();

  factory SavingsStatementRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsStatementRequest()..mergeFromBuffer(data, registry);
  factory SavingsStatementRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsStatementRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsStatementRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsStatementRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'savingsAccountId')
    ..aOS(2, _omitFieldNames ? '' : 'fromDate')
    ..aOS(3, _omitFieldNames ? '' : 'toDate')
    ..aOM<$2.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsStatementRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsStatementRequest copyWith(
          void Function(SavingsStatementRequest) updates) =>
      super.copyWith((message) => updates(message as SavingsStatementRequest))
          as SavingsStatementRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsStatementRequest() / SavingsStatementRequest.new instead')
  static SavingsStatementRequest create() => SavingsStatementRequest._();
  static $pb.GeneratedMessage $_createMessage() => SavingsStatementRequest._();
  @$core.override
  SavingsStatementRequest createEmptyInstance() => SavingsStatementRequest._();
  @$core.pragma('dart2js:noInline')
  static SavingsStatementRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsStatementRequest>(
          SavingsStatementRequest.$_createMessage);
  static SavingsStatementRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get savingsAccountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set savingsAccountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSavingsAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSavingsAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fromDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set fromDate($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromDate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get toDate => $_getSZ(2);
  @$pb.TagNumber(3)
  set toDate($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearToDate() => $_clearField(3);

  /// Page window over the statement entries. Unset returns the first page.
  @$pb.TagNumber(4)
  $2.PageCursor get cursor => $_getN(3);
  @$pb.TagNumber(4)
  set cursor($2.PageCursor value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursor() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.PageCursor ensureCursor() => $_ensure(3);
}

class SavingsStatementResponse extends $pb.GeneratedMessage {
  factory SavingsStatementResponse({
    SavingsAccountObject? account,
    SavingsBalanceObject? balance,
    $core.Iterable<SavingsStatementEntry>? entries,
    $2.PageCursor? nextCursor,
  }) {
    final result = SavingsStatementResponse._();
    if (account != null) result.account = account;
    if (balance != null) result.balance = balance;
    if (entries != null) result.entries.addAll(entries);
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  SavingsStatementResponse._();

  factory SavingsStatementResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsStatementResponse()..mergeFromBuffer(data, registry);
  factory SavingsStatementResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SavingsStatementResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavingsStatementResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'savings.v1'),
      createEmptyInstance: SavingsStatementResponse.$_createMessage)
    ..aOM<SavingsAccountObject>(1, _omitFieldNames ? '' : 'account',
        subBuilder: SavingsAccountObject.$_createMessage)
    ..aOM<SavingsBalanceObject>(2, _omitFieldNames ? '' : 'balance',
        subBuilder: SavingsBalanceObject.$_createMessage)
    ..pPM<SavingsStatementEntry>(3, _omitFieldNames ? '' : 'entries',
        subBuilder: SavingsStatementEntry.$_createMessage)
    ..aOM<$2.PageCursor>(4, _omitFieldNames ? '' : 'nextCursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsStatementResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavingsStatementResponse copyWith(
          void Function(SavingsStatementResponse) updates) =>
      super.copyWith((message) => updates(message as SavingsStatementResponse))
          as SavingsStatementResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SavingsStatementResponse() / SavingsStatementResponse.new instead')
  static SavingsStatementResponse create() => SavingsStatementResponse._();
  static $pb.GeneratedMessage $_createMessage() => SavingsStatementResponse._();
  @$core.override
  SavingsStatementResponse createEmptyInstance() =>
      SavingsStatementResponse._();
  @$core.pragma('dart2js:noInline')
  static SavingsStatementResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavingsStatementResponse>(
          SavingsStatementResponse.$_createMessage);
  static SavingsStatementResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SavingsAccountObject get account => $_getN(0);
  @$pb.TagNumber(1)
  set account(SavingsAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccount() => $_clearField(1);
  @$pb.TagNumber(1)
  SavingsAccountObject ensureAccount() => $_ensure(0);

  @$pb.TagNumber(2)
  SavingsBalanceObject get balance => $_getN(1);
  @$pb.TagNumber(2)
  set balance(SavingsBalanceObject value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBalance() => $_has(1);
  @$pb.TagNumber(2)
  void clearBalance() => $_clearField(2);
  @$pb.TagNumber(2)
  SavingsBalanceObject ensureBalance() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<SavingsStatementEntry> get entries => $_getList(2);

  /// Cursor for the next page of entries; unset when this page is the last.
  @$pb.TagNumber(4)
  $2.PageCursor get nextCursor => $_getN(3);
  @$pb.TagNumber(4)
  set nextCursor($2.PageCursor value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasNextCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearNextCursor() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.PageCursor ensureNextCursor() => $_ensure(3);
}

/// SavingsService manages savings products, accounts, deposits, withdrawals,
/// and interest accruals.
/// All RPCs require authentication via Bearer token.
class SavingsServiceApi {
  final $pb.RpcClient _client;

  SavingsServiceApi(this._client);

  /// SavingsProductSave creates or updates a savings product.
  $async.Future<SavingsProductSaveResponse> savingsProductSave(
          $pb.ClientContext? ctx, SavingsProductSaveRequest request) =>
      _client.invoke<SavingsProductSaveResponse>(ctx, 'SavingsService',
          'SavingsProductSave', request, SavingsProductSaveResponse());

  /// SavingsProductGet retrieves a savings product by its ID.
  $async.Future<SavingsProductGetResponse> savingsProductGet(
          $pb.ClientContext? ctx, SavingsProductGetRequest request) =>
      _client.invoke<SavingsProductGetResponse>(ctx, 'SavingsService',
          'SavingsProductGet', request, SavingsProductGetResponse());

  /// SavingsProductSearch finds savings products matching search criteria.
  $async.Future<SavingsProductSearchResponse> savingsProductSearch(
          $pb.ClientContext? ctx, SavingsProductSearchRequest request) =>
      _client.invoke<SavingsProductSearchResponse>(ctx, 'SavingsService',
          'SavingsProductSearch', request, SavingsProductSearchResponse());

  /// SavingsAccountCreate creates a new savings account.
  $async.Future<SavingsAccountCreateResponse> savingsAccountCreate(
          $pb.ClientContext? ctx, SavingsAccountCreateRequest request) =>
      _client.invoke<SavingsAccountCreateResponse>(ctx, 'SavingsService',
          'SavingsAccountCreate', request, SavingsAccountCreateResponse());

  /// SavingsAccountGet retrieves a savings account by its ID.
  $async.Future<SavingsAccountGetResponse> savingsAccountGet(
          $pb.ClientContext? ctx, SavingsAccountGetRequest request) =>
      _client.invoke<SavingsAccountGetResponse>(ctx, 'SavingsService',
          'SavingsAccountGet', request, SavingsAccountGetResponse());

  /// SavingsAccountSearch finds savings accounts matching search criteria.
  $async.Future<SavingsAccountSearchResponse> savingsAccountSearch(
          $pb.ClientContext? ctx, SavingsAccountSearchRequest request) =>
      _client.invoke<SavingsAccountSearchResponse>(ctx, 'SavingsService',
          'SavingsAccountSearch', request, SavingsAccountSearchResponse());

  /// SavingsAccountFreeze freezes a savings account.
  $async.Future<SavingsAccountFreezeResponse> savingsAccountFreeze(
          $pb.ClientContext? ctx, SavingsAccountFreezeRequest request) =>
      _client.invoke<SavingsAccountFreezeResponse>(ctx, 'SavingsService',
          'SavingsAccountFreeze', request, SavingsAccountFreezeResponse());

  /// SavingsAccountClose closes a savings account.
  $async.Future<SavingsAccountCloseResponse> savingsAccountClose(
          $pb.ClientContext? ctx, SavingsAccountCloseRequest request) =>
      _client.invoke<SavingsAccountCloseResponse>(ctx, 'SavingsService',
          'SavingsAccountClose', request, SavingsAccountCloseResponse());

  /// DepositRecord records a deposit into a savings account.
  $async.Future<DepositRecordResponse> depositRecord(
          $pb.ClientContext? ctx, DepositRecordRequest request) =>
      _client.invoke<DepositRecordResponse>(ctx, 'SavingsService',
          'DepositRecord', request, DepositRecordResponse());

  /// DepositGet retrieves a deposit by its ID.
  $async.Future<DepositGetResponse> depositGet(
          $pb.ClientContext? ctx, DepositGetRequest request) =>
      _client.invoke<DepositGetResponse>(
          ctx, 'SavingsService', 'DepositGet', request, DepositGetResponse());

  /// DepositSearch finds deposits for a savings account.
  $async.Future<DepositSearchResponse> depositSearch(
          $pb.ClientContext? ctx, DepositSearchRequest request) =>
      _client.invoke<DepositSearchResponse>(ctx, 'SavingsService',
          'DepositSearch', request, DepositSearchResponse());

  /// WithdrawalRequest requests a withdrawal from a savings account.
  $async.Future<WithdrawalRequestResponse> withdrawalRequest(
          $pb.ClientContext? ctx, WithdrawalRequestRequest request) =>
      _client.invoke<WithdrawalRequestResponse>(ctx, 'SavingsService',
          'WithdrawalRequest', request, WithdrawalRequestResponse());

  /// WithdrawalApprove approves a pending withdrawal.
  $async.Future<WithdrawalApproveResponse> withdrawalApprove(
          $pb.ClientContext? ctx, WithdrawalApproveRequest request) =>
      _client.invoke<WithdrawalApproveResponse>(ctx, 'SavingsService',
          'WithdrawalApprove', request, WithdrawalApproveResponse());

  /// WithdrawalCancel rejects a pending withdrawal and releases the reserved balance.
  $async.Future<WithdrawalCancelResponse> withdrawalCancel(
          $pb.ClientContext? ctx, WithdrawalCancelRequest request) =>
      _client.invoke<WithdrawalCancelResponse>(ctx, 'SavingsService',
          'WithdrawalCancel', request, WithdrawalCancelResponse());

  /// WithdrawalGet retrieves a withdrawal by its ID.
  $async.Future<WithdrawalGetResponse> withdrawalGet(
          $pb.ClientContext? ctx, WithdrawalGetRequest request) =>
      _client.invoke<WithdrawalGetResponse>(ctx, 'SavingsService',
          'WithdrawalGet', request, WithdrawalGetResponse());

  /// WithdrawalSearch finds withdrawals for a savings account.
  $async.Future<WithdrawalSearchResponse> withdrawalSearch(
          $pb.ClientContext? ctx, WithdrawalSearchRequest request) =>
      _client.invoke<WithdrawalSearchResponse>(ctx, 'SavingsService',
          'WithdrawalSearch', request, WithdrawalSearchResponse());

  /// InterestAccrualGet retrieves an interest accrual by its ID.
  $async.Future<InterestAccrualGetResponse> interestAccrualGet(
          $pb.ClientContext? ctx, InterestAccrualGetRequest request) =>
      _client.invoke<InterestAccrualGetResponse>(ctx, 'SavingsService',
          'InterestAccrualGet', request, InterestAccrualGetResponse());

  /// InterestAccrualSearch finds interest accruals for a savings account.
  $async.Future<InterestAccrualSearchResponse> interestAccrualSearch(
          $pb.ClientContext? ctx, InterestAccrualSearchRequest request) =>
      _client.invoke<InterestAccrualSearchResponse>(ctx, 'SavingsService',
          'InterestAccrualSearch', request, InterestAccrualSearchResponse());

  /// SavingsBalanceGet retrieves the current balance of a savings account.
  $async.Future<SavingsBalanceGetResponse> savingsBalanceGet(
          $pb.ClientContext? ctx, SavingsBalanceGetRequest request) =>
      _client.invoke<SavingsBalanceGetResponse>(ctx, 'SavingsService',
          'SavingsBalanceGet', request, SavingsBalanceGetResponse());

  /// SavingsStatement generates a savings statement for a date range.
  $async.Future<SavingsStatementResponse> savingsStatement(
          $pb.ClientContext? ctx, SavingsStatementRequest request) =>
      _client.invoke<SavingsStatementResponse>(ctx, 'SavingsService',
          'SavingsStatement', request, SavingsStatementResponse());

  /// PayoutFailedApply undoes this service's record of a payout the payment
  /// rail failed after accepting it. Only operations calls it.
  $async.Future<PayoutFailedApplyResponse> payoutFailedApply(
          $pb.ClientContext? ctx, PayoutFailedApplyRequest request) =>
      _client.invoke<PayoutFailedApplyResponse>(ctx, 'SavingsService',
          'PayoutFailedApply', request, PayoutFailedApplyResponse());

  /// SavingsJobRun runs one batch of a periodic job. Called by the platform
  /// scheduler (trustage); nothing in the service runs on a timer.
  $async.Future<SavingsJobRunResponse> savingsJobRun(
          $pb.ClientContext? ctx, SavingsJobRunRequest request) =>
      _client.invoke<SavingsJobRunResponse>(ctx, 'SavingsService',
          'SavingsJobRun', request, SavingsJobRunResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
