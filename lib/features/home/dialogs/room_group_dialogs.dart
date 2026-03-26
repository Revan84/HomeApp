import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';

class RoomGroupDialogs {
  /// Prompts the user for a room-group name.
  static Future<String?> editGroupName(
    BuildContext context, {
    String? currentName,
  }) async {
    final controller = TextEditingController(text: currentName ?? '');

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          currentName == null
              ? context.l10n.roomsAddGroupTitle
              : context.l10n.roomsRenameGroupTitle,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: context.l10n.roomsGroupNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );

    if (isConfirmed != true) return null;

    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  /// Prompts the user for a room name.
  static Future<String?> editRoomName(
    BuildContext context, {
    String? currentName,
  }) async {
    final controller = TextEditingController(text: currentName ?? '');

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          currentName == null
              ? context.l10n.roomsAddRoomTitle
              : context.l10n.roomsRenameRoomTitle,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: context.l10n.roomsRoomNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );

    if (isConfirmed != true) return null;

    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  /// Generic delete confirmation dialog.
  static Future<bool> confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    return isConfirmed == true;
  }
}