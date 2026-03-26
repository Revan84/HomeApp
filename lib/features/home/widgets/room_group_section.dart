import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/room.dart';
import '../../../../domain/models/room_group.dart';

class RoomGroupSection extends StatelessWidget {
  final RoomGroup group;
  final List<Room> rooms;
  final VoidCallback onRenameGroup;
  final VoidCallback onDeleteGroup;
  final VoidCallback onAddRoom;
  final ValueChanged<Room> onTapRoom;
  final ValueChanged<Room> onRenameRoom;
  final ValueChanged<Room> onDeleteRoom;

  const RoomGroupSection({
    super.key,
    required this.group,
    required this.rooms,
    required this.onRenameGroup,
    required this.onDeleteGroup,
    required this.onAddRoom,
    required this.onTapRoom,
    required this.onRenameRoom,
    required this.onDeleteRoom,
  });

  @override
  Widget build(BuildContext context) {
    final sortedRooms = [...rooms]..sort((a, b) {
        final sortComparison = a.sortOrder.compareTo(b.sortOrder);
        if (sortComparison != 0) return sortComparison;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                group.name.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.roomsRenameGroupTooltip,
              onPressed: onRenameGroup,
              icon: Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
            IconButton(
              tooltip: context.l10n.roomsDeleteGroupTooltip,
              onPressed: onDeleteGroup,
              icon: Icon(
                Icons.remove,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...sortedRooms.map(
          (room) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RoomPillTile(
              room: room,
              onTap: () => onTapRoom(room),
              onRename: () => onRenameRoom(room),
              onDelete: () => onDeleteRoom(room),
            ),
          ),
        ),
        Center(
          child: _AddCircleButton(
            tooltip: context.l10n.roomsAddRoomTooltip,
            onPressed: onAddRoom,
          ),
        ),
      ],
    );
  }
}

class _RoomPillTile extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _RoomPillTile({
    required this.room,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onTap,
              onLongPress: onRename,
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.stroke.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: context.l10n.roomsDeleteRoomTooltip,
          onPressed: onDelete,
          icon: Icon(
            Icons.remove,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _AddCircleButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;

  const _AddCircleButton({
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Ink(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.stroke.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}