import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/design_system/buttons/app_button.dart';
import '../../../core/design_system/inputs/app_text_field.dart';
import '../../../core/design_system/layout/app_sheet_header.dart';
import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/home_controller.dart';

/// Bottom sheet for creating a new room group (House, Apartment, Office…).
class AddRoomGroupSheet extends StatefulWidget {
  const AddRoomGroupSheet({super.key});

  @override
  State<AddRoomGroupSheet> createState() => _AddRoomGroupSheetState();
}

class _AddRoomGroupSheetState extends State<AddRoomGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    await context.read<HomeController>().addRoomGroup(_nameController.text.trim());

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
                  title: l.roomsAddGroupTitle,
                  onClose: () => Navigator.pop(context, false),
                ),
                AppSpacing.gapMd,
                AppTextField(
                  controller: _nameController,
                  label: l.roomsGroupNameFieldLabel,
                  hint: l.roomsGroupNameHint,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    return trimmed.isEmpty
                        ? l.validationRoomGroupNameRequired
                        : null;
                  },
                ),
                AppSpacing.gapXl,
                AppButton(
                  label: l.save,
                  leading: Icons.save,
                  onPressed: _saving ? null : _save,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
