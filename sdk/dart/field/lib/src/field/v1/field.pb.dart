// This is a generated file - do not edit.
//
// Generated from field/v1/field.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $0;

import '../../common/v1/common.pb.dart' as $1;
import 'field.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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
    $1.STATE? state,
    $0.Struct? properties,
    $core.Iterable<$core.String>? branchIds,
  }) {
    final result = AgentObject._();
    if (id != null) result.id = id;
    if (organizationId != null) result.organizationId = organizationId;
    if (parentAgentId != null) result.parentAgentId = parentAgentId;
    if (profileId != null) result.profileId = profileId;
    if (agentType != null) result.agentType = agentType;
    if (name != null) result.name = name;
    if (geoId != null) result.geoId = geoId;
    if (depth != null) result.depth = depth;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    if (branchIds != null) result.branchIds.addAll(branchIds);
    return result;
  }

  AgentObject._();

  factory AgentObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentObject()..mergeFromBuffer(data, registry);
  factory AgentObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentAgentId')
    ..aOS(4, _omitFieldNames ? '' : 'profileId')
    ..aE<AgentType>(5, _omitFieldNames ? '' : 'agentType',
        enumValues: AgentType.values)
    ..aOS(6, _omitFieldNames ? '' : 'name')
    ..aOS(7, _omitFieldNames ? '' : 'geoId')
    ..aI(8, _omitFieldNames ? '' : 'depth')
    ..aE<$1.STATE>(9, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(10, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..pPS(11, _omitFieldNames ? '' : 'branchIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentObject copyWith(void Function(AgentObject) updates) =>
      super.copyWith((message) => updates(message as AgentObject))
          as AgentObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AgentObject() / AgentObject.new instead')
  static AgentObject create() => AgentObject._();
  static $pb.GeneratedMessage $_createMessage() => AgentObject._();
  @$core.override
  AgentObject createEmptyInstance() => AgentObject._();
  @$core.pragma('dart2js:noInline')
  static AgentObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentObject>(
          AgentObject.$_createMessage);
  static AgentObject? _defaultInstance;

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
  $core.String get parentAgentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentAgentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentAgentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get profileId => $_getSZ(3);
  @$pb.TagNumber(4)
  set profileId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProfileId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProfileId() => $_clearField(4);

  @$pb.TagNumber(5)
  AgentType get agentType => $_getN(4);
  @$pb.TagNumber(5)
  set agentType(AgentType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAgentType() => $_has(4);
  @$pb.TagNumber(5)
  void clearAgentType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(6)
  set name($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(6)
  void clearName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get geoId => $_getSZ(6);
  @$pb.TagNumber(7)
  set geoId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGeoId() => $_has(6);
  @$pb.TagNumber(7)
  void clearGeoId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get depth => $_getIZ(7);
  @$pb.TagNumber(8)
  set depth($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDepth() => $_has(7);
  @$pb.TagNumber(8)
  void clearDepth() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.STATE get state => $_getN(8);
  @$pb.TagNumber(9)
  set state($1.STATE value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasState() => $_has(8);
  @$pb.TagNumber(9)
  void clearState() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Struct get properties => $_getN(9);
  @$pb.TagNumber(10)
  set properties($0.Struct value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasProperties() => $_has(9);
  @$pb.TagNumber(10)
  void clearProperties() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Struct ensureProperties() => $_ensure(9);

  @$pb.TagNumber(11)
  $pb.PbList<$core.String> get branchIds => $_getList(10);
}

/// AgentBranchObject links an agent to a branch.
/// Supports per-branch properties such as commission structures.
class AgentBranchObject extends $pb.GeneratedMessage {
  factory AgentBranchObject({
    $core.String? id,
    $core.String? agentId,
    $core.String? branchId,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = AgentBranchObject._();
    if (id != null) result.id = id;
    if (agentId != null) result.agentId = agentId;
    if (branchId != null) result.branchId = branchId;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  AgentBranchObject._();

  factory AgentBranchObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchObject()..mergeFromBuffer(data, registry);
  factory AgentBranchObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentBranchObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentBranchObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'agentId')
    ..aOS(3, _omitFieldNames ? '' : 'branchId')
    ..aE<$1.STATE>(4, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(5, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchObject copyWith(void Function(AgentBranchObject) updates) =>
      super.copyWith((message) => updates(message as AgentBranchObject))
          as AgentBranchObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AgentBranchObject() / AgentBranchObject.new instead')
  static AgentBranchObject create() => AgentBranchObject._();
  static $pb.GeneratedMessage $_createMessage() => AgentBranchObject._();
  @$core.override
  AgentBranchObject createEmptyInstance() => AgentBranchObject._();
  @$core.pragma('dart2js:noInline')
  static AgentBranchObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentBranchObject>(
          AgentBranchObject.$_createMessage);
  static AgentBranchObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get agentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set agentId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAgentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAgentId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get branchId => $_getSZ(2);
  @$pb.TagNumber(3)
  set branchId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBranchId() => $_has(2);
  @$pb.TagNumber(3)
  void clearBranchId() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.STATE get state => $_getN(3);
  @$pb.TagNumber(4)
  set state($1.STATE value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasState() => $_has(3);
  @$pb.TagNumber(4)
  void clearState() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Struct get properties => $_getN(4);
  @$pb.TagNumber(5)
  set properties($0.Struct value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasProperties() => $_has(4);
  @$pb.TagNumber(5)
  void clearProperties() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Struct ensureProperties() => $_ensure(4);
}

/// ClientObject represents a loan recipient owned by a team.
/// Client-to-member relationships are managed via ClientRelationshipObject.
class ClientObject extends $pb.GeneratedMessage {
  factory ClientObject({
    $core.String? id,
    $core.String? agentId,
    $core.String? profileId,
    $core.String? name,
    $1.STATE? state,
    $0.Struct? properties,
    $core.String? owningTeamId,
  }) {
    final result = ClientObject._();
    if (id != null) result.id = id;
    if (agentId != null) result.agentId = agentId;
    if (profileId != null) result.profileId = profileId;
    if (name != null) result.name = name;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    if (owningTeamId != null) result.owningTeamId = owningTeamId;
    return result;
  }

  ClientObject._();

  factory ClientObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientObject()..mergeFromBuffer(data, registry);
  factory ClientObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'agentId')
    ..aOS(3, _omitFieldNames ? '' : 'profileId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aE<$1.STATE>(5, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(6, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..aOS(7, _omitFieldNames ? '' : 'owningTeamId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientObject copyWith(void Function(ClientObject) updates) =>
      super.copyWith((message) => updates(message as ClientObject))
          as ClientObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClientObject() / ClientObject.new instead')
  static ClientObject create() => ClientObject._();
  static $pb.GeneratedMessage $_createMessage() => ClientObject._();
  @$core.override
  ClientObject createEmptyInstance() => ClientObject._();
  @$core.pragma('dart2js:noInline')
  static ClientObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientObject>(
          ClientObject.$_createMessage);
  static ClientObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get agentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set agentId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAgentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAgentId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get profileId => $_getSZ(2);
  @$pb.TagNumber(3)
  set profileId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProfileId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProfileId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $1.STATE get state => $_getN(4);
  @$pb.TagNumber(5)
  set state($1.STATE value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasState() => $_has(4);
  @$pb.TagNumber(5)
  void clearState() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Struct get properties => $_getN(5);
  @$pb.TagNumber(6)
  set properties($0.Struct value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasProperties() => $_has(5);
  @$pb.TagNumber(6)
  void clearProperties() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Struct ensureProperties() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get owningTeamId => $_getSZ(6);
  @$pb.TagNumber(7)
  set owningTeamId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOwningTeamId() => $_has(6);
  @$pb.TagNumber(7)
  void clearOwningTeamId() => $_clearField(7);
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
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = ClientRelationshipObject._();
    if (id != null) result.id = id;
    if (clientId != null) result.clientId = clientId;
    if (memberId != null) result.memberId = memberId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (isPrimary != null) result.isPrimary = isPrimary;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  ClientRelationshipObject._();

  factory ClientRelationshipObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipObject()..mergeFromBuffer(data, registry);
  factory ClientRelationshipObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientRelationshipObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientRelationshipObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'clientId')
    ..aOS(3, _omitFieldNames ? '' : 'memberId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aOB(6, _omitFieldNames ? '' : 'isPrimary')
    ..aE<$1.STATE>(7, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(8, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipObject copyWith(
          void Function(ClientRelationshipObject) updates) =>
      super.copyWith((message) => updates(message as ClientRelationshipObject))
          as ClientRelationshipObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientRelationshipObject() / ClientRelationshipObject.new instead')
  static ClientRelationshipObject create() => ClientRelationshipObject._();
  static $pb.GeneratedMessage $_createMessage() => ClientRelationshipObject._();
  @$core.override
  ClientRelationshipObject createEmptyInstance() =>
      ClientRelationshipObject._();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientRelationshipObject>(
          ClientRelationshipObject.$_createMessage);
  static ClientRelationshipObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get memberId => $_getSZ(2);
  @$pb.TagNumber(3)
  set memberId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMemberId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isPrimary => $_getBF(5);
  @$pb.TagNumber(6)
  set isPrimary($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsPrimary() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsPrimary() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.STATE get state => $_getN(6);
  @$pb.TagNumber(7)
  set state($1.STATE value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasState() => $_has(6);
  @$pb.TagNumber(7)
  void clearState() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Struct get properties => $_getN(7);
  @$pb.TagNumber(8)
  set properties($0.Struct value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasProperties() => $_has(7);
  @$pb.TagNumber(8)
  void clearProperties() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Struct ensureProperties() => $_ensure(7);
}

/// Agent messages
class AgentSaveRequest extends $pb.GeneratedMessage {
  factory AgentSaveRequest({
    AgentObject? data,
  }) {
    final result = AgentSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  AgentSaveRequest._();

  factory AgentSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentSaveRequest()..mergeFromBuffer(data, registry);
  factory AgentSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentSaveRequest.$_createMessage)
    ..aOM<AgentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AgentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentSaveRequest copyWith(void Function(AgentSaveRequest) updates) =>
      super.copyWith((message) => updates(message as AgentSaveRequest))
          as AgentSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AgentSaveRequest() / AgentSaveRequest.new instead')
  static AgentSaveRequest create() => AgentSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => AgentSaveRequest._();
  @$core.override
  AgentSaveRequest createEmptyInstance() => AgentSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static AgentSaveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentSaveRequest>(
          AgentSaveRequest.$_createMessage);
  static AgentSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  AgentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AgentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  AgentObject ensureData() => $_ensure(0);
}

class AgentSaveResponse extends $pb.GeneratedMessage {
  factory AgentSaveResponse({
    AgentObject? data,
  }) {
    final result = AgentSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  AgentSaveResponse._();

  factory AgentSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentSaveResponse()..mergeFromBuffer(data, registry);
  factory AgentSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentSaveResponse.$_createMessage)
    ..aOM<AgentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AgentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentSaveResponse copyWith(void Function(AgentSaveResponse) updates) =>
      super.copyWith((message) => updates(message as AgentSaveResponse))
          as AgentSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AgentSaveResponse() / AgentSaveResponse.new instead')
  static AgentSaveResponse create() => AgentSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => AgentSaveResponse._();
  @$core.override
  AgentSaveResponse createEmptyInstance() => AgentSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static AgentSaveResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentSaveResponse>(
          AgentSaveResponse.$_createMessage);
  static AgentSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AgentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AgentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  AgentObject ensureData() => $_ensure(0);
}

class AgentGetRequest extends $pb.GeneratedMessage {
  factory AgentGetRequest({
    $core.String? id,
  }) {
    final result = AgentGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  AgentGetRequest._();

  factory AgentGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentGetRequest()..mergeFromBuffer(data, registry);
  factory AgentGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentGetRequest copyWith(void Function(AgentGetRequest) updates) =>
      super.copyWith((message) => updates(message as AgentGetRequest))
          as AgentGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AgentGetRequest() / AgentGetRequest.new instead')
  static AgentGetRequest create() => AgentGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => AgentGetRequest._();
  @$core.override
  AgentGetRequest createEmptyInstance() => AgentGetRequest._();
  @$core.pragma('dart2js:noInline')
  static AgentGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentGetRequest>(
          AgentGetRequest.$_createMessage);
  static AgentGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class AgentGetResponse extends $pb.GeneratedMessage {
  factory AgentGetResponse({
    AgentObject? data,
  }) {
    final result = AgentGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  AgentGetResponse._();

  factory AgentGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentGetResponse()..mergeFromBuffer(data, registry);
  factory AgentGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentGetResponse.$_createMessage)
    ..aOM<AgentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AgentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentGetResponse copyWith(void Function(AgentGetResponse) updates) =>
      super.copyWith((message) => updates(message as AgentGetResponse))
          as AgentGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AgentGetResponse() / AgentGetResponse.new instead')
  static AgentGetResponse create() => AgentGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => AgentGetResponse._();
  @$core.override
  AgentGetResponse createEmptyInstance() => AgentGetResponse._();
  @$core.pragma('dart2js:noInline')
  static AgentGetResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgentGetResponse>(
          AgentGetResponse.$_createMessage);
  static AgentGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AgentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AgentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  AgentObject ensureData() => $_ensure(0);
}

class AgentSearchRequest extends $pb.GeneratedMessage {
  factory AgentSearchRequest({
    $core.String? query,
    $core.String? branchId,
    $core.String? parentAgentId,
    $1.PageCursor? cursor,
    $core.String? organizationId,
  }) {
    final result = AgentSearchRequest._();
    if (query != null) result.query = query;
    if (branchId != null) result.branchId = branchId;
    if (parentAgentId != null) result.parentAgentId = parentAgentId;
    if (cursor != null) result.cursor = cursor;
    if (organizationId != null) result.organizationId = organizationId;
    return result;
  }

  AgentSearchRequest._();

  factory AgentSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentSearchRequest()..mergeFromBuffer(data, registry);
  factory AgentSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'branchId')
    ..aOS(3, _omitFieldNames ? '' : 'parentAgentId')
    ..aOM<$1.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..aOS(5, _omitFieldNames ? '' : 'organizationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentSearchRequest copyWith(void Function(AgentSearchRequest) updates) =>
      super.copyWith((message) => updates(message as AgentSearchRequest))
          as AgentSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AgentSearchRequest() / AgentSearchRequest.new instead')
  static AgentSearchRequest create() => AgentSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => AgentSearchRequest._();
  @$core.override
  AgentSearchRequest createEmptyInstance() => AgentSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static AgentSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgentSearchRequest>(
          AgentSearchRequest.$_createMessage);
  static AgentSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get branchId => $_getSZ(1);
  @$pb.TagNumber(2)
  set branchId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBranchId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBranchId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get parentAgentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentAgentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentAgentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentAgentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.PageCursor get cursor => $_getN(3);
  @$pb.TagNumber(4)
  set cursor($1.PageCursor value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursor() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.PageCursor ensureCursor() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get organizationId => $_getSZ(4);
  @$pb.TagNumber(5)
  set organizationId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOrganizationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOrganizationId() => $_clearField(5);
}

class AgentSearchResponse extends $pb.GeneratedMessage {
  factory AgentSearchResponse({
    $core.Iterable<AgentObject>? data,
  }) {
    final result = AgentSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  AgentSearchResponse._();

  factory AgentSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentSearchResponse()..mergeFromBuffer(data, registry);
  factory AgentSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentSearchResponse.$_createMessage)
    ..pPM<AgentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AgentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentSearchResponse copyWith(void Function(AgentSearchResponse) updates) =>
      super.copyWith((message) => updates(message as AgentSearchResponse))
          as AgentSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use AgentSearchResponse() / AgentSearchResponse.new instead')
  static AgentSearchResponse create() => AgentSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => AgentSearchResponse._();
  @$core.override
  AgentSearchResponse createEmptyInstance() => AgentSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static AgentSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgentSearchResponse>(
          AgentSearchResponse.$_createMessage);
  static AgentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AgentObject> get data => $_getList(0);
}

/// AgentHierarchyRequest retrieves an agent's descendant tree.
class AgentHierarchyRequest extends $pb.GeneratedMessage {
  factory AgentHierarchyRequest({
    $core.String? agentId,
    $core.int? maxDepth,
  }) {
    final result = AgentHierarchyRequest._();
    if (agentId != null) result.agentId = agentId;
    if (maxDepth != null) result.maxDepth = maxDepth;
    return result;
  }

  AgentHierarchyRequest._();

  factory AgentHierarchyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentHierarchyRequest()..mergeFromBuffer(data, registry);
  factory AgentHierarchyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentHierarchyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentHierarchyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentHierarchyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'agentId')
    ..aI(2, _omitFieldNames ? '' : 'maxDepth')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentHierarchyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentHierarchyRequest copyWith(
          void Function(AgentHierarchyRequest) updates) =>
      super.copyWith((message) => updates(message as AgentHierarchyRequest))
          as AgentHierarchyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AgentHierarchyRequest() / AgentHierarchyRequest.new instead')
  static AgentHierarchyRequest create() => AgentHierarchyRequest._();
  static $pb.GeneratedMessage $_createMessage() => AgentHierarchyRequest._();
  @$core.override
  AgentHierarchyRequest createEmptyInstance() => AgentHierarchyRequest._();
  @$core.pragma('dart2js:noInline')
  static AgentHierarchyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgentHierarchyRequest>(
          AgentHierarchyRequest.$_createMessage);
  static AgentHierarchyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get agentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set agentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAgentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAgentId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxDepth => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxDepth($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxDepth() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxDepth() => $_clearField(2);
}

class AgentHierarchyResponse extends $pb.GeneratedMessage {
  factory AgentHierarchyResponse({
    $core.Iterable<AgentObject>? data,
  }) {
    final result = AgentHierarchyResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  AgentHierarchyResponse._();

  factory AgentHierarchyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentHierarchyResponse()..mergeFromBuffer(data, registry);
  factory AgentHierarchyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentHierarchyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentHierarchyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentHierarchyResponse.$_createMessage)
    ..pPM<AgentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AgentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentHierarchyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentHierarchyResponse copyWith(
          void Function(AgentHierarchyResponse) updates) =>
      super.copyWith((message) => updates(message as AgentHierarchyResponse))
          as AgentHierarchyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AgentHierarchyResponse() / AgentHierarchyResponse.new instead')
  static AgentHierarchyResponse create() => AgentHierarchyResponse._();
  static $pb.GeneratedMessage $_createMessage() => AgentHierarchyResponse._();
  @$core.override
  AgentHierarchyResponse createEmptyInstance() => AgentHierarchyResponse._();
  @$core.pragma('dart2js:noInline')
  static AgentHierarchyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgentHierarchyResponse>(
          AgentHierarchyResponse.$_createMessage);
  static AgentHierarchyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AgentObject> get data => $_getList(0);
}

/// Agent branch assignment messages
class AgentBranchSaveRequest extends $pb.GeneratedMessage {
  factory AgentBranchSaveRequest({
    AgentBranchObject? data,
  }) {
    final result = AgentBranchSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  AgentBranchSaveRequest._();

  factory AgentBranchSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchSaveRequest()..mergeFromBuffer(data, registry);
  factory AgentBranchSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentBranchSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentBranchSaveRequest.$_createMessage)
    ..aOM<AgentBranchObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AgentBranchObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchSaveRequest copyWith(
          void Function(AgentBranchSaveRequest) updates) =>
      super.copyWith((message) => updates(message as AgentBranchSaveRequest))
          as AgentBranchSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AgentBranchSaveRequest() / AgentBranchSaveRequest.new instead')
  static AgentBranchSaveRequest create() => AgentBranchSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => AgentBranchSaveRequest._();
  @$core.override
  AgentBranchSaveRequest createEmptyInstance() => AgentBranchSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static AgentBranchSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgentBranchSaveRequest>(
          AgentBranchSaveRequest.$_createMessage);
  static AgentBranchSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  AgentBranchObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AgentBranchObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  AgentBranchObject ensureData() => $_ensure(0);
}

class AgentBranchSaveResponse extends $pb.GeneratedMessage {
  factory AgentBranchSaveResponse({
    AgentBranchObject? data,
  }) {
    final result = AgentBranchSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  AgentBranchSaveResponse._();

  factory AgentBranchSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchSaveResponse()..mergeFromBuffer(data, registry);
  factory AgentBranchSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentBranchSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentBranchSaveResponse.$_createMessage)
    ..aOM<AgentBranchObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AgentBranchObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchSaveResponse copyWith(
          void Function(AgentBranchSaveResponse) updates) =>
      super.copyWith((message) => updates(message as AgentBranchSaveResponse))
          as AgentBranchSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AgentBranchSaveResponse() / AgentBranchSaveResponse.new instead')
  static AgentBranchSaveResponse create() => AgentBranchSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => AgentBranchSaveResponse._();
  @$core.override
  AgentBranchSaveResponse createEmptyInstance() => AgentBranchSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static AgentBranchSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgentBranchSaveResponse>(
          AgentBranchSaveResponse.$_createMessage);
  static AgentBranchSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AgentBranchObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AgentBranchObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  AgentBranchObject ensureData() => $_ensure(0);
}

class AgentBranchDeleteRequest extends $pb.GeneratedMessage {
  factory AgentBranchDeleteRequest({
    $core.String? id,
  }) {
    final result = AgentBranchDeleteRequest._();
    if (id != null) result.id = id;
    return result;
  }

  AgentBranchDeleteRequest._();

  factory AgentBranchDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchDeleteRequest()..mergeFromBuffer(data, registry);
  factory AgentBranchDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentBranchDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentBranchDeleteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchDeleteRequest copyWith(
          void Function(AgentBranchDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as AgentBranchDeleteRequest))
          as AgentBranchDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AgentBranchDeleteRequest() / AgentBranchDeleteRequest.new instead')
  static AgentBranchDeleteRequest create() => AgentBranchDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => AgentBranchDeleteRequest._();
  @$core.override
  AgentBranchDeleteRequest createEmptyInstance() =>
      AgentBranchDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static AgentBranchDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgentBranchDeleteRequest>(
          AgentBranchDeleteRequest.$_createMessage);
  static AgentBranchDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class AgentBranchDeleteResponse extends $pb.GeneratedMessage {
  factory AgentBranchDeleteResponse() => AgentBranchDeleteResponse._();

  AgentBranchDeleteResponse._();

  factory AgentBranchDeleteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchDeleteResponse()..mergeFromBuffer(data, registry);
  factory AgentBranchDeleteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchDeleteResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentBranchDeleteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentBranchDeleteResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchDeleteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchDeleteResponse copyWith(
          void Function(AgentBranchDeleteResponse) updates) =>
      super.copyWith((message) => updates(message as AgentBranchDeleteResponse))
          as AgentBranchDeleteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AgentBranchDeleteResponse() / AgentBranchDeleteResponse.new instead')
  static AgentBranchDeleteResponse create() => AgentBranchDeleteResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      AgentBranchDeleteResponse._();
  @$core.override
  AgentBranchDeleteResponse createEmptyInstance() =>
      AgentBranchDeleteResponse._();
  @$core.pragma('dart2js:noInline')
  static AgentBranchDeleteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgentBranchDeleteResponse>(
          AgentBranchDeleteResponse.$_createMessage);
  static AgentBranchDeleteResponse? _defaultInstance;
}

class AgentBranchListRequest extends $pb.GeneratedMessage {
  factory AgentBranchListRequest({
    $core.String? agentId,
    $core.String? branchId,
    $1.PageCursor? cursor,
  }) {
    final result = AgentBranchListRequest._();
    if (agentId != null) result.agentId = agentId;
    if (branchId != null) result.branchId = branchId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  AgentBranchListRequest._();

  factory AgentBranchListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchListRequest()..mergeFromBuffer(data, registry);
  factory AgentBranchListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentBranchListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentBranchListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'agentId')
    ..aOS(2, _omitFieldNames ? '' : 'branchId')
    ..aOM<$1.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchListRequest copyWith(
          void Function(AgentBranchListRequest) updates) =>
      super.copyWith((message) => updates(message as AgentBranchListRequest))
          as AgentBranchListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AgentBranchListRequest() / AgentBranchListRequest.new instead')
  static AgentBranchListRequest create() => AgentBranchListRequest._();
  static $pb.GeneratedMessage $_createMessage() => AgentBranchListRequest._();
  @$core.override
  AgentBranchListRequest createEmptyInstance() => AgentBranchListRequest._();
  @$core.pragma('dart2js:noInline')
  static AgentBranchListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgentBranchListRequest>(
          AgentBranchListRequest.$_createMessage);
  static AgentBranchListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get agentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set agentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAgentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAgentId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get branchId => $_getSZ(1);
  @$pb.TagNumber(2)
  set branchId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBranchId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBranchId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($1.PageCursor value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.PageCursor ensureCursor() => $_ensure(2);
}

class AgentBranchListResponse extends $pb.GeneratedMessage {
  factory AgentBranchListResponse({
    $core.Iterable<AgentBranchObject>? data,
  }) {
    final result = AgentBranchListResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  AgentBranchListResponse._();

  factory AgentBranchListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchListResponse()..mergeFromBuffer(data, registry);
  factory AgentBranchListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AgentBranchListResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgentBranchListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: AgentBranchListResponse.$_createMessage)
    ..pPM<AgentBranchObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AgentBranchObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgentBranchListResponse copyWith(
          void Function(AgentBranchListResponse) updates) =>
      super.copyWith((message) => updates(message as AgentBranchListResponse))
          as AgentBranchListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AgentBranchListResponse() / AgentBranchListResponse.new instead')
  static AgentBranchListResponse create() => AgentBranchListResponse._();
  static $pb.GeneratedMessage $_createMessage() => AgentBranchListResponse._();
  @$core.override
  AgentBranchListResponse createEmptyInstance() => AgentBranchListResponse._();
  @$core.pragma('dart2js:noInline')
  static AgentBranchListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgentBranchListResponse>(
          AgentBranchListResponse.$_createMessage);
  static AgentBranchListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AgentBranchObject> get data => $_getList(0);
}

/// Client messages
class ClientSaveRequest extends $pb.GeneratedMessage {
  factory ClientSaveRequest({
    ClientObject? data,
  }) {
    final result = ClientSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  ClientSaveRequest._();

  factory ClientSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientSaveRequest()..mergeFromBuffer(data, registry);
  factory ClientSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientSaveRequest.$_createMessage)
    ..aOM<ClientObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientSaveRequest copyWith(void Function(ClientSaveRequest) updates) =>
      super.copyWith((message) => updates(message as ClientSaveRequest))
          as ClientSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClientSaveRequest() / ClientSaveRequest.new instead')
  static ClientSaveRequest create() => ClientSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientSaveRequest._();
  @$core.override
  ClientSaveRequest createEmptyInstance() => ClientSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientSaveRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientSaveRequest>(
          ClientSaveRequest.$_createMessage);
  static ClientSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ClientObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientObject ensureData() => $_ensure(0);
}

class ClientSaveResponse extends $pb.GeneratedMessage {
  factory ClientSaveResponse({
    ClientObject? data,
  }) {
    final result = ClientSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientSaveResponse._();

  factory ClientSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientSaveResponse()..mergeFromBuffer(data, registry);
  factory ClientSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientSaveResponse.$_createMessage)
    ..aOM<ClientObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientSaveResponse copyWith(void Function(ClientSaveResponse) updates) =>
      super.copyWith((message) => updates(message as ClientSaveResponse))
          as ClientSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClientSaveResponse() / ClientSaveResponse.new instead')
  static ClientSaveResponse create() => ClientSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientSaveResponse._();
  @$core.override
  ClientSaveResponse createEmptyInstance() => ClientSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientSaveResponse>(
          ClientSaveResponse.$_createMessage);
  static ClientSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientObject ensureData() => $_ensure(0);
}

class ClientGetRequest extends $pb.GeneratedMessage {
  factory ClientGetRequest({
    $core.String? id,
  }) {
    final result = ClientGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  ClientGetRequest._();

  factory ClientGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGetRequest()..mergeFromBuffer(data, registry);
  factory ClientGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGetRequest copyWith(void Function(ClientGetRequest) updates) =>
      super.copyWith((message) => updates(message as ClientGetRequest))
          as ClientGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClientGetRequest() / ClientGetRequest.new instead')
  static ClientGetRequest create() => ClientGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientGetRequest._();
  @$core.override
  ClientGetRequest createEmptyInstance() => ClientGetRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGetRequest>(
          ClientGetRequest.$_createMessage);
  static ClientGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ClientGetResponse extends $pb.GeneratedMessage {
  factory ClientGetResponse({
    ClientObject? data,
  }) {
    final result = ClientGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientGetResponse._();

  factory ClientGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGetResponse()..mergeFromBuffer(data, registry);
  factory ClientGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientGetResponse.$_createMessage)
    ..aOM<ClientObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGetResponse copyWith(void Function(ClientGetResponse) updates) =>
      super.copyWith((message) => updates(message as ClientGetResponse))
          as ClientGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClientGetResponse() / ClientGetResponse.new instead')
  static ClientGetResponse create() => ClientGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientGetResponse._();
  @$core.override
  ClientGetResponse createEmptyInstance() => ClientGetResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientGetResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGetResponse>(
          ClientGetResponse.$_createMessage);
  static ClientGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientObject ensureData() => $_ensure(0);
}

class ClientSearchRequest extends $pb.GeneratedMessage {
  factory ClientSearchRequest({
    $core.String? query,
    $core.String? agentId,
    $1.PageCursor? cursor,
    $core.String? owningTeamId,
    $core.String? memberId,
    $core.String? profileId,
  }) {
    final result = ClientSearchRequest._();
    if (query != null) result.query = query;
    if (agentId != null) result.agentId = agentId;
    if (cursor != null) result.cursor = cursor;
    if (owningTeamId != null) result.owningTeamId = owningTeamId;
    if (memberId != null) result.memberId = memberId;
    if (profileId != null) result.profileId = profileId;
    return result;
  }

  ClientSearchRequest._();

  factory ClientSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientSearchRequest()..mergeFromBuffer(data, registry);
  factory ClientSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'agentId')
    ..aOM<$1.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'owningTeamId')
    ..aOS(5, _omitFieldNames ? '' : 'memberId')
    ..aOS(6, _omitFieldNames ? '' : 'profileId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientSearchRequest copyWith(void Function(ClientSearchRequest) updates) =>
      super.copyWith((message) => updates(message as ClientSearchRequest))
          as ClientSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ClientSearchRequest() / ClientSearchRequest.new instead')
  static ClientSearchRequest create() => ClientSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientSearchRequest._();
  @$core.override
  ClientSearchRequest createEmptyInstance() => ClientSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientSearchRequest>(
          ClientSearchRequest.$_createMessage);
  static ClientSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get agentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set agentId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAgentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAgentId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($1.PageCursor value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.PageCursor ensureCursor() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get owningTeamId => $_getSZ(3);
  @$pb.TagNumber(4)
  set owningTeamId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOwningTeamId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOwningTeamId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get memberId => $_getSZ(4);
  @$pb.TagNumber(5)
  set memberId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMemberId() => $_has(4);
  @$pb.TagNumber(5)
  void clearMemberId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get profileId => $_getSZ(5);
  @$pb.TagNumber(6)
  set profileId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProfileId() => $_has(5);
  @$pb.TagNumber(6)
  void clearProfileId() => $_clearField(6);
}

class ClientSearchResponse extends $pb.GeneratedMessage {
  factory ClientSearchResponse({
    $core.Iterable<ClientObject>? data,
  }) {
    final result = ClientSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  ClientSearchResponse._();

  factory ClientSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientSearchResponse()..mergeFromBuffer(data, registry);
  factory ClientSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientSearchResponse.$_createMessage)
    ..pPM<ClientObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientSearchResponse copyWith(void Function(ClientSearchResponse) updates) =>
      super.copyWith((message) => updates(message as ClientSearchResponse))
          as ClientSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientSearchResponse() / ClientSearchResponse.new instead')
  static ClientSearchResponse create() => ClientSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientSearchResponse._();
  @$core.override
  ClientSearchResponse createEmptyInstance() => ClientSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientSearchResponse>(
          ClientSearchResponse.$_createMessage);
  static ClientSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ClientObject> get data => $_getList(0);
}

/// ClientReassignRequest moves a client to a different agent.
class ClientReassignRequest extends $pb.GeneratedMessage {
  factory ClientReassignRequest({
    $core.String? clientId,
    $core.String? newAgentId,
    $core.String? reason,
  }) {
    final result = ClientReassignRequest._();
    if (clientId != null) result.clientId = clientId;
    if (newAgentId != null) result.newAgentId = newAgentId;
    if (reason != null) result.reason = reason;
    return result;
  }

  ClientReassignRequest._();

  factory ClientReassignRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientReassignRequest()..mergeFromBuffer(data, registry);
  factory ClientReassignRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientReassignRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientReassignRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientReassignRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'newAgentId')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientReassignRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientReassignRequest copyWith(
          void Function(ClientReassignRequest) updates) =>
      super.copyWith((message) => updates(message as ClientReassignRequest))
          as ClientReassignRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientReassignRequest() / ClientReassignRequest.new instead')
  static ClientReassignRequest create() => ClientReassignRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientReassignRequest._();
  @$core.override
  ClientReassignRequest createEmptyInstance() => ClientReassignRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientReassignRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientReassignRequest>(
          ClientReassignRequest.$_createMessage);
  static ClientReassignRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get newAgentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set newAgentId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewAgentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewAgentId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);
}

class ClientReassignResponse extends $pb.GeneratedMessage {
  factory ClientReassignResponse({
    ClientObject? data,
  }) {
    final result = ClientReassignResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientReassignResponse._();

  factory ClientReassignResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientReassignResponse()..mergeFromBuffer(data, registry);
  factory ClientReassignResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientReassignResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientReassignResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientReassignResponse.$_createMessage)
    ..aOM<ClientObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientReassignResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientReassignResponse copyWith(
          void Function(ClientReassignResponse) updates) =>
      super.copyWith((message) => updates(message as ClientReassignResponse))
          as ClientReassignResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientReassignResponse() / ClientReassignResponse.new instead')
  static ClientReassignResponse create() => ClientReassignResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientReassignResponse._();
  @$core.override
  ClientReassignResponse createEmptyInstance() => ClientReassignResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientReassignResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientReassignResponse>(
          ClientReassignResponse.$_createMessage);
  static ClientReassignResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
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
    final result = ClientOwnershipTransferRequest._();
    if (clientId != null) result.clientId = clientId;
    if (newOwningTeamId != null) result.newOwningTeamId = newOwningTeamId;
    if (reason != null) result.reason = reason;
    return result;
  }

  ClientOwnershipTransferRequest._();

  factory ClientOwnershipTransferRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientOwnershipTransferRequest()..mergeFromBuffer(data, registry);
  factory ClientOwnershipTransferRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientOwnershipTransferRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientOwnershipTransferRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientOwnershipTransferRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'newOwningTeamId')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientOwnershipTransferRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientOwnershipTransferRequest copyWith(
          void Function(ClientOwnershipTransferRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClientOwnershipTransferRequest))
          as ClientOwnershipTransferRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientOwnershipTransferRequest() / ClientOwnershipTransferRequest.new instead')
  static ClientOwnershipTransferRequest create() =>
      ClientOwnershipTransferRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientOwnershipTransferRequest._();
  @$core.override
  ClientOwnershipTransferRequest createEmptyInstance() =>
      ClientOwnershipTransferRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientOwnershipTransferRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientOwnershipTransferRequest>(
          ClientOwnershipTransferRequest.$_createMessage);
  static ClientOwnershipTransferRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get newOwningTeamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set newOwningTeamId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewOwningTeamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewOwningTeamId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);
}

class ClientOwnershipTransferResponse extends $pb.GeneratedMessage {
  factory ClientOwnershipTransferResponse({
    ClientObject? data,
  }) {
    final result = ClientOwnershipTransferResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientOwnershipTransferResponse._();

  factory ClientOwnershipTransferResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientOwnershipTransferResponse()..mergeFromBuffer(data, registry);
  factory ClientOwnershipTransferResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientOwnershipTransferResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientOwnershipTransferResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientOwnershipTransferResponse.$_createMessage)
    ..aOM<ClientObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientOwnershipTransferResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientOwnershipTransferResponse copyWith(
          void Function(ClientOwnershipTransferResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClientOwnershipTransferResponse))
          as ClientOwnershipTransferResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientOwnershipTransferResponse() / ClientOwnershipTransferResponse.new instead')
  static ClientOwnershipTransferResponse create() =>
      ClientOwnershipTransferResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientOwnershipTransferResponse._();
  @$core.override
  ClientOwnershipTransferResponse createEmptyInstance() =>
      ClientOwnershipTransferResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientOwnershipTransferResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientOwnershipTransferResponse>(
          ClientOwnershipTransferResponse.$_createMessage);
  static ClientOwnershipTransferResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientObject ensureData() => $_ensure(0);
}

class ClientRelationshipSaveRequest extends $pb.GeneratedMessage {
  factory ClientRelationshipSaveRequest({
    ClientRelationshipObject? data,
  }) {
    final result = ClientRelationshipSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  ClientRelationshipSaveRequest._();

  factory ClientRelationshipSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipSaveRequest()..mergeFromBuffer(data, registry);
  factory ClientRelationshipSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientRelationshipSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientRelationshipSaveRequest.$_createMessage)
    ..aOM<ClientRelationshipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientRelationshipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipSaveRequest copyWith(
          void Function(ClientRelationshipSaveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClientRelationshipSaveRequest))
          as ClientRelationshipSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientRelationshipSaveRequest() / ClientRelationshipSaveRequest.new instead')
  static ClientRelationshipSaveRequest create() =>
      ClientRelationshipSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientRelationshipSaveRequest._();
  @$core.override
  ClientRelationshipSaveRequest createEmptyInstance() =>
      ClientRelationshipSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientRelationshipSaveRequest>(
          ClientRelationshipSaveRequest.$_createMessage);
  static ClientRelationshipSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ClientRelationshipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientRelationshipObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientRelationshipObject ensureData() => $_ensure(0);
}

class ClientRelationshipSaveResponse extends $pb.GeneratedMessage {
  factory ClientRelationshipSaveResponse({
    ClientRelationshipObject? data,
  }) {
    final result = ClientRelationshipSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientRelationshipSaveResponse._();

  factory ClientRelationshipSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipSaveResponse()..mergeFromBuffer(data, registry);
  factory ClientRelationshipSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientRelationshipSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientRelationshipSaveResponse.$_createMessage)
    ..aOM<ClientRelationshipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientRelationshipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipSaveResponse copyWith(
          void Function(ClientRelationshipSaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClientRelationshipSaveResponse))
          as ClientRelationshipSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientRelationshipSaveResponse() / ClientRelationshipSaveResponse.new instead')
  static ClientRelationshipSaveResponse create() =>
      ClientRelationshipSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientRelationshipSaveResponse._();
  @$core.override
  ClientRelationshipSaveResponse createEmptyInstance() =>
      ClientRelationshipSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientRelationshipSaveResponse>(
          ClientRelationshipSaveResponse.$_createMessage);
  static ClientRelationshipSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientRelationshipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientRelationshipObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientRelationshipObject ensureData() => $_ensure(0);
}

class ClientRelationshipGetRequest extends $pb.GeneratedMessage {
  factory ClientRelationshipGetRequest({
    $core.String? id,
  }) {
    final result = ClientRelationshipGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  ClientRelationshipGetRequest._();

  factory ClientRelationshipGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipGetRequest()..mergeFromBuffer(data, registry);
  factory ClientRelationshipGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientRelationshipGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientRelationshipGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipGetRequest copyWith(
          void Function(ClientRelationshipGetRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClientRelationshipGetRequest))
          as ClientRelationshipGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientRelationshipGetRequest() / ClientRelationshipGetRequest.new instead')
  static ClientRelationshipGetRequest create() =>
      ClientRelationshipGetRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientRelationshipGetRequest._();
  @$core.override
  ClientRelationshipGetRequest createEmptyInstance() =>
      ClientRelationshipGetRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientRelationshipGetRequest>(
          ClientRelationshipGetRequest.$_createMessage);
  static ClientRelationshipGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ClientRelationshipGetResponse extends $pb.GeneratedMessage {
  factory ClientRelationshipGetResponse({
    ClientRelationshipObject? data,
  }) {
    final result = ClientRelationshipGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientRelationshipGetResponse._();

  factory ClientRelationshipGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipGetResponse()..mergeFromBuffer(data, registry);
  factory ClientRelationshipGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientRelationshipGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientRelationshipGetResponse.$_createMessage)
    ..aOM<ClientRelationshipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientRelationshipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipGetResponse copyWith(
          void Function(ClientRelationshipGetResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClientRelationshipGetResponse))
          as ClientRelationshipGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientRelationshipGetResponse() / ClientRelationshipGetResponse.new instead')
  static ClientRelationshipGetResponse create() =>
      ClientRelationshipGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientRelationshipGetResponse._();
  @$core.override
  ClientRelationshipGetResponse createEmptyInstance() =>
      ClientRelationshipGetResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientRelationshipGetResponse>(
          ClientRelationshipGetResponse.$_createMessage);
  static ClientRelationshipGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientRelationshipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientRelationshipObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientRelationshipObject ensureData() => $_ensure(0);
}

class ClientRelationshipSearchRequest extends $pb.GeneratedMessage {
  factory ClientRelationshipSearchRequest({
    $core.String? clientId,
    $core.String? memberId,
    $1.PageCursor? cursor,
  }) {
    final result = ClientRelationshipSearchRequest._();
    if (clientId != null) result.clientId = clientId;
    if (memberId != null) result.memberId = memberId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  ClientRelationshipSearchRequest._();

  factory ClientRelationshipSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipSearchRequest()..mergeFromBuffer(data, registry);
  factory ClientRelationshipSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientRelationshipSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientRelationshipSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'memberId')
    ..aOM<$1.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipSearchRequest copyWith(
          void Function(ClientRelationshipSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClientRelationshipSearchRequest))
          as ClientRelationshipSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientRelationshipSearchRequest() / ClientRelationshipSearchRequest.new instead')
  static ClientRelationshipSearchRequest create() =>
      ClientRelationshipSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientRelationshipSearchRequest._();
  @$core.override
  ClientRelationshipSearchRequest createEmptyInstance() =>
      ClientRelationshipSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientRelationshipSearchRequest>(
          ClientRelationshipSearchRequest.$_createMessage);
  static ClientRelationshipSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get memberId => $_getSZ(1);
  @$pb.TagNumber(2)
  set memberId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.PageCursor get cursor => $_getN(2);
  @$pb.TagNumber(3)
  set cursor($1.PageCursor value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.PageCursor ensureCursor() => $_ensure(2);
}

class ClientRelationshipSearchResponse extends $pb.GeneratedMessage {
  factory ClientRelationshipSearchResponse({
    $core.Iterable<ClientRelationshipObject>? data,
  }) {
    final result = ClientRelationshipSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  ClientRelationshipSearchResponse._();

  factory ClientRelationshipSearchResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipSearchResponse()..mergeFromBuffer(data, registry);
  factory ClientRelationshipSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientRelationshipSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientRelationshipSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'field.v1'),
      createEmptyInstance: ClientRelationshipSearchResponse.$_createMessage)
    ..pPM<ClientRelationshipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientRelationshipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientRelationshipSearchResponse copyWith(
          void Function(ClientRelationshipSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClientRelationshipSearchResponse))
          as ClientRelationshipSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientRelationshipSearchResponse() / ClientRelationshipSearchResponse.new instead')
  static ClientRelationshipSearchResponse create() =>
      ClientRelationshipSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientRelationshipSearchResponse._();
  @$core.override
  ClientRelationshipSearchResponse createEmptyInstance() =>
      ClientRelationshipSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientRelationshipSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientRelationshipSearchResponse>(
          ClientRelationshipSearchResponse.$_createMessage);
  static ClientRelationshipSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ClientRelationshipObject> get data => $_getList(0);
}

/// FieldService manages agents and clients in the lending hierarchy.
/// All RPCs require authentication via Bearer token.
class FieldServiceApi {
  final $pb.RpcClient _client;

  FieldServiceApi(this._client);

  /// AgentSave creates or updates an agent record.
  $async.Future<AgentSaveResponse> agentSave(
          $pb.ClientContext? ctx, AgentSaveRequest request) =>
      _client.invoke<AgentSaveResponse>(
          ctx, 'FieldService', 'AgentSave', request, AgentSaveResponse());

  /// AgentGet retrieves an agent by their ID.
  $async.Future<AgentGetResponse> agentGet(
          $pb.ClientContext? ctx, AgentGetRequest request) =>
      _client.invoke<AgentGetResponse>(
          ctx, 'FieldService', 'AgentGet', request, AgentGetResponse());

  /// AgentSearch finds agents matching search criteria.
  $async.Future<AgentSearchResponse> agentSearch(
          $pb.ClientContext? ctx, AgentSearchRequest request) =>
      _client.invoke<AgentSearchResponse>(
          ctx, 'FieldService', 'AgentSearch', request, AgentSearchResponse());

  /// AgentHierarchy retrieves the descendant tree of an agent.
  $async.Future<AgentHierarchyResponse> agentHierarchy(
          $pb.ClientContext? ctx, AgentHierarchyRequest request) =>
      _client.invoke<AgentHierarchyResponse>(ctx, 'FieldService',
          'AgentHierarchy', request, AgentHierarchyResponse());

  /// AgentBranchSave assigns or updates an agent-branch link.
  $async.Future<AgentBranchSaveResponse> agentBranchSave(
          $pb.ClientContext? ctx, AgentBranchSaveRequest request) =>
      _client.invoke<AgentBranchSaveResponse>(ctx, 'FieldService',
          'AgentBranchSave', request, AgentBranchSaveResponse());

  /// AgentBranchDelete removes an agent-branch link.
  $async.Future<AgentBranchDeleteResponse> agentBranchDelete(
          $pb.ClientContext? ctx, AgentBranchDeleteRequest request) =>
      _client.invoke<AgentBranchDeleteResponse>(ctx, 'FieldService',
          'AgentBranchDelete', request, AgentBranchDeleteResponse());

  /// AgentBranchList lists agent-branch assignments.
  $async.Future<AgentBranchListResponse> agentBranchList(
          $pb.ClientContext? ctx, AgentBranchListRequest request) =>
      _client.invoke<AgentBranchListResponse>(ctx, 'FieldService',
          'AgentBranchList', request, AgentBranchListResponse());

  /// ClientSave onboards or updates a client record.
  $async.Future<ClientSaveResponse> clientSave(
          $pb.ClientContext? ctx, ClientSaveRequest request) =>
      _client.invoke<ClientSaveResponse>(
          ctx, 'FieldService', 'ClientSave', request, ClientSaveResponse());

  /// ClientGet retrieves a client by their ID.
  $async.Future<ClientGetResponse> clientGet(
          $pb.ClientContext? ctx, ClientGetRequest request) =>
      _client.invoke<ClientGetResponse>(
          ctx, 'FieldService', 'ClientGet', request, ClientGetResponse());

  /// ClientSearch finds clients matching search criteria.
  $async.Future<ClientSearchResponse> clientSearch(
          $pb.ClientContext? ctx, ClientSearchRequest request) =>
      _client.invoke<ClientSearchResponse>(
          ctx, 'FieldService', 'ClientSearch', request, ClientSearchResponse());

  /// ClientReassign moves a client from one agent to another.
  $async.Future<ClientReassignResponse> clientReassign(
          $pb.ClientContext? ctx, ClientReassignRequest request) =>
      _client.invoke<ClientReassignResponse>(ctx, 'FieldService',
          'ClientReassign', request, ClientReassignResponse());
  $async.Future<ClientOwnershipTransferResponse> clientOwnershipTransfer(
          $pb.ClientContext? ctx, ClientOwnershipTransferRequest request) =>
      _client.invoke<ClientOwnershipTransferResponse>(
          ctx,
          'FieldService',
          'ClientOwnershipTransfer',
          request,
          ClientOwnershipTransferResponse());

  /// ClientRelationshipSave creates or updates a client-member relationship.
  $async.Future<ClientRelationshipSaveResponse> clientRelationshipSave(
          $pb.ClientContext? ctx, ClientRelationshipSaveRequest request) =>
      _client.invoke<ClientRelationshipSaveResponse>(ctx, 'FieldService',
          'ClientRelationshipSave', request, ClientRelationshipSaveResponse());

  /// ClientRelationshipGet retrieves a client relationship by ID.
  $async.Future<ClientRelationshipGetResponse> clientRelationshipGet(
          $pb.ClientContext? ctx, ClientRelationshipGetRequest request) =>
      _client.invoke<ClientRelationshipGetResponse>(ctx, 'FieldService',
          'ClientRelationshipGet', request, ClientRelationshipGetResponse());

  /// ClientRelationshipSearch finds client relationships matching criteria.
  $async.Future<ClientRelationshipSearchResponse> clientRelationshipSearch(
          $pb.ClientContext? ctx, ClientRelationshipSearchRequest request) =>
      _client.invoke<ClientRelationshipSearchResponse>(
          ctx,
          'FieldService',
          'ClientRelationshipSearch',
          request,
          ClientRelationshipSearchResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
