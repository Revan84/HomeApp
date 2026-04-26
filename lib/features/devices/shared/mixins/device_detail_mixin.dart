import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/room.dart';
import '../../../equipments/dialogs/equipment_edit_dialogs.dart';
import '../widgets/device_room_picker.dart';

/// Shared behaviour for all device detail screens.
///
/// Provides [showDeviceError], [confirmDeviceDelete], [pickDeviceRoom] and
/// [editDeviceName] so each screen's State only declares its own controller
/// logic and [build] method.
mixin DeviceDetailMixin<W extends StatefulWidget> on State<W> {
  // ── Error ─────────────────────────────────────────────────────────────────

  void showDeviceError(Object err) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(err.toString())));
  }

  // ── Delete confirmation ───────────────────────────────────────────────────

  Future<bool?> confirmDeviceDelete(String deviceName) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(context.l10n.deleteEquipmentConfirmTitle),
          content: Text(context.l10n.deleteEquipmentConfirmBody(deviceName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: Text(context.l10n.delete),
            ),
          ],
        ),
      );

  // ── Room picker ───────────────────────────────────────────────────────────

  Future<void> pickDeviceRoom({
    required List<Room> rooms,
    required String? currentRoomId,
    required Future<void> Function(String?) onUpdate,
  }) async {
    final result = await showDeviceRoomPicker(
      context,
      rooms: rooms,
      currentRoomId: currentRoomId,
    );
    if (result == null || !mounted) return;
    try {
      await onUpdate(result == roomPickerNoneSentinel ? null : result);
    } catch (err) {
      showDeviceError(err);
    }
  }

  // ── Edit name ─────────────────────────────────────────────────────────────

  Future<void> editDeviceName({
    required String currentName,
    required Future<void> Function(String) onUpdate,
  }) async {
    final next = await EquipmentEditDialogs.editName(
      context,
      currentName: currentName,
    );
    if (next == null || !mounted) return;
    try {
      await onUpdate(next);
    } catch (err) {
      showDeviceError(err);
    }
  }
}
