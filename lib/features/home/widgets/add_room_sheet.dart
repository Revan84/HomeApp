import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
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
    final groups = context.watch<HomeController>().roomGroups;
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
                        context.l10n.addRoomTitle,
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
                if (groups.isEmpty) ...[
                  Text(
                    context.l10n.roomsNoGroupForQuickAdd,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _groupNameController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: context.l10n.roomsFirstGroupLabel,
                      hintText: context.l10n.roomsGroupNameHint,
                    ),
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createGroup,
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.roomsCreateFirstGroup),
                    ),
                  ),
                ] else ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGroupId,
                    decoration: InputDecoration(
                      labelText: context.l10n.roomsTargetGroupLabel,
                    ),
                    items: groups
                        .map(
                          (group) => DropdownMenuItem<String>(
                            value: group.id,
                            child: Text(group.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      setState(() {
                        _selectedGroupId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.roomsTargetGroupRequired;
                      }
                      return null;
                    },
                  ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: context.l10n.roomNameLabel,
                            hintText: context.l10n.roomNameHint,
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? context.l10n.validationRoomNameRequired
                                  : null,
                        ),
                        const SizedBox(height: 12),
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
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}