import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';
import '../../../../domain/entities/room.dart';

/// Sentinel returned when the user explicitly picks "No room".
const String roomPickerNoneSentinel = '__none__';

/// Shows the standard room-assignment bottom sheet.
///
/// Returns:
/// - `null` — sheet dismissed without a selection
/// - [roomPickerNoneSentinel] — user picked "None" (remove room assignment)
/// - a room id string — user picked that room
///
/// Callers typically do:
/// ```dart
/// final result = await showDeviceRoomPicker(context, rooms: ..., currentRoomId: ...);
/// if (result == null || !mounted) return;
/// await _ctrl.updateRoom(result == roomPickerNoneSentinel ? null : result);
/// ```
Future<String?> showDeviceRoomPicker(
  BuildContext context, {
  required List<Room> rooms,
  required String? currentRoomId,
  String? noneLabel,
}) {
  // Capture accent and label before the sheet opens to avoid use-after-unmount.
  final accent = DeviceAccentScope.of(context);
  final label = noneLabel ?? context.l10n.none;

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTopBR),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSpacing.gapXl,
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: AppRadius.xsBR,
            ),
          ),
          AppSpacing.gapX3l,
          // "None" option
          ListTile(
            leading: const Icon(Icons.cancel_outlined,
                color: AppColors.textSecondary, size: 20),
            title: Text(
              label,
              style: const TextStyle(
                  fontFamily: 'ShareTech', color: AppColors.textPrimary),
            ),
            trailing: currentRoomId == null
                ? Icon(Icons.check, color: accent, size: 18)
                : null,
            onTap: () => (),//Navigator.pop(_, roomPickerNoneSentinel),
          ),
          if (rooms.isNotEmpty)
            const Divider(height: 1, color: AppColors.border),
          ...rooms.map(
            (r) => ListTile(
              leading: const Icon(Icons.meeting_room_outlined,
                  color: AppColors.textSecondary, size: 20),
              title: Text(
                r.name,
                style: const TextStyle(
                    fontFamily: 'ShareTech', color: AppColors.textPrimary),
              ),
              trailing: r.id == currentRoomId
                  ? Icon(Icons.check, color: accent, size: 18)
                  : null,
              onTap: () => (),//Navigator.pop(_, r.id),
            ),
          ),
          AppSpacing.gapMd,
        ],
      ),
    ),
  );
}
