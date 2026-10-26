import 'package:antinvestor_ui_core/navigation/nav_items.dart';
import 'package:antinvestor_ui_core/permissions/permission_manifest.dart';
import 'package:antinvestor_ui_core/permissions/permission_provider.dart';
import 'package:antinvestor_ui_core/routing/route_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/incoming_payments_screen.dart';
import '../screens/transfer_orders_screen.dart';

/// Routes, navigation and the permission manifest for the operations module.
///
/// Permission keys mirror `service_permissions` in `operations.proto`; the
/// proto is the source of truth and this manifest only labels them.
class OperationsRouteModule extends RouteModule {
  OperationsRouteModule({this.pickLoan});

  /// Offered in the assign dialog so staff can search for the loan.
  final LoanPicker? pickLoan;

  @override
  String get moduleId => 'operations';

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(
      path: '/operations/payments',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => IncomingPaymentsScreen(
          canAssign: ref.watch(hasPermissionProvider('payment_allocate')),
          pickLoan: pickLoan,
        ),
      ),
    ),
    GoRoute(
      path: '/operations/transfers',
      builder: (context, state) => const TransferOrdersScreen(),
    ),
  ];

  @override
  List<NavItem> buildNavItems() => [
    const NavItem(
      id: 'operations_payments',
      label: 'Incoming Payments',
      icon: Icons.call_received_outlined,
      activeIcon: Icons.call_received,
      route: '/operations/payments',
      requiredPermissions: {'payment_view'},
    ),
    const NavItem(
      id: 'operations_transfers',
      label: 'Transfer Orders',
      icon: Icons.swap_horiz_outlined,
      activeIcon: Icons.swap_horiz,
      route: '/operations/transfers',
      requiredPermissions: {'transfer_view'},
    ),
  ];

  @override
  Map<String, Set<String>> get routePermissions => {
    '/operations/payments': {'payment_view'},
    '/operations/transfers': {'transfer_view'},
  };

  @override
  PermissionManifest get permissionManifest => const PermissionManifest(
    namespace: 'service_operations',
    permissions: [
      PermissionEntry(
        key: 'payment_view',
        label: 'View Incoming Payments',
        scope: PermissionScope.feature,
      ),
      PermissionEntry(
        key: 'payment_allocate',
        label: 'Assign and Allocate Payments',
        scope: PermissionScope.action,
      ),
      PermissionEntry(
        key: 'transfer_view',
        label: 'View Transfer Orders',
        scope: PermissionScope.feature,
      ),
    ],
  );
}
