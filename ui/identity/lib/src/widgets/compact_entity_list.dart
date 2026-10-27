import 'package:flutter/material.dart';

/// A list page for phone widths: the title, search, filters and actions on
/// top, then one tappable tile per item. Wide screens use the admin table;
/// on a phone its columns do not fit, so field staff get this instead.
class CompactEntityList<T> extends StatelessWidget {
  const CompactEntityList({
    super.key,
    required this.title,
    required this.items,
    required this.tileBuilder,
    this.onTap,
    this.onSearch,
    this.searchHint,
    this.actions = const [],
    this.filters,
    this.addLabel,
    this.onAdd,
    this.emptyText = 'Nothing here yet',
  });

  final String title;
  final List<T> items;

  /// Builds the tile for one item; tapping it calls [onTap].
  final ListTile Function(T item) tileBuilder;
  final void Function(T item)? onTap;
  final ValueChanged<String>? onSearch;
  final String? searchHint;
  final List<Widget> actions;
  final Widget? filters;
  final String? addLabel;
  final VoidCallback? onAdd;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: onAdd == null
          ? null
          : FloatingActionButton.extended(
              key: const Key('compact-list-add'),
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(addLabel ?? 'Add'),
            ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (onSearch != null) ...[
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('compact-list-search'),
                      decoration: InputDecoration(
                        hintText: searchHint ?? 'Search',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: onSearch,
                    ),
                  ],
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: actions,
                    ),
                  ],
                  ?filters,
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(emptyText)),
            )
          else
            SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final tile = tileBuilder(item);
                return ListTile(
                  key: tile.key,
                  leading: tile.leading,
                  title: tile.title,
                  subtitle: tile.subtitle,
                  trailing: tile.trailing,
                  onTap: onTap == null ? null : () => onTap!(item),
                );
              },
            ),
          // Room for the add button over the last tile.
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
    );
  }
}
