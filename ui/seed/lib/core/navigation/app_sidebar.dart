import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/auth_state_provider.dart';
import 'package:antinvestor_ui_core/auth/tenancy_context.dart';
import 'package:antinvestor_ui_core/widgets/profile_badge.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import 'nav_items.dart';
import 'nav_state.dart';

/// Enterprise sidebar / drawer navigation.
///
/// On desktop/tablet this is rendered as a persistent sidebar.
/// On mobile it is rendered inside a [Drawer].
class AppSidebar extends ConsumerStatefulWidget {
  const AppSidebar({
    super.key,
    required this.currentRoute,
    this.onNavigate,
    this.isDrawer = false,
  });

  final String currentRoute;
  final VoidCallback? onNavigate;
  final bool isDrawer;

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> {
  bool _initialExpansionDone = false;
  late SidebarExpansionState _expansionState;

  @override
  void initState() {
    super.initState();
    _expansionState = ref.read(sidebarExpansionProvider);
    _expansionState.addListener(_onExpansionChanged);
  }

  @override
  void dispose() {
    _expansionState.removeListener(_onExpansionChanged);
    super.dispose();
  }

  void _onExpansionChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final navItemsAsync = ref.watch(filteredNavItemsProvider);
    final theme = Theme.of(context);
    final userInfoAsync = ref.watch(currentProfileIdProvider);
    final displayNameAsync = ref.watch(currentDisplayNameProvider);

    // Until permissions resolve, show only the items that need none. Showing
    // the full menu first would leak the admin surface on every page load.
    final items =
        navItemsAsync.whenOrNull(data: (d) => d) ?? navItemsFor(const {});

    // Auto-expand current route's section on first build
    if (!_initialExpansionDone) {
      _initialExpansionDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _expansionState.expandForRoute(widget.currentRoute, items);
      });
    }

    return Container(
      width: 260,
      color: AppTheme.sidebarBackground(theme.colorScheme),
      child: Column(
        children: [
          const _BrandHeader(),
          _TenancyContextLabel(onNavigate: widget.onNavigate),
          Container(height: 1, color: Colors.white.withAlpha(15)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: [
                for (final item in items)
                  _buildNavItem(context, item, _expansionState, depth: 0),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withAlpha(15)),
          _UserFooter(
            displayName: displayNameAsync.whenOrNull(data: (name) => name),
            profileId: userInfoAsync.whenOrNull(data: (id) => id),
            onLogout: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavItem item,
    SidebarExpansionState expansion, {
    required int depth,
  }) {
    final isActive = routeMatches(item.route, widget.currentRoute);
    final isExpanded = expansion.isExpanded(item.id);

    if (item.hasChildren) {
      return _SectionTile(
        item: item,
        isExpanded: isExpanded,
        isActive: item.matchesRoute(widget.currentRoute),
        depth: depth,
        onToggle: () => expansion.toggle(item.id),
        children: [
          for (final child in item.children)
            _buildNavItem(context, child, expansion, depth: depth + 1),
        ],
      );
    }

    return _LeafTile(
      item: item,
      isActive: isActive,
      depth: depth,
      onTap: () {
        if (item.route != null) {
          context.go(item.route!);
          widget.onNavigate?.call();
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand header — white on navy with gradient logo
// ─────────────────────────────────────────────────────────────────────────────

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: DesignTokens.primaryGradient,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: const Icon(
              Icons.account_balance,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AntInvestor',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Seed Platform',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withAlpha(130),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tenancy context label — shows org/branch from tenancy context
// ─────────────────────────────────────────────────────────────────────────────

class _TenancyContextLabel extends ConsumerWidget {
  const _TenancyContextLabel({this.onNavigate});
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenancy = ref.watch(tenancyContextProvider);
    final orgName = tenancy.organizationName;
    final branchName = tenancy.branchName;

    if (orgName.isEmpty && branchName.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Colors.white.withAlpha(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (orgName.isNotEmpty)
              Text(
                orgName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withAlpha(200),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            if (branchName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  branchName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withAlpha(160),
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section tile (expandable parent)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.item,
    required this.isExpanded,
    required this.isActive,
    required this.depth,
    required this.onToggle,
    required this.children,
  });

  final NavItem item;
  final bool isExpanded;
  final bool isActive;
  final int depth;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final leftPad = 8.0 + (depth * 16.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (depth == 0) const SizedBox(height: 4),
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white.withAlpha(12),
          splashColor: Colors.white.withAlpha(20),
          child: Container(
            padding: EdgeInsets.only(
              left: leftPad,
              right: 8,
              top: 8,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive ? Colors.white.withAlpha(18) : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? (item.activeIcon ?? item.icon) : item.icon,
                  size: 20,
                  color: isActive ? Colors.white : Colors.white.withAlpha(180),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withAlpha(180),
                      fontSize: 13,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.white.withAlpha(100),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeInOut,
        ),
        if (depth == 0) const SizedBox(height: 2),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Leaf tile (navigatable item) with left accent bar
// ─────────────────────────────────────────────────────────────────────────────

class _LeafTile extends StatelessWidget {
  const _LeafTile({
    required this.item,
    required this.isActive,
    required this.depth,
    required this.onTap,
  });

  final NavItem item;
  final bool isActive;
  final int depth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leftPad = 8.0 + (depth * 16.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white.withAlpha(12),
          splashColor: Colors.white.withAlpha(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.only(
              left: leftPad,
              right: 8,
              top: 8,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive ? Colors.white.withAlpha(20) : Colors.transparent,
            ),
            child: Row(
              children: [
                // Left accent bar for active item
                if (isActive)
                  Container(
                    width: DesignTokens.accentBarWidth,
                    height: 20,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Icon(
                  isActive ? (item.activeIcon ?? item.icon) : item.icon,
                  size: 18,
                  color: isActive ? Colors.white : Colors.white.withAlpha(140),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withAlpha(180),
                      fontSize: 13,
                    ),
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withAlpha(50),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.badge!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User footer — white on navy
// ─────────────────────────────────────────────────────────────────────────────

class _UserFooter extends StatelessWidget {
  const _UserFooter({this.displayName, this.profileId, required this.onLogout});
  final String? displayName;
  final String? profileId;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final label = displayName != null && displayName!.isNotEmpty
        ? displayName!
        : 'User';
    final id = profileId ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: ProfileBadge(
        profileId: id,
        name: label,
        description: 'Signed in',
        avatarSize: 32,
        nameColor: Colors.white,
        descriptionColor: Colors.white.withAlpha(100),
        trailing: IconButton(
          icon: Icon(
            Icons.logout,
            size: 18,
            color: Colors.white.withAlpha(140),
          ),
          tooltip: 'Sign out',
          onPressed: onLogout,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ),
    );
  }
}
