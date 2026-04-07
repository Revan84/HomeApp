import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../controllers/home_controller.dart';

/// Bottom sheet used to create a new room group.
///
/// Examples:
/// - House
/// - Apartment
/// - Office
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

    setState(() {
      _saving = true;
    });

    final controller = context.read<HomeController>();

    await controller.addRoomGroup(_nameController.text.trim());

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.roomsAddGroupTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                      tooltip: context.l10n.close,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                /// Group name field.
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: context.l10n.roomsGroupNameFieldLabel,
                    hintText: context.l10n.roomsGroupNameHint,
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return context.l10n.validationRoomGroupNameRequired;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _save(),
                ),

                const SizedBox(height: 12),

                /// Primary creation action.
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(context.l10n.save),
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