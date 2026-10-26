import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/permissions/permission_provider.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/savings_account_detail_screen.dart';
import '../screens/savings_accounts_screen.dart';
import '../screens/savings_products_screen.dart';
import '../screens/savings_statement_screen.dart';
import '../screens/withdrawal_approval_queue_screen.dart';

/// Routes, navigation and the permission manifest for the savings module.
///
/// Permission keys mirror `service_permissions` in `savings.proto`; the proto
/// is the source of truth and this manifest only labels them for the host.
class SavingsRouteModule extends RouteModule {
  @override
  String get moduleId => 'savings';

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/savings',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => SavingsAccountsScreen(
          canManage: ref.watch(hasPermissionProvider('savings_account_manage')),
        ),
      ),
      routes: [
        GoRoute(
          path: 'products',
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => SavingsProductsScreen(
              canManage: ref.watch(
                hasPermissionProvider('savings_product_manage'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: 'withdrawals/pending',
          // Approve and cancel are shown only to callers holding
          // withdrawal_manage, not offered to everyone who can read the
          // queue and refused by the service afterwards.
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => WithdrawalApprovalQueueScreen(
              canManage: ref.watch(hasPermissionProvider('withdrawal_manage')),
            ),
          ),
        ),
        GoRoute(
          path: ':accountId',
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => SavingsAccountDetailScreen(
              accountId: state.pathParameters['accountId']!,
              canManageAccount: ref.watch(
                hasPermissionProvider('savings_account_manage'),
              ),
              canWithdraw: ref.watch(
                hasPermissionProvider('withdrawal_manage'),
              ),
            ),
          ),
          routes: [
            GoRoute(
              path: 'statement',
              builder: (context, state) => SavingsStatementScreen(
                accountId: state.pathParameters['accountId']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'savings',
      label: 'Savings',
      icon: Icons.savings_outlined,
      activeIcon: Icons.savings,
      route: '/savings',
      requiredPermissions: {'savings_account_view'},
    ),
    const NavItem(
      id: 'savings_products',
      label: 'Savings Products',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      route: '/savings/products',
      requiredPermissions: {'savings_product_view'},
    ),
    const NavItem(
      id: 'savings_withdrawal_queue',
      label: 'Withdrawal Approvals',
      icon: Icons.approval_outlined,
      activeIcon: Icons.approval,
      route: '/savings/withdrawals/pending',
      requiredPermissions: {'withdrawal_view'},
    ),
  ];

  @override
  Map<String, Set<String>> get routePermissions => {
    '/savings': {'savings_account_view'},
    '/savings/products': {'savings_product_view'},
    '/savings/withdrawals/pending': {'withdrawal_view'},
  };

  @override
  PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_savings',
    permissions: [
      PermissionEntry(
        key: 'savings_account_view',
        label: 'View Savings Accounts',
        scope: PermissionScope.service,
      ),
      PermissionEntry(
        key: 'savings_account_manage',
        label: 'Manage Savings Accounts',
        scope: PermissionScope.action,
      ),
      PermissionEntry(
        key: 'savings_product_view',
        label: 'View Savings Products',
        scope: PermissionScope.feature,
      ),
      PermissionEntry(
        key: 'savings_product_manage',
        label: 'Manage Savings Products',
        scope: PermissionScope.action,
      ),
      PermissionEntry(
        key: 'deposit_view',
        label: 'View Deposits',
        scope: PermissionScope.feature,
      ),
      PermissionEntry(
        key: 'withdrawal_view',
        label: 'View Withdrawals',
        scope: PermissionScope.feature,
      ),
      PermissionEntry(
        key: 'withdrawal_manage',
        label: 'Approve and Cancel Withdrawals',
        scope: PermissionScope.action,
      ),
      PermissionEntry(
        key: 'interest_view',
        label: 'View Interest Accruals',
        scope: PermissionScope.feature,
      ),
      PermissionEntry(
        key: 'savings_balance_view',
        label: 'View Balances and Statements',
        scope: PermissionScope.feature,
      ),
    ],
  );
}
