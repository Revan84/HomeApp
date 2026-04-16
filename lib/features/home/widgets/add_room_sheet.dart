import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/design_system/buttons/app_button.dart';
import '../../../core/design_system/inputs/app_text_field.dart';
import '../../../core/design_system/layout/app_sheet_header.dart';
import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/home_controller.dart';

class AddRoomSheet extends StatefulWidget {
  const AddRoomSheet({super.key});

  @override
  State<AddRoomSheet> createState() => _AddRoomSheetState();
}

class _AddRoomSheetState extends State<AddRoomSheet> {
  final _nameController = TextEditingController();
  final _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _saving = false;
  String? _selectedGroupId;

  @override
  void dispose() {
    _nameController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) return;

    final controller = context.read<HomeController>();
    final createdGroup = await controller.addRoomGroup(groupName);

    if (!mounted) return;
    _groupNameController.clear();
    setState(() => _selectedGroupId = createdGroup.id);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGroupId == null) return;

    setState(() => _saving = true);

    final controller = context.read<HomeController>();
    final navigator = Navigator.of(context);

    await controller.addRoom(
      name: _nameController.text.trim(),
      groupId: _selectedGroupId!,
    );

    if (!mounted) return;
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final groups = context.watch<HomeController>().roomGroups;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.sheetPadding,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSheetHeader(
                  title: l.addRoomTitle,
                  onClose: () => Navigator.pop(context, false),
                ),
                AppSpacing.gapMd,
                if (groups.isEmpty) ...[
                  Text(
                    l.roomsNoGroupForQuickAdd,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  AppSpacing.gapXl,
                  AppTextField(
                    controller: _groupNameController,
                    label: l.roomsFirstGroupLabel,
                    hint: l.roomsGroupNameHint,
                    textInputAction: TextInputAction.done,
                  ),
                  AppSpacing.gapXl,
                  AppButton(
                    label: l.roomsCreateFirstGroup,
                    leading: Icons.add,
                    onPressed: _createGroup,
                    fullWidth: true,
                    variant: AppButtonVariant.secondary,
                  ),
                ] else ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGroupId,
                    dropdownColor: AppColors.surface,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                    borderRadius: AppRadius.xlBR,
                    decoration: InputDecoration(labelText: l.roomsTargetGroupLabel),
                    items: groups
                        .map((g) => DropdownMenuItem<String>(
                              value: g.id,
                              child: Text(g.name),
                            ))
                        .toList(growable: false),
                    onChanged: (v) => setState(() => _selectedGroupId = v),
                    validator: (v) => (v == null || v.isEmpty)
                        ? l.roomsTargetGroupRequired
                        : null,
                  ),
                  AppSpacing.gapXl,
                  AppTextField(
                    controller: _nameController,
                    label: l.roomNameLabel,
                    hint: l.roomNameHint,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? l.validationRoomNameRequired
                            : null,
                  ),
                  AppSpacing.gapXl,
                  AppButton(
                    label: l.save,
                    leading: Icons.save,
                    onPressed: _saving ? null : _save,
                    fullWidth: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
