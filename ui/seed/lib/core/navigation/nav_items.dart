import 'package:antinvestor_ui_core/navigation/nav_items.dart' as core;
import 'package:antinvestor_ui_funding/antinvestor_ui_funding.dart'
    show FundingRouteModule;
import 'package:antinvestor_ui_loans/antinvestor_ui_loans.dart'
    show LoansRouteModule;
import 'package:antinvestor_ui_operations/antinvestor_ui_operations.dart'
    show OperationsRouteModule;
import 'package:flutter/material.dart';

/// A single navigation item that can contain children (submenus).
///
/// Visibility is gated by [requiredPermissions] (batch-checked at startup).
/// Items with no requiredPermissions are always visible.
class NavItem {
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.activeIcon,
    this.route,
    this.children = const [],
    this.requiredPermissions = const {},
    this.badge,
  });

  /// Adopts a nav item contributed by a library route module. Role-based
  /// gating is dropped: Seed gates on resolved permissions only.
  factory NavItem.fromCore(core.NavItem item) => NavItem(
    id: item.id,
    label: item.label,
    icon: item.icon,
    activeIcon: item.activeIcon,
    route: item.route,
    children: [for (final child in item.children) NavItem.fromCore(child)],
    requiredPermissions: item.requiredPermissions,
    badge: item.badge,
  );

  final String id;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String? route;
  final List<NavItem> children;
  final Set<String> requiredPermissions;
  final String? badge;

  bool get hasChildren => children.isNotEmpty;

  bool matchesRoute(String currentRoute) {
    if (routeMatches(route, currentRoute)) return true;
    return children.any((c) => c.matchesRoute(currentRoute));
  }

  /// Filter by granted permissions. Returns null if user can't see it.
  NavItem? filterByPermissions(Set<String> userPermissions) {
    if (requiredPermissions.isNotEmpty &&
        userPermissions.intersection(requiredPermissions).isEmpty) {
      return null;
    }

    final filteredChildren = children
        .map((c) => c.filterByPermissions(userPermissions))
        .whereType<NavItem>()
        .toList();

    if (route == null && filteredChildren.isEmpty && children.isNotEmpty) {
      return null;
    }

    return NavItem(
      id: id,
      label: label,
      icon: icon,
      activeIcon: activeIcon,
      route: route,
      children: filteredChildren,
      requiredPermissions: requiredPermissions,
      badge: badge,
    );
  }
}

/// Whether [location] is served by [route].
///
/// The dashboard lives at `/`, which is a prefix of every other location, so
/// it only ever matches exactly. Everything else matches its own subtree.
bool routeMatches(String? route, String location) {
  if (route == null) return false;
  if (route == '/') return location == '/';
  return location == route || location.startsWith('$route/');
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation tree — Seed product
// ─────────────────────────────────────────────────────────────────────────────

List<NavItem> buildNavItems() => [
  const NavItem(
    id: 'dashboard',
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    route: '/',
  ),
  const NavItem(
    id: 'organization',
    label: 'Organization',
    icon: Icons.business_outlined,
    activeIcon: Icons.business,
    children: [
      NavItem(
        id: 'organizations',
        label: 'Organizations',
        icon: Icons.account_balance_outlined,
        activeIcon: Icons.account_balance,
        route: '/organizations',
      ),
      NavItem(
        id: 'org_units',
        label: 'Org Units',
        icon: Icons.account_tree_outlined,
        activeIcon: Icons.account_tree,
        route: '/org-units',
      ),
      NavItem(
        id: 'departments',
        label: 'Departments',
        icon: Icons.folder_outlined,
        activeIcon: Icons.folder,
        route: '/departments',
      ),
      NavItem(
        id: 'form_templates',
        label: 'KYC Forms',
        icon: Icons.dynamic_form_outlined,
        activeIcon: Icons.dynamic_form,
        route: '/form-templates',
        requiredPermissions: {'form_template_view'},
      ),
    ],
  ),
  const NavItem(
    id: 'workforce',
    label: 'Workforce',
    icon: Icons.badge_outlined,
    activeIcon: Icons.badge,
    children: [
      NavItem(
        id: 'workforce_members',
        label: 'Members',
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        route: '/workforce',
      ),
      NavItem(
        id: 'teams',
        label: 'Teams',
        icon: Icons.groups_outlined,
        activeIcon: Icons.groups,
        route: '/teams',
      ),
      NavItem(
        id: 'access_roles',
        label: 'Access Roles',
        icon: Icons.admin_panel_settings_outlined,
        activeIcon: Icons.admin_panel_settings,
        route: '/access-roles',
        requiredPermissions: {'access_role_assignment_manage'},
      ),
    ],
  ),
  const NavItem(
    id: 'clients',
    label: 'Clients',
    icon: Icons.people_alt_outlined,
    activeIcon: Icons.people_alt,
    route: '/clients',
    requiredPermissions: {'client_view'},
  ),
  NavItem(
    id: 'loans_section',
    label: 'Loans',
    icon: Icons.account_balance_wallet_outlined,
    activeIcon: Icons.account_balance_wallet,
    children: _loansNavChildren(),
  ),
  NavItem(
    id: 'investors_section',
    label: 'Investors',
    icon: Icons.trending_up_outlined,
    activeIcon: Icons.trending_up,
    children: [
      const NavItem(
        id: 'investors',
        label: 'Investor Profiles',
        icon: Icons.person_search_outlined,
        activeIcon: Icons.person_search,
        route: '/investors',
      ),
      for (final item in FundingRouteModule().buildNavItems())
        NavItem.fromCore(item),
    ],
  ),
  NavItem(
    id: 'operations_section',
    label: 'Payments',
    icon: Icons.payments_outlined,
    activeIcon: Icons.payments,
    children: [
      for (final item in OperationsRouteModule().buildNavItems())
        NavItem.fromCore(item),
    ],
  ),
  const NavItem(
    id: 'limits',
    label: 'Limits',
    icon: Icons.tune_outlined,
    activeIcon: Icons.tune,
    children: [
      NavItem(
        id: 'limits_policies',
        label: 'Policies',
        icon: Icons.policy_outlined,
        activeIcon: Icons.policy,
        route: '/limits/policies',
      ),
      NavItem(
        id: 'limits_playground',
        label: 'Playground',
        icon: Icons.science_outlined,
        activeIcon: Icons.science,
        route: '/limits/playground',
      ),
      NavItem(
        id: 'limits_approvals',
        label: 'Approvals',
        icon: Icons.approval_outlined,
        activeIcon: Icons.approval,
        route: '/limits/approvals',
      ),
      NavItem(
        id: 'limits_ledger',
        label: 'Ledger',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        route: '/limits/ledger',
      ),
      NavItem(
        id: 'limits_audit',
        label: 'Audit',
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        route: '/limits/audit',
      ),
    ],
  ),
];

/// The loans section: the module's own items plus the sub-areas it only
/// guards through [LoansRouteModule.routePermissions]. Specific routes come
/// before `/loans`, whose subtree would otherwise claim them in
/// [requiredPermissionsForRoute].
List<NavItem> _loansNavChildren() {
  final module = LoansRouteModule();
  final guards = module.routePermissions;
  return [
    NavItem(
      id: 'loan_products',
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      route: '/loans/products',
      requiredPermissions: guards['/loans/products'] ?? const {},
    ),
    NavItem(
      id: 'loan_requests',
      label: 'Applications',
      icon: Icons.description_outlined,
      activeIcon: Icons.description,
      route: '/loans/requests',
      requiredPermissions: guards['/loans/requests'] ?? const {},
    ),
    NavItem(
      id: 'portfolio_report',
      label: 'Portfolio',
      icon: Icons.pie_chart_outline,
      activeIcon: Icons.pie_chart,
      route: '/reports/portfolio',
      requiredPermissions: guards['/reports/portfolio'] ?? const {},
    ),
    NavItem(
      id: 'loan_book',
      label: 'Loan Book',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      route: '/reports/loan-book',
      requiredPermissions: guards['/reports/loan-book'] ?? const {},
    ),
    for (final item in module.buildNavItems().reversed) NavItem.fromCore(item),
  ];
}

/// The permissions required to reach [location], gathered from the nav tree
/// so route guards and sidebar visibility can never disagree.
///
/// Returns an empty set for locations the nav tree does not gate.
Set<String> requiredPermissionsForRoute(String location) {
  Set<String>? search(NavItem item, Set<String> inherited) {
    final required = {...inherited, ...item.requiredPermissions};
    if (routeMatches(item.route, location)) return required;
    for (final child in item.children) {
      final found = search(child, required);
      if (found != null) return found;
    }
    return null;
  }

  for (final item in buildNavItems()) {
    final found = search(item, const {});
    if (found != null) return found;
  }
  return const {};
}
