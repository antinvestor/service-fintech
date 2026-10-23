import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/permission_provider.dart';
import 'nav_items.dart';

part 'nav_state.g.dart';

/// Navigation items filtered by the caller's granted permissions.
///
/// Fails **closed**: an empty grant set, a capability service that cannot be
/// reached, and a provider-level error are all treated identically — every
/// permission-gated item is hidden and only unrestricted items remain.
@Riverpod(keepAlive: true)
Future<List<NavItem>> filteredNavItems(Ref ref) async {
  final resolution = await ref.watch(permissionResolutionProvider.future);
  return navItemsFor(resolution.available ? resolution.granted : const {});
}

/// Filters the nav tree down to what [permissions] allows. Exposed for tests
/// and for the pre-resolution sidebar render.
List<NavItem> navItemsFor(Set<String> permissions) => buildNavItems()
    .map((item) => item.filterByPermissions(permissions))
    .whereType<NavItem>()
    .toList();

/// Tracks which parent nav sections are expanded in the sidebar.
class SidebarExpansionState extends ChangeNotifier {
  final Set<String> _expanded = {};

  bool isExpanded(String id) => _expanded.contains(id);

  void toggle(String id) {
    if (_expanded.contains(id)) {
      _expanded.remove(id);
    } else {
      _expanded.add(id);
    }
    notifyListeners();
  }

  void expand(String id) {
    if (_expanded.add(id)) notifyListeners();
  }

  void collapse(String id) {
    if (_expanded.remove(id)) notifyListeners();
  }

  void expandForRoute(String route, List<NavItem> items) {
    for (final item in items) {
      if (item.hasChildren && item.matchesRoute(route)) {
        _expanded.add(item.id);
      }
    }
    notifyListeners();
  }
}

@Riverpod(keepAlive: true)
SidebarExpansionState sidebarExpansion(Ref ref) {
  return SidebarExpansionState();
}
