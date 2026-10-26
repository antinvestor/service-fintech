import 'package:antinvestor_ui_core/responsive/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_sidebar.dart';

/// A destination on the phone bottom bar.
class PhoneDestination {
  const PhoneDestination(this.route, this.label, this.icon, this.selectedIcon);

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// The field agent's daily work, reachable with one thumb on a phone.
List<PhoneDestination> phoneDestinations() => [
  const PhoneDestination('/', 'Home', Icons.home_outlined, Icons.home),
  const PhoneDestination(
    '/clients',
    'Clients',
    Icons.people_outline,
    Icons.people,
  ),
  const PhoneDestination(
    '/loans',
    'Loans',
    Icons.account_balance_wallet_outlined,
    Icons.account_balance_wallet,
  ),
];

/// The bottom-bar index for [location]: the destination with the longest
/// matching route prefix, or null when none matches.
int? phoneDestinationIndex(
  List<PhoneDestination> destinations,
  String location,
) {
  int? best;
  var bestLength = -1;
  for (var i = 0; i < destinations.length; i++) {
    final route = destinations[i].route;
    final matches = route == '/'
        ? location == '/'
        : location == route || location.startsWith('$route/');
    if (matches && route.length > bestLength) {
      best = i;
      bestLength = route.length;
    }
  }
  return best;
}

/// Seed app shell: persistent sidebar on desktop; on a phone, a bottom bar
/// for the daily destinations and a drawer for everything else.
class SeedShell extends ConsumerWidget {
  const SeedShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = AppBreakpoints.isMobile(constraints.maxWidth);

        if (isMobile) {
          final destinations = phoneDestinations();
          final selected = phoneDestinationIndex(destinations, currentRoute);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Seed'),
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
            drawer: Drawer(
              child: AppSidebar(
                currentRoute: currentRoute,
                isDrawer: true,
                onNavigate: () => Navigator.of(context).pop(),
              ),
            ),
            body: child,
            bottomNavigationBar: NavigationBar(
              key: const Key('phone-navigation'),
              // A route outside the bar (reached from the drawer) leaves
              // nothing highlighted rather than the wrong destination.
              selectedIndex: selected ?? 0,
              indicatorColor: selected == null ? Colors.transparent : null,
              onDestinationSelected: (i) => context.go(destinations[i].route),
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              AppSidebar(currentRoute: currentRoute),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
