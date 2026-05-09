//
//  Generated code. Do not modify.
//  source: limits/v1/limits.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../common/v1/common.pb.dart' as $8;
import '../../common/v1/money.pb.dart' as $7;
import '../../google/protobuf/duration.pb.dart' as $0;
import '../../google/protobuf/struct.pb.dart' as $6;
import '../../google/protobuf/timestamp.pb.dart' as $2;
import 'limits.pbenum.dart';

export 'limits.pbenum.dart';

class SubjectRef extends $pb.GeneratedMessage {
  factory SubjectRef({
    SubjectType? type,
    $core.String? id,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  SubjectRef._() : super();
  factory SubjectRef.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubjectRef.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubjectRef', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..e<SubjectType>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: SubjectType.SUBJECT_TYPE_UNSPECIFIED, valueOf: SubjectType.valueOf, enumValues: SubjectType.values)
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubjectRef clone() => SubjectRef()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubjectRef copyWith(void Function(SubjectRef) updates) => super.copyWith((message) => updates(message as SubjectRef)) as SubjectRef;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubjectRef create() => SubjectRef._();
  SubjectRef createEmptyInstance() => create();
  static $pb.PbList<SubjectRef> createRepeated() => $pb.PbList<SubjectRef>();
  @$core.pragma('dart2js:noInline')
  static SubjectRef getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubjectRef>(create);
  static SubjectRef? _defaultInstance;

  @$pb.TagNumber(1)
  SubjectType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SubjectType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => clearField(2);
}

class ApproverTier extends $pb.GeneratedMessage {
  factory ApproverTier({
    $fixnum.Int64? upTo,
    $core.String? role,
    $core.int? approvers,
  }) {
    final $result = create();
    if (upTo != null) {
      $result.upTo = upTo;
    }
    if (role != null) {
      $result.role = role;
    }
    if (approvers != null) {
      $result.approvers = approvers;
    }
    return $result;
  }
  ApproverTier._() : super();
  factory ApproverTier.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ApproverTier.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApproverTier', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'upTo')
    ..aOS(2, _omitFieldNames ? '' : 'role')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'approvers', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ApproverTier clone() => ApproverTier()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ApproverTier copyWith(void Function(ApproverTier) updates) => super.copyWith((message) => updates(message as ApproverTier)) as ApproverTier;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApproverTier create() => ApproverTier._();
  ApproverTier createEmptyInstance() => create();
  static $pb.PbList<ApproverTier> createRepeated() => $pb.PbList<ApproverTier>();
  @$core.pragma('dart2js:noInline')
  static ApproverTier getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApproverTier>(create);
  static ApproverTier? _defaultInstance;

  /// Tier applies for amounts up to and including this value (in minor units).
  /// The final tier may set up_to = 0 to mean "and above".
  @$pb.TagNumber(1)
  $fixnum.Int64 get upTo => $_getI64(0);
  @$pb.TagNumber(1)
  set upTo($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUpTo() => $_has(0);
  @$pb.TagNumber(1)
  void clearUpTo() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get role => $_getSZ(1);
  @$pb.TagNumber(2)
  set role($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get approvers => $_getIZ(2);
  @$pb.TagNumber(3)
  set approvers($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasApprovers() => $_has(2);
  @$pb.TagNumber(3)
  void clearApprovers() => clearField(3);
}

class PolicyObject extends $pb.GeneratedMessage {
  factory PolicyObject({
    $core.String? id,
    $core.String? tenantId,
    PolicyScope? scope,
    $core.String? orgUnitId,
    LimitAction? action,
    SubjectType? subjectType,
    $core.String? currencyCode,
    LimitKind? limitKind,
    $0.Duration? window,
    $7.Money? capAmount,
    $fixnum.Int64? capCount,
    PolicyMode? mode,
    $6.Struct? attributeFilter,
    $core.Iterable<ApproverTier>? approverTiers,
    $0.Duration? approvalTtl,
    $2.Timestamp? effectiveFrom,
    $2.Timestamp? effectiveTo,
    $core.String? notes,
    $core.int? version,
    $2.Timestamp? createdAt,
    $2.Timestamp? modifiedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (tenantId != null) {
      $result.tenantId = tenantId;
    }
    if (scope != null) {
      $result.scope = scope;
    }
    if (orgUnitId != null) {
      $result.orgUnitId = orgUnitId;
    }
    if (action != null) {
      $result.action = action;
    }
    if (subjectType != null) {
      $result.subjectType = subjectType;
    }
    if (currencyCode != null) {
      $result.currencyCode = currencyCode;
    }
    if (limitKind != null) {
      $result.limitKind = limitKind;
    }
    if (window != null) {
      $result.window = window;
    }
    if (capAmount != null) {
      $result.capAmount = capAmount;
    }
    if (capCount != null) {
      $result.capCount = capCount;
    }
    if (mode != null) {
      $result.mode = mode;
    }
    if (attributeFilter != null) {
      $result.attributeFilter = attributeFilter;
    }
    if (approverTiers != null) {
      $result.approverTiers.addAll(approverTiers);
    }
    if (approvalTtl != null) {
      $result.approvalTtl = approvalTtl;
    }
    if (effectiveFrom != null) {
      $result.effectiveFrom = effectiveFrom;
    }
    if (effectiveTo != null) {
      $result.effectiveTo = effectiveTo;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (version != null) {
      $result.version = version;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (modifiedAt != null) {
      $result.modifiedAt = modifiedAt;
    }
    return $result;
  }
  PolicyObject._() : super();
  factory PolicyObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PolicyObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PolicyObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..e<PolicyScope>(3, _omitFieldNames ? '' : 'scope', $pb.PbFieldType.OE, defaultOrMaker: PolicyScope.POLICY_SCOPE_UNSPECIFIED, valueOf: PolicyScope.valueOf, enumValues: PolicyScope.values)
    ..aOS(4, _omitFieldNames ? '' : 'orgUnitId')
    ..e<LimitAction>(5, _omitFieldNames ? '' : 'action', $pb.PbFieldType.OE, defaultOrMaker: LimitAction.LIMIT_ACTION_UNSPECIFIED, valueOf: LimitAction.valueOf, enumValues: LimitAction.values)
    ..e<SubjectType>(6, _omitFieldNames ? '' : 'subjectType', $pb.PbFieldType.OE, defaultOrMaker: SubjectType.SUBJECT_TYPE_UNSPECIFIED, valueOf: SubjectType.valueOf, enumValues: SubjectType.values)
    ..aOS(7, _omitFieldNames ? '' : 'currencyCode')
    ..e<LimitKind>(8, _omitFieldNames ? '' : 'limitKind', $pb.PbFieldType.OE, defaultOrMaker: LimitKind.LIMIT_KIND_UNSPECIFIED, valueOf: LimitKind.valueOf, enumValues: LimitKind.values)
    ..aOM<$0.Duration>(9, _omitFieldNames ? '' : 'window', subBuilder: $0.Duration.create)
    ..aOM<$7.Money>(10, _omitFieldNames ? '' : 'capAmount', subBuilder: $7.Money.create)
    ..aInt64(11, _omitFieldNames ? '' : 'capCount')
    ..e<PolicyMode>(12, _omitFieldNames ? '' : 'mode', $pb.PbFieldType.OE, defaultOrMaker: PolicyMode.POLICY_MODE_UNSPECIFIED, valueOf: PolicyMode.valueOf, enumValues: PolicyMode.values)
    ..aOM<$6.Struct>(13, _omitFieldNames ? '' : 'attributeFilter', subBuilder: $6.Struct.create)
    ..pc<ApproverTier>(14, _omitFieldNames ? '' : 'approverTiers', $pb.PbFieldType.PM, subBuilder: ApproverTier.create)
    ..aOM<$0.Duration>(15, _omitFieldNames ? '' : 'approvalTtl', subBuilder: $0.Duration.create)
    ..aOM<$2.Timestamp>(16, _omitFieldNames ? '' : 'effectiveFrom', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(17, _omitFieldNames ? '' : 'effectiveTo', subBuilder: $2.Timestamp.create)
    ..aOS(18, _omitFieldNames ? '' : 'notes')
    ..a<$core.int>(19, _omitFieldNames ? '' : 'version', $pb.PbFieldType.O3)
    ..aOM<$2.Timestamp>(20, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(21, _omitFieldNames ? '' : 'modifiedAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PolicyObject clone() => PolicyObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PolicyObject copyWith(void Function(PolicyObject) updates) => super.copyWith((message) => updates(message as PolicyObject)) as PolicyObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolicyObject create() => PolicyObject._();
  PolicyObject createEmptyInstance() => create();
  static $pb.PbList<PolicyObject> createRepeated() => $pb.PbList<PolicyObject>();
  @$core.pragma('dart2js:noInline')
  static PolicyObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyObject>(create);
  static PolicyObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => clearField(2);

  @$pb.TagNumber(3)
  PolicyScope get scope => $_getN(2);
  @$pb.TagNumber(3)
  set scope(PolicyScope v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasScope() => $_has(2);
  @$pb.TagNumber(3)
  void clearScope() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get orgUnitId => $_getSZ(3);
  @$pb.TagNumber(4)
  set orgUnitId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOrgUnitId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrgUnitId() => clearField(4);

  @$pb.TagNumber(5)
  LimitAction get action => $_getN(4);
  @$pb.TagNumber(5)
  set action(LimitAction v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAction() => $_has(4);
  @$pb.TagNumber(5)
  void clearAction() => clearField(5);

  @$pb.TagNumber(6)
  SubjectType get subjectType => $_getN(5);
  @$pb.TagNumber(6)
  set subjectType(SubjectType v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasSubjectType() => $_has(5);
  @$pb.TagNumber(6)
  void clearSubjectType() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get currencyCode => $_getSZ(6);
  @$pb.TagNumber(7)
  set currencyCode($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCurrencyCode() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrencyCode() => clearField(7);

  @$pb.TagNumber(8)
  LimitKind get limitKind => $_getN(7);
  @$pb.TagNumber(8)
  set limitKind(LimitKind v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasLimitKind() => $_has(7);
  @$pb.TagNumber(8)
  void clearLimitKind() => clearField(8);

  @$pb.TagNumber(9)
  $0.Duration get window => $_getN(8);
  @$pb.TagNumber(9)
  set window($0.Duration v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasWindow() => $_has(8);
  @$pb.TagNumber(9)
  void clearWindow() => clearField(9);
  @$pb.TagNumber(9)
  $0.Duration ensureWindow() => $_ensure(8);

  @$pb.TagNumber(10)
  $7.Money get capAmount => $_getN(9);
  @$pb.TagNumber(10)
  set capAmount($7.Money v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasCapAmount() => $_has(9);
  @$pb.TagNumber(10)
  void clearCapAmount() => clearField(10);
  @$pb.TagNumber(10)
  $7.Money ensureCapAmount() => $_ensure(9);

  @$pb.TagNumber(11)
  $fixnum.Int64 get capCount => $_getI64(10);
  @$pb.TagNumber(11)
  set capCount($fixnum.Int64 v) { $_setInt64(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasCapCount() => $_has(10);
  @$pb.TagNumber(11)
  void clearCapCount() => clearField(11);

  @$pb.TagNumber(12)
  PolicyMode get mode => $_getN(11);
  @$pb.TagNumber(12)
  set mode(PolicyMode v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasMode() => $_has(11);
  @$pb.TagNumber(12)
  void clearMode() => clearField(12);

  @$pb.TagNumber(13)
  $6.Struct get attributeFilter => $_getN(12);
  @$pb.TagNumber(13)
  set attributeFilter($6.Struct v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasAttributeFilter() => $_has(12);
  @$pb.TagNumber(13)
  void clearAttributeFilter() => clearField(13);
  @$pb.TagNumber(13)
  $6.Struct ensureAttributeFilter() => $_ensure(12);

  @$pb.TagNumber(14)
  $core.List<ApproverTier> get approverTiers => $_getList(13);

  @$pb.TagNumber(15)
  $0.Duration get approvalTtl => $_getN(14);
  @$pb.TagNumber(15)
  set approvalTtl($0.Duration v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasApprovalTtl() => $_has(14);
  @$pb.TagNumber(15)
  void clearApprovalTtl() => clearField(15);
  @$pb.TagNumber(15)
  $0.Duration ensureApprovalTtl() => $_ensure(14);

  @$pb.TagNumber(16)
  $2.Timestamp get effectiveFrom => $_getN(15);
  @$pb.TagNumber(16)
  set effectiveFrom($2.Timestamp v) { setField(16, v); }
  @$pb.TagNumber(16)
  $core.bool hasEffectiveFrom() => $_has(15);
  @$pb.TagNumber(16)
  void clearEffectiveFrom() => clearField(16);
  @$pb.TagNumber(16)
  $2.Timestamp ensureEffectiveFrom() => $_ensure(15);

  @$pb.TagNumber(17)
  $2.Timestamp get effectiveTo => $_getN(16);
  @$pb.TagNumber(17)
  set effectiveTo($2.Timestamp v) { setField(17, v); }
  @$pb.TagNumber(17)
  $core.bool hasEffectiveTo() => $_has(16);
  @$pb.TagNumber(17)
  void clearEffectiveTo() => clearField(17);
  @$pb.TagNumber(17)
  $2.Timestamp ensureEffectiveTo() => $_ensure(16);

  @$pb.TagNumber(18)
  $core.String get notes => $_getSZ(17);
  @$pb.TagNumber(18)
  set notes($core.String v) { $_setString(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasNotes() => $_has(17);
  @$pb.TagNumber(18)
  void clearNotes() => clearField(18);

  @$pb.TagNumber(19)
  $core.int get version => $_getIZ(18);
  @$pb.TagNumber(19)
  set version($core.int v) { $_setSignedInt32(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasVersion() => $_has(18);
  @$pb.TagNumber(19)
  void clearVersion() => clearField(19);

  @$pb.TagNumber(20)
  $2.Timestamp get createdAt => $_getN(19);
  @$pb.TagNumber(20)
  set createdAt($2.Timestamp v) { setField(20, v); }
  @$pb.TagNumber(20)
  $core.bool hasCreatedAt() => $_has(19);
  @$pb.TagNumber(20)
  void clearCreatedAt() => clearField(20);
  @$pb.TagNumber(20)
  $2.Timestamp ensureCreatedAt() => $_ensure(19);

  @$pb.TagNumber(21)
  $2.Timestamp get modifiedAt => $_getN(20);
  @$pb.TagNumber(21)
  set modifiedAt($2.Timestamp v) { setField(21, v); }
  @$pb.TagNumber(21)
  $core.bool hasModifiedAt() => $_has(20);
  @$pb.TagNumber(21)
  void clearModifiedAt() => clearField(21);
  @$pb.TagNumber(21)
  $2.Timestamp ensureModifiedAt() => $_ensure(20);
}

class LimitIntent extends $pb.GeneratedMessage {
  factory LimitIntent({
    LimitAction? action,
    $core.String? tenantId,
    $core.String? orgUnitId,
    $7.Money? amount,
    $core.Iterable<SubjectRef>? subjects,
    $core.String? makerId,
  }) {
    final $result = create();
    if (action != null) {
      $result.action = action;
    }
    if (tenantId != null) {
      $result.tenantId = tenantId;
    }
    if (orgUnitId != null) {
      $result.orgUnitId = orgUnitId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (subjects != null) {
      $result.subjects.addAll(subjects);
    }
    if (makerId != null) {
      $result.makerId = makerId;
    }
    return $result;
  }
  LimitIntent._() : super();
  factory LimitIntent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LimitIntent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LimitIntent', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..e<LimitAction>(1, _omitFieldNames ? '' : 'action', $pb.PbFieldType.OE, defaultOrMaker: LimitAction.LIMIT_ACTION_UNSPECIFIED, valueOf: LimitAction.valueOf, enumValues: LimitAction.values)
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'orgUnitId')
    ..aOM<$7.Money>(4, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..pc<SubjectRef>(5, _omitFieldNames ? '' : 'subjects', $pb.PbFieldType.PM, subBuilder: SubjectRef.create)
    ..aOS(6, _omitFieldNames ? '' : 'makerId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LimitIntent clone() => LimitIntent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LimitIntent copyWith(void Function(LimitIntent) updates) => super.copyWith((message) => updates(message as LimitIntent)) as LimitIntent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LimitIntent create() => LimitIntent._();
  LimitIntent createEmptyInstance() => create();
  static $pb.PbList<LimitIntent> createRepeated() => $pb.PbList<LimitIntent>();
  @$core.pragma('dart2js:noInline')
  static LimitIntent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LimitIntent>(create);
  static LimitIntent? _defaultInstance;

  @$pb.TagNumber(1)
  LimitAction get action => $_getN(0);
  @$pb.TagNumber(1)
  set action(LimitAction v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasAction() => $_has(0);
  @$pb.TagNumber(1)
  void clearAction() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get orgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set orgUnitId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrgUnitId() => clearField(3);

  @$pb.TagNumber(4)
  $7.Money get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($7.Money v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => clearField(4);
  @$pb.TagNumber(4)
  $7.Money ensureAmount() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.List<SubjectRef> get subjects => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get makerId => $_getSZ(5);
  @$pb.TagNumber(6)
  set makerId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMakerId() => $_has(5);
  @$pb.TagNumber(6)
  void clearMakerId() => clearField(6);
}

class PolicyVerdict extends $pb.GeneratedMessage {
  factory PolicyVerdict({
    $core.String? policyId,
    $core.int? policyVersion,
    $core.bool? matched,
    $core.bool? breached,
    $core.bool? wouldRequireApproval,
    PolicyMode? mode,
    $core.String? reason,
    $7.Money? currentUsage,
    $7.Money? capAmount,
    $fixnum.Int64? currentCount,
    $fixnum.Int64? capCount,
  }) {
    final $result = create();
    if (policyId != null) {
      $result.policyId = policyId;
    }
    if (policyVersion != null) {
      $result.policyVersion = policyVersion;
    }
    if (matched != null) {
      $result.matched = matched;
    }
    if (breached != null) {
      $result.breached = breached;
    }
    if (wouldRequireApproval != null) {
      $result.wouldRequireApproval = wouldRequireApproval;
    }
    if (mode != null) {
      $result.mode = mode;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    if (currentUsage != null) {
      $result.currentUsage = currentUsage;
    }
    if (capAmount != null) {
      $result.capAmount = capAmount;
    }
    if (currentCount != null) {
      $result.currentCount = currentCount;
    }
    if (capCount != null) {
      $result.capCount = capCount;
    }
    return $result;
  }
  PolicyVerdict._() : super();
  factory PolicyVerdict.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PolicyVerdict.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PolicyVerdict', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'policyId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'policyVersion', $pb.PbFieldType.O3)
    ..aOB(3, _omitFieldNames ? '' : 'matched')
    ..aOB(4, _omitFieldNames ? '' : 'breached')
    ..aOB(5, _omitFieldNames ? '' : 'wouldRequireApproval')
    ..e<PolicyMode>(6, _omitFieldNames ? '' : 'mode', $pb.PbFieldType.OE, defaultOrMaker: PolicyMode.POLICY_MODE_UNSPECIFIED, valueOf: PolicyMode.valueOf, enumValues: PolicyMode.values)
    ..aOS(7, _omitFieldNames ? '' : 'reason')
    ..aOM<$7.Money>(8, _omitFieldNames ? '' : 'currentUsage', subBuilder: $7.Money.create)
    ..aOM<$7.Money>(9, _omitFieldNames ? '' : 'capAmount', subBuilder: $7.Money.create)
    ..aInt64(10, _omitFieldNames ? '' : 'currentCount')
    ..aInt64(11, _omitFieldNames ? '' : 'capCount')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PolicyVerdict clone() => PolicyVerdict()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PolicyVerdict copyWith(void Function(PolicyVerdict) updates) => super.copyWith((message) => updates(message as PolicyVerdict)) as PolicyVerdict;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolicyVerdict create() => PolicyVerdict._();
  PolicyVerdict createEmptyInstance() => create();
  static $pb.PbList<PolicyVerdict> createRepeated() => $pb.PbList<PolicyVerdict>();
  @$core.pragma('dart2js:noInline')
  static PolicyVerdict getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyVerdict>(create);
  static PolicyVerdict? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get policyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set policyId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPolicyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPolicyId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get policyVersion => $_getIZ(1);
  @$pb.TagNumber(2)
  set policyVersion($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPolicyVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearPolicyVersion() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get matched => $_getBF(2);
  @$pb.TagNumber(3)
  set matched($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMatched() => $_has(2);
  @$pb.TagNumber(3)
  void clearMatched() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get breached => $_getBF(3);
  @$pb.TagNumber(4)
  set breached($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBreached() => $_has(3);
  @$pb.TagNumber(4)
  void clearBreached() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get wouldRequireApproval => $_getBF(4);
  @$pb.TagNumber(5)
  set wouldRequireApproval($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasWouldRequireApproval() => $_has(4);
  @$pb.TagNumber(5)
  void clearWouldRequireApproval() => clearField(5);

  @$pb.TagNumber(6)
  PolicyMode get mode => $_getN(5);
  @$pb.TagNumber(6)
  set mode(PolicyMode v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasMode() => $_has(5);
  @$pb.TagNumber(6)
  void clearMode() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get reason => $_getSZ(6);
  @$pb.TagNumber(7)
  set reason($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasReason() => $_has(6);
  @$pb.TagNumber(7)
  void clearReason() => clearField(7);

  @$pb.TagNumber(8)
  $7.Money get currentUsage => $_getN(7);
  @$pb.TagNumber(8)
  set currentUsage($7.Money v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasCurrentUsage() => $_has(7);
  @$pb.TagNumber(8)
  void clearCurrentUsage() => clearField(8);
  @$pb.TagNumber(8)
  $7.Money ensureCurrentUsage() => $_ensure(7);

  @$pb.TagNumber(9)
  $7.Money get capAmount => $_getN(8);
  @$pb.TagNumber(9)
  set capAmount($7.Money v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasCapAmount() => $_has(8);
  @$pb.TagNumber(9)
  void clearCapAmount() => clearField(9);
  @$pb.TagNumber(9)
  $7.Money ensureCapAmount() => $_ensure(8);

  @$pb.TagNumber(10)
  $fixnum.Int64 get currentCount => $_getI64(9);
  @$pb.TagNumber(10)
  set currentCount($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasCurrentCount() => $_has(9);
  @$pb.TagNumber(10)
  void clearCurrentCount() => clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get capCount => $_getI64(10);
  @$pb.TagNumber(11)
  set capCount($fixnum.Int64 v) { $_setInt64(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasCapCount() => $_has(10);
  @$pb.TagNumber(11)
  void clearCapCount() => clearField(11);
}

class PolicySaveRequest extends $pb.GeneratedMessage {
  factory PolicySaveRequest({
    PolicyObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PolicySaveRequest._() : super();
  factory PolicySaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PolicySaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PolicySaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOM<PolicyObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PolicyObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PolicySaveRequest clone() => PolicySaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PolicySaveRequest copyWith(void Function(PolicySaveRequest) updates) => super.copyWith((message) => updates(message as PolicySaveRequest)) as PolicySaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolicySaveRequest create() => PolicySaveRequest._();
  PolicySaveRequest createEmptyInstance() => create();
  static $pb.PbList<PolicySaveRequest> createRepeated() => $pb.PbList<PolicySaveRequest>();
  @$core.pragma('dart2js:noInline')
  static PolicySaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicySaveRequest>(create);
  static PolicySaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PolicyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PolicyObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  PolicyObject ensureData() => $_ensure(0);
}

class PolicySaveResponse extends $pb.GeneratedMessage {
  factory PolicySaveResponse({
    PolicyObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PolicySaveResponse._() : super();
  factory PolicySaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PolicySaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PolicySaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOM<PolicyObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PolicyObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PolicySaveResponse clone() => PolicySaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PolicySaveResponse copyWith(void Function(PolicySaveResponse) updates) => super.copyWith((message) => updates(message as PolicySaveResponse)) as PolicySaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolicySaveResponse create() => PolicySaveResponse._();
  PolicySaveResponse createEmptyInstance() => create();
  static $pb.PbList<PolicySaveResponse> createRepeated() => $pb.PbList<PolicySaveResponse>();
  @$core.pragma('dart2js:noInline')
  static PolicySaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicySaveResponse>(create);
  static PolicySaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PolicyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PolicyObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  PolicyObject ensureData() => $_ensure(0);
}

class PolicyGetRequest extends $pb.GeneratedMessage {
  factory PolicyGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  PolicyGetRequest._() : super();
  factory PolicyGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PolicyGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PolicyGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PolicyGetRequest clone() => PolicyGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PolicyGetRequest copyWith(void Function(PolicyGetRequest) updates) => super.copyWith((message) => updates(message as PolicyGetRequest)) as PolicyGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolicyGetRequest create() => PolicyGetRequest._();
  PolicyGetRequest createEmptyInstance() => create();
  static $pb.PbList<PolicyGetRequest> createRepeated() => $pb.PbList<PolicyGetRequest>();
  @$core.pragma('dart2js:noInline')
  static PolicyGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyGetRequest>(create);
  static PolicyGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class PolicyGetResponse extends $pb.GeneratedMessage {
  factory PolicyGetResponse({
    PolicyObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PolicyGetResponse._() : super();
  factory PolicyGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PolicyGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PolicyGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOM<PolicyObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PolicyObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PolicyGetResponse clone() => PolicyGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PolicyGetResponse copyWith(void Function(PolicyGetResponse) updates) => super.copyWith((message) => updates(message as PolicyGetResponse)) as PolicyGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolicyGetResponse create() => PolicyGetResponse._();
  PolicyGetResponse createEmptyInstance() => create();
  static $pb.PbList<PolicyGetResponse> createRepeated() => $pb.PbList<PolicyGetResponse>();
  @$core.pragma('dart2js:noInline')
  static PolicyGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyGetResponse>(create);
  static PolicyGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PolicyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PolicyObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  PolicyObject ensureData() => $_ensure(0);
}

class PolicySearchRequest extends $pb.GeneratedMessage {
  factory PolicySearchRequest({
    $core.String? query,
    $core.String? tenantId,
    $core.String? orgUnitId,
    LimitAction? action,
    SubjectType? subjectType,
    PolicyMode? mode,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (tenantId != null) {
      $result.tenantId = tenantId;
    }
    if (orgUnitId != null) {
      $result.orgUnitId = orgUnitId;
    }
    if (action != null) {
      $result.action = action;
    }
    if (subjectType != null) {
      $result.subjectType = subjectType;
    }
    if (mode != null) {
      $result.mode = mode;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  PolicySearchRequest._() : super();
  factory PolicySearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PolicySearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PolicySearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'orgUnitId')
    ..e<LimitAction>(4, _omitFieldNames ? '' : 'action', $pb.PbFieldType.OE, defaultOrMaker: LimitAction.LIMIT_ACTION_UNSPECIFIED, valueOf: LimitAction.valueOf, enumValues: LimitAction.values)
    ..e<SubjectType>(5, _omitFieldNames ? '' : 'subjectType', $pb.PbFieldType.OE, defaultOrMaker: SubjectType.SUBJECT_TYPE_UNSPECIFIED, valueOf: SubjectType.valueOf, enumValues: SubjectType.values)
    ..e<PolicyMode>(6, _omitFieldNames ? '' : 'mode', $pb.PbFieldType.OE, defaultOrMaker: PolicyMode.POLICY_MODE_UNSPECIFIED, valueOf: PolicyMode.valueOf, enumValues: PolicyMode.values)
    ..aOM<$8.PageCursor>(7, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PolicySearchRequest clone() => PolicySearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PolicySearchRequest copyWith(void Function(PolicySearchRequest) updates) => super.copyWith((message) => updates(message as PolicySearchRequest)) as PolicySearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolicySearchRequest create() => PolicySearchRequest._();
  PolicySearchRequest createEmptyInstance() => create();
  static $pb.PbList<PolicySearchRequest> createRepeated() => $pb.PbList<PolicySearchRequest>();
  @$core.pragma('dart2js:noInline')
  static PolicySearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicySearchRequest>(create);
  static PolicySearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get orgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set orgUnitId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrgUnitId() => clearField(3);

  @$pb.TagNumber(4)
  LimitAction get action => $_getN(3);
  @$pb.TagNumber(4)
  set action(LimitAction v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasAction() => $_has(3);
  @$pb.TagNumber(4)
  void clearAction() => clearField(4);

  @$pb.TagNumber(5)
  SubjectType get subjectType => $_getN(4);
  @$pb.TagNumber(5)
  set subjectType(SubjectType v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasSubjectType() => $_has(4);
  @$pb.TagNumber(5)
  void clearSubjectType() => clearField(5);

  @$pb.TagNumber(6)
  PolicyMode get mode => $_getN(5);
  @$pb.TagNumber(6)
  set mode(PolicyMode v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasMode() => $_has(5);
  @$pb.TagNumber(6)
  void clearMode() => clearField(6);

  @$pb.TagNumber(7)
  $8.PageCursor get cursor => $_getN(6);
  @$pb.TagNumber(7)
  set cursor($8.PageCursor v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasCursor() => $_has(6);
  @$pb.TagNumber(7)
  void clearCursor() => clearField(7);
  @$pb.TagNumber(7)
  $8.PageCursor ensureCursor() => $_ensure(6);
}

class PolicySearchResponse extends $pb.GeneratedMessage {
  factory PolicySearchResponse({
    $core.Iterable<PolicyObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  PolicySearchResponse._() : super();
  factory PolicySearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PolicySearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PolicySearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..pc<PolicyObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: PolicyObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PolicySearchResponse clone() => PolicySearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PolicySearchResponse copyWith(void Function(PolicySearchResponse) updates) => super.copyWith((message) => updates(message as PolicySearchResponse)) as PolicySearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolicySearchResponse create() => PolicySearchResponse._();
  PolicySearchResponse createEmptyInstance() => create();
  static $pb.PbList<PolicySearchResponse> createRepeated() => $pb.PbList<PolicySearchResponse>();
  @$core.pragma('dart2js:noInline')
  static PolicySearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicySearchResponse>(create);
  static PolicySearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PolicyObject> get data => $_getList(0);
}

class PolicyDeleteRequest extends $pb.GeneratedMessage {
  factory PolicyDeleteRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  PolicyDeleteRequest._() : super();
  factory PolicyDeleteRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PolicyDeleteRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PolicyDeleteRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PolicyDeleteRequest clone() => PolicyDeleteRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PolicyDeleteRequest copyWith(void Function(PolicyDeleteRequest) updates) => super.copyWith((message) => updates(message as PolicyDeleteRequest)) as PolicyDeleteRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolicyDeleteRequest create() => PolicyDeleteRequest._();
  PolicyDeleteRequest createEmptyInstance() => create();
  static $pb.PbList<PolicyDeleteRequest> createRepeated() => $pb.PbList<PolicyDeleteRequest>();
  @$core.pragma('dart2js:noInline')
  static PolicyDeleteRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyDeleteRequest>(create);
  static PolicyDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class PolicyDeleteResponse extends $pb.GeneratedMessage {
  factory PolicyDeleteResponse() => create();
  PolicyDeleteResponse._() : super();
  factory PolicyDeleteResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PolicyDeleteResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PolicyDeleteResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PolicyDeleteResponse clone() => PolicyDeleteResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PolicyDeleteResponse copyWith(void Function(PolicyDeleteResponse) updates) => super.copyWith((message) => updates(message as PolicyDeleteResponse)) as PolicyDeleteResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolicyDeleteResponse create() => PolicyDeleteResponse._();
  PolicyDeleteResponse createEmptyInstance() => create();
  static $pb.PbList<PolicyDeleteResponse> createRepeated() => $pb.PbList<PolicyDeleteResponse>();
  @$core.pragma('dart2js:noInline')
  static PolicyDeleteResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyDeleteResponse>(create);
  static PolicyDeleteResponse? _defaultInstance;
}

class ApprovalDecisionObject extends $pb.GeneratedMessage {
  factory ApprovalDecisionObject({
    $core.String? approverId,
    $core.String? decision,
    $core.String? note,
    $2.Timestamp? decidedAt,
  }) {
    final $result = create();
    if (approverId != null) {
      $result.approverId = approverId;
    }
    if (decision != null) {
      $result.decision = decision;
    }
    if (note != null) {
      $result.note = note;
    }
    if (decidedAt != null) {
      $result.decidedAt = decidedAt;
    }
    return $result;
  }
  ApprovalDecisionObject._() : super();
  factory ApprovalDecisionObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ApprovalDecisionObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApprovalDecisionObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'approverId')
    ..aOS(2, _omitFieldNames ? '' : 'decision')
    ..aOS(3, _omitFieldNames ? '' : 'note')
    ..aOM<$2.Timestamp>(4, _omitFieldNames ? '' : 'decidedAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ApprovalDecisionObject clone() => ApprovalDecisionObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ApprovalDecisionObject copyWith(void Function(ApprovalDecisionObject) updates) => super.copyWith((message) => updates(message as ApprovalDecisionObject)) as ApprovalDecisionObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApprovalDecisionObject create() => ApprovalDecisionObject._();
  ApprovalDecisionObject createEmptyInstance() => create();
  static $pb.PbList<ApprovalDecisionObject> createRepeated() => $pb.PbList<ApprovalDecisionObject>();
  @$core.pragma('dart2js:noInline')
  static ApprovalDecisionObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApprovalDecisionObject>(create);
  static ApprovalDecisionObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get approverId => $_getSZ(0);
  @$pb.TagNumber(1)
  set approverId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasApproverId() => $_has(0);
  @$pb.TagNumber(1)
  void clearApproverId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get decision => $_getSZ(1);
  @$pb.TagNumber(2)
  set decision($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDecision() => $_has(1);
  @$pb.TagNumber(2)
  void clearDecision() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get note => $_getSZ(2);
  @$pb.TagNumber(3)
  set note($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNote() => $_has(2);
  @$pb.TagNumber(3)
  void clearNote() => clearField(3);

  @$pb.TagNumber(4)
  $2.Timestamp get decidedAt => $_getN(3);
  @$pb.TagNumber(4)
  set decidedAt($2.Timestamp v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasDecidedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearDecidedAt() => clearField(4);
  @$pb.TagNumber(4)
  $2.Timestamp ensureDecidedAt() => $_ensure(3);
}

class ApprovalRequestObject extends $pb.GeneratedMessage {
  factory ApprovalRequestObject({
    $core.String? id,
    $core.String? reservationId,
    $core.String? tenantId,
    $core.String? orgUnitId,
    $core.String? triggeringPolicyId,
    $core.int? policyVersion,
    LimitAction? action,
    $7.Money? amount,
    $core.String? requiredRole,
    $core.int? requiredCount,
    $core.String? makerId,
    ApprovalStatus? status,
    $2.Timestamp? submittedAt,
    $2.Timestamp? expiresAt,
    $2.Timestamp? decidedAt,
    $core.Iterable<ApprovalDecisionObject>? decisions,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (reservationId != null) {
      $result.reservationId = reservationId;
    }
    if (tenantId != null) {
      $result.tenantId = tenantId;
    }
    if (orgUnitId != null) {
      $result.orgUnitId = orgUnitId;
    }
    if (triggeringPolicyId != null) {
      $result.triggeringPolicyId = triggeringPolicyId;
    }
    if (policyVersion != null) {
      $result.policyVersion = policyVersion;
    }
    if (action != null) {
      $result.action = action;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (requiredRole != null) {
      $result.requiredRole = requiredRole;
    }
    if (requiredCount != null) {
      $result.requiredCount = requiredCount;
    }
    if (makerId != null) {
      $result.makerId = makerId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (submittedAt != null) {
      $result.submittedAt = submittedAt;
    }
    if (expiresAt != null) {
      $result.expiresAt = expiresAt;
    }
    if (decidedAt != null) {
      $result.decidedAt = decidedAt;
    }
    if (decisions != null) {
      $result.decisions.addAll(decisions);
    }
    return $result;
  }
  ApprovalRequestObject._() : super();
  factory ApprovalRequestObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ApprovalRequestObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApprovalRequestObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reservationId')
    ..aOS(3, _omitFieldNames ? '' : 'tenantId')
    ..aOS(4, _omitFieldNames ? '' : 'orgUnitId')
    ..aOS(5, _omitFieldNames ? '' : 'triggeringPolicyId')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'policyVersion', $pb.PbFieldType.O3)
    ..e<LimitAction>(7, _omitFieldNames ? '' : 'action', $pb.PbFieldType.OE, defaultOrMaker: LimitAction.LIMIT_ACTION_UNSPECIFIED, valueOf: LimitAction.valueOf, enumValues: LimitAction.values)
    ..aOM<$7.Money>(8, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..aOS(9, _omitFieldNames ? '' : 'requiredRole')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'requiredCount', $pb.PbFieldType.O3)
    ..aOS(11, _omitFieldNames ? '' : 'makerId')
    ..e<ApprovalStatus>(12, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ApprovalStatus.APPROVAL_STATUS_UNSPECIFIED, valueOf: ApprovalStatus.valueOf, enumValues: ApprovalStatus.values)
    ..aOM<$2.Timestamp>(13, _omitFieldNames ? '' : 'submittedAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(14, _omitFieldNames ? '' : 'expiresAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(15, _omitFieldNames ? '' : 'decidedAt', subBuilder: $2.Timestamp.create)
    ..pc<ApprovalDecisionObject>(16, _omitFieldNames ? '' : 'decisions', $pb.PbFieldType.PM, subBuilder: ApprovalDecisionObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ApprovalRequestObject clone() => ApprovalRequestObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ApprovalRequestObject copyWith(void Function(ApprovalRequestObject) updates) => super.copyWith((message) => updates(message as ApprovalRequestObject)) as ApprovalRequestObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApprovalRequestObject create() => ApprovalRequestObject._();
  ApprovalRequestObject createEmptyInstance() => create();
  static $pb.PbList<ApprovalRequestObject> createRepeated() => $pb.PbList<ApprovalRequestObject>();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApprovalRequestObject>(create);
  static ApprovalRequestObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reservationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set reservationId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReservationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReservationId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get tenantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set tenantId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get orgUnitId => $_getSZ(3);
  @$pb.TagNumber(4)
  set orgUnitId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOrgUnitId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrgUnitId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get triggeringPolicyId => $_getSZ(4);
  @$pb.TagNumber(5)
  set triggeringPolicyId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTriggeringPolicyId() => $_has(4);
  @$pb.TagNumber(5)
  void clearTriggeringPolicyId() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get policyVersion => $_getIZ(5);
  @$pb.TagNumber(6)
  set policyVersion($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasPolicyVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearPolicyVersion() => clearField(6);

  @$pb.TagNumber(7)
  LimitAction get action => $_getN(6);
  @$pb.TagNumber(7)
  set action(LimitAction v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasAction() => $_has(6);
  @$pb.TagNumber(7)
  void clearAction() => clearField(7);

  @$pb.TagNumber(8)
  $7.Money get amount => $_getN(7);
  @$pb.TagNumber(8)
  set amount($7.Money v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasAmount() => $_has(7);
  @$pb.TagNumber(8)
  void clearAmount() => clearField(8);
  @$pb.TagNumber(8)
  $7.Money ensureAmount() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.String get requiredRole => $_getSZ(8);
  @$pb.TagNumber(9)
  set requiredRole($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasRequiredRole() => $_has(8);
  @$pb.TagNumber(9)
  void clearRequiredRole() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get requiredCount => $_getIZ(9);
  @$pb.TagNumber(10)
  set requiredCount($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasRequiredCount() => $_has(9);
  @$pb.TagNumber(10)
  void clearRequiredCount() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get makerId => $_getSZ(10);
  @$pb.TagNumber(11)
  set makerId($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasMakerId() => $_has(10);
  @$pb.TagNumber(11)
  void clearMakerId() => clearField(11);

  @$pb.TagNumber(12)
  ApprovalStatus get status => $_getN(11);
  @$pb.TagNumber(12)
  set status(ApprovalStatus v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => clearField(12);

  @$pb.TagNumber(13)
  $2.Timestamp get submittedAt => $_getN(12);
  @$pb.TagNumber(13)
  set submittedAt($2.Timestamp v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasSubmittedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearSubmittedAt() => clearField(13);
  @$pb.TagNumber(13)
  $2.Timestamp ensureSubmittedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $2.Timestamp get expiresAt => $_getN(13);
  @$pb.TagNumber(14)
  set expiresAt($2.Timestamp v) { setField(14, v); }
  @$pb.TagNumber(14)
  $core.bool hasExpiresAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearExpiresAt() => clearField(14);
  @$pb.TagNumber(14)
  $2.Timestamp ensureExpiresAt() => $_ensure(13);

  @$pb.TagNumber(15)
  $2.Timestamp get decidedAt => $_getN(14);
  @$pb.TagNumber(15)
  set decidedAt($2.Timestamp v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasDecidedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearDecidedAt() => clearField(15);
  @$pb.TagNumber(15)
  $2.Timestamp ensureDecidedAt() => $_ensure(14);

  @$pb.TagNumber(16)
  $core.List<ApprovalDecisionObject> get decisions => $_getList(15);
}

class ApprovalRequestListRequest extends $pb.GeneratedMessage {
  factory ApprovalRequestListRequest({
    $core.String? tenantId,
    ApprovalStatus? status,
    $core.String? requiredRole,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (tenantId != null) {
      $result.tenantId = tenantId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (requiredRole != null) {
      $result.requiredRole = requiredRole;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  ApprovalRequestListRequest._() : super();
  factory ApprovalRequestListRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ApprovalRequestListRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApprovalRequestListRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..e<ApprovalStatus>(2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ApprovalStatus.APPROVAL_STATUS_UNSPECIFIED, valueOf: ApprovalStatus.valueOf, enumValues: ApprovalStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'requiredRole')
    ..aOM<$8.PageCursor>(4, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ApprovalRequestListRequest clone() => ApprovalRequestListRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ApprovalRequestListRequest copyWith(void Function(ApprovalRequestListRequest) updates) => super.copyWith((message) => updates(message as ApprovalRequestListRequest)) as ApprovalRequestListRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApprovalRequestListRequest create() => ApprovalRequestListRequest._();
  ApprovalRequestListRequest createEmptyInstance() => create();
  static $pb.PbList<ApprovalRequestListRequest> createRepeated() => $pb.PbList<ApprovalRequestListRequest>();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestListRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApprovalRequestListRequest>(create);
  static ApprovalRequestListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => clearField(1);

  @$pb.TagNumber(2)
  ApprovalStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(ApprovalStatus v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get requiredRole => $_getSZ(2);
  @$pb.TagNumber(3)
  set requiredRole($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRequiredRole() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequiredRole() => clearField(3);

  @$pb.TagNumber(4)
  $8.PageCursor get cursor => $_getN(3);
  @$pb.TagNumber(4)
  set cursor($8.PageCursor v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursor() => clearField(4);
  @$pb.TagNumber(4)
  $8.PageCursor ensureCursor() => $_ensure(3);
}

class ApprovalRequestListResponse extends $pb.GeneratedMessage {
  factory ApprovalRequestListResponse({
    $core.Iterable<ApprovalRequestObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  ApprovalRequestListResponse._() : super();
  factory ApprovalRequestListResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ApprovalRequestListResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApprovalRequestListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..pc<ApprovalRequestObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: ApprovalRequestObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ApprovalRequestListResponse clone() => ApprovalRequestListResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ApprovalRequestListResponse copyWith(void Function(ApprovalRequestListResponse) updates) => super.copyWith((message) => updates(message as ApprovalRequestListResponse)) as ApprovalRequestListResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApprovalRequestListResponse create() => ApprovalRequestListResponse._();
  ApprovalRequestListResponse createEmptyInstance() => create();
  static $pb.PbList<ApprovalRequestListResponse> createRepeated() => $pb.PbList<ApprovalRequestListResponse>();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApprovalRequestListResponse>(create);
  static ApprovalRequestListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ApprovalRequestObject> get data => $_getList(0);
}

class ApprovalRequestGetRequest extends $pb.GeneratedMessage {
  factory ApprovalRequestGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  ApprovalRequestGetRequest._() : super();
  factory ApprovalRequestGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ApprovalRequestGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApprovalRequestGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ApprovalRequestGetRequest clone() => ApprovalRequestGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ApprovalRequestGetRequest copyWith(void Function(ApprovalRequestGetRequest) updates) => super.copyWith((message) => updates(message as ApprovalRequestGetRequest)) as ApprovalRequestGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApprovalRequestGetRequest create() => ApprovalRequestGetRequest._();
  ApprovalRequestGetRequest createEmptyInstance() => create();
  static $pb.PbList<ApprovalRequestGetRequest> createRepeated() => $pb.PbList<ApprovalRequestGetRequest>();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApprovalRequestGetRequest>(create);
  static ApprovalRequestGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class ApprovalRequestGetResponse extends $pb.GeneratedMessage {
  factory ApprovalRequestGetResponse({
    ApprovalRequestObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ApprovalRequestGetResponse._() : super();
  factory ApprovalRequestGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ApprovalRequestGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApprovalRequestGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOM<ApprovalRequestObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ApprovalRequestObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ApprovalRequestGetResponse clone() => ApprovalRequestGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ApprovalRequestGetResponse copyWith(void Function(ApprovalRequestGetResponse) updates) => super.copyWith((message) => updates(message as ApprovalRequestGetResponse)) as ApprovalRequestGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApprovalRequestGetResponse create() => ApprovalRequestGetResponse._();
  ApprovalRequestGetResponse createEmptyInstance() => create();
  static $pb.PbList<ApprovalRequestGetResponse> createRepeated() => $pb.PbList<ApprovalRequestGetResponse>();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApprovalRequestGetResponse>(create);
  static ApprovalRequestGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ApprovalRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ApprovalRequestObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ApprovalRequestObject ensureData() => $_ensure(0);
}

class ApprovalRequestDecideRequest extends $pb.GeneratedMessage {
  factory ApprovalRequestDecideRequest({
    $core.String? id,
    $core.String? decision,
    $core.String? note,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (decision != null) {
      $result.decision = decision;
    }
    if (note != null) {
      $result.note = note;
    }
    return $result;
  }
  ApprovalRequestDecideRequest._() : super();
  factory ApprovalRequestDecideRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ApprovalRequestDecideRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApprovalRequestDecideRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'decision')
    ..aOS(3, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ApprovalRequestDecideRequest clone() => ApprovalRequestDecideRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ApprovalRequestDecideRequest copyWith(void Function(ApprovalRequestDecideRequest) updates) => super.copyWith((message) => updates(message as ApprovalRequestDecideRequest)) as ApprovalRequestDecideRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApprovalRequestDecideRequest create() => ApprovalRequestDecideRequest._();
  ApprovalRequestDecideRequest createEmptyInstance() => create();
  static $pb.PbList<ApprovalRequestDecideRequest> createRepeated() => $pb.PbList<ApprovalRequestDecideRequest>();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestDecideRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApprovalRequestDecideRequest>(create);
  static ApprovalRequestDecideRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get decision => $_getSZ(1);
  @$pb.TagNumber(2)
  set decision($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDecision() => $_has(1);
  @$pb.TagNumber(2)
  void clearDecision() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get note => $_getSZ(2);
  @$pb.TagNumber(3)
  set note($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNote() => $_has(2);
  @$pb.TagNumber(3)
  void clearNote() => clearField(3);
}

class ApprovalRequestDecideResponse extends $pb.GeneratedMessage {
  factory ApprovalRequestDecideResponse({
    ApprovalRequestObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ApprovalRequestDecideResponse._() : super();
  factory ApprovalRequestDecideResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ApprovalRequestDecideResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApprovalRequestDecideResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOM<ApprovalRequestObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ApprovalRequestObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ApprovalRequestDecideResponse clone() => ApprovalRequestDecideResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ApprovalRequestDecideResponse copyWith(void Function(ApprovalRequestDecideResponse) updates) => super.copyWith((message) => updates(message as ApprovalRequestDecideResponse)) as ApprovalRequestDecideResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApprovalRequestDecideResponse create() => ApprovalRequestDecideResponse._();
  ApprovalRequestDecideResponse createEmptyInstance() => create();
  static $pb.PbList<ApprovalRequestDecideResponse> createRepeated() => $pb.PbList<ApprovalRequestDecideResponse>();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestDecideResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApprovalRequestDecideResponse>(create);
  static ApprovalRequestDecideResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ApprovalRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ApprovalRequestObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ApprovalRequestObject ensureData() => $_ensure(0);
}

class LedgerEntryObject extends $pb.GeneratedMessage {
  factory LedgerEntryObject({
    $core.String? id,
    $core.String? reservationId,
    $core.String? tenantId,
    $core.String? orgUnitId,
    LimitAction? action,
    SubjectType? subjectType,
    $core.String? subjectId,
    $7.Money? amount,
    $2.Timestamp? committedAt,
    $2.Timestamp? reversedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (reservationId != null) {
      $result.reservationId = reservationId;
    }
    if (tenantId != null) {
      $result.tenantId = tenantId;
    }
    if (orgUnitId != null) {
      $result.orgUnitId = orgUnitId;
    }
    if (action != null) {
      $result.action = action;
    }
    if (subjectType != null) {
      $result.subjectType = subjectType;
    }
    if (subjectId != null) {
      $result.subjectId = subjectId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (committedAt != null) {
      $result.committedAt = committedAt;
    }
    if (reversedAt != null) {
      $result.reversedAt = reversedAt;
    }
    return $result;
  }
  LedgerEntryObject._() : super();
  factory LedgerEntryObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LedgerEntryObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LedgerEntryObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reservationId')
    ..aOS(3, _omitFieldNames ? '' : 'tenantId')
    ..aOS(4, _omitFieldNames ? '' : 'orgUnitId')
    ..e<LimitAction>(5, _omitFieldNames ? '' : 'action', $pb.PbFieldType.OE, defaultOrMaker: LimitAction.LIMIT_ACTION_UNSPECIFIED, valueOf: LimitAction.valueOf, enumValues: LimitAction.values)
    ..e<SubjectType>(6, _omitFieldNames ? '' : 'subjectType', $pb.PbFieldType.OE, defaultOrMaker: SubjectType.SUBJECT_TYPE_UNSPECIFIED, valueOf: SubjectType.valueOf, enumValues: SubjectType.values)
    ..aOS(7, _omitFieldNames ? '' : 'subjectId')
    ..aOM<$7.Money>(8, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..aOM<$2.Timestamp>(9, _omitFieldNames ? '' : 'committedAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'reversedAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LedgerEntryObject clone() => LedgerEntryObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LedgerEntryObject copyWith(void Function(LedgerEntryObject) updates) => super.copyWith((message) => updates(message as LedgerEntryObject)) as LedgerEntryObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LedgerEntryObject create() => LedgerEntryObject._();
  LedgerEntryObject createEmptyInstance() => create();
  static $pb.PbList<LedgerEntryObject> createRepeated() => $pb.PbList<LedgerEntryObject>();
  @$core.pragma('dart2js:noInline')
  static LedgerEntryObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LedgerEntryObject>(create);
  static LedgerEntryObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reservationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set reservationId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReservationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReservationId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get tenantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set tenantId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get orgUnitId => $_getSZ(3);
  @$pb.TagNumber(4)
  set orgUnitId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOrgUnitId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrgUnitId() => clearField(4);

  @$pb.TagNumber(5)
  LimitAction get action => $_getN(4);
  @$pb.TagNumber(5)
  set action(LimitAction v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAction() => $_has(4);
  @$pb.TagNumber(5)
  void clearAction() => clearField(5);

  @$pb.TagNumber(6)
  SubjectType get subjectType => $_getN(5);
  @$pb.TagNumber(6)
  set subjectType(SubjectType v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasSubjectType() => $_has(5);
  @$pb.TagNumber(6)
  void clearSubjectType() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get subjectId => $_getSZ(6);
  @$pb.TagNumber(7)
  set subjectId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSubjectId() => $_has(6);
  @$pb.TagNumber(7)
  void clearSubjectId() => clearField(7);

  @$pb.TagNumber(8)
  $7.Money get amount => $_getN(7);
  @$pb.TagNumber(8)
  set amount($7.Money v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasAmount() => $_has(7);
  @$pb.TagNumber(8)
  void clearAmount() => clearField(8);
  @$pb.TagNumber(8)
  $7.Money ensureAmount() => $_ensure(7);

  @$pb.TagNumber(9)
  $2.Timestamp get committedAt => $_getN(8);
  @$pb.TagNumber(9)
  set committedAt($2.Timestamp v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasCommittedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCommittedAt() => clearField(9);
  @$pb.TagNumber(9)
  $2.Timestamp ensureCommittedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $2.Timestamp get reversedAt => $_getN(9);
  @$pb.TagNumber(10)
  set reversedAt($2.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasReversedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearReversedAt() => clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureReversedAt() => $_ensure(9);
}

class LedgerSearchRequest extends $pb.GeneratedMessage {
  factory LedgerSearchRequest({
    $core.String? tenantId,
    LimitAction? action,
    SubjectType? subjectType,
    $core.String? subjectId,
    $core.String? currencyCode,
    $2.Timestamp? from,
    $2.Timestamp? to,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (tenantId != null) {
      $result.tenantId = tenantId;
    }
    if (action != null) {
      $result.action = action;
    }
    if (subjectType != null) {
      $result.subjectType = subjectType;
    }
    if (subjectId != null) {
      $result.subjectId = subjectId;
    }
    if (currencyCode != null) {
      $result.currencyCode = currencyCode;
    }
    if (from != null) {
      $result.from = from;
    }
    if (to != null) {
      $result.to = to;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  LedgerSearchRequest._() : super();
  factory LedgerSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LedgerSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LedgerSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..e<LimitAction>(2, _omitFieldNames ? '' : 'action', $pb.PbFieldType.OE, defaultOrMaker: LimitAction.LIMIT_ACTION_UNSPECIFIED, valueOf: LimitAction.valueOf, enumValues: LimitAction.values)
    ..e<SubjectType>(3, _omitFieldNames ? '' : 'subjectType', $pb.PbFieldType.OE, defaultOrMaker: SubjectType.SUBJECT_TYPE_UNSPECIFIED, valueOf: SubjectType.valueOf, enumValues: SubjectType.values)
    ..aOS(4, _omitFieldNames ? '' : 'subjectId')
    ..aOS(5, _omitFieldNames ? '' : 'currencyCode')
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'from', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(7, _omitFieldNames ? '' : 'to', subBuilder: $2.Timestamp.create)
    ..aOM<$8.PageCursor>(8, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LedgerSearchRequest clone() => LedgerSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LedgerSearchRequest copyWith(void Function(LedgerSearchRequest) updates) => super.copyWith((message) => updates(message as LedgerSearchRequest)) as LedgerSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LedgerSearchRequest create() => LedgerSearchRequest._();
  LedgerSearchRequest createEmptyInstance() => create();
  static $pb.PbList<LedgerSearchRequest> createRepeated() => $pb.PbList<LedgerSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static LedgerSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LedgerSearchRequest>(create);
  static LedgerSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => clearField(1);

  @$pb.TagNumber(2)
  LimitAction get action => $_getN(1);
  @$pb.TagNumber(2)
  set action(LimitAction v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => clearField(2);

  @$pb.TagNumber(3)
  SubjectType get subjectType => $_getN(2);
  @$pb.TagNumber(3)
  set subjectType(SubjectType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSubjectType() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubjectType() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get subjectId => $_getSZ(3);
  @$pb.TagNumber(4)
  set subjectId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSubjectId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubjectId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get currencyCode => $_getSZ(4);
  @$pb.TagNumber(5)
  set currencyCode($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCurrencyCode() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrencyCode() => clearField(5);

  @$pb.TagNumber(6)
  $2.Timestamp get from => $_getN(5);
  @$pb.TagNumber(6)
  set from($2.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasFrom() => $_has(5);
  @$pb.TagNumber(6)
  void clearFrom() => clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureFrom() => $_ensure(5);

  @$pb.TagNumber(7)
  $2.Timestamp get to => $_getN(6);
  @$pb.TagNumber(7)
  set to($2.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasTo() => $_has(6);
  @$pb.TagNumber(7)
  void clearTo() => clearField(7);
  @$pb.TagNumber(7)
  $2.Timestamp ensureTo() => $_ensure(6);

  @$pb.TagNumber(8)
  $8.PageCursor get cursor => $_getN(7);
  @$pb.TagNumber(8)
  set cursor($8.PageCursor v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasCursor() => $_has(7);
  @$pb.TagNumber(8)
  void clearCursor() => clearField(8);
  @$pb.TagNumber(8)
  $8.PageCursor ensureCursor() => $_ensure(7);
}

class LedgerSearchResponse extends $pb.GeneratedMessage {
  factory LedgerSearchResponse({
    $core.Iterable<LedgerEntryObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  LedgerSearchResponse._() : super();
  factory LedgerSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LedgerSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LedgerSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..pc<LedgerEntryObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: LedgerEntryObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LedgerSearchResponse clone() => LedgerSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LedgerSearchResponse copyWith(void Function(LedgerSearchResponse) updates) => super.copyWith((message) => updates(message as LedgerSearchResponse)) as LedgerSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LedgerSearchResponse create() => LedgerSearchResponse._();
  LedgerSearchResponse createEmptyInstance() => create();
  static $pb.PbList<LedgerSearchResponse> createRepeated() => $pb.PbList<LedgerSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static LedgerSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LedgerSearchResponse>(create);
  static LedgerSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<LedgerEntryObject> get data => $_getList(0);
}

class LimitsAuditEventObject extends $pb.GeneratedMessage {
  factory LimitsAuditEventObject({
    $core.String? id,
    $core.String? entityType,
    $core.String? entityId,
    $core.String? action,
    $core.String? actorId,
    $core.String? actorType,
    $core.String? reason,
    $6.Struct? metadata,
    $2.Timestamp? occurredAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (entityType != null) {
      $result.entityType = entityType;
    }
    if (entityId != null) {
      $result.entityId = entityId;
    }
    if (action != null) {
      $result.action = action;
    }
    if (actorId != null) {
      $result.actorId = actorId;
    }
    if (actorType != null) {
      $result.actorType = actorType;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    if (metadata != null) {
      $result.metadata = metadata;
    }
    if (occurredAt != null) {
      $result.occurredAt = occurredAt;
    }
    return $result;
  }
  LimitsAuditEventObject._() : super();
  factory LimitsAuditEventObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LimitsAuditEventObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LimitsAuditEventObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'entityType')
    ..aOS(3, _omitFieldNames ? '' : 'entityId')
    ..aOS(4, _omitFieldNames ? '' : 'action')
    ..aOS(5, _omitFieldNames ? '' : 'actorId')
    ..aOS(6, _omitFieldNames ? '' : 'actorType')
    ..aOS(7, _omitFieldNames ? '' : 'reason')
    ..aOM<$6.Struct>(8, _omitFieldNames ? '' : 'metadata', subBuilder: $6.Struct.create)
    ..aOM<$2.Timestamp>(9, _omitFieldNames ? '' : 'occurredAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LimitsAuditEventObject clone() => LimitsAuditEventObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LimitsAuditEventObject copyWith(void Function(LimitsAuditEventObject) updates) => super.copyWith((message) => updates(message as LimitsAuditEventObject)) as LimitsAuditEventObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LimitsAuditEventObject create() => LimitsAuditEventObject._();
  LimitsAuditEventObject createEmptyInstance() => create();
  static $pb.PbList<LimitsAuditEventObject> createRepeated() => $pb.PbList<LimitsAuditEventObject>();
  @$core.pragma('dart2js:noInline')
  static LimitsAuditEventObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LimitsAuditEventObject>(create);
  static LimitsAuditEventObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get entityType => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEntityType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get entityId => $_getSZ(2);
  @$pb.TagNumber(3)
  set entityId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEntityId() => $_has(2);
  @$pb.TagNumber(3)
  void clearEntityId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get action => $_getSZ(3);
  @$pb.TagNumber(4)
  set action($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAction() => $_has(3);
  @$pb.TagNumber(4)
  void clearAction() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get actorId => $_getSZ(4);
  @$pb.TagNumber(5)
  set actorId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasActorId() => $_has(4);
  @$pb.TagNumber(5)
  void clearActorId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get actorType => $_getSZ(5);
  @$pb.TagNumber(6)
  set actorType($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasActorType() => $_has(5);
  @$pb.TagNumber(6)
  void clearActorType() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get reason => $_getSZ(6);
  @$pb.TagNumber(7)
  set reason($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasReason() => $_has(6);
  @$pb.TagNumber(7)
  void clearReason() => clearField(7);

  @$pb.TagNumber(8)
  $6.Struct get metadata => $_getN(7);
  @$pb.TagNumber(8)
  set metadata($6.Struct v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasMetadata() => $_has(7);
  @$pb.TagNumber(8)
  void clearMetadata() => clearField(8);
  @$pb.TagNumber(8)
  $6.Struct ensureMetadata() => $_ensure(7);

  @$pb.TagNumber(9)
  $2.Timestamp get occurredAt => $_getN(8);
  @$pb.TagNumber(9)
  set occurredAt($2.Timestamp v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasOccurredAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearOccurredAt() => clearField(9);
  @$pb.TagNumber(9)
  $2.Timestamp ensureOccurredAt() => $_ensure(8);
}

class LimitsAuditSearchRequest extends $pb.GeneratedMessage {
  factory LimitsAuditSearchRequest({
    $core.Iterable<$core.String>? actions,
    $core.String? entityType,
    $core.String? entityId,
    $core.String? actorId,
    $2.Timestamp? from,
    $2.Timestamp? to,
    $8.PageCursor? cursor,
  }) {
    final $result = create();
    if (actions != null) {
      $result.actions.addAll(actions);
    }
    if (entityType != null) {
      $result.entityType = entityType;
    }
    if (entityId != null) {
      $result.entityId = entityId;
    }
    if (actorId != null) {
      $result.actorId = actorId;
    }
    if (from != null) {
      $result.from = from;
    }
    if (to != null) {
      $result.to = to;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  LimitsAuditSearchRequest._() : super();
  factory LimitsAuditSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LimitsAuditSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LimitsAuditSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'actions')
    ..aOS(2, _omitFieldNames ? '' : 'entityType')
    ..aOS(3, _omitFieldNames ? '' : 'entityId')
    ..aOS(4, _omitFieldNames ? '' : 'actorId')
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'from', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'to', subBuilder: $2.Timestamp.create)
    ..aOM<$8.PageCursor>(7, _omitFieldNames ? '' : 'cursor', subBuilder: $8.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LimitsAuditSearchRequest clone() => LimitsAuditSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LimitsAuditSearchRequest copyWith(void Function(LimitsAuditSearchRequest) updates) => super.copyWith((message) => updates(message as LimitsAuditSearchRequest)) as LimitsAuditSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LimitsAuditSearchRequest create() => LimitsAuditSearchRequest._();
  LimitsAuditSearchRequest createEmptyInstance() => create();
  static $pb.PbList<LimitsAuditSearchRequest> createRepeated() => $pb.PbList<LimitsAuditSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static LimitsAuditSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LimitsAuditSearchRequest>(create);
  static LimitsAuditSearchRequest? _defaultInstance;

  /// Filter on action verb. If empty, all "limits.*" verbs are returned.
  /// Each entry is matched exactly (e.g. "limits.breach.hard").
  @$pb.TagNumber(1)
  $core.List<$core.String> get actions => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get entityType => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEntityType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get entityId => $_getSZ(2);
  @$pb.TagNumber(3)
  set entityId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEntityId() => $_has(2);
  @$pb.TagNumber(3)
  void clearEntityId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get actorId => $_getSZ(3);
  @$pb.TagNumber(4)
  set actorId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasActorId() => $_has(3);
  @$pb.TagNumber(4)
  void clearActorId() => clearField(4);

  @$pb.TagNumber(5)
  $2.Timestamp get from => $_getN(4);
  @$pb.TagNumber(5)
  set from($2.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasFrom() => $_has(4);
  @$pb.TagNumber(5)
  void clearFrom() => clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureFrom() => $_ensure(4);

  @$pb.TagNumber(6)
  $2.Timestamp get to => $_getN(5);
  @$pb.TagNumber(6)
  set to($2.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasTo() => $_has(5);
  @$pb.TagNumber(6)
  void clearTo() => clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureTo() => $_ensure(5);

  @$pb.TagNumber(7)
  $8.PageCursor get cursor => $_getN(6);
  @$pb.TagNumber(7)
  set cursor($8.PageCursor v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasCursor() => $_has(6);
  @$pb.TagNumber(7)
  void clearCursor() => clearField(7);
  @$pb.TagNumber(7)
  $8.PageCursor ensureCursor() => $_ensure(6);
}

class LimitsAuditSearchResponse extends $pb.GeneratedMessage {
  factory LimitsAuditSearchResponse({
    $core.Iterable<LimitsAuditEventObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  LimitsAuditSearchResponse._() : super();
  factory LimitsAuditSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LimitsAuditSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LimitsAuditSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..pc<LimitsAuditEventObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: LimitsAuditEventObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LimitsAuditSearchResponse clone() => LimitsAuditSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LimitsAuditSearchResponse copyWith(void Function(LimitsAuditSearchResponse) updates) => super.copyWith((message) => updates(message as LimitsAuditSearchResponse)) as LimitsAuditSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LimitsAuditSearchResponse create() => LimitsAuditSearchResponse._();
  LimitsAuditSearchResponse createEmptyInstance() => create();
  static $pb.PbList<LimitsAuditSearchResponse> createRepeated() => $pb.PbList<LimitsAuditSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static LimitsAuditSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LimitsAuditSearchResponse>(create);
  static LimitsAuditSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<LimitsAuditEventObject> get data => $_getList(0);
}

class CheckRequest extends $pb.GeneratedMessage {
  factory CheckRequest({
    LimitIntent? intent,
  }) {
    final $result = create();
    if (intent != null) {
      $result.intent = intent;
    }
    return $result;
  }
  CheckRequest._() : super();
  factory CheckRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CheckRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOM<LimitIntent>(1, _omitFieldNames ? '' : 'intent', subBuilder: LimitIntent.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CheckRequest clone() => CheckRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CheckRequest copyWith(void Function(CheckRequest) updates) => super.copyWith((message) => updates(message as CheckRequest)) as CheckRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckRequest create() => CheckRequest._();
  CheckRequest createEmptyInstance() => create();
  static $pb.PbList<CheckRequest> createRepeated() => $pb.PbList<CheckRequest>();
  @$core.pragma('dart2js:noInline')
  static CheckRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckRequest>(create);
  static CheckRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LimitIntent get intent => $_getN(0);
  @$pb.TagNumber(1)
  set intent(LimitIntent v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasIntent() => $_has(0);
  @$pb.TagNumber(1)
  void clearIntent() => clearField(1);
  @$pb.TagNumber(1)
  LimitIntent ensureIntent() => $_ensure(0);
}

class CheckResponse extends $pb.GeneratedMessage {
  factory CheckResponse({
    $core.bool? allowed,
    $core.bool? requiresApproval,
    $core.int? requiredApprovers,
    $core.String? requiredRole,
    $core.Iterable<PolicyVerdict>? verdicts,
    $core.Iterable<$core.String>? breachedPolicyIds,
  }) {
    final $result = create();
    if (allowed != null) {
      $result.allowed = allowed;
    }
    if (requiresApproval != null) {
      $result.requiresApproval = requiresApproval;
    }
    if (requiredApprovers != null) {
      $result.requiredApprovers = requiredApprovers;
    }
    if (requiredRole != null) {
      $result.requiredRole = requiredRole;
    }
    if (verdicts != null) {
      $result.verdicts.addAll(verdicts);
    }
    if (breachedPolicyIds != null) {
      $result.breachedPolicyIds.addAll(breachedPolicyIds);
    }
    return $result;
  }
  CheckResponse._() : super();
  factory CheckResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CheckResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CheckResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'allowed')
    ..aOB(2, _omitFieldNames ? '' : 'requiresApproval')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'requiredApprovers', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'requiredRole')
    ..pc<PolicyVerdict>(5, _omitFieldNames ? '' : 'verdicts', $pb.PbFieldType.PM, subBuilder: PolicyVerdict.create)
    ..pPS(6, _omitFieldNames ? '' : 'breachedPolicyIds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CheckResponse clone() => CheckResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CheckResponse copyWith(void Function(CheckResponse) updates) => super.copyWith((message) => updates(message as CheckResponse)) as CheckResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckResponse create() => CheckResponse._();
  CheckResponse createEmptyInstance() => create();
  static $pb.PbList<CheckResponse> createRepeated() => $pb.PbList<CheckResponse>();
  @$core.pragma('dart2js:noInline')
  static CheckResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckResponse>(create);
  static CheckResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get allowed => $_getBF(0);
  @$pb.TagNumber(1)
  set allowed($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAllowed() => $_has(0);
  @$pb.TagNumber(1)
  void clearAllowed() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get requiresApproval => $_getBF(1);
  @$pb.TagNumber(2)
  set requiresApproval($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRequiresApproval() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequiresApproval() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get requiredApprovers => $_getIZ(2);
  @$pb.TagNumber(3)
  set requiredApprovers($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRequiredApprovers() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequiredApprovers() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get requiredRole => $_getSZ(3);
  @$pb.TagNumber(4)
  set requiredRole($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRequiredRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequiredRole() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<PolicyVerdict> get verdicts => $_getList(4);

  @$pb.TagNumber(6)
  $core.List<$core.String> get breachedPolicyIds => $_getList(5);
}

class ReservationObject extends $pb.GeneratedMessage {
  factory ReservationObject({
    $core.String? id,
    $core.String? tenantId,
    $core.String? idempotencyKey,
    $core.String? orgUnitId,
    LimitAction? action,
    $7.Money? amount,
    $core.Iterable<SubjectRef>? subjects,
    $core.String? makerId,
    ReservationStatus? status,
    $core.bool? isShadow,
    $2.Timestamp? reservedAt,
    $2.Timestamp? ttlAt,
    $2.Timestamp? committedAt,
    $2.Timestamp? releasedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (tenantId != null) {
      $result.tenantId = tenantId;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (orgUnitId != null) {
      $result.orgUnitId = orgUnitId;
    }
    if (action != null) {
      $result.action = action;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (subjects != null) {
      $result.subjects.addAll(subjects);
    }
    if (makerId != null) {
      $result.makerId = makerId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (isShadow != null) {
      $result.isShadow = isShadow;
    }
    if (reservedAt != null) {
      $result.reservedAt = reservedAt;
    }
    if (ttlAt != null) {
      $result.ttlAt = ttlAt;
    }
    if (committedAt != null) {
      $result.committedAt = committedAt;
    }
    if (releasedAt != null) {
      $result.releasedAt = releasedAt;
    }
    return $result;
  }
  ReservationObject._() : super();
  factory ReservationObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReservationObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReservationObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(4, _omitFieldNames ? '' : 'orgUnitId')
    ..e<LimitAction>(5, _omitFieldNames ? '' : 'action', $pb.PbFieldType.OE, defaultOrMaker: LimitAction.LIMIT_ACTION_UNSPECIFIED, valueOf: LimitAction.valueOf, enumValues: LimitAction.values)
    ..aOM<$7.Money>(6, _omitFieldNames ? '' : 'amount', subBuilder: $7.Money.create)
    ..pc<SubjectRef>(7, _omitFieldNames ? '' : 'subjects', $pb.PbFieldType.PM, subBuilder: SubjectRef.create)
    ..aOS(8, _omitFieldNames ? '' : 'makerId')
    ..e<ReservationStatus>(9, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: ReservationStatus.RESERVATION_STATUS_UNSPECIFIED, valueOf: ReservationStatus.valueOf, enumValues: ReservationStatus.values)
    ..aOB(10, _omitFieldNames ? '' : 'isShadow')
    ..aOM<$2.Timestamp>(11, _omitFieldNames ? '' : 'reservedAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(12, _omitFieldNames ? '' : 'ttlAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(13, _omitFieldNames ? '' : 'committedAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(14, _omitFieldNames ? '' : 'releasedAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReservationObject clone() => ReservationObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReservationObject copyWith(void Function(ReservationObject) updates) => super.copyWith((message) => updates(message as ReservationObject)) as ReservationObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReservationObject create() => ReservationObject._();
  ReservationObject createEmptyInstance() => create();
  static $pb.PbList<ReservationObject> createRepeated() => $pb.PbList<ReservationObject>();
  @$core.pragma('dart2js:noInline')
  static ReservationObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReservationObject>(create);
  static ReservationObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get idempotencyKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set idempotencyKey($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIdempotencyKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdempotencyKey() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get orgUnitId => $_getSZ(3);
  @$pb.TagNumber(4)
  set orgUnitId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOrgUnitId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrgUnitId() => clearField(4);

  @$pb.TagNumber(5)
  LimitAction get action => $_getN(4);
  @$pb.TagNumber(5)
  set action(LimitAction v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAction() => $_has(4);
  @$pb.TagNumber(5)
  void clearAction() => clearField(5);

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

  @$pb.TagNumber(7)
  $core.List<SubjectRef> get subjects => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get makerId => $_getSZ(7);
  @$pb.TagNumber(8)
  set makerId($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasMakerId() => $_has(7);
  @$pb.TagNumber(8)
  void clearMakerId() => clearField(8);

  @$pb.TagNumber(9)
  ReservationStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(ReservationStatus v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isShadow => $_getBF(9);
  @$pb.TagNumber(10)
  set isShadow($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasIsShadow() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsShadow() => clearField(10);

  @$pb.TagNumber(11)
  $2.Timestamp get reservedAt => $_getN(10);
  @$pb.TagNumber(11)
  set reservedAt($2.Timestamp v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasReservedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearReservedAt() => clearField(11);
  @$pb.TagNumber(11)
  $2.Timestamp ensureReservedAt() => $_ensure(10);

  @$pb.TagNumber(12)
  $2.Timestamp get ttlAt => $_getN(11);
  @$pb.TagNumber(12)
  set ttlAt($2.Timestamp v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasTtlAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearTtlAt() => clearField(12);
  @$pb.TagNumber(12)
  $2.Timestamp ensureTtlAt() => $_ensure(11);

  @$pb.TagNumber(13)
  $2.Timestamp get committedAt => $_getN(12);
  @$pb.TagNumber(13)
  set committedAt($2.Timestamp v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasCommittedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearCommittedAt() => clearField(13);
  @$pb.TagNumber(13)
  $2.Timestamp ensureCommittedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $2.Timestamp get releasedAt => $_getN(13);
  @$pb.TagNumber(14)
  set releasedAt($2.Timestamp v) { setField(14, v); }
  @$pb.TagNumber(14)
  $core.bool hasReleasedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearReleasedAt() => clearField(14);
  @$pb.TagNumber(14)
  $2.Timestamp ensureReleasedAt() => $_ensure(13);
}

class ReserveRequest extends $pb.GeneratedMessage {
  factory ReserveRequest({
    LimitIntent? intent,
    $core.String? idempotencyKey,
    $0.Duration? ttl,
  }) {
    final $result = create();
    if (intent != null) {
      $result.intent = intent;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (ttl != null) {
      $result.ttl = ttl;
    }
    return $result;
  }
  ReserveRequest._() : super();
  factory ReserveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReserveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReserveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOM<LimitIntent>(1, _omitFieldNames ? '' : 'intent', subBuilder: LimitIntent.create)
    ..aOS(2, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$0.Duration>(3, _omitFieldNames ? '' : 'ttl', subBuilder: $0.Duration.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReserveRequest clone() => ReserveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReserveRequest copyWith(void Function(ReserveRequest) updates) => super.copyWith((message) => updates(message as ReserveRequest)) as ReserveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReserveRequest create() => ReserveRequest._();
  ReserveRequest createEmptyInstance() => create();
  static $pb.PbList<ReserveRequest> createRepeated() => $pb.PbList<ReserveRequest>();
  @$core.pragma('dart2js:noInline')
  static ReserveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReserveRequest>(create);
  static ReserveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LimitIntent get intent => $_getN(0);
  @$pb.TagNumber(1)
  set intent(LimitIntent v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasIntent() => $_has(0);
  @$pb.TagNumber(1)
  void clearIntent() => clearField(1);
  @$pb.TagNumber(1)
  LimitIntent ensureIntent() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get idempotencyKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set idempotencyKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdempotencyKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdempotencyKey() => clearField(2);

  @$pb.TagNumber(3)
  $0.Duration get ttl => $_getN(2);
  @$pb.TagNumber(3)
  set ttl($0.Duration v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTtl() => $_has(2);
  @$pb.TagNumber(3)
  void clearTtl() => clearField(3);
  @$pb.TagNumber(3)
  $0.Duration ensureTtl() => $_ensure(2);
}

class ReserveResponse extends $pb.GeneratedMessage {
  factory ReserveResponse({
    ReservationObject? reservation,
    CheckResponse? check_2,
  }) {
    final $result = create();
    if (reservation != null) {
      $result.reservation = reservation;
    }
    if (check_2 != null) {
      $result.check_2 = check_2;
    }
    return $result;
  }
  ReserveResponse._() : super();
  factory ReserveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReserveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReserveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOM<ReservationObject>(1, _omitFieldNames ? '' : 'reservation', subBuilder: ReservationObject.create)
    ..aOM<CheckResponse>(2, _omitFieldNames ? '' : 'check', subBuilder: CheckResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReserveResponse clone() => ReserveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReserveResponse copyWith(void Function(ReserveResponse) updates) => super.copyWith((message) => updates(message as ReserveResponse)) as ReserveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReserveResponse create() => ReserveResponse._();
  ReserveResponse createEmptyInstance() => create();
  static $pb.PbList<ReserveResponse> createRepeated() => $pb.PbList<ReserveResponse>();
  @$core.pragma('dart2js:noInline')
  static ReserveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReserveResponse>(create);
  static ReserveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReservationObject get reservation => $_getN(0);
  @$pb.TagNumber(1)
  set reservation(ReservationObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasReservation() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservation() => clearField(1);
  @$pb.TagNumber(1)
  ReservationObject ensureReservation() => $_ensure(0);

  @$pb.TagNumber(2)
  CheckResponse get check_2 => $_getN(1);
  @$pb.TagNumber(2)
  set check_2(CheckResponse v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCheck_2() => $_has(1);
  @$pb.TagNumber(2)
  void clearCheck_2() => clearField(2);
  @$pb.TagNumber(2)
  CheckResponse ensureCheck_2() => $_ensure(1);
}

class CommitRequest extends $pb.GeneratedMessage {
  factory CommitRequest({
    $core.String? reservationId,
  }) {
    final $result = create();
    if (reservationId != null) {
      $result.reservationId = reservationId;
    }
    return $result;
  }
  CommitRequest._() : super();
  factory CommitRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CommitRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommitRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'reservationId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CommitRequest clone() => CommitRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CommitRequest copyWith(void Function(CommitRequest) updates) => super.copyWith((message) => updates(message as CommitRequest)) as CommitRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommitRequest create() => CommitRequest._();
  CommitRequest createEmptyInstance() => create();
  static $pb.PbList<CommitRequest> createRepeated() => $pb.PbList<CommitRequest>();
  @$core.pragma('dart2js:noInline')
  static CommitRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommitRequest>(create);
  static CommitRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reservationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set reservationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReservationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservationId() => clearField(1);
}

class CommitResponse extends $pb.GeneratedMessage {
  factory CommitResponse({
    ReservationObject? reservation,
  }) {
    final $result = create();
    if (reservation != null) {
      $result.reservation = reservation;
    }
    return $result;
  }
  CommitResponse._() : super();
  factory CommitResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CommitResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommitResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOM<ReservationObject>(1, _omitFieldNames ? '' : 'reservation', subBuilder: ReservationObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CommitResponse clone() => CommitResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CommitResponse copyWith(void Function(CommitResponse) updates) => super.copyWith((message) => updates(message as CommitResponse)) as CommitResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommitResponse create() => CommitResponse._();
  CommitResponse createEmptyInstance() => create();
  static $pb.PbList<CommitResponse> createRepeated() => $pb.PbList<CommitResponse>();
  @$core.pragma('dart2js:noInline')
  static CommitResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommitResponse>(create);
  static CommitResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReservationObject get reservation => $_getN(0);
  @$pb.TagNumber(1)
  set reservation(ReservationObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasReservation() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservation() => clearField(1);
  @$pb.TagNumber(1)
  ReservationObject ensureReservation() => $_ensure(0);
}

class ReleaseRequest extends $pb.GeneratedMessage {
  factory ReleaseRequest({
    $core.String? reservationId,
    $core.String? reason,
  }) {
    final $result = create();
    if (reservationId != null) {
      $result.reservationId = reservationId;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  ReleaseRequest._() : super();
  factory ReleaseRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReleaseRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReleaseRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'reservationId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReleaseRequest clone() => ReleaseRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReleaseRequest copyWith(void Function(ReleaseRequest) updates) => super.copyWith((message) => updates(message as ReleaseRequest)) as ReleaseRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReleaseRequest create() => ReleaseRequest._();
  ReleaseRequest createEmptyInstance() => create();
  static $pb.PbList<ReleaseRequest> createRepeated() => $pb.PbList<ReleaseRequest>();
  @$core.pragma('dart2js:noInline')
  static ReleaseRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReleaseRequest>(create);
  static ReleaseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reservationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set reservationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReservationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservationId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => clearField(2);
}

class ReleaseResponse extends $pb.GeneratedMessage {
  factory ReleaseResponse({
    ReservationObject? reservation,
  }) {
    final $result = create();
    if (reservation != null) {
      $result.reservation = reservation;
    }
    return $result;
  }
  ReleaseResponse._() : super();
  factory ReleaseResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReleaseResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReleaseResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOM<ReservationObject>(1, _omitFieldNames ? '' : 'reservation', subBuilder: ReservationObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReleaseResponse clone() => ReleaseResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReleaseResponse copyWith(void Function(ReleaseResponse) updates) => super.copyWith((message) => updates(message as ReleaseResponse)) as ReleaseResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReleaseResponse create() => ReleaseResponse._();
  ReleaseResponse createEmptyInstance() => create();
  static $pb.PbList<ReleaseResponse> createRepeated() => $pb.PbList<ReleaseResponse>();
  @$core.pragma('dart2js:noInline')
  static ReleaseResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReleaseResponse>(create);
  static ReleaseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReservationObject get reservation => $_getN(0);
  @$pb.TagNumber(1)
  set reservation(ReservationObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasReservation() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservation() => clearField(1);
  @$pb.TagNumber(1)
  ReservationObject ensureReservation() => $_ensure(0);
}

class ReverseRequest extends $pb.GeneratedMessage {
  factory ReverseRequest({
    $core.String? reservationId,
    $core.String? idempotencyKey,
    $core.String? reason,
  }) {
    final $result = create();
    if (reservationId != null) {
      $result.reservationId = reservationId;
    }
    if (idempotencyKey != null) {
      $result.idempotencyKey = idempotencyKey;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  ReverseRequest._() : super();
  factory ReverseRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReverseRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReverseRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'reservationId')
    ..aOS(2, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReverseRequest clone() => ReverseRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReverseRequest copyWith(void Function(ReverseRequest) updates) => super.copyWith((message) => updates(message as ReverseRequest)) as ReverseRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReverseRequest create() => ReverseRequest._();
  ReverseRequest createEmptyInstance() => create();
  static $pb.PbList<ReverseRequest> createRepeated() => $pb.PbList<ReverseRequest>();
  @$core.pragma('dart2js:noInline')
  static ReverseRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReverseRequest>(create);
  static ReverseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reservationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set reservationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReservationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservationId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get idempotencyKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set idempotencyKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdempotencyKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdempotencyKey() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => clearField(3);
}

class ReverseResponse extends $pb.GeneratedMessage {
  factory ReverseResponse({
    ReservationObject? originalReservation,
    ReservationObject? reversalReservation,
  }) {
    final $result = create();
    if (originalReservation != null) {
      $result.originalReservation = originalReservation;
    }
    if (reversalReservation != null) {
      $result.reversalReservation = reversalReservation;
    }
    return $result;
  }
  ReverseResponse._() : super();
  factory ReverseResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReverseResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReverseResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'), createEmptyInstance: create)
    ..aOM<ReservationObject>(1, _omitFieldNames ? '' : 'originalReservation', subBuilder: ReservationObject.create)
    ..aOM<ReservationObject>(2, _omitFieldNames ? '' : 'reversalReservation', subBuilder: ReservationObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReverseResponse clone() => ReverseResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReverseResponse copyWith(void Function(ReverseResponse) updates) => super.copyWith((message) => updates(message as ReverseResponse)) as ReverseResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReverseResponse create() => ReverseResponse._();
  ReverseResponse createEmptyInstance() => create();
  static $pb.PbList<ReverseResponse> createRepeated() => $pb.PbList<ReverseResponse>();
  @$core.pragma('dart2js:noInline')
  static ReverseResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReverseResponse>(create);
  static ReverseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReservationObject get originalReservation => $_getN(0);
  @$pb.TagNumber(1)
  set originalReservation(ReservationObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOriginalReservation() => $_has(0);
  @$pb.TagNumber(1)
  void clearOriginalReservation() => clearField(1);
  @$pb.TagNumber(1)
  ReservationObject ensureOriginalReservation() => $_ensure(0);

  @$pb.TagNumber(2)
  ReservationObject get reversalReservation => $_getN(1);
  @$pb.TagNumber(2)
  set reversalReservation(ReservationObject v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasReversalReservation() => $_has(1);
  @$pb.TagNumber(2)
  void clearReversalReservation() => clearField(2);
  @$pb.TagNumber(2)
  ReservationObject ensureReversalReservation() => $_ensure(1);
}

class LimitsServiceApi {
  $pb.RpcClient _client;
  LimitsServiceApi(this._client);

  $async.Future<CheckResponse> check_($pb.ClientContext? ctx, CheckRequest request) =>
    _client.invoke<CheckResponse>(ctx, 'LimitsService', 'Check', request, CheckResponse())
  ;
  $async.Future<ReserveResponse> reserve($pb.ClientContext? ctx, ReserveRequest request) =>
    _client.invoke<ReserveResponse>(ctx, 'LimitsService', 'Reserve', request, ReserveResponse())
  ;
  $async.Future<CommitResponse> commit($pb.ClientContext? ctx, CommitRequest request) =>
    _client.invoke<CommitResponse>(ctx, 'LimitsService', 'Commit', request, CommitResponse())
  ;
  $async.Future<ReleaseResponse> release($pb.ClientContext? ctx, ReleaseRequest request) =>
    _client.invoke<ReleaseResponse>(ctx, 'LimitsService', 'Release', request, ReleaseResponse())
  ;
  $async.Future<ReverseResponse> reverse($pb.ClientContext? ctx, ReverseRequest request) =>
    _client.invoke<ReverseResponse>(ctx, 'LimitsService', 'Reverse', request, ReverseResponse())
  ;
}

class LimitsAdminServiceApi {
  $pb.RpcClient _client;
  LimitsAdminServiceApi(this._client);

  $async.Future<PolicySaveResponse> policySave($pb.ClientContext? ctx, PolicySaveRequest request) =>
    _client.invoke<PolicySaveResponse>(ctx, 'LimitsAdminService', 'PolicySave', request, PolicySaveResponse())
  ;
  $async.Future<PolicyGetResponse> policyGet($pb.ClientContext? ctx, PolicyGetRequest request) =>
    _client.invoke<PolicyGetResponse>(ctx, 'LimitsAdminService', 'PolicyGet', request, PolicyGetResponse())
  ;
  $async.Future<PolicySearchResponse> policySearch($pb.ClientContext? ctx, PolicySearchRequest request) =>
    _client.invoke<PolicySearchResponse>(ctx, 'LimitsAdminService', 'PolicySearch', request, PolicySearchResponse())
  ;
  $async.Future<PolicyDeleteResponse> policyDelete($pb.ClientContext? ctx, PolicyDeleteRequest request) =>
    _client.invoke<PolicyDeleteResponse>(ctx, 'LimitsAdminService', 'PolicyDelete', request, PolicyDeleteResponse())
  ;
  $async.Future<ApprovalRequestListResponse> approvalRequestList($pb.ClientContext? ctx, ApprovalRequestListRequest request) =>
    _client.invoke<ApprovalRequestListResponse>(ctx, 'LimitsAdminService', 'ApprovalRequestList', request, ApprovalRequestListResponse())
  ;
  $async.Future<ApprovalRequestGetResponse> approvalRequestGet($pb.ClientContext? ctx, ApprovalRequestGetRequest request) =>
    _client.invoke<ApprovalRequestGetResponse>(ctx, 'LimitsAdminService', 'ApprovalRequestGet', request, ApprovalRequestGetResponse())
  ;
  $async.Future<ApprovalRequestDecideResponse> approvalRequestDecide($pb.ClientContext? ctx, ApprovalRequestDecideRequest request) =>
    _client.invoke<ApprovalRequestDecideResponse>(ctx, 'LimitsAdminService', 'ApprovalRequestDecide', request, ApprovalRequestDecideResponse())
  ;
  $async.Future<LedgerSearchResponse> ledgerSearch($pb.ClientContext? ctx, LedgerSearchRequest request) =>
    _client.invoke<LedgerSearchResponse>(ctx, 'LimitsAdminService', 'LedgerSearch', request, LedgerSearchResponse())
  ;
  $async.Future<LimitsAuditSearchResponse> limitsAuditSearch($pb.ClientContext? ctx, LimitsAuditSearchRequest request) =>
    _client.invoke<LimitsAuditSearchResponse>(ctx, 'LimitsAdminService', 'LimitsAuditSearch', request, LimitsAuditSearchResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
