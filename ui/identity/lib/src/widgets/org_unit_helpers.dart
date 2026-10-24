import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:flutter/material.dart' show IconData, Icons;

/// Human-readable label for an OrgUnitType.
String orgUnitTypeLabel(OrgUnitType type) {
  switch (type) {
    case OrgUnitType.ORG_UNIT_TYPE_REGION:
      return 'Region';
    case OrgUnitType.ORG_UNIT_TYPE_ZONE:
      return 'Zone';
    case OrgUnitType.ORG_UNIT_TYPE_AREA:
      return 'Area';
    case OrgUnitType.ORG_UNIT_TYPE_CLUSTER:
      return 'Cluster';
    case OrgUnitType.ORG_UNIT_TYPE_BRANCH:
      return 'Branch';
    case OrgUnitType.ORG_UNIT_TYPE_OTHER:
      return 'Other';
    case OrgUnitType.ORG_UNIT_TYPE_UNSPECIFIED:
      return 'Unspecified';
  }
  return 'Unspecified';
}

/// Editable org unit types for dropdowns.
const editableOrgUnitTypes = <OrgUnitType>[
  OrgUnitType.ORG_UNIT_TYPE_REGION,
  OrgUnitType.ORG_UNIT_TYPE_ZONE,
  OrgUnitType.ORG_UNIT_TYPE_AREA,
  OrgUnitType.ORG_UNIT_TYPE_CLUSTER,
  OrgUnitType.ORG_UNIT_TYPE_BRANCH,
  OrgUnitType.ORG_UNIT_TYPE_OTHER,
];

/// Human-readable label for a string-based engagement type.
/// The value is organization-defined (e.g. "employee", "contractor", "agent").
String engagementLabel(String type) {
  if (type.isEmpty) return 'Unspecified';
  // Capitalize: "employee" → "Employee", "service_account" → "Service Account"
  return type
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// Human-readable label for a string-based team membership role.
String membershipRoleLabel(String role) {
  if (role.isEmpty) return 'Unspecified';
  return role
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// Human-readable label for a string-based team type.
String teamTypeLabel(String type) {
  if (type.isEmpty) return 'Unspecified';
  return type
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// Icon for a string-based team type.
IconData teamTypeIcon(String type) => switch (type.toLowerCase()) {
  'portfolio' => Icons.pie_chart_outline,
  'servicing' => Icons.support_agent,
  'collections' => Icons.account_balance_wallet,
  'recovery' => Icons.assignment_return,
  'sales' => Icons.trending_up,
  'pilot' => Icons.science_outlined,
  'shared_service' => Icons.hub_outlined,
  'agent_network' => Icons.groups_3_outlined,
  'external_partner' => Icons.handshake_outlined,
  'channel' => Icons.route_outlined,
  _ => Icons.groups_outlined,
};

/// Human-readable label for an AccessScopeType.
String scopeLabel(AccessScopeType scope) => switch (scope) {
  AccessScopeType.ACCESS_SCOPE_TYPE_GLOBAL => 'Global',
  AccessScopeType.ACCESS_SCOPE_TYPE_ORGANIZATION => 'Organization',
  AccessScopeType.ACCESS_SCOPE_TYPE_ORG_UNIT => 'Org Unit',
  AccessScopeType.ACCESS_SCOPE_TYPE_TEAM => 'Team',
  _ => 'Unspecified',
};
