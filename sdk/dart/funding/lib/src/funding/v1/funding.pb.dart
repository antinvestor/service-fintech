//
//  Generated code. Do not modify.
//  source: funding/v1/funding.proto
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

/// InvestorAccountObject represents a pre-funded investor capital account.
class InvestorAccountObject extends $pb.GeneratedMessage {
  factory InvestorAccountObject({
    $core.String? id,
    $core.String? investorId,
    $core.String? accountName,
    $7.Money? availableBalance,
    $7.Money? reservedBalance,
    $7.Money? totalDeployed,
    $7.Money? totalReturned,
    $7.Money? maxExposure,
    $core.String? minInterestRate,
    $6.Struct? allowedProducts,
    $6.Struct? allowedRegions,
    $6.Struct? groupAffiliations,
    $8.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (investorId != null) {
      $result.investorId = investorId;
    }
    if (accountName != null) {
      $result.accountName = accountName;
    }
    if (availableBalance != null) {
      $result.availableBalance = availableBalance;
    }
    if (reservedBalance != null) {
      $result.reservedBalance = reservedBalance;
    }
    if (totalDeployed != null) {
      $result.totalDeployed = totalDeployed;
    }
    if (totalReturned != null) {
      $result.totalReturned = totalReturned;
    }
    if (maxExposure != null) {
      $result.maxExposure = maxExposure;
    }
    if (minInterestRate != null) {
      $result.minInterestRate = minInterestRate;
    }
    if (allowedProducts != null) {
      $result.allowedProducts = allowedProducts;
    }
    if (allowedRegions != null) {
      $result.allowedRegions = allowedRegions;
    }
    if (groupAffiliations != null) {
      $result.groupAffiliations = groupAffiliations;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  InvestorAccountObject._() : super();
  factory InvestorAccountObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorAccountObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'investorId')
    ..aOS(3, _omitFieldNames ? '' : 'accountName')
    ..aOM<$7.Money>(5, _omitFieldNames ? '' : 'availableBalance', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(6, _omitFieldNames ? '' : 'reservedBalance', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(7, _omitFieldNames ? '' : 'totalDeployed', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(8, _omitFieldNames ? '' : 'totalReturned', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(9, _omitFieldNames ? '' : 'maxExposure', subBuilder: $7.Money.create)
    ..aOS(10, _omitFieldNames ? '' : 'minInterestRate')
    ..aOM<$6.Struct>(11, _omitFieldNames ? '' : 'allowedProducts', subBuilder: $6.Struct.create)
    ..aOM<$6.Struct>(12, _omitFieldNames ? '' : 'allowedRegions', subBuilder: $6.Struct.create)
    ..aOM<$6.Struct>(13, _omitFieldNames ? '' : 'groupAffiliations', subBuilder: $6.Struct.create)
    ..e<$8.STATE>(14, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $8.STATE.CREATED, valueOf: $8.STATE.valueOf, enumValues: $8.STATE.values)
    ..aOM<$6.Struct>(15, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorAccountObject clone() => InvestorAccountObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorAccountObject copyWith(void Function(InvestorAccountObject) updates) => super.copyWith((message) => updates(message as InvestorAccountObject)) as InvestorAccountObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorAccountObject create() => InvestorAccountObject._();
  InvestorAccountObject createEmptyInstance() => create();
  static $pb.PbList<InvestorAccountObject> createRepeated() => $pb.PbList<InvestorAccountObject>();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorAccountObject>(create);
  static InvestorAccountObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get investorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set investorId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInvestorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInvestorId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get accountName => $_getSZ(2);
  @$pb.TagNumber(3)
  set accountName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAccountName() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccountName() => clearField(3);

  @$pb.TagNumber(5)
  $7.Money get availableBalance => $_getN(3);
  @$pb.TagNumber(5)
  set availableBalance($7.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAvailableBalance() => $_has(3);
  @$pb.TagNumber(5)
  void clearAvailableBalance() => clearField(5);
  @$pb.TagNumber(5)
  $7.Money ensureAvailableBalance() => $_ensure(3);

  @$pb.TagNumber(6)
  $7.Money get reservedBalance => $_getN(4);
  @$pb.TagNumber(6)
  set reservedBalance($7.Money v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasReservedBalance() => $_has(4);
  @$pb.TagNumber(6)
  void clearReservedBalance() => clearField(6);
  @$pb.TagNumber(6)
  $7.Money ensureReservedBalance() => $_ensure(4);

  @$pb.TagNumber(7)
  $7.Money get totalDeployed => $_getN(5);
  @$pb.TagNumber(7)
  set totalDeployed($7.Money v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasTotalDeployed() => $_has(5);
  @$pb.TagNumber(7)
  void clearTotalDeployed() => clearField(7);
  @$pb.TagNumber(7)
  $7.Money ensureTotalDeployed() => $_ensure(5);

  @$pb.TagNumber(8)
  $7.Money get totalReturned => $_getN(6);
  @$pb.TagNumber(8)
  set totalReturned($7.Money v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasTotalReturned() => $_has(6);
  @$pb.TagNumber(8)
  void clearTotalReturned() => clearField(8);
  @$pb.TagNumber(8)
  $7.Money ensureTotalReturned() => $_ensure(6);

  @$pb.TagNumber(9)
  $7.Money get maxExposure => $_getN(7);
  @$pb.TagNumber(9)
  set maxExposure($7.Money v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasMaxExposure() => $_has(7);
  @$pb.TagNumber(9)
  void clearMaxExposure() => clearField(9);
  @$pb.TagNumber(9)
  $7.Money ensureMaxExposure() => $_ensure(7);

  @$pb.TagNumber(10)
  $core.String get minInterestRate => $_getSZ(8);
  @$pb.TagNumber(10)
  set minInterestRate($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(10)
  $core.bool hasMinInterestRate() => $_has(8);
  @$pb.TagNumber(10)
  void clearMinInterestRate() => clearField(10);

  @$pb.TagNumber(11)
  $6.Struct get allowedProducts => $_getN(9);
  @$pb.TagNumber(11)
  set allowedProducts($6.Struct v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasAllowedProducts() => $_has(9);
  @$pb.TagNumber(11)
  void clearAllowedProducts() => clearField(11);
  @$pb.TagNumber(11)
  $6.Struct ensureAllowedProducts() => $_ensure(9);

  @$pb.TagNumber(12)
  $6.Struct get allowedRegions => $_getN(10);
  @$pb.TagNumber(12)
  set allowedRegions($6.Struct v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasAllowedRegions() => $_has(10);
  @$pb.TagNumber(12)
  void clearAllowedRegions() => clearField(12);
  @$pb.TagNumber(12)
  $6.Struct ensureAllowedRegions() => $_ensure(10);

  @$pb.TagNumber(13)
  $6.Struct get groupAffiliations => $_getN(11);
  @$pb.TagNumber(13)
  set groupAffiliations($6.Struct v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasGroupAffiliations() => $_has(11);
  @$pb.TagNumber(13)
  void clearGroupAffiliations() => clearField(13);
  @$pb.TagNumber(13)
  $6.Struct ensureGroupAffiliations() => $_ensure(11);

  @$pb.TagNumber(14)
  $8.STATE get state => $_getN(12);
  @$pb.TagNumber(14)
  set state($8.STATE v) { setField(14, v); }
  @$pb.TagNumber(14)
  $core.bool hasState() => $_has(12);
  @$pb.TagNumber(14)
  void clearState() => clearField(14);

  @$pb.TagNumber(15)
  $6.Struct get properties => $_getN(13);
  @$pb.TagNumber(15)
  set properties($6.Struct v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasProperties() => $_has(13);
  @$pb.TagNumber(15)
  void clearProperties() => clearField(15);
  @$pb.TagNumber(15)
  $6.Struct ensureProperties() => $_ensure(13);
}

/// FundingAllocationObject represents how a loan is funded across tranches.
class FundingAllocationObject extends $pb.GeneratedMessage {
  factory FundingAllocationObject({
    $core.String? id,
    $core.String? loanRequestId,
    $core.String? sourceId,
    $core.String? sourceType,
    $core.int? trancheLevel,
    $7.Money? amount,
    $core.String? proportion,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (loanRequestId != null) {
      $result.loanRequestId = loanRequestId;
    }
    if (sourceId != null) {
      $result.sourceId = sourceId;
    }
    if (sourceType != null) {
      $result.sourceType = sourceType;
    }
    if (trancheLevel != null) {
      $result.trancheLevel = trancheLevel;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (proportion != null) {
      $result.proportion = proportion;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  FundingAllocationObject._() : super();
  factory FundingAllocationObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FundingAllocationObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FundingAllocationObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'loanRequestId')
    ..aOS(3, _omitFieldNames ? '' : 'sourceId')
    ..aOS(4, _omitFieldNames ? '' : 'sourceType')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'trancheLevel', $pb.PbFieldType.O3)
    ..aOM<$7.Money>(6, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..aOS(8, _omitFieldNames ? '' : 'proportion')
    ..aOM<$6.Struct>(9, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FundingAllocationObject clone() => FundingAllocationObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FundingAllocationObject copyWith(void Function(FundingAllocationObject) updates) => super.copyWith((message) => updates(message as FundingAllocationObject)) as FundingAllocationObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FundingAllocationObject create() => FundingAllocationObject._();
  FundingAllocationObject createEmptyInstance() => create();
  static $pb.PbList<FundingAllocationObject> createRepeated() => $pb.PbList<FundingAllocationObject>();
  @$core.pragma('dart2js:noInline')
  static FundingAllocationObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FundingAllocationObject>(create);
  static FundingAllocationObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get loanRequestId => $_getSZ(1);
  @$pb.TagNumber(2)
  set loanRequestId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLoanRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoanRequestId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get sourceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSourceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get sourceType => $_getSZ(3);
  @$pb.TagNumber(4)
  set sourceType($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSourceType() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourceType() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get trancheLevel => $_getIZ(4);
  @$pb.TagNumber(5)
  set trancheLevel($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTrancheLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearTrancheLevel() => clearField(5);

  @$pb.TagNumber(6)
  $7.Money get amount => $_getN(5);
  @$pb.TagNumber(6)
  set amount($7.Money v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasAmount() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmount() => clearField(6);
  @$pb.TagNumber(6)
  $7.Money ensureAmount() => $_ensure(5);

  @$pb.TagNumber(8)
  $core.String get proportion => $_getSZ(6);
  @$pb.TagNumber(8)
  set proportion($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(8)
  $core.bool hasProportion() => $_has(6);
  @$pb.TagNumber(8)
  void clearProportion() => clearField(8);

  @$pb.TagNumber(9)
  $6.Struct get properties => $_getN(7);
  @$pb.TagNumber(9)
  set properties($6.Struct v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasProperties() => $_has(7);
  @$pb.TagNumber(9)
  void clearProperties() => clearField(9);
  @$pb.TagNumber(9)
  $6.Struct ensureProperties() => $_ensure(7);
}

class InvestorAccountSaveRequest extends $pb.GeneratedMessage {
  factory InvestorAccountSaveRequest({
    InvestorAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InvestorAccountSaveRequest._() : super();
  factory InvestorAccountSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorAccountSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InvestorAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorAccountSaveRequest clone() => InvestorAccountSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorAccountSaveRequest copyWith(void Function(InvestorAccountSaveRequest) updates) => super.copyWith((message) => updates(message as InvestorAccountSaveRequest)) as InvestorAccountSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorAccountSaveRequest create() => InvestorAccountSaveRequest._();
  InvestorAccountSaveRequest createEmptyInstance() => create();
  static $pb.PbList<InvestorAccountSaveRequest> createRepeated() => $pb.PbList<InvestorAccountSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorAccountSaveRequest>(create);
  static InvestorAccountSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InvestorAccountObject ensureData() => $_ensure(0);
}

class InvestorAccountSaveResponse extends $pb.GeneratedMessage {
  factory InvestorAccountSaveResponse({
    InvestorAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InvestorAccountSaveResponse._() : super();
  factory InvestorAccountSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorAccountSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InvestorAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorAccountSaveResponse clone() => InvestorAccountSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorAccountSaveResponse copyWith(void Function(InvestorAccountSaveResponse) updates) => super.copyWith((message) => updates(message as InvestorAccountSaveResponse)) as InvestorAccountSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorAccountSaveResponse create() => InvestorAccountSaveResponse._();
  InvestorAccountSaveResponse createEmptyInstance() => create();
  static $pb.PbList<InvestorAccountSaveResponse> createRepeated() => $pb.PbList<InvestorAccountSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorAccountSaveResponse>(create);
  static InvestorAccountSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InvestorAccountObject ensureData() => $_ensure(0);
}

class InvestorAccountGetRequest extends $pb.GeneratedMessage {
  factory InvestorAccountGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  InvestorAccountGetRequest._() : super();
  factory InvestorAccountGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorAccountGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorAccountGetRequest clone() => InvestorAccountGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorAccountGetRequest copyWith(void Function(InvestorAccountGetRequest) updates) => super.copyWith((message) => updates(message as InvestorAccountGetRequest)) as InvestorAccountGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorAccountGetRequest create() => InvestorAccountGetRequest._();
  InvestorAccountGetRequest createEmptyInstance() => create();
  static $pb.PbList<InvestorAccountGetRequest> createRepeated() => $pb.PbList<InvestorAccountGetRequest>();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorAccountGetRequest>(create);
  static InvestorAccountGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class InvestorAccountGetResponse extends $pb.GeneratedMessage {
  factory InvestorAccountGetResponse({
    InvestorAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InvestorAccountGetResponse._() : super();
  factory InvestorAccountGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorAccountGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InvestorAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorAccountGetResponse clone() => InvestorAccountGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorAccountGetResponse copyWith(void Function(InvestorAccountGetResponse) updates) => super.copyWith((message) => updates(message as InvestorAccountGetResponse)) as InvestorAccountGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorAccountGetResponse create() => InvestorAccountGetResponse._();
  InvestorAccountGetResponse createEmptyInstance() => create();
  static $pb.PbList<InvestorAccountGetResponse> createRepeated() => $pb.PbList<InvestorAccountGetResponse>();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorAccountGetResponse>(create);
  static InvestorAccountGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InvestorAccountObject ensureData() => $_ensure(0);
}

class InvestorAccountSearchRequest extends $pb.GeneratedMessage {
  factory InvestorAccountSearchRequest({
    $core.String? investorId,
    $core.String? currencyCode,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (investorId != null) {
      $result.investorId = investorId;
    }
    if (currencyCode != null) {
      $result.currencyCode = currencyCode;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  InvestorAccountSearchRequest._() : super();
  factory InvestorAccountSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorAccountSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'investorId')
    ..aOS(2, _omitFieldNames ? '' : 'currencyCode')
    ..aOM<$8.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorAccountSearchRequest clone() => InvestorAccountSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorAccountSearchRequest copyWith(void Function(InvestorAccountSearchRequest) updates) => super.copyWith((message) => updates(message as InvestorAccountSearchRequest)) as InvestorAccountSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorAccountSearchRequest create() => InvestorAccountSearchRequest._();
  InvestorAccountSearchRequest createEmptyInstance() => create();
  static $pb.PbList<InvestorAccountSearchRequest> createRepeated() => $pb.PbList<InvestorAccountSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorAccountSearchRequest>(create);
  static InvestorAccountSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get investorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set investorId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasInvestorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearInvestorId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get currencyCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set currencyCode($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCurrencyCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrencyCode() => clearField(2);

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

class InvestorAccountSearchResponse extends $pb.GeneratedMessage {
  factory InvestorAccountSearchResponse({
    $core.Iterable<InvestorAccountObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  InvestorAccountSearchResponse._() : super();
  factory InvestorAccountSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorAccountSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..pc<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: InvestorAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorAccountSearchResponse clone() => InvestorAccountSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorAccountSearchResponse copyWith(void Function(InvestorAccountSearchResponse) updates) => super.copyWith((message) => updates(message as InvestorAccountSearchResponse)) as InvestorAccountSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorAccountSearchResponse create() => InvestorAccountSearchResponse._();
  InvestorAccountSearchResponse createEmptyInstance() => create();
  static $pb.PbList<InvestorAccountSearchResponse> createRepeated() => $pb.PbList<InvestorAccountSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static InvestorAccountSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorAccountSearchResponse>(create);
  static InvestorAccountSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<InvestorAccountObject> get data => $_getList(0);
}

class InvestorDepositRequest extends $pb.GeneratedMessage {
  factory InvestorDepositRequest({
    $core.String? accountId,
    $7.Money? amount,
  }) {
    final $result = create();
    if (accountId != null) {
      $result.accountId = accountId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    return $result;
  }
  InvestorDepositRequest._() : super();
  factory InvestorDepositRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorDepositRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorDepositRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accountId')
    ..aOM<$7.Money>(2, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorDepositRequest clone() => InvestorDepositRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorDepositRequest copyWith(void Function(InvestorDepositRequest) updates) => super.copyWith((message) => updates(message as InvestorDepositRequest)) as InvestorDepositRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorDepositRequest create() => InvestorDepositRequest._();
  InvestorDepositRequest createEmptyInstance() => create();
  static $pb.PbList<InvestorDepositRequest> createRepeated() => $pb.PbList<InvestorDepositRequest>();
  @$core.pragma('dart2js:noInline')
  static InvestorDepositRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorDepositRequest>(create);
  static InvestorDepositRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set accountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountId() => clearField(1);

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
}

class InvestorDepositResponse extends $pb.GeneratedMessage {
  factory InvestorDepositResponse({
    InvestorAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InvestorDepositResponse._() : super();
  factory InvestorDepositResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorDepositResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorDepositResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InvestorAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorDepositResponse clone() => InvestorDepositResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorDepositResponse copyWith(void Function(InvestorDepositResponse) updates) => super.copyWith((message) => updates(message as InvestorDepositResponse)) as InvestorDepositResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorDepositResponse create() => InvestorDepositResponse._();
  InvestorDepositResponse createEmptyInstance() => create();
  static $pb.PbList<InvestorDepositResponse> createRepeated() => $pb.PbList<InvestorDepositResponse>();
  @$core.pragma('dart2js:noInline')
  static InvestorDepositResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorDepositResponse>(create);
  static InvestorDepositResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InvestorAccountObject ensureData() => $_ensure(0);
}

class InvestorWithdrawRequest extends $pb.GeneratedMessage {
  factory InvestorWithdrawRequest({
    $core.String? accountId,
    $7.Money? amount,
  }) {
    final $result = create();
    if (accountId != null) {
      $result.accountId = accountId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    return $result;
  }
  InvestorWithdrawRequest._() : super();
  factory InvestorWithdrawRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorWithdrawRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorWithdrawRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accountId')
    ..aOM<$7.Money>(2, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorWithdrawRequest clone() => InvestorWithdrawRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorWithdrawRequest copyWith(void Function(InvestorWithdrawRequest) updates) => super.copyWith((message) => updates(message as InvestorWithdrawRequest)) as InvestorWithdrawRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorWithdrawRequest create() => InvestorWithdrawRequest._();
  InvestorWithdrawRequest createEmptyInstance() => create();
  static $pb.PbList<InvestorWithdrawRequest> createRepeated() => $pb.PbList<InvestorWithdrawRequest>();
  @$core.pragma('dart2js:noInline')
  static InvestorWithdrawRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorWithdrawRequest>(create);
  static InvestorWithdrawRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set accountId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountId() => clearField(1);

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
}

class InvestorWithdrawResponse extends $pb.GeneratedMessage {
  factory InvestorWithdrawResponse({
    InvestorAccountObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InvestorWithdrawResponse._() : super();
  factory InvestorWithdrawResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorWithdrawResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorWithdrawResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InvestorAccountObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorWithdrawResponse clone() => InvestorWithdrawResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorWithdrawResponse copyWith(void Function(InvestorWithdrawResponse) updates) => super.copyWith((message) => updates(message as InvestorWithdrawResponse)) as InvestorWithdrawResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorWithdrawResponse create() => InvestorWithdrawResponse._();
  InvestorWithdrawResponse createEmptyInstance() => create();
  static $pb.PbList<InvestorWithdrawResponse> createRepeated() => $pb.PbList<InvestorWithdrawResponse>();
  @$core.pragma('dart2js:noInline')
  static InvestorWithdrawResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorWithdrawResponse>(create);
  static InvestorWithdrawResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorAccountObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorAccountObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InvestorAccountObject ensureData() => $_ensure(0);
}

class FundLoanRequest extends $pb.GeneratedMessage {
  factory FundLoanRequest({
    $core.String? loanRequestId,
  }) {
    final $result = create();
    if (loanRequestId != null) {
      $result.loanRequestId = loanRequestId;
    }
    return $result;
  }
  FundLoanRequest._() : super();
  factory FundLoanRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FundLoanRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FundLoanRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanRequestId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FundLoanRequest clone() => FundLoanRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FundLoanRequest copyWith(void Function(FundLoanRequest) updates) => super.copyWith((message) => updates(message as FundLoanRequest)) as FundLoanRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FundLoanRequest create() => FundLoanRequest._();
  FundLoanRequest createEmptyInstance() => create();
  static $pb.PbList<FundLoanRequest> createRepeated() => $pb.PbList<FundLoanRequest>();
  @$core.pragma('dart2js:noInline')
  static FundLoanRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FundLoanRequest>(create);
  static FundLoanRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanRequestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanRequestId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanRequestId() => clearField(1);
}

class FundLoanResponse extends $pb.GeneratedMessage {
  factory FundLoanResponse({
    $core.Iterable<FundingAllocationObject>? allocations,
    $7.Money? totalAllocated,
    $7.Money? deficit,
    $core.bool? fullyFunded,
  }) {
    final $result = create();
    if (allocations != null) {
      $result.allocations.addAll(allocations);
    }
    if (totalAllocated != null) {
      $result.totalAllocated = totalAllocated;
    }
    if (deficit != null) {
      $result.deficit = deficit;
    }
    if (fullyFunded != null) {
      $result.fullyFunded = fullyFunded;
    }
    return $result;
  }
  FundLoanResponse._() : super();
  factory FundLoanResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FundLoanResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FundLoanResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..pc<FundingAllocationObject>(1, _omitFieldNames ? '' : 'allocations', $pb.PbFieldType.PM, subBuilder: FundingAllocationObject.create)
    ..aOM<$7.Money>(2, _omitFieldNames ? '' : 'totalAllocated', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(3, _omitFieldNames ? '' : 'deficit', subBuilder: $7.Money.create)
    ..aOB(4, _omitFieldNames ? '' : 'fullyFunded')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FundLoanResponse clone() => FundLoanResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FundLoanResponse copyWith(void Function(FundLoanResponse) updates) => super.copyWith((message) => updates(message as FundLoanResponse)) as FundLoanResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FundLoanResponse create() => FundLoanResponse._();
  FundLoanResponse createEmptyInstance() => create();
  static $pb.PbList<FundLoanResponse> createRepeated() => $pb.PbList<FundLoanResponse>();
  @$core.pragma('dart2js:noInline')
  static FundLoanResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FundLoanResponse>(create);
  static FundLoanResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<FundingAllocationObject> get allocations => $_getList(0);

  @$pb.TagNumber(2)
  $7.Money get totalAllocated => $_getN(1);
  @$pb.TagNumber(2)
  set totalAllocated($7.Money v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTotalAllocated() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalAllocated() => clearField(2);
  @$pb.TagNumber(2)
  $7.Money ensureTotalAllocated() => $_ensure(1);

  @$pb.TagNumber(3)
  $7.Money get deficit => $_getN(2);
  @$pb.TagNumber(3)
  set deficit($7.Money v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeficit() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeficit() => clearField(3);
  @$pb.TagNumber(3)
  $7.Money ensureDeficit() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.bool get fullyFunded => $_getBF(3);
  @$pb.TagNumber(4)
  set fullyFunded($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFullyFunded() => $_has(3);
  @$pb.TagNumber(4)
  void clearFullyFunded() => clearField(4);
}

class AbsorbLossRequest extends $pb.GeneratedMessage {
  factory AbsorbLossRequest({
    $core.String? loanRequestId,
    $7.Money? amount,
  }) {
    final $result = create();
    if (loanRequestId != null) {
      $result.loanRequestId = loanRequestId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    return $result;
  }
  AbsorbLossRequest._() : super();
  factory AbsorbLossRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AbsorbLossRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AbsorbLossRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'loanRequestId')
    ..aOM<$7.Money>(2, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AbsorbLossRequest clone() => AbsorbLossRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AbsorbLossRequest copyWith(void Function(AbsorbLossRequest) updates) => super.copyWith((message) => updates(message as AbsorbLossRequest)) as AbsorbLossRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AbsorbLossRequest create() => AbsorbLossRequest._();
  AbsorbLossRequest createEmptyInstance() => create();
  static $pb.PbList<AbsorbLossRequest> createRepeated() => $pb.PbList<AbsorbLossRequest>();
  @$core.pragma('dart2js:noInline')
  static AbsorbLossRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AbsorbLossRequest>(create);
  static AbsorbLossRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get loanRequestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set loanRequestId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoanRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoanRequestId() => clearField(1);

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
}

class AbsorbLossResponse extends $pb.GeneratedMessage {
  factory AbsorbLossResponse({
    $7.Money? absorbed,
    $7.Money? unrecoverable,
  }) {
    final $result = create();
    if (absorbed != null) {
      $result.absorbed = absorbed;
    }
    if (unrecoverable != null) {
      $result.unrecoverable = unrecoverable;
    }
    return $result;
  }
  AbsorbLossResponse._() : super();
  factory AbsorbLossResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AbsorbLossResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AbsorbLossResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'funding.v1'), createEmptyInstance: create)
    ..aOM<$7.Money>(1, _omitFieldNames ? '' : 'absorbed', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(2, _omitFieldNames ? '' : 'unrecoverable', subBuilder: $7.Money.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AbsorbLossResponse clone() => AbsorbLossResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AbsorbLossResponse copyWith(void Function(AbsorbLossResponse) updates) => super.copyWith((message) => updates(message as AbsorbLossResponse)) as AbsorbLossResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AbsorbLossResponse create() => AbsorbLossResponse._();
  AbsorbLossResponse createEmptyInstance() => create();
  static $pb.PbList<AbsorbLossResponse> createRepeated() => $pb.PbList<AbsorbLossResponse>();
  @$core.pragma('dart2js:noInline')
  static AbsorbLossResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AbsorbLossResponse>(create);
  static AbsorbLossResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $7.Money get absorbed => $_getN(0);
  @$pb.TagNumber(1)
  set absorbed($7.Money v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasAbsorbed() => $_has(0);
  @$pb.TagNumber(1)
  void clearAbsorbed() => clearField(1);
  @$pb.TagNumber(1)
  $7.Money ensureAbsorbed() => $_ensure(0);

  @$pb.TagNumber(2)
  $7.Money get unrecoverable => $_getN(1);
  @$pb.TagNumber(2)
  set unrecoverable($7.Money v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasUnrecoverable() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnrecoverable() => clearField(2);
  @$pb.TagNumber(2)
  $7.Money ensureUnrecoverable() => $_ensure(1);
}

class FundingServiceApi {
  $pb.RpcClient _client;
  FundingServiceApi(this._client);

  $async.Future<InvestorAccountSaveResponse> investorAccountSave($pb.ClientContext? ctx, InvestorAccountSaveRequest request) =>
    _client.invoke<InvestorAccountSaveResponse>(ctx, 'FundingService', 'InvestorAccountSave', request, InvestorAccountSaveResponse())
  ;
  $async.Future<InvestorAccountGetResponse> investorAccountGet($pb.ClientContext? ctx, InvestorAccountGetRequest request) =>
    _client.invoke<InvestorAccountGetResponse>(ctx, 'FundingService', 'InvestorAccountGet', request, InvestorAccountGetResponse())
  ;
  $async.Future<InvestorAccountSearchResponse> investorAccountSearch($pb.ClientContext? ctx, InvestorAccountSearchRequest request) =>
    _client.invoke<InvestorAccountSearchResponse>(ctx, 'FundingService', 'InvestorAccountSearch', request, InvestorAccountSearchResponse())
  ;
  $async.Future<InvestorDepositResponse> investorDeposit($pb.ClientContext? ctx, InvestorDepositRequest request) =>
    _client.invoke<InvestorDepositResponse>(ctx, 'FundingService', 'InvestorDeposit', request, InvestorDepositResponse())
  ;
  $async.Future<InvestorWithdrawResponse> investorWithdraw($pb.ClientContext? ctx, InvestorWithdrawRequest request) =>
    _client.invoke<InvestorWithdrawResponse>(ctx, 'FundingService', 'InvestorWithdraw', request, InvestorWithdrawResponse())
  ;
  $async.Future<FundLoanResponse> fundLoan($pb.ClientContext? ctx, FundLoanRequest request) =>
    _client.invoke<FundLoanResponse>(ctx, 'FundingService', 'FundLoan', request, FundLoanResponse())
  ;
  $async.Future<AbsorbLossResponse> absorbLoss($pb.ClientContext? ctx, AbsorbLossRequest request) =>
    _client.invoke<AbsorbLossResponse>(ctx, 'FundingService', 'AbsorbLoss', request, AbsorbLossResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
