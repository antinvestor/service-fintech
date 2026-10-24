// This is a generated file - do not edit.
//
// Generated from funding/v1/funding.proto.

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

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// InvestorAccountObject represents a pre-funded investor capital account.
class InvestorAccountObject extends $pb.GeneratedMessage {
  factory InvestorAccountObject({
    $core.String? id,
    $core.String? investorId,
    $core.String? accountName,
    $0.Money? availableBalance,
    $0.Money? reservedBalance,
    $0.Money? totalDeployed,
    $0.Money? totalReturned,
    $0.Money? maxExposure,
    $core.String? minInterestRate,
    $1.Struct? allowedProducts,
    $1.Struct? allowedRegions,
    $1.Struct? groupAffiliations,
    $2.STATE? state,
    $1.Struct? properties,
    $core.String? currencyCode,
  }) {
    final result = InvestorAccountObject._();
    if (id != null) result.id = id;
    if (investorId != null) result.investorId = investorId;
    if (accountName != null) result.accountName = accountName;
    if (availableBalance != null) result.availableBalance = availableBalance;
    if (reservedBalance != null) result.reservedBalance = reservedBalance;
    if (totalDeployed != null) result.totalDeployed = totalDeployed;
    if (totalReturned != null) result.totalReturned = totalReturned;
    if (maxExposure != null) result.maxExposure = maxExposure;
    if (minInterestRate != null) result.minInterestRate = minInterestRate;
    if (allowedProducts != null) result.allowedProducts = allowedProducts;
    if (allowedRegions != null) result.allowedRegions = allowedRegions;
    if (groupAffiliations != null) result.groupAffiliations = groupAffiliations;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    if (currencyCode != null) result.currencyCode = currencyCode;
    return result;
  }

  InvestorAccountObject._();

  factory InvestorAccountObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountObject()..mergeFromBuffer(data, registry);
  factory InvestorAccountObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorAccountObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: InvestorAccountObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'investorId')
    ..aOS(3, _omitFieldNames ? '' : 'accountName')
    ..aOM<$0.Money>(5, _omitFieldNames ? '' : 'availableBalance',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(6, _omitFieldNames ? '' : 'reservedBalance',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(7, _omitFieldNames ? '' : 'totalDeployed',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(8, _omitFieldNames ? '' : 'totalReturned',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(9, _omitFieldNames ? '' : 'maxExposure',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(10, _omitFieldNames ? '' : 'minInterestRate')
    ..aOM<$1.Struct>(11, _omitFieldNames ? '' : 'allowedProducts',
        subBuilder: $1.Struct.$_createMessage)
    ..aOM<$1.Struct>(12, _omitFieldNames ? '' : 'allowedRegions',
        subBuilder: $1.Struct.$_createMessage)
    ..aOM<$1.Struct>(13, _omitFieldNames ? '' : 'groupAffiliations',
        subBuilder: $1.Struct.$_createMessage)
    ..aE<$2.STATE>(14, _omitFieldNames ? '' : 'state',
        enumValues: $2.STATE.values)
    ..aOM<$1.Struct>(15, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..aOS(16, _omitFieldNames ? '' : 'currencyCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountObject copyWith(
          void Function(InvestorAccountObject) updates) =>
      super.copyWith((message) => updates(message as InvestorAccountObject))
          as InvestorAccountObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorAccountObject() / InvestorAccountObject.new instead')
  static InvestorAccountObject create() => InvestorAccountObject._();
  static $pb.GeneratedMessage $_createMessage() => InvestorAccountObject._();
  @$core.override
  InvestorAccountObject createEmptyInstance() => InvestorAccountObject._();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorAccountObject>(
          InvestorAccountObject.$_createMessage);
  static InvestorAccountObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get investorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set investorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInvestorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInvestorId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get accountName => $_getSZ(2);
  @$pb.TagNumber(3)
  set accountName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccountName() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccountName() => $_clearField(3);

  @$pb.TagNumber(5)
  $0.Money get availableBalance => $_getN(3);
  @$pb.TagNumber(5)
  set availableBalance($0.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAvailableBalance() => $_has(3);
  @$pb.TagNumber(5)
  void clearAvailableBalance() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Money ensureAvailableBalance() => $_ensure(3);

  @$pb.TagNumber(6)
  $0.Money get reservedBalance => $_getN(4);
  @$pb.TagNumber(6)
  set reservedBalance($0.Money value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasReservedBalance() => $_has(4);
  @$pb.TagNumber(6)
  void clearReservedBalance() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Money ensureReservedBalance() => $_ensure(4);

  @$pb.TagNumber(7)
  $0.Money get totalDeployed => $_getN(5);
  @$pb.TagNumber(7)
  set totalDeployed($0.Money value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTotalDeployed() => $_has(5);
  @$pb.TagNumber(7)
  void clearTotalDeployed() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Money ensureTotalDeployed() => $_ensure(5);

  @$pb.TagNumber(8)
  $0.Money get totalReturned => $_getN(6);
  @$pb.TagNumber(8)
  set totalReturned($0.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasTotalReturned() => $_has(6);
  @$pb.TagNumber(8)
  void clearTotalReturned() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Money ensureTotalReturned() => $_ensure(6);

  @$pb.TagNumber(9)
  $0.Money get maxExposure => $_getN(7);
  @$pb.TagNumber(9)
  set maxExposure($0.Money value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasMaxExposure() => $_has(7);
  @$pb.TagNumber(9)
  void clearMaxExposure() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Money ensureMaxExposure() => $_ensure(7);

  /// Minimum acceptable loan interest rate as a decimal percentage with up to
  /// two decimals, e.g. "12.50" for 12.5%. The same shape savings and loans
  /// use. Empty means no minimum. A raw basis-point integer is not accepted.
  @$pb.TagNumber(10)
  $core.String get minInterestRate => $_getSZ(8);
  @$pb.TagNumber(10)
  set minInterestRate($core.String value) => $_setString(8, value);
  @$pb.TagNumber(10)
  $core.bool hasMinInterestRate() => $_has(8);
  @$pb.TagNumber(10)
  void clearMinInterestRate() => $_clearField(10);

  @$pb.TagNumber(11)
  $1.Struct get allowedProducts => $_getN(9);
  @$pb.TagNumber(11)
  set allowedProducts($1.Struct value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasAllowedProducts() => $_has(9);
  @$pb.TagNumber(11)
  void clearAllowedProducts() => $_clearField(11);
  @$pb.TagNumber(11)
  $1.Struct ensureAllowedProducts() => $_ensure(9);

  @$pb.TagNumber(12)
  $1.Struct get allowedRegions => $_getN(10);
  @$pb.TagNumber(12)
  set allowedRegions($1.Struct value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasAllowedRegions() => $_has(10);
  @$pb.TagNumber(12)
  void clearAllowedRegions() => $_clearField(12);
  @$pb.TagNumber(12)
  $1.Struct ensureAllowedRegions() => $_ensure(10);

  @$pb.TagNumber(13)
  $1.Struct get groupAffiliations => $_getN(11);
  @$pb.TagNumber(13)
  set groupAffiliations($1.Struct value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasGroupAffiliations() => $_has(11);
  @$pb.TagNumber(13)
  void clearGroupAffiliations() => $_clearField(13);
  @$pb.TagNumber(13)
  $1.Struct ensureGroupAffiliations() => $_ensure(11);

  @$pb.TagNumber(14)
  $2.STATE get state => $_getN(12);
  @$pb.TagNumber(14)
  set state($2.STATE value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasState() => $_has(12);
  @$pb.TagNumber(14)
  void clearState() => $_clearField(14);

  @$pb.TagNumber(15)
  $1.Struct get properties => $_getN(13);
  @$pb.TagNumber(15)
  set properties($1.Struct value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasProperties() => $_has(13);
  @$pb.TagNumber(15)
  void clearProperties() => $_clearField(15);
  @$pb.TagNumber(15)
  $1.Struct ensureProperties() => $_ensure(13);

  /// ISO 4217 code the account is denominated in. Explicit so a caller no
  /// longer has to smuggle the currency through available_balance on create.
  /// When empty, the server falls back to available_balance.currency_code.
  @$pb.TagNumber(16)
  $core.String get currencyCode => $_getSZ(14);
  @$pb.TagNumber(16)
  set currencyCode($core.String value) => $_setString(14, value);
  @$pb.TagNumber(16)
  $core.bool hasCurrencyCode() => $_has(14);
  @$pb.TagNumber(16)
  void clearCurrencyCode() => $_clearField(16);
}

/// FundingAllocationObject represents how a loan is funded across tranches.
class FundingAllocationObject extends $pb.GeneratedMessage {
  factory FundingAllocationObject({
    $core.String? id,
    $core.String? loanRequestId,
    $core.String? sourceId,
    $core.String? sourceType,
    $core.int? trancheLevel,
    $0.Money? amount,
    $core.String? proportion,
    $1.Struct? properties,
  }) {
    final result = FundingAllocationObject._();
    if (id != null) result.id = id;
    if (loanRequestId != null) result.loanRequestId = loanRequestId;
    if (sourceId != null) result.sourceId = sourceId;
    if (sourceType != null) result.sourceType = sourceType;
    if (trancheLevel != null) result.trancheLevel = trancheLevel;
    if (amount != null) result.amount = amount;
    if (proportion != null) result.proportion = proportion;
    if (properties != null) result.properties = properties;
    return result;
  }

  FundingAllocationObject._();

  factory FundingAllocationObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FundingAllocationObject()..mergeFromBuffer(data, registry);
  factory FundingAllocationObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FundingAllocationObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FundingAllocationObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: FundingAllocationObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanRequestId')
    ..aOS(3, _omitFieldNames ? '' : 'sourceId')
    ..aOS(4, _omitFieldNames ? '' : 'sourceType')
    ..aI(5, _omitFieldNames ? '' : 'trancheLevel')
    ..aOM<$0.Money>(6, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'proportion')
    ..aOM<$1.Struct>(9, _omitFieldNames ? '' : 'properties',
        subBuilder: $1.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FundingAllocationObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FundingAllocationObject copyWith(
          void Function(FundingAllocationObject) updates) =>
      super.copyWith((message) => updates(message as FundingAllocationObject))
          as FundingAllocationObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FundingAllocationObject() / FundingAllocationObject.new instead')
  static FundingAllocationObject create() => FundingAllocationObject._();
  static $pb.GeneratedMessage $_createMessage() => FundingAllocationObject._();
  @$core.override
  FundingAllocationObject createEmptyInstance() => FundingAllocationObject._();
  @$core.pragma('dart2js:noInline')
  static FundingAllocationObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FundingAllocationObject>(
          FundingAllocationObject.$_createMessage);
  static FundingAllocationObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanRequestId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanRequestId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLoanRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanRequestId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sourceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sourceType => $_getSZ(3);
  @$pb.TagNumber(4)
  set sourceType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSourceType() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourceType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get trancheLevel => $_getIZ(4);
  @$pb.TagNumber(5)
  set trancheLevel($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTrancheLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearTrancheLevel() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Money get amount => $_getN(5);
  @$pb.TagNumber(6)
  set amount($0.Money value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAmount() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmount() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Money ensureAmount() => $_ensure(5);

  @$pb.TagNumber(8)
  $core.String get proportion => $_getSZ(6);
  @$pb.TagNumber(8)
  set proportion($core.String value) => $_setString(6, value);
  @$pb.TagNumber(8)
  $core.bool hasProportion() => $_has(6);
  @$pb.TagNumber(8)
  void clearProportion() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.Struct get properties => $_getN(7);
  @$pb.TagNumber(9)
  set properties($1.Struct value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasProperties() => $_has(7);
  @$pb.TagNumber(9)
  void clearProperties() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Struct ensureProperties() => $_ensure(7);
}

class InvestorAccountSaveRequest extends $pb.GeneratedMessage {
  factory InvestorAccountSaveRequest({
    InvestorAccountObject? data,
  }) {
    final result = InvestorAccountSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  InvestorAccountSaveRequest._();

  factory InvestorAccountSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountSaveRequest()..mergeFromBuffer(data, registry);
  factory InvestorAccountSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorAccountSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: InvestorAccountSaveRequest.$_createMessage)
    ..aOM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InvestorAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountSaveRequest copyWith(
          void Function(InvestorAccountSaveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as InvestorAccountSaveRequest))
          as InvestorAccountSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorAccountSaveRequest() / InvestorAccountSaveRequest.new instead')
  static InvestorAccountSaveRequest create() => InvestorAccountSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      InvestorAccountSaveRequest._();
  @$core.override
  InvestorAccountSaveRequest createEmptyInstance() =>
      InvestorAccountSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorAccountSaveRequest>(
          InvestorAccountSaveRequest.$_createMessage);
  static InvestorAccountSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InvestorAccountObject ensureData() => $_ensure(0);
}

class InvestorAccountSaveResponse extends $pb.GeneratedMessage {
  factory InvestorAccountSaveResponse({
    InvestorAccountObject? data,
  }) {
    final result = InvestorAccountSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  InvestorAccountSaveResponse._();

  factory InvestorAccountSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountSaveResponse()..mergeFromBuffer(data, registry);
  factory InvestorAccountSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorAccountSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: InvestorAccountSaveResponse.$_createMessage)
    ..aOM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InvestorAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountSaveResponse copyWith(
          void Function(InvestorAccountSaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as InvestorAccountSaveResponse))
          as InvestorAccountSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorAccountSaveResponse() / InvestorAccountSaveResponse.new instead')
  static InvestorAccountSaveResponse create() =>
      InvestorAccountSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      InvestorAccountSaveResponse._();
  @$core.override
  InvestorAccountSaveResponse createEmptyInstance() =>
      InvestorAccountSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorAccountSaveResponse>(
          InvestorAccountSaveResponse.$_createMessage);
  static InvestorAccountSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InvestorAccountObject ensureData() => $_ensure(0);
}

class InvestorAccountGetRequest extends $pb.GeneratedMessage {
  factory InvestorAccountGetRequest({
    $core.String? id,
  }) {
    final result = InvestorAccountGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  InvestorAccountGetRequest._();

  factory InvestorAccountGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountGetRequest()..mergeFromBuffer(data, registry);
  factory InvestorAccountGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorAccountGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: InvestorAccountGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountGetRequest copyWith(
          void Function(InvestorAccountGetRequest) updates) =>
      super.copyWith((message) => updates(message as InvestorAccountGetRequest))
          as InvestorAccountGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorAccountGetRequest() / InvestorAccountGetRequest.new instead')
  static InvestorAccountGetRequest create() => InvestorAccountGetRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      InvestorAccountGetRequest._();
  @$core.override
  InvestorAccountGetRequest createEmptyInstance() =>
      InvestorAccountGetRequest._();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorAccountGetRequest>(
          InvestorAccountGetRequest.$_createMessage);
  static InvestorAccountGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class InvestorAccountGetResponse extends $pb.GeneratedMessage {
  factory InvestorAccountGetResponse({
    InvestorAccountObject? data,
  }) {
    final result = InvestorAccountGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  InvestorAccountGetResponse._();

  factory InvestorAccountGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountGetResponse()..mergeFromBuffer(data, registry);
  factory InvestorAccountGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorAccountGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: InvestorAccountGetResponse.$_createMessage)
    ..aOM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InvestorAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountGetResponse copyWith(
          void Function(InvestorAccountGetResponse) updates) =>
      super.copyWith(
              (message) => updates(message as InvestorAccountGetResponse))
          as InvestorAccountGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorAccountGetResponse() / InvestorAccountGetResponse.new instead')
  static InvestorAccountGetResponse create() => InvestorAccountGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      InvestorAccountGetResponse._();
  @$core.override
  InvestorAccountGetResponse createEmptyInstance() =>
      InvestorAccountGetResponse._();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorAccountGetResponse>(
          InvestorAccountGetResponse.$_createMessage);
  static InvestorAccountGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InvestorAccountObject ensureData() => $_ensure(0);
}

class InvestorAccountSearchRequest extends $pb.GeneratedMessage {
  factory InvestorAccountSearchRequest({
    $core.String? investorId,
    $core.String? currencyCode,
    $2.PageCursor? cursor,
  }) {
    final result = InvestorAccountSearchRequest._();
    if (investorId != null) result.investorId = investorId;
    if (currencyCode != null) result.currencyCode = currencyCode;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  InvestorAccountSearchRequest._();

  factory InvestorAccountSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountSearchRequest()..mergeFromBuffer(data, registry);
  factory InvestorAccountSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorAccountSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: InvestorAccountSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'investorId')
    ..aOS(2, _omitFieldNames ? '' : 'currencyCode')
    ..aOM<$2.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountSearchRequest copyWith(
          void Function(InvestorAccountSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as InvestorAccountSearchRequest))
          as InvestorAccountSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorAccountSearchRequest() / InvestorAccountSearchRequest.new instead')
  static InvestorAccountSearchRequest create() =>
      InvestorAccountSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      InvestorAccountSearchRequest._();
  @$core.override
  InvestorAccountSearchRequest createEmptyInstance() =>
      InvestorAccountSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorAccountSearchRequest>(
          InvestorAccountSearchRequest.$_createMessage);
  static InvestorAccountSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get investorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set investorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInvestorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearInvestorId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get currencyCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set currencyCode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCurrencyCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrencyCode() => $_clearField(2);

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

class InvestorAccountSearchResponse extends $pb.GeneratedMessage {
  factory InvestorAccountSearchResponse({
    $core.Iterable<InvestorAccountObject>? data,
    $2.PageCursor? nextCursor,
  }) {
    final result = InvestorAccountSearchResponse._();
    if (data != null) result.data.addAll(data);
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  InvestorAccountSearchResponse._();

  factory InvestorAccountSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountSearchResponse()..mergeFromBuffer(data, registry);
  factory InvestorAccountSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorAccountSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorAccountSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: InvestorAccountSearchResponse.$_createMessage)
    ..pPM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InvestorAccountObject.$_createMessage)
    ..aOM<$2.PageCursor>(2, _omitFieldNames ? '' : 'nextCursor',
        subBuilder: $2.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorAccountSearchResponse copyWith(
          void Function(InvestorAccountSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as InvestorAccountSearchResponse))
          as InvestorAccountSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorAccountSearchResponse() / InvestorAccountSearchResponse.new instead')
  static InvestorAccountSearchResponse create() =>
      InvestorAccountSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      InvestorAccountSearchResponse._();
  @$core.override
  InvestorAccountSearchResponse createEmptyInstance() =>
      InvestorAccountSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorAccountSearchResponse>(
          InvestorAccountSearchResponse.$_createMessage);
  static InvestorAccountSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<InvestorAccountObject> get data => $_getList(0);

  /// Cursor for the next page; unset when this page is the last.
  @$pb.TagNumber(2)
  $2.PageCursor get nextCursor => $_getN(1);
  @$pb.TagNumber(2)
  set nextCursor($2.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.PageCursor ensureNextCursor() => $_ensure(1);
}

class InvestorDepositRequest extends $pb.GeneratedMessage {
  factory InvestorDepositRequest({
    $core.String? accountId,
    $0.Money? amount,
    $core.String? idempotencyKey,
  }) {
    final result = InvestorDepositRequest._();
    if (accountId != null) result.accountId = accountId;
    if (amount != null) result.amount = amount;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    return result;
  }

  InvestorDepositRequest._();

  factory InvestorDepositRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorDepositRequest()..mergeFromBuffer(data, registry);
  factory InvestorDepositRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorDepositRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorDepositRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: InvestorDepositRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'accountId')
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorDepositRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorDepositRequest copyWith(
          void Function(InvestorDepositRequest) updates) =>
      super.copyWith((message) => updates(message as InvestorDepositRequest))
          as InvestorDepositRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorDepositRequest() / InvestorDepositRequest.new instead')
  static InvestorDepositRequest create() => InvestorDepositRequest._();
  static $pb.GeneratedMessage $_createMessage() => InvestorDepositRequest._();
  @$core.override
  InvestorDepositRequest createEmptyInstance() => InvestorDepositRequest._();
  @$core.pragma('dart2js:noInline')
  static InvestorDepositRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorDepositRequest>(
          InvestorDepositRequest.$_createMessage);
  static InvestorDepositRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set accountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountId() => $_clearField(1);

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

  /// Replay key for this movement. Optional on the wire because the
  /// Idempotency-Key header is also honoured; when both are present the
  /// header wins. Non-empty values must be at least 8 characters.
  @$pb.TagNumber(4)
  $core.String get idempotencyKey => $_getSZ(2);
  @$pb.TagNumber(4)
  set idempotencyKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4)
  $core.bool hasIdempotencyKey() => $_has(2);
  @$pb.TagNumber(4)
  void clearIdempotencyKey() => $_clearField(4);
}

class InvestorDepositResponse extends $pb.GeneratedMessage {
  factory InvestorDepositResponse({
    InvestorAccountObject? data,
  }) {
    final result = InvestorDepositResponse._();
    if (data != null) result.data = data;
    return result;
  }

  InvestorDepositResponse._();

  factory InvestorDepositResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorDepositResponse()..mergeFromBuffer(data, registry);
  factory InvestorDepositResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorDepositResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorDepositResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: InvestorDepositResponse.$_createMessage)
    ..aOM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InvestorAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorDepositResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorDepositResponse copyWith(
          void Function(InvestorDepositResponse) updates) =>
      super.copyWith((message) => updates(message as InvestorDepositResponse))
          as InvestorDepositResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorDepositResponse() / InvestorDepositResponse.new instead')
  static InvestorDepositResponse create() => InvestorDepositResponse._();
  static $pb.GeneratedMessage $_createMessage() => InvestorDepositResponse._();
  @$core.override
  InvestorDepositResponse createEmptyInstance() => InvestorDepositResponse._();
  @$core.pragma('dart2js:noInline')
  static InvestorDepositResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorDepositResponse>(
          InvestorDepositResponse.$_createMessage);
  static InvestorDepositResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InvestorAccountObject ensureData() => $_ensure(0);
}

class InvestorWithdrawRequest extends $pb.GeneratedMessage {
  factory InvestorWithdrawRequest({
    $core.String? accountId,
    $0.Money? amount,
    $core.String? idempotencyKey,
  }) {
    final result = InvestorWithdrawRequest._();
    if (accountId != null) result.accountId = accountId;
    if (amount != null) result.amount = amount;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    return result;
  }

  InvestorWithdrawRequest._();

  factory InvestorWithdrawRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorWithdrawRequest()..mergeFromBuffer(data, registry);
  factory InvestorWithdrawRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorWithdrawRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorWithdrawRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: InvestorWithdrawRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'accountId')
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'idempotencyKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorWithdrawRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorWithdrawRequest copyWith(
          void Function(InvestorWithdrawRequest) updates) =>
      super.copyWith((message) => updates(message as InvestorWithdrawRequest))
          as InvestorWithdrawRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorWithdrawRequest() / InvestorWithdrawRequest.new instead')
  static InvestorWithdrawRequest create() => InvestorWithdrawRequest._();
  static $pb.GeneratedMessage $_createMessage() => InvestorWithdrawRequest._();
  @$core.override
  InvestorWithdrawRequest createEmptyInstance() => InvestorWithdrawRequest._();
  @$core.pragma('dart2js:noInline')
  static InvestorWithdrawRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorWithdrawRequest>(
          InvestorWithdrawRequest.$_createMessage);
  static InvestorWithdrawRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set accountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountId() => $_clearField(1);

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

  /// See InvestorDepositRequest.idempotency_key.
  @$pb.TagNumber(3)
  $core.String get idempotencyKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set idempotencyKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIdempotencyKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdempotencyKey() => $_clearField(3);
}

class InvestorWithdrawResponse extends $pb.GeneratedMessage {
  factory InvestorWithdrawResponse({
    InvestorAccountObject? data,
  }) {
    final result = InvestorWithdrawResponse._();
    if (data != null) result.data = data;
    return result;
  }

  InvestorWithdrawResponse._();

  factory InvestorWithdrawResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorWithdrawResponse()..mergeFromBuffer(data, registry);
  factory InvestorWithdrawResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorWithdrawResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorWithdrawResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: InvestorWithdrawResponse.$_createMessage)
    ..aOM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InvestorAccountObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorWithdrawResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorWithdrawResponse copyWith(
          void Function(InvestorWithdrawResponse) updates) =>
      super.copyWith((message) => updates(message as InvestorWithdrawResponse))
          as InvestorWithdrawResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorWithdrawResponse() / InvestorWithdrawResponse.new instead')
  static InvestorWithdrawResponse create() => InvestorWithdrawResponse._();
  static $pb.GeneratedMessage $_createMessage() => InvestorWithdrawResponse._();
  @$core.override
  InvestorWithdrawResponse createEmptyInstance() =>
      InvestorWithdrawResponse._();
  @$core.pragma('dart2js:noInline')
  static InvestorWithdrawResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorWithdrawResponse>(
          InvestorWithdrawResponse.$_createMessage);
  static InvestorWithdrawResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorAccountObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InvestorAccountObject ensureData() => $_ensure(0);
}

class FundLoanRequest extends $pb.GeneratedMessage {
  factory FundLoanRequest({
    $core.String? loanRequestId,
  }) {
    final result = FundLoanRequest._();
    if (loanRequestId != null) result.loanRequestId = loanRequestId;
    return result;
  }

  FundLoanRequest._();

  factory FundLoanRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FundLoanRequest()..mergeFromBuffer(data, registry);
  factory FundLoanRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FundLoanRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FundLoanRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: FundLoanRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanRequestId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FundLoanRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FundLoanRequest copyWith(void Function(FundLoanRequest) updates) =>
      super.copyWith((message) => updates(message as FundLoanRequest))
          as FundLoanRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FundLoanRequest() / FundLoanRequest.new instead')
  static FundLoanRequest create() => FundLoanRequest._();
  static $pb.GeneratedMessage $_createMessage() => FundLoanRequest._();
  @$core.override
  FundLoanRequest createEmptyInstance() => FundLoanRequest._();
  @$core.pragma('dart2js:noInline')
  static FundLoanRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FundLoanRequest>(
          FundLoanRequest.$_createMessage);
  static FundLoanRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanRequestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanRequestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanRequestId() => $_clearField(1);
}

class FundLoanResponse extends $pb.GeneratedMessage {
  factory FundLoanResponse({
    $core.Iterable<FundingAllocationObject>? allocations,
    $0.Money? totalAllocated,
    $0.Money? deficit,
    $core.bool? fullyFunded,
  }) {
    final result = FundLoanResponse._();
    if (allocations != null) result.allocations.addAll(allocations);
    if (totalAllocated != null) result.totalAllocated = totalAllocated;
    if (deficit != null) result.deficit = deficit;
    if (fullyFunded != null) result.fullyFunded = fullyFunded;
    return result;
  }

  FundLoanResponse._();

  factory FundLoanResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FundLoanResponse()..mergeFromBuffer(data, registry);
  factory FundLoanResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FundLoanResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FundLoanResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: FundLoanResponse.$_createMessage)
    ..pPM<FundingAllocationObject>(1, _omitFieldNames ? '' : 'allocations',
        subBuilder: FundingAllocationObject.$_createMessage)
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'totalAllocated',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'deficit',
        subBuilder: $0.Money.$_createMessage)
    ..aOB(4, _omitFieldNames ? '' : 'fullyFunded')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FundLoanResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FundLoanResponse copyWith(void Function(FundLoanResponse) updates) =>
      super.copyWith((message) => updates(message as FundLoanResponse))
          as FundLoanResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FundLoanResponse() / FundLoanResponse.new instead')
  static FundLoanResponse create() => FundLoanResponse._();
  static $pb.GeneratedMessage $_createMessage() => FundLoanResponse._();
  @$core.override
  FundLoanResponse createEmptyInstance() => FundLoanResponse._();
  @$core.pragma('dart2js:noInline')
  static FundLoanResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FundLoanResponse>(
          FundLoanResponse.$_createMessage);
  static FundLoanResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FundingAllocationObject> get allocations => $_getList(0);

  @$pb.TagNumber(2)
  $0.Money get totalAllocated => $_getN(1);
  @$pb.TagNumber(2)
  set totalAllocated($0.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalAllocated() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalAllocated() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Money ensureTotalAllocated() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Money get deficit => $_getN(2);
  @$pb.TagNumber(3)
  set deficit($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDeficit() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeficit() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensureDeficit() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.bool get fullyFunded => $_getBF(3);
  @$pb.TagNumber(4)
  set fullyFunded($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFullyFunded() => $_has(3);
  @$pb.TagNumber(4)
  void clearFullyFunded() => $_clearField(4);
}

class AbsorbLossRequest extends $pb.GeneratedMessage {
  factory AbsorbLossRequest({
    $core.String? loanRequestId,
    $0.Money? amount,
    $core.String? lossReference,
  }) {
    final result = AbsorbLossRequest._();
    if (loanRequestId != null) result.loanRequestId = loanRequestId;
    if (amount != null) result.amount = amount;
    if (lossReference != null) result.lossReference = lossReference;
    return result;
  }

  AbsorbLossRequest._();

  factory AbsorbLossRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AbsorbLossRequest()..mergeFromBuffer(data, registry);
  factory AbsorbLossRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AbsorbLossRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AbsorbLossRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: AbsorbLossRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'loanRequestId')
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'lossReference')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbsorbLossRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbsorbLossRequest copyWith(void Function(AbsorbLossRequest) updates) =>
      super.copyWith((message) => updates(message as AbsorbLossRequest))
          as AbsorbLossRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AbsorbLossRequest() / AbsorbLossRequest.new instead')
  static AbsorbLossRequest create() => AbsorbLossRequest._();
  static $pb.GeneratedMessage $_createMessage() => AbsorbLossRequest._();
  @$core.override
  AbsorbLossRequest createEmptyInstance() => AbsorbLossRequest._();
  @$core.pragma('dart2js:noInline')
  static AbsorbLossRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AbsorbLossRequest>(
          AbsorbLossRequest.$_createMessage);
  static AbsorbLossRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanRequestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanRequestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoanRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanRequestId() => $_clearField(1);

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

  /// Identifies the loss event (write-off reference, default notice id) so a
  /// repeated call for the same event absorbs once. Empty keeps the current
  /// per-loan idempotency.
  @$pb.TagNumber(3)
  $core.String get lossReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set lossReference($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLossReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearLossReference() => $_clearField(3);
}

class AbsorbLossResponse extends $pb.GeneratedMessage {
  factory AbsorbLossResponse({
    $0.Money? absorbed,
    $0.Money? unrecoverable,
  }) {
    final result = AbsorbLossResponse._();
    if (absorbed != null) result.absorbed = absorbed;
    if (unrecoverable != null) result.unrecoverable = unrecoverable;
    return result;
  }

  AbsorbLossResponse._();

  factory AbsorbLossResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AbsorbLossResponse()..mergeFromBuffer(data, registry);
  factory AbsorbLossResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AbsorbLossResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AbsorbLossResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'),
      createEmptyInstance: AbsorbLossResponse.$_createMessage)
    ..aOM<$0.Money>(1, _omitFieldNames ? '' : 'absorbed',
        subBuilder: $0.Money.$_createMessage)
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'unrecoverable',
        subBuilder: $0.Money.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbsorbLossResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbsorbLossResponse copyWith(void Function(AbsorbLossResponse) updates) =>
      super.copyWith((message) => updates(message as AbsorbLossResponse))
          as AbsorbLossResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AbsorbLossResponse() / AbsorbLossResponse.new instead')
  static AbsorbLossResponse create() => AbsorbLossResponse._();
  static $pb.GeneratedMessage $_createMessage() => AbsorbLossResponse._();
  @$core.override
  AbsorbLossResponse createEmptyInstance() => AbsorbLossResponse._();
  @$core.pragma('dart2js:noInline')
  static AbsorbLossResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AbsorbLossResponse>(
          AbsorbLossResponse.$_createMessage);
  static AbsorbLossResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Money get absorbed => $_getN(0);
  @$pb.TagNumber(1)
  set absorbed($0.Money value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAbsorbed() => $_has(0);
  @$pb.TagNumber(1)
  void clearAbsorbed() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Money ensureAbsorbed() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Money get unrecoverable => $_getN(1);
  @$pb.TagNumber(2)
  set unrecoverable($0.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUnrecoverable() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnrecoverable() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Money ensureUnrecoverable() => $_ensure(1);
}

class FundingServiceApi {
  final $pb.RpcClient _client;

  FundingServiceApi(this._client);

  $async.Future<InvestorAccountSaveResponse> investorAccountSave(
          $pb.ClientContext? ctx, InvestorAccountSaveRequest request) =>
      _client.invoke<InvestorAccountSaveResponse>(ctx, 'FundingService',
          'InvestorAccountSave', request, InvestorAccountSaveResponse());
  $async.Future<InvestorAccountGetResponse> investorAccountGet(
          $pb.ClientContext? ctx, InvestorAccountGetRequest request) =>
      _client.invoke<InvestorAccountGetResponse>(ctx, 'FundingService',
          'InvestorAccountGet', request, InvestorAccountGetResponse());
  $async.Future<InvestorAccountSearchResponse> investorAccountSearch(
          $pb.ClientContext? ctx, InvestorAccountSearchRequest request) =>
      _client.invoke<InvestorAccountSearchResponse>(ctx, 'FundingService',
          'InvestorAccountSearch', request, InvestorAccountSearchResponse());
  $async.Future<InvestorDepositResponse> investorDeposit(
          $pb.ClientContext? ctx, InvestorDepositRequest request) =>
      _client.invoke<InvestorDepositResponse>(ctx, 'FundingService',
          'InvestorDeposit', request, InvestorDepositResponse());
  $async.Future<InvestorWithdrawResponse> investorWithdraw(
          $pb.ClientContext? ctx, InvestorWithdrawRequest request) =>
      _client.invoke<InvestorWithdrawResponse>(ctx, 'FundingService',
          'InvestorWithdraw', request, InvestorWithdrawResponse());
  $async.Future<FundLoanResponse> fundLoan(
          $pb.ClientContext? ctx, FundLoanRequest request) =>
      _client.invoke<FundLoanResponse>(
          ctx, 'FundingService', 'FundLoan', request, FundLoanResponse());
  $async.Future<AbsorbLossResponse> absorbLoss(
          $pb.ClientContext? ctx, AbsorbLossRequest request) =>
      _client.invoke<AbsorbLossResponse>(
          ctx, 'FundingService', 'AbsorbLoss', request, AbsorbLossResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
