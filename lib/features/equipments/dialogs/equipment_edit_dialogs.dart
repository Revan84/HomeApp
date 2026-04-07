import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';

import '../../../domain/entities/room.dart';
import '../../../domain/entities/equipment.dart';

class EquipmentEditDialogs {
  /// Edit the user-facing name.
  static Future<String?> editName(
    BuildContext context, {
    required String currentName,
  }) async {
    final controller = TextEditingController(text: currentName);

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.detailsEditNameTooltip),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: context.l10n.nameHintExample,
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

  /// Edit local IP with light validation.
  static Future<String?> editLocalIp(
    BuildContext context, {
    required String currentIp,
  }) async {
    final controller = TextEditingController(text: currentIp);

    bool isValidIp(String value) {
      final parts = value.split('.');
      if (parts.length != 4) return false;

      for (final part in parts) {
        final number = int.tryParse(part);
        if (number == null || number < 0 || number > 255) {
          return false;
        }
      }

      return true;
    }

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.detailsEditIpTooltip),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: context.l10n.ipLocalHint,
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
    if (!isValidIp(value)) return null;

    return value;
  }

  /// Pick equipment type.
  static Future<EquipmentType?> pickType(
    BuildContext context, {
    required EquipmentType current,
    required String Function(EquipmentType) labelOf,
  }) {
    return showDialog<EquipmentType>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(context.l10n.detailsSelectTypeTooltip),
        children: EquipmentType.values
            .map(
              (type) => _SelectionTile<EquipmentType>(
                value: type,
                selected: type == current,
                label: labelOf(type),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  /// Pick room (nullable => None).
  static Future<String?> pickRoom(
    BuildContext context, {
    required String? currentRoomId,
    required List<Room> rooms,
    required String noneLabel,
  }) {
    return showDialog<String?>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(context.l10n.detailsRoomDropdownTooltip),
        children: [
          _SelectionTile<String?>(
            value: null,
            selected: currentRoomId == null,
            label: noneLabel,
          ),
          ...rooms.map(
            (room) => _SelectionTile<String?>(
              value: room.id,
              selected: room.id == currentRoomId,
              label: room.name,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable selection tile for simple dialog pickers.
///
/// This avoids deprecated RadioListTile group APIs while keeping
/// the same UX: one current value, one tap to validate and close.
class _SelectionTile<T> extends StatelessWidget {
  final T value;
  final bool selected;
  final String label;

  const _SelectionTile({
    required this.value,
    required this.selected,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
      ),
      title: Text(
        label,
        style: textStyle,
      ),
      onTap: () => Navigator.pop<T>(context, value),
    );
  }
}