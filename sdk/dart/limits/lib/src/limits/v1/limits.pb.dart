// This is a generated file - do not edit.
//
// Generated from limits/v1/limits.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart'
    as $0;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $2;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $3;

import '../../common/v1/common.pb.dart' as $4;
import '../../common/v1/money.pb.dart' as $1;
import 'limits.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'limits.pbenum.dart';

class SubjectRef extends $pb.GeneratedMessage {
  factory SubjectRef({
    SubjectType? type,
    $core.String? id,
  }) {
    final result = SubjectRef._();
    if (type != null) result.type = type;
    if (id != null) result.id = id;
    return result;
  }

  SubjectRef._();

  factory SubjectRef.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubjectRef()..mergeFromBuffer(data, registry);
  factory SubjectRef.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubjectRef()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubjectRef',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: SubjectRef.$_createMessage)
    ..aE<SubjectType>(1, _omitFieldNames ? '' : 'type',
        enumValues: SubjectType.values)
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubjectRef clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubjectRef copyWith(void Function(SubjectRef) updates) =>
      super.copyWith((message) => updates(message as SubjectRef)) as SubjectRef;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubjectRef() / SubjectRef.new instead')
  static SubjectRef create() => SubjectRef._();
  static $pb.GeneratedMessage $_createMessage() => SubjectRef._();
  @$core.override
  SubjectRef createEmptyInstance() => SubjectRef._();
  @$core.pragma('dart2js:noInline')
  static SubjectRef getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubjectRef>(SubjectRef.$_createMessage);
  static SubjectRef? _defaultInstance;

  @$pb.TagNumber(1)
  SubjectType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SubjectType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);
}

class ApproverTier extends $pb.GeneratedMessage {
  factory ApproverTier({
    $fixnum.Int64? upTo,
    $core.String? role,
    $core.int? approvers,
  }) {
    final result = ApproverTier._();
    if (upTo != null) result.upTo = upTo;
    if (role != null) result.role = role;
    if (approvers != null) result.approvers = approvers;
    return result;
  }

  ApproverTier._();

  factory ApproverTier.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApproverTier()..mergeFromBuffer(data, registry);
  factory ApproverTier.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApproverTier()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApproverTier',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ApproverTier.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'upTo')
    ..aOS(2, _omitFieldNames ? '' : 'role')
    ..aI(3, _omitFieldNames ? '' : 'approvers')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproverTier clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproverTier copyWith(void Function(ApproverTier) updates) =>
      super.copyWith((message) => updates(message as ApproverTier))
          as ApproverTier;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ApproverTier() / ApproverTier.new instead')
  static ApproverTier create() => ApproverTier._();
  static $pb.GeneratedMessage $_createMessage() => ApproverTier._();
  @$core.override
  ApproverTier createEmptyInstance() => ApproverTier._();
  @$core.pragma('dart2js:noInline')
  static ApproverTier getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApproverTier>(
          ApproverTier.$_createMessage);
  static ApproverTier? _defaultInstance;

  /// Tier applies for amounts up to and including this value (in minor units).
  /// The final tier may set up_to = 0 to mean "and above".
  @$pb.TagNumber(1)
  $fixnum.Int64 get upTo => $_getI64(0);
  @$pb.TagNumber(1)
  set upTo($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUpTo() => $_has(0);
  @$pb.TagNumber(1)
  void clearUpTo() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get role => $_getSZ(1);
  @$pb.TagNumber(2)
  set role($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get approvers => $_getIZ(2);
  @$pb.TagNumber(3)
  set approvers($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasApprovers() => $_has(2);
  @$pb.TagNumber(3)
  void clearApprovers() => $_clearField(3);
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
    $1.Money? capAmount,
    $fixnum.Int64? capCount,
    PolicyMode? mode,
    $2.Struct? attributeFilter,
    $core.Iterable<ApproverTier>? approverTiers,
    $0.Duration? approvalTtl,
    $3.Timestamp? effectiveFrom,
    $3.Timestamp? effectiveTo,
    $core.String? notes,
    $core.int? version,
    $3.Timestamp? createdAt,
    $3.Timestamp? modifiedAt,
  }) {
    final result = PolicyObject._();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (scope != null) result.scope = scope;
    if (orgUnitId != null) result.orgUnitId = orgUnitId;
    if (action != null) result.action = action;
    if (subjectType != null) result.subjectType = subjectType;
    if (currencyCode != null) result.currencyCode = currencyCode;
    if (limitKind != null) result.limitKind = limitKind;
    if (window != null) result.window = window;
    if (capAmount != null) result.capAmount = capAmount;
    if (capCount != null) result.capCount = capCount;
    if (mode != null) result.mode = mode;
    if (attributeFilter != null) result.attributeFilter = attributeFilter;
    if (approverTiers != null) result.approverTiers.addAll(approverTiers);
    if (approvalTtl != null) result.approvalTtl = approvalTtl;
    if (effectiveFrom != null) result.effectiveFrom = effectiveFrom;
    if (effectiveTo != null) result.effectiveTo = effectiveTo;
    if (notes != null) result.notes = notes;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (modifiedAt != null) result.modifiedAt = modifiedAt;
    return result;
  }

  PolicyObject._();

  factory PolicyObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyObject()..mergeFromBuffer(data, registry);
  factory PolicyObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicyObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicyObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aE<PolicyScope>(3, _omitFieldNames ? '' : 'scope',
        enumValues: PolicyScope.values)
    ..aOS(4, _omitFieldNames ? '' : 'orgUnitId')
    ..aE<LimitAction>(5, _omitFieldNames ? '' : 'action',
        enumValues: LimitAction.values)
    ..aE<SubjectType>(6, _omitFieldNames ? '' : 'subjectType',
        enumValues: SubjectType.values)
    ..aOS(7, _omitFieldNames ? '' : 'currencyCode')
    ..aE<LimitKind>(8, _omitFieldNames ? '' : 'limitKind',
        enumValues: LimitKind.values)
    ..aOM<$0.Duration>(9, _omitFieldNames ? '' : 'window',
        subBuilder: $0.Duration.$_createMessage)
    ..aOM<$1.Money>(10, _omitFieldNames ? '' : 'capAmount',
        subBuilder: $1.Money.$_createMessage)
    ..aInt64(11, _omitFieldNames ? '' : 'capCount')
    ..aE<PolicyMode>(12, _omitFieldNames ? '' : 'mode',
        enumValues: PolicyMode.values)
    ..aOM<$2.Struct>(13, _omitFieldNames ? '' : 'attributeFilter',
        subBuilder: $2.Struct.$_createMessage)
    ..pPM<ApproverTier>(14, _omitFieldNames ? '' : 'approverTiers',
        subBuilder: ApproverTier.$_createMessage)
    ..aOM<$0.Duration>(15, _omitFieldNames ? '' : 'approvalTtl',
        subBuilder: $0.Duration.$_createMessage)
    ..aOM<$3.Timestamp>(16, _omitFieldNames ? '' : 'effectiveFrom',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$3.Timestamp>(17, _omitFieldNames ? '' : 'effectiveTo',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOS(18, _omitFieldNames ? '' : 'notes')
    ..aI(19, _omitFieldNames ? '' : 'version')
    ..aOM<$3.Timestamp>(20, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$3.Timestamp>(21, _omitFieldNames ? '' : 'modifiedAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyObject copyWith(void Function(PolicyObject) updates) =>
      super.copyWith((message) => updates(message as PolicyObject))
          as PolicyObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PolicyObject() / PolicyObject.new instead')
  static PolicyObject create() => PolicyObject._();
  static $pb.GeneratedMessage $_createMessage() => PolicyObject._();
  @$core.override
  PolicyObject createEmptyInstance() => PolicyObject._();
  @$core.pragma('dart2js:noInline')
  static PolicyObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyObject>(
          PolicyObject.$_createMessage);
  static PolicyObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  PolicyScope get scope => $_getN(2);
  @$pb.TagNumber(3)
  set scope(PolicyScope value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasScope() => $_has(2);
  @$pb.TagNumber(3)
  void clearScope() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get orgUnitId => $_getSZ(3);
  @$pb.TagNumber(4)
  set orgUnitId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrgUnitId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrgUnitId() => $_clearField(4);

  @$pb.TagNumber(5)
  LimitAction get action => $_getN(4);
  @$pb.TagNumber(5)
  set action(LimitAction value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAction() => $_has(4);
  @$pb.TagNumber(5)
  void clearAction() => $_clearField(5);

  @$pb.TagNumber(6)
  SubjectType get subjectType => $_getN(5);
  @$pb.TagNumber(6)
  set subjectType(SubjectType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSubjectType() => $_has(5);
  @$pb.TagNumber(6)
  void clearSubjectType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get currencyCode => $_getSZ(6);
  @$pb.TagNumber(7)
  set currencyCode($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrencyCode() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrencyCode() => $_clearField(7);

  @$pb.TagNumber(8)
  LimitKind get limitKind => $_getN(7);
  @$pb.TagNumber(8)
  set limitKind(LimitKind value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasLimitKind() => $_has(7);
  @$pb.TagNumber(8)
  void clearLimitKind() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Duration get window => $_getN(8);
  @$pb.TagNumber(9)
  set window($0.Duration value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasWindow() => $_has(8);
  @$pb.TagNumber(9)
  void clearWindow() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Duration ensureWindow() => $_ensure(8);

  @$pb.TagNumber(10)
  $1.Money get capAmount => $_getN(9);
  @$pb.TagNumber(10)
  set capAmount($1.Money value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCapAmount() => $_has(9);
  @$pb.TagNumber(10)
  void clearCapAmount() => $_clearField(10);
  @$pb.TagNumber(10)
  $1.Money ensureCapAmount() => $_ensure(9);

  @$pb.TagNumber(11)
  $fixnum.Int64 get capCount => $_getI64(10);
  @$pb.TagNumber(11)
  set capCount($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCapCount() => $_has(10);
  @$pb.TagNumber(11)
  void clearCapCount() => $_clearField(11);

  @$pb.TagNumber(12)
  PolicyMode get mode => $_getN(11);
  @$pb.TagNumber(12)
  set mode(PolicyMode value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasMode() => $_has(11);
  @$pb.TagNumber(12)
  void clearMode() => $_clearField(12);

  @$pb.TagNumber(13)
  $2.Struct get attributeFilter => $_getN(12);
  @$pb.TagNumber(13)
  set attributeFilter($2.Struct value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasAttributeFilter() => $_has(12);
  @$pb.TagNumber(13)
  void clearAttributeFilter() => $_clearField(13);
  @$pb.TagNumber(13)
  $2.Struct ensureAttributeFilter() => $_ensure(12);

  @$pb.TagNumber(14)
  $pb.PbList<ApproverTier> get approverTiers => $_getList(13);

  @$pb.TagNumber(15)
  $0.Duration get approvalTtl => $_getN(14);
  @$pb.TagNumber(15)
  set approvalTtl($0.Duration value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasApprovalTtl() => $_has(14);
  @$pb.TagNumber(15)
  void clearApprovalTtl() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Duration ensureApprovalTtl() => $_ensure(14);

  @$pb.TagNumber(16)
  $3.Timestamp get effectiveFrom => $_getN(15);
  @$pb.TagNumber(16)
  set effectiveFrom($3.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasEffectiveFrom() => $_has(15);
  @$pb.TagNumber(16)
  void clearEffectiveFrom() => $_clearField(16);
  @$pb.TagNumber(16)
  $3.Timestamp ensureEffectiveFrom() => $_ensure(15);

  @$pb.TagNumber(17)
  $3.Timestamp get effectiveTo => $_getN(16);
  @$pb.TagNumber(17)
  set effectiveTo($3.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasEffectiveTo() => $_has(16);
  @$pb.TagNumber(17)
  void clearEffectiveTo() => $_clearField(17);
  @$pb.TagNumber(17)
  $3.Timestamp ensureEffectiveTo() => $_ensure(16);

  @$pb.TagNumber(18)
  $core.String get notes => $_getSZ(17);
  @$pb.TagNumber(18)
  set notes($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasNotes() => $_has(17);
  @$pb.TagNumber(18)
  void clearNotes() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get version => $_getIZ(18);
  @$pb.TagNumber(19)
  set version($core.int value) => $_setSignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasVersion() => $_has(18);
  @$pb.TagNumber(19)
  void clearVersion() => $_clearField(19);

  @$pb.TagNumber(20)
  $3.Timestamp get createdAt => $_getN(19);
  @$pb.TagNumber(20)
  set createdAt($3.Timestamp value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasCreatedAt() => $_has(19);
  @$pb.TagNumber(20)
  void clearCreatedAt() => $_clearField(20);
  @$pb.TagNumber(20)
  $3.Timestamp ensureCreatedAt() => $_ensure(19);

  @$pb.TagNumber(21)
  $3.Timestamp get modifiedAt => $_getN(20);
  @$pb.TagNumber(21)
  set modifiedAt($3.Timestamp value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasModifiedAt() => $_has(20);
  @$pb.TagNumber(21)
  void clearModifiedAt() => $_clearField(21);
  @$pb.TagNumber(21)
  $3.Timestamp ensureModifiedAt() => $_ensure(20);
}

class LimitIntent extends $pb.GeneratedMessage {
  factory LimitIntent({
    LimitAction? action,
    $core.String? tenantId,
    $core.String? orgUnitId,
    $1.Money? amount,
    $core.Iterable<SubjectRef>? subjects,
    $core.String? makerId,
  }) {
    final result = LimitIntent._();
    if (action != null) result.action = action;
    if (tenantId != null) result.tenantId = tenantId;
    if (orgUnitId != null) result.orgUnitId = orgUnitId;
    if (amount != null) result.amount = amount;
    if (subjects != null) result.subjects.addAll(subjects);
    if (makerId != null) result.makerId = makerId;
    return result;
  }

  LimitIntent._();

  factory LimitIntent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitIntent()..mergeFromBuffer(data, registry);
  factory LimitIntent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitIntent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LimitIntent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: LimitIntent.$_createMessage)
    ..aE<LimitAction>(1, _omitFieldNames ? '' : 'action',
        enumValues: LimitAction.values)
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'orgUnitId')
    ..aOM<$1.Money>(4, _omitFieldNames ? '' : 'amount',
        subBuilder: $1.Money.$_createMessage)
    ..pPM<SubjectRef>(5, _omitFieldNames ? '' : 'subjects',
        subBuilder: SubjectRef.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'makerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitIntent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitIntent copyWith(void Function(LimitIntent) updates) =>
      super.copyWith((message) => updates(message as LimitIntent))
          as LimitIntent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LimitIntent() / LimitIntent.new instead')
  static LimitIntent create() => LimitIntent._();
  static $pb.GeneratedMessage $_createMessage() => LimitIntent._();
  @$core.override
  LimitIntent createEmptyInstance() => LimitIntent._();
  @$core.pragma('dart2js:noInline')
  static LimitIntent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LimitIntent>(
          LimitIntent.$_createMessage);
  static LimitIntent? _defaultInstance;

  @$pb.TagNumber(1)
  LimitAction get action => $_getN(0);
  @$pb.TagNumber(1)
  set action(LimitAction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAction() => $_has(0);
  @$pb.TagNumber(1)
  void clearAction() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get orgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set orgUnitId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrgUnitId() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Money get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($1.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Money ensureAmount() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<SubjectRef> get subjects => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get makerId => $_getSZ(5);
  @$pb.TagNumber(6)
  set makerId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMakerId() => $_has(5);
  @$pb.TagNumber(6)
  void clearMakerId() => $_clearField(6);
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
    $1.Money? currentUsage,
    $1.Money? capAmount,
    $fixnum.Int64? currentCount,
    $fixnum.Int64? capCount,
  }) {
    final result = PolicyVerdict._();
    if (policyId != null) result.policyId = policyId;
    if (policyVersion != null) result.policyVersion = policyVersion;
    if (matched != null) result.matched = matched;
    if (breached != null) result.breached = breached;
    if (wouldRequireApproval != null)
      result.wouldRequireApproval = wouldRequireApproval;
    if (mode != null) result.mode = mode;
    if (reason != null) result.reason = reason;
    if (currentUsage != null) result.currentUsage = currentUsage;
    if (capAmount != null) result.capAmount = capAmount;
    if (currentCount != null) result.currentCount = currentCount;
    if (capCount != null) result.capCount = capCount;
    return result;
  }

  PolicyVerdict._();

  factory PolicyVerdict.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyVerdict()..mergeFromBuffer(data, registry);
  factory PolicyVerdict.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyVerdict()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicyVerdict',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicyVerdict.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'policyId')
    ..aI(2, _omitFieldNames ? '' : 'policyVersion')
    ..aOB(3, _omitFieldNames ? '' : 'matched')
    ..aOB(4, _omitFieldNames ? '' : 'breached')
    ..aOB(5, _omitFieldNames ? '' : 'wouldRequireApproval')
    ..aE<PolicyMode>(6, _omitFieldNames ? '' : 'mode',
        enumValues: PolicyMode.values)
    ..aOS(7, _omitFieldNames ? '' : 'reason')
    ..aOM<$1.Money>(8, _omitFieldNames ? '' : 'currentUsage',
        subBuilder: $1.Money.$_createMessage)
    ..aOM<$1.Money>(9, _omitFieldNames ? '' : 'capAmount',
        subBuilder: $1.Money.$_createMessage)
    ..aInt64(10, _omitFieldNames ? '' : 'currentCount')
    ..aInt64(11, _omitFieldNames ? '' : 'capCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyVerdict clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyVerdict copyWith(void Function(PolicyVerdict) updates) =>
      super.copyWith((message) => updates(message as PolicyVerdict))
          as PolicyVerdict;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PolicyVerdict() / PolicyVerdict.new instead')
  static PolicyVerdict create() => PolicyVerdict._();
  static $pb.GeneratedMessage $_createMessage() => PolicyVerdict._();
  @$core.override
  PolicyVerdict createEmptyInstance() => PolicyVerdict._();
  @$core.pragma('dart2js:noInline')
  static PolicyVerdict getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyVerdict>(
          PolicyVerdict.$_createMessage);
  static PolicyVerdict? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get policyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set policyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPolicyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPolicyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get policyVersion => $_getIZ(1);
  @$pb.TagNumber(2)
  set policyVersion($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPolicyVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearPolicyVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get matched => $_getBF(2);
  @$pb.TagNumber(3)
  set matched($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMatched() => $_has(2);
  @$pb.TagNumber(3)
  void clearMatched() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get breached => $_getBF(3);
  @$pb.TagNumber(4)
  set breached($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBreached() => $_has(3);
  @$pb.TagNumber(4)
  void clearBreached() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get wouldRequireApproval => $_getBF(4);
  @$pb.TagNumber(5)
  set wouldRequireApproval($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWouldRequireApproval() => $_has(4);
  @$pb.TagNumber(5)
  void clearWouldRequireApproval() => $_clearField(5);

  @$pb.TagNumber(6)
  PolicyMode get mode => $_getN(5);
  @$pb.TagNumber(6)
  set mode(PolicyMode value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasMode() => $_has(5);
  @$pb.TagNumber(6)
  void clearMode() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get reason => $_getSZ(6);
  @$pb.TagNumber(7)
  set reason($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReason() => $_has(6);
  @$pb.TagNumber(7)
  void clearReason() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.Money get currentUsage => $_getN(7);
  @$pb.TagNumber(8)
  set currentUsage($1.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCurrentUsage() => $_has(7);
  @$pb.TagNumber(8)
  void clearCurrentUsage() => $_clearField(8);
  @$pb.TagNumber(8)
  $1.Money ensureCurrentUsage() => $_ensure(7);

  @$pb.TagNumber(9)
  $1.Money get capAmount => $_getN(8);
  @$pb.TagNumber(9)
  set capAmount($1.Money value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCapAmount() => $_has(8);
  @$pb.TagNumber(9)
  void clearCapAmount() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Money ensureCapAmount() => $_ensure(8);

  @$pb.TagNumber(10)
  $fixnum.Int64 get currentCount => $_getI64(9);
  @$pb.TagNumber(10)
  set currentCount($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCurrentCount() => $_has(9);
  @$pb.TagNumber(10)
  void clearCurrentCount() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get capCount => $_getI64(10);
  @$pb.TagNumber(11)
  set capCount($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCapCount() => $_has(10);
  @$pb.TagNumber(11)
  void clearCapCount() => $_clearField(11);
}

class PolicySaveRequest extends $pb.GeneratedMessage {
  factory PolicySaveRequest({
    PolicyObject? data,
  }) {
    final result = PolicySaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  PolicySaveRequest._();

  factory PolicySaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicySaveRequest()..mergeFromBuffer(data, registry);
  factory PolicySaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicySaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicySaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicySaveRequest.$_createMessage)
    ..aOM<PolicyObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PolicyObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicySaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicySaveRequest copyWith(void Function(PolicySaveRequest) updates) =>
      super.copyWith((message) => updates(message as PolicySaveRequest))
          as PolicySaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PolicySaveRequest() / PolicySaveRequest.new instead')
  static PolicySaveRequest create() => PolicySaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => PolicySaveRequest._();
  @$core.override
  PolicySaveRequest createEmptyInstance() => PolicySaveRequest._();
  @$core.pragma('dart2js:noInline')
  static PolicySaveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicySaveRequest>(
          PolicySaveRequest.$_createMessage);
  static PolicySaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PolicyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PolicyObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PolicyObject ensureData() => $_ensure(0);
}

class PolicySaveResponse extends $pb.GeneratedMessage {
  factory PolicySaveResponse({
    PolicyObject? data,
  }) {
    final result = PolicySaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  PolicySaveResponse._();

  factory PolicySaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicySaveResponse()..mergeFromBuffer(data, registry);
  factory PolicySaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicySaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicySaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicySaveResponse.$_createMessage)
    ..aOM<PolicyObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PolicyObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicySaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicySaveResponse copyWith(void Function(PolicySaveResponse) updates) =>
      super.copyWith((message) => updates(message as PolicySaveResponse))
          as PolicySaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PolicySaveResponse() / PolicySaveResponse.new instead')
  static PolicySaveResponse create() => PolicySaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => PolicySaveResponse._();
  @$core.override
  PolicySaveResponse createEmptyInstance() => PolicySaveResponse._();
  @$core.pragma('dart2js:noInline')
  static PolicySaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PolicySaveResponse>(
          PolicySaveResponse.$_createMessage);
  static PolicySaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PolicyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PolicyObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PolicyObject ensureData() => $_ensure(0);
}

class PolicyGetRequest extends $pb.GeneratedMessage {
  factory PolicyGetRequest({
    $core.String? id,
  }) {
    final result = PolicyGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  PolicyGetRequest._();

  factory PolicyGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyGetRequest()..mergeFromBuffer(data, registry);
  factory PolicyGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicyGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicyGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyGetRequest copyWith(void Function(PolicyGetRequest) updates) =>
      super.copyWith((message) => updates(message as PolicyGetRequest))
          as PolicyGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PolicyGetRequest() / PolicyGetRequest.new instead')
  static PolicyGetRequest create() => PolicyGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => PolicyGetRequest._();
  @$core.override
  PolicyGetRequest createEmptyInstance() => PolicyGetRequest._();
  @$core.pragma('dart2js:noInline')
  static PolicyGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyGetRequest>(
          PolicyGetRequest.$_createMessage);
  static PolicyGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class PolicyGetResponse extends $pb.GeneratedMessage {
  factory PolicyGetResponse({
    PolicyObject? data,
  }) {
    final result = PolicyGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  PolicyGetResponse._();

  factory PolicyGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyGetResponse()..mergeFromBuffer(data, registry);
  factory PolicyGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicyGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicyGetResponse.$_createMessage)
    ..aOM<PolicyObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PolicyObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyGetResponse copyWith(void Function(PolicyGetResponse) updates) =>
      super.copyWith((message) => updates(message as PolicyGetResponse))
          as PolicyGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PolicyGetResponse() / PolicyGetResponse.new instead')
  static PolicyGetResponse create() => PolicyGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => PolicyGetResponse._();
  @$core.override
  PolicyGetResponse createEmptyInstance() => PolicyGetResponse._();
  @$core.pragma('dart2js:noInline')
  static PolicyGetResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolicyGetResponse>(
          PolicyGetResponse.$_createMessage);
  static PolicyGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PolicyObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PolicyObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
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
    $4.PageCursor? cursor,
  }) {
    final result = PolicySearchRequest._();
    if (query != null) result.query = query;
    if (tenantId != null) result.tenantId = tenantId;
    if (orgUnitId != null) result.orgUnitId = orgUnitId;
    if (action != null) result.action = action;
    if (subjectType != null) result.subjectType = subjectType;
    if (mode != null) result.mode = mode;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  PolicySearchRequest._();

  factory PolicySearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicySearchRequest()..mergeFromBuffer(data, registry);
  factory PolicySearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicySearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicySearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicySearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'orgUnitId')
    ..aE<LimitAction>(4, _omitFieldNames ? '' : 'action',
        enumValues: LimitAction.values)
    ..aE<SubjectType>(5, _omitFieldNames ? '' : 'subjectType',
        enumValues: SubjectType.values)
    ..aE<PolicyMode>(6, _omitFieldNames ? '' : 'mode',
        enumValues: PolicyMode.values)
    ..aOM<$4.PageCursor>(7, _omitFieldNames ? '' : 'cursor',
        subBuilder: $4.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicySearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicySearchRequest copyWith(void Function(PolicySearchRequest) updates) =>
      super.copyWith((message) => updates(message as PolicySearchRequest))
          as PolicySearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use PolicySearchRequest() / PolicySearchRequest.new instead')
  static PolicySearchRequest create() => PolicySearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => PolicySearchRequest._();
  @$core.override
  PolicySearchRequest createEmptyInstance() => PolicySearchRequest._();
  @$core.pragma('dart2js:noInline')
  static PolicySearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PolicySearchRequest>(
          PolicySearchRequest.$_createMessage);
  static PolicySearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get orgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set orgUnitId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrgUnitId() => $_clearField(3);

  @$pb.TagNumber(4)
  LimitAction get action => $_getN(3);
  @$pb.TagNumber(4)
  set action(LimitAction value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAction() => $_has(3);
  @$pb.TagNumber(4)
  void clearAction() => $_clearField(4);

  @$pb.TagNumber(5)
  SubjectType get subjectType => $_getN(4);
  @$pb.TagNumber(5)
  set subjectType(SubjectType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSubjectType() => $_has(4);
  @$pb.TagNumber(5)
  void clearSubjectType() => $_clearField(5);

  @$pb.TagNumber(6)
  PolicyMode get mode => $_getN(5);
  @$pb.TagNumber(6)
  set mode(PolicyMode value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasMode() => $_has(5);
  @$pb.TagNumber(6)
  void clearMode() => $_clearField(6);

  @$pb.TagNumber(7)
  $4.PageCursor get cursor => $_getN(6);
  @$pb.TagNumber(7)
  set cursor($4.PageCursor value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCursor() => $_has(6);
  @$pb.TagNumber(7)
  void clearCursor() => $_clearField(7);
  @$pb.TagNumber(7)
  $4.PageCursor ensureCursor() => $_ensure(6);
}

class PolicySearchResponse extends $pb.GeneratedMessage {
  factory PolicySearchResponse({
    $core.Iterable<PolicyObject>? data,
    $4.PageCursor? nextCursor,
  }) {
    final result = PolicySearchResponse._();
    if (data != null) result.data.addAll(data);
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  PolicySearchResponse._();

  factory PolicySearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicySearchResponse()..mergeFromBuffer(data, registry);
  factory PolicySearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicySearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicySearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicySearchResponse.$_createMessage)
    ..pPM<PolicyObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PolicyObject.$_createMessage)
    ..aOM<$4.PageCursor>(2, _omitFieldNames ? '' : 'nextCursor',
        subBuilder: $4.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicySearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicySearchResponse copyWith(void Function(PolicySearchResponse) updates) =>
      super.copyWith((message) => updates(message as PolicySearchResponse))
          as PolicySearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PolicySearchResponse() / PolicySearchResponse.new instead')
  static PolicySearchResponse create() => PolicySearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => PolicySearchResponse._();
  @$core.override
  PolicySearchResponse createEmptyInstance() => PolicySearchResponse._();
  @$core.pragma('dart2js:noInline')
  static PolicySearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PolicySearchResponse>(
          PolicySearchResponse.$_createMessage);
  static PolicySearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PolicyObject> get data => $_getList(0);

  /// Cursor for the next page; unset when this is the last page.
  @$pb.TagNumber(2)
  $4.PageCursor get nextCursor => $_getN(1);
  @$pb.TagNumber(2)
  set nextCursor($4.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.PageCursor ensureNextCursor() => $_ensure(1);
}

class PolicyDeleteRequest extends $pb.GeneratedMessage {
  factory PolicyDeleteRequest({
    $core.String? id,
  }) {
    final result = PolicyDeleteRequest._();
    if (id != null) result.id = id;
    return result;
  }

  PolicyDeleteRequest._();

  factory PolicyDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyDeleteRequest()..mergeFromBuffer(data, registry);
  factory PolicyDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicyDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicyDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyDeleteRequest copyWith(void Function(PolicyDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as PolicyDeleteRequest))
          as PolicyDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use PolicyDeleteRequest() / PolicyDeleteRequest.new instead')
  static PolicyDeleteRequest create() => PolicyDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => PolicyDeleteRequest._();
  @$core.override
  PolicyDeleteRequest createEmptyInstance() => PolicyDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static PolicyDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PolicyDeleteRequest>(
          PolicyDeleteRequest.$_createMessage);
  static PolicyDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class PolicyDeleteResponse extends $pb.GeneratedMessage {
  factory PolicyDeleteResponse() => PolicyDeleteResponse._();

  PolicyDeleteResponse._();

  factory PolicyDeleteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyDeleteResponse()..mergeFromBuffer(data, registry);
  factory PolicyDeleteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyDeleteResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicyDeleteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicyDeleteResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyDeleteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyDeleteResponse copyWith(void Function(PolicyDeleteResponse) updates) =>
      super.copyWith((message) => updates(message as PolicyDeleteResponse))
          as PolicyDeleteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PolicyDeleteResponse() / PolicyDeleteResponse.new instead')
  static PolicyDeleteResponse create() => PolicyDeleteResponse._();
  static $pb.GeneratedMessage $_createMessage() => PolicyDeleteResponse._();
  @$core.override
  PolicyDeleteResponse createEmptyInstance() => PolicyDeleteResponse._();
  @$core.pragma('dart2js:noInline')
  static PolicyDeleteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PolicyDeleteResponse>(
          PolicyDeleteResponse.$_createMessage);
  static PolicyDeleteResponse? _defaultInstance;
}

/// PolicyVersionObject is one immutable snapshot from a policy's history.
class PolicyVersionObject extends $pb.GeneratedMessage {
  factory PolicyVersionObject({
    $core.String? policyId,
    $core.int? version,
    PolicyObject? snapshot,
    $3.Timestamp? createdAt,
  }) {
    final result = PolicyVersionObject._();
    if (policyId != null) result.policyId = policyId;
    if (version != null) result.version = version;
    if (snapshot != null) result.snapshot = snapshot;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  PolicyVersionObject._();

  factory PolicyVersionObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyVersionObject()..mergeFromBuffer(data, registry);
  factory PolicyVersionObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyVersionObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicyVersionObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicyVersionObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'policyId')
    ..aI(2, _omitFieldNames ? '' : 'version')
    ..aOM<PolicyObject>(3, _omitFieldNames ? '' : 'snapshot',
        subBuilder: PolicyObject.$_createMessage)
    ..aOM<$3.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyVersionObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyVersionObject copyWith(void Function(PolicyVersionObject) updates) =>
      super.copyWith((message) => updates(message as PolicyVersionObject))
          as PolicyVersionObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use PolicyVersionObject() / PolicyVersionObject.new instead')
  static PolicyVersionObject create() => PolicyVersionObject._();
  static $pb.GeneratedMessage $_createMessage() => PolicyVersionObject._();
  @$core.override
  PolicyVersionObject createEmptyInstance() => PolicyVersionObject._();
  @$core.pragma('dart2js:noInline')
  static PolicyVersionObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PolicyVersionObject>(
          PolicyVersionObject.$_createMessage);
  static PolicyVersionObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get policyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set policyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPolicyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPolicyId() => $_clearField(1);

  /// Monotonic per-policy snapshot number, 1 for the first save.
  @$pb.TagNumber(2)
  $core.int get version => $_getIZ(1);
  @$pb.TagNumber(2)
  set version($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  PolicyObject get snapshot => $_getN(2);
  @$pb.TagNumber(3)
  set snapshot(PolicyObject value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSnapshot() => $_has(2);
  @$pb.TagNumber(3)
  void clearSnapshot() => $_clearField(3);
  @$pb.TagNumber(3)
  PolicyObject ensureSnapshot() => $_ensure(2);

  @$pb.TagNumber(4)
  $3.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($3.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.Timestamp ensureCreatedAt() => $_ensure(3);
}

class PolicyHistoryRequest extends $pb.GeneratedMessage {
  factory PolicyHistoryRequest({
    $core.String? policyId,
    $4.PageCursor? cursor,
  }) {
    final result = PolicyHistoryRequest._();
    if (policyId != null) result.policyId = policyId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  PolicyHistoryRequest._();

  factory PolicyHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyHistoryRequest()..mergeFromBuffer(data, registry);
  factory PolicyHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyHistoryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicyHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicyHistoryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'policyId')
    ..aOM<$4.PageCursor>(2, _omitFieldNames ? '' : 'cursor',
        subBuilder: $4.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyHistoryRequest copyWith(void Function(PolicyHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as PolicyHistoryRequest))
          as PolicyHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PolicyHistoryRequest() / PolicyHistoryRequest.new instead')
  static PolicyHistoryRequest create() => PolicyHistoryRequest._();
  static $pb.GeneratedMessage $_createMessage() => PolicyHistoryRequest._();
  @$core.override
  PolicyHistoryRequest createEmptyInstance() => PolicyHistoryRequest._();
  @$core.pragma('dart2js:noInline')
  static PolicyHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PolicyHistoryRequest>(
          PolicyHistoryRequest.$_createMessage);
  static PolicyHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get policyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set policyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPolicyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPolicyId() => $_clearField(1);

  /// cursor.page carries the last version number seen; cursor.limit the page size.
  @$pb.TagNumber(2)
  $4.PageCursor get cursor => $_getN(1);
  @$pb.TagNumber(2)
  set cursor($4.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.PageCursor ensureCursor() => $_ensure(1);
}

class PolicyHistoryResponse extends $pb.GeneratedMessage {
  factory PolicyHistoryResponse({
    $core.Iterable<PolicyVersionObject>? data,
    $4.PageCursor? nextCursor,
  }) {
    final result = PolicyHistoryResponse._();
    if (data != null) result.data.addAll(data);
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  PolicyHistoryResponse._();

  factory PolicyHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyHistoryResponse()..mergeFromBuffer(data, registry);
  factory PolicyHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PolicyHistoryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolicyHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: PolicyHistoryResponse.$_createMessage)
    ..pPM<PolicyVersionObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PolicyVersionObject.$_createMessage)
    ..aOM<$4.PageCursor>(2, _omitFieldNames ? '' : 'nextCursor',
        subBuilder: $4.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolicyHistoryResponse copyWith(
          void Function(PolicyHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as PolicyHistoryResponse))
          as PolicyHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PolicyHistoryResponse() / PolicyHistoryResponse.new instead')
  static PolicyHistoryResponse create() => PolicyHistoryResponse._();
  static $pb.GeneratedMessage $_createMessage() => PolicyHistoryResponse._();
  @$core.override
  PolicyHistoryResponse createEmptyInstance() => PolicyHistoryResponse._();
  @$core.pragma('dart2js:noInline')
  static PolicyHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PolicyHistoryResponse>(
          PolicyHistoryResponse.$_createMessage);
  static PolicyHistoryResponse? _defaultInstance;

  /// Newest first.
  @$pb.TagNumber(1)
  $pb.PbList<PolicyVersionObject> get data => $_getList(0);

  /// Cursor for the next page; unset when this is the last page.
  @$pb.TagNumber(2)
  $4.PageCursor get nextCursor => $_getN(1);
  @$pb.TagNumber(2)
  set nextCursor($4.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.PageCursor ensureNextCursor() => $_ensure(1);
}

class ApprovalDecisionObject extends $pb.GeneratedMessage {
  factory ApprovalDecisionObject({
    $core.String? approverId,
    $core.String? decision,
    $core.String? note,
    $3.Timestamp? decidedAt,
  }) {
    final result = ApprovalDecisionObject._();
    if (approverId != null) result.approverId = approverId;
    if (decision != null) result.decision = decision;
    if (note != null) result.note = note;
    if (decidedAt != null) result.decidedAt = decidedAt;
    return result;
  }

  ApprovalDecisionObject._();

  factory ApprovalDecisionObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalDecisionObject()..mergeFromBuffer(data, registry);
  factory ApprovalDecisionObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalDecisionObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApprovalDecisionObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ApprovalDecisionObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'approverId')
    ..aOS(2, _omitFieldNames ? '' : 'decision')
    ..aOS(3, _omitFieldNames ? '' : 'note')
    ..aOM<$3.Timestamp>(4, _omitFieldNames ? '' : 'decidedAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalDecisionObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalDecisionObject copyWith(
          void Function(ApprovalDecisionObject) updates) =>
      super.copyWith((message) => updates(message as ApprovalDecisionObject))
          as ApprovalDecisionObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ApprovalDecisionObject() / ApprovalDecisionObject.new instead')
  static ApprovalDecisionObject create() => ApprovalDecisionObject._();
  static $pb.GeneratedMessage $_createMessage() => ApprovalDecisionObject._();
  @$core.override
  ApprovalDecisionObject createEmptyInstance() => ApprovalDecisionObject._();
  @$core.pragma('dart2js:noInline')
  static ApprovalDecisionObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApprovalDecisionObject>(
          ApprovalDecisionObject.$_createMessage);
  static ApprovalDecisionObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get approverId => $_getSZ(0);
  @$pb.TagNumber(1)
  set approverId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasApproverId() => $_has(0);
  @$pb.TagNumber(1)
  void clearApproverId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get decision => $_getSZ(1);
  @$pb.TagNumber(2)
  set decision($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDecision() => $_has(1);
  @$pb.TagNumber(2)
  void clearDecision() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get note => $_getSZ(2);
  @$pb.TagNumber(3)
  set note($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNote() => $_has(2);
  @$pb.TagNumber(3)
  void clearNote() => $_clearField(3);

  @$pb.TagNumber(4)
  $3.Timestamp get decidedAt => $_getN(3);
  @$pb.TagNumber(4)
  set decidedAt($3.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDecidedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearDecidedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.Timestamp ensureDecidedAt() => $_ensure(3);
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
    $1.Money? amount,
    $core.String? requiredRole,
    $core.int? requiredCount,
    $core.String? makerId,
    ApprovalStatus? status,
    $3.Timestamp? submittedAt,
    $3.Timestamp? expiresAt,
    $3.Timestamp? decidedAt,
    $core.Iterable<ApprovalDecisionObject>? decisions,
  }) {
    final result = ApprovalRequestObject._();
    if (id != null) result.id = id;
    if (reservationId != null) result.reservationId = reservationId;
    if (tenantId != null) result.tenantId = tenantId;
    if (orgUnitId != null) result.orgUnitId = orgUnitId;
    if (triggeringPolicyId != null)
      result.triggeringPolicyId = triggeringPolicyId;
    if (policyVersion != null) result.policyVersion = policyVersion;
    if (action != null) result.action = action;
    if (amount != null) result.amount = amount;
    if (requiredRole != null) result.requiredRole = requiredRole;
    if (requiredCount != null) result.requiredCount = requiredCount;
    if (makerId != null) result.makerId = makerId;
    if (status != null) result.status = status;
    if (submittedAt != null) result.submittedAt = submittedAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (decidedAt != null) result.decidedAt = decidedAt;
    if (decisions != null) result.decisions.addAll(decisions);
    return result;
  }

  ApprovalRequestObject._();

  factory ApprovalRequestObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestObject()..mergeFromBuffer(data, registry);
  factory ApprovalRequestObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApprovalRequestObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ApprovalRequestObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reservationId')
    ..aOS(3, _omitFieldNames ? '' : 'tenantId')
    ..aOS(4, _omitFieldNames ? '' : 'orgUnitId')
    ..aOS(5, _omitFieldNames ? '' : 'triggeringPolicyId')
    ..aI(6, _omitFieldNames ? '' : 'policyVersion')
    ..aE<LimitAction>(7, _omitFieldNames ? '' : 'action',
        enumValues: LimitAction.values)
    ..aOM<$1.Money>(8, _omitFieldNames ? '' : 'amount',
        subBuilder: $1.Money.$_createMessage)
    ..aOS(9, _omitFieldNames ? '' : 'requiredRole')
    ..aI(10, _omitFieldNames ? '' : 'requiredCount')
    ..aOS(11, _omitFieldNames ? '' : 'makerId')
    ..aE<ApprovalStatus>(12, _omitFieldNames ? '' : 'status',
        enumValues: ApprovalStatus.values)
    ..aOM<$3.Timestamp>(13, _omitFieldNames ? '' : 'submittedAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$3.Timestamp>(14, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$3.Timestamp>(15, _omitFieldNames ? '' : 'decidedAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..pPM<ApprovalDecisionObject>(16, _omitFieldNames ? '' : 'decisions',
        subBuilder: ApprovalDecisionObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestObject copyWith(
          void Function(ApprovalRequestObject) updates) =>
      super.copyWith((message) => updates(message as ApprovalRequestObject))
          as ApprovalRequestObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ApprovalRequestObject() / ApprovalRequestObject.new instead')
  static ApprovalRequestObject create() => ApprovalRequestObject._();
  static $pb.GeneratedMessage $_createMessage() => ApprovalRequestObject._();
  @$core.override
  ApprovalRequestObject createEmptyInstance() => ApprovalRequestObject._();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApprovalRequestObject>(
          ApprovalRequestObject.$_createMessage);
  static ApprovalRequestObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reservationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set reservationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReservationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReservationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tenantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set tenantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get orgUnitId => $_getSZ(3);
  @$pb.TagNumber(4)
  set orgUnitId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrgUnitId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrgUnitId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get triggeringPolicyId => $_getSZ(4);
  @$pb.TagNumber(5)
  set triggeringPolicyId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTriggeringPolicyId() => $_has(4);
  @$pb.TagNumber(5)
  void clearTriggeringPolicyId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get policyVersion => $_getIZ(5);
  @$pb.TagNumber(6)
  set policyVersion($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPolicyVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearPolicyVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  LimitAction get action => $_getN(6);
  @$pb.TagNumber(7)
  set action(LimitAction value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasAction() => $_has(6);
  @$pb.TagNumber(7)
  void clearAction() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.Money get amount => $_getN(7);
  @$pb.TagNumber(8)
  set amount($1.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasAmount() => $_has(7);
  @$pb.TagNumber(8)
  void clearAmount() => $_clearField(8);
  @$pb.TagNumber(8)
  $1.Money ensureAmount() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.String get requiredRole => $_getSZ(8);
  @$pb.TagNumber(9)
  set requiredRole($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRequiredRole() => $_has(8);
  @$pb.TagNumber(9)
  void clearRequiredRole() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get requiredCount => $_getIZ(9);
  @$pb.TagNumber(10)
  set requiredCount($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRequiredCount() => $_has(9);
  @$pb.TagNumber(10)
  void clearRequiredCount() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get makerId => $_getSZ(10);
  @$pb.TagNumber(11)
  set makerId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasMakerId() => $_has(10);
  @$pb.TagNumber(11)
  void clearMakerId() => $_clearField(11);

  @$pb.TagNumber(12)
  ApprovalStatus get status => $_getN(11);
  @$pb.TagNumber(12)
  set status(ApprovalStatus value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => $_clearField(12);

  @$pb.TagNumber(13)
  $3.Timestamp get submittedAt => $_getN(12);
  @$pb.TagNumber(13)
  set submittedAt($3.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasSubmittedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearSubmittedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $3.Timestamp ensureSubmittedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $3.Timestamp get expiresAt => $_getN(13);
  @$pb.TagNumber(14)
  set expiresAt($3.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasExpiresAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearExpiresAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $3.Timestamp ensureExpiresAt() => $_ensure(13);

  @$pb.TagNumber(15)
  $3.Timestamp get decidedAt => $_getN(14);
  @$pb.TagNumber(15)
  set decidedAt($3.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasDecidedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearDecidedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $3.Timestamp ensureDecidedAt() => $_ensure(14);

  @$pb.TagNumber(16)
  $pb.PbList<ApprovalDecisionObject> get decisions => $_getList(15);
}

class ApprovalRequestListRequest extends $pb.GeneratedMessage {
  factory ApprovalRequestListRequest({
    $core.String? tenantId,
    ApprovalStatus? status,
    $core.String? requiredRole,
    $4.PageCursor? cursor,
  }) {
    final result = ApprovalRequestListRequest._();
    if (tenantId != null) result.tenantId = tenantId;
    if (status != null) result.status = status;
    if (requiredRole != null) result.requiredRole = requiredRole;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  ApprovalRequestListRequest._();

  factory ApprovalRequestListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestListRequest()..mergeFromBuffer(data, registry);
  factory ApprovalRequestListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApprovalRequestListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ApprovalRequestListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aE<ApprovalStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: ApprovalStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'requiredRole')
    ..aOM<$4.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $4.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestListRequest copyWith(
          void Function(ApprovalRequestListRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ApprovalRequestListRequest))
          as ApprovalRequestListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ApprovalRequestListRequest() / ApprovalRequestListRequest.new instead')
  static ApprovalRequestListRequest create() => ApprovalRequestListRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ApprovalRequestListRequest._();
  @$core.override
  ApprovalRequestListRequest createEmptyInstance() =>
      ApprovalRequestListRequest._();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApprovalRequestListRequest>(
          ApprovalRequestListRequest.$_createMessage);
  static ApprovalRequestListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  @$pb.TagNumber(2)
  ApprovalStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(ApprovalStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get requiredRole => $_getSZ(2);
  @$pb.TagNumber(3)
  set requiredRole($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequiredRole() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequiredRole() => $_clearField(3);

  @$pb.TagNumber(4)
  $4.PageCursor get cursor => $_getN(3);
  @$pb.TagNumber(4)
  set cursor($4.PageCursor value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursor() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.PageCursor ensureCursor() => $_ensure(3);
}

class ApprovalRequestListResponse extends $pb.GeneratedMessage {
  factory ApprovalRequestListResponse({
    $core.Iterable<ApprovalRequestObject>? data,
    $4.PageCursor? nextCursor,
  }) {
    final result = ApprovalRequestListResponse._();
    if (data != null) result.data.addAll(data);
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  ApprovalRequestListResponse._();

  factory ApprovalRequestListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestListResponse()..mergeFromBuffer(data, registry);
  factory ApprovalRequestListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestListResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApprovalRequestListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ApprovalRequestListResponse.$_createMessage)
    ..pPM<ApprovalRequestObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ApprovalRequestObject.$_createMessage)
    ..aOM<$4.PageCursor>(2, _omitFieldNames ? '' : 'nextCursor',
        subBuilder: $4.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestListResponse copyWith(
          void Function(ApprovalRequestListResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ApprovalRequestListResponse))
          as ApprovalRequestListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ApprovalRequestListResponse() / ApprovalRequestListResponse.new instead')
  static ApprovalRequestListResponse create() =>
      ApprovalRequestListResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ApprovalRequestListResponse._();
  @$core.override
  ApprovalRequestListResponse createEmptyInstance() =>
      ApprovalRequestListResponse._();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApprovalRequestListResponse>(
          ApprovalRequestListResponse.$_createMessage);
  static ApprovalRequestListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ApprovalRequestObject> get data => $_getList(0);

  /// Cursor for the next page; unset when this is the last page.
  @$pb.TagNumber(2)
  $4.PageCursor get nextCursor => $_getN(1);
  @$pb.TagNumber(2)
  set nextCursor($4.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.PageCursor ensureNextCursor() => $_ensure(1);
}

class ApprovalRequestGetRequest extends $pb.GeneratedMessage {
  factory ApprovalRequestGetRequest({
    $core.String? id,
  }) {
    final result = ApprovalRequestGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  ApprovalRequestGetRequest._();

  factory ApprovalRequestGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestGetRequest()..mergeFromBuffer(data, registry);
  factory ApprovalRequestGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApprovalRequestGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ApprovalRequestGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestGetRequest copyWith(
          void Function(ApprovalRequestGetRequest) updates) =>
      super.copyWith((message) => updates(message as ApprovalRequestGetRequest))
          as ApprovalRequestGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ApprovalRequestGetRequest() / ApprovalRequestGetRequest.new instead')
  static ApprovalRequestGetRequest create() => ApprovalRequestGetRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ApprovalRequestGetRequest._();
  @$core.override
  ApprovalRequestGetRequest createEmptyInstance() =>
      ApprovalRequestGetRequest._();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApprovalRequestGetRequest>(
          ApprovalRequestGetRequest.$_createMessage);
  static ApprovalRequestGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ApprovalRequestGetResponse extends $pb.GeneratedMessage {
  factory ApprovalRequestGetResponse({
    ApprovalRequestObject? data,
  }) {
    final result = ApprovalRequestGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ApprovalRequestGetResponse._();

  factory ApprovalRequestGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestGetResponse()..mergeFromBuffer(data, registry);
  factory ApprovalRequestGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApprovalRequestGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ApprovalRequestGetResponse.$_createMessage)
    ..aOM<ApprovalRequestObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ApprovalRequestObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestGetResponse copyWith(
          void Function(ApprovalRequestGetResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ApprovalRequestGetResponse))
          as ApprovalRequestGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ApprovalRequestGetResponse() / ApprovalRequestGetResponse.new instead')
  static ApprovalRequestGetResponse create() => ApprovalRequestGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ApprovalRequestGetResponse._();
  @$core.override
  ApprovalRequestGetResponse createEmptyInstance() =>
      ApprovalRequestGetResponse._();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApprovalRequestGetResponse>(
          ApprovalRequestGetResponse.$_createMessage);
  static ApprovalRequestGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ApprovalRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ApprovalRequestObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ApprovalRequestObject ensureData() => $_ensure(0);
}

class ApprovalRequestDecideRequest extends $pb.GeneratedMessage {
  factory ApprovalRequestDecideRequest({
    $core.String? id,
    $core.String? decision,
    $core.String? note,
  }) {
    final result = ApprovalRequestDecideRequest._();
    if (id != null) result.id = id;
    if (decision != null) result.decision = decision;
    if (note != null) result.note = note;
    return result;
  }

  ApprovalRequestDecideRequest._();

  factory ApprovalRequestDecideRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestDecideRequest()..mergeFromBuffer(data, registry);
  factory ApprovalRequestDecideRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestDecideRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApprovalRequestDecideRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ApprovalRequestDecideRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'decision')
    ..aOS(3, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestDecideRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestDecideRequest copyWith(
          void Function(ApprovalRequestDecideRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ApprovalRequestDecideRequest))
          as ApprovalRequestDecideRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ApprovalRequestDecideRequest() / ApprovalRequestDecideRequest.new instead')
  static ApprovalRequestDecideRequest create() =>
      ApprovalRequestDecideRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ApprovalRequestDecideRequest._();
  @$core.override
  ApprovalRequestDecideRequest createEmptyInstance() =>
      ApprovalRequestDecideRequest._();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestDecideRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApprovalRequestDecideRequest>(
          ApprovalRequestDecideRequest.$_createMessage);
  static ApprovalRequestDecideRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get decision => $_getSZ(1);
  @$pb.TagNumber(2)
  set decision($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDecision() => $_has(1);
  @$pb.TagNumber(2)
  void clearDecision() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get note => $_getSZ(2);
  @$pb.TagNumber(3)
  set note($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNote() => $_has(2);
  @$pb.TagNumber(3)
  void clearNote() => $_clearField(3);
}

class ApprovalRequestDecideResponse extends $pb.GeneratedMessage {
  factory ApprovalRequestDecideResponse({
    ApprovalRequestObject? data,
  }) {
    final result = ApprovalRequestDecideResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ApprovalRequestDecideResponse._();

  factory ApprovalRequestDecideResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestDecideResponse()..mergeFromBuffer(data, registry);
  factory ApprovalRequestDecideResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApprovalRequestDecideResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApprovalRequestDecideResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ApprovalRequestDecideResponse.$_createMessage)
    ..aOM<ApprovalRequestObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ApprovalRequestObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestDecideResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequestDecideResponse copyWith(
          void Function(ApprovalRequestDecideResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ApprovalRequestDecideResponse))
          as ApprovalRequestDecideResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ApprovalRequestDecideResponse() / ApprovalRequestDecideResponse.new instead')
  static ApprovalRequestDecideResponse create() =>
      ApprovalRequestDecideResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ApprovalRequestDecideResponse._();
  @$core.override
  ApprovalRequestDecideResponse createEmptyInstance() =>
      ApprovalRequestDecideResponse._();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequestDecideResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApprovalRequestDecideResponse>(
          ApprovalRequestDecideResponse.$_createMessage);
  static ApprovalRequestDecideResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ApprovalRequestObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ApprovalRequestObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
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
    $1.Money? amount,
    $3.Timestamp? committedAt,
    $3.Timestamp? reversedAt,
  }) {
    final result = LedgerEntryObject._();
    if (id != null) result.id = id;
    if (reservationId != null) result.reservationId = reservationId;
    if (tenantId != null) result.tenantId = tenantId;
    if (orgUnitId != null) result.orgUnitId = orgUnitId;
    if (action != null) result.action = action;
    if (subjectType != null) result.subjectType = subjectType;
    if (subjectId != null) result.subjectId = subjectId;
    if (amount != null) result.amount = amount;
    if (committedAt != null) result.committedAt = committedAt;
    if (reversedAt != null) result.reversedAt = reversedAt;
    return result;
  }

  LedgerEntryObject._();

  factory LedgerEntryObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LedgerEntryObject()..mergeFromBuffer(data, registry);
  factory LedgerEntryObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LedgerEntryObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LedgerEntryObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: LedgerEntryObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reservationId')
    ..aOS(3, _omitFieldNames ? '' : 'tenantId')
    ..aOS(4, _omitFieldNames ? '' : 'orgUnitId')
    ..aE<LimitAction>(5, _omitFieldNames ? '' : 'action',
        enumValues: LimitAction.values)
    ..aE<SubjectType>(6, _omitFieldNames ? '' : 'subjectType',
        enumValues: SubjectType.values)
    ..aOS(7, _omitFieldNames ? '' : 'subjectId')
    ..aOM<$1.Money>(8, _omitFieldNames ? '' : 'amount',
        subBuilder: $1.Money.$_createMessage)
    ..aOM<$3.Timestamp>(9, _omitFieldNames ? '' : 'committedAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$3.Timestamp>(10, _omitFieldNames ? '' : 'reversedAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerEntryObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerEntryObject copyWith(void Function(LedgerEntryObject) updates) =>
      super.copyWith((message) => updates(message as LedgerEntryObject))
          as LedgerEntryObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LedgerEntryObject() / LedgerEntryObject.new instead')
  static LedgerEntryObject create() => LedgerEntryObject._();
  static $pb.GeneratedMessage $_createMessage() => LedgerEntryObject._();
  @$core.override
  LedgerEntryObject createEmptyInstance() => LedgerEntryObject._();
  @$core.pragma('dart2js:noInline')
  static LedgerEntryObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LedgerEntryObject>(
          LedgerEntryObject.$_createMessage);
  static LedgerEntryObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reservationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set reservationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReservationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReservationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tenantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set tenantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get orgUnitId => $_getSZ(3);
  @$pb.TagNumber(4)
  set orgUnitId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrgUnitId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrgUnitId() => $_clearField(4);

  @$pb.TagNumber(5)
  LimitAction get action => $_getN(4);
  @$pb.TagNumber(5)
  set action(LimitAction value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAction() => $_has(4);
  @$pb.TagNumber(5)
  void clearAction() => $_clearField(5);

  @$pb.TagNumber(6)
  SubjectType get subjectType => $_getN(5);
  @$pb.TagNumber(6)
  set subjectType(SubjectType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSubjectType() => $_has(5);
  @$pb.TagNumber(6)
  void clearSubjectType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get subjectId => $_getSZ(6);
  @$pb.TagNumber(7)
  set subjectId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSubjectId() => $_has(6);
  @$pb.TagNumber(7)
  void clearSubjectId() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.Money get amount => $_getN(7);
  @$pb.TagNumber(8)
  set amount($1.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasAmount() => $_has(7);
  @$pb.TagNumber(8)
  void clearAmount() => $_clearField(8);
  @$pb.TagNumber(8)
  $1.Money ensureAmount() => $_ensure(7);

  @$pb.TagNumber(9)
  $3.Timestamp get committedAt => $_getN(8);
  @$pb.TagNumber(9)
  set committedAt($3.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCommittedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCommittedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $3.Timestamp ensureCommittedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $3.Timestamp get reversedAt => $_getN(9);
  @$pb.TagNumber(10)
  set reversedAt($3.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasReversedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearReversedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $3.Timestamp ensureReversedAt() => $_ensure(9);
}

class LedgerSearchRequest extends $pb.GeneratedMessage {
  factory LedgerSearchRequest({
    $core.String? tenantId,
    LimitAction? action,
    SubjectType? subjectType,
    $core.String? subjectId,
    $core.String? currencyCode,
    $3.Timestamp? from,
    $3.Timestamp? to,
    $4.PageCursor? cursor,
  }) {
    final result = LedgerSearchRequest._();
    if (tenantId != null) result.tenantId = tenantId;
    if (action != null) result.action = action;
    if (subjectType != null) result.subjectType = subjectType;
    if (subjectId != null) result.subjectId = subjectId;
    if (currencyCode != null) result.currencyCode = currencyCode;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  LedgerSearchRequest._();

  factory LedgerSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LedgerSearchRequest()..mergeFromBuffer(data, registry);
  factory LedgerSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LedgerSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LedgerSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: LedgerSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aE<LimitAction>(2, _omitFieldNames ? '' : 'action',
        enumValues: LimitAction.values)
    ..aE<SubjectType>(3, _omitFieldNames ? '' : 'subjectType',
        enumValues: SubjectType.values)
    ..aOS(4, _omitFieldNames ? '' : 'subjectId')
    ..aOS(5, _omitFieldNames ? '' : 'currencyCode')
    ..aOM<$3.Timestamp>(6, _omitFieldNames ? '' : 'from',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$3.Timestamp>(7, _omitFieldNames ? '' : 'to',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$4.PageCursor>(8, _omitFieldNames ? '' : 'cursor',
        subBuilder: $4.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerSearchRequest copyWith(void Function(LedgerSearchRequest) updates) =>
      super.copyWith((message) => updates(message as LedgerSearchRequest))
          as LedgerSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use LedgerSearchRequest() / LedgerSearchRequest.new instead')
  static LedgerSearchRequest create() => LedgerSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => LedgerSearchRequest._();
  @$core.override
  LedgerSearchRequest createEmptyInstance() => LedgerSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static LedgerSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LedgerSearchRequest>(
          LedgerSearchRequest.$_createMessage);
  static LedgerSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  @$pb.TagNumber(2)
  LimitAction get action => $_getN(1);
  @$pb.TagNumber(2)
  set action(LimitAction value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);

  @$pb.TagNumber(3)
  SubjectType get subjectType => $_getN(2);
  @$pb.TagNumber(3)
  set subjectType(SubjectType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSubjectType() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubjectType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get subjectId => $_getSZ(3);
  @$pb.TagNumber(4)
  set subjectId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSubjectId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubjectId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get currencyCode => $_getSZ(4);
  @$pb.TagNumber(5)
  set currencyCode($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCurrencyCode() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrencyCode() => $_clearField(5);

  @$pb.TagNumber(6)
  $3.Timestamp get from => $_getN(5);
  @$pb.TagNumber(6)
  set from($3.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasFrom() => $_has(5);
  @$pb.TagNumber(6)
  void clearFrom() => $_clearField(6);
  @$pb.TagNumber(6)
  $3.Timestamp ensureFrom() => $_ensure(5);

  @$pb.TagNumber(7)
  $3.Timestamp get to => $_getN(6);
  @$pb.TagNumber(7)
  set to($3.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTo() => $_has(6);
  @$pb.TagNumber(7)
  void clearTo() => $_clearField(7);
  @$pb.TagNumber(7)
  $3.Timestamp ensureTo() => $_ensure(6);

  @$pb.TagNumber(8)
  $4.PageCursor get cursor => $_getN(7);
  @$pb.TagNumber(8)
  set cursor($4.PageCursor value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCursor() => $_has(7);
  @$pb.TagNumber(8)
  void clearCursor() => $_clearField(8);
  @$pb.TagNumber(8)
  $4.PageCursor ensureCursor() => $_ensure(7);
}

class LedgerSearchResponse extends $pb.GeneratedMessage {
  factory LedgerSearchResponse({
    $core.Iterable<LedgerEntryObject>? data,
    $4.PageCursor? nextCursor,
  }) {
    final result = LedgerSearchResponse._();
    if (data != null) result.data.addAll(data);
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  LedgerSearchResponse._();

  factory LedgerSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LedgerSearchResponse()..mergeFromBuffer(data, registry);
  factory LedgerSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LedgerSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LedgerSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: LedgerSearchResponse.$_createMessage)
    ..pPM<LedgerEntryObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LedgerEntryObject.$_createMessage)
    ..aOM<$4.PageCursor>(2, _omitFieldNames ? '' : 'nextCursor',
        subBuilder: $4.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerSearchResponse copyWith(void Function(LedgerSearchResponse) updates) =>
      super.copyWith((message) => updates(message as LedgerSearchResponse))
          as LedgerSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LedgerSearchResponse() / LedgerSearchResponse.new instead')
  static LedgerSearchResponse create() => LedgerSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => LedgerSearchResponse._();
  @$core.override
  LedgerSearchResponse createEmptyInstance() => LedgerSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static LedgerSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LedgerSearchResponse>(
          LedgerSearchResponse.$_createMessage);
  static LedgerSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LedgerEntryObject> get data => $_getList(0);

  /// Cursor for the next page; unset when this is the last page.
  @$pb.TagNumber(2)
  $4.PageCursor get nextCursor => $_getN(1);
  @$pb.TagNumber(2)
  set nextCursor($4.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.PageCursor ensureNextCursor() => $_ensure(1);
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
    $2.Struct? metadata,
    $3.Timestamp? occurredAt,
  }) {
    final result = LimitsAuditEventObject._();
    if (id != null) result.id = id;
    if (entityType != null) result.entityType = entityType;
    if (entityId != null) result.entityId = entityId;
    if (action != null) result.action = action;
    if (actorId != null) result.actorId = actorId;
    if (actorType != null) result.actorType = actorType;
    if (reason != null) result.reason = reason;
    if (metadata != null) result.metadata = metadata;
    if (occurredAt != null) result.occurredAt = occurredAt;
    return result;
  }

  LimitsAuditEventObject._();

  factory LimitsAuditEventObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitsAuditEventObject()..mergeFromBuffer(data, registry);
  factory LimitsAuditEventObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitsAuditEventObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LimitsAuditEventObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: LimitsAuditEventObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'entityType')
    ..aOS(3, _omitFieldNames ? '' : 'entityId')
    ..aOS(4, _omitFieldNames ? '' : 'action')
    ..aOS(5, _omitFieldNames ? '' : 'actorId')
    ..aOS(6, _omitFieldNames ? '' : 'actorType')
    ..aOS(7, _omitFieldNames ? '' : 'reason')
    ..aOM<$2.Struct>(8, _omitFieldNames ? '' : 'metadata',
        subBuilder: $2.Struct.$_createMessage)
    ..aOM<$3.Timestamp>(9, _omitFieldNames ? '' : 'occurredAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitsAuditEventObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitsAuditEventObject copyWith(
          void Function(LimitsAuditEventObject) updates) =>
      super.copyWith((message) => updates(message as LimitsAuditEventObject))
          as LimitsAuditEventObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LimitsAuditEventObject() / LimitsAuditEventObject.new instead')
  static LimitsAuditEventObject create() => LimitsAuditEventObject._();
  static $pb.GeneratedMessage $_createMessage() => LimitsAuditEventObject._();
  @$core.override
  LimitsAuditEventObject createEmptyInstance() => LimitsAuditEventObject._();
  @$core.pragma('dart2js:noInline')
  static LimitsAuditEventObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LimitsAuditEventObject>(
          LimitsAuditEventObject.$_createMessage);
  static LimitsAuditEventObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get entityType => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntityType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get entityId => $_getSZ(2);
  @$pb.TagNumber(3)
  set entityId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEntityId() => $_has(2);
  @$pb.TagNumber(3)
  void clearEntityId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get action => $_getSZ(3);
  @$pb.TagNumber(4)
  set action($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAction() => $_has(3);
  @$pb.TagNumber(4)
  void clearAction() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get actorId => $_getSZ(4);
  @$pb.TagNumber(5)
  set actorId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasActorId() => $_has(4);
  @$pb.TagNumber(5)
  void clearActorId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get actorType => $_getSZ(5);
  @$pb.TagNumber(6)
  set actorType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActorType() => $_has(5);
  @$pb.TagNumber(6)
  void clearActorType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get reason => $_getSZ(6);
  @$pb.TagNumber(7)
  set reason($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReason() => $_has(6);
  @$pb.TagNumber(7)
  void clearReason() => $_clearField(7);

  @$pb.TagNumber(8)
  $2.Struct get metadata => $_getN(7);
  @$pb.TagNumber(8)
  set metadata($2.Struct value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasMetadata() => $_has(7);
  @$pb.TagNumber(8)
  void clearMetadata() => $_clearField(8);
  @$pb.TagNumber(8)
  $2.Struct ensureMetadata() => $_ensure(7);

  @$pb.TagNumber(9)
  $3.Timestamp get occurredAt => $_getN(8);
  @$pb.TagNumber(9)
  set occurredAt($3.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasOccurredAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearOccurredAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $3.Timestamp ensureOccurredAt() => $_ensure(8);
}

class LimitsAuditSearchRequest extends $pb.GeneratedMessage {
  factory LimitsAuditSearchRequest({
    $core.Iterable<$core.String>? actions,
    $core.String? entityType,
    $core.String? entityId,
    $core.String? actorId,
    $3.Timestamp? from,
    $3.Timestamp? to,
    $4.PageCursor? cursor,
    $core.String? tenantId,
  }) {
    final result = LimitsAuditSearchRequest._();
    if (actions != null) result.actions.addAll(actions);
    if (entityType != null) result.entityType = entityType;
    if (entityId != null) result.entityId = entityId;
    if (actorId != null) result.actorId = actorId;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (cursor != null) result.cursor = cursor;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  LimitsAuditSearchRequest._();

  factory LimitsAuditSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitsAuditSearchRequest()..mergeFromBuffer(data, registry);
  factory LimitsAuditSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitsAuditSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LimitsAuditSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: LimitsAuditSearchRequest.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'actions')
    ..aOS(2, _omitFieldNames ? '' : 'entityType')
    ..aOS(3, _omitFieldNames ? '' : 'entityId')
    ..aOS(4, _omitFieldNames ? '' : 'actorId')
    ..aOM<$3.Timestamp>(5, _omitFieldNames ? '' : 'from',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$3.Timestamp>(6, _omitFieldNames ? '' : 'to',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$4.PageCursor>(7, _omitFieldNames ? '' : 'cursor',
        subBuilder: $4.PageCursor.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitsAuditSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitsAuditSearchRequest copyWith(
          void Function(LimitsAuditSearchRequest) updates) =>
      super.copyWith((message) => updates(message as LimitsAuditSearchRequest))
          as LimitsAuditSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LimitsAuditSearchRequest() / LimitsAuditSearchRequest.new instead')
  static LimitsAuditSearchRequest create() => LimitsAuditSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => LimitsAuditSearchRequest._();
  @$core.override
  LimitsAuditSearchRequest createEmptyInstance() =>
      LimitsAuditSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static LimitsAuditSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LimitsAuditSearchRequest>(
          LimitsAuditSearchRequest.$_createMessage);
  static LimitsAuditSearchRequest? _defaultInstance;

  /// Filter on action verb. If empty, all "limits.*" verbs are returned.
  /// Each entry is matched exactly (e.g. "limits.breach.hard").
  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get actions => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get entityType => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntityType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get entityId => $_getSZ(2);
  @$pb.TagNumber(3)
  set entityId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEntityId() => $_has(2);
  @$pb.TagNumber(3)
  void clearEntityId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get actorId => $_getSZ(3);
  @$pb.TagNumber(4)
  set actorId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasActorId() => $_has(3);
  @$pb.TagNumber(4)
  void clearActorId() => $_clearField(4);

  @$pb.TagNumber(5)
  $3.Timestamp get from => $_getN(4);
  @$pb.TagNumber(5)
  set from($3.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasFrom() => $_has(4);
  @$pb.TagNumber(5)
  void clearFrom() => $_clearField(5);
  @$pb.TagNumber(5)
  $3.Timestamp ensureFrom() => $_ensure(4);

  @$pb.TagNumber(6)
  $3.Timestamp get to => $_getN(5);
  @$pb.TagNumber(6)
  set to($3.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasTo() => $_has(5);
  @$pb.TagNumber(6)
  void clearTo() => $_clearField(6);
  @$pb.TagNumber(6)
  $3.Timestamp ensureTo() => $_ensure(5);

  @$pb.TagNumber(7)
  $4.PageCursor get cursor => $_getN(6);
  @$pb.TagNumber(7)
  set cursor($4.PageCursor value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCursor() => $_has(6);
  @$pb.TagNumber(7)
  void clearCursor() => $_clearField(7);
  @$pb.TagNumber(7)
  $4.PageCursor ensureCursor() => $_ensure(6);

  /// Tenant whose audit feed is requested. Non-internal callers may only name
  /// their own tenant; the server derives it from claims when unset.
  @$pb.TagNumber(8)
  $core.String get tenantId => $_getSZ(7);
  @$pb.TagNumber(8)
  set tenantId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTenantId() => $_has(7);
  @$pb.TagNumber(8)
  void clearTenantId() => $_clearField(8);
}

class LimitsAuditSearchResponse extends $pb.GeneratedMessage {
  factory LimitsAuditSearchResponse({
    $core.Iterable<LimitsAuditEventObject>? data,
    $4.PageCursor? nextCursor,
  }) {
    final result = LimitsAuditSearchResponse._();
    if (data != null) result.data.addAll(data);
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  LimitsAuditSearchResponse._();

  factory LimitsAuditSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitsAuditSearchResponse()..mergeFromBuffer(data, registry);
  factory LimitsAuditSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitsAuditSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LimitsAuditSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: LimitsAuditSearchResponse.$_createMessage)
    ..pPM<LimitsAuditEventObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: LimitsAuditEventObject.$_createMessage)
    ..aOM<$4.PageCursor>(2, _omitFieldNames ? '' : 'nextCursor',
        subBuilder: $4.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitsAuditSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitsAuditSearchResponse copyWith(
          void Function(LimitsAuditSearchResponse) updates) =>
      super.copyWith((message) => updates(message as LimitsAuditSearchResponse))
          as LimitsAuditSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LimitsAuditSearchResponse() / LimitsAuditSearchResponse.new instead')
  static LimitsAuditSearchResponse create() => LimitsAuditSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      LimitsAuditSearchResponse._();
  @$core.override
  LimitsAuditSearchResponse createEmptyInstance() =>
      LimitsAuditSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static LimitsAuditSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LimitsAuditSearchResponse>(
          LimitsAuditSearchResponse.$_createMessage);
  static LimitsAuditSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LimitsAuditEventObject> get data => $_getList(0);

  /// Cursor for the next page; unset when this is the last page.
  @$pb.TagNumber(2)
  $4.PageCursor get nextCursor => $_getN(1);
  @$pb.TagNumber(2)
  set nextCursor($4.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.PageCursor ensureNextCursor() => $_ensure(1);
}

class CheckRequest extends $pb.GeneratedMessage {
  factory CheckRequest({
    LimitIntent? intent,
  }) {
    final result = CheckRequest._();
    if (intent != null) result.intent = intent;
    return result;
  }

  CheckRequest._();

  factory CheckRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckRequest()..mergeFromBuffer(data, registry);
  factory CheckRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: CheckRequest.$_createMessage)
    ..aOM<LimitIntent>(1, _omitFieldNames ? '' : 'intent',
        subBuilder: LimitIntent.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckRequest copyWith(void Function(CheckRequest) updates) =>
      super.copyWith((message) => updates(message as CheckRequest))
          as CheckRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckRequest() / CheckRequest.new instead')
  static CheckRequest create() => CheckRequest._();
  static $pb.GeneratedMessage $_createMessage() => CheckRequest._();
  @$core.override
  CheckRequest createEmptyInstance() => CheckRequest._();
  @$core.pragma('dart2js:noInline')
  static CheckRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckRequest>(
          CheckRequest.$_createMessage);
  static CheckRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LimitIntent get intent => $_getN(0);
  @$pb.TagNumber(1)
  set intent(LimitIntent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasIntent() => $_has(0);
  @$pb.TagNumber(1)
  void clearIntent() => $_clearField(1);
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
    final result = CheckResponse._();
    if (allowed != null) result.allowed = allowed;
    if (requiresApproval != null) result.requiresApproval = requiresApproval;
    if (requiredApprovers != null) result.requiredApprovers = requiredApprovers;
    if (requiredRole != null) result.requiredRole = requiredRole;
    if (verdicts != null) result.verdicts.addAll(verdicts);
    if (breachedPolicyIds != null)
      result.breachedPolicyIds.addAll(breachedPolicyIds);
    return result;
  }

  CheckResponse._();

  factory CheckResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckResponse()..mergeFromBuffer(data, registry);
  factory CheckResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: CheckResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'allowed')
    ..aOB(2, _omitFieldNames ? '' : 'requiresApproval')
    ..aI(3, _omitFieldNames ? '' : 'requiredApprovers')
    ..aOS(4, _omitFieldNames ? '' : 'requiredRole')
    ..pPM<PolicyVerdict>(5, _omitFieldNames ? '' : 'verdicts',
        subBuilder: PolicyVerdict.$_createMessage)
    ..pPS(6, _omitFieldNames ? '' : 'breachedPolicyIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckResponse copyWith(void Function(CheckResponse) updates) =>
      super.copyWith((message) => updates(message as CheckResponse))
          as CheckResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckResponse() / CheckResponse.new instead')
  static CheckResponse create() => CheckResponse._();
  static $pb.GeneratedMessage $_createMessage() => CheckResponse._();
  @$core.override
  CheckResponse createEmptyInstance() => CheckResponse._();
  @$core.pragma('dart2js:noInline')
  static CheckResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckResponse>(
          CheckResponse.$_createMessage);
  static CheckResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get allowed => $_getBF(0);
  @$pb.TagNumber(1)
  set allowed($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAllowed() => $_has(0);
  @$pb.TagNumber(1)
  void clearAllowed() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get requiresApproval => $_getBF(1);
  @$pb.TagNumber(2)
  set requiresApproval($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequiresApproval() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequiresApproval() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get requiredApprovers => $_getIZ(2);
  @$pb.TagNumber(3)
  set requiredApprovers($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequiredApprovers() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequiredApprovers() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get requiredRole => $_getSZ(3);
  @$pb.TagNumber(4)
  set requiredRole($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRequiredRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequiredRole() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<PolicyVerdict> get verdicts => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get breachedPolicyIds => $_getList(5);
}

class ReservationObject extends $pb.GeneratedMessage {
  factory ReservationObject({
    $core.String? id,
    $core.String? tenantId,
    $core.String? idempotencyKey,
    $core.String? orgUnitId,
    LimitAction? action,
    $1.Money? amount,
    $core.Iterable<SubjectRef>? subjects,
    $core.String? makerId,
    ReservationStatus? status,
    $core.bool? isShadow,
    $3.Timestamp? reservedAt,
    $3.Timestamp? ttlAt,
    $3.Timestamp? committedAt,
    $3.Timestamp? releasedAt,
    $core.String? reversesReservationId,
    $core.String? notes,
  }) {
    final result = ReservationObject._();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (orgUnitId != null) result.orgUnitId = orgUnitId;
    if (action != null) result.action = action;
    if (amount != null) result.amount = amount;
    if (subjects != null) result.subjects.addAll(subjects);
    if (makerId != null) result.makerId = makerId;
    if (status != null) result.status = status;
    if (isShadow != null) result.isShadow = isShadow;
    if (reservedAt != null) result.reservedAt = reservedAt;
    if (ttlAt != null) result.ttlAt = ttlAt;
    if (committedAt != null) result.committedAt = committedAt;
    if (releasedAt != null) result.releasedAt = releasedAt;
    if (reversesReservationId != null)
      result.reversesReservationId = reversesReservationId;
    if (notes != null) result.notes = notes;
    return result;
  }

  ReservationObject._();

  factory ReservationObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReservationObject()..mergeFromBuffer(data, registry);
  factory ReservationObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReservationObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReservationObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ReservationObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(4, _omitFieldNames ? '' : 'orgUnitId')
    ..aE<LimitAction>(5, _omitFieldNames ? '' : 'action',
        enumValues: LimitAction.values)
    ..aOM<$1.Money>(6, _omitFieldNames ? '' : 'amount',
        subBuilder: $1.Money.$_createMessage)
    ..pPM<SubjectRef>(7, _omitFieldNames ? '' : 'subjects',
        subBuilder: SubjectRef.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'makerId')
    ..aE<ReservationStatus>(9, _omitFieldNames ? '' : 'status',
        enumValues: ReservationStatus.values)
    ..aOB(10, _omitFieldNames ? '' : 'isShadow')
    ..aOM<$3.Timestamp>(11, _omitFieldNames ? '' : 'reservedAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$3.Timestamp>(12, _omitFieldNames ? '' : 'ttlAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$3.Timestamp>(13, _omitFieldNames ? '' : 'committedAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOM<$3.Timestamp>(14, _omitFieldNames ? '' : 'releasedAt',
        subBuilder: $3.Timestamp.$_createMessage)
    ..aOS(15, _omitFieldNames ? '' : 'reversesReservationId')
    ..aOS(16, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReservationObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReservationObject copyWith(void Function(ReservationObject) updates) =>
      super.copyWith((message) => updates(message as ReservationObject))
          as ReservationObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReservationObject() / ReservationObject.new instead')
  static ReservationObject create() => ReservationObject._();
  static $pb.GeneratedMessage $_createMessage() => ReservationObject._();
  @$core.override
  ReservationObject createEmptyInstance() => ReservationObject._();
  @$core.pragma('dart2js:noInline')
  static ReservationObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReservationObject>(
          ReservationObject.$_createMessage);
  static ReservationObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get idempotencyKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set idempotencyKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIdempotencyKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdempotencyKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get orgUnitId => $_getSZ(3);
  @$pb.TagNumber(4)
  set orgUnitId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrgUnitId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrgUnitId() => $_clearField(4);

  @$pb.TagNumber(5)
  LimitAction get action => $_getN(4);
  @$pb.TagNumber(5)
  set action(LimitAction value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAction() => $_has(4);
  @$pb.TagNumber(5)
  void clearAction() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.Money get amount => $_getN(5);
  @$pb.TagNumber(6)
  set amount($1.Money value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAmount() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmount() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.Money ensureAmount() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbList<SubjectRef> get subjects => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get makerId => $_getSZ(7);
  @$pb.TagNumber(8)
  set makerId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMakerId() => $_has(7);
  @$pb.TagNumber(8)
  void clearMakerId() => $_clearField(8);

  @$pb.TagNumber(9)
  ReservationStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(ReservationStatus value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isShadow => $_getBF(9);
  @$pb.TagNumber(10)
  set isShadow($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsShadow() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsShadow() => $_clearField(10);

  @$pb.TagNumber(11)
  $3.Timestamp get reservedAt => $_getN(10);
  @$pb.TagNumber(11)
  set reservedAt($3.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasReservedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearReservedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $3.Timestamp ensureReservedAt() => $_ensure(10);

  @$pb.TagNumber(12)
  $3.Timestamp get ttlAt => $_getN(11);
  @$pb.TagNumber(12)
  set ttlAt($3.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasTtlAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearTtlAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $3.Timestamp ensureTtlAt() => $_ensure(11);

  @$pb.TagNumber(13)
  $3.Timestamp get committedAt => $_getN(12);
  @$pb.TagNumber(13)
  set committedAt($3.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasCommittedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearCommittedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $3.Timestamp ensureCommittedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $3.Timestamp get releasedAt => $_getN(13);
  @$pb.TagNumber(14)
  set releasedAt($3.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasReleasedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearReleasedAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $3.Timestamp ensureReleasedAt() => $_ensure(13);

  /// Set on a reversal reservation: the committed reservation it reverses.
  @$pb.TagNumber(15)
  $core.String get reversesReservationId => $_getSZ(14);
  @$pb.TagNumber(15)
  set reversesReservationId($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasReversesReservationId() => $_has(14);
  @$pb.TagNumber(15)
  void clearReversesReservationId() => $_clearField(15);

  /// Free-text reason recorded on release/reversal.
  @$pb.TagNumber(16)
  $core.String get notes => $_getSZ(15);
  @$pb.TagNumber(16)
  set notes($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasNotes() => $_has(15);
  @$pb.TagNumber(16)
  void clearNotes() => $_clearField(16);
}

class ReserveRequest extends $pb.GeneratedMessage {
  factory ReserveRequest({
    LimitIntent? intent,
    $core.String? idempotencyKey,
    $0.Duration? ttl,
  }) {
    final result = ReserveRequest._();
    if (intent != null) result.intent = intent;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (ttl != null) result.ttl = ttl;
    return result;
  }

  ReserveRequest._();

  factory ReserveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveRequest()..mergeFromBuffer(data, registry);
  factory ReserveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReserveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ReserveRequest.$_createMessage)
    ..aOM<LimitIntent>(1, _omitFieldNames ? '' : 'intent',
        subBuilder: LimitIntent.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOM<$0.Duration>(3, _omitFieldNames ? '' : 'ttl',
        subBuilder: $0.Duration.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveRequest copyWith(void Function(ReserveRequest) updates) =>
      super.copyWith((message) => updates(message as ReserveRequest))
          as ReserveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReserveRequest() / ReserveRequest.new instead')
  static ReserveRequest create() => ReserveRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReserveRequest._();
  @$core.override
  ReserveRequest createEmptyInstance() => ReserveRequest._();
  @$core.pragma('dart2js:noInline')
  static ReserveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReserveRequest>(
          ReserveRequest.$_createMessage);
  static ReserveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LimitIntent get intent => $_getN(0);
  @$pb.TagNumber(1)
  set intent(LimitIntent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasIntent() => $_has(0);
  @$pb.TagNumber(1)
  void clearIntent() => $_clearField(1);
  @$pb.TagNumber(1)
  LimitIntent ensureIntent() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get idempotencyKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set idempotencyKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdempotencyKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdempotencyKey() => $_clearField(2);

  /// Requested hold duration. The server applies its default when unset and
  /// never honours more than one hour.
  @$pb.TagNumber(3)
  $0.Duration get ttl => $_getN(2);
  @$pb.TagNumber(3)
  set ttl($0.Duration value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTtl() => $_has(2);
  @$pb.TagNumber(3)
  void clearTtl() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Duration ensureTtl() => $_ensure(2);
}

class ReserveResponse extends $pb.GeneratedMessage {
  factory ReserveResponse({
    ReservationObject? reservation,
    CheckResponse? check_2,
  }) {
    final result = ReserveResponse._();
    if (reservation != null) result.reservation = reservation;
    if (check_2 != null) result.check_2 = check_2;
    return result;
  }

  ReserveResponse._();

  factory ReserveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveResponse()..mergeFromBuffer(data, registry);
  factory ReserveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReserveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReserveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ReserveResponse.$_createMessage)
    ..aOM<ReservationObject>(1, _omitFieldNames ? '' : 'reservation',
        subBuilder: ReservationObject.$_createMessage)
    ..aOM<CheckResponse>(2, _omitFieldNames ? '' : 'check',
        subBuilder: CheckResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReserveResponse copyWith(void Function(ReserveResponse) updates) =>
      super.copyWith((message) => updates(message as ReserveResponse))
          as ReserveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReserveResponse() / ReserveResponse.new instead')
  static ReserveResponse create() => ReserveResponse._();
  static $pb.GeneratedMessage $_createMessage() => ReserveResponse._();
  @$core.override
  ReserveResponse createEmptyInstance() => ReserveResponse._();
  @$core.pragma('dart2js:noInline')
  static ReserveResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReserveResponse>(
          ReserveResponse.$_createMessage);
  static ReserveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReservationObject get reservation => $_getN(0);
  @$pb.TagNumber(1)
  set reservation(ReservationObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReservation() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservation() => $_clearField(1);
  @$pb.TagNumber(1)
  ReservationObject ensureReservation() => $_ensure(0);

  @$pb.TagNumber(2)
  CheckResponse get check_2 => $_getN(1);
  @$pb.TagNumber(2)
  set check_2(CheckResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCheck_2() => $_has(1);
  @$pb.TagNumber(2)
  void clearCheck_2() => $_clearField(2);
  @$pb.TagNumber(2)
  CheckResponse ensureCheck_2() => $_ensure(1);
}

class CommitRequest extends $pb.GeneratedMessage {
  factory CommitRequest({
    $core.String? reservationId,
  }) {
    final result = CommitRequest._();
    if (reservationId != null) result.reservationId = reservationId;
    return result;
  }

  CommitRequest._();

  factory CommitRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommitRequest()..mergeFromBuffer(data, registry);
  factory CommitRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommitRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommitRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: CommitRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'reservationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommitRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommitRequest copyWith(void Function(CommitRequest) updates) =>
      super.copyWith((message) => updates(message as CommitRequest))
          as CommitRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommitRequest() / CommitRequest.new instead')
  static CommitRequest create() => CommitRequest._();
  static $pb.GeneratedMessage $_createMessage() => CommitRequest._();
  @$core.override
  CommitRequest createEmptyInstance() => CommitRequest._();
  @$core.pragma('dart2js:noInline')
  static CommitRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommitRequest>(
          CommitRequest.$_createMessage);
  static CommitRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reservationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set reservationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReservationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservationId() => $_clearField(1);
}

class CommitResponse extends $pb.GeneratedMessage {
  factory CommitResponse({
    ReservationObject? reservation,
  }) {
    final result = CommitResponse._();
    if (reservation != null) result.reservation = reservation;
    return result;
  }

  CommitResponse._();

  factory CommitResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommitResponse()..mergeFromBuffer(data, registry);
  factory CommitResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommitResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommitResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: CommitResponse.$_createMessage)
    ..aOM<ReservationObject>(1, _omitFieldNames ? '' : 'reservation',
        subBuilder: ReservationObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommitResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommitResponse copyWith(void Function(CommitResponse) updates) =>
      super.copyWith((message) => updates(message as CommitResponse))
          as CommitResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommitResponse() / CommitResponse.new instead')
  static CommitResponse create() => CommitResponse._();
  static $pb.GeneratedMessage $_createMessage() => CommitResponse._();
  @$core.override
  CommitResponse createEmptyInstance() => CommitResponse._();
  @$core.pragma('dart2js:noInline')
  static CommitResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommitResponse>(
          CommitResponse.$_createMessage);
  static CommitResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReservationObject get reservation => $_getN(0);
  @$pb.TagNumber(1)
  set reservation(ReservationObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReservation() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservation() => $_clearField(1);
  @$pb.TagNumber(1)
  ReservationObject ensureReservation() => $_ensure(0);
}

class ReleaseRequest extends $pb.GeneratedMessage {
  factory ReleaseRequest({
    $core.String? reservationId,
    $core.String? reason,
  }) {
    final result = ReleaseRequest._();
    if (reservationId != null) result.reservationId = reservationId;
    if (reason != null) result.reason = reason;
    return result;
  }

  ReleaseRequest._();

  factory ReleaseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReleaseRequest()..mergeFromBuffer(data, registry);
  factory ReleaseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReleaseRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReleaseRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ReleaseRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'reservationId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReleaseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReleaseRequest copyWith(void Function(ReleaseRequest) updates) =>
      super.copyWith((message) => updates(message as ReleaseRequest))
          as ReleaseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReleaseRequest() / ReleaseRequest.new instead')
  static ReleaseRequest create() => ReleaseRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReleaseRequest._();
  @$core.override
  ReleaseRequest createEmptyInstance() => ReleaseRequest._();
  @$core.pragma('dart2js:noInline')
  static ReleaseRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReleaseRequest>(
          ReleaseRequest.$_createMessage);
  static ReleaseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reservationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set reservationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReservationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class ReleaseResponse extends $pb.GeneratedMessage {
  factory ReleaseResponse({
    ReservationObject? reservation,
  }) {
    final result = ReleaseResponse._();
    if (reservation != null) result.reservation = reservation;
    return result;
  }

  ReleaseResponse._();

  factory ReleaseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReleaseResponse()..mergeFromBuffer(data, registry);
  factory ReleaseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReleaseResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReleaseResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ReleaseResponse.$_createMessage)
    ..aOM<ReservationObject>(1, _omitFieldNames ? '' : 'reservation',
        subBuilder: ReservationObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReleaseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReleaseResponse copyWith(void Function(ReleaseResponse) updates) =>
      super.copyWith((message) => updates(message as ReleaseResponse))
          as ReleaseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReleaseResponse() / ReleaseResponse.new instead')
  static ReleaseResponse create() => ReleaseResponse._();
  static $pb.GeneratedMessage $_createMessage() => ReleaseResponse._();
  @$core.override
  ReleaseResponse createEmptyInstance() => ReleaseResponse._();
  @$core.pragma('dart2js:noInline')
  static ReleaseResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReleaseResponse>(
          ReleaseResponse.$_createMessage);
  static ReleaseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReservationObject get reservation => $_getN(0);
  @$pb.TagNumber(1)
  set reservation(ReservationObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReservation() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservation() => $_clearField(1);
  @$pb.TagNumber(1)
  ReservationObject ensureReservation() => $_ensure(0);
}

class ReverseRequest extends $pb.GeneratedMessage {
  factory ReverseRequest({
    $core.String? reservationId,
    $core.String? idempotencyKey,
    $core.String? reason,
  }) {
    final result = ReverseRequest._();
    if (reservationId != null) result.reservationId = reservationId;
    if (idempotencyKey != null) result.idempotencyKey = idempotencyKey;
    if (reason != null) result.reason = reason;
    return result;
  }

  ReverseRequest._();

  factory ReverseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReverseRequest()..mergeFromBuffer(data, registry);
  factory ReverseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReverseRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReverseRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ReverseRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'reservationId')
    ..aOS(2, _omitFieldNames ? '' : 'idempotencyKey')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseRequest copyWith(void Function(ReverseRequest) updates) =>
      super.copyWith((message) => updates(message as ReverseRequest))
          as ReverseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReverseRequest() / ReverseRequest.new instead')
  static ReverseRequest create() => ReverseRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReverseRequest._();
  @$core.override
  ReverseRequest createEmptyInstance() => ReverseRequest._();
  @$core.pragma('dart2js:noInline')
  static ReverseRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReverseRequest>(
          ReverseRequest.$_createMessage);
  static ReverseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reservationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set reservationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReservationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReservationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get idempotencyKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set idempotencyKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdempotencyKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdempotencyKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);
}

class ReverseResponse extends $pb.GeneratedMessage {
  factory ReverseResponse({
    ReservationObject? originalReservation,
    ReservationObject? reversalReservation,
  }) {
    final result = ReverseResponse._();
    if (originalReservation != null)
      result.originalReservation = originalReservation;
    if (reversalReservation != null)
      result.reversalReservation = reversalReservation;
    return result;
  }

  ReverseResponse._();

  factory ReverseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReverseResponse()..mergeFromBuffer(data, registry);
  factory ReverseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReverseResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReverseResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: ReverseResponse.$_createMessage)
    ..aOM<ReservationObject>(1, _omitFieldNames ? '' : 'originalReservation',
        subBuilder: ReservationObject.$_createMessage)
    ..aOM<ReservationObject>(2, _omitFieldNames ? '' : 'reversalReservation',
        subBuilder: ReservationObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseResponse copyWith(void Function(ReverseResponse) updates) =>
      super.copyWith((message) => updates(message as ReverseResponse))
          as ReverseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReverseResponse() / ReverseResponse.new instead')
  static ReverseResponse create() => ReverseResponse._();
  static $pb.GeneratedMessage $_createMessage() => ReverseResponse._();
  @$core.override
  ReverseResponse createEmptyInstance() => ReverseResponse._();
  @$core.pragma('dart2js:noInline')
  static ReverseResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReverseResponse>(
          ReverseResponse.$_createMessage);
  static ReverseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReservationObject get originalReservation => $_getN(0);
  @$pb.TagNumber(1)
  set originalReservation(ReservationObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOriginalReservation() => $_has(0);
  @$pb.TagNumber(1)
  void clearOriginalReservation() => $_clearField(1);
  @$pb.TagNumber(1)
  ReservationObject ensureOriginalReservation() => $_ensure(0);

  @$pb.TagNumber(2)
  ReservationObject get reversalReservation => $_getN(1);
  @$pb.TagNumber(2)
  set reversalReservation(ReservationObject value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasReversalReservation() => $_has(1);
  @$pb.TagNumber(2)
  void clearReversalReservation() => $_clearField(2);
  @$pb.TagNumber(2)
  ReservationObject ensureReversalReservation() => $_ensure(1);
}

class LimitsJobRunRequest extends $pb.GeneratedMessage {
  factory LimitsJobRunRequest({
    LimitsJob? job,
  }) {
    final result = LimitsJobRunRequest._();
    if (job != null) result.job = job;
    return result;
  }

  LimitsJobRunRequest._();

  factory LimitsJobRunRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitsJobRunRequest()..mergeFromBuffer(data, registry);
  factory LimitsJobRunRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitsJobRunRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LimitsJobRunRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: LimitsJobRunRequest.$_createMessage)
    ..aE<LimitsJob>(1, _omitFieldNames ? '' : 'job',
        enumValues: LimitsJob.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitsJobRunRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitsJobRunRequest copyWith(void Function(LimitsJobRunRequest) updates) =>
      super.copyWith((message) => updates(message as LimitsJobRunRequest))
          as LimitsJobRunRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use LimitsJobRunRequest() / LimitsJobRunRequest.new instead')
  static LimitsJobRunRequest create() => LimitsJobRunRequest._();
  static $pb.GeneratedMessage $_createMessage() => LimitsJobRunRequest._();
  @$core.override
  LimitsJobRunRequest createEmptyInstance() => LimitsJobRunRequest._();
  @$core.pragma('dart2js:noInline')
  static LimitsJobRunRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LimitsJobRunRequest>(
          LimitsJobRunRequest.$_createMessage);
  static LimitsJobRunRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LimitsJob get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(LimitsJob value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);
}

class LimitsJobRunResponse extends $pb.GeneratedMessage {
  factory LimitsJobRunResponse() => LimitsJobRunResponse._();

  LimitsJobRunResponse._();

  factory LimitsJobRunResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitsJobRunResponse()..mergeFromBuffer(data, registry);
  factory LimitsJobRunResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LimitsJobRunResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LimitsJobRunResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'limits.v1'),
      createEmptyInstance: LimitsJobRunResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitsJobRunResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LimitsJobRunResponse copyWith(void Function(LimitsJobRunResponse) updates) =>
      super.copyWith((message) => updates(message as LimitsJobRunResponse))
          as LimitsJobRunResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use LimitsJobRunResponse() / LimitsJobRunResponse.new instead')
  static LimitsJobRunResponse create() => LimitsJobRunResponse._();
  static $pb.GeneratedMessage $_createMessage() => LimitsJobRunResponse._();
  @$core.override
  LimitsJobRunResponse createEmptyInstance() => LimitsJobRunResponse._();
  @$core.pragma('dart2js:noInline')
  static LimitsJobRunResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LimitsJobRunResponse>(
          LimitsJobRunResponse.$_createMessage);
  static LimitsJobRunResponse? _defaultInstance;
}

class LimitsServiceApi {
  final $pb.RpcClient _client;

  LimitsServiceApi(this._client);

  $async.Future<CheckResponse> check_(
          $pb.ClientContext? ctx, CheckRequest request) =>
      _client.invoke<CheckResponse>(
          ctx, 'LimitsService', 'Check', request, CheckResponse());
  $async.Future<ReserveResponse> reserve(
          $pb.ClientContext? ctx, ReserveRequest request) =>
      _client.invoke<ReserveResponse>(
          ctx, 'LimitsService', 'Reserve', request, ReserveResponse());
  $async.Future<CommitResponse> commit(
          $pb.ClientContext? ctx, CommitRequest request) =>
      _client.invoke<CommitResponse>(
          ctx, 'LimitsService', 'Commit', request, CommitResponse());
  $async.Future<ReleaseResponse> release(
          $pb.ClientContext? ctx, ReleaseRequest request) =>
      _client.invoke<ReleaseResponse>(
          ctx, 'LimitsService', 'Release', request, ReleaseResponse());
  $async.Future<ReverseResponse> reverse(
          $pb.ClientContext? ctx, ReverseRequest request) =>
      _client.invoke<ReverseResponse>(
          ctx, 'LimitsService', 'Reverse', request, ReverseResponse());
}

class LimitsAdminServiceApi {
  final $pb.RpcClient _client;

  LimitsAdminServiceApi(this._client);

  $async.Future<PolicySaveResponse> policySave(
          $pb.ClientContext? ctx, PolicySaveRequest request) =>
      _client.invoke<PolicySaveResponse>(ctx, 'LimitsAdminService',
          'PolicySave', request, PolicySaveResponse());
  $async.Future<PolicyGetResponse> policyGet(
          $pb.ClientContext? ctx, PolicyGetRequest request) =>
      _client.invoke<PolicyGetResponse>(
          ctx, 'LimitsAdminService', 'PolicyGet', request, PolicyGetResponse());
  $async.Future<PolicySearchResponse> policySearch(
          $pb.ClientContext? ctx, PolicySearchRequest request) =>
      _client.invoke<PolicySearchResponse>(ctx, 'LimitsAdminService',
          'PolicySearch', request, PolicySearchResponse());
  $async.Future<PolicyDeleteResponse> policyDelete(
          $pb.ClientContext? ctx, PolicyDeleteRequest request) =>
      _client.invoke<PolicyDeleteResponse>(ctx, 'LimitsAdminService',
          'PolicyDelete', request, PolicyDeleteResponse());

  /// PolicyHistory pages through a policy's immutable version snapshots, newest first.
  $async.Future<PolicyHistoryResponse> policyHistory(
          $pb.ClientContext? ctx, PolicyHistoryRequest request) =>
      _client.invoke<PolicyHistoryResponse>(ctx, 'LimitsAdminService',
          'PolicyHistory', request, PolicyHistoryResponse());
  $async.Future<ApprovalRequestListResponse> approvalRequestList(
          $pb.ClientContext? ctx, ApprovalRequestListRequest request) =>
      _client.invoke<ApprovalRequestListResponse>(ctx, 'LimitsAdminService',
          'ApprovalRequestList', request, ApprovalRequestListResponse());
  $async.Future<ApprovalRequestGetResponse> approvalRequestGet(
          $pb.ClientContext? ctx, ApprovalRequestGetRequest request) =>
      _client.invoke<ApprovalRequestGetResponse>(ctx, 'LimitsAdminService',
          'ApprovalRequestGet', request, ApprovalRequestGetResponse());
  $async.Future<ApprovalRequestDecideResponse> approvalRequestDecide(
          $pb.ClientContext? ctx, ApprovalRequestDecideRequest request) =>
      _client.invoke<ApprovalRequestDecideResponse>(ctx, 'LimitsAdminService',
          'ApprovalRequestDecide', request, ApprovalRequestDecideResponse());
  $async.Future<LedgerSearchResponse> ledgerSearch(
          $pb.ClientContext? ctx, LedgerSearchRequest request) =>
      _client.invoke<LedgerSearchResponse>(ctx, 'LimitsAdminService',
          'LedgerSearch', request, LedgerSearchResponse());
  $async.Future<LimitsAuditSearchResponse> limitsAuditSearch(
          $pb.ClientContext? ctx, LimitsAuditSearchRequest request) =>
      _client.invoke<LimitsAuditSearchResponse>(ctx, 'LimitsAdminService',
          'LimitsAuditSearch', request, LimitsAuditSearchResponse());

  /// LimitsJobRun runs one pass of a periodic job. Called by the platform
  /// scheduler (trustage); the permission is bound to no role and granted to
  /// the scheduler's service account.
  $async.Future<LimitsJobRunResponse> limitsJobRun(
          $pb.ClientContext? ctx, LimitsJobRunRequest request) =>
      _client.invoke<LimitsJobRunResponse>(ctx, 'LimitsAdminService',
          'LimitsJobRun', request, LimitsJobRunResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
