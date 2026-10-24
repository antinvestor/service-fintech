// This is a generated file - do not edit.
//
// Generated from field/v1/field.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// AgentType defines whether an agent is an individual or an organization.
class AgentType extends $pb.ProtobufEnum {
  static const AgentType AGENT_TYPE_UNSPECIFIED =
      AgentType._(0, _omitEnumNames ? '' : 'AGENT_TYPE_UNSPECIFIED');
  static const AgentType AGENT_TYPE_INDIVIDUAL =
      AgentType._(1, _omitEnumNames ? '' : 'AGENT_TYPE_INDIVIDUAL');
  static const AgentType AGENT_TYPE_ORGANIZATION =
      AgentType._(2, _omitEnumNames ? '' : 'AGENT_TYPE_ORGANIZATION');

  static const $core.List<AgentType> values = <AgentType>[
    AGENT_TYPE_UNSPECIFIED,
    AGENT_TYPE_INDIVIDUAL,
    AGENT_TYPE_ORGANIZATION,
  ];

  static final $core.List<AgentType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static AgentType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AgentType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
