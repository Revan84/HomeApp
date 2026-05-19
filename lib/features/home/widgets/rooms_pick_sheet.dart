import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/room.dart';

/// The result returned by [RoomsPickSheet].
class RoomsPickResult {
  final bool isCreateNew;
  final Room? existingRoom;

  const RoomsPickResult.createNew()
      : isCreateNew = true,
        existingRoom = null;

  const RoomsPickResult.existing(Room room)
      : isCreateNew = false,
        existingRoom = room;
}

/// Bottom sheet for choosing to create a new room or move an existing one
/// into the active group.
class RoomsPickSheet extends StatelessWidget {
  final List<Room> availableRooms;

  const RoomsPickSheet({super.key, required this.availableRooms});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSpacing.gapXl,
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: AppRadius.xsBR,
            ),
          ),
          AppSpacing.gapX3l,
          Text(
            l10n.roomsAddRoomTitle,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.gapXl,
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.add, color: AppColors.primary, size: 20),
            ),
            title: Text(
              l10n.roomsCreateNewRoom,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () =>
                Navigator.pop(context, const RoomsPickResult.createNew()),
          ),
          if (availableRooms.isNotEmpty) ...[
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: availableRooms.length,
                separatorBuilder: (_, _) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final room = availableRooms[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(
                        Icons.meeting_room_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      room.name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => Navigator.pop(
                        context, RoomsPickResult.existing(room)),
                  );
                },
              ),
            ),
          ] else ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 24, horizontal: 16),
              child: Text(
                l10n.roomsNoAvailableRooms,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          AppSpacing.gapMd,
        ],
      ),
    );
  }
}
