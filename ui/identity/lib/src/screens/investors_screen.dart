import 'dart:async';

import 'package:antinvestor_api_identity/antinvestor_api_identity.dart'
    as common;
import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/widgets/admin_entity_list_page.dart';
import 'package:antinvestor_ui_core/widgets/form_field_card.dart';
import 'package:antinvestor_ui_core/widgets/state_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';

import '../providers/investor_providers.dart';
import '../widgets/state_helpers.dart';
import '../widgets/async_state_views.dart';

class InvestorsScreen extends ConsumerStatefulWidget {
  const InvestorsScreen({super.key, this.canManage = true});

  final bool canManage;

  @override
  ConsumerState<InvestorsScreen> createState() => _InvestorsScreenState();
}

class _InvestorsScreenState extends ConsumerState<InvestorsScreen> {
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _query = value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final investorsAsync = ref.watch(investorListProvider(_query));
    if (investorsAsync.hasError) {
      return ListErrorView(
        title: 'Investors',
        breadcrumbs: const ['Identity', 'Investors'],
        error: investorsAsync.error!,
        onRetry: () => ref.invalidate(investorListProvider(_query)),
      );
    }
    if (investorsAsync.isLoading && !investorsAsync.hasValue) {
      return const ListLoadingView(
        title: 'Investors',
        breadcrumbs: ['Identity', 'Investors'],
      );
    }
    final investors = investorsAsync.requireValue;

    return AdminEntityListPage<InvestorObject>(
      title: 'Investors',
      breadcrumbs: const ['Identity', 'Investors'],
      columns: const [
        DataColumn(label: Text('NAME')),
        DataColumn(label: Text('PROFILE')),
        DataColumn(label: Text('STATE')),
      ],
      items: investors,
      onSearch: _onSearch,
      addLabel: widget.canManage ? 'Add Investor' : null,
      onAdd: widget.canManage ? () => _showInvestorDialog(context) : null,
      rowBuilder: (investor, selected, onSelect) {
        return DataRow(
          selected: selected,
          onSelectChanged: (_) => onSelect(),
          cells: [
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      investor.name.isNotEmpty
                          ? investor.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    investor.name.isNotEmpty
                        ? investor.name
                        : 'Unnamed Investor',
                  ),
                ],
              ),
            ),
            DataCell(Text(investor.profileId)),
            DataCell(Text(investor.state.name)),
          ],
        );
      },
      detailBuilder: (investor) => _InvestorDetail(
        investor: investor,
        canManage: widget.canManage,
        onEdit: () => _showInvestorDialog(context, investor: investor),
      ),
      exportRow: (investor) => [
        investor.name,
        investor.profileId,
        investor.state.name,
        investor.id,
      ],
    );
  }

  void _showInvestorDialog(BuildContext context, {InvestorObject? investor}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _InvestorFormDialog(
        investor: investor,
        onSave: (updated) async {
          try {
            await ref.read(investorNotifierProvider.notifier).save(updated);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    investor == null
                        ? 'Investor created successfully'
                        : 'Investor updated successfully',
                  ),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(friendlyError(e)),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
            // The dialog decides whether to stay open, so the user does not
            // lose what they typed when the save fails.
            rethrow;
          }
        },
      ),
    );
  }
}

class _InvestorDetail extends StatelessWidget {
  const _InvestorDetail({
    required this.investor,
    required this.canManage,
    required this.onEdit,
  });
  final InvestorObject investor;
  final bool canManage;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                investor.name.isNotEmpty ? investor.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investor.name.isNotEmpty
                        ? investor.name
                        : 'Unnamed Investor',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    investor.id,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            if (canManage)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
          ],
        ),
        const SizedBox(height: 20),
        _DetailRow(label: 'Profile ID', value: investor.profileId),
        _DetailRow(label: 'State', value: investor.state.name),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvestorFormDialog extends StatefulWidget {
  const _InvestorFormDialog({this.investor, required this.onSave});

  final InvestorObject? investor;
  final Future<void> Function(InvestorObject investor) onSave;

  @override
  State<_InvestorFormDialog> createState() => _InvestorFormDialogState();
}

class _InvestorFormDialogState extends State<_InvestorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _profileIdCtrl;
  late common.STATE _selectedState;
  bool _saving = false;

  bool get _isEditing => widget.investor != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.investor?.name ?? '');
    _profileIdCtrl = TextEditingController(
      text: widget.investor?.profileId ?? '',
    );
    _selectedState = widget.investor?.state ?? common.STATE.CREATED;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _profileIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final investor = InvestorObject(
      id: widget.investor?.id,
      name: _nameCtrl.text.trim(),
      profileId: _profileIdCtrl.text.trim(),
      state: _selectedState,
    );

    if (widget.investor != null && widget.investor!.hasProperties()) {
      investor.properties = widget.investor!.properties;
    }

    try {
      await widget.onSave(investor);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  static const _editableStates = [
    common.STATE.CREATED,
    common.STATE.CHECKED,
    common.STATE.ACTIVE,
    common.STATE.INACTIVE,
    common.STATE.DELETED,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Investor' : 'Add Investor'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormFieldCard(
                label: 'Name',
                description: 'The full legal or display name of the investor',
                isRequired: true,
                child: TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter investor name',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
              ),
              FormFieldCard(
                label: 'Profile ID',
                description:
                    'The unique profile identifier from the user management system',
                isRequired: true,
                child: TextFormField(
                  controller: _profileIdCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter profile ID',
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Profile ID is required'
                      : null,
                ),
              ),
              FormFieldCard(
                label: 'State',
                description:
                    'The current lifecycle state of this investor record',
                isRequired: true,
                child: DropdownButtonFormField<common.STATE>(
                  initialValue: _selectedState,
                  items: _editableStates
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(stateLabel(toCommonState(s))),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedState = v);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
