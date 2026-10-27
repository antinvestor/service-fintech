import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/permissions/permission_provider.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/investor_account_detail_screen.dart';
import '../screens/investor_accounts_screen.dart';

/// Routes, navigation and the permission manifest for the funding module.
///
/// Permission keys mirror `service_permissions` in `funding.proto`; the proto
/// is the source of truth and this manifest only labels them for the host.
class FundingRouteModule extends RouteModule {
  @override
  String get moduleId => 'funding';

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/funding/accounts',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => InvestorAccountsScreen(
          canManage: ref.watch(
            hasPermissionProvider('investor_account_manage'),
          ),
        ),
      ),
      routes: [
        GoRoute(
          path: ':accountId',
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => InvestorAccountDetailScreen(
              accountId: state.pathParameters['accountId']!,
              canManage: ref.watch(
                hasPermissionProvider('investor_account_manage'),
              ),
            ),
          ),
        ),
      ],
    ),
  ];

  @override
  List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'funding_accounts',
      label: 'Investor Accounts',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      route: '/funding/accounts',
      requiredPermissions: {'investor_account_view'},
    ),
  ];

  @override
  Map<String, Set<String>> get routePermissions => {
    '/funding/accounts': {'investor_account_view'},
  };

  @override
  PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_funding',
    permissions: [
      PermissionEntry(
        key: 'investor_account_view',
        label: 'View Investor Accounts',
        scope: PermissionScope.service,
      ),
      PermissionEntry(
        key: 'investor_account_manage',
        label: 'Open Accounts, Deposit and Withdraw',
        scope: PermissionScope.action,
      ),
      PermissionEntry(
        key: 'fund_manage',
        label: 'Fund Loans',
        scope: PermissionScope.action,
      ),
    ],
  );
}
