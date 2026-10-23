//
//  Generated code. Do not modify.
//  source: field/v1/field.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../common/v1/common.pb.dart' as $7;
import '../../common/v1/common.pbenum.dart' as $7;
import '../../google/protobuf/struct.pb.dart' as $6;
import 'field.pbenum.dart';

export 'field.pbenum.dart';

/// AgentObject represents a field agent in the lending hierarchy.
/// Agents can be assigned to multiple branches via AgentBranchObject.
/// Deprecated: use identity.v1.WorkforceMemberObject, PositionObject, and InternalTeamObject.
class AgentObject extends $pb.GeneratedMessage {
  factory AgentObject({
    $core.String? id,
    $core.String? organizationId,
    $core.String? parentAgentId,
    $core.String? profileId,
    AgentType? agentType,
    $core.String? name,
    $core.String? geoId,
    $core.int? depth,
    $7.STATE? state,
    $6.Struct? properties,
    $core.Iterable<$core.String>? branchIds,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (parentAgentId != null) {
      $result.parentAgentId = parentAgentId;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (agentType != null) {
      $result.agentType = agentType;
    }
    if (name != null) {
      $result.name = name;
    }
    if (geoId != null) {
      $result.geoId = geoId;
    }
    if (depth != null) {
      $result.depth = depth;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    if (branchIds != null) {
      $result.branchIds.addAll(branchIds);
    }
    return $result;
  }
  AgentObject._() : super();
  factory AgentObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentAgentId')
    ..aOS(4, _omitFieldNames ? '' : 'profileId')
    ..e<AgentType>(5, _omitFieldNames ? '' : 'agentType', $pb.PbFieldType.OE, defaultOrMaker: AgentType.AGENT_TYPE_UNSPECIFIED, valueOf: AgentType.valueOf, enumValues: AgentType.values)
    ..aOS(6, _omitFieldNames ? '' : 'name')
    ..aOS(7, _omitFieldNames ? '' : 'geoId')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'depth', $pb.PbFieldType.O3)
    ..e<$7.STATE>(9, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(10, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..pPS(11, _omitFieldNames ? '' : 'branchIds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentObject clone() => AgentObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentObject copyWith(void Function(AgentObject) updates) => super.copyWith((message) => updates(message as AgentObject)) as AgentObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentObject create() => AgentObject._();
  AgentObject createEmptyInstance() => create();
  static $pb.PbList<AgentObject> createRepeated() => $pb.PbList<AgentObject>();
  @$core.pragma('dart2js:noInline')
  static AgentObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentObject>(create);
  static AgentObject? _defaultInstance;

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
  $core.String get parentAgentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentAgentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasParentAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentAgentId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get profileId => $_getSZ(3);
  @$pb.TagNumber(4)
  set profileId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasProfileId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProfileId() => clearField(4);

  @$pb.TagNumber(5)
  AgentType get agentType => $_getN(4);
  @$pb.TagNumber(5)
  set agentType(AgentType v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAgentType() => $_has(4);
  @$pb.TagNumber(5)
  void clearAgentType() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(6)
  set name($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(6)
  void clearName() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get geoId => $_getSZ(6);
  @$pb.TagNumber(7)
  set geoId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasGeoId() => $_has(6);
  @$pb.TagNumber(7)
  void clearGeoId() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get depth => $_getIZ(7);
  @$pb.TagNumber(8)
  set depth($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasDepth() => $_has(7);
  @$pb.TagNumber(8)
  void clearDepth() => clearField(8);

  @$pb.TagNumber(9)
  $7.STATE get state => $_getN(8);
  @$pb.TagNumber(9)
  set state($7.STATE v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasState() => $_has(8);
  @$pb.TagNumber(9)
  void clearState() => clearField(9);

  @$pb.TagNumber(10)
  $6.Struct get properties => $_getN(9);
  @$pb.TagNumber(10)
  set properties($6.Struct v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasProperties() => $_has(9);
  @$pb.TagNumber(10)
  void clearProperties() => clearField(10);
  @$pb.TagNumber(10)
  $6.Struct ensureProperties() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.List<$core.String> get branchIds => $_getList(10);
}

/// AgentBranchObject links an agent to a branch.
/// Supports per-branch properties such as commission structures.
class AgentBranchObject extends $pb.GeneratedMessage {
  factory AgentBranchObject({
    $core.String? id,
    $core.String? agentId,
    $core.String? branchId,
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (branchId != null) {
      $result.branchId = branchId;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  AgentBranchObject._() : super();
  factory AgentBranchObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentBranchObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentBranchObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'agentId')
    ..aOS(3, _omitFieldNames ? '' : 'branchId')
    ..e<$7.STATE>(4, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(5, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentBranchObject clone() => AgentBranchObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentBranchObject copyWith(void Function(AgentBranchObject) updates) => super.copyWith((message) => updates(message as AgentBranchObject)) as AgentBranchObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentBranchObject create() => AgentBranchObject._();
  AgentBranchObject createEmptyInstance() => create();
  static $pb.PbList<AgentBranchObject> createRepeated() => $pb.PbList<AgentBranchObject>();
  @$core.pragma('dart2js:noInline')
  static AgentBranchObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentBranchObject>(create);
  static AgentBranchObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get agentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set agentId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAgentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAgentId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get branchId => $_getSZ(2);
  @$pb.TagNumber(3)
  set branchId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBranchId() => $_has(2);
  @$pb.TagNumber(3)
  void clearBranchId() => clearField(3);

  @$pb.TagNumber(4)
  $7.STATE get state => $_getN(3);
  @$pb.TagNumber(4)
  set state($7.STATE v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasState() => $_has(3);
  @$pb.TagNumber(4)
  void clearState() => clearField(4);

  @$pb.TagNumber(5)
  $6.Struct get properties => $_getN(4);
  @$pb.TagNumber(5)
  set properties($6.Struct v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasProperties() => $_has(4);
  @$pb.TagNumber(5)
  void clearProperties() => clearField(5);
  @$pb.TagNumber(5)
  $6.Struct ensureProperties() => $_ensure(4);
}

/// ClientObject represents a loan recipient owned by a team.
/// Client-to-member relationships are managed via ClientRelationshipObject.
class ClientObject extends $pb.GeneratedMessage {
  factory ClientObject({
    $core.String? id,
    $core.String? agentId,
    $core.String? profileId,
    $core.String? name,
    $7.STATE? state,
    $6.Struct? properties,
    $core.String? owningTeamId,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    if (owningTeamId != null) {
      $result.owningTeamId = owningTeamId;
    }
    return $result;
  }
  ClientObject._() : super();
  factory ClientObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'agentId')
    ..aOS(3, _omitFieldNames ? '' : 'profileId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..e<$7.STATE>(5, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(6, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..aOS(7, _omitFieldNames ? '' : 'owningTeamId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientObject clone() => ClientObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientObject copyWith(void Function(ClientObject) updates) => super.copyWith((message) => updates(message as ClientObject)) as ClientObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientObject create() => ClientObject._();
  ClientObject createEmptyInstance() => create();
  static $pb.PbList<ClientObject> createRepeated() => $pb.PbList<ClientObject>();
  @$core.pragma('dart2js:noInline')
  static ClientObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientObject>(create);
  static ClientObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get agentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set agentId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAgentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAgentId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get profileId => $_getSZ(2);
  @$pb.TagNumber(3)
  set profileId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasProfileId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProfileId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => clearField(4);

  @$pb.TagNumber(5)
  $7.STATE get state => $_getN(4);
  @$pb.TagNumber(5)
  set state($7.STATE v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasState() => $_has(4);
  @$pb.TagNumber(5)
  void clearState() => clearField(5);

  @$pb.TagNumber(6)
  $6.Struct get properties => $_getN(5);
  @$pb.TagNumber(6)
  set properties($6.Struct v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasProperties() => $_has(5);
  @$pb.TagNumber(6)
  void clearProperties() => clearField(6);
  @$pb.TagNumber(6)
  $6.Struct ensureProperties() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get owningTeamId => $_getSZ(6);
  @$pb.TagNumber(7)
  set owningTeamId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasOwningTeamId() => $_has(6);
  @$pb.TagNumber(7)
  void clearOwningTeamId() => clearField(7);
}

/// ClientRelationshipObject assigns a workforce member to a client.
/// Multiple members can be assigned to the same client.
class ClientRelationshipObject extends $pb.GeneratedMessage {
  factory ClientRelationshipObject({
    $core.String? id,
    $core.String? clientId,
    $core.String? memberId,
    $core.String? name,
    $core.String? description,
    $core.bool? isPrimary,
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (memberId != null) {
      $result.memberId = memberId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (isPrimary != null) {
      $result.isPrimary = isPrimary;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  ClientRelationshipObject._() : super();
  factory ClientRelationshipObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientRelationshipObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientRelationshipObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'clientId')
    ..aOS(3, _omitFieldNames ? '' : 'memberId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aOB(6, _omitFieldNames ? '' : 'isPrimary')
    ..e<$7.STATE>(7, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(8, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientRelationshipObject clone() => ClientRelationshipObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientRelationshipObject copyWith(void Function(ClientRelationshipObject) updates) => super.copyWith((message) => updates(message as ClientRelationshipObject)) as ClientRelationshipObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientRelationshipObject create() => ClientRelationshipObject._();
  ClientRelationshipObject createEmptyInstance() => create();
  static $pb.PbList<ClientRelationshipObject> createRepeated() => $pb.PbList<ClientRelationshipObject>();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientRelationshipObject>(create);
  static ClientRelationshipObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get memberId => $_getSZ(2);
  @$pb.TagNumber(3)
  set memberId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMemberId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isPrimary => $_getBF(5);
  @$pb.TagNumber(6)
  set isPrimary($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsPrimary() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsPrimary() => clearField(6);

  @$pb.TagNumber(7)
  $7.STATE get state => $_getN(6);
  @$pb.TagNumber(7)
  set state($7.STATE v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasState() => $_has(6);
  @$pb.TagNumber(7)
  void clearState() => clearField(7);

  @$pb.TagNumber(8)
  $6.Struct get properties => $_getN(7);
  @$pb.TagNumber(8)
  set properties($6.Struct v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasProperties() => $_has(7);
  @$pb.TagNumber(8)
  void clearProperties() => clearField(8);
  @$pb.TagNumber(8)
  $6.Struct ensureProperties() => $_ensure(7);
}

/// Agent messages
class AgentSaveRequest extends $pb.GeneratedMessage {
  factory AgentSaveRequest({
    AgentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  AgentSaveRequest._() : super();
  factory AgentSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<AgentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: AgentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentSaveRequest clone() => AgentSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentSaveRequest copyWith(void Function(AgentSaveRequest) updates) => super.copyWith((message) => updates(message as AgentSaveRequest)) as AgentSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentSaveRequest create() => AgentSaveRequest._();
  AgentSaveRequest createEmptyInstance() => create();
  static $pb.PbList<AgentSaveRequest> createRepeated() => $pb.PbList<AgentSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static AgentSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentSaveRequest>(create);
  static AgentSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  AgentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AgentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  AgentObject ensureData() => $_ensure(0);
}

class AgentSaveResponse extends $pb.GeneratedMessage {
  factory AgentSaveResponse({
    AgentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  AgentSaveResponse._() : super();
  factory AgentSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<AgentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: AgentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentSaveResponse clone() => AgentSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentSaveResponse copyWith(void Function(AgentSaveResponse) updates) => super.copyWith((message) => updates(message as AgentSaveResponse)) as AgentSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentSaveResponse create() => AgentSaveResponse._();
  AgentSaveResponse createEmptyInstance() => create();
  static $pb.PbList<AgentSaveResponse> createRepeated() => $pb.PbList<AgentSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static AgentSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentSaveResponse>(create);
  static AgentSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AgentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AgentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  AgentObject ensureData() => $_ensure(0);
}

class AgentGetRequest extends $pb.GeneratedMessage {
  factory AgentGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  AgentGetRequest._() : super();
  factory AgentGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentGetRequest clone() => AgentGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentGetRequest copyWith(void Function(AgentGetRequest) updates) => super.copyWith((message) => updates(message as AgentGetRequest)) as AgentGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentGetRequest create() => AgentGetRequest._();
  AgentGetRequest createEmptyInstance() => create();
  static $pb.PbList<AgentGetRequest> createRepeated() => $pb.PbList<AgentGetRequest>();
  @$core.pragma('dart2js:noInline')
  static AgentGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentGetRequest>(create);
  static AgentGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class AgentGetResponse extends $pb.GeneratedMessage {
  factory AgentGetResponse({
    AgentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  AgentGetResponse._() : super();
  factory AgentGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<AgentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: AgentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentGetResponse clone() => AgentGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentGetResponse copyWith(void Function(AgentGetResponse) updates) => super.copyWith((message) => updates(message as AgentGetResponse)) as AgentGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentGetResponse create() => AgentGetResponse._();
  AgentGetResponse createEmptyInstance() => create();
  static $pb.PbList<AgentGetResponse> createRepeated() => $pb.PbList<AgentGetResponse>();
  @$core.pragma('dart2js:noInline')
  static AgentGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentGetResponse>(create);
  static AgentGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AgentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AgentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  AgentObject ensureData() => $_ensure(0);
}

class AgentSearchRequest extends $pb.GeneratedMessage {
  factory AgentSearchRequest({
    $core.String? query,
    $core.String? branchId,
    $core.String? parentAgentId,
    $7.PageCursor? cursor,
    $core.String? organizationId,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (branchId != null) {
      $result.branchId = branchId;
    }
    if (parentAgentId != null) {
      $result.parentAgentId = parentAgentId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    return $result;
  }
  AgentSearchRequest._() : super();
  factory AgentSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'branchId')
    ..aOS(3, _omitFieldNames ? '' : 'parentAgentId')
    ..aOM<$7.PageCursor>(4, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..aOS(5, _omitFieldNames ? '' : 'organizationId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentSearchRequest clone() => AgentSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentSearchRequest copyWith(void Function(AgentSearchRequest) updates) => super.copyWith((message) => updates(message as AgentSearchRequest)) as AgentSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentSearchRequest create() => AgentSearchRequest._();
  AgentSearchRequest createEmptyInstance() => create();
  static $pb.PbList<AgentSearchRequest> createRepeated() => $pb.PbList<AgentSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static AgentSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentSearchRequest>(create);
  static AgentSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get branchId => $_getSZ(1);
  @$pb.TagNumber(2)
  set branchId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBranchId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBranchId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get parentAgentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentAgentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasParentAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentAgentId() => clearField(3);

  @$pb.TagNumber(4)
  $7.PageCursor get cursor => $_getN(3);
  @$pb.TagNumber(4)
  set cursor($7.PageCursor v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursor() => clearField(4);
  @$pb.TagNumber(4)
  $7.PageCursor ensureCursor() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get organizationId => $_getSZ(4);
  @$pb.TagNumber(5)
  set organizationId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOrganizationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOrganizationId() => clearField(5);
}

class AgentSearchResponse extends $pb.GeneratedMessage {
  factory AgentSearchResponse({
    $core.Iterable<AgentObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  AgentSearchResponse._() : super();
  factory AgentSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..pc<AgentObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: AgentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentSearchResponse clone() => AgentSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentSearchResponse copyWith(void Function(AgentSearchResponse) updates) => super.copyWith((message) => updates(message as AgentSearchResponse)) as AgentSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentSearchResponse create() => AgentSearchResponse._();
  AgentSearchResponse createEmptyInstance() => create();
  static $pb.PbList<AgentSearchResponse> createRepeated() => $pb.PbList<AgentSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static AgentSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentSearchResponse>(create);
  static AgentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<AgentObject> get data => $_getList(0);
}

/// AgentHierarchyRequest retrieves an agent's descendant tree.
class AgentHierarchyRequest extends $pb.GeneratedMessage {
  factory AgentHierarchyRequest({
    $core.String? agentId,
    $core.int? maxDepth,
  }) {
    final $result = create();
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (maxDepth != null) {
      $result.maxDepth = maxDepth;
    }
    return $result;
  }
  AgentHierarchyRequest._() : super();
  factory AgentHierarchyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentHierarchyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentHierarchyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'agentId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'maxDepth', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentHierarchyRequest clone() => AgentHierarchyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentHierarchyRequest copyWith(void Function(AgentHierarchyRequest) updates) => super.copyWith((message) => updates(message as AgentHierarchyRequest)) as AgentHierarchyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentHierarchyRequest create() => AgentHierarchyRequest._();
  AgentHierarchyRequest createEmptyInstance() => create();
  static $pb.PbList<AgentHierarchyRequest> createRepeated() => $pb.PbList<AgentHierarchyRequest>();
  @$core.pragma('dart2js:noInline')
  static AgentHierarchyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentHierarchyRequest>(create);
  static AgentHierarchyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get agentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set agentId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAgentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAgentId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxDepth => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxDepth($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMaxDepth() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxDepth() => clearField(2);
}

class AgentHierarchyResponse extends $pb.GeneratedMessage {
  factory AgentHierarchyResponse({
    $core.Iterable<AgentObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  AgentHierarchyResponse._() : super();
  factory AgentHierarchyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentHierarchyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentHierarchyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..pc<AgentObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: AgentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentHierarchyResponse clone() => AgentHierarchyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentHierarchyResponse copyWith(void Function(AgentHierarchyResponse) updates) => super.copyWith((message) => updates(message as AgentHierarchyResponse)) as AgentHierarchyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentHierarchyResponse create() => AgentHierarchyResponse._();
  AgentHierarchyResponse createEmptyInstance() => create();
  static $pb.PbList<AgentHierarchyResponse> createRepeated() => $pb.PbList<AgentHierarchyResponse>();
  @$core.pragma('dart2js:noInline')
  static AgentHierarchyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentHierarchyResponse>(create);
  static AgentHierarchyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<AgentObject> get data => $_getList(0);
}

/// Agent branch assignment messages
class AgentBranchSaveRequest extends $pb.GeneratedMessage {
  factory AgentBranchSaveRequest({
    AgentBranchObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  AgentBranchSaveRequest._() : super();
  factory AgentBranchSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentBranchSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentBranchSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<AgentBranchObject>(1, _omitFieldNames ? '' : 'data', subBuilder: AgentBranchObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentBranchSaveRequest clone() => AgentBranchSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentBranchSaveRequest copyWith(void Function(AgentBranchSaveRequest) updates) => super.copyWith((message) => updates(message as AgentBranchSaveRequest)) as AgentBranchSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentBranchSaveRequest create() => AgentBranchSaveRequest._();
  AgentBranchSaveRequest createEmptyInstance() => create();
  static $pb.PbList<AgentBranchSaveRequest> createRepeated() => $pb.PbList<AgentBranchSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static AgentBranchSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentBranchSaveRequest>(create);
  static AgentBranchSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  AgentBranchObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AgentBranchObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  AgentBranchObject ensureData() => $_ensure(0);
}

class AgentBranchSaveResponse extends $pb.GeneratedMessage {
  factory AgentBranchSaveResponse({
    AgentBranchObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  AgentBranchSaveResponse._() : super();
  factory AgentBranchSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentBranchSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentBranchSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<AgentBranchObject>(1, _omitFieldNames ? '' : 'data', subBuilder: AgentBranchObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentBranchSaveResponse clone() => AgentBranchSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentBranchSaveResponse copyWith(void Function(AgentBranchSaveResponse) updates) => super.copyWith((message) => updates(message as AgentBranchSaveResponse)) as AgentBranchSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentBranchSaveResponse create() => AgentBranchSaveResponse._();
  AgentBranchSaveResponse createEmptyInstance() => create();
  static $pb.PbList<AgentBranchSaveResponse> createRepeated() => $pb.PbList<AgentBranchSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static AgentBranchSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentBranchSaveResponse>(create);
  static AgentBranchSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AgentBranchObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AgentBranchObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  AgentBranchObject ensureData() => $_ensure(0);
}

class AgentBranchDeleteRequest extends $pb.GeneratedMessage {
  factory AgentBranchDeleteRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  AgentBranchDeleteRequest._() : super();
  factory AgentBranchDeleteRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentBranchDeleteRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentBranchDeleteRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentBranchDeleteRequest clone() => AgentBranchDeleteRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentBranchDeleteRequest copyWith(void Function(AgentBranchDeleteRequest) updates) => super.copyWith((message) => updates(message as AgentBranchDeleteRequest)) as AgentBranchDeleteRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentBranchDeleteRequest create() => AgentBranchDeleteRequest._();
  AgentBranchDeleteRequest createEmptyInstance() => create();
  static $pb.PbList<AgentBranchDeleteRequest> createRepeated() => $pb.PbList<AgentBranchDeleteRequest>();
  @$core.pragma('dart2js:noInline')
  static AgentBranchDeleteRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentBranchDeleteRequest>(create);
  static AgentBranchDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class AgentBranchDeleteResponse extends $pb.GeneratedMessage {
  factory AgentBranchDeleteResponse() => create();
  AgentBranchDeleteResponse._() : super();
  factory AgentBranchDeleteResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentBranchDeleteResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentBranchDeleteResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentBranchDeleteResponse clone() => AgentBranchDeleteResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentBranchDeleteResponse copyWith(void Function(AgentBranchDeleteResponse) updates) => super.copyWith((message) => updates(message as AgentBranchDeleteResponse)) as AgentBranchDeleteResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentBranchDeleteResponse create() => AgentBranchDeleteResponse._();
  AgentBranchDeleteResponse createEmptyInstance() => create();
  static $pb.PbList<AgentBranchDeleteResponse> createRepeated() => $pb.PbList<AgentBranchDeleteResponse>();
  @$core.pragma('dart2js:noInline')
  static AgentBranchDeleteResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentBranchDeleteResponse>(create);
  static AgentBranchDeleteResponse? _defaultInstance;
}

class AgentBranchListRequest extends $pb.GeneratedMessage {
  factory AgentBranchListRequest({
    $core.String? agentId,
    $core.String? branchId,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (branchId != null) {
      $result.branchId = branchId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  AgentBranchListRequest._() : super();
  factory AgentBranchListRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentBranchListRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentBranchListRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'agentId')
    ..aOS(2, _omitFieldNames ? '' : 'branchId')
    ..aOM<$7.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentBranchListRequest clone() => AgentBranchListRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentBranchListRequest copyWith(void Function(AgentBranchListRequest) updates) => super.copyWith((message) => updates(message as AgentBranchListRequest)) as AgentBranchListRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentBranchListRequest create() => AgentBranchListRequest._();
  AgentBranchListRequest createEmptyInstance() => create();
  static $pb.PbList<AgentBranchListRequest> createRepeated() => $pb.PbList<AgentBranchListRequest>();
  @$core.pragma('dart2js:noInline')
  static AgentBranchListRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentBranchListRequest>(create);
  static AgentBranchListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get agentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set agentId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAgentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAgentId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get branchId => $_getSZ(1);
  @$pb.TagNumber(2)
  set branchId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBranchId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBranchId() => clearField(2);

  @$pb.TagNumber(3)
  $7.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($7.PageCursor v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => clearField(3);
  @$pb.TagNumber(3)
  $7.PageCursor ensureCursor() => $_ensure(2);
}

class AgentBranchListResponse extends $pb.GeneratedMessage {
  factory AgentBranchListResponse({
    $core.Iterable<AgentBranchObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  AgentBranchListResponse._() : super();
  factory AgentBranchListResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgentBranchListResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgentBranchListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..pc<AgentBranchObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: AgentBranchObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgentBranchListResponse clone() => AgentBranchListResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgentBranchListResponse copyWith(void Function(AgentBranchListResponse) updates) => super.copyWith((message) => updates(message as AgentBranchListResponse)) as AgentBranchListResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgentBranchListResponse create() => AgentBranchListResponse._();
  AgentBranchListResponse createEmptyInstance() => create();
  static $pb.PbList<AgentBranchListResponse> createRepeated() => $pb.PbList<AgentBranchListResponse>();
  @$core.pragma('dart2js:noInline')
  static AgentBranchListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentBranchListResponse>(create);
  static AgentBranchListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<AgentBranchObject> get data => $_getList(0);
}

/// Client messages
class ClientSaveRequest extends $pb.GeneratedMessage {
  factory ClientSaveRequest({
    ClientObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientSaveRequest._() : super();
  factory ClientSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<ClientObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientSaveRequest clone() => ClientSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientSaveRequest copyWith(void Function(ClientSaveRequest) updates) => super.copyWith((message) => updates(message as ClientSaveRequest)) as ClientSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientSaveRequest create() => ClientSaveRequest._();
  ClientSaveRequest createEmptyInstance() => create();
  static $pb.PbList<ClientSaveRequest> createRepeated() => $pb.PbList<ClientSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientSaveRequest>(create);
  static ClientSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ClientObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientObject ensureData() => $_ensure(0);
}

class ClientSaveResponse extends $pb.GeneratedMessage {
  factory ClientSaveResponse({
    ClientObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientSaveResponse._() : super();
  factory ClientSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<ClientObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientSaveResponse clone() => ClientSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientSaveResponse copyWith(void Function(ClientSaveResponse) updates) => super.copyWith((message) => updates(message as ClientSaveResponse)) as ClientSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientSaveResponse create() => ClientSaveResponse._();
  ClientSaveResponse createEmptyInstance() => create();
  static $pb.PbList<ClientSaveResponse> createRepeated() => $pb.PbList<ClientSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientSaveResponse>(create);
  static ClientSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientObject ensureData() => $_ensure(0);
}

class ClientGetRequest extends $pb.GeneratedMessage {
  factory ClientGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  ClientGetRequest._() : super();
  factory ClientGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientGetRequest clone() => ClientGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientGetRequest copyWith(void Function(ClientGetRequest) updates) => super.copyWith((message) => updates(message as ClientGetRequest)) as ClientGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientGetRequest create() => ClientGetRequest._();
  ClientGetRequest createEmptyInstance() => create();
  static $pb.PbList<ClientGetRequest> createRepeated() => $pb.PbList<ClientGetRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGetRequest>(create);
  static ClientGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class ClientGetResponse extends $pb.GeneratedMessage {
  factory ClientGetResponse({
    ClientObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientGetResponse._() : super();
  factory ClientGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<ClientObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientGetResponse clone() => ClientGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientGetResponse copyWith(void Function(ClientGetResponse) updates) => super.copyWith((message) => updates(message as ClientGetResponse)) as ClientGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientGetResponse create() => ClientGetResponse._();
  ClientGetResponse createEmptyInstance() => create();
  static $pb.PbList<ClientGetResponse> createRepeated() => $pb.PbList<ClientGetResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGetResponse>(create);
  static ClientGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientObject ensureData() => $_ensure(0);
}

class ClientSearchRequest extends $pb.GeneratedMessage {
  factory ClientSearchRequest({
    $core.String? query,
    $core.String? agentId,
    $7.PageCursor? cursor,
    $core.String? owningTeamId,
    $core.String? memberId,
    $core.String? profileId,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    if (owningTeamId != null) {
      $result.owningTeamId = owningTeamId;
    }
    if (memberId != null) {
      $result.memberId = memberId;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    return $result;
  }
  ClientSearchRequest._() : super();
  factory ClientSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'agentId')
    ..aOM<$7.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..aOS(4, _omitFieldNames ? '' : 'owningTeamId')
    ..aOS(5, _omitFieldNames ? '' : 'memberId')
    ..aOS(6, _omitFieldNames ? '' : 'profileId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientSearchRequest clone() => ClientSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientSearchRequest copyWith(void Function(ClientSearchRequest) updates) => super.copyWith((message) => updates(message as ClientSearchRequest)) as ClientSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientSearchRequest create() => ClientSearchRequest._();
  ClientSearchRequest createEmptyInstance() => create();
  static $pb.PbList<ClientSearchRequest> createRepeated() => $pb.PbList<ClientSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientSearchRequest>(create);
  static ClientSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get agentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set agentId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAgentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAgentId() => clearField(2);

  @$pb.TagNumber(3)
  $7.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($7.PageCursor v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => clearField(3);
  @$pb.TagNumber(3)
  $7.PageCursor ensureCursor() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get owningTeamId => $_getSZ(3);
  @$pb.TagNumber(4)
  set owningTeamId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOwningTeamId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOwningTeamId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get memberId => $_getSZ(4);
  @$pb.TagNumber(5)
  set memberId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMemberId() => $_has(4);
  @$pb.TagNumber(5)
  void clearMemberId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get profileId => $_getSZ(5);
  @$pb.TagNumber(6)
  set profileId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasProfileId() => $_has(5);
  @$pb.TagNumber(6)
  void clearProfileId() => clearField(6);
}

class ClientSearchResponse extends $pb.GeneratedMessage {
  factory ClientSearchResponse({
    $core.Iterable<ClientObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  ClientSearchResponse._() : super();
  factory ClientSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..pc<ClientObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: ClientObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientSearchResponse clone() => ClientSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientSearchResponse copyWith(void Function(ClientSearchResponse) updates) => super.copyWith((message) => updates(message as ClientSearchResponse)) as ClientSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientSearchResponse create() => ClientSearchResponse._();
  ClientSearchResponse createEmptyInstance() => create();
  static $pb.PbList<ClientSearchResponse> createRepeated() => $pb.PbList<ClientSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientSearchResponse>(create);
  static ClientSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ClientObject> get data => $_getList(0);
}

/// ClientReassignRequest moves a client to a different agent.
class ClientReassignRequest extends $pb.GeneratedMessage {
  factory ClientReassignRequest({
    $core.String? clientId,
    $core.String? newAgentId,
    $core.String? reason,
  }) {
    final $result = create();
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (newAgentId != null) {
      $result.newAgentId = newAgentId;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  ClientReassignRequest._() : super();
  factory ClientReassignRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientReassignRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientReassignRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'newAgentId')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientReassignRequest clone() => ClientReassignRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientReassignRequest copyWith(void Function(ClientReassignRequest) updates) => super.copyWith((message) => updates(message as ClientReassignRequest)) as ClientReassignRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientReassignRequest create() => ClientReassignRequest._();
  ClientReassignRequest createEmptyInstance() => create();
  static $pb.PbList<ClientReassignRequest> createRepeated() => $pb.PbList<ClientReassignRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientReassignRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientReassignRequest>(create);
  static ClientReassignRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get newAgentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set newAgentId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNewAgentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewAgentId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => clearField(3);
}

class ClientReassignResponse extends $pb.GeneratedMessage {
  factory ClientReassignResponse({
    ClientObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientReassignResponse._() : super();
  factory ClientReassignResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientReassignResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientReassignResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<ClientObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientReassignResponse clone() => ClientReassignResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientReassignResponse copyWith(void Function(ClientReassignResponse) updates) => super.copyWith((message) => updates(message as ClientReassignResponse)) as ClientReassignResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientReassignResponse create() => ClientReassignResponse._();
  ClientReassignResponse createEmptyInstance() => create();
  static $pb.PbList<ClientReassignResponse> createRepeated() => $pb.PbList<ClientReassignResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientReassignResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientReassignResponse>(create);
  static ClientReassignResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientObject ensureData() => $_ensure(0);
}

/// ClientOwnershipTransferRequest moves a client from one owning team to another.
class ClientOwnershipTransferRequest extends $pb.GeneratedMessage {
  factory ClientOwnershipTransferRequest({
    $core.String? clientId,
    $core.String? newOwningTeamId,
    $core.String? reason,
  }) {
    final $result = create();
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (newOwningTeamId != null) {
      $result.newOwningTeamId = newOwningTeamId;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  ClientOwnershipTransferRequest._() : super();
  factory ClientOwnershipTransferRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientOwnershipTransferRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientOwnershipTransferRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'newOwningTeamId')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientOwnershipTransferRequest clone() => ClientOwnershipTransferRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientOwnershipTransferRequest copyWith(void Function(ClientOwnershipTransferRequest) updates) => super.copyWith((message) => updates(message as ClientOwnershipTransferRequest)) as ClientOwnershipTransferRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientOwnershipTransferRequest create() => ClientOwnershipTransferRequest._();
  ClientOwnershipTransferRequest createEmptyInstance() => create();
  static $pb.PbList<ClientOwnershipTransferRequest> createRepeated() => $pb.PbList<ClientOwnershipTransferRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientOwnershipTransferRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientOwnershipTransferRequest>(create);
  static ClientOwnershipTransferRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get newOwningTeamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set newOwningTeamId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNewOwningTeamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewOwningTeamId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => clearField(3);
}

class ClientOwnershipTransferResponse extends $pb.GeneratedMessage {
  factory ClientOwnershipTransferResponse({
    ClientObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientOwnershipTransferResponse._() : super();
  factory ClientOwnershipTransferResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientOwnershipTransferResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientOwnershipTransferResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<ClientObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientOwnershipTransferResponse clone() => ClientOwnershipTransferResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientOwnershipTransferResponse copyWith(void Function(ClientOwnershipTransferResponse) updates) => super.copyWith((message) => updates(message as ClientOwnershipTransferResponse)) as ClientOwnershipTransferResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientOwnershipTransferResponse create() => ClientOwnershipTransferResponse._();
  ClientOwnershipTransferResponse createEmptyInstance() => create();
  static $pb.PbList<ClientOwnershipTransferResponse> createRepeated() => $pb.PbList<ClientOwnershipTransferResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientOwnershipTransferResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientOwnershipTransferResponse>(create);
  static ClientOwnershipTransferResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientObject ensureData() => $_ensure(0);
}

class ClientRelationshipSaveRequest extends $pb.GeneratedMessage {
  factory ClientRelationshipSaveRequest({
    ClientRelationshipObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientRelationshipSaveRequest._() : super();
  factory ClientRelationshipSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientRelationshipSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientRelationshipSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<ClientRelationshipObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientRelationshipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientRelationshipSaveRequest clone() => ClientRelationshipSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientRelationshipSaveRequest copyWith(void Function(ClientRelationshipSaveRequest) updates) => super.copyWith((message) => updates(message as ClientRelationshipSaveRequest)) as ClientRelationshipSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSaveRequest create() => ClientRelationshipSaveRequest._();
  ClientRelationshipSaveRequest createEmptyInstance() => create();
  static $pb.PbList<ClientRelationshipSaveRequest> createRepeated() => $pb.PbList<ClientRelationshipSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientRelationshipSaveRequest>(create);
  static ClientRelationshipSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ClientRelationshipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientRelationshipObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientRelationshipObject ensureData() => $_ensure(0);
}

class ClientRelationshipSaveResponse extends $pb.GeneratedMessage {
  factory ClientRelationshipSaveResponse({
    ClientRelationshipObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientRelationshipSaveResponse._() : super();
  factory ClientRelationshipSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientRelationshipSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientRelationshipSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<ClientRelationshipObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientRelationshipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientRelationshipSaveResponse clone() => ClientRelationshipSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientRelationshipSaveResponse copyWith(void Function(ClientRelationshipSaveResponse) updates) => super.copyWith((message) => updates(message as ClientRelationshipSaveResponse)) as ClientRelationshipSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSaveResponse create() => ClientRelationshipSaveResponse._();
  ClientRelationshipSaveResponse createEmptyInstance() => create();
  static $pb.PbList<ClientRelationshipSaveResponse> createRepeated() => $pb.PbList<ClientRelationshipSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientRelationshipSaveResponse>(create);
  static ClientRelationshipSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientRelationshipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientRelationshipObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientRelationshipObject ensureData() => $_ensure(0);
}

class ClientRelationshipGetRequest extends $pb.GeneratedMessage {
  factory ClientRelationshipGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  ClientRelationshipGetRequest._() : super();
  factory ClientRelationshipGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientRelationshipGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientRelationshipGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientRelationshipGetRequest clone() => ClientRelationshipGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientRelationshipGetRequest copyWith(void Function(ClientRelationshipGetRequest) updates) => super.copyWith((message) => updates(message as ClientRelationshipGetRequest)) as ClientRelationshipGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientRelationshipGetRequest create() => ClientRelationshipGetRequest._();
  ClientRelationshipGetRequest createEmptyInstance() => create();
  static $pb.PbList<ClientRelationshipGetRequest> createRepeated() => $pb.PbList<ClientRelationshipGetRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientRelationshipGetRequest>(create);
  static ClientRelationshipGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class ClientRelationshipGetResponse extends $pb.GeneratedMessage {
  factory ClientRelationshipGetResponse({
    ClientRelationshipObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientRelationshipGetResponse._() : super();
  factory ClientRelationshipGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientRelationshipGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientRelationshipGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOM<ClientRelationshipObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientRelationshipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientRelationshipGetResponse clone() => ClientRelationshipGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientRelationshipGetResponse copyWith(void Function(ClientRelationshipGetResponse) updates) => super.copyWith((message) => updates(message as ClientRelationshipGetResponse)) as ClientRelationshipGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientRelationshipGetResponse create() => ClientRelationshipGetResponse._();
  ClientRelationshipGetResponse createEmptyInstance() => create();
  static $pb.PbList<ClientRelationshipGetResponse> createRepeated() => $pb.PbList<ClientRelationshipGetResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientRelationshipGetResponse>(create);
  static ClientRelationshipGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientRelationshipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientRelationshipObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientRelationshipObject ensureData() => $_ensure(0);
}

class ClientRelationshipSearchRequest extends $pb.GeneratedMessage {
  factory ClientRelationshipSearchRequest({
    $core.String? clientId,
    $core.String? memberId,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (memberId != null) {
      $result.memberId = memberId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  ClientRelationshipSearchRequest._() : super();
  factory ClientRelationshipSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientRelationshipSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientRelationshipSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'memberId')
    ..aOM<$7.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientRelationshipSearchRequest clone() => ClientRelationshipSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientRelationshipSearchRequest copyWith(void Function(ClientRelationshipSearchRequest) updates) => super.copyWith((message) => updates(message as ClientRelationshipSearchRequest)) as ClientRelationshipSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSearchRequest create() => ClientRelationshipSearchRequest._();
  ClientRelationshipSearchRequest createEmptyInstance() => create();
  static $pb.PbList<ClientRelationshipSearchRequest> createRepeated() => $pb.PbList<ClientRelationshipSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientRelationshipSearchRequest>(create);
  static ClientRelationshipSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get memberId => $_getSZ(1);
  @$pb.TagNumber(2)
  set memberId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => clearField(2);

  @$pb.TagNumber(3)
  $7.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($7.PageCursor v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => clearField(3);
  @$pb.TagNumber(3)
  $7.PageCursor ensureCursor() => $_ensure(2);
}

class ClientRelationshipSearchResponse extends $pb.GeneratedMessage {
  factory ClientRelationshipSearchResponse({
    $core.Iterable<ClientRelationshipObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  ClientRelationshipSearchResponse._() : super();
  factory ClientRelationshipSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientRelationshipSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientRelationshipSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'), createEmptyInstance: create)
    ..pc<ClientRelationshipObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: ClientRelationshipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientRelationshipSearchResponse clone() => ClientRelationshipSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientRelationshipSearchResponse copyWith(void Function(ClientRelationshipSearchResponse) updates) => super.copyWith((message) => updates(message as ClientRelationshipSearchResponse)) as ClientRelationshipSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSearchResponse create() => ClientRelationshipSearchResponse._();
  ClientRelationshipSearchResponse createEmptyInstance() => create();
  static $pb.PbList<ClientRelationshipSearchResponse> createRepeated() => $pb.PbList<ClientRelationshipSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientRelationshipSearchResponse>(create);
  static ClientRelationshipSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ClientRelationshipObject> get data => $_getList(0);
}

class FieldServiceApi {
  $pb.RpcClient _client;
  FieldServiceApi(this._client);

  $async.Future<AgentSaveResponse> agentSave($pb.ClientContext? ctx, AgentSaveRequest request) =>
    _client.invoke<AgentSaveResponse>(ctx, 'FieldService', 'AgentSave', request, AgentSaveResponse())
  ;
  $async.Future<AgentGetResponse> agentGet($pb.ClientContext? ctx, AgentGetRequest request) =>
    _client.invoke<AgentGetResponse>(ctx, 'FieldService', 'AgentGet', request, AgentGetResponse())
  ;
  $async.Future<AgentSearchResponse> agentSearch($pb.ClientContext? ctx, AgentSearchRequest request) =>
    _client.invoke<AgentSearchResponse>(ctx, 'FieldService', 'AgentSearch', request, AgentSearchResponse())
  ;
  $async.Future<AgentHierarchyResponse> agentHierarchy($pb.ClientContext? ctx, AgentHierarchyRequest request) =>
    _client.invoke<AgentHierarchyResponse>(ctx, 'FieldService', 'AgentHierarchy', request, AgentHierarchyResponse())
  ;
  $async.Future<AgentBranchSaveResponse> agentBranchSave($pb.ClientContext? ctx, AgentBranchSaveRequest request) =>
    _client.invoke<AgentBranchSaveResponse>(ctx, 'FieldService', 'AgentBranchSave', request, AgentBranchSaveResponse())
  ;
  $async.Future<AgentBranchDeleteResponse> agentBranchDelete($pb.ClientContext? ctx, AgentBranchDeleteRequest request) =>
    _client.invoke<AgentBranchDeleteResponse>(ctx, 'FieldService', 'AgentBranchDelete', request, AgentBranchDeleteResponse())
  ;
  $async.Future<AgentBranchListResponse> agentBranchList($pb.ClientContext? ctx, AgentBranchListRequest request) =>
    _client.invoke<AgentBranchListResponse>(ctx, 'FieldService', 'AgentBranchList', request, AgentBranchListResponse())
  ;
  $async.Future<ClientSaveResponse> clientSave($pb.ClientContext? ctx, ClientSaveRequest request) =>
    _client.invoke<ClientSaveResponse>(ctx, 'FieldService', 'ClientSave', request, ClientSaveResponse())
  ;
  $async.Future<ClientGetResponse> clientGet($pb.ClientContext? ctx, ClientGetRequest request) =>
    _client.invoke<ClientGetResponse>(ctx, 'FieldService', 'ClientGet', request, ClientGetResponse())
  ;
  $async.Future<ClientSearchResponse> clientSearch($pb.ClientContext? ctx, ClientSearchRequest request) =>
    _client.invoke<ClientSearchResponse>(ctx, 'FieldService', 'ClientSearch', request, ClientSearchResponse())
  ;
  $async.Future<ClientReassignResponse> clientReassign($pb.ClientContext? ctx, ClientReassignRequest request) =>
    _client.invoke<ClientReassignResponse>(ctx, 'FieldService', 'ClientReassign', request, ClientReassignResponse())
  ;
  $async.Future<ClientOwnershipTransferResponse> clientOwnershipTransfer($pb.ClientContext? ctx, ClientOwnershipTransferRequest request) =>
    _client.invoke<ClientOwnershipTransferResponse>(ctx, 'FieldService', 'ClientOwnershipTransfer', request, ClientOwnershipTransferResponse())
  ;
  $async.Future<ClientRelationshipSaveResponse> clientRelationshipSave($pb.ClientContext? ctx, ClientRelationshipSaveRequest request) =>
    _client.invoke<ClientRelationshipSaveResponse>(ctx, 'FieldService', 'ClientRelationshipSave', request, ClientRelationshipSaveResponse())
  ;
  $async.Future<ClientRelationshipGetResponse> clientRelationshipGet($pb.ClientContext? ctx, ClientRelationshipGetRequest request) =>
    _client.invoke<ClientRelationshipGetResponse>(ctx, 'FieldService', 'ClientRelationshipGet', request, ClientRelationshipGetResponse())
  ;
  $async.Future<ClientRelationshipSearchResponse> clientRelationshipSearch($pb.ClientContext? ctx, ClientRelationshipSearchRequest request) =>
    _client.invoke<ClientRelationshipSearchResponse>(ctx, 'FieldService', 'ClientRelationshipSearch', request, ClientRelationshipSearchResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
