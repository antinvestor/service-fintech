//
//  Generated code. Do not modify.
//  source: identity/v1/identity.proto
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

import '../../common/v1/common.pb.dart' as $7;
import '../../common/v1/common.pbenum.dart' as $7;
import '../../common/v1/money.pb.dart' as $8;
import '../../google/protobuf/struct.pb.dart' as $6;
import 'identity.pbenum.dart';

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
    $7.STATE? state,
    OrganizationType? organizationType,
    $6.Struct? properties,
    $core.String? clientId,
    $core.String? geoId,
    $core.String? parentId,
    $core.bool? hasChildren,
    $core.String? domain,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (partitionId != null) {
      $result.partitionId = partitionId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (code != null) {
      $result.code = code;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (state != null) {
      $result.state = state;
    }
    if (organizationType != null) {
      $result.organizationType = organizationType;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (geoId != null) {
      $result.geoId = geoId;
    }
    if (parentId != null) {
      $result.parentId = parentId;
    }
    if (hasChildren != null) {
      $result.hasChildren = hasChildren;
    }
    if (domain != null) {
      $result.domain = domain;
    }
    return $result;
  }
  OrganizationObject._() : super();
  factory OrganizationObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrganizationObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrganizationObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'partitionId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'code')
    ..aOS(5, _omitFieldNames ? '' : 'profileId')
    ..e<$7.STATE>(6, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..e<OrganizationType>(7, _omitFieldNames ? '' : 'organizationType', $pb.PbFieldType.OE, defaultOrMaker: OrganizationType.ORGANIZATION_TYPE_UNSPECIFIED, valueOf: OrganizationType.valueOf, enumValues: OrganizationType.values)
    ..aOM<$6.Struct>(8, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..aOS(9, _omitFieldNames ? '' : 'clientId')
    ..aOS(10, _omitFieldNames ? '' : 'geoId')
    ..aOS(11, _omitFieldNames ? '' : 'parentId')
    ..aOB(12, _omitFieldNames ? '' : 'hasChildren')
    ..aOS(13, _omitFieldNames ? '' : 'domain')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrganizationObject clone() => OrganizationObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrganizationObject copyWith(void Function(OrganizationObject) updates) => super.copyWith((message) => updates(message as OrganizationObject)) as OrganizationObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrganizationObject create() => OrganizationObject._();
  OrganizationObject createEmptyInstance() => create();
  static $pb.PbList<OrganizationObject> createRepeated() => $pb.PbList<OrganizationObject>();
  @$core.pragma('dart2js:noInline')
  static OrganizationObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrganizationObject>(create);
  static OrganizationObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get partitionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set partitionId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPartitionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPartitionId() => clearField(2);

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
  $core.String get profileId => $_getSZ(4);
  @$pb.TagNumber(5)
  set profileId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasProfileId() => $_has(4);
  @$pb.TagNumber(5)
  void clearProfileId() => clearField(5);

  @$pb.TagNumber(6)
  $7.STATE get state => $_getN(5);
  @$pb.TagNumber(6)
  set state($7.STATE v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasState() => $_has(5);
  @$pb.TagNumber(6)
  void clearState() => clearField(6);

  @$pb.TagNumber(7)
  OrganizationType get organizationType => $_getN(6);
  @$pb.TagNumber(7)
  set organizationType(OrganizationType v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasOrganizationType() => $_has(6);
  @$pb.TagNumber(7)
  void clearOrganizationType() => clearField(7);

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

  @$pb.TagNumber(9)
  $core.String get clientId => $_getSZ(8);
  @$pb.TagNumber(9)
  set clientId($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasClientId() => $_has(8);
  @$pb.TagNumber(9)
  void clearClientId() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get geoId => $_getSZ(9);
  @$pb.TagNumber(10)
  set geoId($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasGeoId() => $_has(9);
  @$pb.TagNumber(10)
  void clearGeoId() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get parentId => $_getSZ(10);
  @$pb.TagNumber(11)
  set parentId($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasParentId() => $_has(10);
  @$pb.TagNumber(11)
  void clearParentId() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get hasChildren => $_getBF(11);
  @$pb.TagNumber(12)
  set hasChildren($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasHasChildren() => $_has(11);
  @$pb.TagNumber(12)
  void clearHasChildren() => clearField(12);

  /// The domain name associated with this organization (e.g. "stawi.org").
  @$pb.TagNumber(13)
  $core.String get domain => $_getSZ(12);
  @$pb.TagNumber(13)
  set domain($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasDomain() => $_has(12);
  @$pb.TagNumber(13)
  void clearDomain() => clearField(13);
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
    $7.STATE? state,
    OrgUnitType? type,
    $6.Struct? properties,
    $core.String? clientId,
    $core.bool? hasChildren,
    $core.String? profileId,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (parentId != null) {
      $result.parentId = parentId;
    }
    if (partitionId != null) {
      $result.partitionId = partitionId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (code != null) {
      $result.code = code;
    }
    if (geoId != null) {
      $result.geoId = geoId;
    }
    if (state != null) {
      $result.state = state;
    }
    if (type != null) {
      $result.type = type;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (hasChildren != null) {
      $result.hasChildren = hasChildren;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    return $result;
  }
  OrgUnitObject._() : super();
  factory OrgUnitObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrgUnitObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrgUnitObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aOS(4, _omitFieldNames ? '' : 'partitionId')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'code')
    ..aOS(7, _omitFieldNames ? '' : 'geoId')
    ..e<$7.STATE>(8, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..e<OrgUnitType>(9, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED, valueOf: OrgUnitType.valueOf, enumValues: OrgUnitType.values)
    ..aOM<$6.Struct>(10, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..aOS(11, _omitFieldNames ? '' : 'clientId')
    ..aOB(12, _omitFieldNames ? '' : 'hasChildren')
    ..aOS(13, _omitFieldNames ? '' : 'profileId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrgUnitObject clone() => OrgUnitObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrgUnitObject copyWith(void Function(OrgUnitObject) updates) => super.copyWith((message) => updates(message as OrgUnitObject)) as OrgUnitObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrgUnitObject create() => OrgUnitObject._();
  OrgUnitObject createEmptyInstance() => create();
  static $pb.PbList<OrgUnitObject> createRepeated() => $pb.PbList<OrgUnitObject>();
  @$core.pragma('dart2js:noInline')
  static OrgUnitObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrgUnitObject>(create);
  static OrgUnitObject? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get partitionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set partitionId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPartitionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearPartitionId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get code => $_getSZ(5);
  @$pb.TagNumber(6)
  set code($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCode() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get geoId => $_getSZ(6);
  @$pb.TagNumber(7)
  set geoId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasGeoId() => $_has(6);
  @$pb.TagNumber(7)
  void clearGeoId() => clearField(7);

  @$pb.TagNumber(8)
  $7.STATE get state => $_getN(7);
  @$pb.TagNumber(8)
  set state($7.STATE v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasState() => $_has(7);
  @$pb.TagNumber(8)
  void clearState() => clearField(8);

  @$pb.TagNumber(9)
  OrgUnitType get type => $_getN(8);
  @$pb.TagNumber(9)
  set type(OrgUnitType v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasType() => $_has(8);
  @$pb.TagNumber(9)
  void clearType() => clearField(9);

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
  $core.String get clientId => $_getSZ(10);
  @$pb.TagNumber(11)
  set clientId($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasClientId() => $_has(10);
  @$pb.TagNumber(11)
  void clearClientId() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get hasChildren => $_getBF(11);
  @$pb.TagNumber(12)
  set hasChildren($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasHasChildren() => $_has(11);
  @$pb.TagNumber(12)
  void clearHasChildren() => clearField(12);

  /// Profile ID for this org unit's profile (contacts, addresses, avatar).
  @$pb.TagNumber(13)
  $core.String get profileId => $_getSZ(12);
  @$pb.TagNumber(13)
  set profileId($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasProfileId() => $_has(12);
  @$pb.TagNumber(13)
  void clearProfileId() => clearField(13);
}

/// InvestorObject represents an independent investor with a profile link.
/// Investors are not assigned to agents — they exist independently.
class InvestorObject extends $pb.GeneratedMessage {
  factory InvestorObject({
    $core.String? id,
    $core.String? profileId,
    $core.String? name,
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
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
    return $result;
  }
  InvestorObject._() : super();
  factory InvestorObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'profileId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..e<$7.STATE>(4, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(5, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorObject clone() => InvestorObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorObject copyWith(void Function(InvestorObject) updates) => super.copyWith((message) => updates(message as InvestorObject)) as InvestorObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorObject create() => InvestorObject._();
  InvestorObject createEmptyInstance() => create();
  static $pb.PbList<InvestorObject> createRepeated() => $pb.PbList<InvestorObject>();
  @$core.pragma('dart2js:noInline')
  static InvestorObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorObject>(create);
  static InvestorObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get profileId => $_getSZ(1);
  @$pb.TagNumber(2)
  set profileId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProfileId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfileId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

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

/// WorkforceMemberObject represents a worker in the organization.
class WorkforceMemberObject extends $pb.GeneratedMessage {
  factory WorkforceMemberObject({
    $core.String? id,
    $core.String? organizationId,
    $core.String? profileId,
    $core.String? engagementType,
    $core.String? homeOrgUnitId,
    $core.String? geoId,
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (engagementType != null) {
      $result.engagementType = engagementType;
    }
    if (homeOrgUnitId != null) {
      $result.homeOrgUnitId = homeOrgUnitId;
    }
    if (geoId != null) {
      $result.geoId = geoId;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  WorkforceMemberObject._() : super();
  factory WorkforceMemberObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WorkforceMemberObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WorkforceMemberObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'profileId')
    ..aOS(4, _omitFieldNames ? '' : 'engagementType')
    ..aOS(5, _omitFieldNames ? '' : 'homeOrgUnitId')
    ..aOS(6, _omitFieldNames ? '' : 'geoId')
    ..e<$7.STATE>(7, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(8, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WorkforceMemberObject clone() => WorkforceMemberObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WorkforceMemberObject copyWith(void Function(WorkforceMemberObject) updates) => super.copyWith((message) => updates(message as WorkforceMemberObject)) as WorkforceMemberObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkforceMemberObject create() => WorkforceMemberObject._();
  WorkforceMemberObject createEmptyInstance() => create();
  static $pb.PbList<WorkforceMemberObject> createRepeated() => $pb.PbList<WorkforceMemberObject>();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkforceMemberObject>(create);
  static WorkforceMemberObject? _defaultInstance;

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
  $core.String get profileId => $_getSZ(2);
  @$pb.TagNumber(3)
  set profileId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasProfileId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProfileId() => clearField(3);

  /// Organization-defined engagement type (e.g. "employee", "contractor", "agent", "intern").
  @$pb.TagNumber(4)
  $core.String get engagementType => $_getSZ(3);
  @$pb.TagNumber(4)
  set engagementType($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEngagementType() => $_has(3);
  @$pb.TagNumber(4)
  void clearEngagementType() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get homeOrgUnitId => $_getSZ(4);
  @$pb.TagNumber(5)
  set homeOrgUnitId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHomeOrgUnitId() => $_has(4);
  @$pb.TagNumber(5)
  void clearHomeOrgUnitId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get geoId => $_getSZ(5);
  @$pb.TagNumber(6)
  set geoId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasGeoId() => $_has(5);
  @$pb.TagNumber(6)
  void clearGeoId() => clearField(6);

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

/// DepartmentObject represents a functional grouping node.
class DepartmentObject extends $pb.GeneratedMessage {
  factory DepartmentObject({
    $core.String? id,
    $core.String? organizationId,
    $core.String? parentId,
    DepartmentKind? kind,
    $core.String? name,
    $core.String? code,
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (parentId != null) {
      $result.parentId = parentId;
    }
    if (kind != null) {
      $result.kind = kind;
    }
    if (name != null) {
      $result.name = name;
    }
    if (code != null) {
      $result.code = code;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  DepartmentObject._() : super();
  factory DepartmentObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepartmentObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepartmentObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..e<DepartmentKind>(4, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE, defaultOrMaker: DepartmentKind.DEPARTMENT_KIND_UNSPECIFIED, valueOf: DepartmentKind.valueOf, enumValues: DepartmentKind.values)
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'code')
    ..e<$7.STATE>(7, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(8, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepartmentObject clone() => DepartmentObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepartmentObject copyWith(void Function(DepartmentObject) updates) => super.copyWith((message) => updates(message as DepartmentObject)) as DepartmentObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepartmentObject create() => DepartmentObject._();
  DepartmentObject createEmptyInstance() => create();
  static $pb.PbList<DepartmentObject> createRepeated() => $pb.PbList<DepartmentObject>();
  @$core.pragma('dart2js:noInline')
  static DepartmentObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepartmentObject>(create);
  static DepartmentObject? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => clearField(3);

  @$pb.TagNumber(4)
  DepartmentKind get kind => $_getN(3);
  @$pb.TagNumber(4)
  set kind(DepartmentKind v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearKind() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get code => $_getSZ(5);
  @$pb.TagNumber(6)
  set code($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCode() => clearField(6);

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
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (orgUnitId != null) {
      $result.orgUnitId = orgUnitId;
    }
    if (departmentId != null) {
      $result.departmentId = departmentId;
    }
    if (reportsToPositionId != null) {
      $result.reportsToPositionId = reportsToPositionId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (code != null) {
      $result.code = code;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  PositionObject._() : super();
  factory PositionObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'orgUnitId')
    ..aOS(4, _omitFieldNames ? '' : 'departmentId')
    ..aOS(5, _omitFieldNames ? '' : 'reportsToPositionId')
    ..aOS(6, _omitFieldNames ? '' : 'name')
    ..aOS(7, _omitFieldNames ? '' : 'code')
    ..e<$7.STATE>(8, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(9, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionObject clone() => PositionObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionObject copyWith(void Function(PositionObject) updates) => super.copyWith((message) => updates(message as PositionObject)) as PositionObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionObject create() => PositionObject._();
  PositionObject createEmptyInstance() => create();
  static $pb.PbList<PositionObject> createRepeated() => $pb.PbList<PositionObject>();
  @$core.pragma('dart2js:noInline')
  static PositionObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionObject>(create);
  static PositionObject? _defaultInstance;

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
  $core.String get orgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set orgUnitId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrgUnitId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get departmentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set departmentId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDepartmentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDepartmentId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get reportsToPositionId => $_getSZ(4);
  @$pb.TagNumber(5)
  set reportsToPositionId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReportsToPositionId() => $_has(4);
  @$pb.TagNumber(5)
  void clearReportsToPositionId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(6)
  set name($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(6)
  void clearName() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get code => $_getSZ(6);
  @$pb.TagNumber(7)
  set code($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCode() => $_has(6);
  @$pb.TagNumber(7)
  void clearCode() => clearField(7);

  @$pb.TagNumber(8)
  $7.STATE get state => $_getN(7);
  @$pb.TagNumber(8)
  set state($7.STATE v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasState() => $_has(7);
  @$pb.TagNumber(8)
  void clearState() => clearField(8);

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

/// PositionAssignmentObject assigns a workforce member to a position.
class PositionAssignmentObject extends $pb.GeneratedMessage {
  factory PositionAssignmentObject({
    $core.String? id,
    $core.String? memberId,
    $core.String? positionId,
    $core.bool? isPrimary,
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (memberId != null) {
      $result.memberId = memberId;
    }
    if (positionId != null) {
      $result.positionId = positionId;
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
  PositionAssignmentObject._() : super();
  factory PositionAssignmentObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionAssignmentObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionAssignmentObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'memberId')
    ..aOS(3, _omitFieldNames ? '' : 'positionId')
    ..aOB(4, _omitFieldNames ? '' : 'isPrimary')
    ..e<$7.STATE>(5, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(6, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionAssignmentObject clone() => PositionAssignmentObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionAssignmentObject copyWith(void Function(PositionAssignmentObject) updates) => super.copyWith((message) => updates(message as PositionAssignmentObject)) as PositionAssignmentObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionAssignmentObject create() => PositionAssignmentObject._();
  PositionAssignmentObject createEmptyInstance() => create();
  static $pb.PbList<PositionAssignmentObject> createRepeated() => $pb.PbList<PositionAssignmentObject>();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionAssignmentObject>(create);
  static PositionAssignmentObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get memberId => $_getSZ(1);
  @$pb.TagNumber(2)
  set memberId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get positionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set positionId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPositionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPositionId() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isPrimary => $_getBF(3);
  @$pb.TagNumber(4)
  set isPrimary($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsPrimary() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsPrimary() => clearField(4);

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
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (parentTeamId != null) {
      $result.parentTeamId = parentTeamId;
    }
    if (homeOrgUnitId != null) {
      $result.homeOrgUnitId = homeOrgUnitId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (code != null) {
      $result.code = code;
    }
    if (teamType != null) {
      $result.teamType = teamType;
    }
    if (objective != null) {
      $result.objective = objective;
    }
    if (geoId != null) {
      $result.geoId = geoId;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  InternalTeamObject._() : super();
  factory InternalTeamObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InternalTeamObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InternalTeamObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentTeamId')
    ..aOS(4, _omitFieldNames ? '' : 'homeOrgUnitId')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'code')
    ..aOS(7, _omitFieldNames ? '' : 'teamType')
    ..aOS(8, _omitFieldNames ? '' : 'objective')
    ..aOS(9, _omitFieldNames ? '' : 'geoId')
    ..e<$7.STATE>(10, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(11, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InternalTeamObject clone() => InternalTeamObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InternalTeamObject copyWith(void Function(InternalTeamObject) updates) => super.copyWith((message) => updates(message as InternalTeamObject)) as InternalTeamObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InternalTeamObject create() => InternalTeamObject._();
  InternalTeamObject createEmptyInstance() => create();
  static $pb.PbList<InternalTeamObject> createRepeated() => $pb.PbList<InternalTeamObject>();
  @$core.pragma('dart2js:noInline')
  static InternalTeamObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InternalTeamObject>(create);
  static InternalTeamObject? _defaultInstance;

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
  $core.String get parentTeamId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentTeamId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasParentTeamId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentTeamId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get homeOrgUnitId => $_getSZ(3);
  @$pb.TagNumber(4)
  set homeOrgUnitId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHomeOrgUnitId() => $_has(3);
  @$pb.TagNumber(4)
  void clearHomeOrgUnitId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get code => $_getSZ(5);
  @$pb.TagNumber(6)
  set code($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearCode() => clearField(6);

  /// Organization-defined team type (e.g. "portfolio", "collections", "recovery", "sales", "agent_network").
  @$pb.TagNumber(7)
  $core.String get teamType => $_getSZ(6);
  @$pb.TagNumber(7)
  set teamType($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTeamType() => $_has(6);
  @$pb.TagNumber(7)
  void clearTeamType() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get objective => $_getSZ(7);
  @$pb.TagNumber(8)
  set objective($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasObjective() => $_has(7);
  @$pb.TagNumber(8)
  void clearObjective() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get geoId => $_getSZ(8);
  @$pb.TagNumber(9)
  set geoId($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasGeoId() => $_has(8);
  @$pb.TagNumber(9)
  void clearGeoId() => clearField(9);

  @$pb.TagNumber(10)
  $7.STATE get state => $_getN(9);
  @$pb.TagNumber(10)
  set state($7.STATE v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasState() => $_has(9);
  @$pb.TagNumber(10)
  void clearState() => clearField(10);

  @$pb.TagNumber(11)
  $6.Struct get properties => $_getN(10);
  @$pb.TagNumber(11)
  set properties($6.Struct v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasProperties() => $_has(10);
  @$pb.TagNumber(11)
  void clearProperties() => clearField(11);
  @$pb.TagNumber(11)
  $6.Struct ensureProperties() => $_ensure(10);
}

/// TeamMembershipObject assigns a workforce member to an internal team.
class TeamMembershipObject extends $pb.GeneratedMessage {
  factory TeamMembershipObject({
    $core.String? id,
    $core.String? teamId,
    $core.String? memberId,
    $core.String? membershipRole,
    $core.bool? isPrimaryTeam,
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (teamId != null) {
      $result.teamId = teamId;
    }
    if (memberId != null) {
      $result.memberId = memberId;
    }
    if (membershipRole != null) {
      $result.membershipRole = membershipRole;
    }
    if (isPrimaryTeam != null) {
      $result.isPrimaryTeam = isPrimaryTeam;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  TeamMembershipObject._() : super();
  factory TeamMembershipObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TeamMembershipObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TeamMembershipObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'teamId')
    ..aOS(3, _omitFieldNames ? '' : 'memberId')
    ..aOS(4, _omitFieldNames ? '' : 'membershipRole')
    ..aOB(5, _omitFieldNames ? '' : 'isPrimaryTeam')
    ..e<$7.STATE>(6, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(7, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TeamMembershipObject clone() => TeamMembershipObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TeamMembershipObject copyWith(void Function(TeamMembershipObject) updates) => super.copyWith((message) => updates(message as TeamMembershipObject)) as TeamMembershipObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamMembershipObject create() => TeamMembershipObject._();
  TeamMembershipObject createEmptyInstance() => create();
  static $pb.PbList<TeamMembershipObject> createRepeated() => $pb.PbList<TeamMembershipObject>();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TeamMembershipObject>(create);
  static TeamMembershipObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get teamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set teamId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTeamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTeamId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get memberId => $_getSZ(2);
  @$pb.TagNumber(3)
  set memberId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMemberId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberId() => clearField(3);

  /// Organization-defined role within the team (e.g. "lead", "member", "supervisor", "coordinator").
  @$pb.TagNumber(4)
  $core.String get membershipRole => $_getSZ(3);
  @$pb.TagNumber(4)
  set membershipRole($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMembershipRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearMembershipRole() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isPrimaryTeam => $_getBF(4);
  @$pb.TagNumber(5)
  set isPrimaryTeam($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsPrimaryTeam() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsPrimaryTeam() => clearField(5);

  @$pb.TagNumber(6)
  $7.STATE get state => $_getN(5);
  @$pb.TagNumber(6)
  set state($7.STATE v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasState() => $_has(5);
  @$pb.TagNumber(6)
  void clearState() => clearField(6);

  @$pb.TagNumber(7)
  $6.Struct get properties => $_getN(6);
  @$pb.TagNumber(7)
  set properties($6.Struct v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasProperties() => $_has(6);
  @$pb.TagNumber(7)
  void clearProperties() => clearField(7);
  @$pb.TagNumber(7)
  $6.Struct ensureProperties() => $_ensure(6);
}

/// AccessRoleAssignmentObject grants explicit access at a given scope.
class AccessRoleAssignmentObject extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentObject({
    $core.String? id,
    $core.String? memberId,
    $core.String? roleKey,
    AccessScopeType? scopeType,
    $core.String? scopeId,
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (memberId != null) {
      $result.memberId = memberId;
    }
    if (roleKey != null) {
      $result.roleKey = roleKey;
    }
    if (scopeType != null) {
      $result.scopeType = scopeType;
    }
    if (scopeId != null) {
      $result.scopeId = scopeId;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  AccessRoleAssignmentObject._() : super();
  factory AccessRoleAssignmentObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AccessRoleAssignmentObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AccessRoleAssignmentObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'memberId')
    ..aOS(3, _omitFieldNames ? '' : 'roleKey')
    ..e<AccessScopeType>(4, _omitFieldNames ? '' : 'scopeType', $pb.PbFieldType.OE, defaultOrMaker: AccessScopeType.ACCESS_SCOPE_TYPE_UNSPECIFIED, valueOf: AccessScopeType.valueOf, enumValues: AccessScopeType.values)
    ..aOS(5, _omitFieldNames ? '' : 'scopeId')
    ..e<$7.STATE>(6, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(7, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentObject clone() => AccessRoleAssignmentObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentObject copyWith(void Function(AccessRoleAssignmentObject) updates) => super.copyWith((message) => updates(message as AccessRoleAssignmentObject)) as AccessRoleAssignmentObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentObject create() => AccessRoleAssignmentObject._();
  AccessRoleAssignmentObject createEmptyInstance() => create();
  static $pb.PbList<AccessRoleAssignmentObject> createRepeated() => $pb.PbList<AccessRoleAssignmentObject>();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentObject>(create);
  static AccessRoleAssignmentObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get memberId => $_getSZ(1);
  @$pb.TagNumber(2)
  set memberId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get roleKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set roleKey($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRoleKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoleKey() => clearField(3);

  @$pb.TagNumber(4)
  AccessScopeType get scopeType => $_getN(3);
  @$pb.TagNumber(4)
  set scopeType(AccessScopeType v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasScopeType() => $_has(3);
  @$pb.TagNumber(4)
  void clearScopeType() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get scopeId => $_getSZ(4);
  @$pb.TagNumber(5)
  set scopeId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasScopeId() => $_has(4);
  @$pb.TagNumber(5)
  void clearScopeId() => clearField(5);

  @$pb.TagNumber(6)
  $7.STATE get state => $_getN(5);
  @$pb.TagNumber(6)
  set state($7.STATE v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasState() => $_has(5);
  @$pb.TagNumber(6)
  void clearState() => clearField(6);

  @$pb.TagNumber(7)
  $6.Struct get properties => $_getN(6);
  @$pb.TagNumber(7)
  set properties($6.Struct v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasProperties() => $_has(6);
  @$pb.TagNumber(7)
  void clearProperties() => clearField(7);
  @$pb.TagNumber(7)
  $6.Struct ensureProperties() => $_ensure(6);
}

/// Organization messages
class OrganizationSaveRequest extends $pb.GeneratedMessage {
  factory OrganizationSaveRequest({
    OrganizationObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  OrganizationSaveRequest._() : super();
  factory OrganizationSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrganizationSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrganizationSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<OrganizationObject>(1, _omitFieldNames ? '' : 'data', subBuilder: OrganizationObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrganizationSaveRequest clone() => OrganizationSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrganizationSaveRequest copyWith(void Function(OrganizationSaveRequest) updates) => super.copyWith((message) => updates(message as OrganizationSaveRequest)) as OrganizationSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrganizationSaveRequest create() => OrganizationSaveRequest._();
  OrganizationSaveRequest createEmptyInstance() => create();
  static $pb.PbList<OrganizationSaveRequest> createRepeated() => $pb.PbList<OrganizationSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static OrganizationSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrganizationSaveRequest>(create);
  static OrganizationSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  OrganizationObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrganizationObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  OrganizationObject ensureData() => $_ensure(0);
}

class OrganizationSaveResponse extends $pb.GeneratedMessage {
  factory OrganizationSaveResponse({
    OrganizationObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  OrganizationSaveResponse._() : super();
  factory OrganizationSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrganizationSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrganizationSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<OrganizationObject>(1, _omitFieldNames ? '' : 'data', subBuilder: OrganizationObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrganizationSaveResponse clone() => OrganizationSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrganizationSaveResponse copyWith(void Function(OrganizationSaveResponse) updates) => super.copyWith((message) => updates(message as OrganizationSaveResponse)) as OrganizationSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrganizationSaveResponse create() => OrganizationSaveResponse._();
  OrganizationSaveResponse createEmptyInstance() => create();
  static $pb.PbList<OrganizationSaveResponse> createRepeated() => $pb.PbList<OrganizationSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static OrganizationSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrganizationSaveResponse>(create);
  static OrganizationSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  OrganizationObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrganizationObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  OrganizationObject ensureData() => $_ensure(0);
}

class OrganizationGetRequest extends $pb.GeneratedMessage {
  factory OrganizationGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  OrganizationGetRequest._() : super();
  factory OrganizationGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrganizationGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrganizationGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrganizationGetRequest clone() => OrganizationGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrganizationGetRequest copyWith(void Function(OrganizationGetRequest) updates) => super.copyWith((message) => updates(message as OrganizationGetRequest)) as OrganizationGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrganizationGetRequest create() => OrganizationGetRequest._();
  OrganizationGetRequest createEmptyInstance() => create();
  static $pb.PbList<OrganizationGetRequest> createRepeated() => $pb.PbList<OrganizationGetRequest>();
  @$core.pragma('dart2js:noInline')
  static OrganizationGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrganizationGetRequest>(create);
  static OrganizationGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class OrganizationGetResponse extends $pb.GeneratedMessage {
  factory OrganizationGetResponse({
    OrganizationObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  OrganizationGetResponse._() : super();
  factory OrganizationGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrganizationGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrganizationGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<OrganizationObject>(1, _omitFieldNames ? '' : 'data', subBuilder: OrganizationObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrganizationGetResponse clone() => OrganizationGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrganizationGetResponse copyWith(void Function(OrganizationGetResponse) updates) => super.copyWith((message) => updates(message as OrganizationGetResponse)) as OrganizationGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrganizationGetResponse create() => OrganizationGetResponse._();
  OrganizationGetResponse createEmptyInstance() => create();
  static $pb.PbList<OrganizationGetResponse> createRepeated() => $pb.PbList<OrganizationGetResponse>();
  @$core.pragma('dart2js:noInline')
  static OrganizationGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrganizationGetResponse>(create);
  static OrganizationGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  OrganizationObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrganizationObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  OrganizationObject ensureData() => $_ensure(0);
}

class OrganizationSearchResponse extends $pb.GeneratedMessage {
  factory OrganizationSearchResponse({
    $core.Iterable<OrganizationObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  OrganizationSearchResponse._() : super();
  factory OrganizationSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrganizationSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrganizationSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<OrganizationObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: OrganizationObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrganizationSearchResponse clone() => OrganizationSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrganizationSearchResponse copyWith(void Function(OrganizationSearchResponse) updates) => super.copyWith((message) => updates(message as OrganizationSearchResponse)) as OrganizationSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrganizationSearchResponse create() => OrganizationSearchResponse._();
  OrganizationSearchResponse createEmptyInstance() => create();
  static $pb.PbList<OrganizationSearchResponse> createRepeated() => $pb.PbList<OrganizationSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static OrganizationSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrganizationSearchResponse>(create);
  static OrganizationSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<OrganizationObject> get data => $_getList(0);
}

/// Org unit messages
class OrgUnitSaveRequest extends $pb.GeneratedMessage {
  factory OrgUnitSaveRequest({
    OrgUnitObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  OrgUnitSaveRequest._() : super();
  factory OrgUnitSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrgUnitSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrgUnitSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<OrgUnitObject>(1, _omitFieldNames ? '' : 'data', subBuilder: OrgUnitObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrgUnitSaveRequest clone() => OrgUnitSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrgUnitSaveRequest copyWith(void Function(OrgUnitSaveRequest) updates) => super.copyWith((message) => updates(message as OrgUnitSaveRequest)) as OrgUnitSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrgUnitSaveRequest create() => OrgUnitSaveRequest._();
  OrgUnitSaveRequest createEmptyInstance() => create();
  static $pb.PbList<OrgUnitSaveRequest> createRepeated() => $pb.PbList<OrgUnitSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static OrgUnitSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrgUnitSaveRequest>(create);
  static OrgUnitSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  OrgUnitObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrgUnitObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  OrgUnitObject ensureData() => $_ensure(0);
}

class OrgUnitSaveResponse extends $pb.GeneratedMessage {
  factory OrgUnitSaveResponse({
    OrgUnitObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  OrgUnitSaveResponse._() : super();
  factory OrgUnitSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrgUnitSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrgUnitSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<OrgUnitObject>(1, _omitFieldNames ? '' : 'data', subBuilder: OrgUnitObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrgUnitSaveResponse clone() => OrgUnitSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrgUnitSaveResponse copyWith(void Function(OrgUnitSaveResponse) updates) => super.copyWith((message) => updates(message as OrgUnitSaveResponse)) as OrgUnitSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrgUnitSaveResponse create() => OrgUnitSaveResponse._();
  OrgUnitSaveResponse createEmptyInstance() => create();
  static $pb.PbList<OrgUnitSaveResponse> createRepeated() => $pb.PbList<OrgUnitSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static OrgUnitSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrgUnitSaveResponse>(create);
  static OrgUnitSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  OrgUnitObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrgUnitObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  OrgUnitObject ensureData() => $_ensure(0);
}

class OrgUnitGetRequest extends $pb.GeneratedMessage {
  factory OrgUnitGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  OrgUnitGetRequest._() : super();
  factory OrgUnitGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrgUnitGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrgUnitGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrgUnitGetRequest clone() => OrgUnitGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrgUnitGetRequest copyWith(void Function(OrgUnitGetRequest) updates) => super.copyWith((message) => updates(message as OrgUnitGetRequest)) as OrgUnitGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrgUnitGetRequest create() => OrgUnitGetRequest._();
  OrgUnitGetRequest createEmptyInstance() => create();
  static $pb.PbList<OrgUnitGetRequest> createRepeated() => $pb.PbList<OrgUnitGetRequest>();
  @$core.pragma('dart2js:noInline')
  static OrgUnitGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrgUnitGetRequest>(create);
  static OrgUnitGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class OrgUnitGetResponse extends $pb.GeneratedMessage {
  factory OrgUnitGetResponse({
    OrgUnitObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  OrgUnitGetResponse._() : super();
  factory OrgUnitGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrgUnitGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrgUnitGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<OrgUnitObject>(1, _omitFieldNames ? '' : 'data', subBuilder: OrgUnitObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrgUnitGetResponse clone() => OrgUnitGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrgUnitGetResponse copyWith(void Function(OrgUnitGetResponse) updates) => super.copyWith((message) => updates(message as OrgUnitGetResponse)) as OrgUnitGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrgUnitGetResponse create() => OrgUnitGetResponse._();
  OrgUnitGetResponse createEmptyInstance() => create();
  static $pb.PbList<OrgUnitGetResponse> createRepeated() => $pb.PbList<OrgUnitGetResponse>();
  @$core.pragma('dart2js:noInline')
  static OrgUnitGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrgUnitGetResponse>(create);
  static OrgUnitGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  OrgUnitObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(OrgUnitObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
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
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (parentId != null) {
      $result.parentId = parentId;
    }
    if (rootOnly != null) {
      $result.rootOnly = rootOnly;
    }
    if (type != null) {
      $result.type = type;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  OrgUnitSearchRequest._() : super();
  factory OrgUnitSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrgUnitSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrgUnitSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aOB(4, _omitFieldNames ? '' : 'rootOnly')
    ..e<OrgUnitType>(5, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED, valueOf: OrgUnitType.valueOf, enumValues: OrgUnitType.values)
    ..aOM<$7.PageCursor>(6, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrgUnitSearchRequest clone() => OrgUnitSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrgUnitSearchRequest copyWith(void Function(OrgUnitSearchRequest) updates) => super.copyWith((message) => updates(message as OrgUnitSearchRequest)) as OrgUnitSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrgUnitSearchRequest create() => OrgUnitSearchRequest._();
  OrgUnitSearchRequest createEmptyInstance() => create();
  static $pb.PbList<OrgUnitSearchRequest> createRepeated() => $pb.PbList<OrgUnitSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static OrgUnitSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrgUnitSearchRequest>(create);
  static OrgUnitSearchRequest? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get rootOnly => $_getBF(3);
  @$pb.TagNumber(4)
  set rootOnly($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRootOnly() => $_has(3);
  @$pb.TagNumber(4)
  void clearRootOnly() => clearField(4);

  @$pb.TagNumber(5)
  OrgUnitType get type => $_getN(4);
  @$pb.TagNumber(5)
  set type(OrgUnitType v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => clearField(5);

  @$pb.TagNumber(6)
  $7.PageCursor get cursor => $_getN(5);
  @$pb.TagNumber(6)
  set cursor($7.PageCursor v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearCursor() => clearField(6);
  @$pb.TagNumber(6)
  $7.PageCursor ensureCursor() => $_ensure(5);
}

class OrgUnitSearchResponse extends $pb.GeneratedMessage {
  factory OrgUnitSearchResponse({
    $core.Iterable<OrgUnitObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  OrgUnitSearchResponse._() : super();
  factory OrgUnitSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrgUnitSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrgUnitSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<OrgUnitObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: OrgUnitObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrgUnitSearchResponse clone() => OrgUnitSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrgUnitSearchResponse copyWith(void Function(OrgUnitSearchResponse) updates) => super.copyWith((message) => updates(message as OrgUnitSearchResponse)) as OrgUnitSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrgUnitSearchResponse create() => OrgUnitSearchResponse._();
  OrgUnitSearchResponse createEmptyInstance() => create();
  static $pb.PbList<OrgUnitSearchResponse> createRepeated() => $pb.PbList<OrgUnitSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static OrgUnitSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrgUnitSearchResponse>(create);
  static OrgUnitSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<OrgUnitObject> get data => $_getList(0);
}

/// Investor messages
class InvestorSaveRequest extends $pb.GeneratedMessage {
  factory InvestorSaveRequest({
    InvestorObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InvestorSaveRequest._() : super();
  factory InvestorSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<InvestorObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InvestorObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorSaveRequest clone() => InvestorSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorSaveRequest copyWith(void Function(InvestorSaveRequest) updates) => super.copyWith((message) => updates(message as InvestorSaveRequest)) as InvestorSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorSaveRequest create() => InvestorSaveRequest._();
  InvestorSaveRequest createEmptyInstance() => create();
  static $pb.PbList<InvestorSaveRequest> createRepeated() => $pb.PbList<InvestorSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static InvestorSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorSaveRequest>(create);
  static InvestorSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InvestorObject ensureData() => $_ensure(0);
}

class InvestorSaveResponse extends $pb.GeneratedMessage {
  factory InvestorSaveResponse({
    InvestorObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InvestorSaveResponse._() : super();
  factory InvestorSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<InvestorObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InvestorObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorSaveResponse clone() => InvestorSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorSaveResponse copyWith(void Function(InvestorSaveResponse) updates) => super.copyWith((message) => updates(message as InvestorSaveResponse)) as InvestorSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorSaveResponse create() => InvestorSaveResponse._();
  InvestorSaveResponse createEmptyInstance() => create();
  static $pb.PbList<InvestorSaveResponse> createRepeated() => $pb.PbList<InvestorSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static InvestorSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorSaveResponse>(create);
  static InvestorSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InvestorObject ensureData() => $_ensure(0);
}

class InvestorGetRequest extends $pb.GeneratedMessage {
  factory InvestorGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  InvestorGetRequest._() : super();
  factory InvestorGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorGetRequest clone() => InvestorGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorGetRequest copyWith(void Function(InvestorGetRequest) updates) => super.copyWith((message) => updates(message as InvestorGetRequest)) as InvestorGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorGetRequest create() => InvestorGetRequest._();
  InvestorGetRequest createEmptyInstance() => create();
  static $pb.PbList<InvestorGetRequest> createRepeated() => $pb.PbList<InvestorGetRequest>();
  @$core.pragma('dart2js:noInline')
  static InvestorGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorGetRequest>(create);
  static InvestorGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class InvestorGetResponse extends $pb.GeneratedMessage {
  factory InvestorGetResponse({
    InvestorObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InvestorGetResponse._() : super();
  factory InvestorGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<InvestorObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InvestorObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorGetResponse clone() => InvestorGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorGetResponse copyWith(void Function(InvestorGetResponse) updates) => super.copyWith((message) => updates(message as InvestorGetResponse)) as InvestorGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorGetResponse create() => InvestorGetResponse._();
  InvestorGetResponse createEmptyInstance() => create();
  static $pb.PbList<InvestorGetResponse> createRepeated() => $pb.PbList<InvestorGetResponse>();
  @$core.pragma('dart2js:noInline')
  static InvestorGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorGetResponse>(create);
  static InvestorGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InvestorObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InvestorObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InvestorObject ensureData() => $_ensure(0);
}

class InvestorSearchRequest extends $pb.GeneratedMessage {
  factory InvestorSearchRequest({
    $core.String? query,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  InvestorSearchRequest._() : super();
  factory InvestorSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOM<$7.PageCursor>(2, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorSearchRequest clone() => InvestorSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorSearchRequest copyWith(void Function(InvestorSearchRequest) updates) => super.copyWith((message) => updates(message as InvestorSearchRequest)) as InvestorSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorSearchRequest create() => InvestorSearchRequest._();
  InvestorSearchRequest createEmptyInstance() => create();
  static $pb.PbList<InvestorSearchRequest> createRepeated() => $pb.PbList<InvestorSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static InvestorSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorSearchRequest>(create);
  static InvestorSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $7.PageCursor get cursor => $_getN(1);
  @$pb.TagNumber(2)
  set cursor($7.PageCursor v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => clearField(2);
  @$pb.TagNumber(2)
  $7.PageCursor ensureCursor() => $_ensure(1);
}

class InvestorSearchResponse extends $pb.GeneratedMessage {
  factory InvestorSearchResponse({
    $core.Iterable<InvestorObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  InvestorSearchResponse._() : super();
  factory InvestorSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InvestorSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<InvestorObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: InvestorObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InvestorSearchResponse clone() => InvestorSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InvestorSearchResponse copyWith(void Function(InvestorSearchResponse) updates) => super.copyWith((message) => updates(message as InvestorSearchResponse)) as InvestorSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvestorSearchResponse create() => InvestorSearchResponse._();
  InvestorSearchResponse createEmptyInstance() => create();
  static $pb.PbList<InvestorSearchResponse> createRepeated() => $pb.PbList<InvestorSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static InvestorSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InvestorSearchResponse>(create);
  static InvestorSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<InvestorObject> get data => $_getList(0);
}

/// Workforce member messages
class WorkforceMemberSaveRequest extends $pb.GeneratedMessage {
  factory WorkforceMemberSaveRequest({
    WorkforceMemberObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  WorkforceMemberSaveRequest._() : super();
  factory WorkforceMemberSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WorkforceMemberSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WorkforceMemberSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<WorkforceMemberObject>(1, _omitFieldNames ? '' : 'data', subBuilder: WorkforceMemberObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WorkforceMemberSaveRequest clone() => WorkforceMemberSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WorkforceMemberSaveRequest copyWith(void Function(WorkforceMemberSaveRequest) updates) => super.copyWith((message) => updates(message as WorkforceMemberSaveRequest)) as WorkforceMemberSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSaveRequest create() => WorkforceMemberSaveRequest._();
  WorkforceMemberSaveRequest createEmptyInstance() => create();
  static $pb.PbList<WorkforceMemberSaveRequest> createRepeated() => $pb.PbList<WorkforceMemberSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkforceMemberSaveRequest>(create);
  static WorkforceMemberSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  WorkforceMemberObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WorkforceMemberObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  WorkforceMemberObject ensureData() => $_ensure(0);
}

class WorkforceMemberSaveResponse extends $pb.GeneratedMessage {
  factory WorkforceMemberSaveResponse({
    WorkforceMemberObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  WorkforceMemberSaveResponse._() : super();
  factory WorkforceMemberSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WorkforceMemberSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WorkforceMemberSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<WorkforceMemberObject>(1, _omitFieldNames ? '' : 'data', subBuilder: WorkforceMemberObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WorkforceMemberSaveResponse clone() => WorkforceMemberSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WorkforceMemberSaveResponse copyWith(void Function(WorkforceMemberSaveResponse) updates) => super.copyWith((message) => updates(message as WorkforceMemberSaveResponse)) as WorkforceMemberSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSaveResponse create() => WorkforceMemberSaveResponse._();
  WorkforceMemberSaveResponse createEmptyInstance() => create();
  static $pb.PbList<WorkforceMemberSaveResponse> createRepeated() => $pb.PbList<WorkforceMemberSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkforceMemberSaveResponse>(create);
  static WorkforceMemberSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WorkforceMemberObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WorkforceMemberObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  WorkforceMemberObject ensureData() => $_ensure(0);
}

class WorkforceMemberGetRequest extends $pb.GeneratedMessage {
  factory WorkforceMemberGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  WorkforceMemberGetRequest._() : super();
  factory WorkforceMemberGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WorkforceMemberGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WorkforceMemberGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WorkforceMemberGetRequest clone() => WorkforceMemberGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WorkforceMemberGetRequest copyWith(void Function(WorkforceMemberGetRequest) updates) => super.copyWith((message) => updates(message as WorkforceMemberGetRequest)) as WorkforceMemberGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkforceMemberGetRequest create() => WorkforceMemberGetRequest._();
  WorkforceMemberGetRequest createEmptyInstance() => create();
  static $pb.PbList<WorkforceMemberGetRequest> createRepeated() => $pb.PbList<WorkforceMemberGetRequest>();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkforceMemberGetRequest>(create);
  static WorkforceMemberGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class WorkforceMemberGetResponse extends $pb.GeneratedMessage {
  factory WorkforceMemberGetResponse({
    WorkforceMemberObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  WorkforceMemberGetResponse._() : super();
  factory WorkforceMemberGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WorkforceMemberGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WorkforceMemberGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<WorkforceMemberObject>(1, _omitFieldNames ? '' : 'data', subBuilder: WorkforceMemberObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WorkforceMemberGetResponse clone() => WorkforceMemberGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WorkforceMemberGetResponse copyWith(void Function(WorkforceMemberGetResponse) updates) => super.copyWith((message) => updates(message as WorkforceMemberGetResponse)) as WorkforceMemberGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkforceMemberGetResponse create() => WorkforceMemberGetResponse._();
  WorkforceMemberGetResponse createEmptyInstance() => create();
  static $pb.PbList<WorkforceMemberGetResponse> createRepeated() => $pb.PbList<WorkforceMemberGetResponse>();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkforceMemberGetResponse>(create);
  static WorkforceMemberGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WorkforceMemberObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(WorkforceMemberObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  WorkforceMemberObject ensureData() => $_ensure(0);
}

class WorkforceMemberSearchRequest extends $pb.GeneratedMessage {
  factory WorkforceMemberSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    $core.String? homeOrgUnitId,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (homeOrgUnitId != null) {
      $result.homeOrgUnitId = homeOrgUnitId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  WorkforceMemberSearchRequest._() : super();
  factory WorkforceMemberSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WorkforceMemberSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WorkforceMemberSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'homeOrgUnitId')
    ..aOM<$7.PageCursor>(4, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WorkforceMemberSearchRequest clone() => WorkforceMemberSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WorkforceMemberSearchRequest copyWith(void Function(WorkforceMemberSearchRequest) updates) => super.copyWith((message) => updates(message as WorkforceMemberSearchRequest)) as WorkforceMemberSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSearchRequest create() => WorkforceMemberSearchRequest._();
  WorkforceMemberSearchRequest createEmptyInstance() => create();
  static $pb.PbList<WorkforceMemberSearchRequest> createRepeated() => $pb.PbList<WorkforceMemberSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkforceMemberSearchRequest>(create);
  static WorkforceMemberSearchRequest? _defaultInstance;

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
  $core.String get homeOrgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set homeOrgUnitId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHomeOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearHomeOrgUnitId() => clearField(3);

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
}

class WorkforceMemberSearchResponse extends $pb.GeneratedMessage {
  factory WorkforceMemberSearchResponse({
    $core.Iterable<WorkforceMemberObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  WorkforceMemberSearchResponse._() : super();
  factory WorkforceMemberSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WorkforceMemberSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WorkforceMemberSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<WorkforceMemberObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: WorkforceMemberObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WorkforceMemberSearchResponse clone() => WorkforceMemberSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WorkforceMemberSearchResponse copyWith(void Function(WorkforceMemberSearchResponse) updates) => super.copyWith((message) => updates(message as WorkforceMemberSearchResponse)) as WorkforceMemberSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSearchResponse create() => WorkforceMemberSearchResponse._();
  WorkforceMemberSearchResponse createEmptyInstance() => create();
  static $pb.PbList<WorkforceMemberSearchResponse> createRepeated() => $pb.PbList<WorkforceMemberSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static WorkforceMemberSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkforceMemberSearchResponse>(create);
  static WorkforceMemberSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<WorkforceMemberObject> get data => $_getList(0);
}

/// Department messages
class DepartmentSaveRequest extends $pb.GeneratedMessage {
  factory DepartmentSaveRequest({
    DepartmentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  DepartmentSaveRequest._() : super();
  factory DepartmentSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepartmentSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepartmentSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<DepartmentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: DepartmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepartmentSaveRequest clone() => DepartmentSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepartmentSaveRequest copyWith(void Function(DepartmentSaveRequest) updates) => super.copyWith((message) => updates(message as DepartmentSaveRequest)) as DepartmentSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepartmentSaveRequest create() => DepartmentSaveRequest._();
  DepartmentSaveRequest createEmptyInstance() => create();
  static $pb.PbList<DepartmentSaveRequest> createRepeated() => $pb.PbList<DepartmentSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static DepartmentSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepartmentSaveRequest>(create);
  static DepartmentSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  DepartmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DepartmentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  DepartmentObject ensureData() => $_ensure(0);
}

class DepartmentSaveResponse extends $pb.GeneratedMessage {
  factory DepartmentSaveResponse({
    DepartmentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  DepartmentSaveResponse._() : super();
  factory DepartmentSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepartmentSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepartmentSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<DepartmentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: DepartmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepartmentSaveResponse clone() => DepartmentSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepartmentSaveResponse copyWith(void Function(DepartmentSaveResponse) updates) => super.copyWith((message) => updates(message as DepartmentSaveResponse)) as DepartmentSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepartmentSaveResponse create() => DepartmentSaveResponse._();
  DepartmentSaveResponse createEmptyInstance() => create();
  static $pb.PbList<DepartmentSaveResponse> createRepeated() => $pb.PbList<DepartmentSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static DepartmentSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepartmentSaveResponse>(create);
  static DepartmentSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DepartmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DepartmentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  DepartmentObject ensureData() => $_ensure(0);
}

class DepartmentGetRequest extends $pb.GeneratedMessage {
  factory DepartmentGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DepartmentGetRequest._() : super();
  factory DepartmentGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepartmentGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepartmentGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepartmentGetRequest clone() => DepartmentGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepartmentGetRequest copyWith(void Function(DepartmentGetRequest) updates) => super.copyWith((message) => updates(message as DepartmentGetRequest)) as DepartmentGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepartmentGetRequest create() => DepartmentGetRequest._();
  DepartmentGetRequest createEmptyInstance() => create();
  static $pb.PbList<DepartmentGetRequest> createRepeated() => $pb.PbList<DepartmentGetRequest>();
  @$core.pragma('dart2js:noInline')
  static DepartmentGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepartmentGetRequest>(create);
  static DepartmentGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class DepartmentGetResponse extends $pb.GeneratedMessage {
  factory DepartmentGetResponse({
    DepartmentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  DepartmentGetResponse._() : super();
  factory DepartmentGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepartmentGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepartmentGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<DepartmentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: DepartmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepartmentGetResponse clone() => DepartmentGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepartmentGetResponse copyWith(void Function(DepartmentGetResponse) updates) => super.copyWith((message) => updates(message as DepartmentGetResponse)) as DepartmentGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepartmentGetResponse create() => DepartmentGetResponse._();
  DepartmentGetResponse createEmptyInstance() => create();
  static $pb.PbList<DepartmentGetResponse> createRepeated() => $pb.PbList<DepartmentGetResponse>();
  @$core.pragma('dart2js:noInline')
  static DepartmentGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepartmentGetResponse>(create);
  static DepartmentGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DepartmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(DepartmentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  DepartmentObject ensureData() => $_ensure(0);
}

class DepartmentSearchRequest extends $pb.GeneratedMessage {
  factory DepartmentSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    $core.String? parentId,
    DepartmentKind? kind,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (parentId != null) {
      $result.parentId = parentId;
    }
    if (kind != null) {
      $result.kind = kind;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  DepartmentSearchRequest._() : super();
  factory DepartmentSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepartmentSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepartmentSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..e<DepartmentKind>(4, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE, defaultOrMaker: DepartmentKind.DEPARTMENT_KIND_UNSPECIFIED, valueOf: DepartmentKind.valueOf, enumValues: DepartmentKind.values)
    ..aOM<$7.PageCursor>(5, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepartmentSearchRequest clone() => DepartmentSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepartmentSearchRequest copyWith(void Function(DepartmentSearchRequest) updates) => super.copyWith((message) => updates(message as DepartmentSearchRequest)) as DepartmentSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepartmentSearchRequest create() => DepartmentSearchRequest._();
  DepartmentSearchRequest createEmptyInstance() => create();
  static $pb.PbList<DepartmentSearchRequest> createRepeated() => $pb.PbList<DepartmentSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static DepartmentSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepartmentSearchRequest>(create);
  static DepartmentSearchRequest? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => clearField(3);

  @$pb.TagNumber(4)
  DepartmentKind get kind => $_getN(3);
  @$pb.TagNumber(4)
  set kind(DepartmentKind v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearKind() => clearField(4);

  @$pb.TagNumber(5)
  $7.PageCursor get cursor => $_getN(4);
  @$pb.TagNumber(5)
  set cursor($7.PageCursor v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasCursor() => $_has(4);
  @$pb.TagNumber(5)
  void clearCursor() => clearField(5);
  @$pb.TagNumber(5)
  $7.PageCursor ensureCursor() => $_ensure(4);
}

class DepartmentSearchResponse extends $pb.GeneratedMessage {
  factory DepartmentSearchResponse({
    $core.Iterable<DepartmentObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  DepartmentSearchResponse._() : super();
  factory DepartmentSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DepartmentSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DepartmentSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<DepartmentObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: DepartmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DepartmentSearchResponse clone() => DepartmentSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DepartmentSearchResponse copyWith(void Function(DepartmentSearchResponse) updates) => super.copyWith((message) => updates(message as DepartmentSearchResponse)) as DepartmentSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DepartmentSearchResponse create() => DepartmentSearchResponse._();
  DepartmentSearchResponse createEmptyInstance() => create();
  static $pb.PbList<DepartmentSearchResponse> createRepeated() => $pb.PbList<DepartmentSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static DepartmentSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DepartmentSearchResponse>(create);
  static DepartmentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<DepartmentObject> get data => $_getList(0);
}

/// Position messages
class PositionSaveRequest extends $pb.GeneratedMessage {
  factory PositionSaveRequest({
    PositionObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PositionSaveRequest._() : super();
  factory PositionSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<PositionObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PositionObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionSaveRequest clone() => PositionSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionSaveRequest copyWith(void Function(PositionSaveRequest) updates) => super.copyWith((message) => updates(message as PositionSaveRequest)) as PositionSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionSaveRequest create() => PositionSaveRequest._();
  PositionSaveRequest createEmptyInstance() => create();
  static $pb.PbList<PositionSaveRequest> createRepeated() => $pb.PbList<PositionSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static PositionSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionSaveRequest>(create);
  static PositionSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PositionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  PositionObject ensureData() => $_ensure(0);
}

class PositionSaveResponse extends $pb.GeneratedMessage {
  factory PositionSaveResponse({
    PositionObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PositionSaveResponse._() : super();
  factory PositionSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<PositionObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PositionObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionSaveResponse clone() => PositionSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionSaveResponse copyWith(void Function(PositionSaveResponse) updates) => super.copyWith((message) => updates(message as PositionSaveResponse)) as PositionSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionSaveResponse create() => PositionSaveResponse._();
  PositionSaveResponse createEmptyInstance() => create();
  static $pb.PbList<PositionSaveResponse> createRepeated() => $pb.PbList<PositionSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static PositionSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionSaveResponse>(create);
  static PositionSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PositionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  PositionObject ensureData() => $_ensure(0);
}

class PositionGetRequest extends $pb.GeneratedMessage {
  factory PositionGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  PositionGetRequest._() : super();
  factory PositionGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionGetRequest clone() => PositionGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionGetRequest copyWith(void Function(PositionGetRequest) updates) => super.copyWith((message) => updates(message as PositionGetRequest)) as PositionGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionGetRequest create() => PositionGetRequest._();
  PositionGetRequest createEmptyInstance() => create();
  static $pb.PbList<PositionGetRequest> createRepeated() => $pb.PbList<PositionGetRequest>();
  @$core.pragma('dart2js:noInline')
  static PositionGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionGetRequest>(create);
  static PositionGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class PositionGetResponse extends $pb.GeneratedMessage {
  factory PositionGetResponse({
    PositionObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PositionGetResponse._() : super();
  factory PositionGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<PositionObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PositionObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionGetResponse clone() => PositionGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionGetResponse copyWith(void Function(PositionGetResponse) updates) => super.copyWith((message) => updates(message as PositionGetResponse)) as PositionGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionGetResponse create() => PositionGetResponse._();
  PositionGetResponse createEmptyInstance() => create();
  static $pb.PbList<PositionGetResponse> createRepeated() => $pb.PbList<PositionGetResponse>();
  @$core.pragma('dart2js:noInline')
  static PositionGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionGetResponse>(create);
  static PositionGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PositionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
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
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (orgUnitId != null) {
      $result.orgUnitId = orgUnitId;
    }
    if (departmentId != null) {
      $result.departmentId = departmentId;
    }
    if (reportsToPositionId != null) {
      $result.reportsToPositionId = reportsToPositionId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  PositionSearchRequest._() : super();
  factory PositionSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'orgUnitId')
    ..aOS(4, _omitFieldNames ? '' : 'departmentId')
    ..aOS(5, _omitFieldNames ? '' : 'reportsToPositionId')
    ..aOM<$7.PageCursor>(6, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionSearchRequest clone() => PositionSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionSearchRequest copyWith(void Function(PositionSearchRequest) updates) => super.copyWith((message) => updates(message as PositionSearchRequest)) as PositionSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionSearchRequest create() => PositionSearchRequest._();
  PositionSearchRequest createEmptyInstance() => create();
  static $pb.PbList<PositionSearchRequest> createRepeated() => $pb.PbList<PositionSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static PositionSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionSearchRequest>(create);
  static PositionSearchRequest? _defaultInstance;

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
  $core.String get orgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set orgUnitId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrgUnitId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get departmentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set departmentId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDepartmentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDepartmentId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get reportsToPositionId => $_getSZ(4);
  @$pb.TagNumber(5)
  set reportsToPositionId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReportsToPositionId() => $_has(4);
  @$pb.TagNumber(5)
  void clearReportsToPositionId() => clearField(5);

  @$pb.TagNumber(6)
  $7.PageCursor get cursor => $_getN(5);
  @$pb.TagNumber(6)
  set cursor($7.PageCursor v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearCursor() => clearField(6);
  @$pb.TagNumber(6)
  $7.PageCursor ensureCursor() => $_ensure(5);
}

class PositionSearchResponse extends $pb.GeneratedMessage {
  factory PositionSearchResponse({
    $core.Iterable<PositionObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  PositionSearchResponse._() : super();
  factory PositionSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<PositionObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: PositionObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionSearchResponse clone() => PositionSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionSearchResponse copyWith(void Function(PositionSearchResponse) updates) => super.copyWith((message) => updates(message as PositionSearchResponse)) as PositionSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionSearchResponse create() => PositionSearchResponse._();
  PositionSearchResponse createEmptyInstance() => create();
  static $pb.PbList<PositionSearchResponse> createRepeated() => $pb.PbList<PositionSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static PositionSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionSearchResponse>(create);
  static PositionSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PositionObject> get data => $_getList(0);
}

/// Position assignment messages
class PositionAssignmentSaveRequest extends $pb.GeneratedMessage {
  factory PositionAssignmentSaveRequest({
    PositionAssignmentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PositionAssignmentSaveRequest._() : super();
  factory PositionAssignmentSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionAssignmentSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionAssignmentSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<PositionAssignmentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PositionAssignmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionAssignmentSaveRequest clone() => PositionAssignmentSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionAssignmentSaveRequest copyWith(void Function(PositionAssignmentSaveRequest) updates) => super.copyWith((message) => updates(message as PositionAssignmentSaveRequest)) as PositionAssignmentSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSaveRequest create() => PositionAssignmentSaveRequest._();
  PositionAssignmentSaveRequest createEmptyInstance() => create();
  static $pb.PbList<PositionAssignmentSaveRequest> createRepeated() => $pb.PbList<PositionAssignmentSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionAssignmentSaveRequest>(create);
  static PositionAssignmentSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PositionAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionAssignmentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  PositionAssignmentObject ensureData() => $_ensure(0);
}

class PositionAssignmentSaveResponse extends $pb.GeneratedMessage {
  factory PositionAssignmentSaveResponse({
    PositionAssignmentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PositionAssignmentSaveResponse._() : super();
  factory PositionAssignmentSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionAssignmentSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionAssignmentSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<PositionAssignmentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PositionAssignmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionAssignmentSaveResponse clone() => PositionAssignmentSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionAssignmentSaveResponse copyWith(void Function(PositionAssignmentSaveResponse) updates) => super.copyWith((message) => updates(message as PositionAssignmentSaveResponse)) as PositionAssignmentSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSaveResponse create() => PositionAssignmentSaveResponse._();
  PositionAssignmentSaveResponse createEmptyInstance() => create();
  static $pb.PbList<PositionAssignmentSaveResponse> createRepeated() => $pb.PbList<PositionAssignmentSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionAssignmentSaveResponse>(create);
  static PositionAssignmentSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PositionAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionAssignmentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  PositionAssignmentObject ensureData() => $_ensure(0);
}

class PositionAssignmentGetRequest extends $pb.GeneratedMessage {
  factory PositionAssignmentGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  PositionAssignmentGetRequest._() : super();
  factory PositionAssignmentGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionAssignmentGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionAssignmentGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionAssignmentGetRequest clone() => PositionAssignmentGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionAssignmentGetRequest copyWith(void Function(PositionAssignmentGetRequest) updates) => super.copyWith((message) => updates(message as PositionAssignmentGetRequest)) as PositionAssignmentGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionAssignmentGetRequest create() => PositionAssignmentGetRequest._();
  PositionAssignmentGetRequest createEmptyInstance() => create();
  static $pb.PbList<PositionAssignmentGetRequest> createRepeated() => $pb.PbList<PositionAssignmentGetRequest>();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionAssignmentGetRequest>(create);
  static PositionAssignmentGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class PositionAssignmentGetResponse extends $pb.GeneratedMessage {
  factory PositionAssignmentGetResponse({
    PositionAssignmentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PositionAssignmentGetResponse._() : super();
  factory PositionAssignmentGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionAssignmentGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionAssignmentGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<PositionAssignmentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: PositionAssignmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionAssignmentGetResponse clone() => PositionAssignmentGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionAssignmentGetResponse copyWith(void Function(PositionAssignmentGetResponse) updates) => super.copyWith((message) => updates(message as PositionAssignmentGetResponse)) as PositionAssignmentGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionAssignmentGetResponse create() => PositionAssignmentGetResponse._();
  PositionAssignmentGetResponse createEmptyInstance() => create();
  static $pb.PbList<PositionAssignmentGetResponse> createRepeated() => $pb.PbList<PositionAssignmentGetResponse>();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionAssignmentGetResponse>(create);
  static PositionAssignmentGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PositionAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(PositionAssignmentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  PositionAssignmentObject ensureData() => $_ensure(0);
}

class PositionAssignmentSearchRequest extends $pb.GeneratedMessage {
  factory PositionAssignmentSearchRequest({
    $core.String? query,
    $core.String? memberId,
    $core.String? positionId,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (memberId != null) {
      $result.memberId = memberId;
    }
    if (positionId != null) {
      $result.positionId = positionId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  PositionAssignmentSearchRequest._() : super();
  factory PositionAssignmentSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionAssignmentSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionAssignmentSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'memberId')
    ..aOS(3, _omitFieldNames ? '' : 'positionId')
    ..aOM<$7.PageCursor>(4, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionAssignmentSearchRequest clone() => PositionAssignmentSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionAssignmentSearchRequest copyWith(void Function(PositionAssignmentSearchRequest) updates) => super.copyWith((message) => updates(message as PositionAssignmentSearchRequest)) as PositionAssignmentSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSearchRequest create() => PositionAssignmentSearchRequest._();
  PositionAssignmentSearchRequest createEmptyInstance() => create();
  static $pb.PbList<PositionAssignmentSearchRequest> createRepeated() => $pb.PbList<PositionAssignmentSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionAssignmentSearchRequest>(create);
  static PositionAssignmentSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get memberId => $_getSZ(1);
  @$pb.TagNumber(2)
  set memberId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get positionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set positionId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPositionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPositionId() => clearField(3);

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
}

class PositionAssignmentSearchResponse extends $pb.GeneratedMessage {
  factory PositionAssignmentSearchResponse({
    $core.Iterable<PositionAssignmentObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  PositionAssignmentSearchResponse._() : super();
  factory PositionAssignmentSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PositionAssignmentSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PositionAssignmentSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<PositionAssignmentObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: PositionAssignmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PositionAssignmentSearchResponse clone() => PositionAssignmentSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PositionAssignmentSearchResponse copyWith(void Function(PositionAssignmentSearchResponse) updates) => super.copyWith((message) => updates(message as PositionAssignmentSearchResponse)) as PositionAssignmentSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSearchResponse create() => PositionAssignmentSearchResponse._();
  PositionAssignmentSearchResponse createEmptyInstance() => create();
  static $pb.PbList<PositionAssignmentSearchResponse> createRepeated() => $pb.PbList<PositionAssignmentSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static PositionAssignmentSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionAssignmentSearchResponse>(create);
  static PositionAssignmentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PositionAssignmentObject> get data => $_getList(0);
}

/// Internal team messages
class InternalTeamSaveRequest extends $pb.GeneratedMessage {
  factory InternalTeamSaveRequest({
    InternalTeamObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InternalTeamSaveRequest._() : super();
  factory InternalTeamSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InternalTeamSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InternalTeamSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<InternalTeamObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InternalTeamObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InternalTeamSaveRequest clone() => InternalTeamSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InternalTeamSaveRequest copyWith(void Function(InternalTeamSaveRequest) updates) => super.copyWith((message) => updates(message as InternalTeamSaveRequest)) as InternalTeamSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InternalTeamSaveRequest create() => InternalTeamSaveRequest._();
  InternalTeamSaveRequest createEmptyInstance() => create();
  static $pb.PbList<InternalTeamSaveRequest> createRepeated() => $pb.PbList<InternalTeamSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static InternalTeamSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InternalTeamSaveRequest>(create);
  static InternalTeamSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  InternalTeamObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InternalTeamObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InternalTeamObject ensureData() => $_ensure(0);
}

class InternalTeamSaveResponse extends $pb.GeneratedMessage {
  factory InternalTeamSaveResponse({
    InternalTeamObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InternalTeamSaveResponse._() : super();
  factory InternalTeamSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InternalTeamSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InternalTeamSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<InternalTeamObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InternalTeamObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InternalTeamSaveResponse clone() => InternalTeamSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InternalTeamSaveResponse copyWith(void Function(InternalTeamSaveResponse) updates) => super.copyWith((message) => updates(message as InternalTeamSaveResponse)) as InternalTeamSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InternalTeamSaveResponse create() => InternalTeamSaveResponse._();
  InternalTeamSaveResponse createEmptyInstance() => create();
  static $pb.PbList<InternalTeamSaveResponse> createRepeated() => $pb.PbList<InternalTeamSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static InternalTeamSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InternalTeamSaveResponse>(create);
  static InternalTeamSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InternalTeamObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InternalTeamObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InternalTeamObject ensureData() => $_ensure(0);
}

class InternalTeamGetRequest extends $pb.GeneratedMessage {
  factory InternalTeamGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  InternalTeamGetRequest._() : super();
  factory InternalTeamGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InternalTeamGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InternalTeamGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InternalTeamGetRequest clone() => InternalTeamGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InternalTeamGetRequest copyWith(void Function(InternalTeamGetRequest) updates) => super.copyWith((message) => updates(message as InternalTeamGetRequest)) as InternalTeamGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InternalTeamGetRequest create() => InternalTeamGetRequest._();
  InternalTeamGetRequest createEmptyInstance() => create();
  static $pb.PbList<InternalTeamGetRequest> createRepeated() => $pb.PbList<InternalTeamGetRequest>();
  @$core.pragma('dart2js:noInline')
  static InternalTeamGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InternalTeamGetRequest>(create);
  static InternalTeamGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class InternalTeamGetResponse extends $pb.GeneratedMessage {
  factory InternalTeamGetResponse({
    InternalTeamObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  InternalTeamGetResponse._() : super();
  factory InternalTeamGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InternalTeamGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InternalTeamGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<InternalTeamObject>(1, _omitFieldNames ? '' : 'data', subBuilder: InternalTeamObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InternalTeamGetResponse clone() => InternalTeamGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InternalTeamGetResponse copyWith(void Function(InternalTeamGetResponse) updates) => super.copyWith((message) => updates(message as InternalTeamGetResponse)) as InternalTeamGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InternalTeamGetResponse create() => InternalTeamGetResponse._();
  InternalTeamGetResponse createEmptyInstance() => create();
  static $pb.PbList<InternalTeamGetResponse> createRepeated() => $pb.PbList<InternalTeamGetResponse>();
  @$core.pragma('dart2js:noInline')
  static InternalTeamGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InternalTeamGetResponse>(create);
  static InternalTeamGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InternalTeamObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(InternalTeamObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  InternalTeamObject ensureData() => $_ensure(0);
}

class InternalTeamSearchRequest extends $pb.GeneratedMessage {
  factory InternalTeamSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    $core.String? homeOrgUnitId,
    $core.String? teamType,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (organizationId != null) {
      $result.organizationId = organizationId;
    }
    if (homeOrgUnitId != null) {
      $result.homeOrgUnitId = homeOrgUnitId;
    }
    if (teamType != null) {
      $result.teamType = teamType;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  InternalTeamSearchRequest._() : super();
  factory InternalTeamSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InternalTeamSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InternalTeamSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'homeOrgUnitId')
    ..aOS(4, _omitFieldNames ? '' : 'teamType')
    ..aOM<$7.PageCursor>(5, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InternalTeamSearchRequest clone() => InternalTeamSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InternalTeamSearchRequest copyWith(void Function(InternalTeamSearchRequest) updates) => super.copyWith((message) => updates(message as InternalTeamSearchRequest)) as InternalTeamSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InternalTeamSearchRequest create() => InternalTeamSearchRequest._();
  InternalTeamSearchRequest createEmptyInstance() => create();
  static $pb.PbList<InternalTeamSearchRequest> createRepeated() => $pb.PbList<InternalTeamSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static InternalTeamSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InternalTeamSearchRequest>(create);
  static InternalTeamSearchRequest? _defaultInstance;

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
  $core.String get homeOrgUnitId => $_getSZ(2);
  @$pb.TagNumber(3)
  set homeOrgUnitId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHomeOrgUnitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearHomeOrgUnitId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get teamType => $_getSZ(3);
  @$pb.TagNumber(4)
  set teamType($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTeamType() => $_has(3);
  @$pb.TagNumber(4)
  void clearTeamType() => clearField(4);

  @$pb.TagNumber(5)
  $7.PageCursor get cursor => $_getN(4);
  @$pb.TagNumber(5)
  set cursor($7.PageCursor v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasCursor() => $_has(4);
  @$pb.TagNumber(5)
  void clearCursor() => clearField(5);
  @$pb.TagNumber(5)
  $7.PageCursor ensureCursor() => $_ensure(4);
}

class InternalTeamSearchResponse extends $pb.GeneratedMessage {
  factory InternalTeamSearchResponse({
    $core.Iterable<InternalTeamObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  InternalTeamSearchResponse._() : super();
  factory InternalTeamSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InternalTeamSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InternalTeamSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<InternalTeamObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: InternalTeamObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InternalTeamSearchResponse clone() => InternalTeamSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InternalTeamSearchResponse copyWith(void Function(InternalTeamSearchResponse) updates) => super.copyWith((message) => updates(message as InternalTeamSearchResponse)) as InternalTeamSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InternalTeamSearchResponse create() => InternalTeamSearchResponse._();
  InternalTeamSearchResponse createEmptyInstance() => create();
  static $pb.PbList<InternalTeamSearchResponse> createRepeated() => $pb.PbList<InternalTeamSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static InternalTeamSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InternalTeamSearchResponse>(create);
  static InternalTeamSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<InternalTeamObject> get data => $_getList(0);
}

/// Team membership messages
class TeamMembershipSaveRequest extends $pb.GeneratedMessage {
  factory TeamMembershipSaveRequest({
    TeamMembershipObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  TeamMembershipSaveRequest._() : super();
  factory TeamMembershipSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TeamMembershipSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TeamMembershipSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<TeamMembershipObject>(1, _omitFieldNames ? '' : 'data', subBuilder: TeamMembershipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TeamMembershipSaveRequest clone() => TeamMembershipSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TeamMembershipSaveRequest copyWith(void Function(TeamMembershipSaveRequest) updates) => super.copyWith((message) => updates(message as TeamMembershipSaveRequest)) as TeamMembershipSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamMembershipSaveRequest create() => TeamMembershipSaveRequest._();
  TeamMembershipSaveRequest createEmptyInstance() => create();
  static $pb.PbList<TeamMembershipSaveRequest> createRepeated() => $pb.PbList<TeamMembershipSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TeamMembershipSaveRequest>(create);
  static TeamMembershipSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  TeamMembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(TeamMembershipObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  TeamMembershipObject ensureData() => $_ensure(0);
}

class TeamMembershipSaveResponse extends $pb.GeneratedMessage {
  factory TeamMembershipSaveResponse({
    TeamMembershipObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  TeamMembershipSaveResponse._() : super();
  factory TeamMembershipSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TeamMembershipSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TeamMembershipSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<TeamMembershipObject>(1, _omitFieldNames ? '' : 'data', subBuilder: TeamMembershipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TeamMembershipSaveResponse clone() => TeamMembershipSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TeamMembershipSaveResponse copyWith(void Function(TeamMembershipSaveResponse) updates) => super.copyWith((message) => updates(message as TeamMembershipSaveResponse)) as TeamMembershipSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamMembershipSaveResponse create() => TeamMembershipSaveResponse._();
  TeamMembershipSaveResponse createEmptyInstance() => create();
  static $pb.PbList<TeamMembershipSaveResponse> createRepeated() => $pb.PbList<TeamMembershipSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TeamMembershipSaveResponse>(create);
  static TeamMembershipSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TeamMembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(TeamMembershipObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  TeamMembershipObject ensureData() => $_ensure(0);
}

class TeamMembershipGetRequest extends $pb.GeneratedMessage {
  factory TeamMembershipGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  TeamMembershipGetRequest._() : super();
  factory TeamMembershipGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TeamMembershipGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TeamMembershipGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TeamMembershipGetRequest clone() => TeamMembershipGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TeamMembershipGetRequest copyWith(void Function(TeamMembershipGetRequest) updates) => super.copyWith((message) => updates(message as TeamMembershipGetRequest)) as TeamMembershipGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamMembershipGetRequest create() => TeamMembershipGetRequest._();
  TeamMembershipGetRequest createEmptyInstance() => create();
  static $pb.PbList<TeamMembershipGetRequest> createRepeated() => $pb.PbList<TeamMembershipGetRequest>();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TeamMembershipGetRequest>(create);
  static TeamMembershipGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class TeamMembershipGetResponse extends $pb.GeneratedMessage {
  factory TeamMembershipGetResponse({
    TeamMembershipObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  TeamMembershipGetResponse._() : super();
  factory TeamMembershipGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TeamMembershipGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TeamMembershipGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<TeamMembershipObject>(1, _omitFieldNames ? '' : 'data', subBuilder: TeamMembershipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TeamMembershipGetResponse clone() => TeamMembershipGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TeamMembershipGetResponse copyWith(void Function(TeamMembershipGetResponse) updates) => super.copyWith((message) => updates(message as TeamMembershipGetResponse)) as TeamMembershipGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamMembershipGetResponse create() => TeamMembershipGetResponse._();
  TeamMembershipGetResponse createEmptyInstance() => create();
  static $pb.PbList<TeamMembershipGetResponse> createRepeated() => $pb.PbList<TeamMembershipGetResponse>();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TeamMembershipGetResponse>(create);
  static TeamMembershipGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TeamMembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(TeamMembershipObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  TeamMembershipObject ensureData() => $_ensure(0);
}

class TeamMembershipSearchRequest extends $pb.GeneratedMessage {
  factory TeamMembershipSearchRequest({
    $core.String? query,
    $core.String? teamId,
    $core.String? memberId,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (teamId != null) {
      $result.teamId = teamId;
    }
    if (memberId != null) {
      $result.memberId = memberId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  TeamMembershipSearchRequest._() : super();
  factory TeamMembershipSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TeamMembershipSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TeamMembershipSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'teamId')
    ..aOS(3, _omitFieldNames ? '' : 'memberId')
    ..aOM<$7.PageCursor>(4, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TeamMembershipSearchRequest clone() => TeamMembershipSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TeamMembershipSearchRequest copyWith(void Function(TeamMembershipSearchRequest) updates) => super.copyWith((message) => updates(message as TeamMembershipSearchRequest)) as TeamMembershipSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamMembershipSearchRequest create() => TeamMembershipSearchRequest._();
  TeamMembershipSearchRequest createEmptyInstance() => create();
  static $pb.PbList<TeamMembershipSearchRequest> createRepeated() => $pb.PbList<TeamMembershipSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TeamMembershipSearchRequest>(create);
  static TeamMembershipSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get teamId => $_getSZ(1);
  @$pb.TagNumber(2)
  set teamId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTeamId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTeamId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get memberId => $_getSZ(2);
  @$pb.TagNumber(3)
  set memberId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMemberId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberId() => clearField(3);

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
}

class TeamMembershipSearchResponse extends $pb.GeneratedMessage {
  factory TeamMembershipSearchResponse({
    $core.Iterable<TeamMembershipObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  TeamMembershipSearchResponse._() : super();
  factory TeamMembershipSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TeamMembershipSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TeamMembershipSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<TeamMembershipObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: TeamMembershipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TeamMembershipSearchResponse clone() => TeamMembershipSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TeamMembershipSearchResponse copyWith(void Function(TeamMembershipSearchResponse) updates) => super.copyWith((message) => updates(message as TeamMembershipSearchResponse)) as TeamMembershipSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamMembershipSearchResponse create() => TeamMembershipSearchResponse._();
  TeamMembershipSearchResponse createEmptyInstance() => create();
  static $pb.PbList<TeamMembershipSearchResponse> createRepeated() => $pb.PbList<TeamMembershipSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static TeamMembershipSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TeamMembershipSearchResponse>(create);
  static TeamMembershipSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<TeamMembershipObject> get data => $_getList(0);
}

/// Access role assignment messages
class AccessRoleAssignmentSaveRequest extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentSaveRequest({
    AccessRoleAssignmentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  AccessRoleAssignmentSaveRequest._() : super();
  factory AccessRoleAssignmentSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AccessRoleAssignmentSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AccessRoleAssignmentSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<AccessRoleAssignmentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: AccessRoleAssignmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentSaveRequest clone() => AccessRoleAssignmentSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentSaveRequest copyWith(void Function(AccessRoleAssignmentSaveRequest) updates) => super.copyWith((message) => updates(message as AccessRoleAssignmentSaveRequest)) as AccessRoleAssignmentSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSaveRequest create() => AccessRoleAssignmentSaveRequest._();
  AccessRoleAssignmentSaveRequest createEmptyInstance() => create();
  static $pb.PbList<AccessRoleAssignmentSaveRequest> createRepeated() => $pb.PbList<AccessRoleAssignmentSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentSaveRequest>(create);
  static AccessRoleAssignmentSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  AccessRoleAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AccessRoleAssignmentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  AccessRoleAssignmentObject ensureData() => $_ensure(0);
}

class AccessRoleAssignmentSaveResponse extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentSaveResponse({
    AccessRoleAssignmentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  AccessRoleAssignmentSaveResponse._() : super();
  factory AccessRoleAssignmentSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AccessRoleAssignmentSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AccessRoleAssignmentSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<AccessRoleAssignmentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: AccessRoleAssignmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentSaveResponse clone() => AccessRoleAssignmentSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentSaveResponse copyWith(void Function(AccessRoleAssignmentSaveResponse) updates) => super.copyWith((message) => updates(message as AccessRoleAssignmentSaveResponse)) as AccessRoleAssignmentSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSaveResponse create() => AccessRoleAssignmentSaveResponse._();
  AccessRoleAssignmentSaveResponse createEmptyInstance() => create();
  static $pb.PbList<AccessRoleAssignmentSaveResponse> createRepeated() => $pb.PbList<AccessRoleAssignmentSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentSaveResponse>(create);
  static AccessRoleAssignmentSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AccessRoleAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AccessRoleAssignmentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  AccessRoleAssignmentObject ensureData() => $_ensure(0);
}

class AccessRoleAssignmentGetRequest extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  AccessRoleAssignmentGetRequest._() : super();
  factory AccessRoleAssignmentGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AccessRoleAssignmentGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AccessRoleAssignmentGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentGetRequest clone() => AccessRoleAssignmentGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentGetRequest copyWith(void Function(AccessRoleAssignmentGetRequest) updates) => super.copyWith((message) => updates(message as AccessRoleAssignmentGetRequest)) as AccessRoleAssignmentGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentGetRequest create() => AccessRoleAssignmentGetRequest._();
  AccessRoleAssignmentGetRequest createEmptyInstance() => create();
  static $pb.PbList<AccessRoleAssignmentGetRequest> createRepeated() => $pb.PbList<AccessRoleAssignmentGetRequest>();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentGetRequest>(create);
  static AccessRoleAssignmentGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class AccessRoleAssignmentGetResponse extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentGetResponse({
    AccessRoleAssignmentObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  AccessRoleAssignmentGetResponse._() : super();
  factory AccessRoleAssignmentGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AccessRoleAssignmentGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AccessRoleAssignmentGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<AccessRoleAssignmentObject>(1, _omitFieldNames ? '' : 'data', subBuilder: AccessRoleAssignmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentGetResponse clone() => AccessRoleAssignmentGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentGetResponse copyWith(void Function(AccessRoleAssignmentGetResponse) updates) => super.copyWith((message) => updates(message as AccessRoleAssignmentGetResponse)) as AccessRoleAssignmentGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentGetResponse create() => AccessRoleAssignmentGetResponse._();
  AccessRoleAssignmentGetResponse createEmptyInstance() => create();
  static $pb.PbList<AccessRoleAssignmentGetResponse> createRepeated() => $pb.PbList<AccessRoleAssignmentGetResponse>();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentGetResponse>(create);
  static AccessRoleAssignmentGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AccessRoleAssignmentObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(AccessRoleAssignmentObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
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
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (memberId != null) {
      $result.memberId = memberId;
    }
    if (roleKey != null) {
      $result.roleKey = roleKey;
    }
    if (scopeType != null) {
      $result.scopeType = scopeType;
    }
    if (scopeId != null) {
      $result.scopeId = scopeId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  AccessRoleAssignmentSearchRequest._() : super();
  factory AccessRoleAssignmentSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AccessRoleAssignmentSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AccessRoleAssignmentSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'memberId')
    ..aOS(3, _omitFieldNames ? '' : 'roleKey')
    ..e<AccessScopeType>(4, _omitFieldNames ? '' : 'scopeType', $pb.PbFieldType.OE, defaultOrMaker: AccessScopeType.ACCESS_SCOPE_TYPE_UNSPECIFIED, valueOf: AccessScopeType.valueOf, enumValues: AccessScopeType.values)
    ..aOS(5, _omitFieldNames ? '' : 'scopeId')
    ..aOM<$7.PageCursor>(6, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentSearchRequest clone() => AccessRoleAssignmentSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentSearchRequest copyWith(void Function(AccessRoleAssignmentSearchRequest) updates) => super.copyWith((message) => updates(message as AccessRoleAssignmentSearchRequest)) as AccessRoleAssignmentSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSearchRequest create() => AccessRoleAssignmentSearchRequest._();
  AccessRoleAssignmentSearchRequest createEmptyInstance() => create();
  static $pb.PbList<AccessRoleAssignmentSearchRequest> createRepeated() => $pb.PbList<AccessRoleAssignmentSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentSearchRequest>(create);
  static AccessRoleAssignmentSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get memberId => $_getSZ(1);
  @$pb.TagNumber(2)
  set memberId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMemberId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get roleKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set roleKey($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRoleKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoleKey() => clearField(3);

  @$pb.TagNumber(4)
  AccessScopeType get scopeType => $_getN(3);
  @$pb.TagNumber(4)
  set scopeType(AccessScopeType v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasScopeType() => $_has(3);
  @$pb.TagNumber(4)
  void clearScopeType() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get scopeId => $_getSZ(4);
  @$pb.TagNumber(5)
  set scopeId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasScopeId() => $_has(4);
  @$pb.TagNumber(5)
  void clearScopeId() => clearField(5);

  @$pb.TagNumber(6)
  $7.PageCursor get cursor => $_getN(5);
  @$pb.TagNumber(6)
  set cursor($7.PageCursor v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearCursor() => clearField(6);
  @$pb.TagNumber(6)
  $7.PageCursor ensureCursor() => $_ensure(5);
}

class AccessRoleAssignmentSearchResponse extends $pb.GeneratedMessage {
  factory AccessRoleAssignmentSearchResponse({
    $core.Iterable<AccessRoleAssignmentObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  AccessRoleAssignmentSearchResponse._() : super();
  factory AccessRoleAssignmentSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AccessRoleAssignmentSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AccessRoleAssignmentSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<AccessRoleAssignmentObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: AccessRoleAssignmentObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentSearchResponse clone() => AccessRoleAssignmentSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AccessRoleAssignmentSearchResponse copyWith(void Function(AccessRoleAssignmentSearchResponse) updates) => super.copyWith((message) => updates(message as AccessRoleAssignmentSearchResponse)) as AccessRoleAssignmentSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSearchResponse create() => AccessRoleAssignmentSearchResponse._();
  AccessRoleAssignmentSearchResponse createEmptyInstance() => create();
  static $pb.PbList<AccessRoleAssignmentSearchResponse> createRepeated() => $pb.PbList<AccessRoleAssignmentSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static AccessRoleAssignmentSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccessRoleAssignmentSearchResponse>(create);
  static AccessRoleAssignmentSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<AccessRoleAssignmentObject> get data => $_getList(0);
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
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (productId != null) {
      $result.productId = productId;
    }
    if (parentId != null) {
      $result.parentId = parentId;
    }
    if (agentId != null) {
      $result.agentId = agentId;
    }
    if (branchId != null) {
      $result.branchId = branchId;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (groupType != null) {
      $result.groupType = groupType;
    }
    if (currencyCode != null) {
      $result.currencyCode = currencyCode;
    }
    if (savingAmount != null) {
      $result.savingAmount = savingAmount;
    }
    if (timeZone != null) {
      $result.timeZone = timeZone;
    }
    if (minMembers != null) {
      $result.minMembers = minMembers;
    }
    if (maxMembers != null) {
      $result.maxMembers = maxMembers;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  ClientGroupObject._() : super();
  factory ClientGroupObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientGroupObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientGroupObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aOS(4, _omitFieldNames ? '' : 'agentId')
    ..aOS(5, _omitFieldNames ? '' : 'branchId')
    ..aOS(6, _omitFieldNames ? '' : 'profileId')
    ..aOS(7, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'groupType', $pb.PbFieldType.O3)
    ..aOS(9, _omitFieldNames ? '' : 'currencyCode')
    ..aInt64(10, _omitFieldNames ? '' : 'savingAmount')
    ..aOS(11, _omitFieldNames ? '' : 'timeZone')
    ..a<$core.int>(12, _omitFieldNames ? '' : 'minMembers', $pb.PbFieldType.O3)
    ..a<$core.int>(13, _omitFieldNames ? '' : 'maxMembers', $pb.PbFieldType.O3)
    ..e<$7.STATE>(14, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(15, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientGroupObject clone() => ClientGroupObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientGroupObject copyWith(void Function(ClientGroupObject) updates) => super.copyWith((message) => updates(message as ClientGroupObject)) as ClientGroupObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientGroupObject create() => ClientGroupObject._();
  ClientGroupObject createEmptyInstance() => create();
  static $pb.PbList<ClientGroupObject> createRepeated() => $pb.PbList<ClientGroupObject>();
  @$core.pragma('dart2js:noInline')
  static ClientGroupObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGroupObject>(create);
  static ClientGroupObject? _defaultInstance;

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
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get agentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set agentId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAgentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAgentId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get branchId => $_getSZ(4);
  @$pb.TagNumber(5)
  set branchId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBranchId() => $_has(4);
  @$pb.TagNumber(5)
  void clearBranchId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get profileId => $_getSZ(5);
  @$pb.TagNumber(6)
  set profileId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasProfileId() => $_has(5);
  @$pb.TagNumber(6)
  void clearProfileId() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get name => $_getSZ(6);
  @$pb.TagNumber(7)
  set name($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasName() => $_has(6);
  @$pb.TagNumber(7)
  void clearName() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get groupType => $_getIZ(7);
  @$pb.TagNumber(8)
  set groupType($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasGroupType() => $_has(7);
  @$pb.TagNumber(8)
  void clearGroupType() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get currencyCode => $_getSZ(8);
  @$pb.TagNumber(9)
  set currencyCode($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasCurrencyCode() => $_has(8);
  @$pb.TagNumber(9)
  void clearCurrencyCode() => clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get savingAmount => $_getI64(9);
  @$pb.TagNumber(10)
  set savingAmount($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasSavingAmount() => $_has(9);
  @$pb.TagNumber(10)
  void clearSavingAmount() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get timeZone => $_getSZ(10);
  @$pb.TagNumber(11)
  set timeZone($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasTimeZone() => $_has(10);
  @$pb.TagNumber(11)
  void clearTimeZone() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get minMembers => $_getIZ(11);
  @$pb.TagNumber(12)
  set minMembers($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasMinMembers() => $_has(11);
  @$pb.TagNumber(12)
  void clearMinMembers() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get maxMembers => $_getIZ(12);
  @$pb.TagNumber(13)
  set maxMembers($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasMaxMembers() => $_has(12);
  @$pb.TagNumber(13)
  void clearMaxMembers() => clearField(13);

  @$pb.TagNumber(14)
  $7.STATE get state => $_getN(13);
  @$pb.TagNumber(14)
  set state($7.STATE v) { setField(14, v); }
  @$pb.TagNumber(14)
  $core.bool hasState() => $_has(13);
  @$pb.TagNumber(14)
  void clearState() => clearField(14);

  @$pb.TagNumber(15)
  $6.Struct get properties => $_getN(14);
  @$pb.TagNumber(15)
  set properties($6.Struct v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasProperties() => $_has(14);
  @$pb.TagNumber(15)
  void clearProperties() => clearField(15);
  @$pb.TagNumber(15)
  $6.Struct ensureProperties() => $_ensure(14);
}

class ClientGroupSaveRequest extends $pb.GeneratedMessage {
  factory ClientGroupSaveRequest({
    ClientGroupObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientGroupSaveRequest._() : super();
  factory ClientGroupSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientGroupSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientGroupSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<ClientGroupObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientGroupObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientGroupSaveRequest clone() => ClientGroupSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientGroupSaveRequest copyWith(void Function(ClientGroupSaveRequest) updates) => super.copyWith((message) => updates(message as ClientGroupSaveRequest)) as ClientGroupSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientGroupSaveRequest create() => ClientGroupSaveRequest._();
  ClientGroupSaveRequest createEmptyInstance() => create();
  static $pb.PbList<ClientGroupSaveRequest> createRepeated() => $pb.PbList<ClientGroupSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientGroupSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGroupSaveRequest>(create);
  static ClientGroupSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ClientGroupObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientGroupObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientGroupObject ensureData() => $_ensure(0);
}

class ClientGroupSaveResponse extends $pb.GeneratedMessage {
  factory ClientGroupSaveResponse({
    ClientGroupObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientGroupSaveResponse._() : super();
  factory ClientGroupSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientGroupSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientGroupSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<ClientGroupObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientGroupObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientGroupSaveResponse clone() => ClientGroupSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientGroupSaveResponse copyWith(void Function(ClientGroupSaveResponse) updates) => super.copyWith((message) => updates(message as ClientGroupSaveResponse)) as ClientGroupSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientGroupSaveResponse create() => ClientGroupSaveResponse._();
  ClientGroupSaveResponse createEmptyInstance() => create();
  static $pb.PbList<ClientGroupSaveResponse> createRepeated() => $pb.PbList<ClientGroupSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientGroupSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGroupSaveResponse>(create);
  static ClientGroupSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientGroupObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientGroupObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientGroupObject ensureData() => $_ensure(0);
}

class ClientGroupGetRequest extends $pb.GeneratedMessage {
  factory ClientGroupGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  ClientGroupGetRequest._() : super();
  factory ClientGroupGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientGroupGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientGroupGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientGroupGetRequest clone() => ClientGroupGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientGroupGetRequest copyWith(void Function(ClientGroupGetRequest) updates) => super.copyWith((message) => updates(message as ClientGroupGetRequest)) as ClientGroupGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientGroupGetRequest create() => ClientGroupGetRequest._();
  ClientGroupGetRequest createEmptyInstance() => create();
  static $pb.PbList<ClientGroupGetRequest> createRepeated() => $pb.PbList<ClientGroupGetRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientGroupGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGroupGetRequest>(create);
  static ClientGroupGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class ClientGroupGetResponse extends $pb.GeneratedMessage {
  factory ClientGroupGetResponse({
    ClientGroupObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientGroupGetResponse._() : super();
  factory ClientGroupGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientGroupGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientGroupGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<ClientGroupObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientGroupObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientGroupGetResponse clone() => ClientGroupGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientGroupGetResponse copyWith(void Function(ClientGroupGetResponse) updates) => super.copyWith((message) => updates(message as ClientGroupGetResponse)) as ClientGroupGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientGroupGetResponse create() => ClientGroupGetResponse._();
  ClientGroupGetResponse createEmptyInstance() => create();
  static $pb.PbList<ClientGroupGetResponse> createRepeated() => $pb.PbList<ClientGroupGetResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientGroupGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGroupGetResponse>(create);
  static ClientGroupGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientGroupObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientGroupObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientGroupObject ensureData() => $_ensure(0);
}

class ClientGroupSearchRequest extends $pb.GeneratedMessage {
  factory ClientGroupSearchRequest({
    $core.String? query,
    $core.String? agentId,
    $core.String? branchId,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
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
  ClientGroupSearchRequest._() : super();
  factory ClientGroupSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientGroupSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientGroupSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'agentId')
    ..aOS(3, _omitFieldNames ? '' : 'branchId')
    ..aOM<$7.PageCursor>(4, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientGroupSearchRequest clone() => ClientGroupSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientGroupSearchRequest copyWith(void Function(ClientGroupSearchRequest) updates) => super.copyWith((message) => updates(message as ClientGroupSearchRequest)) as ClientGroupSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientGroupSearchRequest create() => ClientGroupSearchRequest._();
  ClientGroupSearchRequest createEmptyInstance() => create();
  static $pb.PbList<ClientGroupSearchRequest> createRepeated() => $pb.PbList<ClientGroupSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientGroupSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGroupSearchRequest>(create);
  static ClientGroupSearchRequest? _defaultInstance;

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
  $core.String get branchId => $_getSZ(2);
  @$pb.TagNumber(3)
  set branchId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBranchId() => $_has(2);
  @$pb.TagNumber(3)
  void clearBranchId() => clearField(3);

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
}

class ClientGroupSearchResponse extends $pb.GeneratedMessage {
  factory ClientGroupSearchResponse({
    $core.Iterable<ClientGroupObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  ClientGroupSearchResponse._() : super();
  factory ClientGroupSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientGroupSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientGroupSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<ClientGroupObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: ClientGroupObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientGroupSearchResponse clone() => ClientGroupSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientGroupSearchResponse copyWith(void Function(ClientGroupSearchResponse) updates) => super.copyWith((message) => updates(message as ClientGroupSearchResponse)) as ClientGroupSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientGroupSearchResponse create() => ClientGroupSearchResponse._();
  ClientGroupSearchResponse createEmptyInstance() => create();
  static $pb.PbList<ClientGroupSearchResponse> createRepeated() => $pb.PbList<ClientGroupSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientGroupSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientGroupSearchResponse>(create);
  static ClientGroupSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ClientGroupObject> get data => $_getList(0);
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
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (contactId != null) {
      $result.contactId = contactId;
    }
    if (role != null) {
      $result.role = role;
    }
    if (membershipType != null) {
      $result.membershipType = membershipType;
    }
    if (orderNo != null) {
      $result.orderNo = orderNo;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  MembershipObject._() : super();
  factory MembershipObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MembershipObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MembershipObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'profileId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'contactId')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'role', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'membershipType', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'orderNo', $pb.PbFieldType.O3)
    ..e<$7.STATE>(9, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(10, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MembershipObject clone() => MembershipObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MembershipObject copyWith(void Function(MembershipObject) updates) => super.copyWith((message) => updates(message as MembershipObject)) as MembershipObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipObject create() => MembershipObject._();
  MembershipObject createEmptyInstance() => create();
  static $pb.PbList<MembershipObject> createRepeated() => $pb.PbList<MembershipObject>();
  @$core.pragma('dart2js:noInline')
  static MembershipObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MembershipObject>(create);
  static MembershipObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => clearField(2);

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
  $core.String get contactId => $_getSZ(4);
  @$pb.TagNumber(5)
  set contactId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasContactId() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactId() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get role => $_getIZ(5);
  @$pb.TagNumber(6)
  set role($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasRole() => $_has(5);
  @$pb.TagNumber(6)
  void clearRole() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get membershipType => $_getIZ(6);
  @$pb.TagNumber(7)
  set membershipType($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMembershipType() => $_has(6);
  @$pb.TagNumber(7)
  void clearMembershipType() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get orderNo => $_getIZ(7);
  @$pb.TagNumber(8)
  set orderNo($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasOrderNo() => $_has(7);
  @$pb.TagNumber(8)
  void clearOrderNo() => clearField(8);

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
}

class MembershipSaveRequest extends $pb.GeneratedMessage {
  factory MembershipSaveRequest({
    MembershipObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  MembershipSaveRequest._() : super();
  factory MembershipSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MembershipSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MembershipSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<MembershipObject>(1, _omitFieldNames ? '' : 'data', subBuilder: MembershipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MembershipSaveRequest clone() => MembershipSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MembershipSaveRequest copyWith(void Function(MembershipSaveRequest) updates) => super.copyWith((message) => updates(message as MembershipSaveRequest)) as MembershipSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipSaveRequest create() => MembershipSaveRequest._();
  MembershipSaveRequest createEmptyInstance() => create();
  static $pb.PbList<MembershipSaveRequest> createRepeated() => $pb.PbList<MembershipSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static MembershipSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MembershipSaveRequest>(create);
  static MembershipSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  MembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(MembershipObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  MembershipObject ensureData() => $_ensure(0);
}

class MembershipSaveResponse extends $pb.GeneratedMessage {
  factory MembershipSaveResponse({
    MembershipObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  MembershipSaveResponse._() : super();
  factory MembershipSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MembershipSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MembershipSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<MembershipObject>(1, _omitFieldNames ? '' : 'data', subBuilder: MembershipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MembershipSaveResponse clone() => MembershipSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MembershipSaveResponse copyWith(void Function(MembershipSaveResponse) updates) => super.copyWith((message) => updates(message as MembershipSaveResponse)) as MembershipSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipSaveResponse create() => MembershipSaveResponse._();
  MembershipSaveResponse createEmptyInstance() => create();
  static $pb.PbList<MembershipSaveResponse> createRepeated() => $pb.PbList<MembershipSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static MembershipSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MembershipSaveResponse>(create);
  static MembershipSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(MembershipObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  MembershipObject ensureData() => $_ensure(0);
}

class MembershipGetRequest extends $pb.GeneratedMessage {
  factory MembershipGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  MembershipGetRequest._() : super();
  factory MembershipGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MembershipGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MembershipGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MembershipGetRequest clone() => MembershipGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MembershipGetRequest copyWith(void Function(MembershipGetRequest) updates) => super.copyWith((message) => updates(message as MembershipGetRequest)) as MembershipGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipGetRequest create() => MembershipGetRequest._();
  MembershipGetRequest createEmptyInstance() => create();
  static $pb.PbList<MembershipGetRequest> createRepeated() => $pb.PbList<MembershipGetRequest>();
  @$core.pragma('dart2js:noInline')
  static MembershipGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MembershipGetRequest>(create);
  static MembershipGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class MembershipGetResponse extends $pb.GeneratedMessage {
  factory MembershipGetResponse({
    MembershipObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  MembershipGetResponse._() : super();
  factory MembershipGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MembershipGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MembershipGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<MembershipObject>(1, _omitFieldNames ? '' : 'data', subBuilder: MembershipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MembershipGetResponse clone() => MembershipGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MembershipGetResponse copyWith(void Function(MembershipGetResponse) updates) => super.copyWith((message) => updates(message as MembershipGetResponse)) as MembershipGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipGetResponse create() => MembershipGetResponse._();
  MembershipGetResponse createEmptyInstance() => create();
  static $pb.PbList<MembershipGetResponse> createRepeated() => $pb.PbList<MembershipGetResponse>();
  @$core.pragma('dart2js:noInline')
  static MembershipGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MembershipGetResponse>(create);
  static MembershipGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MembershipObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(MembershipObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  MembershipObject ensureData() => $_ensure(0);
}

class MembershipSearchRequest extends $pb.GeneratedMessage {
  factory MembershipSearchRequest({
    $core.String? query,
    $core.String? groupId,
    $core.String? profileId,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (profileId != null) {
      $result.profileId = profileId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  MembershipSearchRequest._() : super();
  factory MembershipSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MembershipSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MembershipSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'profileId')
    ..aOM<$7.PageCursor>(4, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MembershipSearchRequest clone() => MembershipSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MembershipSearchRequest copyWith(void Function(MembershipSearchRequest) updates) => super.copyWith((message) => updates(message as MembershipSearchRequest)) as MembershipSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipSearchRequest create() => MembershipSearchRequest._();
  MembershipSearchRequest createEmptyInstance() => create();
  static $pb.PbList<MembershipSearchRequest> createRepeated() => $pb.PbList<MembershipSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static MembershipSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MembershipSearchRequest>(create);
  static MembershipSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get profileId => $_getSZ(2);
  @$pb.TagNumber(3)
  set profileId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasProfileId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProfileId() => clearField(3);

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
}

class MembershipSearchResponse extends $pb.GeneratedMessage {
  factory MembershipSearchResponse({
    $core.Iterable<MembershipObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  MembershipSearchResponse._() : super();
  factory MembershipSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MembershipSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MembershipSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<MembershipObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: MembershipObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MembershipSearchResponse clone() => MembershipSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MembershipSearchResponse copyWith(void Function(MembershipSearchResponse) updates) => super.copyWith((message) => updates(message as MembershipSearchResponse)) as MembershipSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipSearchResponse create() => MembershipSearchResponse._();
  MembershipSearchResponse createEmptyInstance() => create();
  static $pb.PbList<MembershipSearchResponse> createRepeated() => $pb.PbList<MembershipSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static MembershipSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MembershipSearchResponse>(create);
  static MembershipSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<MembershipObject> get data => $_getList(0);
}

/// InvestorAccountObject represents a pre-funded investor capital account.
class InvestorAccountObject extends $pb.GeneratedMessage {
  factory InvestorAccountObject({
    $core.String? id,
    $core.String? investorId,
    $core.String? accountName,
    $8.Money? availableBalance,
    $8.Money? reservedBalance,
    $8.Money? totalDeployed,
    $8.Money? totalReturned,
    $8.Money? maxExposure,
    $core.String? minInterestRate,
    $6.Struct? allowedProducts,
    $6.Struct? allowedRegions,
    $6.Struct? groupAffiliations,
    $7.STATE? state,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'investorId')
    ..aOS(3, _omitFieldNames ? '' : 'accountName')
    ..aOM<$8.Money>(5, _omitFieldNames ? '' : 'availableBalance', subBuilder: $8.Money.create)
    ..aOM<$8.Money>(6, _omitFieldNames ? '' : 'reservedBalance', subBuilder: $8.Money.create)
    ..aOM<$8.Money>(7, _omitFieldNames ? '' : 'totalDeployed', subBuilder: $8.Money.create)
    ..aOM<$8.Money>(8, _omitFieldNames ? '' : 'totalReturned', subBuilder: $8.Money.create)
    ..aOM<$8.Money>(9, _omitFieldNames ? '' : 'maxExposure', subBuilder: $8.Money.create)
    ..aOS(10, _omitFieldNames ? '' : 'minInterestRate')
    ..aOM<$6.Struct>(11, _omitFieldNames ? '' : 'allowedProducts', subBuilder: $6.Struct.create)
    ..aOM<$6.Struct>(12, _omitFieldNames ? '' : 'allowedRegions', subBuilder: $6.Struct.create)
    ..aOM<$6.Struct>(13, _omitFieldNames ? '' : 'groupAffiliations', subBuilder: $6.Struct.create)
    ..e<$7.STATE>(14, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
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
  $8.Money get availableBalance => $_getN(3);
  @$pb.TagNumber(5)
  set availableBalance($8.Money v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAvailableBalance() => $_has(3);
  @$pb.TagNumber(5)
  void clearAvailableBalance() => clearField(5);
  @$pb.TagNumber(5)
  $8.Money ensureAvailableBalance() => $_ensure(3);

  @$pb.TagNumber(6)
  $8.Money get reservedBalance => $_getN(4);
  @$pb.TagNumber(6)
  set reservedBalance($8.Money v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasReservedBalance() => $_has(4);
  @$pb.TagNumber(6)
  void clearReservedBalance() => clearField(6);
  @$pb.TagNumber(6)
  $8.Money ensureReservedBalance() => $_ensure(4);

  @$pb.TagNumber(7)
  $8.Money get totalDeployed => $_getN(5);
  @$pb.TagNumber(7)
  set totalDeployed($8.Money v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasTotalDeployed() => $_has(5);
  @$pb.TagNumber(7)
  void clearTotalDeployed() => clearField(7);
  @$pb.TagNumber(7)
  $8.Money ensureTotalDeployed() => $_ensure(5);

  @$pb.TagNumber(8)
  $8.Money get totalReturned => $_getN(6);
  @$pb.TagNumber(8)
  set totalReturned($8.Money v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasTotalReturned() => $_has(6);
  @$pb.TagNumber(8)
  void clearTotalReturned() => clearField(8);
  @$pb.TagNumber(8)
  $8.Money ensureTotalReturned() => $_ensure(6);

  @$pb.TagNumber(9)
  $8.Money get maxExposure => $_getN(7);
  @$pb.TagNumber(9)
  set maxExposure($8.Money v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasMaxExposure() => $_has(7);
  @$pb.TagNumber(9)
  void clearMaxExposure() => clearField(9);
  @$pb.TagNumber(9)
  $8.Money ensureMaxExposure() => $_ensure(7);

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
  $7.STATE get state => $_getN(12);
  @$pb.TagNumber(14)
  set state($7.STATE v) { setField(14, v); }
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
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
    $7.PageCursor? cursor,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'investorId')
    ..aOS(2, _omitFieldNames ? '' : 'currencyCode')
    ..aOM<$7.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorAccountSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
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
    $8.Money? amount,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorDepositRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accountId')
    ..aOM<$8.Money>(2, _omitFieldNames ? '' : 'amount', subBuilder: $8.Money.create)
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
  $8.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($8.Money v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);
  @$pb.TagNumber(2)
  $8.Money ensureAmount() => $_ensure(1);
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorDepositResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
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
    $8.Money? amount,
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorWithdrawRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accountId')
    ..aOM<$8.Money>(2, _omitFieldNames ? '' : 'amount', subBuilder: $8.Money.create)
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
  $8.Money get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($8.Money v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);
  @$pb.TagNumber(2)
  $8.Money ensureAmount() => $_ensure(1);
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

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InvestorWithdrawResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
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
    $6.Struct? properties,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (label != null) {
      $result.label = label;
    }
    if (fieldType != null) {
      $result.fieldType = fieldType;
    }
    if (group != null) {
      $result.group = group;
    }
    if (required != null) {
      $result.required = required;
    }
    if (description != null) {
      $result.description = description;
    }
    if (placeholder != null) {
      $result.placeholder = placeholder;
    }
    if (defaultValue != null) {
      $result.defaultValue = defaultValue;
    }
    if (validationPattern != null) {
      $result.validationPattern = validationPattern;
    }
    if (validationMessage != null) {
      $result.validationMessage = validationMessage;
    }
    if (options != null) {
      $result.options.addAll(options);
    }
    if (minLength != null) {
      $result.minLength = minLength;
    }
    if (maxLength != null) {
      $result.maxLength = maxLength;
    }
    if (minValue != null) {
      $result.minValue = minValue;
    }
    if (maxValue != null) {
      $result.maxValue = maxValue;
    }
    if (order != null) {
      $result.order = order;
    }
    if (section != null) {
      $result.section = section;
    }
    if (encrypted != null) {
      $result.encrypted = encrypted;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  FormFieldDefinition._() : super();
  factory FormFieldDefinition.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormFieldDefinition.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormFieldDefinition', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..e<FormFieldType>(3, _omitFieldNames ? '' : 'fieldType', $pb.PbFieldType.OE, defaultOrMaker: FormFieldType.FORM_FIELD_TYPE_UNSPECIFIED, valueOf: FormFieldType.valueOf, enumValues: FormFieldType.values)
    ..e<FormFieldGroup>(4, _omitFieldNames ? '' : 'group', $pb.PbFieldType.OE, defaultOrMaker: FormFieldGroup.FORM_FIELD_GROUP_UNSPECIFIED, valueOf: FormFieldGroup.valueOf, enumValues: FormFieldGroup.values)
    ..aOB(5, _omitFieldNames ? '' : 'required')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'placeholder')
    ..aOS(8, _omitFieldNames ? '' : 'defaultValue')
    ..aOS(9, _omitFieldNames ? '' : 'validationPattern')
    ..aOS(10, _omitFieldNames ? '' : 'validationMessage')
    ..pPS(11, _omitFieldNames ? '' : 'options')
    ..a<$core.int>(12, _omitFieldNames ? '' : 'minLength', $pb.PbFieldType.O3)
    ..a<$core.int>(13, _omitFieldNames ? '' : 'maxLength', $pb.PbFieldType.O3)
    ..aOS(14, _omitFieldNames ? '' : 'minValue')
    ..aOS(15, _omitFieldNames ? '' : 'maxValue')
    ..a<$core.int>(16, _omitFieldNames ? '' : 'order', $pb.PbFieldType.O3)
    ..aOS(17, _omitFieldNames ? '' : 'section')
    ..aOB(18, _omitFieldNames ? '' : 'encrypted')
    ..aOM<$6.Struct>(19, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormFieldDefinition clone() => FormFieldDefinition()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormFieldDefinition copyWith(void Function(FormFieldDefinition) updates) => super.copyWith((message) => updates(message as FormFieldDefinition)) as FormFieldDefinition;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormFieldDefinition create() => FormFieldDefinition._();
  FormFieldDefinition createEmptyInstance() => create();
  static $pb.PbList<FormFieldDefinition> createRepeated() => $pb.PbList<FormFieldDefinition>();
  @$core.pragma('dart2js:noInline')
  static FormFieldDefinition getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormFieldDefinition>(create);
  static FormFieldDefinition? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => clearField(2);

  @$pb.TagNumber(3)
  FormFieldType get fieldType => $_getN(2);
  @$pb.TagNumber(3)
  set fieldType(FormFieldType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasFieldType() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldType() => clearField(3);

  @$pb.TagNumber(4)
  FormFieldGroup get group => $_getN(3);
  @$pb.TagNumber(4)
  set group(FormFieldGroup v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasGroup() => $_has(3);
  @$pb.TagNumber(4)
  void clearGroup() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get required => $_getBF(4);
  @$pb.TagNumber(5)
  set required($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasRequired() => $_has(4);
  @$pb.TagNumber(5)
  void clearRequired() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get placeholder => $_getSZ(6);
  @$pb.TagNumber(7)
  set placeholder($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasPlaceholder() => $_has(6);
  @$pb.TagNumber(7)
  void clearPlaceholder() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get defaultValue => $_getSZ(7);
  @$pb.TagNumber(8)
  set defaultValue($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasDefaultValue() => $_has(7);
  @$pb.TagNumber(8)
  void clearDefaultValue() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get validationPattern => $_getSZ(8);
  @$pb.TagNumber(9)
  set validationPattern($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasValidationPattern() => $_has(8);
  @$pb.TagNumber(9)
  void clearValidationPattern() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get validationMessage => $_getSZ(9);
  @$pb.TagNumber(10)
  set validationMessage($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasValidationMessage() => $_has(9);
  @$pb.TagNumber(10)
  void clearValidationMessage() => clearField(10);

  @$pb.TagNumber(11)
  $core.List<$core.String> get options => $_getList(10);

  @$pb.TagNumber(12)
  $core.int get minLength => $_getIZ(11);
  @$pb.TagNumber(12)
  set minLength($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasMinLength() => $_has(11);
  @$pb.TagNumber(12)
  void clearMinLength() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get maxLength => $_getIZ(12);
  @$pb.TagNumber(13)
  set maxLength($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasMaxLength() => $_has(12);
  @$pb.TagNumber(13)
  void clearMaxLength() => clearField(13);

  @$pb.TagNumber(14)
  $core.String get minValue => $_getSZ(13);
  @$pb.TagNumber(14)
  set minValue($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasMinValue() => $_has(13);
  @$pb.TagNumber(14)
  void clearMinValue() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get maxValue => $_getSZ(14);
  @$pb.TagNumber(15)
  set maxValue($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasMaxValue() => $_has(14);
  @$pb.TagNumber(15)
  void clearMaxValue() => clearField(15);

  @$pb.TagNumber(16)
  $core.int get order => $_getIZ(15);
  @$pb.TagNumber(16)
  set order($core.int v) { $_setSignedInt32(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasOrder() => $_has(15);
  @$pb.TagNumber(16)
  void clearOrder() => clearField(16);

  @$pb.TagNumber(17)
  $core.String get section => $_getSZ(16);
  @$pb.TagNumber(17)
  set section($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasSection() => $_has(16);
  @$pb.TagNumber(17)
  void clearSection() => clearField(17);

  @$pb.TagNumber(18)
  $core.bool get encrypted => $_getBF(17);
  @$pb.TagNumber(18)
  set encrypted($core.bool v) { $_setBool(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasEncrypted() => $_has(17);
  @$pb.TagNumber(18)
  void clearEncrypted() => clearField(18);

  @$pb.TagNumber(19)
  $6.Struct get properties => $_getN(18);
  @$pb.TagNumber(19)
  set properties($6.Struct v) { setField(19, v); }
  @$pb.TagNumber(19)
  $core.bool hasProperties() => $_has(18);
  @$pb.TagNumber(19)
  void clearProperties() => clearField(19);
  @$pb.TagNumber(19)
  $6.Struct ensureProperties() => $_ensure(18);
}

///  FormTemplateObject defines a reusable form schema for dynamic data collection.
///
///  Form templates are the backbone of dynamic data collection across the
///  platform. A single template can be used for loan origination KYC,
///  client onboarding, group membership registration, investor KYC, or
///  any other structured data collection requirement.
///
///  The entity_type field determines which domain the template serves
///  (e.g. "client", "agent", "investor", "group", "loan_request").
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
    $6.Struct? validationRules,
    $6.Struct? properties,
    $core.String? entityType,
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
    if (description != null) {
      $result.description = description;
    }
    if (version != null) {
      $result.version = version;
    }
    if (status != null) {
      $result.status = status;
    }
    if (fields != null) {
      $result.fields.addAll(fields);
    }
    if (sections != null) {
      $result.sections.addAll(sections);
    }
    if (validationRules != null) {
      $result.validationRules = validationRules;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    if (entityType != null) {
      $result.entityType = entityType;
    }
    return $result;
  }
  FormTemplateObject._() : super();
  factory FormTemplateObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormTemplateObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormTemplateObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'version', $pb.PbFieldType.O3)
    ..e<FormTemplateStatus>(6, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: FormTemplateStatus.FORM_TEMPLATE_STATUS_UNSPECIFIED, valueOf: FormTemplateStatus.valueOf, enumValues: FormTemplateStatus.values)
    ..pc<FormFieldDefinition>(7, _omitFieldNames ? '' : 'fields', $pb.PbFieldType.PM, subBuilder: FormFieldDefinition.create)
    ..pPS(8, _omitFieldNames ? '' : 'sections')
    ..aOM<$6.Struct>(9, _omitFieldNames ? '' : 'validationRules', subBuilder: $6.Struct.create)
    ..aOM<$6.Struct>(10, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..aOS(11, _omitFieldNames ? '' : 'entityType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormTemplateObject clone() => FormTemplateObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormTemplateObject copyWith(void Function(FormTemplateObject) updates) => super.copyWith((message) => updates(message as FormTemplateObject)) as FormTemplateObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormTemplateObject create() => FormTemplateObject._();
  FormTemplateObject createEmptyInstance() => create();
  static $pb.PbList<FormTemplateObject> createRepeated() => $pb.PbList<FormTemplateObject>();
  @$core.pragma('dart2js:noInline')
  static FormTemplateObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormTemplateObject>(create);
  static FormTemplateObject? _defaultInstance;

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
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => clearField(5);

  @$pb.TagNumber(6)
  FormTemplateStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(FormTemplateStatus v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<FormFieldDefinition> get fields => $_getList(6);

  @$pb.TagNumber(8)
  $core.List<$core.String> get sections => $_getList(7);

  @$pb.TagNumber(9)
  $6.Struct get validationRules => $_getN(8);
  @$pb.TagNumber(9)
  set validationRules($6.Struct v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasValidationRules() => $_has(8);
  @$pb.TagNumber(9)
  void clearValidationRules() => clearField(9);
  @$pb.TagNumber(9)
  $6.Struct ensureValidationRules() => $_ensure(8);

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

  /// The entity type this template is designed for. Used to filter
  /// templates when loading requirements for a specific domain.
  /// Standard values: "client", "agent", "investor", "group", "loan_request".
  @$pb.TagNumber(11)
  $core.String get entityType => $_getSZ(10);
  @$pb.TagNumber(11)
  set entityType($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasEntityType() => $_has(10);
  @$pb.TagNumber(11)
  void clearEntityType() => clearField(11);
}

///  FormSubmissionObject captures filled form data for an entity.
///
///  Submissions are linked to an owning entity via entity_id.
///  The entity_type matches FormTemplateObject.entity_type.
class FormSubmissionObject extends $pb.GeneratedMessage {
  factory FormSubmissionObject({
    $core.String? id,
    $core.String? entityId,
    $core.String? entityType,
    $core.String? templateId,
    $core.int? templateVersion,
    $core.String? submittedBy,
    $6.Struct? data,
    $6.Struct? fileRefs,
    $7.STATE? state,
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (entityId != null) {
      $result.entityId = entityId;
    }
    if (entityType != null) {
      $result.entityType = entityType;
    }
    if (templateId != null) {
      $result.templateId = templateId;
    }
    if (templateVersion != null) {
      $result.templateVersion = templateVersion;
    }
    if (submittedBy != null) {
      $result.submittedBy = submittedBy;
    }
    if (data != null) {
      $result.data = data;
    }
    if (fileRefs != null) {
      $result.fileRefs = fileRefs;
    }
    if (state != null) {
      $result.state = state;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  FormSubmissionObject._() : super();
  factory FormSubmissionObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormSubmissionObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormSubmissionObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'entityId')
    ..aOS(3, _omitFieldNames ? '' : 'entityType')
    ..aOS(4, _omitFieldNames ? '' : 'templateId')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'templateVersion', $pb.PbFieldType.O3)
    ..aOS(6, _omitFieldNames ? '' : 'submittedBy')
    ..aOM<$6.Struct>(7, _omitFieldNames ? '' : 'data', subBuilder: $6.Struct.create)
    ..aOM<$6.Struct>(8, _omitFieldNames ? '' : 'fileRefs', subBuilder: $6.Struct.create)
    ..e<$7.STATE>(9, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: $7.STATE.CREATED, valueOf: $7.STATE.valueOf, enumValues: $7.STATE.values)
    ..aOM<$6.Struct>(10, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormSubmissionObject clone() => FormSubmissionObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormSubmissionObject copyWith(void Function(FormSubmissionObject) updates) => super.copyWith((message) => updates(message as FormSubmissionObject)) as FormSubmissionObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormSubmissionObject create() => FormSubmissionObject._();
  FormSubmissionObject createEmptyInstance() => create();
  static $pb.PbList<FormSubmissionObject> createRepeated() => $pb.PbList<FormSubmissionObject>();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormSubmissionObject>(create);
  static FormSubmissionObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get entityId => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEntityId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get entityType => $_getSZ(2);
  @$pb.TagNumber(3)
  set entityType($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEntityType() => $_has(2);
  @$pb.TagNumber(3)
  void clearEntityType() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get templateId => $_getSZ(3);
  @$pb.TagNumber(4)
  set templateId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTemplateId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTemplateId() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get templateVersion => $_getIZ(4);
  @$pb.TagNumber(5)
  set templateVersion($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTemplateVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearTemplateVersion() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get submittedBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set submittedBy($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSubmittedBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearSubmittedBy() => clearField(6);

  @$pb.TagNumber(7)
  $6.Struct get data => $_getN(6);
  @$pb.TagNumber(7)
  set data($6.Struct v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasData() => $_has(6);
  @$pb.TagNumber(7)
  void clearData() => clearField(7);
  @$pb.TagNumber(7)
  $6.Struct ensureData() => $_ensure(6);

  @$pb.TagNumber(8)
  $6.Struct get fileRefs => $_getN(7);
  @$pb.TagNumber(8)
  set fileRefs($6.Struct v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasFileRefs() => $_has(7);
  @$pb.TagNumber(8)
  void clearFileRefs() => clearField(8);
  @$pb.TagNumber(8)
  $6.Struct ensureFileRefs() => $_ensure(7);

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
    $6.Struct? properties,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (fieldKey != null) {
      $result.fieldKey = fieldKey;
    }
    if (value != null) {
      $result.value = value;
    }
    if (valueType != null) {
      $result.valueType = valueType;
    }
    if (verificationStatus != null) {
      $result.verificationStatus = verificationStatus;
    }
    if (reviewerId != null) {
      $result.reviewerId = reviewerId;
    }
    if (reviewerComment != null) {
      $result.reviewerComment = reviewerComment;
    }
    if (sourceEntityId != null) {
      $result.sourceEntityId = sourceEntityId;
    }
    if (revision != null) {
      $result.revision = revision;
    }
    if (verifiedAt != null) {
      $result.verifiedAt = verifiedAt;
    }
    if (expiresAt != null) {
      $result.expiresAt = expiresAt;
    }
    if (properties != null) {
      $result.properties = properties;
    }
    return $result;
  }
  ClientDataEntryObject._() : super();
  factory ClientDataEntryObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataEntryObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataEntryObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'clientId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldKey')
    ..aOS(4, _omitFieldNames ? '' : 'value')
    ..aOS(5, _omitFieldNames ? '' : 'valueType')
    ..e<DataVerificationStatus>(6, _omitFieldNames ? '' : 'verificationStatus', $pb.PbFieldType.OE, defaultOrMaker: DataVerificationStatus.DATA_VERIFICATION_STATUS_UNSPECIFIED, valueOf: DataVerificationStatus.valueOf, enumValues: DataVerificationStatus.values)
    ..aOS(7, _omitFieldNames ? '' : 'reviewerId')
    ..aOS(8, _omitFieldNames ? '' : 'reviewerComment')
    ..aOS(9, _omitFieldNames ? '' : 'sourceEntityId')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.O3)
    ..aOS(11, _omitFieldNames ? '' : 'verifiedAt')
    ..aOS(12, _omitFieldNames ? '' : 'expiresAt')
    ..aOM<$6.Struct>(13, _omitFieldNames ? '' : 'properties', subBuilder: $6.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataEntryObject clone() => ClientDataEntryObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataEntryObject copyWith(void Function(ClientDataEntryObject) updates) => super.copyWith((message) => updates(message as ClientDataEntryObject)) as ClientDataEntryObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataEntryObject create() => ClientDataEntryObject._();
  ClientDataEntryObject createEmptyInstance() => create();
  static $pb.PbList<ClientDataEntryObject> createRepeated() => $pb.PbList<ClientDataEntryObject>();
  @$core.pragma('dart2js:noInline')
  static ClientDataEntryObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataEntryObject>(create);
  static ClientDataEntryObject? _defaultInstance;

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
  $core.String get fieldKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldKey($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFieldKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldKey() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get value => $_getSZ(3);
  @$pb.TagNumber(4)
  set value($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearValue() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get valueType => $_getSZ(4);
  @$pb.TagNumber(5)
  set valueType($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasValueType() => $_has(4);
  @$pb.TagNumber(5)
  void clearValueType() => clearField(5);

  @$pb.TagNumber(6)
  DataVerificationStatus get verificationStatus => $_getN(5);
  @$pb.TagNumber(6)
  set verificationStatus(DataVerificationStatus v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasVerificationStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearVerificationStatus() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get reviewerId => $_getSZ(6);
  @$pb.TagNumber(7)
  set reviewerId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasReviewerId() => $_has(6);
  @$pb.TagNumber(7)
  void clearReviewerId() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get reviewerComment => $_getSZ(7);
  @$pb.TagNumber(8)
  set reviewerComment($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasReviewerComment() => $_has(7);
  @$pb.TagNumber(8)
  void clearReviewerComment() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get sourceEntityId => $_getSZ(8);
  @$pb.TagNumber(9)
  set sourceEntityId($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasSourceEntityId() => $_has(8);
  @$pb.TagNumber(9)
  void clearSourceEntityId() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get revision => $_getIZ(9);
  @$pb.TagNumber(10)
  set revision($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasRevision() => $_has(9);
  @$pb.TagNumber(10)
  void clearRevision() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get verifiedAt => $_getSZ(10);
  @$pb.TagNumber(11)
  set verifiedAt($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasVerifiedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearVerifiedAt() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get expiresAt => $_getSZ(11);
  @$pb.TagNumber(12)
  set expiresAt($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasExpiresAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearExpiresAt() => clearField(12);

  @$pb.TagNumber(13)
  $6.Struct get properties => $_getN(12);
  @$pb.TagNumber(13)
  set properties($6.Struct v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasProperties() => $_has(12);
  @$pb.TagNumber(13)
  void clearProperties() => clearField(13);
  @$pb.TagNumber(13)
  $6.Struct ensureProperties() => $_ensure(12);
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
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (entryId != null) {
      $result.entryId = entryId;
    }
    if (revision != null) {
      $result.revision = revision;
    }
    if (value != null) {
      $result.value = value;
    }
    if (action != null) {
      $result.action = action;
    }
    if (actorId != null) {
      $result.actorId = actorId;
    }
    if (comment != null) {
      $result.comment = comment;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  ClientDataEntryHistoryObject._() : super();
  factory ClientDataEntryHistoryObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataEntryHistoryObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataEntryHistoryObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'entryId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'value')
    ..aOS(5, _omitFieldNames ? '' : 'action')
    ..aOS(6, _omitFieldNames ? '' : 'actorId')
    ..aOS(7, _omitFieldNames ? '' : 'comment')
    ..aOS(8, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataEntryHistoryObject clone() => ClientDataEntryHistoryObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataEntryHistoryObject copyWith(void Function(ClientDataEntryHistoryObject) updates) => super.copyWith((message) => updates(message as ClientDataEntryHistoryObject)) as ClientDataEntryHistoryObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataEntryHistoryObject create() => ClientDataEntryHistoryObject._();
  ClientDataEntryHistoryObject createEmptyInstance() => create();
  static $pb.PbList<ClientDataEntryHistoryObject> createRepeated() => $pb.PbList<ClientDataEntryHistoryObject>();
  @$core.pragma('dart2js:noInline')
  static ClientDataEntryHistoryObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataEntryHistoryObject>(create);
  static ClientDataEntryHistoryObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get entryId => $_getSZ(1);
  @$pb.TagNumber(2)
  set entryId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEntryId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntryId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get revision => $_getIZ(2);
  @$pb.TagNumber(3)
  set revision($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRevision() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevision() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get value => $_getSZ(3);
  @$pb.TagNumber(4)
  set value($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearValue() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get action => $_getSZ(4);
  @$pb.TagNumber(5)
  set action($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAction() => $_has(4);
  @$pb.TagNumber(5)
  void clearAction() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get actorId => $_getSZ(5);
  @$pb.TagNumber(6)
  set actorId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasActorId() => $_has(5);
  @$pb.TagNumber(6)
  void clearActorId() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get comment => $_getSZ(6);
  @$pb.TagNumber(7)
  set comment($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasComment() => $_has(6);
  @$pb.TagNumber(7)
  void clearComment() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get createdAt => $_getSZ(7);
  @$pb.TagNumber(8)
  set createdAt($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => clearField(8);
}

/// Save/update client data (agent submitting)
class ClientDataSaveRequest extends $pb.GeneratedMessage {
  factory ClientDataSaveRequest({
    ClientDataEntryObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientDataSaveRequest._() : super();
  factory ClientDataSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientDataEntryObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataSaveRequest clone() => ClientDataSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataSaveRequest copyWith(void Function(ClientDataSaveRequest) updates) => super.copyWith((message) => updates(message as ClientDataSaveRequest)) as ClientDataSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataSaveRequest create() => ClientDataSaveRequest._();
  ClientDataSaveRequest createEmptyInstance() => create();
  static $pb.PbList<ClientDataSaveRequest> createRepeated() => $pb.PbList<ClientDataSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientDataSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataSaveRequest>(create);
  static ClientDataSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

class ClientDataSaveResponse extends $pb.GeneratedMessage {
  factory ClientDataSaveResponse({
    ClientDataEntryObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientDataSaveResponse._() : super();
  factory ClientDataSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientDataEntryObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataSaveResponse clone() => ClientDataSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataSaveResponse copyWith(void Function(ClientDataSaveResponse) updates) => super.copyWith((message) => updates(message as ClientDataSaveResponse)) as ClientDataSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataSaveResponse create() => ClientDataSaveResponse._();
  ClientDataSaveResponse createEmptyInstance() => create();
  static $pb.PbList<ClientDataSaveResponse> createRepeated() => $pb.PbList<ClientDataSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientDataSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataSaveResponse>(create);
  static ClientDataSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// Get a single entry by client_id + field_key
class ClientDataGetRequest extends $pb.GeneratedMessage {
  factory ClientDataGetRequest({
    $core.String? clientId,
    $core.String? fieldKey,
  }) {
    final $result = create();
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (fieldKey != null) {
      $result.fieldKey = fieldKey;
    }
    return $result;
  }
  ClientDataGetRequest._() : super();
  factory ClientDataGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataGetRequest clone() => ClientDataGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataGetRequest copyWith(void Function(ClientDataGetRequest) updates) => super.copyWith((message) => updates(message as ClientDataGetRequest)) as ClientDataGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataGetRequest create() => ClientDataGetRequest._();
  ClientDataGetRequest createEmptyInstance() => create();
  static $pb.PbList<ClientDataGetRequest> createRepeated() => $pb.PbList<ClientDataGetRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientDataGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataGetRequest>(create);
  static ClientDataGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFieldKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldKey() => clearField(2);
}

class ClientDataGetResponse extends $pb.GeneratedMessage {
  factory ClientDataGetResponse({
    ClientDataEntryObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientDataGetResponse._() : super();
  factory ClientDataGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientDataEntryObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataGetResponse clone() => ClientDataGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataGetResponse copyWith(void Function(ClientDataGetResponse) updates) => super.copyWith((message) => updates(message as ClientDataGetResponse)) as ClientDataGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataGetResponse create() => ClientDataGetResponse._();
  ClientDataGetResponse createEmptyInstance() => create();
  static $pb.PbList<ClientDataGetResponse> createRepeated() => $pb.PbList<ClientDataGetResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientDataGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataGetResponse>(create);
  static ClientDataGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// List all entries for a client
class ClientDataListRequest extends $pb.GeneratedMessage {
  factory ClientDataListRequest({
    $core.String? clientId,
    DataVerificationStatus? verificationStatus,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (clientId != null) {
      $result.clientId = clientId;
    }
    if (verificationStatus != null) {
      $result.verificationStatus = verificationStatus;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  ClientDataListRequest._() : super();
  factory ClientDataListRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataListRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataListRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..e<DataVerificationStatus>(2, _omitFieldNames ? '' : 'verificationStatus', $pb.PbFieldType.OE, defaultOrMaker: DataVerificationStatus.DATA_VERIFICATION_STATUS_UNSPECIFIED, valueOf: DataVerificationStatus.valueOf, enumValues: DataVerificationStatus.values)
    ..aOM<$7.PageCursor>(3, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataListRequest clone() => ClientDataListRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataListRequest copyWith(void Function(ClientDataListRequest) updates) => super.copyWith((message) => updates(message as ClientDataListRequest)) as ClientDataListRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataListRequest create() => ClientDataListRequest._();
  ClientDataListRequest createEmptyInstance() => create();
  static $pb.PbList<ClientDataListRequest> createRepeated() => $pb.PbList<ClientDataListRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientDataListRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataListRequest>(create);
  static ClientDataListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => clearField(1);

  @$pb.TagNumber(2)
  DataVerificationStatus get verificationStatus => $_getN(1);
  @$pb.TagNumber(2)
  set verificationStatus(DataVerificationStatus v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasVerificationStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerificationStatus() => clearField(2);

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

class ClientDataListResponse extends $pb.GeneratedMessage {
  factory ClientDataListResponse({
    $core.Iterable<ClientDataEntryObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  ClientDataListResponse._() : super();
  factory ClientDataListResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataListResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: ClientDataEntryObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataListResponse clone() => ClientDataListResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataListResponse copyWith(void Function(ClientDataListResponse) updates) => super.copyWith((message) => updates(message as ClientDataListResponse)) as ClientDataListResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataListResponse create() => ClientDataListResponse._();
  ClientDataListResponse createEmptyInstance() => create();
  static $pb.PbList<ClientDataListResponse> createRepeated() => $pb.PbList<ClientDataListResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientDataListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataListResponse>(create);
  static ClientDataListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ClientDataEntryObject> get data => $_getList(0);
}

/// Verifier approves a data entry
class ClientDataVerifyRequest extends $pb.GeneratedMessage {
  factory ClientDataVerifyRequest({
    $core.String? entryId,
    $core.String? reviewerId,
    $core.String? comment,
  }) {
    final $result = create();
    if (entryId != null) {
      $result.entryId = entryId;
    }
    if (reviewerId != null) {
      $result.reviewerId = reviewerId;
    }
    if (comment != null) {
      $result.comment = comment;
    }
    return $result;
  }
  ClientDataVerifyRequest._() : super();
  factory ClientDataVerifyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataVerifyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataVerifyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'entryId')
    ..aOS(2, _omitFieldNames ? '' : 'reviewerId')
    ..aOS(3, _omitFieldNames ? '' : 'comment')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataVerifyRequest clone() => ClientDataVerifyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataVerifyRequest copyWith(void Function(ClientDataVerifyRequest) updates) => super.copyWith((message) => updates(message as ClientDataVerifyRequest)) as ClientDataVerifyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataVerifyRequest create() => ClientDataVerifyRequest._();
  ClientDataVerifyRequest createEmptyInstance() => create();
  static $pb.PbList<ClientDataVerifyRequest> createRepeated() => $pb.PbList<ClientDataVerifyRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientDataVerifyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataVerifyRequest>(create);
  static ClientDataVerifyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entryId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reviewerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set reviewerId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReviewerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReviewerId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get comment => $_getSZ(2);
  @$pb.TagNumber(3)
  set comment($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasComment() => $_has(2);
  @$pb.TagNumber(3)
  void clearComment() => clearField(3);
}

class ClientDataVerifyResponse extends $pb.GeneratedMessage {
  factory ClientDataVerifyResponse({
    ClientDataEntryObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientDataVerifyResponse._() : super();
  factory ClientDataVerifyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataVerifyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataVerifyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientDataEntryObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataVerifyResponse clone() => ClientDataVerifyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataVerifyResponse copyWith(void Function(ClientDataVerifyResponse) updates) => super.copyWith((message) => updates(message as ClientDataVerifyResponse)) as ClientDataVerifyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataVerifyResponse create() => ClientDataVerifyResponse._();
  ClientDataVerifyResponse createEmptyInstance() => create();
  static $pb.PbList<ClientDataVerifyResponse> createRepeated() => $pb.PbList<ClientDataVerifyResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientDataVerifyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataVerifyResponse>(create);
  static ClientDataVerifyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// Verifier rejects a data entry
class ClientDataRejectRequest extends $pb.GeneratedMessage {
  factory ClientDataRejectRequest({
    $core.String? entryId,
    $core.String? reviewerId,
    $core.String? reason,
  }) {
    final $result = create();
    if (entryId != null) {
      $result.entryId = entryId;
    }
    if (reviewerId != null) {
      $result.reviewerId = reviewerId;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    return $result;
  }
  ClientDataRejectRequest._() : super();
  factory ClientDataRejectRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataRejectRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataRejectRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'entryId')
    ..aOS(2, _omitFieldNames ? '' : 'reviewerId')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataRejectRequest clone() => ClientDataRejectRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataRejectRequest copyWith(void Function(ClientDataRejectRequest) updates) => super.copyWith((message) => updates(message as ClientDataRejectRequest)) as ClientDataRejectRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataRejectRequest create() => ClientDataRejectRequest._();
  ClientDataRejectRequest createEmptyInstance() => create();
  static $pb.PbList<ClientDataRejectRequest> createRepeated() => $pb.PbList<ClientDataRejectRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientDataRejectRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataRejectRequest>(create);
  static ClientDataRejectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entryId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reviewerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set reviewerId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReviewerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReviewerId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => clearField(3);
}

class ClientDataRejectResponse extends $pb.GeneratedMessage {
  factory ClientDataRejectResponse({
    ClientDataEntryObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientDataRejectResponse._() : super();
  factory ClientDataRejectResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataRejectResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataRejectResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientDataEntryObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataRejectResponse clone() => ClientDataRejectResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataRejectResponse copyWith(void Function(ClientDataRejectResponse) updates) => super.copyWith((message) => updates(message as ClientDataRejectResponse)) as ClientDataRejectResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataRejectResponse create() => ClientDataRejectResponse._();
  ClientDataRejectResponse createEmptyInstance() => create();
  static $pb.PbList<ClientDataRejectResponse> createRepeated() => $pb.PbList<ClientDataRejectResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientDataRejectResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataRejectResponse>(create);
  static ClientDataRejectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// Verifier requests more information
class ClientDataRequestInfoRequest extends $pb.GeneratedMessage {
  factory ClientDataRequestInfoRequest({
    $core.String? entryId,
    $core.String? reviewerId,
    $core.String? comment,
  }) {
    final $result = create();
    if (entryId != null) {
      $result.entryId = entryId;
    }
    if (reviewerId != null) {
      $result.reviewerId = reviewerId;
    }
    if (comment != null) {
      $result.comment = comment;
    }
    return $result;
  }
  ClientDataRequestInfoRequest._() : super();
  factory ClientDataRequestInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataRequestInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataRequestInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'entryId')
    ..aOS(2, _omitFieldNames ? '' : 'reviewerId')
    ..aOS(3, _omitFieldNames ? '' : 'comment')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataRequestInfoRequest clone() => ClientDataRequestInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataRequestInfoRequest copyWith(void Function(ClientDataRequestInfoRequest) updates) => super.copyWith((message) => updates(message as ClientDataRequestInfoRequest)) as ClientDataRequestInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataRequestInfoRequest create() => ClientDataRequestInfoRequest._();
  ClientDataRequestInfoRequest createEmptyInstance() => create();
  static $pb.PbList<ClientDataRequestInfoRequest> createRepeated() => $pb.PbList<ClientDataRequestInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientDataRequestInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataRequestInfoRequest>(create);
  static ClientDataRequestInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entryId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get reviewerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set reviewerId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReviewerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReviewerId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get comment => $_getSZ(2);
  @$pb.TagNumber(3)
  set comment($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasComment() => $_has(2);
  @$pb.TagNumber(3)
  void clearComment() => clearField(3);
}

class ClientDataRequestInfoResponse extends $pb.GeneratedMessage {
  factory ClientDataRequestInfoResponse({
    ClientDataEntryObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ClientDataRequestInfoResponse._() : super();
  factory ClientDataRequestInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataRequestInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataRequestInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<ClientDataEntryObject>(1, _omitFieldNames ? '' : 'data', subBuilder: ClientDataEntryObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataRequestInfoResponse clone() => ClientDataRequestInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataRequestInfoResponse copyWith(void Function(ClientDataRequestInfoResponse) updates) => super.copyWith((message) => updates(message as ClientDataRequestInfoResponse)) as ClientDataRequestInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataRequestInfoResponse create() => ClientDataRequestInfoResponse._();
  ClientDataRequestInfoResponse createEmptyInstance() => create();
  static $pb.PbList<ClientDataRequestInfoResponse> createRepeated() => $pb.PbList<ClientDataRequestInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientDataRequestInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataRequestInfoResponse>(create);
  static ClientDataRequestInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ClientDataEntryObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(ClientDataEntryObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  ClientDataEntryObject ensureData() => $_ensure(0);
}

/// Get revision history for a data entry
class ClientDataHistoryRequest extends $pb.GeneratedMessage {
  factory ClientDataHistoryRequest({
    $core.String? entryId,
  }) {
    final $result = create();
    if (entryId != null) {
      $result.entryId = entryId;
    }
    return $result;
  }
  ClientDataHistoryRequest._() : super();
  factory ClientDataHistoryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataHistoryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataHistoryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'entryId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataHistoryRequest clone() => ClientDataHistoryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataHistoryRequest copyWith(void Function(ClientDataHistoryRequest) updates) => super.copyWith((message) => updates(message as ClientDataHistoryRequest)) as ClientDataHistoryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataHistoryRequest create() => ClientDataHistoryRequest._();
  ClientDataHistoryRequest createEmptyInstance() => create();
  static $pb.PbList<ClientDataHistoryRequest> createRepeated() => $pb.PbList<ClientDataHistoryRequest>();
  @$core.pragma('dart2js:noInline')
  static ClientDataHistoryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataHistoryRequest>(create);
  static ClientDataHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entryId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => clearField(1);
}

class ClientDataHistoryResponse extends $pb.GeneratedMessage {
  factory ClientDataHistoryResponse({
    $core.Iterable<ClientDataEntryHistoryObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  ClientDataHistoryResponse._() : super();
  factory ClientDataHistoryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientDataHistoryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientDataHistoryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<ClientDataEntryHistoryObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: ClientDataEntryHistoryObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientDataHistoryResponse clone() => ClientDataHistoryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientDataHistoryResponse copyWith(void Function(ClientDataHistoryResponse) updates) => super.copyWith((message) => updates(message as ClientDataHistoryResponse)) as ClientDataHistoryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientDataHistoryResponse create() => ClientDataHistoryResponse._();
  ClientDataHistoryResponse createEmptyInstance() => create();
  static $pb.PbList<ClientDataHistoryResponse> createRepeated() => $pb.PbList<ClientDataHistoryResponse>();
  @$core.pragma('dart2js:noInline')
  static ClientDataHistoryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientDataHistoryResponse>(create);
  static ClientDataHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ClientDataEntryHistoryObject> get data => $_getList(0);
}

class FormTemplateSaveRequest extends $pb.GeneratedMessage {
  factory FormTemplateSaveRequest({
    FormTemplateObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  FormTemplateSaveRequest._() : super();
  factory FormTemplateSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormTemplateSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormTemplateSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<FormTemplateObject>(1, _omitFieldNames ? '' : 'data', subBuilder: FormTemplateObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormTemplateSaveRequest clone() => FormTemplateSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormTemplateSaveRequest copyWith(void Function(FormTemplateSaveRequest) updates) => super.copyWith((message) => updates(message as FormTemplateSaveRequest)) as FormTemplateSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormTemplateSaveRequest create() => FormTemplateSaveRequest._();
  FormTemplateSaveRequest createEmptyInstance() => create();
  static $pb.PbList<FormTemplateSaveRequest> createRepeated() => $pb.PbList<FormTemplateSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static FormTemplateSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormTemplateSaveRequest>(create);
  static FormTemplateSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  FormTemplateObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormTemplateObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  FormTemplateObject ensureData() => $_ensure(0);
}

class FormTemplateSaveResponse extends $pb.GeneratedMessage {
  factory FormTemplateSaveResponse({
    FormTemplateObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  FormTemplateSaveResponse._() : super();
  factory FormTemplateSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormTemplateSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormTemplateSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<FormTemplateObject>(1, _omitFieldNames ? '' : 'data', subBuilder: FormTemplateObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormTemplateSaveResponse clone() => FormTemplateSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormTemplateSaveResponse copyWith(void Function(FormTemplateSaveResponse) updates) => super.copyWith((message) => updates(message as FormTemplateSaveResponse)) as FormTemplateSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormTemplateSaveResponse create() => FormTemplateSaveResponse._();
  FormTemplateSaveResponse createEmptyInstance() => create();
  static $pb.PbList<FormTemplateSaveResponse> createRepeated() => $pb.PbList<FormTemplateSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static FormTemplateSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormTemplateSaveResponse>(create);
  static FormTemplateSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FormTemplateObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormTemplateObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  FormTemplateObject ensureData() => $_ensure(0);
}

class FormTemplateGetRequest extends $pb.GeneratedMessage {
  factory FormTemplateGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  FormTemplateGetRequest._() : super();
  factory FormTemplateGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormTemplateGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormTemplateGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormTemplateGetRequest clone() => FormTemplateGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormTemplateGetRequest copyWith(void Function(FormTemplateGetRequest) updates) => super.copyWith((message) => updates(message as FormTemplateGetRequest)) as FormTemplateGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormTemplateGetRequest create() => FormTemplateGetRequest._();
  FormTemplateGetRequest createEmptyInstance() => create();
  static $pb.PbList<FormTemplateGetRequest> createRepeated() => $pb.PbList<FormTemplateGetRequest>();
  @$core.pragma('dart2js:noInline')
  static FormTemplateGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormTemplateGetRequest>(create);
  static FormTemplateGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class FormTemplateGetResponse extends $pb.GeneratedMessage {
  factory FormTemplateGetResponse({
    FormTemplateObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  FormTemplateGetResponse._() : super();
  factory FormTemplateGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormTemplateGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormTemplateGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<FormTemplateObject>(1, _omitFieldNames ? '' : 'data', subBuilder: FormTemplateObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormTemplateGetResponse clone() => FormTemplateGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormTemplateGetResponse copyWith(void Function(FormTemplateGetResponse) updates) => super.copyWith((message) => updates(message as FormTemplateGetResponse)) as FormTemplateGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormTemplateGetResponse create() => FormTemplateGetResponse._();
  FormTemplateGetResponse createEmptyInstance() => create();
  static $pb.PbList<FormTemplateGetResponse> createRepeated() => $pb.PbList<FormTemplateGetResponse>();
  @$core.pragma('dart2js:noInline')
  static FormTemplateGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormTemplateGetResponse>(create);
  static FormTemplateGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FormTemplateObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormTemplateObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  FormTemplateObject ensureData() => $_ensure(0);
}

class FormTemplateSearchRequest extends $pb.GeneratedMessage {
  factory FormTemplateSearchRequest({
    $core.String? query,
    $core.String? organizationId,
    FormTemplateStatus? status,
    $7.PageCursor? cursor,
    $core.String? entityType,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
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
    if (entityType != null) {
      $result.entityType = entityType;
    }
    return $result;
  }
  FormTemplateSearchRequest._() : super();
  factory FormTemplateSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormTemplateSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormTemplateSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'organizationId')
    ..e<FormTemplateStatus>(3, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: FormTemplateStatus.FORM_TEMPLATE_STATUS_UNSPECIFIED, valueOf: FormTemplateStatus.valueOf, enumValues: FormTemplateStatus.values)
    ..aOM<$7.PageCursor>(4, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..aOS(5, _omitFieldNames ? '' : 'entityType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormTemplateSearchRequest clone() => FormTemplateSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormTemplateSearchRequest copyWith(void Function(FormTemplateSearchRequest) updates) => super.copyWith((message) => updates(message as FormTemplateSearchRequest)) as FormTemplateSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormTemplateSearchRequest create() => FormTemplateSearchRequest._();
  FormTemplateSearchRequest createEmptyInstance() => create();
  static $pb.PbList<FormTemplateSearchRequest> createRepeated() => $pb.PbList<FormTemplateSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static FormTemplateSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormTemplateSearchRequest>(create);
  static FormTemplateSearchRequest? _defaultInstance;

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
  FormTemplateStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(FormTemplateStatus v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);

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

  /// Filter templates by entity type (e.g. "client", "group", "loan_request").
  @$pb.TagNumber(5)
  $core.String get entityType => $_getSZ(4);
  @$pb.TagNumber(5)
  set entityType($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEntityType() => $_has(4);
  @$pb.TagNumber(5)
  void clearEntityType() => clearField(5);
}

class FormTemplateSearchResponse extends $pb.GeneratedMessage {
  factory FormTemplateSearchResponse({
    $core.Iterable<FormTemplateObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  FormTemplateSearchResponse._() : super();
  factory FormTemplateSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormTemplateSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormTemplateSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<FormTemplateObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: FormTemplateObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormTemplateSearchResponse clone() => FormTemplateSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormTemplateSearchResponse copyWith(void Function(FormTemplateSearchResponse) updates) => super.copyWith((message) => updates(message as FormTemplateSearchResponse)) as FormTemplateSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormTemplateSearchResponse create() => FormTemplateSearchResponse._();
  FormTemplateSearchResponse createEmptyInstance() => create();
  static $pb.PbList<FormTemplateSearchResponse> createRepeated() => $pb.PbList<FormTemplateSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static FormTemplateSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormTemplateSearchResponse>(create);
  static FormTemplateSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<FormTemplateObject> get data => $_getList(0);
}

class FormTemplatePublishRequest extends $pb.GeneratedMessage {
  factory FormTemplatePublishRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  FormTemplatePublishRequest._() : super();
  factory FormTemplatePublishRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormTemplatePublishRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormTemplatePublishRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormTemplatePublishRequest clone() => FormTemplatePublishRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormTemplatePublishRequest copyWith(void Function(FormTemplatePublishRequest) updates) => super.copyWith((message) => updates(message as FormTemplatePublishRequest)) as FormTemplatePublishRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormTemplatePublishRequest create() => FormTemplatePublishRequest._();
  FormTemplatePublishRequest createEmptyInstance() => create();
  static $pb.PbList<FormTemplatePublishRequest> createRepeated() => $pb.PbList<FormTemplatePublishRequest>();
  @$core.pragma('dart2js:noInline')
  static FormTemplatePublishRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormTemplatePublishRequest>(create);
  static FormTemplatePublishRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class FormTemplatePublishResponse extends $pb.GeneratedMessage {
  factory FormTemplatePublishResponse({
    FormTemplateObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  FormTemplatePublishResponse._() : super();
  factory FormTemplatePublishResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormTemplatePublishResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormTemplatePublishResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<FormTemplateObject>(1, _omitFieldNames ? '' : 'data', subBuilder: FormTemplateObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormTemplatePublishResponse clone() => FormTemplatePublishResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormTemplatePublishResponse copyWith(void Function(FormTemplatePublishResponse) updates) => super.copyWith((message) => updates(message as FormTemplatePublishResponse)) as FormTemplatePublishResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormTemplatePublishResponse create() => FormTemplatePublishResponse._();
  FormTemplatePublishResponse createEmptyInstance() => create();
  static $pb.PbList<FormTemplatePublishResponse> createRepeated() => $pb.PbList<FormTemplatePublishResponse>();
  @$core.pragma('dart2js:noInline')
  static FormTemplatePublishResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormTemplatePublishResponse>(create);
  static FormTemplatePublishResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FormTemplateObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormTemplateObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  FormTemplateObject ensureData() => $_ensure(0);
}

class FormSubmissionSaveRequest extends $pb.GeneratedMessage {
  factory FormSubmissionSaveRequest({
    FormSubmissionObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  FormSubmissionSaveRequest._() : super();
  factory FormSubmissionSaveRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormSubmissionSaveRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormSubmissionSaveRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<FormSubmissionObject>(1, _omitFieldNames ? '' : 'data', subBuilder: FormSubmissionObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormSubmissionSaveRequest clone() => FormSubmissionSaveRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormSubmissionSaveRequest copyWith(void Function(FormSubmissionSaveRequest) updates) => super.copyWith((message) => updates(message as FormSubmissionSaveRequest)) as FormSubmissionSaveRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormSubmissionSaveRequest create() => FormSubmissionSaveRequest._();
  FormSubmissionSaveRequest createEmptyInstance() => create();
  static $pb.PbList<FormSubmissionSaveRequest> createRepeated() => $pb.PbList<FormSubmissionSaveRequest>();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionSaveRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormSubmissionSaveRequest>(create);
  static FormSubmissionSaveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  FormSubmissionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormSubmissionObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  FormSubmissionObject ensureData() => $_ensure(0);
}

class FormSubmissionSaveResponse extends $pb.GeneratedMessage {
  factory FormSubmissionSaveResponse({
    FormSubmissionObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  FormSubmissionSaveResponse._() : super();
  factory FormSubmissionSaveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormSubmissionSaveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormSubmissionSaveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<FormSubmissionObject>(1, _omitFieldNames ? '' : 'data', subBuilder: FormSubmissionObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormSubmissionSaveResponse clone() => FormSubmissionSaveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormSubmissionSaveResponse copyWith(void Function(FormSubmissionSaveResponse) updates) => super.copyWith((message) => updates(message as FormSubmissionSaveResponse)) as FormSubmissionSaveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormSubmissionSaveResponse create() => FormSubmissionSaveResponse._();
  FormSubmissionSaveResponse createEmptyInstance() => create();
  static $pb.PbList<FormSubmissionSaveResponse> createRepeated() => $pb.PbList<FormSubmissionSaveResponse>();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionSaveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormSubmissionSaveResponse>(create);
  static FormSubmissionSaveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FormSubmissionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormSubmissionObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  FormSubmissionObject ensureData() => $_ensure(0);
}

class FormSubmissionGetRequest extends $pb.GeneratedMessage {
  factory FormSubmissionGetRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  FormSubmissionGetRequest._() : super();
  factory FormSubmissionGetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormSubmissionGetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormSubmissionGetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormSubmissionGetRequest clone() => FormSubmissionGetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormSubmissionGetRequest copyWith(void Function(FormSubmissionGetRequest) updates) => super.copyWith((message) => updates(message as FormSubmissionGetRequest)) as FormSubmissionGetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormSubmissionGetRequest create() => FormSubmissionGetRequest._();
  FormSubmissionGetRequest createEmptyInstance() => create();
  static $pb.PbList<FormSubmissionGetRequest> createRepeated() => $pb.PbList<FormSubmissionGetRequest>();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionGetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormSubmissionGetRequest>(create);
  static FormSubmissionGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class FormSubmissionGetResponse extends $pb.GeneratedMessage {
  factory FormSubmissionGetResponse({
    FormSubmissionObject? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  FormSubmissionGetResponse._() : super();
  factory FormSubmissionGetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormSubmissionGetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormSubmissionGetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOM<FormSubmissionObject>(1, _omitFieldNames ? '' : 'data', subBuilder: FormSubmissionObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormSubmissionGetResponse clone() => FormSubmissionGetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormSubmissionGetResponse copyWith(void Function(FormSubmissionGetResponse) updates) => super.copyWith((message) => updates(message as FormSubmissionGetResponse)) as FormSubmissionGetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormSubmissionGetResponse create() => FormSubmissionGetResponse._();
  FormSubmissionGetResponse createEmptyInstance() => create();
  static $pb.PbList<FormSubmissionGetResponse> createRepeated() => $pb.PbList<FormSubmissionGetResponse>();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionGetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormSubmissionGetResponse>(create);
  static FormSubmissionGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FormSubmissionObject get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(FormSubmissionObject v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  FormSubmissionObject ensureData() => $_ensure(0);
}

class FormSubmissionSearchRequest extends $pb.GeneratedMessage {
  factory FormSubmissionSearchRequest({
    $core.String? entityId,
    $core.String? entityType,
    $core.String? templateId,
    $7.PageCursor? cursor,
  }) {
    final $result = create();
    if (entityId != null) {
      $result.entityId = entityId;
    }
    if (entityType != null) {
      $result.entityType = entityType;
    }
    if (templateId != null) {
      $result.templateId = templateId;
    }
    if (cursor != null) {
      $result.cursor = cursor;
    }
    return $result;
  }
  FormSubmissionSearchRequest._() : super();
  factory FormSubmissionSearchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormSubmissionSearchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormSubmissionSearchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'entityId')
    ..aOS(2, _omitFieldNames ? '' : 'entityType')
    ..aOS(3, _omitFieldNames ? '' : 'templateId')
    ..aOM<$7.PageCursor>(4, _omitFieldNames ? '' : 'cursor', subBuilder: $7.PageCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormSubmissionSearchRequest clone() => FormSubmissionSearchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormSubmissionSearchRequest copyWith(void Function(FormSubmissionSearchRequest) updates) => super.copyWith((message) => updates(message as FormSubmissionSearchRequest)) as FormSubmissionSearchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormSubmissionSearchRequest create() => FormSubmissionSearchRequest._();
  FormSubmissionSearchRequest createEmptyInstance() => create();
  static $pb.PbList<FormSubmissionSearchRequest> createRepeated() => $pb.PbList<FormSubmissionSearchRequest>();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionSearchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormSubmissionSearchRequest>(create);
  static FormSubmissionSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entityId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEntityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntityId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get entityType => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEntityType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get templateId => $_getSZ(2);
  @$pb.TagNumber(3)
  set templateId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTemplateId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTemplateId() => clearField(3);

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
}

class FormSubmissionSearchResponse extends $pb.GeneratedMessage {
  factory FormSubmissionSearchResponse({
    $core.Iterable<FormSubmissionObject>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data.addAll(data);
    }
    return $result;
  }
  FormSubmissionSearchResponse._() : super();
  factory FormSubmissionSearchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FormSubmissionSearchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FormSubmissionSearchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'identity.v1'), createEmptyInstance: create)
    ..pc<FormSubmissionObject>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: FormSubmissionObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FormSubmissionSearchResponse clone() => FormSubmissionSearchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FormSubmissionSearchResponse copyWith(void Function(FormSubmissionSearchResponse) updates) => super.copyWith((message) => updates(message as FormSubmissionSearchResponse)) as FormSubmissionSearchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FormSubmissionSearchResponse create() => FormSubmissionSearchResponse._();
  FormSubmissionSearchResponse createEmptyInstance() => create();
  static $pb.PbList<FormSubmissionSearchResponse> createRepeated() => $pb.PbList<FormSubmissionSearchResponse>();
  @$core.pragma('dart2js:noInline')
  static FormSubmissionSearchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FormSubmissionSearchResponse>(create);
  static FormSubmissionSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<FormSubmissionObject> get data => $_getList(0);
}

class IdentityServiceApi {
  $pb.RpcClient _client;
  IdentityServiceApi(this._client);

  $async.Future<OrganizationSaveResponse> organizationSave($pb.ClientContext? ctx, OrganizationSaveRequest request) =>
    _client.invoke<OrganizationSaveResponse>(ctx, 'IdentityService', 'OrganizationSave', request, OrganizationSaveResponse())
  ;
  $async.Future<OrganizationGetResponse> organizationGet($pb.ClientContext? ctx, OrganizationGetRequest request) =>
    _client.invoke<OrganizationGetResponse>(ctx, 'IdentityService', 'OrganizationGet', request, OrganizationGetResponse())
  ;
  $async.Future<OrganizationSearchResponse> organizationSearch($pb.ClientContext? ctx, $7.SearchRequest request) =>
    _client.invoke<OrganizationSearchResponse>(ctx, 'IdentityService', 'OrganizationSearch', request, OrganizationSearchResponse())
  ;
  $async.Future<OrgUnitSaveResponse> orgUnitSave($pb.ClientContext? ctx, OrgUnitSaveRequest request) =>
    _client.invoke<OrgUnitSaveResponse>(ctx, 'IdentityService', 'OrgUnitSave', request, OrgUnitSaveResponse())
  ;
  $async.Future<OrgUnitGetResponse> orgUnitGet($pb.ClientContext? ctx, OrgUnitGetRequest request) =>
    _client.invoke<OrgUnitGetResponse>(ctx, 'IdentityService', 'OrgUnitGet', request, OrgUnitGetResponse())
  ;
  $async.Future<OrgUnitSearchResponse> orgUnitSearch($pb.ClientContext? ctx, OrgUnitSearchRequest request) =>
    _client.invoke<OrgUnitSearchResponse>(ctx, 'IdentityService', 'OrgUnitSearch', request, OrgUnitSearchResponse())
  ;
  $async.Future<WorkforceMemberSaveResponse> workforceMemberSave($pb.ClientContext? ctx, WorkforceMemberSaveRequest request) =>
    _client.invoke<WorkforceMemberSaveResponse>(ctx, 'IdentityService', 'WorkforceMemberSave', request, WorkforceMemberSaveResponse())
  ;
  $async.Future<WorkforceMemberGetResponse> workforceMemberGet($pb.ClientContext? ctx, WorkforceMemberGetRequest request) =>
    _client.invoke<WorkforceMemberGetResponse>(ctx, 'IdentityService', 'WorkforceMemberGet', request, WorkforceMemberGetResponse())
  ;
  $async.Future<WorkforceMemberSearchResponse> workforceMemberSearch($pb.ClientContext? ctx, WorkforceMemberSearchRequest request) =>
    _client.invoke<WorkforceMemberSearchResponse>(ctx, 'IdentityService', 'WorkforceMemberSearch', request, WorkforceMemberSearchResponse())
  ;
  $async.Future<DepartmentSaveResponse> departmentSave($pb.ClientContext? ctx, DepartmentSaveRequest request) =>
    _client.invoke<DepartmentSaveResponse>(ctx, 'IdentityService', 'DepartmentSave', request, DepartmentSaveResponse())
  ;
  $async.Future<DepartmentGetResponse> departmentGet($pb.ClientContext? ctx, DepartmentGetRequest request) =>
    _client.invoke<DepartmentGetResponse>(ctx, 'IdentityService', 'DepartmentGet', request, DepartmentGetResponse())
  ;
  $async.Future<DepartmentSearchResponse> departmentSearch($pb.ClientContext? ctx, DepartmentSearchRequest request) =>
    _client.invoke<DepartmentSearchResponse>(ctx, 'IdentityService', 'DepartmentSearch', request, DepartmentSearchResponse())
  ;
  $async.Future<PositionSaveResponse> positionSave($pb.ClientContext? ctx, PositionSaveRequest request) =>
    _client.invoke<PositionSaveResponse>(ctx, 'IdentityService', 'PositionSave', request, PositionSaveResponse())
  ;
  $async.Future<PositionGetResponse> positionGet($pb.ClientContext? ctx, PositionGetRequest request) =>
    _client.invoke<PositionGetResponse>(ctx, 'IdentityService', 'PositionGet', request, PositionGetResponse())
  ;
  $async.Future<PositionSearchResponse> positionSearch($pb.ClientContext? ctx, PositionSearchRequest request) =>
    _client.invoke<PositionSearchResponse>(ctx, 'IdentityService', 'PositionSearch', request, PositionSearchResponse())
  ;
  $async.Future<PositionAssignmentSaveResponse> positionAssignmentSave($pb.ClientContext? ctx, PositionAssignmentSaveRequest request) =>
    _client.invoke<PositionAssignmentSaveResponse>(ctx, 'IdentityService', 'PositionAssignmentSave', request, PositionAssignmentSaveResponse())
  ;
  $async.Future<PositionAssignmentGetResponse> positionAssignmentGet($pb.ClientContext? ctx, PositionAssignmentGetRequest request) =>
    _client.invoke<PositionAssignmentGetResponse>(ctx, 'IdentityService', 'PositionAssignmentGet', request, PositionAssignmentGetResponse())
  ;
  $async.Future<PositionAssignmentSearchResponse> positionAssignmentSearch($pb.ClientContext? ctx, PositionAssignmentSearchRequest request) =>
    _client.invoke<PositionAssignmentSearchResponse>(ctx, 'IdentityService', 'PositionAssignmentSearch', request, PositionAssignmentSearchResponse())
  ;
  $async.Future<InternalTeamSaveResponse> internalTeamSave($pb.ClientContext? ctx, InternalTeamSaveRequest request) =>
    _client.invoke<InternalTeamSaveResponse>(ctx, 'IdentityService', 'InternalTeamSave', request, InternalTeamSaveResponse())
  ;
  $async.Future<InternalTeamGetResponse> internalTeamGet($pb.ClientContext? ctx, InternalTeamGetRequest request) =>
    _client.invoke<InternalTeamGetResponse>(ctx, 'IdentityService', 'InternalTeamGet', request, InternalTeamGetResponse())
  ;
  $async.Future<InternalTeamSearchResponse> internalTeamSearch($pb.ClientContext? ctx, InternalTeamSearchRequest request) =>
    _client.invoke<InternalTeamSearchResponse>(ctx, 'IdentityService', 'InternalTeamSearch', request, InternalTeamSearchResponse())
  ;
  $async.Future<TeamMembershipSaveResponse> teamMembershipSave($pb.ClientContext? ctx, TeamMembershipSaveRequest request) =>
    _client.invoke<TeamMembershipSaveResponse>(ctx, 'IdentityService', 'TeamMembershipSave', request, TeamMembershipSaveResponse())
  ;
  $async.Future<TeamMembershipGetResponse> teamMembershipGet($pb.ClientContext? ctx, TeamMembershipGetRequest request) =>
    _client.invoke<TeamMembershipGetResponse>(ctx, 'IdentityService', 'TeamMembershipGet', request, TeamMembershipGetResponse())
  ;
  $async.Future<TeamMembershipSearchResponse> teamMembershipSearch($pb.ClientContext? ctx, TeamMembershipSearchRequest request) =>
    _client.invoke<TeamMembershipSearchResponse>(ctx, 'IdentityService', 'TeamMembershipSearch', request, TeamMembershipSearchResponse())
  ;
  $async.Future<AccessRoleAssignmentSaveResponse> accessRoleAssignmentSave($pb.ClientContext? ctx, AccessRoleAssignmentSaveRequest request) =>
    _client.invoke<AccessRoleAssignmentSaveResponse>(ctx, 'IdentityService', 'AccessRoleAssignmentSave', request, AccessRoleAssignmentSaveResponse())
  ;
  $async.Future<AccessRoleAssignmentGetResponse> accessRoleAssignmentGet($pb.ClientContext? ctx, AccessRoleAssignmentGetRequest request) =>
    _client.invoke<AccessRoleAssignmentGetResponse>(ctx, 'IdentityService', 'AccessRoleAssignmentGet', request, AccessRoleAssignmentGetResponse())
  ;
  $async.Future<AccessRoleAssignmentSearchResponse> accessRoleAssignmentSearch($pb.ClientContext? ctx, AccessRoleAssignmentSearchRequest request) =>
    _client.invoke<AccessRoleAssignmentSearchResponse>(ctx, 'IdentityService', 'AccessRoleAssignmentSearch', request, AccessRoleAssignmentSearchResponse())
  ;
  $async.Future<InvestorSaveResponse> investorSave($pb.ClientContext? ctx, InvestorSaveRequest request) =>
    _client.invoke<InvestorSaveResponse>(ctx, 'IdentityService', 'InvestorSave', request, InvestorSaveResponse())
  ;
  $async.Future<InvestorGetResponse> investorGet($pb.ClientContext? ctx, InvestorGetRequest request) =>
    _client.invoke<InvestorGetResponse>(ctx, 'IdentityService', 'InvestorGet', request, InvestorGetResponse())
  ;
  $async.Future<InvestorSearchResponse> investorSearch($pb.ClientContext? ctx, InvestorSearchRequest request) =>
    _client.invoke<InvestorSearchResponse>(ctx, 'IdentityService', 'InvestorSearch', request, InvestorSearchResponse())
  ;
  $async.Future<ClientGroupSaveResponse> clientGroupSave($pb.ClientContext? ctx, ClientGroupSaveRequest request) =>
    _client.invoke<ClientGroupSaveResponse>(ctx, 'IdentityService', 'ClientGroupSave', request, ClientGroupSaveResponse())
  ;
  $async.Future<ClientGroupGetResponse> clientGroupGet($pb.ClientContext? ctx, ClientGroupGetRequest request) =>
    _client.invoke<ClientGroupGetResponse>(ctx, 'IdentityService', 'ClientGroupGet', request, ClientGroupGetResponse())
  ;
  $async.Future<ClientGroupSearchResponse> clientGroupSearch($pb.ClientContext? ctx, ClientGroupSearchRequest request) =>
    _client.invoke<ClientGroupSearchResponse>(ctx, 'IdentityService', 'ClientGroupSearch', request, ClientGroupSearchResponse())
  ;
  $async.Future<MembershipSaveResponse> membershipSave($pb.ClientContext? ctx, MembershipSaveRequest request) =>
    _client.invoke<MembershipSaveResponse>(ctx, 'IdentityService', 'MembershipSave', request, MembershipSaveResponse())
  ;
  $async.Future<MembershipGetResponse> membershipGet($pb.ClientContext? ctx, MembershipGetRequest request) =>
    _client.invoke<MembershipGetResponse>(ctx, 'IdentityService', 'MembershipGet', request, MembershipGetResponse())
  ;
  $async.Future<MembershipSearchResponse> membershipSearch($pb.ClientContext? ctx, MembershipSearchRequest request) =>
    _client.invoke<MembershipSearchResponse>(ctx, 'IdentityService', 'MembershipSearch', request, MembershipSearchResponse())
  ;
  $async.Future<InvestorAccountSaveResponse> investorAccountSave($pb.ClientContext? ctx, InvestorAccountSaveRequest request) =>
    _client.invoke<InvestorAccountSaveResponse>(ctx, 'IdentityService', 'InvestorAccountSave', request, InvestorAccountSaveResponse())
  ;
  $async.Future<InvestorAccountGetResponse> investorAccountGet($pb.ClientContext? ctx, InvestorAccountGetRequest request) =>
    _client.invoke<InvestorAccountGetResponse>(ctx, 'IdentityService', 'InvestorAccountGet', request, InvestorAccountGetResponse())
  ;
  $async.Future<InvestorAccountSearchResponse> investorAccountSearch($pb.ClientContext? ctx, InvestorAccountSearchRequest request) =>
    _client.invoke<InvestorAccountSearchResponse>(ctx, 'IdentityService', 'InvestorAccountSearch', request, InvestorAccountSearchResponse())
  ;
  $async.Future<InvestorDepositResponse> investorDeposit($pb.ClientContext? ctx, InvestorDepositRequest request) =>
    _client.invoke<InvestorDepositResponse>(ctx, 'IdentityService', 'InvestorDeposit', request, InvestorDepositResponse())
  ;
  $async.Future<InvestorWithdrawResponse> investorWithdraw($pb.ClientContext? ctx, InvestorWithdrawRequest request) =>
    _client.invoke<InvestorWithdrawResponse>(ctx, 'IdentityService', 'InvestorWithdraw', request, InvestorWithdrawResponse())
  ;
  $async.Future<ClientDataSaveResponse> clientDataSave($pb.ClientContext? ctx, ClientDataSaveRequest request) =>
    _client.invoke<ClientDataSaveResponse>(ctx, 'IdentityService', 'ClientDataSave', request, ClientDataSaveResponse())
  ;
  $async.Future<ClientDataGetResponse> clientDataGet($pb.ClientContext? ctx, ClientDataGetRequest request) =>
    _client.invoke<ClientDataGetResponse>(ctx, 'IdentityService', 'ClientDataGet', request, ClientDataGetResponse())
  ;
  $async.Future<ClientDataListResponse> clientDataList($pb.ClientContext? ctx, ClientDataListRequest request) =>
    _client.invoke<ClientDataListResponse>(ctx, 'IdentityService', 'ClientDataList', request, ClientDataListResponse())
  ;
  $async.Future<ClientDataVerifyResponse> clientDataVerify($pb.ClientContext? ctx, ClientDataVerifyRequest request) =>
    _client.invoke<ClientDataVerifyResponse>(ctx, 'IdentityService', 'ClientDataVerify', request, ClientDataVerifyResponse())
  ;
  $async.Future<ClientDataRejectResponse> clientDataReject($pb.ClientContext? ctx, ClientDataRejectRequest request) =>
    _client.invoke<ClientDataRejectResponse>(ctx, 'IdentityService', 'ClientDataReject', request, ClientDataRejectResponse())
  ;
  $async.Future<ClientDataRequestInfoResponse> clientDataRequestInfo($pb.ClientContext? ctx, ClientDataRequestInfoRequest request) =>
    _client.invoke<ClientDataRequestInfoResponse>(ctx, 'IdentityService', 'ClientDataRequestInfo', request, ClientDataRequestInfoResponse())
  ;
  $async.Future<ClientDataHistoryResponse> clientDataHistory($pb.ClientContext? ctx, ClientDataHistoryRequest request) =>
    _client.invoke<ClientDataHistoryResponse>(ctx, 'IdentityService', 'ClientDataHistory', request, ClientDataHistoryResponse())
  ;
  $async.Future<FormTemplateSaveResponse> formTemplateSave($pb.ClientContext? ctx, FormTemplateSaveRequest request) =>
    _client.invoke<FormTemplateSaveResponse>(ctx, 'IdentityService', 'FormTemplateSave', request, FormTemplateSaveResponse())
  ;
  $async.Future<FormTemplateGetResponse> formTemplateGet($pb.ClientContext? ctx, FormTemplateGetRequest request) =>
    _client.invoke<FormTemplateGetResponse>(ctx, 'IdentityService', 'FormTemplateGet', request, FormTemplateGetResponse())
  ;
  $async.Future<FormTemplateSearchResponse> formTemplateSearch($pb.ClientContext? ctx, FormTemplateSearchRequest request) =>
    _client.invoke<FormTemplateSearchResponse>(ctx, 'IdentityService', 'FormTemplateSearch', request, FormTemplateSearchResponse())
  ;
  $async.Future<FormTemplatePublishResponse> formTemplatePublish($pb.ClientContext? ctx, FormTemplatePublishRequest request) =>
    _client.invoke<FormTemplatePublishResponse>(ctx, 'IdentityService', 'FormTemplatePublish', request, FormTemplatePublishResponse())
  ;
  $async.Future<FormSubmissionSaveResponse> formSubmissionSave($pb.ClientContext? ctx, FormSubmissionSaveRequest request) =>
    _client.invoke<FormSubmissionSaveResponse>(ctx, 'IdentityService', 'FormSubmissionSave', request, FormSubmissionSaveResponse())
  ;
  $async.Future<FormSubmissionGetResponse> formSubmissionGet($pb.ClientContext? ctx, FormSubmissionGetRequest request) =>
    _client.invoke<FormSubmissionGetResponse>(ctx, 'IdentityService', 'FormSubmissionGet', request, FormSubmissionGetResponse())
  ;
  $async.Future<FormSubmissionSearchResponse> formSubmissionSearch($pb.ClientContext? ctx, FormSubmissionSearchRequest request) =>
    _client.invoke<FormSubmissionSearchResponse>(ctx, 'IdentityService', 'FormSubmissionSearch', request, FormSubmissionSearchResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
