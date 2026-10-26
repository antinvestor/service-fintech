// This is a generated file - do not edit.
//
// Generated from identity/v1/identity.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $0;

import '../../common/v1/common.pb.dart' as $1;
import '../../common/v1/money.pb.dart' as $2;
import 'identity.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'identity.pbenum.dart';

/// OrganizationObject represents a top-level institution mapped to a partition.
/// This is a generic entity that can represent banks, microfinance institutions,
/// SACCOs, fintechs, cooperatives, or any other organization type.
class OrganizationObject extends $pb.GeneratedMessage {
  factory OrganizationObject({
    $core.String? id,
    $core.String? partitionId,
    $core.String? name,
    $core.String? code,
    $core.String? profileId,
    $1.STATE? state,
    OrganizationType? organizationType,
    $0.Struct? properties,
    $core.String? clientId,
    $core.String? geoId,
    $core.String? parentId,
    $core.bool? hasChildren,
    $core.String? domain,
  }) {
    final result = OrganizationObject._();
    if (id != null) result.id = id;
    if (partitionId != null) result.partitionId = partitionId;
    if (name != null) result.name = name;
    if (code != null) result.code = code;
    if (profileId != null) result.profileId = profileId;
    if (state != null) result.state = state;
    if (organizationType != null) result.organizationType = organizationType;
    if (properties != null) result.properties = properties;
    if (clientId != null) result.clientId = clientId;
    if (geoId != null) result.geoId = geoId;
    if (parentId != null) result.parentId = parentId;
    if (hasChildren != null) result.hasChildren = hasChildren;
    if (domain != null) result.domain = domain;
    return result;
  }

  OrganizationObject._();

  factory OrganizationObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationObject()..mergeFromBuffer(data, registry);
  factory OrganizationObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrganizationObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrganizationObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'partitionId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'code')
    ..aOS(5, _omitFieldNames ? '' : 'profileId')
    ..aE<$1.STATE>(6, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aE<OrganizationType>(7, _omitFieldNames ? '' : 'organizationType',
        enumValues: OrganizationType.values)
    ..aOM<$0.Struct>(8, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..aOS(9, _omitFieldNames ? '' : 'clientId')
    ..aOS(10, _omitFieldNames ? '' : 'geoId')
    ..aOS(11, _omitFieldNames ? '' : 'parentId')
    ..aOB(12, _omitFieldNames ? '' : 'hasChildren')
    ..aOS(13, _omitFieldNames ? '' : 'domain')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationObject copyWith(void Function(OrganizationObject) updates) =>
      super.copyWith((message) => updates(message as OrganizationObject))
          as OrganizationObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OrganizationObject() / OrganizationObject.new instead')
  static OrganizationObject create() => OrganizationObject._();
  static $pb.GeneratedMessage $_createMessage() => OrganizationObject._();
  @$core.override
  OrganizationObject createEmptyInstance() => OrganizationObject._();
  @$core.pragma('dart2js:noInline')
  static OrganizationObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrganizationObject>(
          OrganizationObject.$_createMessage);
  static OrganizationObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get partitionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set partitionId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPartitionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPartitionId() => $_clearField(2);

  /// (child partition from the caller's claims), so a create request
  /// may omit it; required shape only applies when a value is present.
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
  $core.String get profileId => $_getSZ(4);
  @$pb.TagNumber(5)
  set profileId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProfileId() => $_has(4);
  @$pb.TagNumber(5)
  void clearProfileId() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.STATE get state => $_getN(5);
  @$pb.TagNumber(6)
  set state($1.STATE value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasState() => $_has(5);
  @$pb.TagNumber(6)
  void clearState() => $_clearField(6);

  @$pb.TagNumber(7)
  OrganizationType get organizationType => $_getN(6);
  @$pb.TagNumber(7)
  set organizationType(OrganizationType value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasOrganizationType() => $_has(6);
  @$pb.TagNumber(7)
  void clearOrganizationType() => $_clearField(7);

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

  @$pb.TagNumber(9)
  $core.String get clientId => $_getSZ(8);
  @$pb.TagNumber(9)
  set clientId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasClientId() => $_has(8);
  @$pb.TagNumber(9)
  void clearClientId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get geoId => $_getSZ(9);
  @$pb.TagNumber(10)
  set geoId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasGeoId() => $_has(9);
  @$pb.TagNumber(10)
  void clearGeoId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get parentId => $_getSZ(10);
  @$pb.TagNumber(11)
  set parentId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasParentId() => $_has(10);
  @$pb.TagNumber(11)
  void clearParentId() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get hasChildren => $_getBF(11);
  @$pb.TagNumber(12)
  set hasChildren($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHasChildren() => $_has(11);
  @$pb.TagNumber(12)
  void clearHasChildren() => $_clearField(12);

  /// The domain name associated with this organization (e.g. "stawi.org").
  @$pb.TagNumber(13)
  $core.String get domain => $_getSZ(12);
  @$pb.TagNumber(13)
  set domain($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDomain() => $_has(12);
  @$pb.TagNumber(13)
  void clearDomain() => $_clearField(13);
}

/// OrgUnitObject represents a typed hierarchical unit within an organization.
/// Org units can form a tree such as Region -> Zone -> Area -> Cluster -> Branch.
class OrgUnitObject extends $pb.GeneratedMessage {
  factory OrgUnitObject({
    $core.String? id,
    $core.String? organizationId,
    $core.String? parentId,
    $core.String? partitionId,
    $core.String? name,
    $core.String? code,
    $core.String? geoId,
    $1.STATE? state,
    OrgUnitType? type,
    $0.Struct? properties,
    $core.String? clientId,
    $core.bool? hasChildren,
    $core.String? profileId,
  }) {
    final result = OrgUnitObject._();
    if (id != null) result.id = id;
    if (organizationId != null) result.organizationId = organizationId;
    if (parentId != null) result.parentId = parentId;
    if (partitionId != null) result.partitionId = partitionId;
    if (name != null) result.name = name;
    if (code != null) result.code = code;
    if (geoId != null) result.geoId = geoId;
    if (state != null) result.state = state;
    if (type != null) result.type = type;
    if (properties != null) result.properties = properties;
    if (clientId != null) result.clientId = clientId;
    if (hasChildren != null) result.hasChildren = hasChildren;
    if (profileId != null) result.profileId = profileId;
    return result;
  }

  OrgUnitObject._();

  factory OrgUnitObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitObject()..mergeFromBuffer(data, registry);
  factory OrgUnitObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrgUnitObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrgUnitObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aOS(4, _omitFieldNames ? '' : 'partitionId')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'code')
    ..aOS(7, _omitFieldNames ? '' : 'geoId')
    ..aE<$1.STATE>(8, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aE<OrgUnitType>(9, _omitFieldNames ? '' : 'type',
        enumValues: OrgUnitType.values)
    ..aOM<$0.Struct>(10, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..aOS(11, _omitFieldNames ? '' : 'clientId')
    ..aOB(12, _omitFieldNames ? '' : 'hasChildren')
    ..aOS(13, _omitFieldNames ? '' : 'profileId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitObject copyWith(void Function(OrgUnitObject) updates) =>
      super.copyWith((message) => updates(message as OrgUnitObject))
          as OrgUnitObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OrgUnitObject() / OrgUnitObject.new instead')
  static OrgUnitObject create() => OrgUnitObject._();
  static $pb.GeneratedMessage $_createMessage() => OrgUnitObject._();
  @$core.override
  OrgUnitObject createEmptyInstance() => OrgUnitObject._();
  @$core.pragma('dart2js:noInline')
  static OrgUnitObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrgUnitObject>(
          OrgUnitObject.$_createMessage);
  static OrgUnitObject? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get partitionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set partitionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPartitionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearPartitionId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get code => $_getSZ(5);
  @$pb.TagNumber(6)
  set code($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCode() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get geoId => $_getSZ(6);
  @$pb.TagNumber(7)
  set geoId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGeoId() => $_has(6);
  @$pb.TagNumber(7)
  void clearGeoId() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.STATE get state => $_getN(7);
  @$pb.TagNumber(8)
  set state($1.STATE value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasState() => $_has(7);
  @$pb.TagNumber(8)
  void clearState() => $_clearField(8);

  @$pb.TagNumber(9)
  OrgUnitType get type => $_getN(8);
  @$pb.TagNumber(9)
  set type(OrgUnitType value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasType() => $_has(8);
  @$pb.TagNumber(9)
  void clearType() => $_clearField(9);

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
  $core.String get clientId => $_getSZ(10);
  @$pb.TagNumber(11)
  set clientId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasClientId() => $_has(10);
  @$pb.TagNumber(11)
  void clearClientId() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get hasChildren => $_getBF(11);
  @$pb.TagNumber(12)
  set hasChildren($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHasChildren() => $_has(11);
  @$pb.TagNumber(12)
  void clearHasChildren() => $_clearField(12);

  /// Profile ID for this org unit's profile (contacts, addresses, avatar).
  @$pb.TagNumber(13)
  $core.String get profileId => $_getSZ(12);
  @$pb.TagNumber(13)
  set profileId($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasProfileId() => $_has(12);
  @$pb.TagNumber(13)
  void clearProfileId() => $_clearField(13);
}

/// InvestorObject represents an independent investor with a profile link.
/// Investors are not assigned to agents — they exist independently.
class InvestorObject extends $pb.GeneratedMessage {
  factory InvestorObject({
    $core.String? id,
    $core.String? profileId,
    $core.String? name,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = InvestorObject._();
    if (id != null) result.id = id;
    if (profileId != null) result.profileId = profileId;
    if (name != null) result.name = name;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  InvestorObject._();

  factory InvestorObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorObject()..mergeFromBuffer(data, registry);
  factory InvestorObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'profileId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aE<$1.STATE>(4, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(5, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorObject copyWith(void Function(InvestorObject) updates) =>
      super.copyWith((message) => updates(message as InvestorObject))
          as InvestorObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InvestorObject() / InvestorObject.new instead')
  static InvestorObject create() => InvestorObject._();
  static $pb.GeneratedMessage $_createMessage() => InvestorObject._();
  @$core.override
  InvestorObject createEmptyInstance() => InvestorObject._();
  @$core.pragma('dart2js:noInline')
  static InvestorObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorObject>(
          InvestorObject.$_createMessage);
  static InvestorObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get profileId => $_getSZ(1);
  @$pb.TagNumber(2)
  set profileId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProfileId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfileId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

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

/// WorkforceMemberObject represents a worker in the organization.
class WorkforceMemberObject extends $pb.GeneratedMessage {
  factory WorkforceMemberObject({
    $core.String? id,
    $core.String? organizationId,
    $core.String? profileId,
    $core.String? engagementType,
    $core.String? homeOrgUnitId,
    $core.String? geoId,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = WorkforceMemberObject._();
    if (id != null) result.id = id;
    if (organizationId != null) result.organizationId = organizationId;
    if (profileId != null) result.profileId = profileId;
    if (engagementType != null) result.engagementType = engagementType;
    if (homeOrgUnitId != null) result.homeOrgUnitId = homeOrgUnitId;
    if (geoId != null) result.geoId = geoId;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  WorkforceMemberObject._();

  factory WorkforceMemberObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberObject()..mergeFromBuffer(data, registry);
  factory WorkforceMemberObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkforceMemberObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: WorkforceMemberObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'profileId')
    ..aOS(4, _omitFieldNames ? '' : 'engagementType')
    ..aOS(5, _omitFieldNames ? '' : 'homeOrgUnitId')
    ..aOS(6, _omitFieldNames ? '' : 'geoId')
    ..aE<$1.STATE>(7, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(8, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberObject copyWith(
          void Function(WorkforceMemberObject) updates) =>
      super.copyWith((message) => updates(message as WorkforceMemberObject))
          as WorkforceMemberObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkforceMemberObject() / WorkforceMemberObject.new instead')
  static WorkforceMemberObject create() => WorkforceMemberObject._();
  static $pb.GeneratedMessage $_createMessage() => WorkforceMemberObject._();
  @$core.override
  WorkforceMemberObject createEmptyInstance() => WorkforceMemberObject._();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkforceMemberObject>(
          WorkforceMemberObject.$_createMessage);
  static WorkforceMemberObject? _defaultInstance;

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
  $core.String get profileId => $_getSZ(2);
  @$pb.TagNumber(3)
  set profileId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProfileId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProfileId() => $_clearField(3);

  /// Organization-defined engagement type (e.g. "employee", "contractor", "agent", "intern").
  @$pb.TagNumber(4)
  $core.String get engagementType => $_getSZ(3);
  @$pb.TagNumber(4)
  set engagementType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEngagementType() => $_has(3);
  @$pb.TagNumber(4)
  void clearEngagementType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get homeOrgUnitId => $_getSZ(4);
  @$pb.TagNumber(5)
  set homeOrgUnitId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHomeOrgUnitId() => $_has(4);
  @$pb.TagNumber(5)
  void clearHomeOrgUnitId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get geoId => $_getSZ(5);
  @$pb.TagNumber(6)
  set geoId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGeoId() => $_has(5);
  @$pb.TagNumber(6)
  void clearGeoId() => $_clearField(6);

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

/// DepartmentObject represents a functional grouping node.
class DepartmentObject extends $pb.GeneratedMessage {
  factory DepartmentObject({
    $core.String? id,
    $core.String? organizationId,
    $core.String? parentId,
    DepartmentKind? kind,
    $core.String? name,
    $core.String? code,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = DepartmentObject._();
    if (id != null) result.id = id;
    if (organizationId != null) result.organizationId = organizationId;
    if (parentId != null) result.parentId = parentId;
    if (kind != null) result.kind = kind;
    if (name != null) result.name = name;
    if (code != null) result.code = code;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  DepartmentObject._();

  factory DepartmentObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentObject()..mergeFromBuffer(data, registry);
  factory DepartmentObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepartmentObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: DepartmentObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aE<DepartmentKind>(4, _omitFieldNames ? '' : 'kind',
        enumValues: DepartmentKind.values)
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'code')
    ..aE<$1.STATE>(7, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(8, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentObject copyWith(void Function(DepartmentObject) updates) =>
      super.copyWith((message) => updates(message as DepartmentObject))
          as DepartmentObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DepartmentObject() / DepartmentObject.new instead')
  static DepartmentObject create() => DepartmentObject._();
  static $pb.GeneratedMessage $_createMessage() => DepartmentObject._();
  @$core.override
  DepartmentObject createEmptyInstance() => DepartmentObject._();
  @$core.pragma('dart2js:noInline')
  static DepartmentObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepartmentObject>(
          DepartmentObject.$_createMessage);
  static DepartmentObject? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => $_clearField(3);

  @$pb.TagNumber(4)
  DepartmentKind get kind => $_getN(3);
  @$pb.TagNumber(4)
  set kind(DepartmentKind value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearKind() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get code => $_getSZ(5);
  @$pb.TagNumber(6)
  set code($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCode() => $_clearField(6);

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

/// PositionObject represents a reporting seat in the organization.
class PositionObject extends $pb.GeneratedMessage {
  factory PositionObject({
    $core.String? id,
    $core.String? organizationId,
    $core.String? orgUnitId,
    $core.String? departmentId,
    $core.String? reportsToPositionId,
    $core.String? name,
    $core.String? code,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = PositionObject._();
    if (id != null) result.id = id;
    if (organizationId != null) result.organizationId = organizationId;
    if (orgUnitId != null) result.orgUnitId = orgUnitId;
    if (departmentId != null) result.departmentId = departmentId;
    if (reportsToPositionId != null)
      result.reportsToPositionId = reportsToPositionId;
    if (name != null) result.name = name;
    if (code != null) result.code = code;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  PositionObject._();

  factory PositionObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionObject()..mergeFromBuffer(data, registry);
  factory PositionObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'orgUnitId')
    ..aOS(4, _omitFieldNames ? '' : 'departmentId')
    ..aOS(5, _omitFieldNames ? '' : 'reportsToPositionId')
    ..aOS(6, _omitFieldNames ? '' : 'name')
    ..aOS(7, _omitFieldNames ? '' : 'code')
    ..aE<$1.STATE>(8, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(9, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionObject copyWith(void Function(PositionObject) updates) =>
      super.copyWith((message) => updates(message as PositionObject))
          as PositionObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PositionObject() / PositionObject.new instead')
  static PositionObject create() => PositionObject._();
  static $pb.GeneratedMessage $_createMessage() => PositionObject._();
  @$core.override
  PositionObject createEmptyInstance() => PositionObject._();
  @$core.pragma('dart2js:noInline')
  static PositionObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionObject>(
          PositionObject.$_createMessage);
  static PositionObject? _defaultInstance;

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
  $core.String get orgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set orgUnitId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrgUnitId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get departmentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set departmentId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDepartmentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDepartmentId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get reportsToPositionId => $_getSZ(4);
  @$pb.TagNumber(5)
  set reportsToPositionId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReportsToPositionId() => $_has(4);
  @$pb.TagNumber(5)
  void clearReportsToPositionId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(6)
  set name($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(6)
  void clearName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get code => $_getSZ(6);
  @$pb.TagNumber(7)
  set code($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCode() => $_has(6);
  @$pb.TagNumber(7)
  void clearCode() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.STATE get state => $_getN(7);
  @$pb.TagNumber(8)
  set state($1.STATE value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasState() => $_has(7);
  @$pb.TagNumber(8)
  void clearState() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Struct get properties => $_getN(8);
  @$pb.TagNumber(9)
  set properties($0.Struct value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasProperties() => $_has(8);
  @$pb.TagNumber(9)
  void clearProperties() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Struct ensureProperties() => $_ensure(8);
}

/// PositionAssignmentObject assigns a workforce member to a position.
class PositionAssignmentObject extends $pb.GeneratedMessage {
  factory PositionAssignmentObject({
    $core.String? id,
    $core.String? memberId,
    $core.String? positionId,
    $core.bool? isPrimary,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = PositionAssignmentObject._();
    if (id != null) result.id = id;
    if (memberId != null) result.memberId = memberId;
    if (positionId != null) result.positionId = positionId;
    if (isPrimary != null) result.isPrimary = isPrimary;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  PositionAssignmentObject._();

  factory PositionAssignmentObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentObject()..mergeFromBuffer(data, registry);
  factory PositionAssignmentObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionAssignmentObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionAssignmentObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'memberId')
    ..aOS(3, _omitFieldNames ? '' : 'positionId')
    ..aOB(4, _omitFieldNames ? '' : 'isPrimary')
    ..aE<$1.STATE>(5, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(6, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentObject copyWith(
          void Function(PositionAssignmentObject) updates) =>
      super.copyWith((message) => updates(message as PositionAssignmentObject))
          as PositionAssignmentObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PositionAssignmentObject() / PositionAssignmentObject.new instead')
  static PositionAssignmentObject create() => PositionAssignmentObject._();
  static $pb.GeneratedMessage $_createMessage() => PositionAssignmentObject._();
  @$core.override
  PositionAssignmentObject createEmptyInstance() =>
      PositionAssignmentObject._();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionAssignmentObject>(
          PositionAssignmentObject.$_createMessage);
  static PositionAssignmentObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get memberId => $_getSZ(1);
  @$pb.TagNumber(2)
  set memberId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get positionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set positionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPositionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPositionId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isPrimary => $_getBF(3);
  @$pb.TagNumber(4)
  set isPrimary($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsPrimary() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsPrimary() => $_clearField(4);

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
}

/// InternalTeamObject represents an execution team for a business objective.
class InternalTeamObject extends $pb.GeneratedMessage {
  factory InternalTeamObject({
    $core.String? id,
    $core.String? organizationId,
    $core.String? parentTeamId,
    $core.String? homeOrgUnitId,
    $core.String? name,
    $core.String? code,
    $core.String? teamType,
    $core.String? objective,
    $core.String? geoId,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = InternalTeamObject._();
    if (id != null) result.id = id;
    if (organizationId != null) result.organizationId = organizationId;
    if (parentTeamId != null) result.parentTeamId = parentTeamId;
    if (homeOrgUnitId != null) result.homeOrgUnitId = homeOrgUnitId;
    if (name != null) result.name = name;
    if (code != null) result.code = code;
    if (teamType != null) result.teamType = teamType;
    if (objective != null) result.objective = objective;
    if (geoId != null) result.geoId = geoId;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  InternalTeamObject._();

  factory InternalTeamObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamObject()..mergeFromBuffer(data, registry);
  factory InternalTeamObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalTeamObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InternalTeamObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentTeamId')
    ..aOS(4, _omitFieldNames ? '' : 'homeOrgUnitId')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'code')
    ..aOS(7, _omitFieldNames ? '' : 'teamType')
    ..aOS(8, _omitFieldNames ? '' : 'objective')
    ..aOS(9, _omitFieldNames ? '' : 'geoId')
    ..aE<$1.STATE>(10, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(11, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamObject copyWith(void Function(InternalTeamObject) updates) =>
      super.copyWith((message) => updates(message as InternalTeamObject))
          as InternalTeamObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InternalTeamObject() / InternalTeamObject.new instead')
  static InternalTeamObject create() => InternalTeamObject._();
  static $pb.GeneratedMessage $_createMessage() => InternalTeamObject._();
  @$core.override
  InternalTeamObject createEmptyInstance() => InternalTeamObject._();
  @$core.pragma('dart2js:noInline')
  static InternalTeamObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalTeamObject>(
          InternalTeamObject.$_createMessage);
  static InternalTeamObject? _defaultInstance;

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
  $core.String get parentTeamId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentTeamId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentTeamId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentTeamId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get homeOrgUnitId => $_getSZ(3);
  @$pb.TagNumber(4)
  set homeOrgUnitId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHomeOrgUnitId() => $_has(3);
  @$pb.TagNumber(4)
  void clearHomeOrgUnitId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get code => $_getSZ(5);
  @$pb.TagNumber(6)
  set code($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCode() => $_clearField(6);

  /// Organization-defined team type (e.g. "portfolio", "collections", "recovery", "sales", "agent_network").
  @$pb.TagNumber(7)
  $core.String get teamType => $_getSZ(6);
  @$pb.TagNumber(7)
  set teamType($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTeamType() => $_has(6);
  @$pb.TagNumber(7)
  void clearTeamType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get objective => $_getSZ(7);
  @$pb.TagNumber(8)
  set objective($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasObjective() => $_has(7);
  @$pb.TagNumber(8)
  void clearObjective() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get geoId => $_getSZ(8);
  @$pb.TagNumber(9)
  set geoId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasGeoId() => $_has(8);
  @$pb.TagNumber(9)
  void clearGeoId() => $_clearField(9);

  @$pb.TagNumber(10)
  $1.STATE get state => $_getN(9);
  @$pb.TagNumber(10)
  set state($1.STATE value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasState() => $_has(9);
  @$pb.TagNumber(10)
  void clearState() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Struct get properties => $_getN(10);
  @$pb.TagNumber(11)
  set properties($0.Struct value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasProperties() => $_has(10);
  @$pb.TagNumber(11)
  void clearProperties() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Struct ensureProperties() => $_ensure(10);
}

/// TeamMembershipObject assigns a workforce member to an internal team.
class TeamMembershipObject extends $pb.GeneratedMessage {
  factory TeamMembershipObject({
    $core.String? id,
    $core.String? teamId,
    $core.String? memberId,
    $core.String? membershipRole,
    $core.bool? isPrimaryTeam,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = TeamMembershipObject._();
    if (id != null) result.id = id;
    if (teamId != null) result.teamId = teamId;
    if (memberId != null) result.memberId = memberId;
    if (membershipRole != null) result.membershipRole = membershipRole;
    if (isPrimaryTeam != null) result.isPrimaryTeam = isPrimaryTeam;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  TeamMembershipObject._();

  factory TeamMembershipObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipObject()..mergeFromBuffer(data, registry);
  factory TeamMembershipObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamMembershipObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: TeamMembershipObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'teamId')
    ..aOS(3, _omitFieldNames ? '' : 'memberId')
    ..aOS(4, _omitFieldNames ? '' : 'membershipRole')
    ..aOB(5, _omitFieldNames ? '' : 'isPrimaryTeam')
    ..aE<$1.STATE>(6, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(7, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipObject copyWith(void Function(TeamMembershipObject) updates) =>
      super.copyWith((message) => updates(message as TeamMembershipObject))
          as TeamMembershipObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamMembershipObject() / TeamMembershipObject.new instead')
  static TeamMembershipObject create() => TeamMembershipObject._();
  static $pb.GeneratedMessage $_createMessage() => TeamMembershipObject._();
  @$core.override
  TeamMembershipObject createEmptyInstance() => TeamMembershipObject._();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamMembershipObject>(
          TeamMembershipObject.$_createMessage);
  static TeamMembershipObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get teamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set teamId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTeamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTeamId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get memberId => $_getSZ(2);
  @$pb.TagNumber(3)
  set memberId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMemberId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberId() => $_clearField(3);

  /// Organization-defined role within the team (e.g. "lead", "member", "supervisor", "coordinator").
  @$pb.TagNumber(4)
  $core.String get membershipRole => $_getSZ(3);
  @$pb.TagNumber(4)
  set membershipRole($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMembershipRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearMembershipRole() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isPrimaryTeam => $_getBF(4);
  @$pb.TagNumber(5)
  set isPrimaryTeam($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsPrimaryTeam() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsPrimaryTeam() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.STATE get state => $_getN(5);
  @$pb.TagNumber(6)
  set state($1.STATE value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasState() => $_has(5);
  @$pb.TagNumber(6)
  void clearState() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Struct get properties => $_getN(6);
  @$pb.TagNumber(7)
  set properties($0.Struct value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasProperties() => $_has(6);
  @$pb.TagNumber(7)
  void clearProperties() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Struct ensureProperties() => $_ensure(6);
}

/// AccessRoleAssignmentObject grants explicit access at a given scope.
class AccessRoleAssignmentObject extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentObject({
    $core.String? id,
    $core.String? memberId,
    $core.String? roleKey,
    AccessScopeType? scopeType,
    $core.String? scopeId,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = AccessRoleAssignmentObject._();
    if (id != null) result.id = id;
    if (memberId != null) result.memberId = memberId;
    if (roleKey != null) result.roleKey = roleKey;
    if (scopeType != null) result.scopeType = scopeType;
    if (scopeId != null) result.scopeId = scopeId;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  AccessRoleAssignmentObject._();

  factory AccessRoleAssignmentObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentObject()..mergeFromBuffer(data, registry);
  factory AccessRoleAssignmentObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccessRoleAssignmentObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: AccessRoleAssignmentObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'memberId')
    ..aOS(3, _omitFieldNames ? '' : 'roleKey')
    ..aE<AccessScopeType>(4, _omitFieldNames ? '' : 'scopeType',
        enumValues: AccessScopeType.values)
    ..aOS(5, _omitFieldNames ? '' : 'scopeId')
    ..aE<$1.STATE>(6, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(7, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentObject copyWith(
          void Function(AccessRoleAssignmentObject) updates) =>
      super.copyWith(
              (message) => updates(message as AccessRoleAssignmentObject))
          as AccessRoleAssignmentObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AccessRoleAssignmentObject() / AccessRoleAssignmentObject.new instead')
  static AccessRoleAssignmentObject create() => AccessRoleAssignmentObject._();
  static $pb.GeneratedMessage $_createMessage() =>
      AccessRoleAssignmentObject._();
  @$core.override
  AccessRoleAssignmentObject createEmptyInstance() =>
      AccessRoleAssignmentObject._();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentObject>(
          AccessRoleAssignmentObject.$_createMessage);
  static AccessRoleAssignmentObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get memberId => $_getSZ(1);
  @$pb.TagNumber(2)
  set memberId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get roleKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set roleKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRoleKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoleKey() => $_clearField(3);

  @$pb.TagNumber(4)
  AccessScopeType get scopeType => $_getN(3);
  @$pb.TagNumber(4)
  set scopeType(AccessScopeType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasScopeType() => $_has(3);
  @$pb.TagNumber(4)
  void clearScopeType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get scopeId => $_getSZ(4);
  @$pb.TagNumber(5)
  set scopeId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasScopeId() => $_has(4);
  @$pb.TagNumber(5)
  void clearScopeId() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.STATE get state => $_getN(5);
  @$pb.TagNumber(6)
  set state($1.STATE value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasState() => $_has(5);
  @$pb.TagNumber(6)
  void clearState() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Struct get properties => $_getN(6);
  @$pb.TagNumber(7)
  set properties($0.Struct value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasProperties() => $_has(6);
  @$pb.TagNumber(7)
  void clearProperties() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Struct ensureProperties() => $_ensure(6);
}

/// Organization messages
class OrganizationSaveRequest extends $pb.GeneratedMessage {
  factory OrganizationSaveRequest({
    OrganizationObject? data,
  }) {
    final result = OrganizationSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  OrganizationSaveRequest._();

  factory OrganizationSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationSaveRequest()..mergeFromBuffer(data, registry);
  factory OrganizationSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrganizationSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrganizationSaveRequest.$_createMessage)
    ..aOM<OrganizationObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: OrganizationObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationSaveRequest copyWith(
          void Function(OrganizationSaveRequest) updates) =>
      super.copyWith((message) => updates(message as OrganizationSaveRequest))
          as OrganizationSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OrganizationSaveRequest() / OrganizationSaveRequest.new instead')
  static OrganizationSaveRequest create() => OrganizationSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => OrganizationSaveRequest._();
  @$core.override
  OrganizationSaveRequest createEmptyInstance() => OrganizationSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static OrganizationSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrganizationSaveRequest>(
          OrganizationSaveRequest.$_createMessage);
  static OrganizationSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  OrganizationObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrganizationObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  OrganizationObject ensureData() => $_ensure(0);
}

class OrganizationSaveResponse extends $pb.GeneratedMessage {
  factory OrganizationSaveResponse({
    OrganizationObject? data,
  }) {
    final result = OrganizationSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  OrganizationSaveResponse._();

  factory OrganizationSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationSaveResponse()..mergeFromBuffer(data, registry);
  factory OrganizationSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrganizationSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrganizationSaveResponse.$_createMessage)
    ..aOM<OrganizationObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: OrganizationObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationSaveResponse copyWith(
          void Function(OrganizationSaveResponse) updates) =>
      super.copyWith((message) => updates(message as OrganizationSaveResponse))
          as OrganizationSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OrganizationSaveResponse() / OrganizationSaveResponse.new instead')
  static OrganizationSaveResponse create() => OrganizationSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => OrganizationSaveResponse._();
  @$core.override
  OrganizationSaveResponse createEmptyInstance() =>
      OrganizationSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static OrganizationSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrganizationSaveResponse>(
          OrganizationSaveResponse.$_createMessage);
  static OrganizationSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  OrganizationObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrganizationObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  OrganizationObject ensureData() => $_ensure(0);
}

class OrganizationGetRequest extends $pb.GeneratedMessage {
  factory OrganizationGetRequest({
    $core.String? id,
  }) {
    final result = OrganizationGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  OrganizationGetRequest._();

  factory OrganizationGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationGetRequest()..mergeFromBuffer(data, registry);
  factory OrganizationGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrganizationGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrganizationGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationGetRequest copyWith(
          void Function(OrganizationGetRequest) updates) =>
      super.copyWith((message) => updates(message as OrganizationGetRequest))
          as OrganizationGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OrganizationGetRequest() / OrganizationGetRequest.new instead')
  static OrganizationGetRequest create() => OrganizationGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => OrganizationGetRequest._();
  @$core.override
  OrganizationGetRequest createEmptyInstance() => OrganizationGetRequest._();
  @$core.pragma('dart2js:noInline')
  static OrganizationGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrganizationGetRequest>(
          OrganizationGetRequest.$_createMessage);
  static OrganizationGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class OrganizationGetResponse extends $pb.GeneratedMessage {
  factory OrganizationGetResponse({
    OrganizationObject? data,
  }) {
    final result = OrganizationGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  OrganizationGetResponse._();

  factory OrganizationGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationGetResponse()..mergeFromBuffer(data, registry);
  factory OrganizationGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrganizationGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrganizationGetResponse.$_createMessage)
    ..aOM<OrganizationObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: OrganizationObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationGetResponse copyWith(
          void Function(OrganizationGetResponse) updates) =>
      super.copyWith((message) => updates(message as OrganizationGetResponse))
          as OrganizationGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OrganizationGetResponse() / OrganizationGetResponse.new instead')
  static OrganizationGetResponse create() => OrganizationGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => OrganizationGetResponse._();
  @$core.override
  OrganizationGetResponse createEmptyInstance() => OrganizationGetResponse._();
  @$core.pragma('dart2js:noInline')
  static OrganizationGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrganizationGetResponse>(
          OrganizationGetResponse.$_createMessage);
  static OrganizationGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  OrganizationObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrganizationObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  OrganizationObject ensureData() => $_ensure(0);
}

class OrganizationSearchResponse extends $pb.GeneratedMessage {
  factory OrganizationSearchResponse({
    $core.Iterable<OrganizationObject>? data,
  }) {
    final result = OrganizationSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  OrganizationSearchResponse._();

  factory OrganizationSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationSearchResponse()..mergeFromBuffer(data, registry);
  factory OrganizationSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrganizationSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrganizationSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrganizationSearchResponse.$_createMessage)
    ..pPM<OrganizationObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: OrganizationObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationSearchResponse copyWith(
          void Function(OrganizationSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as OrganizationSearchResponse))
          as OrganizationSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OrganizationSearchResponse() / OrganizationSearchResponse.new instead')
  static OrganizationSearchResponse create() => OrganizationSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      OrganizationSearchResponse._();
  @$core.override
  OrganizationSearchResponse createEmptyInstance() =>
      OrganizationSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static OrganizationSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrganizationSearchResponse>(
          OrganizationSearchResponse.$_createMessage);
  static OrganizationSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<OrganizationObject> get data => $_getList(0);
}

/// Org unit messages
class OrgUnitSaveRequest extends $pb.GeneratedMessage {
  factory OrgUnitSaveRequest({
    OrgUnitObject? data,
  }) {
    final result = OrgUnitSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  OrgUnitSaveRequest._();

  factory OrgUnitSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitSaveRequest()..mergeFromBuffer(data, registry);
  factory OrgUnitSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrgUnitSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrgUnitSaveRequest.$_createMessage)
    ..aOM<OrgUnitObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: OrgUnitObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitSaveRequest copyWith(void Function(OrgUnitSaveRequest) updates) =>
      super.copyWith((message) => updates(message as OrgUnitSaveRequest))
          as OrgUnitSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OrgUnitSaveRequest() / OrgUnitSaveRequest.new instead')
  static OrgUnitSaveRequest create() => OrgUnitSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => OrgUnitSaveRequest._();
  @$core.override
  OrgUnitSaveRequest createEmptyInstance() => OrgUnitSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static OrgUnitSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrgUnitSaveRequest>(
          OrgUnitSaveRequest.$_createMessage);
  static OrgUnitSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  OrgUnitObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrgUnitObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  OrgUnitObject ensureData() => $_ensure(0);
}

class OrgUnitSaveResponse extends $pb.GeneratedMessage {
  factory OrgUnitSaveResponse({
    OrgUnitObject? data,
  }) {
    final result = OrgUnitSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  OrgUnitSaveResponse._();

  factory OrgUnitSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitSaveResponse()..mergeFromBuffer(data, registry);
  factory OrgUnitSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrgUnitSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrgUnitSaveResponse.$_createMessage)
    ..aOM<OrgUnitObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: OrgUnitObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitSaveResponse copyWith(void Function(OrgUnitSaveResponse) updates) =>
      super.copyWith((message) => updates(message as OrgUnitSaveResponse))
          as OrgUnitSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use OrgUnitSaveResponse() / OrgUnitSaveResponse.new instead')
  static OrgUnitSaveResponse create() => OrgUnitSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => OrgUnitSaveResponse._();
  @$core.override
  OrgUnitSaveResponse createEmptyInstance() => OrgUnitSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static OrgUnitSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrgUnitSaveResponse>(
          OrgUnitSaveResponse.$_createMessage);
  static OrgUnitSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  OrgUnitObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrgUnitObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  OrgUnitObject ensureData() => $_ensure(0);
}

class OrgUnitGetRequest extends $pb.GeneratedMessage {
  factory OrgUnitGetRequest({
    $core.String? id,
  }) {
    final result = OrgUnitGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  OrgUnitGetRequest._();

  factory OrgUnitGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitGetRequest()..mergeFromBuffer(data, registry);
  factory OrgUnitGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrgUnitGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrgUnitGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitGetRequest copyWith(void Function(OrgUnitGetRequest) updates) =>
      super.copyWith((message) => updates(message as OrgUnitGetRequest))
          as OrgUnitGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OrgUnitGetRequest() / OrgUnitGetRequest.new instead')
  static OrgUnitGetRequest create() => OrgUnitGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => OrgUnitGetRequest._();
  @$core.override
  OrgUnitGetRequest createEmptyInstance() => OrgUnitGetRequest._();
  @$core.pragma('dart2js:noInline')
  static OrgUnitGetRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrgUnitGetRequest>(
          OrgUnitGetRequest.$_createMessage);
  static OrgUnitGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class OrgUnitGetResponse extends $pb.GeneratedMessage {
  factory OrgUnitGetResponse({
    OrgUnitObject? data,
  }) {
    final result = OrgUnitGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  OrgUnitGetResponse._();

  factory OrgUnitGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitGetResponse()..mergeFromBuffer(data, registry);
  factory OrgUnitGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrgUnitGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrgUnitGetResponse.$_createMessage)
    ..aOM<OrgUnitObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: OrgUnitObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitGetResponse copyWith(void Function(OrgUnitGetResponse) updates) =>
      super.copyWith((message) => updates(message as OrgUnitGetResponse))
          as OrgUnitGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OrgUnitGetResponse() / OrgUnitGetResponse.new instead')
  static OrgUnitGetResponse create() => OrgUnitGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => OrgUnitGetResponse._();
  @$core.override
  OrgUnitGetResponse createEmptyInstance() => OrgUnitGetResponse._();
  @$core.pragma('dart2js:noInline')
  static OrgUnitGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrgUnitGetResponse>(
          OrgUnitGetResponse.$_createMessage);
  static OrgUnitGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  OrgUnitObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrgUnitObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  OrgUnitObject ensureData() => $_ensure(0);
}

class OrgUnitSearchRequest extends $pb.GeneratedMessage {
  factory OrgUnitSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    $core.String? parentId,
    $core.bool? rootOnly,
    OrgUnitType? type,
    $1.PageCursor? cursor,
  }) {
    final result = OrgUnitSearchRequest._();
    if (query != null) result.query = query;
    if (organizationId != null) result.organizationId = organizationId;
    if (parentId != null) result.parentId = parentId;
    if (rootOnly != null) result.rootOnly = rootOnly;
    if (type != null) result.type = type;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  OrgUnitSearchRequest._();

  factory OrgUnitSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitSearchRequest()..mergeFromBuffer(data, registry);
  factory OrgUnitSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrgUnitSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrgUnitSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aOB(4, _omitFieldNames ? '' : 'rootOnly')
    ..aE<OrgUnitType>(5, _omitFieldNames ? '' : 'type',
        enumValues: OrgUnitType.values)
    ..aOM<$1.PageCursor>(6, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitSearchRequest copyWith(void Function(OrgUnitSearchRequest) updates) =>
      super.copyWith((message) => updates(message as OrgUnitSearchRequest))
          as OrgUnitSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OrgUnitSearchRequest() / OrgUnitSearchRequest.new instead')
  static OrgUnitSearchRequest create() => OrgUnitSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => OrgUnitSearchRequest._();
  @$core.override
  OrgUnitSearchRequest createEmptyInstance() => OrgUnitSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static OrgUnitSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrgUnitSearchRequest>(
          OrgUnitSearchRequest.$_createMessage);
  static OrgUnitSearchRequest? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get rootOnly => $_getBF(3);
  @$pb.TagNumber(4)
  set rootOnly($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRootOnly() => $_has(3);
  @$pb.TagNumber(4)
  void clearRootOnly() => $_clearField(4);

  @$pb.TagNumber(5)
  OrgUnitType get type => $_getN(4);
  @$pb.TagNumber(5)
  set type(OrgUnitType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.PageCursor get cursor => $_getN(5);
  @$pb.TagNumber(6)
  set cursor($1.PageCursor value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearCursor() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.PageCursor ensureCursor() => $_ensure(5);
}

class OrgUnitSearchResponse extends $pb.GeneratedMessage {
  factory OrgUnitSearchResponse({
    $core.Iterable<OrgUnitObject>? data,
  }) {
    final result = OrgUnitSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  OrgUnitSearchResponse._();

  factory OrgUnitSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitSearchResponse()..mergeFromBuffer(data, registry);
  factory OrgUnitSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OrgUnitSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrgUnitSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: OrgUnitSearchResponse.$_createMessage)
    ..pPM<OrgUnitObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: OrgUnitObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgUnitSearchResponse copyWith(
          void Function(OrgUnitSearchResponse) updates) =>
      super.copyWith((message) => updates(message as OrgUnitSearchResponse))
          as OrgUnitSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use OrgUnitSearchResponse() / OrgUnitSearchResponse.new instead')
  static OrgUnitSearchResponse create() => OrgUnitSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => OrgUnitSearchResponse._();
  @$core.override
  OrgUnitSearchResponse createEmptyInstance() => OrgUnitSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static OrgUnitSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrgUnitSearchResponse>(
          OrgUnitSearchResponse.$_createMessage);
  static OrgUnitSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<OrgUnitObject> get data => $_getList(0);
}

/// Investor messages
class InvestorSaveRequest extends $pb.GeneratedMessage {
  factory InvestorSaveRequest({
    InvestorObject? data,
  }) {
    final result = InvestorSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  InvestorSaveRequest._();

  factory InvestorSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorSaveRequest()..mergeFromBuffer(data, registry);
  factory InvestorSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorSaveRequest.$_createMessage)
    ..aOM<InvestorObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InvestorObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorSaveRequest copyWith(void Function(InvestorSaveRequest) updates) =>
      super.copyWith((message) => updates(message as InvestorSaveRequest))
          as InvestorSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use InvestorSaveRequest() / InvestorSaveRequest.new instead')
  static InvestorSaveRequest create() => InvestorSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => InvestorSaveRequest._();
  @$core.override
  InvestorSaveRequest createEmptyInstance() => InvestorSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static InvestorSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorSaveRequest>(
          InvestorSaveRequest.$_createMessage);
  static InvestorSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InvestorObject ensureData() => $_ensure(0);
}

class InvestorSaveResponse extends $pb.GeneratedMessage {
  factory InvestorSaveResponse({
    InvestorObject? data,
  }) {
    final result = InvestorSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  InvestorSaveResponse._();

  factory InvestorSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorSaveResponse()..mergeFromBuffer(data, registry);
  factory InvestorSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorSaveResponse.$_createMessage)
    ..aOM<InvestorObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InvestorObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorSaveResponse copyWith(void Function(InvestorSaveResponse) updates) =>
      super.copyWith((message) => updates(message as InvestorSaveResponse))
          as InvestorSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorSaveResponse() / InvestorSaveResponse.new instead')
  static InvestorSaveResponse create() => InvestorSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => InvestorSaveResponse._();
  @$core.override
  InvestorSaveResponse createEmptyInstance() => InvestorSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static InvestorSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorSaveResponse>(
          InvestorSaveResponse.$_createMessage);
  static InvestorSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InvestorObject ensureData() => $_ensure(0);
}

class InvestorGetRequest extends $pb.GeneratedMessage {
  factory InvestorGetRequest({
    $core.String? id,
  }) {
    final result = InvestorGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  InvestorGetRequest._();

  factory InvestorGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorGetRequest()..mergeFromBuffer(data, registry);
  factory InvestorGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorGetRequest copyWith(void Function(InvestorGetRequest) updates) =>
      super.copyWith((message) => updates(message as InvestorGetRequest))
          as InvestorGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InvestorGetRequest() / InvestorGetRequest.new instead')
  static InvestorGetRequest create() => InvestorGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => InvestorGetRequest._();
  @$core.override
  InvestorGetRequest createEmptyInstance() => InvestorGetRequest._();
  @$core.pragma('dart2js:noInline')
  static InvestorGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorGetRequest>(
          InvestorGetRequest.$_createMessage);
  static InvestorGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class InvestorGetResponse extends $pb.GeneratedMessage {
  factory InvestorGetResponse({
    InvestorObject? data,
  }) {
    final result = InvestorGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  InvestorGetResponse._();

  factory InvestorGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorGetResponse()..mergeFromBuffer(data, registry);
  factory InvestorGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorGetResponse.$_createMessage)
    ..aOM<InvestorObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InvestorObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorGetResponse copyWith(void Function(InvestorGetResponse) updates) =>
      super.copyWith((message) => updates(message as InvestorGetResponse))
          as InvestorGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use InvestorGetResponse() / InvestorGetResponse.new instead')
  static InvestorGetResponse create() => InvestorGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => InvestorGetResponse._();
  @$core.override
  InvestorGetResponse createEmptyInstance() => InvestorGetResponse._();
  @$core.pragma('dart2js:noInline')
  static InvestorGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorGetResponse>(
          InvestorGetResponse.$_createMessage);
  static InvestorGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InvestorObject ensureData() => $_ensure(0);
}

class InvestorSearchRequest extends $pb.GeneratedMessage {
  factory InvestorSearchRequest({
    $core.String? query,
    $1.PageCursor? cursor,
  }) {
    final result = InvestorSearchRequest._();
    if (query != null) result.query = query;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  InvestorSearchRequest._();

  factory InvestorSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorSearchRequest()..mergeFromBuffer(data, registry);
  factory InvestorSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOM<$1.PageCursor>(2, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorSearchRequest copyWith(
          void Function(InvestorSearchRequest) updates) =>
      super.copyWith((message) => updates(message as InvestorSearchRequest))
          as InvestorSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorSearchRequest() / InvestorSearchRequest.new instead')
  static InvestorSearchRequest create() => InvestorSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => InvestorSearchRequest._();
  @$core.override
  InvestorSearchRequest createEmptyInstance() => InvestorSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static InvestorSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorSearchRequest>(
          InvestorSearchRequest.$_createMessage);
  static InvestorSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.PageCursor get cursor => $_getN(1);
  @$pb.TagNumber(2)
  set cursor($1.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.PageCursor ensureCursor() => $_ensure(1);
}

class InvestorSearchResponse extends $pb.GeneratedMessage {
  factory InvestorSearchResponse({
    $core.Iterable<InvestorObject>? data,
  }) {
    final result = InvestorSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  InvestorSearchResponse._();

  factory InvestorSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorSearchResponse()..mergeFromBuffer(data, registry);
  factory InvestorSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InvestorSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvestorSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorSearchResponse.$_createMessage)
    ..pPM<InvestorObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InvestorObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvestorSearchResponse copyWith(
          void Function(InvestorSearchResponse) updates) =>
      super.copyWith((message) => updates(message as InvestorSearchResponse))
          as InvestorSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InvestorSearchResponse() / InvestorSearchResponse.new instead')
  static InvestorSearchResponse create() => InvestorSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => InvestorSearchResponse._();
  @$core.override
  InvestorSearchResponse createEmptyInstance() => InvestorSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static InvestorSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvestorSearchResponse>(
          InvestorSearchResponse.$_createMessage);
  static InvestorSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<InvestorObject> get data => $_getList(0);
}

/// Workforce member messages
class WorkforceMemberSaveRequest extends $pb.GeneratedMessage {
  factory WorkforceMemberSaveRequest({
    WorkforceMemberObject? data,
  }) {
    final result = WorkforceMemberSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  WorkforceMemberSaveRequest._();

  factory WorkforceMemberSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberSaveRequest()..mergeFromBuffer(data, registry);
  factory WorkforceMemberSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkforceMemberSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: WorkforceMemberSaveRequest.$_createMessage)
    ..aOM<WorkforceMemberObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: WorkforceMemberObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberSaveRequest copyWith(
          void Function(WorkforceMemberSaveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as WorkforceMemberSaveRequest))
          as WorkforceMemberSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkforceMemberSaveRequest() / WorkforceMemberSaveRequest.new instead')
  static WorkforceMemberSaveRequest create() => WorkforceMemberSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      WorkforceMemberSaveRequest._();
  @$core.override
  WorkforceMemberSaveRequest createEmptyInstance() =>
      WorkforceMemberSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkforceMemberSaveRequest>(
          WorkforceMemberSaveRequest.$_createMessage);
  static WorkforceMemberSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  WorkforceMemberObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WorkforceMemberObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  WorkforceMemberObject ensureData() => $_ensure(0);
}

class WorkforceMemberSaveResponse extends $pb.GeneratedMessage {
  factory WorkforceMemberSaveResponse({
    WorkforceMemberObject? data,
  }) {
    final result = WorkforceMemberSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  WorkforceMemberSaveResponse._();

  factory WorkforceMemberSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberSaveResponse()..mergeFromBuffer(data, registry);
  factory WorkforceMemberSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkforceMemberSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: WorkforceMemberSaveResponse.$_createMessage)
    ..aOM<WorkforceMemberObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: WorkforceMemberObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberSaveResponse copyWith(
          void Function(WorkforceMemberSaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as WorkforceMemberSaveResponse))
          as WorkforceMemberSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkforceMemberSaveResponse() / WorkforceMemberSaveResponse.new instead')
  static WorkforceMemberSaveResponse create() =>
      WorkforceMemberSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      WorkforceMemberSaveResponse._();
  @$core.override
  WorkforceMemberSaveResponse createEmptyInstance() =>
      WorkforceMemberSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkforceMemberSaveResponse>(
          WorkforceMemberSaveResponse.$_createMessage);
  static WorkforceMemberSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WorkforceMemberObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WorkforceMemberObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  WorkforceMemberObject ensureData() => $_ensure(0);
}

class WorkforceMemberGetRequest extends $pb.GeneratedMessage {
  factory WorkforceMemberGetRequest({
    $core.String? id,
  }) {
    final result = WorkforceMemberGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  WorkforceMemberGetRequest._();

  factory WorkforceMemberGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberGetRequest()..mergeFromBuffer(data, registry);
  factory WorkforceMemberGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkforceMemberGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: WorkforceMemberGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberGetRequest copyWith(
          void Function(WorkforceMemberGetRequest) updates) =>
      super.copyWith((message) => updates(message as WorkforceMemberGetRequest))
          as WorkforceMemberGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkforceMemberGetRequest() / WorkforceMemberGetRequest.new instead')
  static WorkforceMemberGetRequest create() => WorkforceMemberGetRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      WorkforceMemberGetRequest._();
  @$core.override
  WorkforceMemberGetRequest createEmptyInstance() =>
      WorkforceMemberGetRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkforceMemberGetRequest>(
          WorkforceMemberGetRequest.$_createMessage);
  static WorkforceMemberGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class WorkforceMemberGetResponse extends $pb.GeneratedMessage {
  factory WorkforceMemberGetResponse({
    WorkforceMemberObject? data,
  }) {
    final result = WorkforceMemberGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  WorkforceMemberGetResponse._();

  factory WorkforceMemberGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberGetResponse()..mergeFromBuffer(data, registry);
  factory WorkforceMemberGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkforceMemberGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: WorkforceMemberGetResponse.$_createMessage)
    ..aOM<WorkforceMemberObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: WorkforceMemberObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberGetResponse copyWith(
          void Function(WorkforceMemberGetResponse) updates) =>
      super.copyWith(
              (message) => updates(message as WorkforceMemberGetResponse))
          as WorkforceMemberGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkforceMemberGetResponse() / WorkforceMemberGetResponse.new instead')
  static WorkforceMemberGetResponse create() => WorkforceMemberGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      WorkforceMemberGetResponse._();
  @$core.override
  WorkforceMemberGetResponse createEmptyInstance() =>
      WorkforceMemberGetResponse._();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkforceMemberGetResponse>(
          WorkforceMemberGetResponse.$_createMessage);
  static WorkforceMemberGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WorkforceMemberObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WorkforceMemberObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  WorkforceMemberObject ensureData() => $_ensure(0);
}

class WorkforceMemberSearchRequest extends $pb.GeneratedMessage {
  factory WorkforceMemberSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    $core.String? homeOrgUnitId,
    $1.PageCursor? cursor,
  }) {
    final result = WorkforceMemberSearchRequest._();
    if (query != null) result.query = query;
    if (organizationId != null) result.organizationId = organizationId;
    if (homeOrgUnitId != null) result.homeOrgUnitId = homeOrgUnitId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  WorkforceMemberSearchRequest._();

  factory WorkforceMemberSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberSearchRequest()..mergeFromBuffer(data, registry);
  factory WorkforceMemberSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkforceMemberSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: WorkforceMemberSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'homeOrgUnitId')
    ..aOM<$1.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberSearchRequest copyWith(
          void Function(WorkforceMemberSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as WorkforceMemberSearchRequest))
          as WorkforceMemberSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkforceMemberSearchRequest() / WorkforceMemberSearchRequest.new instead')
  static WorkforceMemberSearchRequest create() =>
      WorkforceMemberSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      WorkforceMemberSearchRequest._();
  @$core.override
  WorkforceMemberSearchRequest createEmptyInstance() =>
      WorkforceMemberSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkforceMemberSearchRequest>(
          WorkforceMemberSearchRequest.$_createMessage);
  static WorkforceMemberSearchRequest? _defaultInstance;

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
  $core.String get homeOrgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set homeOrgUnitId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHomeOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearHomeOrgUnitId() => $_clearField(3);

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
}

class WorkforceMemberSearchResponse extends $pb.GeneratedMessage {
  factory WorkforceMemberSearchResponse({
    $core.Iterable<WorkforceMemberObject>? data,
  }) {
    final result = WorkforceMemberSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  WorkforceMemberSearchResponse._();

  factory WorkforceMemberSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberSearchResponse()..mergeFromBuffer(data, registry);
  factory WorkforceMemberSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkforceMemberSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkforceMemberSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: WorkforceMemberSearchResponse.$_createMessage)
    ..pPM<WorkforceMemberObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: WorkforceMemberObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkforceMemberSearchResponse copyWith(
          void Function(WorkforceMemberSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as WorkforceMemberSearchResponse))
          as WorkforceMemberSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WorkforceMemberSearchResponse() / WorkforceMemberSearchResponse.new instead')
  static WorkforceMemberSearchResponse create() =>
      WorkforceMemberSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      WorkforceMemberSearchResponse._();
  @$core.override
  WorkforceMemberSearchResponse createEmptyInstance() =>
      WorkforceMemberSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkforceMemberSearchResponse>(
          WorkforceMemberSearchResponse.$_createMessage);
  static WorkforceMemberSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WorkforceMemberObject> get data => $_getList(0);
}

/// Department messages
class DepartmentSaveRequest extends $pb.GeneratedMessage {
  factory DepartmentSaveRequest({
    DepartmentObject? data,
  }) {
    final result = DepartmentSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  DepartmentSaveRequest._();

  factory DepartmentSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentSaveRequest()..mergeFromBuffer(data, registry);
  factory DepartmentSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepartmentSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: DepartmentSaveRequest.$_createMessage)
    ..aOM<DepartmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: DepartmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentSaveRequest copyWith(
          void Function(DepartmentSaveRequest) updates) =>
      super.copyWith((message) => updates(message as DepartmentSaveRequest))
          as DepartmentSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DepartmentSaveRequest() / DepartmentSaveRequest.new instead')
  static DepartmentSaveRequest create() => DepartmentSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => DepartmentSaveRequest._();
  @$core.override
  DepartmentSaveRequest createEmptyInstance() => DepartmentSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static DepartmentSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DepartmentSaveRequest>(
          DepartmentSaveRequest.$_createMessage);
  static DepartmentSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  DepartmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DepartmentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  DepartmentObject ensureData() => $_ensure(0);
}

class DepartmentSaveResponse extends $pb.GeneratedMessage {
  factory DepartmentSaveResponse({
    DepartmentObject? data,
  }) {
    final result = DepartmentSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  DepartmentSaveResponse._();

  factory DepartmentSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentSaveResponse()..mergeFromBuffer(data, registry);
  factory DepartmentSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepartmentSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: DepartmentSaveResponse.$_createMessage)
    ..aOM<DepartmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: DepartmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentSaveResponse copyWith(
          void Function(DepartmentSaveResponse) updates) =>
      super.copyWith((message) => updates(message as DepartmentSaveResponse))
          as DepartmentSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DepartmentSaveResponse() / DepartmentSaveResponse.new instead')
  static DepartmentSaveResponse create() => DepartmentSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => DepartmentSaveResponse._();
  @$core.override
  DepartmentSaveResponse createEmptyInstance() => DepartmentSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static DepartmentSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DepartmentSaveResponse>(
          DepartmentSaveResponse.$_createMessage);
  static DepartmentSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DepartmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DepartmentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  DepartmentObject ensureData() => $_ensure(0);
}

class DepartmentGetRequest extends $pb.GeneratedMessage {
  factory DepartmentGetRequest({
    $core.String? id,
  }) {
    final result = DepartmentGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  DepartmentGetRequest._();

  factory DepartmentGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentGetRequest()..mergeFromBuffer(data, registry);
  factory DepartmentGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepartmentGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: DepartmentGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentGetRequest copyWith(void Function(DepartmentGetRequest) updates) =>
      super.copyWith((message) => updates(message as DepartmentGetRequest))
          as DepartmentGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DepartmentGetRequest() / DepartmentGetRequest.new instead')
  static DepartmentGetRequest create() => DepartmentGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => DepartmentGetRequest._();
  @$core.override
  DepartmentGetRequest createEmptyInstance() => DepartmentGetRequest._();
  @$core.pragma('dart2js:noInline')
  static DepartmentGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DepartmentGetRequest>(
          DepartmentGetRequest.$_createMessage);
  static DepartmentGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DepartmentGetResponse extends $pb.GeneratedMessage {
  factory DepartmentGetResponse({
    DepartmentObject? data,
  }) {
    final result = DepartmentGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  DepartmentGetResponse._();

  factory DepartmentGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentGetResponse()..mergeFromBuffer(data, registry);
  factory DepartmentGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepartmentGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: DepartmentGetResponse.$_createMessage)
    ..aOM<DepartmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: DepartmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentGetResponse copyWith(
          void Function(DepartmentGetResponse) updates) =>
      super.copyWith((message) => updates(message as DepartmentGetResponse))
          as DepartmentGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DepartmentGetResponse() / DepartmentGetResponse.new instead')
  static DepartmentGetResponse create() => DepartmentGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => DepartmentGetResponse._();
  @$core.override
  DepartmentGetResponse createEmptyInstance() => DepartmentGetResponse._();
  @$core.pragma('dart2js:noInline')
  static DepartmentGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DepartmentGetResponse>(
          DepartmentGetResponse.$_createMessage);
  static DepartmentGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DepartmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DepartmentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  DepartmentObject ensureData() => $_ensure(0);
}

class DepartmentSearchRequest extends $pb.GeneratedMessage {
  factory DepartmentSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    $core.String? parentId,
    DepartmentKind? kind,
    $1.PageCursor? cursor,
  }) {
    final result = DepartmentSearchRequest._();
    if (query != null) result.query = query;
    if (organizationId != null) result.organizationId = organizationId;
    if (parentId != null) result.parentId = parentId;
    if (kind != null) result.kind = kind;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  DepartmentSearchRequest._();

  factory DepartmentSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentSearchRequest()..mergeFromBuffer(data, registry);
  factory DepartmentSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepartmentSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: DepartmentSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aE<DepartmentKind>(4, _omitFieldNames ? '' : 'kind',
        enumValues: DepartmentKind.values)
    ..aOM<$1.PageCursor>(5, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentSearchRequest copyWith(
          void Function(DepartmentSearchRequest) updates) =>
      super.copyWith((message) => updates(message as DepartmentSearchRequest))
          as DepartmentSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DepartmentSearchRequest() / DepartmentSearchRequest.new instead')
  static DepartmentSearchRequest create() => DepartmentSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => DepartmentSearchRequest._();
  @$core.override
  DepartmentSearchRequest createEmptyInstance() => DepartmentSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static DepartmentSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DepartmentSearchRequest>(
          DepartmentSearchRequest.$_createMessage);
  static DepartmentSearchRequest? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => $_clearField(3);

  @$pb.TagNumber(4)
  DepartmentKind get kind => $_getN(3);
  @$pb.TagNumber(4)
  set kind(DepartmentKind value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearKind() => $_clearField(4);

  @$pb.TagNumber(5)
  $1.PageCursor get cursor => $_getN(4);
  @$pb.TagNumber(5)
  set cursor($1.PageCursor value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCursor() => $_has(4);
  @$pb.TagNumber(5)
  void clearCursor() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.PageCursor ensureCursor() => $_ensure(4);
}

class DepartmentSearchResponse extends $pb.GeneratedMessage {
  factory DepartmentSearchResponse({
    $core.Iterable<DepartmentObject>? data,
  }) {
    final result = DepartmentSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  DepartmentSearchResponse._();

  factory DepartmentSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentSearchResponse()..mergeFromBuffer(data, registry);
  factory DepartmentSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DepartmentSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DepartmentSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: DepartmentSearchResponse.$_createMessage)
    ..pPM<DepartmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: DepartmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DepartmentSearchResponse copyWith(
          void Function(DepartmentSearchResponse) updates) =>
      super.copyWith((message) => updates(message as DepartmentSearchResponse))
          as DepartmentSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DepartmentSearchResponse() / DepartmentSearchResponse.new instead')
  static DepartmentSearchResponse create() => DepartmentSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => DepartmentSearchResponse._();
  @$core.override
  DepartmentSearchResponse createEmptyInstance() =>
      DepartmentSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static DepartmentSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DepartmentSearchResponse>(
          DepartmentSearchResponse.$_createMessage);
  static DepartmentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DepartmentObject> get data => $_getList(0);
}

/// Position messages
class PositionSaveRequest extends $pb.GeneratedMessage {
  factory PositionSaveRequest({
    PositionObject? data,
  }) {
    final result = PositionSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  PositionSaveRequest._();

  factory PositionSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionSaveRequest()..mergeFromBuffer(data, registry);
  factory PositionSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionSaveRequest.$_createMessage)
    ..aOM<PositionObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PositionObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionSaveRequest copyWith(void Function(PositionSaveRequest) updates) =>
      super.copyWith((message) => updates(message as PositionSaveRequest))
          as PositionSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use PositionSaveRequest() / PositionSaveRequest.new instead')
  static PositionSaveRequest create() => PositionSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => PositionSaveRequest._();
  @$core.override
  PositionSaveRequest createEmptyInstance() => PositionSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static PositionSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionSaveRequest>(
          PositionSaveRequest.$_createMessage);
  static PositionSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PositionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PositionObject ensureData() => $_ensure(0);
}

class PositionSaveResponse extends $pb.GeneratedMessage {
  factory PositionSaveResponse({
    PositionObject? data,
  }) {
    final result = PositionSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  PositionSaveResponse._();

  factory PositionSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionSaveResponse()..mergeFromBuffer(data, registry);
  factory PositionSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionSaveResponse.$_createMessage)
    ..aOM<PositionObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PositionObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionSaveResponse copyWith(void Function(PositionSaveResponse) updates) =>
      super.copyWith((message) => updates(message as PositionSaveResponse))
          as PositionSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PositionSaveResponse() / PositionSaveResponse.new instead')
  static PositionSaveResponse create() => PositionSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => PositionSaveResponse._();
  @$core.override
  PositionSaveResponse createEmptyInstance() => PositionSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static PositionSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionSaveResponse>(
          PositionSaveResponse.$_createMessage);
  static PositionSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PositionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PositionObject ensureData() => $_ensure(0);
}

class PositionGetRequest extends $pb.GeneratedMessage {
  factory PositionGetRequest({
    $core.String? id,
  }) {
    final result = PositionGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  PositionGetRequest._();

  factory PositionGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionGetRequest()..mergeFromBuffer(data, registry);
  factory PositionGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionGetRequest copyWith(void Function(PositionGetRequest) updates) =>
      super.copyWith((message) => updates(message as PositionGetRequest))
          as PositionGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PositionGetRequest() / PositionGetRequest.new instead')
  static PositionGetRequest create() => PositionGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => PositionGetRequest._();
  @$core.override
  PositionGetRequest createEmptyInstance() => PositionGetRequest._();
  @$core.pragma('dart2js:noInline')
  static PositionGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionGetRequest>(
          PositionGetRequest.$_createMessage);
  static PositionGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class PositionGetResponse extends $pb.GeneratedMessage {
  factory PositionGetResponse({
    PositionObject? data,
  }) {
    final result = PositionGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  PositionGetResponse._();

  factory PositionGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionGetResponse()..mergeFromBuffer(data, registry);
  factory PositionGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionGetResponse.$_createMessage)
    ..aOM<PositionObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PositionObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionGetResponse copyWith(void Function(PositionGetResponse) updates) =>
      super.copyWith((message) => updates(message as PositionGetResponse))
          as PositionGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use PositionGetResponse() / PositionGetResponse.new instead')
  static PositionGetResponse create() => PositionGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => PositionGetResponse._();
  @$core.override
  PositionGetResponse createEmptyInstance() => PositionGetResponse._();
  @$core.pragma('dart2js:noInline')
  static PositionGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionGetResponse>(
          PositionGetResponse.$_createMessage);
  static PositionGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PositionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PositionObject ensureData() => $_ensure(0);
}

class PositionSearchRequest extends $pb.GeneratedMessage {
  factory PositionSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    $core.String? orgUnitId,
    $core.String? departmentId,
    $core.String? reportsToPositionId,
    $1.PageCursor? cursor,
  }) {
    final result = PositionSearchRequest._();
    if (query != null) result.query = query;
    if (organizationId != null) result.organizationId = organizationId;
    if (orgUnitId != null) result.orgUnitId = orgUnitId;
    if (departmentId != null) result.departmentId = departmentId;
    if (reportsToPositionId != null)
      result.reportsToPositionId = reportsToPositionId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  PositionSearchRequest._();

  factory PositionSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionSearchRequest()..mergeFromBuffer(data, registry);
  factory PositionSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'orgUnitId')
    ..aOS(4, _omitFieldNames ? '' : 'departmentId')
    ..aOS(5, _omitFieldNames ? '' : 'reportsToPositionId')
    ..aOM<$1.PageCursor>(6, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionSearchRequest copyWith(
          void Function(PositionSearchRequest) updates) =>
      super.copyWith((message) => updates(message as PositionSearchRequest))
          as PositionSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PositionSearchRequest() / PositionSearchRequest.new instead')
  static PositionSearchRequest create() => PositionSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => PositionSearchRequest._();
  @$core.override
  PositionSearchRequest createEmptyInstance() => PositionSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static PositionSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionSearchRequest>(
          PositionSearchRequest.$_createMessage);
  static PositionSearchRequest? _defaultInstance;

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
  $core.String get orgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set orgUnitId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrgUnitId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get departmentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set departmentId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDepartmentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDepartmentId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get reportsToPositionId => $_getSZ(4);
  @$pb.TagNumber(5)
  set reportsToPositionId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReportsToPositionId() => $_has(4);
  @$pb.TagNumber(5)
  void clearReportsToPositionId() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.PageCursor get cursor => $_getN(5);
  @$pb.TagNumber(6)
  set cursor($1.PageCursor value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearCursor() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.PageCursor ensureCursor() => $_ensure(5);
}

class PositionSearchResponse extends $pb.GeneratedMessage {
  factory PositionSearchResponse({
    $core.Iterable<PositionObject>? data,
  }) {
    final result = PositionSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  PositionSearchResponse._();

  factory PositionSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionSearchResponse()..mergeFromBuffer(data, registry);
  factory PositionSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionSearchResponse.$_createMessage)
    ..pPM<PositionObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PositionObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionSearchResponse copyWith(
          void Function(PositionSearchResponse) updates) =>
      super.copyWith((message) => updates(message as PositionSearchResponse))
          as PositionSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PositionSearchResponse() / PositionSearchResponse.new instead')
  static PositionSearchResponse create() => PositionSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => PositionSearchResponse._();
  @$core.override
  PositionSearchResponse createEmptyInstance() => PositionSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static PositionSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionSearchResponse>(
          PositionSearchResponse.$_createMessage);
  static PositionSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PositionObject> get data => $_getList(0);
}

/// Position assignment messages
class PositionAssignmentSaveRequest extends $pb.GeneratedMessage {
  factory PositionAssignmentSaveRequest({
    PositionAssignmentObject? data,
  }) {
    final result = PositionAssignmentSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  PositionAssignmentSaveRequest._();

  factory PositionAssignmentSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentSaveRequest()..mergeFromBuffer(data, registry);
  factory PositionAssignmentSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionAssignmentSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionAssignmentSaveRequest.$_createMessage)
    ..aOM<PositionAssignmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PositionAssignmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentSaveRequest copyWith(
          void Function(PositionAssignmentSaveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as PositionAssignmentSaveRequest))
          as PositionAssignmentSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PositionAssignmentSaveRequest() / PositionAssignmentSaveRequest.new instead')
  static PositionAssignmentSaveRequest create() =>
      PositionAssignmentSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      PositionAssignmentSaveRequest._();
  @$core.override
  PositionAssignmentSaveRequest createEmptyInstance() =>
      PositionAssignmentSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionAssignmentSaveRequest>(
          PositionAssignmentSaveRequest.$_createMessage);
  static PositionAssignmentSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PositionAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionAssignmentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PositionAssignmentObject ensureData() => $_ensure(0);
}

class PositionAssignmentSaveResponse extends $pb.GeneratedMessage {
  factory PositionAssignmentSaveResponse({
    PositionAssignmentObject? data,
  }) {
    final result = PositionAssignmentSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  PositionAssignmentSaveResponse._();

  factory PositionAssignmentSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentSaveResponse()..mergeFromBuffer(data, registry);
  factory PositionAssignmentSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionAssignmentSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionAssignmentSaveResponse.$_createMessage)
    ..aOM<PositionAssignmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PositionAssignmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentSaveResponse copyWith(
          void Function(PositionAssignmentSaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PositionAssignmentSaveResponse))
          as PositionAssignmentSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PositionAssignmentSaveResponse() / PositionAssignmentSaveResponse.new instead')
  static PositionAssignmentSaveResponse create() =>
      PositionAssignmentSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      PositionAssignmentSaveResponse._();
  @$core.override
  PositionAssignmentSaveResponse createEmptyInstance() =>
      PositionAssignmentSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionAssignmentSaveResponse>(
          PositionAssignmentSaveResponse.$_createMessage);
  static PositionAssignmentSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PositionAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionAssignmentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PositionAssignmentObject ensureData() => $_ensure(0);
}

class PositionAssignmentGetRequest extends $pb.GeneratedMessage {
  factory PositionAssignmentGetRequest({
    $core.String? id,
  }) {
    final result = PositionAssignmentGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  PositionAssignmentGetRequest._();

  factory PositionAssignmentGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentGetRequest()..mergeFromBuffer(data, registry);
  factory PositionAssignmentGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionAssignmentGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionAssignmentGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentGetRequest copyWith(
          void Function(PositionAssignmentGetRequest) updates) =>
      super.copyWith(
              (message) => updates(message as PositionAssignmentGetRequest))
          as PositionAssignmentGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PositionAssignmentGetRequest() / PositionAssignmentGetRequest.new instead')
  static PositionAssignmentGetRequest create() =>
      PositionAssignmentGetRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      PositionAssignmentGetRequest._();
  @$core.override
  PositionAssignmentGetRequest createEmptyInstance() =>
      PositionAssignmentGetRequest._();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionAssignmentGetRequest>(
          PositionAssignmentGetRequest.$_createMessage);
  static PositionAssignmentGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class PositionAssignmentGetResponse extends $pb.GeneratedMessage {
  factory PositionAssignmentGetResponse({
    PositionAssignmentObject? data,
  }) {
    final result = PositionAssignmentGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  PositionAssignmentGetResponse._();

  factory PositionAssignmentGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentGetResponse()..mergeFromBuffer(data, registry);
  factory PositionAssignmentGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionAssignmentGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionAssignmentGetResponse.$_createMessage)
    ..aOM<PositionAssignmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PositionAssignmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentGetResponse copyWith(
          void Function(PositionAssignmentGetResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PositionAssignmentGetResponse))
          as PositionAssignmentGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PositionAssignmentGetResponse() / PositionAssignmentGetResponse.new instead')
  static PositionAssignmentGetResponse create() =>
      PositionAssignmentGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      PositionAssignmentGetResponse._();
  @$core.override
  PositionAssignmentGetResponse createEmptyInstance() =>
      PositionAssignmentGetResponse._();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionAssignmentGetResponse>(
          PositionAssignmentGetResponse.$_createMessage);
  static PositionAssignmentGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PositionAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionAssignmentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  PositionAssignmentObject ensureData() => $_ensure(0);
}

class PositionAssignmentSearchRequest extends $pb.GeneratedMessage {
  factory PositionAssignmentSearchRequest({
    $core.String? query,
    $core.String? memberId,
    $core.String? positionId,
    $1.PageCursor? cursor,
  }) {
    final result = PositionAssignmentSearchRequest._();
    if (query != null) result.query = query;
    if (memberId != null) result.memberId = memberId;
    if (positionId != null) result.positionId = positionId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  PositionAssignmentSearchRequest._();

  factory PositionAssignmentSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentSearchRequest()..mergeFromBuffer(data, registry);
  factory PositionAssignmentSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionAssignmentSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionAssignmentSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'memberId')
    ..aOS(3, _omitFieldNames ? '' : 'positionId')
    ..aOM<$1.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentSearchRequest copyWith(
          void Function(PositionAssignmentSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as PositionAssignmentSearchRequest))
          as PositionAssignmentSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PositionAssignmentSearchRequest() / PositionAssignmentSearchRequest.new instead')
  static PositionAssignmentSearchRequest create() =>
      PositionAssignmentSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      PositionAssignmentSearchRequest._();
  @$core.override
  PositionAssignmentSearchRequest createEmptyInstance() =>
      PositionAssignmentSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionAssignmentSearchRequest>(
          PositionAssignmentSearchRequest.$_createMessage);
  static PositionAssignmentSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get memberId => $_getSZ(1);
  @$pb.TagNumber(2)
  set memberId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get positionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set positionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPositionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPositionId() => $_clearField(3);

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
}

class PositionAssignmentSearchResponse extends $pb.GeneratedMessage {
  factory PositionAssignmentSearchResponse({
    $core.Iterable<PositionAssignmentObject>? data,
  }) {
    final result = PositionAssignmentSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  PositionAssignmentSearchResponse._();

  factory PositionAssignmentSearchResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentSearchResponse()..mergeFromBuffer(data, registry);
  factory PositionAssignmentSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionAssignmentSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionAssignmentSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: PositionAssignmentSearchResponse.$_createMessage)
    ..pPM<PositionAssignmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: PositionAssignmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionAssignmentSearchResponse copyWith(
          void Function(PositionAssignmentSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PositionAssignmentSearchResponse))
          as PositionAssignmentSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PositionAssignmentSearchResponse() / PositionAssignmentSearchResponse.new instead')
  static PositionAssignmentSearchResponse create() =>
      PositionAssignmentSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      PositionAssignmentSearchResponse._();
  @$core.override
  PositionAssignmentSearchResponse createEmptyInstance() =>
      PositionAssignmentSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PositionAssignmentSearchResponse>(
          PositionAssignmentSearchResponse.$_createMessage);
  static PositionAssignmentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PositionAssignmentObject> get data => $_getList(0);
}

/// Internal team messages
class InternalTeamSaveRequest extends $pb.GeneratedMessage {
  factory InternalTeamSaveRequest({
    InternalTeamObject? data,
  }) {
    final result = InternalTeamSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  InternalTeamSaveRequest._();

  factory InternalTeamSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamSaveRequest()..mergeFromBuffer(data, registry);
  factory InternalTeamSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalTeamSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InternalTeamSaveRequest.$_createMessage)
    ..aOM<InternalTeamObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InternalTeamObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamSaveRequest copyWith(
          void Function(InternalTeamSaveRequest) updates) =>
      super.copyWith((message) => updates(message as InternalTeamSaveRequest))
          as InternalTeamSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InternalTeamSaveRequest() / InternalTeamSaveRequest.new instead')
  static InternalTeamSaveRequest create() => InternalTeamSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => InternalTeamSaveRequest._();
  @$core.override
  InternalTeamSaveRequest createEmptyInstance() => InternalTeamSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static InternalTeamSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalTeamSaveRequest>(
          InternalTeamSaveRequest.$_createMessage);
  static InternalTeamSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  InternalTeamObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InternalTeamObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InternalTeamObject ensureData() => $_ensure(0);
}

class InternalTeamSaveResponse extends $pb.GeneratedMessage {
  factory InternalTeamSaveResponse({
    InternalTeamObject? data,
  }) {
    final result = InternalTeamSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  InternalTeamSaveResponse._();

  factory InternalTeamSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamSaveResponse()..mergeFromBuffer(data, registry);
  factory InternalTeamSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalTeamSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InternalTeamSaveResponse.$_createMessage)
    ..aOM<InternalTeamObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InternalTeamObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamSaveResponse copyWith(
          void Function(InternalTeamSaveResponse) updates) =>
      super.copyWith((message) => updates(message as InternalTeamSaveResponse))
          as InternalTeamSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InternalTeamSaveResponse() / InternalTeamSaveResponse.new instead')
  static InternalTeamSaveResponse create() => InternalTeamSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => InternalTeamSaveResponse._();
  @$core.override
  InternalTeamSaveResponse createEmptyInstance() =>
      InternalTeamSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static InternalTeamSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalTeamSaveResponse>(
          InternalTeamSaveResponse.$_createMessage);
  static InternalTeamSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InternalTeamObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InternalTeamObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InternalTeamObject ensureData() => $_ensure(0);
}

class InternalTeamGetRequest extends $pb.GeneratedMessage {
  factory InternalTeamGetRequest({
    $core.String? id,
  }) {
    final result = InternalTeamGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  InternalTeamGetRequest._();

  factory InternalTeamGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamGetRequest()..mergeFromBuffer(data, registry);
  factory InternalTeamGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalTeamGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InternalTeamGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamGetRequest copyWith(
          void Function(InternalTeamGetRequest) updates) =>
      super.copyWith((message) => updates(message as InternalTeamGetRequest))
          as InternalTeamGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InternalTeamGetRequest() / InternalTeamGetRequest.new instead')
  static InternalTeamGetRequest create() => InternalTeamGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => InternalTeamGetRequest._();
  @$core.override
  InternalTeamGetRequest createEmptyInstance() => InternalTeamGetRequest._();
  @$core.pragma('dart2js:noInline')
  static InternalTeamGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalTeamGetRequest>(
          InternalTeamGetRequest.$_createMessage);
  static InternalTeamGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class InternalTeamGetResponse extends $pb.GeneratedMessage {
  factory InternalTeamGetResponse({
    InternalTeamObject? data,
  }) {
    final result = InternalTeamGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  InternalTeamGetResponse._();

  factory InternalTeamGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamGetResponse()..mergeFromBuffer(data, registry);
  factory InternalTeamGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalTeamGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InternalTeamGetResponse.$_createMessage)
    ..aOM<InternalTeamObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InternalTeamObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamGetResponse copyWith(
          void Function(InternalTeamGetResponse) updates) =>
      super.copyWith((message) => updates(message as InternalTeamGetResponse))
          as InternalTeamGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InternalTeamGetResponse() / InternalTeamGetResponse.new instead')
  static InternalTeamGetResponse create() => InternalTeamGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => InternalTeamGetResponse._();
  @$core.override
  InternalTeamGetResponse createEmptyInstance() => InternalTeamGetResponse._();
  @$core.pragma('dart2js:noInline')
  static InternalTeamGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalTeamGetResponse>(
          InternalTeamGetResponse.$_createMessage);
  static InternalTeamGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InternalTeamObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InternalTeamObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  InternalTeamObject ensureData() => $_ensure(0);
}

class InternalTeamSearchRequest extends $pb.GeneratedMessage {
  factory InternalTeamSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    $core.String? homeOrgUnitId,
    $core.String? teamType,
    $1.PageCursor? cursor,
  }) {
    final result = InternalTeamSearchRequest._();
    if (query != null) result.query = query;
    if (organizationId != null) result.organizationId = organizationId;
    if (homeOrgUnitId != null) result.homeOrgUnitId = homeOrgUnitId;
    if (teamType != null) result.teamType = teamType;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  InternalTeamSearchRequest._();

  factory InternalTeamSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamSearchRequest()..mergeFromBuffer(data, registry);
  factory InternalTeamSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalTeamSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InternalTeamSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'homeOrgUnitId')
    ..aOS(4, _omitFieldNames ? '' : 'teamType')
    ..aOM<$1.PageCursor>(5, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamSearchRequest copyWith(
          void Function(InternalTeamSearchRequest) updates) =>
      super.copyWith((message) => updates(message as InternalTeamSearchRequest))
          as InternalTeamSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InternalTeamSearchRequest() / InternalTeamSearchRequest.new instead')
  static InternalTeamSearchRequest create() => InternalTeamSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      InternalTeamSearchRequest._();
  @$core.override
  InternalTeamSearchRequest createEmptyInstance() =>
      InternalTeamSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static InternalTeamSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalTeamSearchRequest>(
          InternalTeamSearchRequest.$_createMessage);
  static InternalTeamSearchRequest? _defaultInstance;

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
  $core.String get homeOrgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set homeOrgUnitId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHomeOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearHomeOrgUnitId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get teamType => $_getSZ(3);
  @$pb.TagNumber(4)
  set teamType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTeamType() => $_has(3);
  @$pb.TagNumber(4)
  void clearTeamType() => $_clearField(4);

  @$pb.TagNumber(5)
  $1.PageCursor get cursor => $_getN(4);
  @$pb.TagNumber(5)
  set cursor($1.PageCursor value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCursor() => $_has(4);
  @$pb.TagNumber(5)
  void clearCursor() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.PageCursor ensureCursor() => $_ensure(4);
}

class InternalTeamSearchResponse extends $pb.GeneratedMessage {
  factory InternalTeamSearchResponse({
    $core.Iterable<InternalTeamObject>? data,
  }) {
    final result = InternalTeamSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  InternalTeamSearchResponse._();

  factory InternalTeamSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamSearchResponse()..mergeFromBuffer(data, registry);
  factory InternalTeamSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalTeamSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalTeamSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InternalTeamSearchResponse.$_createMessage)
    ..pPM<InternalTeamObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InternalTeamObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalTeamSearchResponse copyWith(
          void Function(InternalTeamSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as InternalTeamSearchResponse))
          as InternalTeamSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InternalTeamSearchResponse() / InternalTeamSearchResponse.new instead')
  static InternalTeamSearchResponse create() => InternalTeamSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      InternalTeamSearchResponse._();
  @$core.override
  InternalTeamSearchResponse createEmptyInstance() =>
      InternalTeamSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static InternalTeamSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalTeamSearchResponse>(
          InternalTeamSearchResponse.$_createMessage);
  static InternalTeamSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<InternalTeamObject> get data => $_getList(0);
}

/// Team membership messages
class TeamMembershipSaveRequest extends $pb.GeneratedMessage {
  factory TeamMembershipSaveRequest({
    TeamMembershipObject? data,
  }) {
    final result = TeamMembershipSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  TeamMembershipSaveRequest._();

  factory TeamMembershipSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipSaveRequest()..mergeFromBuffer(data, registry);
  factory TeamMembershipSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamMembershipSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: TeamMembershipSaveRequest.$_createMessage)
    ..aOM<TeamMembershipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: TeamMembershipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipSaveRequest copyWith(
          void Function(TeamMembershipSaveRequest) updates) =>
      super.copyWith((message) => updates(message as TeamMembershipSaveRequest))
          as TeamMembershipSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamMembershipSaveRequest() / TeamMembershipSaveRequest.new instead')
  static TeamMembershipSaveRequest create() => TeamMembershipSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamMembershipSaveRequest._();
  @$core.override
  TeamMembershipSaveRequest createEmptyInstance() =>
      TeamMembershipSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamMembershipSaveRequest>(
          TeamMembershipSaveRequest.$_createMessage);
  static TeamMembershipSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  TeamMembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(TeamMembershipObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  TeamMembershipObject ensureData() => $_ensure(0);
}

class TeamMembershipSaveResponse extends $pb.GeneratedMessage {
  factory TeamMembershipSaveResponse({
    TeamMembershipObject? data,
  }) {
    final result = TeamMembershipSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  TeamMembershipSaveResponse._();

  factory TeamMembershipSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipSaveResponse()..mergeFromBuffer(data, registry);
  factory TeamMembershipSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamMembershipSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: TeamMembershipSaveResponse.$_createMessage)
    ..aOM<TeamMembershipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: TeamMembershipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipSaveResponse copyWith(
          void Function(TeamMembershipSaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as TeamMembershipSaveResponse))
          as TeamMembershipSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamMembershipSaveResponse() / TeamMembershipSaveResponse.new instead')
  static TeamMembershipSaveResponse create() => TeamMembershipSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamMembershipSaveResponse._();
  @$core.override
  TeamMembershipSaveResponse createEmptyInstance() =>
      TeamMembershipSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamMembershipSaveResponse>(
          TeamMembershipSaveResponse.$_createMessage);
  static TeamMembershipSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TeamMembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(TeamMembershipObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  TeamMembershipObject ensureData() => $_ensure(0);
}

class TeamMembershipGetRequest extends $pb.GeneratedMessage {
  factory TeamMembershipGetRequest({
    $core.String? id,
  }) {
    final result = TeamMembershipGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  TeamMembershipGetRequest._();

  factory TeamMembershipGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipGetRequest()..mergeFromBuffer(data, registry);
  factory TeamMembershipGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamMembershipGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: TeamMembershipGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipGetRequest copyWith(
          void Function(TeamMembershipGetRequest) updates) =>
      super.copyWith((message) => updates(message as TeamMembershipGetRequest))
          as TeamMembershipGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamMembershipGetRequest() / TeamMembershipGetRequest.new instead')
  static TeamMembershipGetRequest create() => TeamMembershipGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => TeamMembershipGetRequest._();
  @$core.override
  TeamMembershipGetRequest createEmptyInstance() =>
      TeamMembershipGetRequest._();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamMembershipGetRequest>(
          TeamMembershipGetRequest.$_createMessage);
  static TeamMembershipGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class TeamMembershipGetResponse extends $pb.GeneratedMessage {
  factory TeamMembershipGetResponse({
    TeamMembershipObject? data,
  }) {
    final result = TeamMembershipGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  TeamMembershipGetResponse._();

  factory TeamMembershipGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipGetResponse()..mergeFromBuffer(data, registry);
  factory TeamMembershipGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamMembershipGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: TeamMembershipGetResponse.$_createMessage)
    ..aOM<TeamMembershipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: TeamMembershipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipGetResponse copyWith(
          void Function(TeamMembershipGetResponse) updates) =>
      super.copyWith((message) => updates(message as TeamMembershipGetResponse))
          as TeamMembershipGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamMembershipGetResponse() / TeamMembershipGetResponse.new instead')
  static TeamMembershipGetResponse create() => TeamMembershipGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamMembershipGetResponse._();
  @$core.override
  TeamMembershipGetResponse createEmptyInstance() =>
      TeamMembershipGetResponse._();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamMembershipGetResponse>(
          TeamMembershipGetResponse.$_createMessage);
  static TeamMembershipGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TeamMembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(TeamMembershipObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  TeamMembershipObject ensureData() => $_ensure(0);
}

class TeamMembershipSearchRequest extends $pb.GeneratedMessage {
  factory TeamMembershipSearchRequest({
    $core.String? query,
    $core.String? teamId,
    $core.String? memberId,
    $1.PageCursor? cursor,
  }) {
    final result = TeamMembershipSearchRequest._();
    if (query != null) result.query = query;
    if (teamId != null) result.teamId = teamId;
    if (memberId != null) result.memberId = memberId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  TeamMembershipSearchRequest._();

  factory TeamMembershipSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipSearchRequest()..mergeFromBuffer(data, registry);
  factory TeamMembershipSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamMembershipSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: TeamMembershipSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'teamId')
    ..aOS(3, _omitFieldNames ? '' : 'memberId')
    ..aOM<$1.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipSearchRequest copyWith(
          void Function(TeamMembershipSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as TeamMembershipSearchRequest))
          as TeamMembershipSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamMembershipSearchRequest() / TeamMembershipSearchRequest.new instead')
  static TeamMembershipSearchRequest create() =>
      TeamMembershipSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamMembershipSearchRequest._();
  @$core.override
  TeamMembershipSearchRequest createEmptyInstance() =>
      TeamMembershipSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamMembershipSearchRequest>(
          TeamMembershipSearchRequest.$_createMessage);
  static TeamMembershipSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get teamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set teamId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTeamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTeamId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get memberId => $_getSZ(2);
  @$pb.TagNumber(3)
  set memberId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMemberId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberId() => $_clearField(3);

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
}

class TeamMembershipSearchResponse extends $pb.GeneratedMessage {
  factory TeamMembershipSearchResponse({
    $core.Iterable<TeamMembershipObject>? data,
  }) {
    final result = TeamMembershipSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  TeamMembershipSearchResponse._();

  factory TeamMembershipSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipSearchResponse()..mergeFromBuffer(data, registry);
  factory TeamMembershipSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TeamMembershipSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamMembershipSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: TeamMembershipSearchResponse.$_createMessage)
    ..pPM<TeamMembershipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: TeamMembershipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMembershipSearchResponse copyWith(
          void Function(TeamMembershipSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as TeamMembershipSearchResponse))
          as TeamMembershipSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TeamMembershipSearchResponse() / TeamMembershipSearchResponse.new instead')
  static TeamMembershipSearchResponse create() =>
      TeamMembershipSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      TeamMembershipSearchResponse._();
  @$core.override
  TeamMembershipSearchResponse createEmptyInstance() =>
      TeamMembershipSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamMembershipSearchResponse>(
          TeamMembershipSearchResponse.$_createMessage);
  static TeamMembershipSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamMembershipObject> get data => $_getList(0);
}

/// Access role assignment messages
class AccessRoleAssignmentSaveRequest extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentSaveRequest({
    AccessRoleAssignmentObject? data,
  }) {
    final result = AccessRoleAssignmentSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  AccessRoleAssignmentSaveRequest._();

  factory AccessRoleAssignmentSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentSaveRequest()..mergeFromBuffer(data, registry);
  factory AccessRoleAssignmentSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccessRoleAssignmentSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: AccessRoleAssignmentSaveRequest.$_createMessage)
    ..aOM<AccessRoleAssignmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AccessRoleAssignmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentSaveRequest copyWith(
          void Function(AccessRoleAssignmentSaveRequest) updates) =>
      super.copyWith(
              (message) => updates(message as AccessRoleAssignmentSaveRequest))
          as AccessRoleAssignmentSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AccessRoleAssignmentSaveRequest() / AccessRoleAssignmentSaveRequest.new instead')
  static AccessRoleAssignmentSaveRequest create() =>
      AccessRoleAssignmentSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      AccessRoleAssignmentSaveRequest._();
  @$core.override
  AccessRoleAssignmentSaveRequest createEmptyInstance() =>
      AccessRoleAssignmentSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentSaveRequest>(
          AccessRoleAssignmentSaveRequest.$_createMessage);
  static AccessRoleAssignmentSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  AccessRoleAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AccessRoleAssignmentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  AccessRoleAssignmentObject ensureData() => $_ensure(0);
}

class AccessRoleAssignmentSaveResponse extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentSaveResponse({
    AccessRoleAssignmentObject? data,
  }) {
    final result = AccessRoleAssignmentSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  AccessRoleAssignmentSaveResponse._();

  factory AccessRoleAssignmentSaveResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentSaveResponse()..mergeFromBuffer(data, registry);
  factory AccessRoleAssignmentSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccessRoleAssignmentSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: AccessRoleAssignmentSaveResponse.$_createMessage)
    ..aOM<AccessRoleAssignmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AccessRoleAssignmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentSaveResponse copyWith(
          void Function(AccessRoleAssignmentSaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as AccessRoleAssignmentSaveResponse))
          as AccessRoleAssignmentSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AccessRoleAssignmentSaveResponse() / AccessRoleAssignmentSaveResponse.new instead')
  static AccessRoleAssignmentSaveResponse create() =>
      AccessRoleAssignmentSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      AccessRoleAssignmentSaveResponse._();
  @$core.override
  AccessRoleAssignmentSaveResponse createEmptyInstance() =>
      AccessRoleAssignmentSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentSaveResponse>(
          AccessRoleAssignmentSaveResponse.$_createMessage);
  static AccessRoleAssignmentSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AccessRoleAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AccessRoleAssignmentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  AccessRoleAssignmentObject ensureData() => $_ensure(0);
}

class AccessRoleAssignmentGetRequest extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentGetRequest({
    $core.String? id,
  }) {
    final result = AccessRoleAssignmentGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  AccessRoleAssignmentGetRequest._();

  factory AccessRoleAssignmentGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentGetRequest()..mergeFromBuffer(data, registry);
  factory AccessRoleAssignmentGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccessRoleAssignmentGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: AccessRoleAssignmentGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentGetRequest copyWith(
          void Function(AccessRoleAssignmentGetRequest) updates) =>
      super.copyWith(
              (message) => updates(message as AccessRoleAssignmentGetRequest))
          as AccessRoleAssignmentGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AccessRoleAssignmentGetRequest() / AccessRoleAssignmentGetRequest.new instead')
  static AccessRoleAssignmentGetRequest create() =>
      AccessRoleAssignmentGetRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      AccessRoleAssignmentGetRequest._();
  @$core.override
  AccessRoleAssignmentGetRequest createEmptyInstance() =>
      AccessRoleAssignmentGetRequest._();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentGetRequest>(
          AccessRoleAssignmentGetRequest.$_createMessage);
  static AccessRoleAssignmentGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class AccessRoleAssignmentGetResponse extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentGetResponse({
    AccessRoleAssignmentObject? data,
  }) {
    final result = AccessRoleAssignmentGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  AccessRoleAssignmentGetResponse._();

  factory AccessRoleAssignmentGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentGetResponse()..mergeFromBuffer(data, registry);
  factory AccessRoleAssignmentGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccessRoleAssignmentGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: AccessRoleAssignmentGetResponse.$_createMessage)
    ..aOM<AccessRoleAssignmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AccessRoleAssignmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentGetResponse copyWith(
          void Function(AccessRoleAssignmentGetResponse) updates) =>
      super.copyWith(
              (message) => updates(message as AccessRoleAssignmentGetResponse))
          as AccessRoleAssignmentGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AccessRoleAssignmentGetResponse() / AccessRoleAssignmentGetResponse.new instead')
  static AccessRoleAssignmentGetResponse create() =>
      AccessRoleAssignmentGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      AccessRoleAssignmentGetResponse._();
  @$core.override
  AccessRoleAssignmentGetResponse createEmptyInstance() =>
      AccessRoleAssignmentGetResponse._();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentGetResponse>(
          AccessRoleAssignmentGetResponse.$_createMessage);
  static AccessRoleAssignmentGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AccessRoleAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AccessRoleAssignmentObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  AccessRoleAssignmentObject ensureData() => $_ensure(0);
}

class AccessRoleAssignmentSearchRequest extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentSearchRequest({
    $core.String? query,
    $core.String? memberId,
    $core.String? roleKey,
    AccessScopeType? scopeType,
    $core.String? scopeId,
    $1.PageCursor? cursor,
  }) {
    final result = AccessRoleAssignmentSearchRequest._();
    if (query != null) result.query = query;
    if (memberId != null) result.memberId = memberId;
    if (roleKey != null) result.roleKey = roleKey;
    if (scopeType != null) result.scopeType = scopeType;
    if (scopeId != null) result.scopeId = scopeId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  AccessRoleAssignmentSearchRequest._();

  factory AccessRoleAssignmentSearchRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentSearchRequest()..mergeFromBuffer(data, registry);
  factory AccessRoleAssignmentSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccessRoleAssignmentSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: AccessRoleAssignmentSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'memberId')
    ..aOS(3, _omitFieldNames ? '' : 'roleKey')
    ..aE<AccessScopeType>(4, _omitFieldNames ? '' : 'scopeType',
        enumValues: AccessScopeType.values)
    ..aOS(5, _omitFieldNames ? '' : 'scopeId')
    ..aOM<$1.PageCursor>(6, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentSearchRequest copyWith(
          void Function(AccessRoleAssignmentSearchRequest) updates) =>
      super.copyWith((message) =>
              updates(message as AccessRoleAssignmentSearchRequest))
          as AccessRoleAssignmentSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AccessRoleAssignmentSearchRequest() / AccessRoleAssignmentSearchRequest.new instead')
  static AccessRoleAssignmentSearchRequest create() =>
      AccessRoleAssignmentSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      AccessRoleAssignmentSearchRequest._();
  @$core.override
  AccessRoleAssignmentSearchRequest createEmptyInstance() =>
      AccessRoleAssignmentSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentSearchRequest>(
          AccessRoleAssignmentSearchRequest.$_createMessage);
  static AccessRoleAssignmentSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get memberId => $_getSZ(1);
  @$pb.TagNumber(2)
  set memberId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get roleKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set roleKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRoleKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoleKey() => $_clearField(3);

  @$pb.TagNumber(4)
  AccessScopeType get scopeType => $_getN(3);
  @$pb.TagNumber(4)
  set scopeType(AccessScopeType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasScopeType() => $_has(3);
  @$pb.TagNumber(4)
  void clearScopeType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get scopeId => $_getSZ(4);
  @$pb.TagNumber(5)
  set scopeId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasScopeId() => $_has(4);
  @$pb.TagNumber(5)
  void clearScopeId() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.PageCursor get cursor => $_getN(5);
  @$pb.TagNumber(6)
  set cursor($1.PageCursor value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearCursor() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.PageCursor ensureCursor() => $_ensure(5);
}

class AccessRoleAssignmentSearchResponse extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentSearchResponse({
    $core.Iterable<AccessRoleAssignmentObject>? data,
  }) {
    final result = AccessRoleAssignmentSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  AccessRoleAssignmentSearchResponse._();

  factory AccessRoleAssignmentSearchResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentSearchResponse()..mergeFromBuffer(data, registry);
  factory AccessRoleAssignmentSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AccessRoleAssignmentSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccessRoleAssignmentSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: AccessRoleAssignmentSearchResponse.$_createMessage)
    ..pPM<AccessRoleAssignmentObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: AccessRoleAssignmentObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccessRoleAssignmentSearchResponse copyWith(
          void Function(AccessRoleAssignmentSearchResponse) updates) =>
      super.copyWith((message) =>
              updates(message as AccessRoleAssignmentSearchResponse))
          as AccessRoleAssignmentSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AccessRoleAssignmentSearchResponse() / AccessRoleAssignmentSearchResponse.new instead')
  static AccessRoleAssignmentSearchResponse create() =>
      AccessRoleAssignmentSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      AccessRoleAssignmentSearchResponse._();
  @$core.override
  AccessRoleAssignmentSearchResponse createEmptyInstance() =>
      AccessRoleAssignmentSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentSearchResponse>(
          AccessRoleAssignmentSearchResponse.$_createMessage);
  static AccessRoleAssignmentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AccessRoleAssignmentObject> get data => $_getList(0);
}

/// ClientGroupObject represents a collective entity (e.g. SACCO group) in the lending hierarchy.
class ClientGroupObject extends $pb.GeneratedMessage {
  factory ClientGroupObject({
    $core.String? id,
    $core.String? productId,
    $core.String? parentId,
    $core.String? agentId,
    $core.String? branchId,
    $core.String? profileId,
    $core.String? name,
    $core.int? groupType,
    $core.String? currencyCode,
    $fixnum.Int64? savingAmount,
    $core.String? timeZone,
    $core.int? minMembers,
    $core.int? maxMembers,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = ClientGroupObject._();
    if (id != null) result.id = id;
    if (productId != null) result.productId = productId;
    if (parentId != null) result.parentId = parentId;
    if (agentId != null) result.agentId = agentId;
    if (branchId != null) result.branchId = branchId;
    if (profileId != null) result.profileId = profileId;
    if (name != null) result.name = name;
    if (groupType != null) result.groupType = groupType;
    if (currencyCode != null) result.currencyCode = currencyCode;
    if (savingAmount != null) result.savingAmount = savingAmount;
    if (timeZone != null) result.timeZone = timeZone;
    if (minMembers != null) result.minMembers = minMembers;
    if (maxMembers != null) result.maxMembers = maxMembers;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  ClientGroupObject._();

  factory ClientGroupObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupObject()..mergeFromBuffer(data, registry);
  factory ClientGroupObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientGroupObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientGroupObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aOS(4, _omitFieldNames ? '' : 'agentId')
    ..aOS(5, _omitFieldNames ? '' : 'branchId')
    ..aOS(6, _omitFieldNames ? '' : 'profileId')
    ..aOS(7, _omitFieldNames ? '' : 'name')
    ..aI(8, _omitFieldNames ? '' : 'groupType')
    ..aOS(9, _omitFieldNames ? '' : 'currencyCode')
    ..aInt64(10, _omitFieldNames ? '' : 'savingAmount')
    ..aOS(11, _omitFieldNames ? '' : 'timeZone')
    ..aI(12, _omitFieldNames ? '' : 'minMembers')
    ..aI(13, _omitFieldNames ? '' : 'maxMembers')
    ..aE<$1.STATE>(14, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(15, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupObject copyWith(void Function(ClientGroupObject) updates) =>
      super.copyWith((message) => updates(message as ClientGroupObject))
          as ClientGroupObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClientGroupObject() / ClientGroupObject.new instead')
  static ClientGroupObject create() => ClientGroupObject._();
  static $pb.GeneratedMessage $_createMessage() => ClientGroupObject._();
  @$core.override
  ClientGroupObject createEmptyInstance() => ClientGroupObject._();
  @$core.pragma('dart2js:noInline')
  static ClientGroupObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGroupObject>(
          ClientGroupObject.$_createMessage);
  static ClientGroupObject? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get agentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set agentId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAgentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAgentId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get branchId => $_getSZ(4);
  @$pb.TagNumber(5)
  set branchId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBranchId() => $_has(4);
  @$pb.TagNumber(5)
  void clearBranchId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get profileId => $_getSZ(5);
  @$pb.TagNumber(6)
  set profileId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProfileId() => $_has(5);
  @$pb.TagNumber(6)
  void clearProfileId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get name => $_getSZ(6);
  @$pb.TagNumber(7)
  set name($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasName() => $_has(6);
  @$pb.TagNumber(7)
  void clearName() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get groupType => $_getIZ(7);
  @$pb.TagNumber(8)
  set groupType($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasGroupType() => $_has(7);
  @$pb.TagNumber(8)
  void clearGroupType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get currencyCode => $_getSZ(8);
  @$pb.TagNumber(9)
  set currencyCode($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCurrencyCode() => $_has(8);
  @$pb.TagNumber(9)
  void clearCurrencyCode() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get savingAmount => $_getI64(9);
  @$pb.TagNumber(10)
  set savingAmount($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSavingAmount() => $_has(9);
  @$pb.TagNumber(10)
  void clearSavingAmount() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get timeZone => $_getSZ(10);
  @$pb.TagNumber(11)
  set timeZone($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasTimeZone() => $_has(10);
  @$pb.TagNumber(11)
  void clearTimeZone() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get minMembers => $_getIZ(11);
  @$pb.TagNumber(12)
  set minMembers($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMinMembers() => $_has(11);
  @$pb.TagNumber(12)
  void clearMinMembers() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get maxMembers => $_getIZ(12);
  @$pb.TagNumber(13)
  set maxMembers($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasMaxMembers() => $_has(12);
  @$pb.TagNumber(13)
  void clearMaxMembers() => $_clearField(13);

  @$pb.TagNumber(14)
  $1.STATE get state => $_getN(13);
  @$pb.TagNumber(14)
  set state($1.STATE value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasState() => $_has(13);
  @$pb.TagNumber(14)
  void clearState() => $_clearField(14);

  @$pb.TagNumber(15)
  $0.Struct get properties => $_getN(14);
  @$pb.TagNumber(15)
  set properties($0.Struct value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasProperties() => $_has(14);
  @$pb.TagNumber(15)
  void clearProperties() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Struct ensureProperties() => $_ensure(14);
}

class ClientGroupSaveRequest extends $pb.GeneratedMessage {
  factory ClientGroupSaveRequest({
    ClientGroupObject? data,
  }) {
    final result = ClientGroupSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  ClientGroupSaveRequest._();

  factory ClientGroupSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupSaveRequest()..mergeFromBuffer(data, registry);
  factory ClientGroupSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientGroupSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientGroupSaveRequest.$_createMessage)
    ..aOM<ClientGroupObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientGroupObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupSaveRequest copyWith(
          void Function(ClientGroupSaveRequest) updates) =>
      super.copyWith((message) => updates(message as ClientGroupSaveRequest))
          as ClientGroupSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientGroupSaveRequest() / ClientGroupSaveRequest.new instead')
  static ClientGroupSaveRequest create() => ClientGroupSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientGroupSaveRequest._();
  @$core.override
  ClientGroupSaveRequest createEmptyInstance() => ClientGroupSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientGroupSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientGroupSaveRequest>(
          ClientGroupSaveRequest.$_createMessage);
  static ClientGroupSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ClientGroupObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientGroupObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientGroupObject ensureData() => $_ensure(0);
}

class ClientGroupSaveResponse extends $pb.GeneratedMessage {
  factory ClientGroupSaveResponse({
    ClientGroupObject? data,
  }) {
    final result = ClientGroupSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientGroupSaveResponse._();

  factory ClientGroupSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupSaveResponse()..mergeFromBuffer(data, registry);
  factory ClientGroupSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientGroupSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientGroupSaveResponse.$_createMessage)
    ..aOM<ClientGroupObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientGroupObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupSaveResponse copyWith(
          void Function(ClientGroupSaveResponse) updates) =>
      super.copyWith((message) => updates(message as ClientGroupSaveResponse))
          as ClientGroupSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientGroupSaveResponse() / ClientGroupSaveResponse.new instead')
  static ClientGroupSaveResponse create() => ClientGroupSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientGroupSaveResponse._();
  @$core.override
  ClientGroupSaveResponse createEmptyInstance() => ClientGroupSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientGroupSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientGroupSaveResponse>(
          ClientGroupSaveResponse.$_createMessage);
  static ClientGroupSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientGroupObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientGroupObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientGroupObject ensureData() => $_ensure(0);
}

class ClientGroupGetRequest extends $pb.GeneratedMessage {
  factory ClientGroupGetRequest({
    $core.String? id,
  }) {
    final result = ClientGroupGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  ClientGroupGetRequest._();

  factory ClientGroupGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupGetRequest()..mergeFromBuffer(data, registry);
  factory ClientGroupGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientGroupGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientGroupGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupGetRequest copyWith(
          void Function(ClientGroupGetRequest) updates) =>
      super.copyWith((message) => updates(message as ClientGroupGetRequest))
          as ClientGroupGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientGroupGetRequest() / ClientGroupGetRequest.new instead')
  static ClientGroupGetRequest create() => ClientGroupGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientGroupGetRequest._();
  @$core.override
  ClientGroupGetRequest createEmptyInstance() => ClientGroupGetRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientGroupGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientGroupGetRequest>(
          ClientGroupGetRequest.$_createMessage);
  static ClientGroupGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ClientGroupGetResponse extends $pb.GeneratedMessage {
  factory ClientGroupGetResponse({
    ClientGroupObject? data,
  }) {
    final result = ClientGroupGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientGroupGetResponse._();

  factory ClientGroupGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupGetResponse()..mergeFromBuffer(data, registry);
  factory ClientGroupGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientGroupGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientGroupGetResponse.$_createMessage)
    ..aOM<ClientGroupObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientGroupObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupGetResponse copyWith(
          void Function(ClientGroupGetResponse) updates) =>
      super.copyWith((message) => updates(message as ClientGroupGetResponse))
          as ClientGroupGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientGroupGetResponse() / ClientGroupGetResponse.new instead')
  static ClientGroupGetResponse create() => ClientGroupGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientGroupGetResponse._();
  @$core.override
  ClientGroupGetResponse createEmptyInstance() => ClientGroupGetResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientGroupGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientGroupGetResponse>(
          ClientGroupGetResponse.$_createMessage);
  static ClientGroupGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientGroupObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientGroupObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientGroupObject ensureData() => $_ensure(0);
}

class ClientGroupSearchRequest extends $pb.GeneratedMessage {
  factory ClientGroupSearchRequest({
    $core.String? query,
    $core.String? agentId,
    $core.String? branchId,
    $1.PageCursor? cursor,
    $core.String? parentId,
    $core.String? productId,
    $core.int? groupType,
    $1.STATE? state,
  }) {
    final result = ClientGroupSearchRequest._();
    if (query != null) result.query = query;
    if (agentId != null) result.agentId = agentId;
    if (branchId != null) result.branchId = branchId;
    if (cursor != null) result.cursor = cursor;
    if (parentId != null) result.parentId = parentId;
    if (productId != null) result.productId = productId;
    if (groupType != null) result.groupType = groupType;
    if (state != null) result.state = state;
    return result;
  }

  ClientGroupSearchRequest._();

  factory ClientGroupSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupSearchRequest()..mergeFromBuffer(data, registry);
  factory ClientGroupSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientGroupSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientGroupSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'agentId')
    ..aOS(3, _omitFieldNames ? '' : 'branchId')
    ..aOM<$1.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..aOS(5, _omitFieldNames ? '' : 'parentId')
    ..aOS(6, _omitFieldNames ? '' : 'productId')
    ..aI(7, _omitFieldNames ? '' : 'groupType')
    ..aE<$1.STATE>(8, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupSearchRequest copyWith(
          void Function(ClientGroupSearchRequest) updates) =>
      super.copyWith((message) => updates(message as ClientGroupSearchRequest))
          as ClientGroupSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientGroupSearchRequest() / ClientGroupSearchRequest.new instead')
  static ClientGroupSearchRequest create() => ClientGroupSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientGroupSearchRequest._();
  @$core.override
  ClientGroupSearchRequest createEmptyInstance() =>
      ClientGroupSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientGroupSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientGroupSearchRequest>(
          ClientGroupSearchRequest.$_createMessage);
  static ClientGroupSearchRequest? _defaultInstance;

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
  $core.String get branchId => $_getSZ(2);
  @$pb.TagNumber(3)
  set branchId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBranchId() => $_has(2);
  @$pb.TagNumber(3)
  void clearBranchId() => $_clearField(3);

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
  $core.String get parentId => $_getSZ(4);
  @$pb.TagNumber(5)
  set parentId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasParentId() => $_has(4);
  @$pb.TagNumber(5)
  void clearParentId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get productId => $_getSZ(5);
  @$pb.TagNumber(6)
  set productId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProductId() => $_has(5);
  @$pb.TagNumber(6)
  void clearProductId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get groupType => $_getIZ(6);
  @$pb.TagNumber(7)
  set groupType($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGroupType() => $_has(6);
  @$pb.TagNumber(7)
  void clearGroupType() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.STATE get state => $_getN(7);
  @$pb.TagNumber(8)
  set state($1.STATE value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasState() => $_has(7);
  @$pb.TagNumber(8)
  void clearState() => $_clearField(8);
}

class ClientGroupSearchResponse extends $pb.GeneratedMessage {
  factory ClientGroupSearchResponse({
    $core.Iterable<ClientGroupObject>? data,
  }) {
    final result = ClientGroupSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  ClientGroupSearchResponse._();

  factory ClientGroupSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupSearchResponse()..mergeFromBuffer(data, registry);
  factory ClientGroupSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientGroupSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientGroupSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientGroupSearchResponse.$_createMessage)
    ..pPM<ClientGroupObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientGroupObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientGroupSearchResponse copyWith(
          void Function(ClientGroupSearchResponse) updates) =>
      super.copyWith((message) => updates(message as ClientGroupSearchResponse))
          as ClientGroupSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientGroupSearchResponse() / ClientGroupSearchResponse.new instead')
  static ClientGroupSearchResponse create() => ClientGroupSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientGroupSearchResponse._();
  @$core.override
  ClientGroupSearchResponse createEmptyInstance() =>
      ClientGroupSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientGroupSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientGroupSearchResponse>(
          ClientGroupSearchResponse.$_createMessage);
  static ClientGroupSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ClientGroupObject> get data => $_getList(0);
}

/// MembershipObject tracks a profile's affiliation with a client group.
class MembershipObject extends $pb.GeneratedMessage {
  factory MembershipObject({
    $core.String? id,
    $core.String? groupId,
    $core.String? profileId,
    $core.String? name,
    $core.String? contactId,
    $core.int? role,
    $core.int? membershipType,
    $core.int? orderNo,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = MembershipObject._();
    if (id != null) result.id = id;
    if (groupId != null) result.groupId = groupId;
    if (profileId != null) result.profileId = profileId;
    if (name != null) result.name = name;
    if (contactId != null) result.contactId = contactId;
    if (role != null) result.role = role;
    if (membershipType != null) result.membershipType = membershipType;
    if (orderNo != null) result.orderNo = orderNo;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  MembershipObject._();

  factory MembershipObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipObject()..mergeFromBuffer(data, registry);
  factory MembershipObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: MembershipObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'profileId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'contactId')
    ..aI(6, _omitFieldNames ? '' : 'role')
    ..aI(7, _omitFieldNames ? '' : 'membershipType')
    ..aI(8, _omitFieldNames ? '' : 'orderNo')
    ..aE<$1.STATE>(9, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(10, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipObject copyWith(void Function(MembershipObject) updates) =>
      super.copyWith((message) => updates(message as MembershipObject))
          as MembershipObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MembershipObject() / MembershipObject.new instead')
  static MembershipObject create() => MembershipObject._();
  static $pb.GeneratedMessage $_createMessage() => MembershipObject._();
  @$core.override
  MembershipObject createEmptyInstance() => MembershipObject._();
  @$core.pragma('dart2js:noInline')
  static MembershipObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MembershipObject>(
          MembershipObject.$_createMessage);
  static MembershipObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

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
  $core.String get contactId => $_getSZ(4);
  @$pb.TagNumber(5)
  set contactId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasContactId() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get role => $_getIZ(5);
  @$pb.TagNumber(6)
  set role($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRole() => $_has(5);
  @$pb.TagNumber(6)
  void clearRole() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get membershipType => $_getIZ(6);
  @$pb.TagNumber(7)
  set membershipType($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMembershipType() => $_has(6);
  @$pb.TagNumber(7)
  void clearMembershipType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get orderNo => $_getIZ(7);
  @$pb.TagNumber(8)
  set orderNo($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOrderNo() => $_has(7);
  @$pb.TagNumber(8)
  void clearOrderNo() => $_clearField(8);

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
}

class MembershipSaveRequest extends $pb.GeneratedMessage {
  factory MembershipSaveRequest({
    MembershipObject? data,
  }) {
    final result = MembershipSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  MembershipSaveRequest._();

  factory MembershipSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipSaveRequest()..mergeFromBuffer(data, registry);
  factory MembershipSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: MembershipSaveRequest.$_createMessage)
    ..aOM<MembershipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: MembershipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipSaveRequest copyWith(
          void Function(MembershipSaveRequest) updates) =>
      super.copyWith((message) => updates(message as MembershipSaveRequest))
          as MembershipSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use MembershipSaveRequest() / MembershipSaveRequest.new instead')
  static MembershipSaveRequest create() => MembershipSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => MembershipSaveRequest._();
  @$core.override
  MembershipSaveRequest createEmptyInstance() => MembershipSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static MembershipSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipSaveRequest>(
          MembershipSaveRequest.$_createMessage);
  static MembershipSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  MembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(MembershipObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  MembershipObject ensureData() => $_ensure(0);
}

class MembershipSaveResponse extends $pb.GeneratedMessage {
  factory MembershipSaveResponse({
    MembershipObject? data,
  }) {
    final result = MembershipSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  MembershipSaveResponse._();

  factory MembershipSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipSaveResponse()..mergeFromBuffer(data, registry);
  factory MembershipSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: MembershipSaveResponse.$_createMessage)
    ..aOM<MembershipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: MembershipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipSaveResponse copyWith(
          void Function(MembershipSaveResponse) updates) =>
      super.copyWith((message) => updates(message as MembershipSaveResponse))
          as MembershipSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use MembershipSaveResponse() / MembershipSaveResponse.new instead')
  static MembershipSaveResponse create() => MembershipSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => MembershipSaveResponse._();
  @$core.override
  MembershipSaveResponse createEmptyInstance() => MembershipSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static MembershipSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipSaveResponse>(
          MembershipSaveResponse.$_createMessage);
  static MembershipSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(MembershipObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  MembershipObject ensureData() => $_ensure(0);
}

class MembershipGetRequest extends $pb.GeneratedMessage {
  factory MembershipGetRequest({
    $core.String? id,
  }) {
    final result = MembershipGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  MembershipGetRequest._();

  factory MembershipGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipGetRequest()..mergeFromBuffer(data, registry);
  factory MembershipGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: MembershipGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipGetRequest copyWith(void Function(MembershipGetRequest) updates) =>
      super.copyWith((message) => updates(message as MembershipGetRequest))
          as MembershipGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use MembershipGetRequest() / MembershipGetRequest.new instead')
  static MembershipGetRequest create() => MembershipGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => MembershipGetRequest._();
  @$core.override
  MembershipGetRequest createEmptyInstance() => MembershipGetRequest._();
  @$core.pragma('dart2js:noInline')
  static MembershipGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipGetRequest>(
          MembershipGetRequest.$_createMessage);
  static MembershipGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class MembershipGetResponse extends $pb.GeneratedMessage {
  factory MembershipGetResponse({
    MembershipObject? data,
  }) {
    final result = MembershipGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  MembershipGetResponse._();

  factory MembershipGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipGetResponse()..mergeFromBuffer(data, registry);
  factory MembershipGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: MembershipGetResponse.$_createMessage)
    ..aOM<MembershipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: MembershipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipGetResponse copyWith(
          void Function(MembershipGetResponse) updates) =>
      super.copyWith((message) => updates(message as MembershipGetResponse))
          as MembershipGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use MembershipGetResponse() / MembershipGetResponse.new instead')
  static MembershipGetResponse create() => MembershipGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => MembershipGetResponse._();
  @$core.override
  MembershipGetResponse createEmptyInstance() => MembershipGetResponse._();
  @$core.pragma('dart2js:noInline')
  static MembershipGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipGetResponse>(
          MembershipGetResponse.$_createMessage);
  static MembershipGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(MembershipObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  MembershipObject ensureData() => $_ensure(0);
}

class MembershipSearchRequest extends $pb.GeneratedMessage {
  factory MembershipSearchRequest({
    $core.String? query,
    $core.String? groupId,
    $core.String? profileId,
    $1.PageCursor? cursor,
    $core.String? contactId,
    $core.int? role,
    $core.int? membershipType,
    $1.STATE? state,
  }) {
    final result = MembershipSearchRequest._();
    if (query != null) result.query = query;
    if (groupId != null) result.groupId = groupId;
    if (profileId != null) result.profileId = profileId;
    if (cursor != null) result.cursor = cursor;
    if (contactId != null) result.contactId = contactId;
    if (role != null) result.role = role;
    if (membershipType != null) result.membershipType = membershipType;
    if (state != null) result.state = state;
    return result;
  }

  MembershipSearchRequest._();

  factory MembershipSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipSearchRequest()..mergeFromBuffer(data, registry);
  factory MembershipSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: MembershipSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'profileId')
    ..aOM<$1.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..aOS(5, _omitFieldNames ? '' : 'contactId')
    ..aI(6, _omitFieldNames ? '' : 'role')
    ..aI(7, _omitFieldNames ? '' : 'membershipType')
    ..aE<$1.STATE>(8, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipSearchRequest copyWith(
          void Function(MembershipSearchRequest) updates) =>
      super.copyWith((message) => updates(message as MembershipSearchRequest))
          as MembershipSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use MembershipSearchRequest() / MembershipSearchRequest.new instead')
  static MembershipSearchRequest create() => MembershipSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() => MembershipSearchRequest._();
  @$core.override
  MembershipSearchRequest createEmptyInstance() => MembershipSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static MembershipSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipSearchRequest>(
          MembershipSearchRequest.$_createMessage);
  static MembershipSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get profileId => $_getSZ(2);
  @$pb.TagNumber(3)
  set profileId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProfileId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProfileId() => $_clearField(3);

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
  $core.String get contactId => $_getSZ(4);
  @$pb.TagNumber(5)
  set contactId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasContactId() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get role => $_getIZ(5);
  @$pb.TagNumber(6)
  set role($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRole() => $_has(5);
  @$pb.TagNumber(6)
  void clearRole() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get membershipType => $_getIZ(6);
  @$pb.TagNumber(7)
  set membershipType($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMembershipType() => $_has(6);
  @$pb.TagNumber(7)
  void clearMembershipType() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.STATE get state => $_getN(7);
  @$pb.TagNumber(8)
  set state($1.STATE value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasState() => $_has(7);
  @$pb.TagNumber(8)
  void clearState() => $_clearField(8);
}

class MembershipSearchResponse extends $pb.GeneratedMessage {
  factory MembershipSearchResponse({
    $core.Iterable<MembershipObject>? data,
  }) {
    final result = MembershipSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  MembershipSearchResponse._();

  factory MembershipSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipSearchResponse()..mergeFromBuffer(data, registry);
  factory MembershipSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MembershipSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: MembershipSearchResponse.$_createMessage)
    ..pPM<MembershipObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: MembershipObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipSearchResponse copyWith(
          void Function(MembershipSearchResponse) updates) =>
      super.copyWith((message) => updates(message as MembershipSearchResponse))
          as MembershipSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use MembershipSearchResponse() / MembershipSearchResponse.new instead')
  static MembershipSearchResponse create() => MembershipSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() => MembershipSearchResponse._();
  @$core.override
  MembershipSearchResponse createEmptyInstance() =>
      MembershipSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static MembershipSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipSearchResponse>(
          MembershipSearchResponse.$_createMessage);
  static MembershipSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MembershipObject> get data => $_getList(0);
}

/// InvestorAccountObject represents a pre-funded investor capital account.
class InvestorAccountObject extends $pb.GeneratedMessage {
  factory InvestorAccountObject({
    $core.String? id,
    $core.String? investorId,
    $core.String? accountName,
    $2.Money? availableBalance,
    $2.Money? reservedBalance,
    $2.Money? totalDeployed,
    $2.Money? totalReturned,
    $2.Money? maxExposure,
    $core.String? minInterestRate,
    $0.Struct? allowedProducts,
    $0.Struct? allowedRegions,
    $0.Struct? groupAffiliations,
    $1.STATE? state,
    $0.Struct? properties,
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorAccountObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'investorId')
    ..aOS(3, _omitFieldNames ? '' : 'accountName')
    ..aOM<$2.Money>(5, _omitFieldNames ? '' : 'availableBalance',
        subBuilder: $2.Money.$_createMessage)
    ..aOM<$2.Money>(6, _omitFieldNames ? '' : 'reservedBalance',
        subBuilder: $2.Money.$_createMessage)
    ..aOM<$2.Money>(7, _omitFieldNames ? '' : 'totalDeployed',
        subBuilder: $2.Money.$_createMessage)
    ..aOM<$2.Money>(8, _omitFieldNames ? '' : 'totalReturned',
        subBuilder: $2.Money.$_createMessage)
    ..aOM<$2.Money>(9, _omitFieldNames ? '' : 'maxExposure',
        subBuilder: $2.Money.$_createMessage)
    ..aOS(10, _omitFieldNames ? '' : 'minInterestRate')
    ..aOM<$0.Struct>(11, _omitFieldNames ? '' : 'allowedProducts',
        subBuilder: $0.Struct.$_createMessage)
    ..aOM<$0.Struct>(12, _omitFieldNames ? '' : 'allowedRegions',
        subBuilder: $0.Struct.$_createMessage)
    ..aOM<$0.Struct>(13, _omitFieldNames ? '' : 'groupAffiliations',
        subBuilder: $0.Struct.$_createMessage)
    ..aE<$1.STATE>(14, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(15, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
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
  $2.Money get availableBalance => $_getN(3);
  @$pb.TagNumber(5)
  set availableBalance($2.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAvailableBalance() => $_has(3);
  @$pb.TagNumber(5)
  void clearAvailableBalance() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.Money ensureAvailableBalance() => $_ensure(3);

  @$pb.TagNumber(6)
  $2.Money get reservedBalance => $_getN(4);
  @$pb.TagNumber(6)
  set reservedBalance($2.Money value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasReservedBalance() => $_has(4);
  @$pb.TagNumber(6)
  void clearReservedBalance() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.Money ensureReservedBalance() => $_ensure(4);

  @$pb.TagNumber(7)
  $2.Money get totalDeployed => $_getN(5);
  @$pb.TagNumber(7)
  set totalDeployed($2.Money value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTotalDeployed() => $_has(5);
  @$pb.TagNumber(7)
  void clearTotalDeployed() => $_clearField(7);
  @$pb.TagNumber(7)
  $2.Money ensureTotalDeployed() => $_ensure(5);

  @$pb.TagNumber(8)
  $2.Money get totalReturned => $_getN(6);
  @$pb.TagNumber(8)
  set totalReturned($2.Money value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasTotalReturned() => $_has(6);
  @$pb.TagNumber(8)
  void clearTotalReturned() => $_clearField(8);
  @$pb.TagNumber(8)
  $2.Money ensureTotalReturned() => $_ensure(6);

  @$pb.TagNumber(9)
  $2.Money get maxExposure => $_getN(7);
  @$pb.TagNumber(9)
  set maxExposure($2.Money value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasMaxExposure() => $_has(7);
  @$pb.TagNumber(9)
  void clearMaxExposure() => $_clearField(9);
  @$pb.TagNumber(9)
  $2.Money ensureMaxExposure() => $_ensure(7);

  @$pb.TagNumber(10)
  $core.String get minInterestRate => $_getSZ(8);
  @$pb.TagNumber(10)
  set minInterestRate($core.String value) => $_setString(8, value);
  @$pb.TagNumber(10)
  $core.bool hasMinInterestRate() => $_has(8);
  @$pb.TagNumber(10)
  void clearMinInterestRate() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Struct get allowedProducts => $_getN(9);
  @$pb.TagNumber(11)
  set allowedProducts($0.Struct value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasAllowedProducts() => $_has(9);
  @$pb.TagNumber(11)
  void clearAllowedProducts() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Struct ensureAllowedProducts() => $_ensure(9);

  @$pb.TagNumber(12)
  $0.Struct get allowedRegions => $_getN(10);
  @$pb.TagNumber(12)
  set allowedRegions($0.Struct value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasAllowedRegions() => $_has(10);
  @$pb.TagNumber(12)
  void clearAllowedRegions() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Struct ensureAllowedRegions() => $_ensure(10);

  @$pb.TagNumber(13)
  $0.Struct get groupAffiliations => $_getN(11);
  @$pb.TagNumber(13)
  set groupAffiliations($0.Struct value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasGroupAffiliations() => $_has(11);
  @$pb.TagNumber(13)
  void clearGroupAffiliations() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Struct ensureGroupAffiliations() => $_ensure(11);

  @$pb.TagNumber(14)
  $1.STATE get state => $_getN(12);
  @$pb.TagNumber(14)
  set state($1.STATE value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasState() => $_has(12);
  @$pb.TagNumber(14)
  void clearState() => $_clearField(14);

  @$pb.TagNumber(15)
  $0.Struct get properties => $_getN(13);
  @$pb.TagNumber(15)
  set properties($0.Struct value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasProperties() => $_has(13);
  @$pb.TagNumber(15)
  void clearProperties() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Struct ensureProperties() => $_ensure(13);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
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
    $1.PageCursor? cursor,
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorAccountSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'investorId')
    ..aOS(2, _omitFieldNames ? '' : 'currencyCode')
    ..aOM<$1.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
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

class InvestorAccountSearchResponse extends $pb.GeneratedMessage {
  factory InvestorAccountSearchResponse({
    $core.Iterable<InvestorAccountObject>? data,
  }) {
    final result = InvestorAccountSearchResponse._();
    if (data != null) result.data.addAll(data);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorAccountSearchResponse.$_createMessage)
    ..pPM<InvestorAccountObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: InvestorAccountObject.$_createMessage)
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
}

class InvestorDepositRequest extends $pb.GeneratedMessage {
  factory InvestorDepositRequest({
    $core.String? accountId,
    $2.Money? amount,
  }) {
    final result = InvestorDepositRequest._();
    if (accountId != null) result.accountId = accountId;
    if (amount != null) result.amount = amount;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorDepositRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'accountId')
    ..aOM<$2.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $2.Money.$_createMessage)
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
  $2.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($2.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.Money ensureAmount() => $_ensure(1);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
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
    $2.Money? amount,
  }) {
    final result = InvestorWithdrawRequest._();
    if (accountId != null) result.accountId = accountId;
    if (amount != null) result.amount = amount;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: InvestorWithdrawRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'accountId')
    ..aOM<$2.Money>(2, _omitFieldNames ? '' : 'amount',
        subBuilder: $2.Money.$_createMessage)
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
  $2.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($2.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.Money ensureAmount() => $_ensure(1);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
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

/// FormFieldDefinition defines a single field in a form template.
class FormFieldDefinition extends $pb.GeneratedMessage {
  factory FormFieldDefinition({
    $core.String? key,
    $core.String? label,
    FormFieldType? fieldType,
    FormFieldGroup? group,
    $core.bool? required,
    $core.String? description,
    $core.String? placeholder,
    $core.String? defaultValue,
    $core.String? validationPattern,
    $core.String? validationMessage,
    $core.Iterable<$core.String>? options,
    $core.int? minLength,
    $core.int? maxLength,
    $core.String? minValue,
    $core.String? maxValue,
    $core.int? order,
    $core.String? section,
    $core.bool? encrypted,
    $0.Struct? properties,
  }) {
    final result = FormFieldDefinition._();
    if (key != null) result.key = key;
    if (label != null) result.label = label;
    if (fieldType != null) result.fieldType = fieldType;
    if (group != null) result.group = group;
    if (required != null) result.required = required;
    if (description != null) result.description = description;
    if (placeholder != null) result.placeholder = placeholder;
    if (defaultValue != null) result.defaultValue = defaultValue;
    if (validationPattern != null) result.validationPattern = validationPattern;
    if (validationMessage != null) result.validationMessage = validationMessage;
    if (options != null) result.options.addAll(options);
    if (minLength != null) result.minLength = minLength;
    if (maxLength != null) result.maxLength = maxLength;
    if (minValue != null) result.minValue = minValue;
    if (maxValue != null) result.maxValue = maxValue;
    if (order != null) result.order = order;
    if (section != null) result.section = section;
    if (encrypted != null) result.encrypted = encrypted;
    if (properties != null) result.properties = properties;
    return result;
  }

  FormFieldDefinition._();

  factory FormFieldDefinition.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormFieldDefinition()..mergeFromBuffer(data, registry);
  factory FormFieldDefinition.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormFieldDefinition()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormFieldDefinition',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormFieldDefinition.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aE<FormFieldType>(3, _omitFieldNames ? '' : 'fieldType',
        enumValues: FormFieldType.values)
    ..aE<FormFieldGroup>(4, _omitFieldNames ? '' : 'group',
        enumValues: FormFieldGroup.values)
    ..aOB(5, _omitFieldNames ? '' : 'required')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'placeholder')
    ..aOS(8, _omitFieldNames ? '' : 'defaultValue')
    ..aOS(9, _omitFieldNames ? '' : 'validationPattern')
    ..aOS(10, _omitFieldNames ? '' : 'validationMessage')
    ..pPS(11, _omitFieldNames ? '' : 'options')
    ..aI(12, _omitFieldNames ? '' : 'minLength')
    ..aI(13, _omitFieldNames ? '' : 'maxLength')
    ..aOS(14, _omitFieldNames ? '' : 'minValue')
    ..aOS(15, _omitFieldNames ? '' : 'maxValue')
    ..aI(16, _omitFieldNames ? '' : 'order')
    ..aOS(17, _omitFieldNames ? '' : 'section')
    ..aOB(18, _omitFieldNames ? '' : 'encrypted')
    ..aOM<$0.Struct>(19, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormFieldDefinition clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormFieldDefinition copyWith(void Function(FormFieldDefinition) updates) =>
      super.copyWith((message) => updates(message as FormFieldDefinition))
          as FormFieldDefinition;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use FormFieldDefinition() / FormFieldDefinition.new instead')
  static FormFieldDefinition create() => FormFieldDefinition._();
  static $pb.GeneratedMessage $_createMessage() => FormFieldDefinition._();
  @$core.override
  FormFieldDefinition createEmptyInstance() => FormFieldDefinition._();
  @$core.pragma('dart2js:noInline')
  static FormFieldDefinition getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormFieldDefinition>(
          FormFieldDefinition.$_createMessage);
  static FormFieldDefinition? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  FormFieldType get fieldType => $_getN(2);
  @$pb.TagNumber(3)
  set fieldType(FormFieldType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldType() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldType() => $_clearField(3);

  @$pb.TagNumber(4)
  FormFieldGroup get group => $_getN(3);
  @$pb.TagNumber(4)
  set group(FormFieldGroup value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasGroup() => $_has(3);
  @$pb.TagNumber(4)
  void clearGroup() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get required => $_getBF(4);
  @$pb.TagNumber(5)
  set required($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRequired() => $_has(4);
  @$pb.TagNumber(5)
  void clearRequired() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get placeholder => $_getSZ(6);
  @$pb.TagNumber(7)
  set placeholder($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPlaceholder() => $_has(6);
  @$pb.TagNumber(7)
  void clearPlaceholder() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get defaultValue => $_getSZ(7);
  @$pb.TagNumber(8)
  set defaultValue($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDefaultValue() => $_has(7);
  @$pb.TagNumber(8)
  void clearDefaultValue() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get validationPattern => $_getSZ(8);
  @$pb.TagNumber(9)
  set validationPattern($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasValidationPattern() => $_has(8);
  @$pb.TagNumber(9)
  void clearValidationPattern() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get validationMessage => $_getSZ(9);
  @$pb.TagNumber(10)
  set validationMessage($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasValidationMessage() => $_has(9);
  @$pb.TagNumber(10)
  void clearValidationMessage() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<$core.String> get options => $_getList(10);

  @$pb.TagNumber(12)
  $core.int get minLength => $_getIZ(11);
  @$pb.TagNumber(12)
  set minLength($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMinLength() => $_has(11);
  @$pb.TagNumber(12)
  void clearMinLength() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get maxLength => $_getIZ(12);
  @$pb.TagNumber(13)
  set maxLength($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasMaxLength() => $_has(12);
  @$pb.TagNumber(13)
  void clearMaxLength() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get minValue => $_getSZ(13);
  @$pb.TagNumber(14)
  set minValue($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasMinValue() => $_has(13);
  @$pb.TagNumber(14)
  void clearMinValue() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get maxValue => $_getSZ(14);
  @$pb.TagNumber(15)
  set maxValue($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasMaxValue() => $_has(14);
  @$pb.TagNumber(15)
  void clearMaxValue() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get order => $_getIZ(15);
  @$pb.TagNumber(16)
  set order($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasOrder() => $_has(15);
  @$pb.TagNumber(16)
  void clearOrder() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get section => $_getSZ(16);
  @$pb.TagNumber(17)
  set section($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasSection() => $_has(16);
  @$pb.TagNumber(17)
  void clearSection() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.bool get encrypted => $_getBF(17);
  @$pb.TagNumber(18)
  set encrypted($core.bool value) => $_setBool(17, value);
  @$pb.TagNumber(18)
  $core.bool hasEncrypted() => $_has(17);
  @$pb.TagNumber(18)
  void clearEncrypted() => $_clearField(18);

  @$pb.TagNumber(19)
  $0.Struct get properties => $_getN(18);
  @$pb.TagNumber(19)
  set properties($0.Struct value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasProperties() => $_has(18);
  @$pb.TagNumber(19)
  void clearProperties() => $_clearField(19);
  @$pb.TagNumber(19)
  $0.Struct ensureProperties() => $_ensure(18);
}

/// FormTemplateObject defines a reusable form schema for dynamic data collection.
///
/// Form templates are the backbone of dynamic data collection across the
/// platform. A single template can be used for loan origination KYC,
/// client onboarding, group membership registration, investor KYC, or
/// any other structured data collection requirement.
///
/// The entity_type field determines which domain the template serves
/// (e.g. "client", "agent", "investor", "group", "loan_request").
class FormTemplateObject extends $pb.GeneratedMessage {
  factory FormTemplateObject({
    $core.String? id,
    $core.String? organizationId,
    $core.String? name,
    $core.String? description,
    $core.int? version,
    FormTemplateStatus? status,
    $core.Iterable<FormFieldDefinition>? fields,
    $core.Iterable<$core.String>? sections,
    $0.Struct? validationRules,
    $0.Struct? properties,
    $core.String? entityType,
  }) {
    final result = FormTemplateObject._();
    if (id != null) result.id = id;
    if (organizationId != null) result.organizationId = organizationId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (version != null) result.version = version;
    if (status != null) result.status = status;
    if (fields != null) result.fields.addAll(fields);
    if (sections != null) result.sections.addAll(sections);
    if (validationRules != null) result.validationRules = validationRules;
    if (properties != null) result.properties = properties;
    if (entityType != null) result.entityType = entityType;
    return result;
  }

  FormTemplateObject._();

  factory FormTemplateObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateObject()..mergeFromBuffer(data, registry);
  factory FormTemplateObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormTemplateObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormTemplateObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aI(5, _omitFieldNames ? '' : 'version')
    ..aE<FormTemplateStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: FormTemplateStatus.values)
    ..pPM<FormFieldDefinition>(7, _omitFieldNames ? '' : 'fields',
        subBuilder: FormFieldDefinition.$_createMessage)
    ..pPS(8, _omitFieldNames ? '' : 'sections')
    ..aOM<$0.Struct>(9, _omitFieldNames ? '' : 'validationRules',
        subBuilder: $0.Struct.$_createMessage)
    ..aOM<$0.Struct>(10, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..aOS(11, _omitFieldNames ? '' : 'entityType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateObject copyWith(void Function(FormTemplateObject) updates) =>
      super.copyWith((message) => updates(message as FormTemplateObject))
          as FormTemplateObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FormTemplateObject() / FormTemplateObject.new instead')
  static FormTemplateObject create() => FormTemplateObject._();
  static $pb.GeneratedMessage $_createMessage() => FormTemplateObject._();
  @$core.override
  FormTemplateObject createEmptyInstance() => FormTemplateObject._();
  @$core.pragma('dart2js:noInline')
  static FormTemplateObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormTemplateObject>(
          FormTemplateObject.$_createMessage);
  static FormTemplateObject? _defaultInstance;

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
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  FormTemplateStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(FormTemplateStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<FormFieldDefinition> get fields => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get sections => $_getList(7);

  @$pb.TagNumber(9)
  $0.Struct get validationRules => $_getN(8);
  @$pb.TagNumber(9)
  set validationRules($0.Struct value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasValidationRules() => $_has(8);
  @$pb.TagNumber(9)
  void clearValidationRules() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Struct ensureValidationRules() => $_ensure(8);

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

  /// The entity type this template is designed for. Used to filter
  /// templates when loading requirements for a specific domain.
  /// Standard values: "client", "agent", "investor", "group", "loan_request".
  @$pb.TagNumber(11)
  $core.String get entityType => $_getSZ(10);
  @$pb.TagNumber(11)
  set entityType($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasEntityType() => $_has(10);
  @$pb.TagNumber(11)
  void clearEntityType() => $_clearField(11);
}

/// FormSubmissionObject captures filled form data for an entity.
///
/// Submissions are linked to an owning entity via entity_id.
/// The entity_type matches FormTemplateObject.entity_type.
class FormSubmissionObject extends $pb.GeneratedMessage {
  factory FormSubmissionObject({
    $core.String? id,
    $core.String? entityId,
    $core.String? entityType,
    $core.String? templateId,
    $core.int? templateVersion,
    $core.String? submittedBy,
    $0.Struct? data,
    $0.Struct? fileRefs,
    $1.STATE? state,
    $0.Struct? properties,
  }) {
    final result = FormSubmissionObject._();
    if (id != null) result.id = id;
    if (entityId != null) result.entityId = entityId;
    if (entityType != null) result.entityType = entityType;
    if (templateId != null) result.templateId = templateId;
    if (templateVersion != null) result.templateVersion = templateVersion;
    if (submittedBy != null) result.submittedBy = submittedBy;
    if (data != null) result.data = data;
    if (fileRefs != null) result.fileRefs = fileRefs;
    if (state != null) result.state = state;
    if (properties != null) result.properties = properties;
    return result;
  }

  FormSubmissionObject._();

  factory FormSubmissionObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionObject()..mergeFromBuffer(data, registry);
  factory FormSubmissionObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormSubmissionObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormSubmissionObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'entityId')
    ..aOS(3, _omitFieldNames ? '' : 'entityType')
    ..aOS(4, _omitFieldNames ? '' : 'templateId')
    ..aI(5, _omitFieldNames ? '' : 'templateVersion')
    ..aOS(6, _omitFieldNames ? '' : 'submittedBy')
    ..aOM<$0.Struct>(7, _omitFieldNames ? '' : 'data',
        subBuilder: $0.Struct.$_createMessage)
    ..aOM<$0.Struct>(8, _omitFieldNames ? '' : 'fileRefs',
        subBuilder: $0.Struct.$_createMessage)
    ..aE<$1.STATE>(9, _omitFieldNames ? '' : 'state',
        enumValues: $1.STATE.values)
    ..aOM<$0.Struct>(10, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionObject copyWith(void Function(FormSubmissionObject) updates) =>
      super.copyWith((message) => updates(message as FormSubmissionObject))
          as FormSubmissionObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormSubmissionObject() / FormSubmissionObject.new instead')
  static FormSubmissionObject create() => FormSubmissionObject._();
  static $pb.GeneratedMessage $_createMessage() => FormSubmissionObject._();
  @$core.override
  FormSubmissionObject createEmptyInstance() => FormSubmissionObject._();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormSubmissionObject>(
          FormSubmissionObject.$_createMessage);
  static FormSubmissionObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get entityId => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntityId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get entityType => $_getSZ(2);
  @$pb.TagNumber(3)
  set entityType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEntityType() => $_has(2);
  @$pb.TagNumber(3)
  void clearEntityType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get templateId => $_getSZ(3);
  @$pb.TagNumber(4)
  set templateId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTemplateId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTemplateId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get templateVersion => $_getIZ(4);
  @$pb.TagNumber(5)
  set templateVersion($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTemplateVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearTemplateVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get submittedBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set submittedBy($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSubmittedBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearSubmittedBy() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Struct get data => $_getN(6);
  @$pb.TagNumber(7)
  set data($0.Struct value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasData() => $_has(6);
  @$pb.TagNumber(7)
  void clearData() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Struct ensureData() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Struct get fileRefs => $_getN(7);
  @$pb.TagNumber(8)
  set fileRefs($0.Struct value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasFileRefs() => $_has(7);
  @$pb.TagNumber(8)
  void clearFileRefs() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Struct ensureFileRefs() => $_ensure(7);

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
}

/// ClientDataEntryObject stores a single piece of client KYC data.
/// Field keys are global identifiers shared across form templates.
/// Verified data is reusable across multiple applications.
class ClientDataEntryObject extends $pb.GeneratedMessage {
  factory ClientDataEntryObject({
    $core.String? id,
    $core.String? clientId,
    $core.String? fieldKey,
    $core.String? value,
    $core.String? valueType,
    DataVerificationStatus? verificationStatus,
    $core.String? reviewerId,
    $core.String? reviewerComment,
    $core.String? sourceEntityId,
    $core.int? revision,
    $core.String? verifiedAt,
    $core.String? expiresAt,
    $0.Struct? properties,
  }) {
    final result = ClientDataEntryObject._();
    if (id != null) result.id = id;
    if (clientId != null) result.clientId = clientId;
    if (fieldKey != null) result.fieldKey = fieldKey;
    if (value != null) result.value = value;
    if (valueType != null) result.valueType = valueType;
    if (verificationStatus != null)
      result.verificationStatus = verificationStatus;
    if (reviewerId != null) result.reviewerId = reviewerId;
    if (reviewerComment != null) result.reviewerComment = reviewerComment;
    if (sourceEntityId != null) result.sourceEntityId = sourceEntityId;
    if (revision != null) result.revision = revision;
    if (verifiedAt != null) result.verifiedAt = verifiedAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (properties != null) result.properties = properties;
    return result;
  }

  ClientDataEntryObject._();

  factory ClientDataEntryObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataEntryObject()..mergeFromBuffer(data, registry);
  factory ClientDataEntryObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataEntryObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataEntryObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataEntryObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'clientId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldKey')
    ..aOS(4, _omitFieldNames ? '' : 'value')
    ..aOS(5, _omitFieldNames ? '' : 'valueType')
    ..aE<DataVerificationStatus>(6, _omitFieldNames ? '' : 'verificationStatus',
        enumValues: DataVerificationStatus.values)
    ..aOS(7, _omitFieldNames ? '' : 'reviewerId')
    ..aOS(8, _omitFieldNames ? '' : 'reviewerComment')
    ..aOS(9, _omitFieldNames ? '' : 'sourceEntityId')
    ..aI(10, _omitFieldNames ? '' : 'revision')
    ..aOS(11, _omitFieldNames ? '' : 'verifiedAt')
    ..aOS(12, _omitFieldNames ? '' : 'expiresAt')
    ..aOM<$0.Struct>(13, _omitFieldNames ? '' : 'properties',
        subBuilder: $0.Struct.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataEntryObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataEntryObject copyWith(
          void Function(ClientDataEntryObject) updates) =>
      super.copyWith((message) => updates(message as ClientDataEntryObject))
          as ClientDataEntryObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataEntryObject() / ClientDataEntryObject.new instead')
  static ClientDataEntryObject create() => ClientDataEntryObject._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataEntryObject._();
  @$core.override
  ClientDataEntryObject createEmptyInstance() => ClientDataEntryObject._();
  @$core.pragma('dart2js:noInline')
  static ClientDataEntryObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataEntryObject>(
          ClientDataEntryObject.$_createMessage);
  static ClientDataEntryObject? _defaultInstance;

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
  $core.String get fieldKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get value => $_getSZ(3);
  @$pb.TagNumber(4)
  set value($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearValue() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get valueType => $_getSZ(4);
  @$pb.TagNumber(5)
  set valueType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasValueType() => $_has(4);
  @$pb.TagNumber(5)
  void clearValueType() => $_clearField(5);

  @$pb.TagNumber(6)
  DataVerificationStatus get verificationStatus => $_getN(5);
  @$pb.TagNumber(6)
  set verificationStatus(DataVerificationStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasVerificationStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearVerificationStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get reviewerId => $_getSZ(6);
  @$pb.TagNumber(7)
  set reviewerId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReviewerId() => $_has(6);
  @$pb.TagNumber(7)
  void clearReviewerId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get reviewerComment => $_getSZ(7);
  @$pb.TagNumber(8)
  set reviewerComment($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasReviewerComment() => $_has(7);
  @$pb.TagNumber(8)
  void clearReviewerComment() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get sourceEntityId => $_getSZ(8);
  @$pb.TagNumber(9)
  set sourceEntityId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSourceEntityId() => $_has(8);
  @$pb.TagNumber(9)
  void clearSourceEntityId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get revision => $_getIZ(9);
  @$pb.TagNumber(10)
  set revision($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRevision() => $_has(9);
  @$pb.TagNumber(10)
  void clearRevision() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get verifiedAt => $_getSZ(10);
  @$pb.TagNumber(11)
  set verifiedAt($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasVerifiedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearVerifiedAt() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get expiresAt => $_getSZ(11);
  @$pb.TagNumber(12)
  set expiresAt($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasExpiresAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearExpiresAt() => $_clearField(12);

  @$pb.TagNumber(13)
  $0.Struct get properties => $_getN(12);
  @$pb.TagNumber(13)
  set properties($0.Struct value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasProperties() => $_has(12);
  @$pb.TagNumber(13)
  void clearProperties() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Struct ensureProperties() => $_ensure(12);
}

/// ClientDataEntryHistoryObject tracks every action on a data entry.
class ClientDataEntryHistoryObject extends $pb.GeneratedMessage {
  factory ClientDataEntryHistoryObject({
    $core.String? id,
    $core.String? entryId,
    $core.int? revision,
    $core.String? value,
    $core.String? action,
    $core.String? actorId,
    $core.String? comment,
    $core.String? createdAt,
  }) {
    final result = ClientDataEntryHistoryObject._();
    if (id != null) result.id = id;
    if (entryId != null) result.entryId = entryId;
    if (revision != null) result.revision = revision;
    if (value != null) result.value = value;
    if (action != null) result.action = action;
    if (actorId != null) result.actorId = actorId;
    if (comment != null) result.comment = comment;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  ClientDataEntryHistoryObject._();

  factory ClientDataEntryHistoryObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataEntryHistoryObject()..mergeFromBuffer(data, registry);
  factory ClientDataEntryHistoryObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataEntryHistoryObject()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataEntryHistoryObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataEntryHistoryObject.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'entryId')
    ..aI(3, _omitFieldNames ? '' : 'revision')
    ..aOS(4, _omitFieldNames ? '' : 'value')
    ..aOS(5, _omitFieldNames ? '' : 'action')
    ..aOS(6, _omitFieldNames ? '' : 'actorId')
    ..aOS(7, _omitFieldNames ? '' : 'comment')
    ..aOS(8, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataEntryHistoryObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataEntryHistoryObject copyWith(
          void Function(ClientDataEntryHistoryObject) updates) =>
      super.copyWith(
              (message) => updates(message as ClientDataEntryHistoryObject))
          as ClientDataEntryHistoryObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataEntryHistoryObject() / ClientDataEntryHistoryObject.new instead')
  static ClientDataEntryHistoryObject create() =>
      ClientDataEntryHistoryObject._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientDataEntryHistoryObject._();
  @$core.override
  ClientDataEntryHistoryObject createEmptyInstance() =>
      ClientDataEntryHistoryObject._();
  @$core.pragma('dart2js:noInline')
  static ClientDataEntryHistoryObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataEntryHistoryObject>(
          ClientDataEntryHistoryObject.$_createMessage);
  static ClientDataEntryHistoryObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get entryId => $_getSZ(1);
  @$pb.TagNumber(2)
  set entryId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntryId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntryId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get revision => $_getIZ(2);
  @$pb.TagNumber(3)
  set revision($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevision() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevision() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get value => $_getSZ(3);
  @$pb.TagNumber(4)
  set value($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearValue() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get action => $_getSZ(4);
  @$pb.TagNumber(5)
  set action($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAction() => $_has(4);
  @$pb.TagNumber(5)
  void clearAction() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get actorId => $_getSZ(5);
  @$pb.TagNumber(6)
  set actorId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActorId() => $_has(5);
  @$pb.TagNumber(6)
  void clearActorId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get comment => $_getSZ(6);
  @$pb.TagNumber(7)
  set comment($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasComment() => $_has(6);
  @$pb.TagNumber(7)
  void clearComment() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get createdAt => $_getSZ(7);
  @$pb.TagNumber(8)
  set createdAt($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);
}

/// ClientDocumentUploadRequest stores a KYC photo, document or signature for
/// a client. The service keeps the file privately; nobody else holds a copy
/// they could swap in.
class ClientDocumentUploadRequest extends $pb.GeneratedMessage {
  factory ClientDocumentUploadRequest({
    $core.String? clientId,
    $core.String? fieldKey,
    $core.String? valueType,
    $core.String? contentType,
    $core.String? filename,
    $core.List<$core.int>? content,
    $core.String? sourceEntityId,
  }) {
    final result = ClientDocumentUploadRequest._();
    if (clientId != null) result.clientId = clientId;
    if (fieldKey != null) result.fieldKey = fieldKey;
    if (valueType != null) result.valueType = valueType;
    if (contentType != null) result.contentType = contentType;
    if (filename != null) result.filename = filename;
    if (content != null) result.content = content;
    if (sourceEntityId != null) result.sourceEntityId = sourceEntityId;
    return result;
  }

  ClientDocumentUploadRequest._();

  factory ClientDocumentUploadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDocumentUploadRequest()..mergeFromBuffer(data, registry);
  factory ClientDocumentUploadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDocumentUploadRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDocumentUploadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDocumentUploadRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldKey')
    ..aOS(3, _omitFieldNames ? '' : 'valueType')
    ..aOS(4, _omitFieldNames ? '' : 'contentType')
    ..aOS(5, _omitFieldNames ? '' : 'filename')
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aOS(7, _omitFieldNames ? '' : 'sourceEntityId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDocumentUploadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDocumentUploadRequest copyWith(
          void Function(ClientDocumentUploadRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClientDocumentUploadRequest))
          as ClientDocumentUploadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDocumentUploadRequest() / ClientDocumentUploadRequest.new instead')
  static ClientDocumentUploadRequest create() =>
      ClientDocumentUploadRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientDocumentUploadRequest._();
  @$core.override
  ClientDocumentUploadRequest createEmptyInstance() =>
      ClientDocumentUploadRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientDocumentUploadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDocumentUploadRequest>(
          ClientDocumentUploadRequest.$_createMessage);
  static ClientDocumentUploadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldKey() => $_clearField(2);

  /// "photo", "file" or "signature".
  @$pb.TagNumber(3)
  $core.String get valueType => $_getSZ(2);
  @$pb.TagNumber(3)
  set valueType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValueType() => $_has(2);
  @$pb.TagNumber(3)
  void clearValueType() => $_clearField(3);

  /// image/jpeg, image/png, image/webp or application/pdf.
  @$pb.TagNumber(4)
  $core.String get contentType => $_getSZ(3);
  @$pb.TagNumber(4)
  set contentType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContentType() => $_has(3);
  @$pb.TagNumber(4)
  void clearContentType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get filename => $_getSZ(4);
  @$pb.TagNumber(5)
  set filename($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFilename() => $_has(4);
  @$pb.TagNumber(5)
  void clearFilename() => $_clearField(5);

  /// At most 5 MiB.
  @$pb.TagNumber(6)
  $core.List<$core.int> get content => $_getN(5);
  @$pb.TagNumber(6)
  set content($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasContent() => $_has(5);
  @$pb.TagNumber(6)
  void clearContent() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get sourceEntityId => $_getSZ(6);
  @$pb.TagNumber(7)
  set sourceEntityId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSourceEntityId() => $_has(6);
  @$pb.TagNumber(7)
  void clearSourceEntityId() => $_clearField(7);
}

class ClientDocumentUploadResponse extends $pb.GeneratedMessage {
  factory ClientDocumentUploadResponse({
    ClientDataEntryObject? data,
  }) {
    final result = ClientDocumentUploadResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientDocumentUploadResponse._();

  factory ClientDocumentUploadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDocumentUploadResponse()..mergeFromBuffer(data, registry);
  factory ClientDocumentUploadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDocumentUploadResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDocumentUploadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDocumentUploadResponse.$_createMessage)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientDataEntryObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDocumentUploadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDocumentUploadResponse copyWith(
          void Function(ClientDocumentUploadResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClientDocumentUploadResponse))
          as ClientDocumentUploadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDocumentUploadResponse() / ClientDocumentUploadResponse.new instead')
  static ClientDocumentUploadResponse create() =>
      ClientDocumentUploadResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientDocumentUploadResponse._();
  @$core.override
  ClientDocumentUploadResponse createEmptyInstance() =>
      ClientDocumentUploadResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientDocumentUploadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDocumentUploadResponse>(
          ClientDocumentUploadResponse.$_createMessage);
  static ClientDocumentUploadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// ClientDocumentLinkRequest asks for a short-lived link to view a KYC
/// document entry.
class ClientDocumentLinkRequest extends $pb.GeneratedMessage {
  factory ClientDocumentLinkRequest({
    $core.String? entryId,
  }) {
    final result = ClientDocumentLinkRequest._();
    if (entryId != null) result.entryId = entryId;
    return result;
  }

  ClientDocumentLinkRequest._();

  factory ClientDocumentLinkRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDocumentLinkRequest()..mergeFromBuffer(data, registry);
  factory ClientDocumentLinkRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDocumentLinkRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDocumentLinkRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDocumentLinkRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'entryId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDocumentLinkRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDocumentLinkRequest copyWith(
          void Function(ClientDocumentLinkRequest) updates) =>
      super.copyWith((message) => updates(message as ClientDocumentLinkRequest))
          as ClientDocumentLinkRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDocumentLinkRequest() / ClientDocumentLinkRequest.new instead')
  static ClientDocumentLinkRequest create() => ClientDocumentLinkRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientDocumentLinkRequest._();
  @$core.override
  ClientDocumentLinkRequest createEmptyInstance() =>
      ClientDocumentLinkRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientDocumentLinkRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDocumentLinkRequest>(
          ClientDocumentLinkRequest.$_createMessage);
  static ClientDocumentLinkRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entryId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => $_clearField(1);
}

class ClientDocumentLinkResponse extends $pb.GeneratedMessage {
  factory ClientDocumentLinkResponse({
    $core.String? url,
    $core.String? expiresAt,
  }) {
    final result = ClientDocumentLinkResponse._();
    if (url != null) result.url = url;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  ClientDocumentLinkResponse._();

  factory ClientDocumentLinkResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDocumentLinkResponse()..mergeFromBuffer(data, registry);
  factory ClientDocumentLinkResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDocumentLinkResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDocumentLinkResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDocumentLinkResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'expiresAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDocumentLinkResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDocumentLinkResponse copyWith(
          void Function(ClientDocumentLinkResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClientDocumentLinkResponse))
          as ClientDocumentLinkResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDocumentLinkResponse() / ClientDocumentLinkResponse.new instead')
  static ClientDocumentLinkResponse create() => ClientDocumentLinkResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientDocumentLinkResponse._();
  @$core.override
  ClientDocumentLinkResponse createEmptyInstance() =>
      ClientDocumentLinkResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientDocumentLinkResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDocumentLinkResponse>(
          ClientDocumentLinkResponse.$_createMessage);
  static ClientDocumentLinkResponse? _defaultInstance;

  /// A signed link that stops working at expires_at.
  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get expiresAt => $_getSZ(1);
  @$pb.TagNumber(2)
  set expiresAt($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpiresAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiresAt() => $_clearField(2);
}

/// Save/update client data (agent submitting)
class ClientDataSaveRequest extends $pb.GeneratedMessage {
  factory ClientDataSaveRequest({
    ClientDataEntryObject? data,
  }) {
    final result = ClientDataSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  ClientDataSaveRequest._();

  factory ClientDataSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataSaveRequest()..mergeFromBuffer(data, registry);
  factory ClientDataSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataSaveRequest.$_createMessage)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientDataEntryObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataSaveRequest copyWith(
          void Function(ClientDataSaveRequest) updates) =>
      super.copyWith((message) => updates(message as ClientDataSaveRequest))
          as ClientDataSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataSaveRequest() / ClientDataSaveRequest.new instead')
  static ClientDataSaveRequest create() => ClientDataSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataSaveRequest._();
  @$core.override
  ClientDataSaveRequest createEmptyInstance() => ClientDataSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientDataSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataSaveRequest>(
          ClientDataSaveRequest.$_createMessage);
  static ClientDataSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

class ClientDataSaveResponse extends $pb.GeneratedMessage {
  factory ClientDataSaveResponse({
    ClientDataEntryObject? data,
  }) {
    final result = ClientDataSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientDataSaveResponse._();

  factory ClientDataSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataSaveResponse()..mergeFromBuffer(data, registry);
  factory ClientDataSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataSaveResponse.$_createMessage)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientDataEntryObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataSaveResponse copyWith(
          void Function(ClientDataSaveResponse) updates) =>
      super.copyWith((message) => updates(message as ClientDataSaveResponse))
          as ClientDataSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataSaveResponse() / ClientDataSaveResponse.new instead')
  static ClientDataSaveResponse create() => ClientDataSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataSaveResponse._();
  @$core.override
  ClientDataSaveResponse createEmptyInstance() => ClientDataSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientDataSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataSaveResponse>(
          ClientDataSaveResponse.$_createMessage);
  static ClientDataSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// Get a single entry by client_id + field_key
class ClientDataGetRequest extends $pb.GeneratedMessage {
  factory ClientDataGetRequest({
    $core.String? clientId,
    $core.String? fieldKey,
  }) {
    final result = ClientDataGetRequest._();
    if (clientId != null) result.clientId = clientId;
    if (fieldKey != null) result.fieldKey = fieldKey;
    return result;
  }

  ClientDataGetRequest._();

  factory ClientDataGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataGetRequest()..mergeFromBuffer(data, registry);
  factory ClientDataGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataGetRequest copyWith(void Function(ClientDataGetRequest) updates) =>
      super.copyWith((message) => updates(message as ClientDataGetRequest))
          as ClientDataGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataGetRequest() / ClientDataGetRequest.new instead')
  static ClientDataGetRequest create() => ClientDataGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataGetRequest._();
  @$core.override
  ClientDataGetRequest createEmptyInstance() => ClientDataGetRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientDataGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataGetRequest>(
          ClientDataGetRequest.$_createMessage);
  static ClientDataGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldKey() => $_clearField(2);
}

class ClientDataGetResponse extends $pb.GeneratedMessage {
  factory ClientDataGetResponse({
    ClientDataEntryObject? data,
  }) {
    final result = ClientDataGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientDataGetResponse._();

  factory ClientDataGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataGetResponse()..mergeFromBuffer(data, registry);
  factory ClientDataGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataGetResponse.$_createMessage)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientDataEntryObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataGetResponse copyWith(
          void Function(ClientDataGetResponse) updates) =>
      super.copyWith((message) => updates(message as ClientDataGetResponse))
          as ClientDataGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataGetResponse() / ClientDataGetResponse.new instead')
  static ClientDataGetResponse create() => ClientDataGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataGetResponse._();
  @$core.override
  ClientDataGetResponse createEmptyInstance() => ClientDataGetResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientDataGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataGetResponse>(
          ClientDataGetResponse.$_createMessage);
  static ClientDataGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// List all entries for a client
class ClientDataListRequest extends $pb.GeneratedMessage {
  factory ClientDataListRequest({
    $core.String? clientId,
    DataVerificationStatus? verificationStatus,
    $1.PageCursor? cursor,
  }) {
    final result = ClientDataListRequest._();
    if (clientId != null) result.clientId = clientId;
    if (verificationStatus != null)
      result.verificationStatus = verificationStatus;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  ClientDataListRequest._();

  factory ClientDataListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataListRequest()..mergeFromBuffer(data, registry);
  factory ClientDataListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataListRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataListRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aE<DataVerificationStatus>(2, _omitFieldNames ? '' : 'verificationStatus',
        enumValues: DataVerificationStatus.values)
    ..aOM<$1.PageCursor>(3, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataListRequest copyWith(
          void Function(ClientDataListRequest) updates) =>
      super.copyWith((message) => updates(message as ClientDataListRequest))
          as ClientDataListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataListRequest() / ClientDataListRequest.new instead')
  static ClientDataListRequest create() => ClientDataListRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataListRequest._();
  @$core.override
  ClientDataListRequest createEmptyInstance() => ClientDataListRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientDataListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataListRequest>(
          ClientDataListRequest.$_createMessage);
  static ClientDataListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  @$pb.TagNumber(2)
  DataVerificationStatus get verificationStatus => $_getN(1);
  @$pb.TagNumber(2)
  set verificationStatus(DataVerificationStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasVerificationStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerificationStatus() => $_clearField(2);

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

class ClientDataListResponse extends $pb.GeneratedMessage {
  factory ClientDataListResponse({
    $core.Iterable<ClientDataEntryObject>? data,
    $1.PageCursor? nextCursor,
  }) {
    final result = ClientDataListResponse._();
    if (data != null) result.data.addAll(data);
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  ClientDataListResponse._();

  factory ClientDataListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataListResponse()..mergeFromBuffer(data, registry);
  factory ClientDataListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataListResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataListResponse.$_createMessage)
    ..pPM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientDataEntryObject.$_createMessage)
    ..aOM<$1.PageCursor>(2, _omitFieldNames ? '' : 'nextCursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataListResponse copyWith(
          void Function(ClientDataListResponse) updates) =>
      super.copyWith((message) => updates(message as ClientDataListResponse))
          as ClientDataListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataListResponse() / ClientDataListResponse.new instead')
  static ClientDataListResponse create() => ClientDataListResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataListResponse._();
  @$core.override
  ClientDataListResponse createEmptyInstance() => ClientDataListResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientDataListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataListResponse>(
          ClientDataListResponse.$_createMessage);
  static ClientDataListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ClientDataEntryObject> get data => $_getList(0);

  /// Cursor for the page after this one. Empty on the last page.
  @$pb.TagNumber(2)
  $1.PageCursor get nextCursor => $_getN(1);
  @$pb.TagNumber(2)
  set nextCursor($1.PageCursor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.PageCursor ensureNextCursor() => $_ensure(1);
}

/// ClientKYCRequirementsRequest names either the client whose KYC is being
/// checked, or (before a client exists) the team a borrower is being
/// registered into. With neither, a field agent's own primary team is used.
class ClientKYCRequirementsRequest extends $pb.GeneratedMessage {
  factory ClientKYCRequirementsRequest({
    $core.String? clientId,
    $core.String? owningTeamId,
  }) {
    final result = ClientKYCRequirementsRequest._();
    if (clientId != null) result.clientId = clientId;
    if (owningTeamId != null) result.owningTeamId = owningTeamId;
    return result;
  }

  ClientKYCRequirementsRequest._();

  factory ClientKYCRequirementsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientKYCRequirementsRequest()..mergeFromBuffer(data, registry);
  factory ClientKYCRequirementsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientKYCRequirementsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientKYCRequirementsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientKYCRequirementsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'owningTeamId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientKYCRequirementsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientKYCRequirementsRequest copyWith(
          void Function(ClientKYCRequirementsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClientKYCRequirementsRequest))
          as ClientKYCRequirementsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientKYCRequirementsRequest() / ClientKYCRequirementsRequest.new instead')
  static ClientKYCRequirementsRequest create() =>
      ClientKYCRequirementsRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientKYCRequirementsRequest._();
  @$core.override
  ClientKYCRequirementsRequest createEmptyInstance() =>
      ClientKYCRequirementsRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientKYCRequirementsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientKYCRequirementsRequest>(
          ClientKYCRequirementsRequest.$_createMessage);
  static ClientKYCRequirementsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get owningTeamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set owningTeamId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOwningTeamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOwningTeamId() => $_clearField(2);
}

/// ClientKYCRequirementStatus is one required field and where the client's
/// entry for it stands. Status is UNSPECIFIED when nothing was collected.
class ClientKYCRequirementStatus extends $pb.GeneratedMessage {
  factory ClientKYCRequirementStatus({
    $core.String? fieldKey,
    $core.String? label,
    DataVerificationStatus? status,
  }) {
    final result = ClientKYCRequirementStatus._();
    if (fieldKey != null) result.fieldKey = fieldKey;
    if (label != null) result.label = label;
    if (status != null) result.status = status;
    return result;
  }

  ClientKYCRequirementStatus._();

  factory ClientKYCRequirementStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientKYCRequirementStatus()..mergeFromBuffer(data, registry);
  factory ClientKYCRequirementStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientKYCRequirementStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientKYCRequirementStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientKYCRequirementStatus.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fieldKey')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aE<DataVerificationStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: DataVerificationStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientKYCRequirementStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientKYCRequirementStatus copyWith(
          void Function(ClientKYCRequirementStatus) updates) =>
      super.copyWith(
              (message) => updates(message as ClientKYCRequirementStatus))
          as ClientKYCRequirementStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientKYCRequirementStatus() / ClientKYCRequirementStatus.new instead')
  static ClientKYCRequirementStatus create() => ClientKYCRequirementStatus._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientKYCRequirementStatus._();
  @$core.override
  ClientKYCRequirementStatus createEmptyInstance() =>
      ClientKYCRequirementStatus._();
  @$core.pragma('dart2js:noInline')
  static ClientKYCRequirementStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientKYCRequirementStatus>(
          ClientKYCRequirementStatus.$_createMessage);
  static ClientKYCRequirementStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldKey($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  DataVerificationStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(DataVerificationStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);
}

/// ClientKYCRequirementsResponse carries the organization's published client
/// form template (the onboarding form) and, for a client, the status of each
/// required field. A client is activated only when complete is true.
class ClientKYCRequirementsResponse extends $pb.GeneratedMessage {
  factory ClientKYCRequirementsResponse({
    FormTemplateObject? template,
    $core.Iterable<ClientKYCRequirementStatus>? requirements,
    $core.bool? complete,
  }) {
    final result = ClientKYCRequirementsResponse._();
    if (template != null) result.template = template;
    if (requirements != null) result.requirements.addAll(requirements);
    if (complete != null) result.complete = complete;
    return result;
  }

  ClientKYCRequirementsResponse._();

  factory ClientKYCRequirementsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientKYCRequirementsResponse()..mergeFromBuffer(data, registry);
  factory ClientKYCRequirementsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientKYCRequirementsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientKYCRequirementsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientKYCRequirementsResponse.$_createMessage)
    ..aOM<FormTemplateObject>(1, _omitFieldNames ? '' : 'template',
        subBuilder: FormTemplateObject.$_createMessage)
    ..pPM<ClientKYCRequirementStatus>(2, _omitFieldNames ? '' : 'requirements',
        subBuilder: ClientKYCRequirementStatus.$_createMessage)
    ..aOB(3, _omitFieldNames ? '' : 'complete')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientKYCRequirementsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientKYCRequirementsResponse copyWith(
          void Function(ClientKYCRequirementsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClientKYCRequirementsResponse))
          as ClientKYCRequirementsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientKYCRequirementsResponse() / ClientKYCRequirementsResponse.new instead')
  static ClientKYCRequirementsResponse create() =>
      ClientKYCRequirementsResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientKYCRequirementsResponse._();
  @$core.override
  ClientKYCRequirementsResponse createEmptyInstance() =>
      ClientKYCRequirementsResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientKYCRequirementsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientKYCRequirementsResponse>(
          ClientKYCRequirementsResponse.$_createMessage);
  static ClientKYCRequirementsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FormTemplateObject get template => $_getN(0);
  @$pb.TagNumber(1)
  set template(FormTemplateObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTemplate() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemplate() => $_clearField(1);
  @$pb.TagNumber(1)
  FormTemplateObject ensureTemplate() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<ClientKYCRequirementStatus> get requirements => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get complete => $_getBF(2);
  @$pb.TagNumber(3)
  set complete($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasComplete() => $_has(2);
  @$pb.TagNumber(3)
  void clearComplete() => $_clearField(3);
}

/// Verifier approves a data entry
class ClientDataVerifyRequest extends $pb.GeneratedMessage {
  factory ClientDataVerifyRequest({
    $core.String? entryId,
    @$core.Deprecated('This field is deprecated.') $core.String? reviewerId,
    $core.String? comment,
  }) {
    final result = ClientDataVerifyRequest._();
    if (entryId != null) result.entryId = entryId;
    if (reviewerId != null) result.reviewerId = reviewerId;
    if (comment != null) result.comment = comment;
    return result;
  }

  ClientDataVerifyRequest._();

  factory ClientDataVerifyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataVerifyRequest()..mergeFromBuffer(data, registry);
  factory ClientDataVerifyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataVerifyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataVerifyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataVerifyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'entryId')
    ..aOS(2, _omitFieldNames ? '' : 'reviewerId')
    ..aOS(3, _omitFieldNames ? '' : 'comment')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataVerifyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataVerifyRequest copyWith(
          void Function(ClientDataVerifyRequest) updates) =>
      super.copyWith((message) => updates(message as ClientDataVerifyRequest))
          as ClientDataVerifyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataVerifyRequest() / ClientDataVerifyRequest.new instead')
  static ClientDataVerifyRequest create() => ClientDataVerifyRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataVerifyRequest._();
  @$core.override
  ClientDataVerifyRequest createEmptyInstance() => ClientDataVerifyRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientDataVerifyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataVerifyRequest>(
          ClientDataVerifyRequest.$_createMessage);
  static ClientDataVerifyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entryId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => $_clearField(1);

  /// Deprecated: the reviewer is always the authenticated caller. The server
  /// ignores this field; it remains only so older clients keep compiling.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.String get reviewerId => $_getSZ(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  set reviewerId($core.String value) => $_setString(1, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.bool hasReviewerId() => $_has(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  void clearReviewerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get comment => $_getSZ(2);
  @$pb.TagNumber(3)
  set comment($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasComment() => $_has(2);
  @$pb.TagNumber(3)
  void clearComment() => $_clearField(3);
}

class ClientDataVerifyResponse extends $pb.GeneratedMessage {
  factory ClientDataVerifyResponse({
    ClientDataEntryObject? data,
  }) {
    final result = ClientDataVerifyResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientDataVerifyResponse._();

  factory ClientDataVerifyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataVerifyResponse()..mergeFromBuffer(data, registry);
  factory ClientDataVerifyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataVerifyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataVerifyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataVerifyResponse.$_createMessage)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientDataEntryObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataVerifyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataVerifyResponse copyWith(
          void Function(ClientDataVerifyResponse) updates) =>
      super.copyWith((message) => updates(message as ClientDataVerifyResponse))
          as ClientDataVerifyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataVerifyResponse() / ClientDataVerifyResponse.new instead')
  static ClientDataVerifyResponse create() => ClientDataVerifyResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataVerifyResponse._();
  @$core.override
  ClientDataVerifyResponse createEmptyInstance() =>
      ClientDataVerifyResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientDataVerifyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataVerifyResponse>(
          ClientDataVerifyResponse.$_createMessage);
  static ClientDataVerifyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// A reviewer takes a data entry for review. While it is under review only
/// that reviewer can decide it; a claim left untouched for a day can be taken
/// over by another reviewer.
class ClientDataStartReviewRequest extends $pb.GeneratedMessage {
  factory ClientDataStartReviewRequest({
    $core.String? entryId,
  }) {
    final result = ClientDataStartReviewRequest._();
    if (entryId != null) result.entryId = entryId;
    return result;
  }

  ClientDataStartReviewRequest._();

  factory ClientDataStartReviewRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataStartReviewRequest()..mergeFromBuffer(data, registry);
  factory ClientDataStartReviewRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataStartReviewRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataStartReviewRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataStartReviewRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'entryId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataStartReviewRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataStartReviewRequest copyWith(
          void Function(ClientDataStartReviewRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClientDataStartReviewRequest))
          as ClientDataStartReviewRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataStartReviewRequest() / ClientDataStartReviewRequest.new instead')
  static ClientDataStartReviewRequest create() =>
      ClientDataStartReviewRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientDataStartReviewRequest._();
  @$core.override
  ClientDataStartReviewRequest createEmptyInstance() =>
      ClientDataStartReviewRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientDataStartReviewRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataStartReviewRequest>(
          ClientDataStartReviewRequest.$_createMessage);
  static ClientDataStartReviewRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entryId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => $_clearField(1);
}

class ClientDataStartReviewResponse extends $pb.GeneratedMessage {
  factory ClientDataStartReviewResponse({
    ClientDataEntryObject? data,
  }) {
    final result = ClientDataStartReviewResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientDataStartReviewResponse._();

  factory ClientDataStartReviewResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataStartReviewResponse()..mergeFromBuffer(data, registry);
  factory ClientDataStartReviewResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataStartReviewResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataStartReviewResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataStartReviewResponse.$_createMessage)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientDataEntryObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataStartReviewResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataStartReviewResponse copyWith(
          void Function(ClientDataStartReviewResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClientDataStartReviewResponse))
          as ClientDataStartReviewResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataStartReviewResponse() / ClientDataStartReviewResponse.new instead')
  static ClientDataStartReviewResponse create() =>
      ClientDataStartReviewResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientDataStartReviewResponse._();
  @$core.override
  ClientDataStartReviewResponse createEmptyInstance() =>
      ClientDataStartReviewResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientDataStartReviewResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataStartReviewResponse>(
          ClientDataStartReviewResponse.$_createMessage);
  static ClientDataStartReviewResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// Verifier rejects a data entry
class ClientDataRejectRequest extends $pb.GeneratedMessage {
  factory ClientDataRejectRequest({
    $core.String? entryId,
    @$core.Deprecated('This field is deprecated.') $core.String? reviewerId,
    $core.String? reason,
  }) {
    final result = ClientDataRejectRequest._();
    if (entryId != null) result.entryId = entryId;
    if (reviewerId != null) result.reviewerId = reviewerId;
    if (reason != null) result.reason = reason;
    return result;
  }

  ClientDataRejectRequest._();

  factory ClientDataRejectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataRejectRequest()..mergeFromBuffer(data, registry);
  factory ClientDataRejectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataRejectRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataRejectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataRejectRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'entryId')
    ..aOS(2, _omitFieldNames ? '' : 'reviewerId')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataRejectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataRejectRequest copyWith(
          void Function(ClientDataRejectRequest) updates) =>
      super.copyWith((message) => updates(message as ClientDataRejectRequest))
          as ClientDataRejectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataRejectRequest() / ClientDataRejectRequest.new instead')
  static ClientDataRejectRequest create() => ClientDataRejectRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataRejectRequest._();
  @$core.override
  ClientDataRejectRequest createEmptyInstance() => ClientDataRejectRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientDataRejectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataRejectRequest>(
          ClientDataRejectRequest.$_createMessage);
  static ClientDataRejectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entryId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => $_clearField(1);

  /// Deprecated: the reviewer is always the authenticated caller. The server
  /// ignores this field; it remains only so older clients keep compiling.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.String get reviewerId => $_getSZ(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  set reviewerId($core.String value) => $_setString(1, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.bool hasReviewerId() => $_has(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  void clearReviewerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);
}

class ClientDataRejectResponse extends $pb.GeneratedMessage {
  factory ClientDataRejectResponse({
    ClientDataEntryObject? data,
  }) {
    final result = ClientDataRejectResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientDataRejectResponse._();

  factory ClientDataRejectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataRejectResponse()..mergeFromBuffer(data, registry);
  factory ClientDataRejectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataRejectResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataRejectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataRejectResponse.$_createMessage)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientDataEntryObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataRejectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataRejectResponse copyWith(
          void Function(ClientDataRejectResponse) updates) =>
      super.copyWith((message) => updates(message as ClientDataRejectResponse))
          as ClientDataRejectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataRejectResponse() / ClientDataRejectResponse.new instead')
  static ClientDataRejectResponse create() => ClientDataRejectResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataRejectResponse._();
  @$core.override
  ClientDataRejectResponse createEmptyInstance() =>
      ClientDataRejectResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientDataRejectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataRejectResponse>(
          ClientDataRejectResponse.$_createMessage);
  static ClientDataRejectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// Verifier requests more information
class ClientDataRequestInfoRequest extends $pb.GeneratedMessage {
  factory ClientDataRequestInfoRequest({
    $core.String? entryId,
    @$core.Deprecated('This field is deprecated.') $core.String? reviewerId,
    $core.String? comment,
  }) {
    final result = ClientDataRequestInfoRequest._();
    if (entryId != null) result.entryId = entryId;
    if (reviewerId != null) result.reviewerId = reviewerId;
    if (comment != null) result.comment = comment;
    return result;
  }

  ClientDataRequestInfoRequest._();

  factory ClientDataRequestInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataRequestInfoRequest()..mergeFromBuffer(data, registry);
  factory ClientDataRequestInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataRequestInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataRequestInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataRequestInfoRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'entryId')
    ..aOS(2, _omitFieldNames ? '' : 'reviewerId')
    ..aOS(3, _omitFieldNames ? '' : 'comment')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataRequestInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataRequestInfoRequest copyWith(
          void Function(ClientDataRequestInfoRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClientDataRequestInfoRequest))
          as ClientDataRequestInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataRequestInfoRequest() / ClientDataRequestInfoRequest.new instead')
  static ClientDataRequestInfoRequest create() =>
      ClientDataRequestInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientDataRequestInfoRequest._();
  @$core.override
  ClientDataRequestInfoRequest createEmptyInstance() =>
      ClientDataRequestInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientDataRequestInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataRequestInfoRequest>(
          ClientDataRequestInfoRequest.$_createMessage);
  static ClientDataRequestInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entryId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => $_clearField(1);

  /// Deprecated: the reviewer is always the authenticated caller. The server
  /// ignores this field; it remains only so older clients keep compiling.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.String get reviewerId => $_getSZ(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  set reviewerId($core.String value) => $_setString(1, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  $core.bool hasReviewerId() => $_has(1);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(2)
  void clearReviewerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get comment => $_getSZ(2);
  @$pb.TagNumber(3)
  set comment($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasComment() => $_has(2);
  @$pb.TagNumber(3)
  void clearComment() => $_clearField(3);
}

class ClientDataRequestInfoResponse extends $pb.GeneratedMessage {
  factory ClientDataRequestInfoResponse({
    ClientDataEntryObject? data,
  }) {
    final result = ClientDataRequestInfoResponse._();
    if (data != null) result.data = data;
    return result;
  }

  ClientDataRequestInfoResponse._();

  factory ClientDataRequestInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataRequestInfoResponse()..mergeFromBuffer(data, registry);
  factory ClientDataRequestInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataRequestInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataRequestInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataRequestInfoResponse.$_createMessage)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientDataEntryObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataRequestInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataRequestInfoResponse copyWith(
          void Function(ClientDataRequestInfoResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClientDataRequestInfoResponse))
          as ClientDataRequestInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataRequestInfoResponse() / ClientDataRequestInfoResponse.new instead')
  static ClientDataRequestInfoResponse create() =>
      ClientDataRequestInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientDataRequestInfoResponse._();
  @$core.override
  ClientDataRequestInfoResponse createEmptyInstance() =>
      ClientDataRequestInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientDataRequestInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataRequestInfoResponse>(
          ClientDataRequestInfoResponse.$_createMessage);
  static ClientDataRequestInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// Get revision history for a data entry
class ClientDataHistoryRequest extends $pb.GeneratedMessage {
  factory ClientDataHistoryRequest({
    $core.String? entryId,
  }) {
    final result = ClientDataHistoryRequest._();
    if (entryId != null) result.entryId = entryId;
    return result;
  }

  ClientDataHistoryRequest._();

  factory ClientDataHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataHistoryRequest()..mergeFromBuffer(data, registry);
  factory ClientDataHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataHistoryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataHistoryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'entryId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataHistoryRequest copyWith(
          void Function(ClientDataHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as ClientDataHistoryRequest))
          as ClientDataHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataHistoryRequest() / ClientDataHistoryRequest.new instead')
  static ClientDataHistoryRequest create() => ClientDataHistoryRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClientDataHistoryRequest._();
  @$core.override
  ClientDataHistoryRequest createEmptyInstance() =>
      ClientDataHistoryRequest._();
  @$core.pragma('dart2js:noInline')
  static ClientDataHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataHistoryRequest>(
          ClientDataHistoryRequest.$_createMessage);
  static ClientDataHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entryId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => $_clearField(1);
}

class ClientDataHistoryResponse extends $pb.GeneratedMessage {
  factory ClientDataHistoryResponse({
    $core.Iterable<ClientDataEntryHistoryObject>? data,
  }) {
    final result = ClientDataHistoryResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  ClientDataHistoryResponse._();

  factory ClientDataHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataHistoryResponse()..mergeFromBuffer(data, registry);
  factory ClientDataHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClientDataHistoryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientDataHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: ClientDataHistoryResponse.$_createMessage)
    ..pPM<ClientDataEntryHistoryObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: ClientDataEntryHistoryObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientDataHistoryResponse copyWith(
          void Function(ClientDataHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as ClientDataHistoryResponse))
          as ClientDataHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ClientDataHistoryResponse() / ClientDataHistoryResponse.new instead')
  static ClientDataHistoryResponse create() => ClientDataHistoryResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ClientDataHistoryResponse._();
  @$core.override
  ClientDataHistoryResponse createEmptyInstance() =>
      ClientDataHistoryResponse._();
  @$core.pragma('dart2js:noInline')
  static ClientDataHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientDataHistoryResponse>(
          ClientDataHistoryResponse.$_createMessage);
  static ClientDataHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ClientDataEntryHistoryObject> get data => $_getList(0);
}

class FormTemplateSaveRequest extends $pb.GeneratedMessage {
  factory FormTemplateSaveRequest({
    FormTemplateObject? data,
  }) {
    final result = FormTemplateSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  FormTemplateSaveRequest._();

  factory FormTemplateSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateSaveRequest()..mergeFromBuffer(data, registry);
  factory FormTemplateSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormTemplateSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormTemplateSaveRequest.$_createMessage)
    ..aOM<FormTemplateObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: FormTemplateObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateSaveRequest copyWith(
          void Function(FormTemplateSaveRequest) updates) =>
      super.copyWith((message) => updates(message as FormTemplateSaveRequest))
          as FormTemplateSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormTemplateSaveRequest() / FormTemplateSaveRequest.new instead')
  static FormTemplateSaveRequest create() => FormTemplateSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() => FormTemplateSaveRequest._();
  @$core.override
  FormTemplateSaveRequest createEmptyInstance() => FormTemplateSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static FormTemplateSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormTemplateSaveRequest>(
          FormTemplateSaveRequest.$_createMessage);
  static FormTemplateSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  FormTemplateObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormTemplateObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  FormTemplateObject ensureData() => $_ensure(0);
}

class FormTemplateSaveResponse extends $pb.GeneratedMessage {
  factory FormTemplateSaveResponse({
    FormTemplateObject? data,
  }) {
    final result = FormTemplateSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  FormTemplateSaveResponse._();

  factory FormTemplateSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateSaveResponse()..mergeFromBuffer(data, registry);
  factory FormTemplateSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormTemplateSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormTemplateSaveResponse.$_createMessage)
    ..aOM<FormTemplateObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: FormTemplateObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateSaveResponse copyWith(
          void Function(FormTemplateSaveResponse) updates) =>
      super.copyWith((message) => updates(message as FormTemplateSaveResponse))
          as FormTemplateSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormTemplateSaveResponse() / FormTemplateSaveResponse.new instead')
  static FormTemplateSaveResponse create() => FormTemplateSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() => FormTemplateSaveResponse._();
  @$core.override
  FormTemplateSaveResponse createEmptyInstance() =>
      FormTemplateSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static FormTemplateSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormTemplateSaveResponse>(
          FormTemplateSaveResponse.$_createMessage);
  static FormTemplateSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FormTemplateObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormTemplateObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  FormTemplateObject ensureData() => $_ensure(0);
}

class FormTemplateGetRequest extends $pb.GeneratedMessage {
  factory FormTemplateGetRequest({
    $core.String? id,
  }) {
    final result = FormTemplateGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  FormTemplateGetRequest._();

  factory FormTemplateGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateGetRequest()..mergeFromBuffer(data, registry);
  factory FormTemplateGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormTemplateGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormTemplateGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateGetRequest copyWith(
          void Function(FormTemplateGetRequest) updates) =>
      super.copyWith((message) => updates(message as FormTemplateGetRequest))
          as FormTemplateGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormTemplateGetRequest() / FormTemplateGetRequest.new instead')
  static FormTemplateGetRequest create() => FormTemplateGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => FormTemplateGetRequest._();
  @$core.override
  FormTemplateGetRequest createEmptyInstance() => FormTemplateGetRequest._();
  @$core.pragma('dart2js:noInline')
  static FormTemplateGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormTemplateGetRequest>(
          FormTemplateGetRequest.$_createMessage);
  static FormTemplateGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class FormTemplateGetResponse extends $pb.GeneratedMessage {
  factory FormTemplateGetResponse({
    FormTemplateObject? data,
  }) {
    final result = FormTemplateGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  FormTemplateGetResponse._();

  factory FormTemplateGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateGetResponse()..mergeFromBuffer(data, registry);
  factory FormTemplateGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormTemplateGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormTemplateGetResponse.$_createMessage)
    ..aOM<FormTemplateObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: FormTemplateObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateGetResponse copyWith(
          void Function(FormTemplateGetResponse) updates) =>
      super.copyWith((message) => updates(message as FormTemplateGetResponse))
          as FormTemplateGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormTemplateGetResponse() / FormTemplateGetResponse.new instead')
  static FormTemplateGetResponse create() => FormTemplateGetResponse._();
  static $pb.GeneratedMessage $_createMessage() => FormTemplateGetResponse._();
  @$core.override
  FormTemplateGetResponse createEmptyInstance() => FormTemplateGetResponse._();
  @$core.pragma('dart2js:noInline')
  static FormTemplateGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormTemplateGetResponse>(
          FormTemplateGetResponse.$_createMessage);
  static FormTemplateGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FormTemplateObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormTemplateObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  FormTemplateObject ensureData() => $_ensure(0);
}

class FormTemplateSearchRequest extends $pb.GeneratedMessage {
  factory FormTemplateSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    FormTemplateStatus? status,
    $1.PageCursor? cursor,
    $core.String? entityType,
  }) {
    final result = FormTemplateSearchRequest._();
    if (query != null) result.query = query;
    if (organizationId != null) result.organizationId = organizationId;
    if (status != null) result.status = status;
    if (cursor != null) result.cursor = cursor;
    if (entityType != null) result.entityType = entityType;
    return result;
  }

  FormTemplateSearchRequest._();

  factory FormTemplateSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateSearchRequest()..mergeFromBuffer(data, registry);
  factory FormTemplateSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormTemplateSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormTemplateSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aE<FormTemplateStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: FormTemplateStatus.values)
    ..aOM<$1.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..aOS(5, _omitFieldNames ? '' : 'entityType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateSearchRequest copyWith(
          void Function(FormTemplateSearchRequest) updates) =>
      super.copyWith((message) => updates(message as FormTemplateSearchRequest))
          as FormTemplateSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormTemplateSearchRequest() / FormTemplateSearchRequest.new instead')
  static FormTemplateSearchRequest create() => FormTemplateSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      FormTemplateSearchRequest._();
  @$core.override
  FormTemplateSearchRequest createEmptyInstance() =>
      FormTemplateSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static FormTemplateSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormTemplateSearchRequest>(
          FormTemplateSearchRequest.$_createMessage);
  static FormTemplateSearchRequest? _defaultInstance;

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
  FormTemplateStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(FormTemplateStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

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

  /// Filter templates by entity type (e.g. "client", "group", "loan_request").
  @$pb.TagNumber(5)
  $core.String get entityType => $_getSZ(4);
  @$pb.TagNumber(5)
  set entityType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEntityType() => $_has(4);
  @$pb.TagNumber(5)
  void clearEntityType() => $_clearField(5);
}

class FormTemplateSearchResponse extends $pb.GeneratedMessage {
  factory FormTemplateSearchResponse({
    $core.Iterable<FormTemplateObject>? data,
  }) {
    final result = FormTemplateSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  FormTemplateSearchResponse._();

  factory FormTemplateSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateSearchResponse()..mergeFromBuffer(data, registry);
  factory FormTemplateSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplateSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormTemplateSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormTemplateSearchResponse.$_createMessage)
    ..pPM<FormTemplateObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: FormTemplateObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplateSearchResponse copyWith(
          void Function(FormTemplateSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as FormTemplateSearchResponse))
          as FormTemplateSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormTemplateSearchResponse() / FormTemplateSearchResponse.new instead')
  static FormTemplateSearchResponse create() => FormTemplateSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      FormTemplateSearchResponse._();
  @$core.override
  FormTemplateSearchResponse createEmptyInstance() =>
      FormTemplateSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static FormTemplateSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormTemplateSearchResponse>(
          FormTemplateSearchResponse.$_createMessage);
  static FormTemplateSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FormTemplateObject> get data => $_getList(0);
}

class FormTemplatePublishRequest extends $pb.GeneratedMessage {
  factory FormTemplatePublishRequest({
    $core.String? id,
  }) {
    final result = FormTemplatePublishRequest._();
    if (id != null) result.id = id;
    return result;
  }

  FormTemplatePublishRequest._();

  factory FormTemplatePublishRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplatePublishRequest()..mergeFromBuffer(data, registry);
  factory FormTemplatePublishRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplatePublishRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormTemplatePublishRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormTemplatePublishRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplatePublishRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplatePublishRequest copyWith(
          void Function(FormTemplatePublishRequest) updates) =>
      super.copyWith(
              (message) => updates(message as FormTemplatePublishRequest))
          as FormTemplatePublishRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormTemplatePublishRequest() / FormTemplatePublishRequest.new instead')
  static FormTemplatePublishRequest create() => FormTemplatePublishRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      FormTemplatePublishRequest._();
  @$core.override
  FormTemplatePublishRequest createEmptyInstance() =>
      FormTemplatePublishRequest._();
  @$core.pragma('dart2js:noInline')
  static FormTemplatePublishRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormTemplatePublishRequest>(
          FormTemplatePublishRequest.$_createMessage);
  static FormTemplatePublishRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class FormTemplatePublishResponse extends $pb.GeneratedMessage {
  factory FormTemplatePublishResponse({
    FormTemplateObject? data,
  }) {
    final result = FormTemplatePublishResponse._();
    if (data != null) result.data = data;
    return result;
  }

  FormTemplatePublishResponse._();

  factory FormTemplatePublishResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplatePublishResponse()..mergeFromBuffer(data, registry);
  factory FormTemplatePublishResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormTemplatePublishResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormTemplatePublishResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormTemplatePublishResponse.$_createMessage)
    ..aOM<FormTemplateObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: FormTemplateObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplatePublishResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormTemplatePublishResponse copyWith(
          void Function(FormTemplatePublishResponse) updates) =>
      super.copyWith(
              (message) => updates(message as FormTemplatePublishResponse))
          as FormTemplatePublishResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormTemplatePublishResponse() / FormTemplatePublishResponse.new instead')
  static FormTemplatePublishResponse create() =>
      FormTemplatePublishResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      FormTemplatePublishResponse._();
  @$core.override
  FormTemplatePublishResponse createEmptyInstance() =>
      FormTemplatePublishResponse._();
  @$core.pragma('dart2js:noInline')
  static FormTemplatePublishResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormTemplatePublishResponse>(
          FormTemplatePublishResponse.$_createMessage);
  static FormTemplatePublishResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FormTemplateObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormTemplateObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  FormTemplateObject ensureData() => $_ensure(0);
}

class FormSubmissionSaveRequest extends $pb.GeneratedMessage {
  factory FormSubmissionSaveRequest({
    FormSubmissionObject? data,
  }) {
    final result = FormSubmissionSaveRequest._();
    if (data != null) result.data = data;
    return result;
  }

  FormSubmissionSaveRequest._();

  factory FormSubmissionSaveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionSaveRequest()..mergeFromBuffer(data, registry);
  factory FormSubmissionSaveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionSaveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormSubmissionSaveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormSubmissionSaveRequest.$_createMessage)
    ..aOM<FormSubmissionObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: FormSubmissionObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionSaveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionSaveRequest copyWith(
          void Function(FormSubmissionSaveRequest) updates) =>
      super.copyWith((message) => updates(message as FormSubmissionSaveRequest))
          as FormSubmissionSaveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormSubmissionSaveRequest() / FormSubmissionSaveRequest.new instead')
  static FormSubmissionSaveRequest create() => FormSubmissionSaveRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      FormSubmissionSaveRequest._();
  @$core.override
  FormSubmissionSaveRequest createEmptyInstance() =>
      FormSubmissionSaveRequest._();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionSaveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormSubmissionSaveRequest>(
          FormSubmissionSaveRequest.$_createMessage);
  static FormSubmissionSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  FormSubmissionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormSubmissionObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  FormSubmissionObject ensureData() => $_ensure(0);
}

class FormSubmissionSaveResponse extends $pb.GeneratedMessage {
  factory FormSubmissionSaveResponse({
    FormSubmissionObject? data,
  }) {
    final result = FormSubmissionSaveResponse._();
    if (data != null) result.data = data;
    return result;
  }

  FormSubmissionSaveResponse._();

  factory FormSubmissionSaveResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionSaveResponse()..mergeFromBuffer(data, registry);
  factory FormSubmissionSaveResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionSaveResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormSubmissionSaveResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormSubmissionSaveResponse.$_createMessage)
    ..aOM<FormSubmissionObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: FormSubmissionObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionSaveResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionSaveResponse copyWith(
          void Function(FormSubmissionSaveResponse) updates) =>
      super.copyWith(
              (message) => updates(message as FormSubmissionSaveResponse))
          as FormSubmissionSaveResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormSubmissionSaveResponse() / FormSubmissionSaveResponse.new instead')
  static FormSubmissionSaveResponse create() => FormSubmissionSaveResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      FormSubmissionSaveResponse._();
  @$core.override
  FormSubmissionSaveResponse createEmptyInstance() =>
      FormSubmissionSaveResponse._();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionSaveResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormSubmissionSaveResponse>(
          FormSubmissionSaveResponse.$_createMessage);
  static FormSubmissionSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FormSubmissionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormSubmissionObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  FormSubmissionObject ensureData() => $_ensure(0);
}

class FormSubmissionGetRequest extends $pb.GeneratedMessage {
  factory FormSubmissionGetRequest({
    $core.String? id,
  }) {
    final result = FormSubmissionGetRequest._();
    if (id != null) result.id = id;
    return result;
  }

  FormSubmissionGetRequest._();

  factory FormSubmissionGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionGetRequest()..mergeFromBuffer(data, registry);
  factory FormSubmissionGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormSubmissionGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormSubmissionGetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionGetRequest copyWith(
          void Function(FormSubmissionGetRequest) updates) =>
      super.copyWith((message) => updates(message as FormSubmissionGetRequest))
          as FormSubmissionGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormSubmissionGetRequest() / FormSubmissionGetRequest.new instead')
  static FormSubmissionGetRequest create() => FormSubmissionGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => FormSubmissionGetRequest._();
  @$core.override
  FormSubmissionGetRequest createEmptyInstance() =>
      FormSubmissionGetRequest._();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormSubmissionGetRequest>(
          FormSubmissionGetRequest.$_createMessage);
  static FormSubmissionGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class FormSubmissionGetResponse extends $pb.GeneratedMessage {
  factory FormSubmissionGetResponse({
    FormSubmissionObject? data,
  }) {
    final result = FormSubmissionGetResponse._();
    if (data != null) result.data = data;
    return result;
  }

  FormSubmissionGetResponse._();

  factory FormSubmissionGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionGetResponse()..mergeFromBuffer(data, registry);
  factory FormSubmissionGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionGetResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormSubmissionGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormSubmissionGetResponse.$_createMessage)
    ..aOM<FormSubmissionObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: FormSubmissionObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionGetResponse copyWith(
          void Function(FormSubmissionGetResponse) updates) =>
      super.copyWith((message) => updates(message as FormSubmissionGetResponse))
          as FormSubmissionGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormSubmissionGetResponse() / FormSubmissionGetResponse.new instead')
  static FormSubmissionGetResponse create() => FormSubmissionGetResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      FormSubmissionGetResponse._();
  @$core.override
  FormSubmissionGetResponse createEmptyInstance() =>
      FormSubmissionGetResponse._();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormSubmissionGetResponse>(
          FormSubmissionGetResponse.$_createMessage);
  static FormSubmissionGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FormSubmissionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormSubmissionObject value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  FormSubmissionObject ensureData() => $_ensure(0);
}

class FormSubmissionSearchRequest extends $pb.GeneratedMessage {
  factory FormSubmissionSearchRequest({
    $core.String? entityId,
    $core.String? entityType,
    $core.String? templateId,
    $1.PageCursor? cursor,
  }) {
    final result = FormSubmissionSearchRequest._();
    if (entityId != null) result.entityId = entityId;
    if (entityType != null) result.entityType = entityType;
    if (templateId != null) result.templateId = templateId;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  FormSubmissionSearchRequest._();

  factory FormSubmissionSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionSearchRequest()..mergeFromBuffer(data, registry);
  factory FormSubmissionSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionSearchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormSubmissionSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormSubmissionSearchRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'entityId')
    ..aOS(2, _omitFieldNames ? '' : 'entityType')
    ..aOS(3, _omitFieldNames ? '' : 'templateId')
    ..aOM<$1.PageCursor>(4, _omitFieldNames ? '' : 'cursor',
        subBuilder: $1.PageCursor.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionSearchRequest copyWith(
          void Function(FormSubmissionSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as FormSubmissionSearchRequest))
          as FormSubmissionSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormSubmissionSearchRequest() / FormSubmissionSearchRequest.new instead')
  static FormSubmissionSearchRequest create() =>
      FormSubmissionSearchRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      FormSubmissionSearchRequest._();
  @$core.override
  FormSubmissionSearchRequest createEmptyInstance() =>
      FormSubmissionSearchRequest._();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormSubmissionSearchRequest>(
          FormSubmissionSearchRequest.$_createMessage);
  static FormSubmissionSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get entityType => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntityType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get templateId => $_getSZ(2);
  @$pb.TagNumber(3)
  set templateId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTemplateId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTemplateId() => $_clearField(3);

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
}

class FormSubmissionSearchResponse extends $pb.GeneratedMessage {
  factory FormSubmissionSearchResponse({
    $core.Iterable<FormSubmissionObject>? data,
  }) {
    final result = FormSubmissionSearchResponse._();
    if (data != null) result.data.addAll(data);
    return result;
  }

  FormSubmissionSearchResponse._();

  factory FormSubmissionSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionSearchResponse()..mergeFromBuffer(data, registry);
  factory FormSubmissionSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FormSubmissionSearchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FormSubmissionSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'),
      createEmptyInstance: FormSubmissionSearchResponse.$_createMessage)
    ..pPM<FormSubmissionObject>(1, _omitFieldNames ? '' : 'data',
        subBuilder: FormSubmissionObject.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FormSubmissionSearchResponse copyWith(
          void Function(FormSubmissionSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as FormSubmissionSearchResponse))
          as FormSubmissionSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use FormSubmissionSearchResponse() / FormSubmissionSearchResponse.new instead')
  static FormSubmissionSearchResponse create() =>
      FormSubmissionSearchResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      FormSubmissionSearchResponse._();
  @$core.override
  FormSubmissionSearchResponse createEmptyInstance() =>
      FormSubmissionSearchResponse._();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FormSubmissionSearchResponse>(
          FormSubmissionSearchResponse.$_createMessage);
  static FormSubmissionSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FormSubmissionObject> get data => $_getList(0);
}

/// IdentityService manages organizations, org units, workforce members, form templates,
/// and data collection for the platform.
/// Canonical workforce, hierarchy, team, and access-control concepts live here.
/// All RPCs require authentication via Bearer token.
/// IdentityService still binds investor_account_* to its roles although the
/// investor account RPCs are served by funding: tenancy refuses to drop a
/// role binding through registration, so removing them needs a deliberate
/// tenancy-side change rather than a manifest edit.
class IdentityServiceApi {
  final $pb.RpcClient _client;

  IdentityServiceApi(this._client);

  /// OrganizationSave creates or updates an organization record.
  $async.Future<OrganizationSaveResponse> organizationSave(
          $pb.ClientContext? ctx, OrganizationSaveRequest request) =>
      _client.invoke<OrganizationSaveResponse>(ctx, 'IdentityService',
          'OrganizationSave', request, OrganizationSaveResponse());

  /// OrganizationGet retrieves an organization by its ID.
  $async.Future<OrganizationGetResponse> organizationGet(
          $pb.ClientContext? ctx, OrganizationGetRequest request) =>
      _client.invoke<OrganizationGetResponse>(ctx, 'IdentityService',
          'OrganizationGet', request, OrganizationGetResponse());

  /// OrganizationSearch finds organizations matching search criteria.
  $async.Future<OrganizationSearchResponse> organizationSearch(
          $pb.ClientContext? ctx, $1.SearchRequest request) =>
      _client.invoke<OrganizationSearchResponse>(ctx, 'IdentityService',
          'OrganizationSearch', request, OrganizationSearchResponse());

  /// OrgUnitSave creates or updates a hierarchical org unit record.
  $async.Future<OrgUnitSaveResponse> orgUnitSave(
          $pb.ClientContext? ctx, OrgUnitSaveRequest request) =>
      _client.invoke<OrgUnitSaveResponse>(ctx, 'IdentityService', 'OrgUnitSave',
          request, OrgUnitSaveResponse());

  /// OrgUnitGet retrieves an org unit by its ID.
  $async.Future<OrgUnitGetResponse> orgUnitGet(
          $pb.ClientContext? ctx, OrgUnitGetRequest request) =>
      _client.invoke<OrgUnitGetResponse>(
          ctx, 'IdentityService', 'OrgUnitGet', request, OrgUnitGetResponse());

  /// OrgUnitSearch finds org units matching search criteria.
  $async.Future<OrgUnitSearchResponse> orgUnitSearch(
          $pb.ClientContext? ctx, OrgUnitSearchRequest request) =>
      _client.invoke<OrgUnitSearchResponse>(ctx, 'IdentityService',
          'OrgUnitSearch', request, OrgUnitSearchResponse());
  $async.Future<WorkforceMemberSaveResponse> workforceMemberSave(
          $pb.ClientContext? ctx, WorkforceMemberSaveRequest request) =>
      _client.invoke<WorkforceMemberSaveResponse>(ctx, 'IdentityService',
          'WorkforceMemberSave', request, WorkforceMemberSaveResponse());
  $async.Future<WorkforceMemberGetResponse> workforceMemberGet(
          $pb.ClientContext? ctx, WorkforceMemberGetRequest request) =>
      _client.invoke<WorkforceMemberGetResponse>(ctx, 'IdentityService',
          'WorkforceMemberGet', request, WorkforceMemberGetResponse());
  $async.Future<WorkforceMemberSearchResponse> workforceMemberSearch(
          $pb.ClientContext? ctx, WorkforceMemberSearchRequest request) =>
      _client.invoke<WorkforceMemberSearchResponse>(ctx, 'IdentityService',
          'WorkforceMemberSearch', request, WorkforceMemberSearchResponse());
  $async.Future<DepartmentSaveResponse> departmentSave(
          $pb.ClientContext? ctx, DepartmentSaveRequest request) =>
      _client.invoke<DepartmentSaveResponse>(ctx, 'IdentityService',
          'DepartmentSave', request, DepartmentSaveResponse());
  $async.Future<DepartmentGetResponse> departmentGet(
          $pb.ClientContext? ctx, DepartmentGetRequest request) =>
      _client.invoke<DepartmentGetResponse>(ctx, 'IdentityService',
          'DepartmentGet', request, DepartmentGetResponse());
  $async.Future<DepartmentSearchResponse> departmentSearch(
          $pb.ClientContext? ctx, DepartmentSearchRequest request) =>
      _client.invoke<DepartmentSearchResponse>(ctx, 'IdentityService',
          'DepartmentSearch', request, DepartmentSearchResponse());
  $async.Future<PositionSaveResponse> positionSave(
          $pb.ClientContext? ctx, PositionSaveRequest request) =>
      _client.invoke<PositionSaveResponse>(ctx, 'IdentityService',
          'PositionSave', request, PositionSaveResponse());
  $async.Future<PositionGetResponse> positionGet(
          $pb.ClientContext? ctx, PositionGetRequest request) =>
      _client.invoke<PositionGetResponse>(ctx, 'IdentityService', 'PositionGet',
          request, PositionGetResponse());
  $async.Future<PositionSearchResponse> positionSearch(
          $pb.ClientContext? ctx, PositionSearchRequest request) =>
      _client.invoke<PositionSearchResponse>(ctx, 'IdentityService',
          'PositionSearch', request, PositionSearchResponse());
  $async.Future<PositionAssignmentSaveResponse> positionAssignmentSave(
          $pb.ClientContext? ctx, PositionAssignmentSaveRequest request) =>
      _client.invoke<PositionAssignmentSaveResponse>(ctx, 'IdentityService',
          'PositionAssignmentSave', request, PositionAssignmentSaveResponse());
  $async.Future<PositionAssignmentGetResponse> positionAssignmentGet(
          $pb.ClientContext? ctx, PositionAssignmentGetRequest request) =>
      _client.invoke<PositionAssignmentGetResponse>(ctx, 'IdentityService',
          'PositionAssignmentGet', request, PositionAssignmentGetResponse());
  $async.Future<PositionAssignmentSearchResponse> positionAssignmentSearch(
          $pb.ClientContext? ctx, PositionAssignmentSearchRequest request) =>
      _client.invoke<PositionAssignmentSearchResponse>(
          ctx,
          'IdentityService',
          'PositionAssignmentSearch',
          request,
          PositionAssignmentSearchResponse());
  $async.Future<InternalTeamSaveResponse> internalTeamSave(
          $pb.ClientContext? ctx, InternalTeamSaveRequest request) =>
      _client.invoke<InternalTeamSaveResponse>(ctx, 'IdentityService',
          'InternalTeamSave', request, InternalTeamSaveResponse());
  $async.Future<InternalTeamGetResponse> internalTeamGet(
          $pb.ClientContext? ctx, InternalTeamGetRequest request) =>
      _client.invoke<InternalTeamGetResponse>(ctx, 'IdentityService',
          'InternalTeamGet', request, InternalTeamGetResponse());
  $async.Future<InternalTeamSearchResponse> internalTeamSearch(
          $pb.ClientContext? ctx, InternalTeamSearchRequest request) =>
      _client.invoke<InternalTeamSearchResponse>(ctx, 'IdentityService',
          'InternalTeamSearch', request, InternalTeamSearchResponse());
  $async.Future<TeamMembershipSaveResponse> teamMembershipSave(
          $pb.ClientContext? ctx, TeamMembershipSaveRequest request) =>
      _client.invoke<TeamMembershipSaveResponse>(ctx, 'IdentityService',
          'TeamMembershipSave', request, TeamMembershipSaveResponse());
  $async.Future<TeamMembershipGetResponse> teamMembershipGet(
          $pb.ClientContext? ctx, TeamMembershipGetRequest request) =>
      _client.invoke<TeamMembershipGetResponse>(ctx, 'IdentityService',
          'TeamMembershipGet', request, TeamMembershipGetResponse());
  $async.Future<TeamMembershipSearchResponse> teamMembershipSearch(
          $pb.ClientContext? ctx, TeamMembershipSearchRequest request) =>
      _client.invoke<TeamMembershipSearchResponse>(ctx, 'IdentityService',
          'TeamMembershipSearch', request, TeamMembershipSearchResponse());
  $async.Future<AccessRoleAssignmentSaveResponse> accessRoleAssignmentSave(
          $pb.ClientContext? ctx, AccessRoleAssignmentSaveRequest request) =>
      _client.invoke<AccessRoleAssignmentSaveResponse>(
          ctx,
          'IdentityService',
          'AccessRoleAssignmentSave',
          request,
          AccessRoleAssignmentSaveResponse());
  $async.Future<AccessRoleAssignmentGetResponse> accessRoleAssignmentGet(
          $pb.ClientContext? ctx, AccessRoleAssignmentGetRequest request) =>
      _client.invoke<AccessRoleAssignmentGetResponse>(
          ctx,
          'IdentityService',
          'AccessRoleAssignmentGet',
          request,
          AccessRoleAssignmentGetResponse());
  $async.Future<AccessRoleAssignmentSearchResponse> accessRoleAssignmentSearch(
          $pb.ClientContext? ctx, AccessRoleAssignmentSearchRequest request) =>
      _client.invoke<AccessRoleAssignmentSearchResponse>(
          ctx,
          'IdentityService',
          'AccessRoleAssignmentSearch',
          request,
          AccessRoleAssignmentSearchResponse());

  /// InvestorSave creates or updates an investor record.
  $async.Future<InvestorSaveResponse> investorSave(
          $pb.ClientContext? ctx, InvestorSaveRequest request) =>
      _client.invoke<InvestorSaveResponse>(ctx, 'IdentityService',
          'InvestorSave', request, InvestorSaveResponse());

  /// InvestorGet retrieves an investor by their ID.
  $async.Future<InvestorGetResponse> investorGet(
          $pb.ClientContext? ctx, InvestorGetRequest request) =>
      _client.invoke<InvestorGetResponse>(ctx, 'IdentityService', 'InvestorGet',
          request, InvestorGetResponse());

  /// InvestorSearch finds investors matching search criteria.
  $async.Future<InvestorSearchResponse> investorSearch(
          $pb.ClientContext? ctx, InvestorSearchRequest request) =>
      _client.invoke<InvestorSearchResponse>(ctx, 'IdentityService',
          'InvestorSearch', request, InvestorSearchResponse());

  /// ClientGroupSave creates or updates a client group record.
  $async.Future<ClientGroupSaveResponse> clientGroupSave(
          $pb.ClientContext? ctx, ClientGroupSaveRequest request) =>
      _client.invoke<ClientGroupSaveResponse>(ctx, 'IdentityService',
          'ClientGroupSave', request, ClientGroupSaveResponse());

  /// ClientGroupGet retrieves a client group by its ID.
  $async.Future<ClientGroupGetResponse> clientGroupGet(
          $pb.ClientContext? ctx, ClientGroupGetRequest request) =>
      _client.invoke<ClientGroupGetResponse>(ctx, 'IdentityService',
          'ClientGroupGet', request, ClientGroupGetResponse());

  /// ClientGroupSearch finds client groups matching search criteria.
  $async.Future<ClientGroupSearchResponse> clientGroupSearch(
          $pb.ClientContext? ctx, ClientGroupSearchRequest request) =>
      _client.invoke<ClientGroupSearchResponse>(ctx, 'IdentityService',
          'ClientGroupSearch', request, ClientGroupSearchResponse());

  /// MembershipSave creates or updates a membership record.
  $async.Future<MembershipSaveResponse> membershipSave(
          $pb.ClientContext? ctx, MembershipSaveRequest request) =>
      _client.invoke<MembershipSaveResponse>(ctx, 'IdentityService',
          'MembershipSave', request, MembershipSaveResponse());

  /// MembershipGet retrieves a membership by its ID.
  $async.Future<MembershipGetResponse> membershipGet(
          $pb.ClientContext? ctx, MembershipGetRequest request) =>
      _client.invoke<MembershipGetResponse>(ctx, 'IdentityService',
          'MembershipGet', request, MembershipGetResponse());

  /// MembershipSearch finds memberships matching search criteria.
  $async.Future<MembershipSearchResponse> membershipSearch(
          $pb.ClientContext? ctx, MembershipSearchRequest request) =>
      _client.invoke<MembershipSearchResponse>(ctx, 'IdentityService',
          'MembershipSearch', request, MembershipSearchResponse());

  /// InvestorAccountSave creates or updates an investor capital account.
  /// Deprecated: use funding.v1.FundingService instead.
  @$core.Deprecated('This method is deprecated')
  $async.Future<InvestorAccountSaveResponse> investorAccountSave(
          $pb.ClientContext? ctx, InvestorAccountSaveRequest request) =>
      _client.invoke<InvestorAccountSaveResponse>(ctx, 'IdentityService',
          'InvestorAccountSave', request, InvestorAccountSaveResponse());

  /// InvestorAccountGet retrieves an investor account by its ID.
  /// Deprecated: use funding.v1.FundingService instead.
  @$core.Deprecated('This method is deprecated')
  $async.Future<InvestorAccountGetResponse> investorAccountGet(
          $pb.ClientContext? ctx, InvestorAccountGetRequest request) =>
      _client.invoke<InvestorAccountGetResponse>(ctx, 'IdentityService',
          'InvestorAccountGet', request, InvestorAccountGetResponse());

  /// InvestorAccountSearch finds investor accounts matching search criteria.
  /// Deprecated: use funding.v1.FundingService instead.
  @$core.Deprecated('This method is deprecated')
  $async.Future<InvestorAccountSearchResponse> investorAccountSearch(
          $pb.ClientContext? ctx, InvestorAccountSearchRequest request) =>
      _client.invoke<InvestorAccountSearchResponse>(ctx, 'IdentityService',
          'InvestorAccountSearch', request, InvestorAccountSearchResponse());

  /// InvestorDeposit adds funds to an investor capital account.
  /// Deprecated: use funding.v1.FundingService instead.
  @$core.Deprecated('This method is deprecated')
  $async.Future<InvestorDepositResponse> investorDeposit(
          $pb.ClientContext? ctx, InvestorDepositRequest request) =>
      _client.invoke<InvestorDepositResponse>(ctx, 'IdentityService',
          'InvestorDeposit', request, InvestorDepositResponse());

  /// InvestorWithdraw removes funds from an investor capital account.
  /// Deprecated: use funding.v1.FundingService instead.
  @$core.Deprecated('This method is deprecated')
  $async.Future<InvestorWithdrawResponse> investorWithdraw(
          $pb.ClientContext? ctx, InvestorWithdrawRequest request) =>
      _client.invoke<InvestorWithdrawResponse>(ctx, 'IdentityService',
          'InvestorWithdraw', request, InvestorWithdrawResponse());

  /// ClientDataSave creates or updates a client data entry.
  $async.Future<ClientDataSaveResponse> clientDataSave(
          $pb.ClientContext? ctx, ClientDataSaveRequest request) =>
      _client.invoke<ClientDataSaveResponse>(ctx, 'IdentityService',
          'ClientDataSave', request, ClientDataSaveResponse());

  /// ClientDocumentUpload stores a KYC photo, document or signature and
  /// records it as the client's entry for the field, as ClientDataSave does
  /// for typed values.
  $async.Future<ClientDocumentUploadResponse> clientDocumentUpload(
          $pb.ClientContext? ctx, ClientDocumentUploadRequest request) =>
      _client.invoke<ClientDocumentUploadResponse>(ctx, 'IdentityService',
          'ClientDocumentUpload', request, ClientDocumentUploadResponse());

  /// ClientDocumentLink gives a short-lived link to view a KYC document to a
  /// caller who may see the client.
  $async.Future<ClientDocumentLinkResponse> clientDocumentLink(
          $pb.ClientContext? ctx, ClientDocumentLinkRequest request) =>
      _client.invoke<ClientDocumentLinkResponse>(ctx, 'IdentityService',
          'ClientDocumentLink', request, ClientDocumentLinkResponse());

  /// ClientDataGet retrieves a single data entry by client_id and field_key.
  $async.Future<ClientDataGetResponse> clientDataGet(
          $pb.ClientContext? ctx, ClientDataGetRequest request) =>
      _client.invoke<ClientDataGetResponse>(ctx, 'IdentityService',
          'ClientDataGet', request, ClientDataGetResponse());

  /// ClientDataList lists all data entries for a client with optional status filter.
  $async.Future<ClientDataListResponse> clientDataList(
          $pb.ClientContext? ctx, ClientDataListRequest request) =>
      _client.invoke<ClientDataListResponse>(ctx, 'IdentityService',
          'ClientDataList', request, ClientDataListResponse());

  /// ClientKYCRequirements returns what an organization requires of a
  /// client: its published client form template, whose required fields must
  /// be VERIFIED before the client is activated. Each organization sets its
  /// own; a child organization without one uses its parent's.
  $async.Future<ClientKYCRequirementsResponse> clientKYCRequirements(
          $pb.ClientContext? ctx, ClientKYCRequirementsRequest request) =>
      _client.invoke<ClientKYCRequirementsResponse>(ctx, 'IdentityService',
          'ClientKYCRequirements', request, ClientKYCRequirementsResponse());

  /// ClientDataStartReview takes a data entry for review.
  $async.Future<ClientDataStartReviewResponse> clientDataStartReview(
          $pb.ClientContext? ctx, ClientDataStartReviewRequest request) =>
      _client.invoke<ClientDataStartReviewResponse>(ctx, 'IdentityService',
          'ClientDataStartReview', request, ClientDataStartReviewResponse());

  /// ClientDataVerify marks a data entry as verified.
  $async.Future<ClientDataVerifyResponse> clientDataVerify(
          $pb.ClientContext? ctx, ClientDataVerifyRequest request) =>
      _client.invoke<ClientDataVerifyResponse>(ctx, 'IdentityService',
          'ClientDataVerify', request, ClientDataVerifyResponse());

  /// ClientDataReject marks a data entry as rejected.
  $async.Future<ClientDataRejectResponse> clientDataReject(
          $pb.ClientContext? ctx, ClientDataRejectRequest request) =>
      _client.invoke<ClientDataRejectResponse>(ctx, 'IdentityService',
          'ClientDataReject', request, ClientDataRejectResponse());

  /// ClientDataRequestInfo requests more information for a data entry.
  $async.Future<ClientDataRequestInfoResponse> clientDataRequestInfo(
          $pb.ClientContext? ctx, ClientDataRequestInfoRequest request) =>
      _client.invoke<ClientDataRequestInfoResponse>(ctx, 'IdentityService',
          'ClientDataRequestInfo', request, ClientDataRequestInfoResponse());

  /// ClientDataHistory retrieves the revision history for a data entry.
  $async.Future<ClientDataHistoryResponse> clientDataHistory(
          $pb.ClientContext? ctx, ClientDataHistoryRequest request) =>
      _client.invoke<ClientDataHistoryResponse>(ctx, 'IdentityService',
          'ClientDataHistory', request, ClientDataHistoryResponse());

  /// FormTemplateSave creates or updates a form template.
  $async.Future<FormTemplateSaveResponse> formTemplateSave(
          $pb.ClientContext? ctx, FormTemplateSaveRequest request) =>
      _client.invoke<FormTemplateSaveResponse>(ctx, 'IdentityService',
          'FormTemplateSave', request, FormTemplateSaveResponse());

  /// FormTemplateGet retrieves a form template by its ID.
  $async.Future<FormTemplateGetResponse> formTemplateGet(
          $pb.ClientContext? ctx, FormTemplateGetRequest request) =>
      _client.invoke<FormTemplateGetResponse>(ctx, 'IdentityService',
          'FormTemplateGet', request, FormTemplateGetResponse());

  /// FormTemplateSearch finds form templates matching search criteria.
  $async.Future<FormTemplateSearchResponse> formTemplateSearch(
          $pb.ClientContext? ctx, FormTemplateSearchRequest request) =>
      _client.invoke<FormTemplateSearchResponse>(ctx, 'IdentityService',
          'FormTemplateSearch', request, FormTemplateSearchResponse());

  /// FormTemplatePublish transitions a draft form template to published.
  $async.Future<FormTemplatePublishResponse> formTemplatePublish(
          $pb.ClientContext? ctx, FormTemplatePublishRequest request) =>
      _client.invoke<FormTemplatePublishResponse>(ctx, 'IdentityService',
          'FormTemplatePublish', request, FormTemplatePublishResponse());

  /// FormSubmissionSave creates or updates a form submission.
  $async.Future<FormSubmissionSaveResponse> formSubmissionSave(
          $pb.ClientContext? ctx, FormSubmissionSaveRequest request) =>
      _client.invoke<FormSubmissionSaveResponse>(ctx, 'IdentityService',
          'FormSubmissionSave', request, FormSubmissionSaveResponse());

  /// FormSubmissionGet retrieves a form submission by its ID.
  $async.Future<FormSubmissionGetResponse> formSubmissionGet(
          $pb.ClientContext? ctx, FormSubmissionGetRequest request) =>
      _client.invoke<FormSubmissionGetResponse>(ctx, 'IdentityService',
          'FormSubmissionGet', request, FormSubmissionGetResponse());

  /// FormSubmissionSearch finds form submissions matching search criteria.
  $async.Future<FormSubmissionSearchResponse> formSubmissionSearch(
          $pb.ClientContext? ctx, FormSubmissionSearchRequest request) =>
      _client.invoke<FormSubmissionSearchResponse>(ctx, 'IdentityService',
          'FormSubmissionSearch', request, FormSubmissionSearchResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
