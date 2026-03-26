import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/equipment.dart';
import '../../../domain/models/room.dart';
import '../../../domain/models/room_group.dart';
import '../../../domain/repositories/room_repository.dart';

/// Rooms page showing only the rooms belonging to the currently active group.
///
/// The visual structure follows the same spirit as the favorites page:
/// - custom header
/// - pill rows
/// - centered add button at the bottom
class RoomsPage extends StatefulWidget {
  final RoomGroup? activeGroup;
  final List<Room> rooms;
  final List<Equipment> equipments;

  const RoomsPage({
    super.key,
    required this.activeGroup,
    required this.rooms,
    required this.equipments,
  });

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  late List<Room> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = [...widget.rooms]..sort((a, b) {
        final sortComparison = a.sortOrder.compareTo(b.sortOrder);
        if (sortComparison != 0) return sortComparison;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
  }

  Future<void> _addRoom() async {
    final activeGroup = widget.activeGroup;
    if (activeGroup == null) return;

    final repo = context.read<RoomRepository>();
    final allRooms = await repo.loadAll();
    final currentGroupRoomIds = _rooms.map((r) => r.id).toSet();
    final availableRooms = allRooms
        .where((r) => r.groupId != activeGroup.id && !currentGroupRoomIds.contains(r.id))
        .toList();

    if (!mounted) return;

    final result = await showModalBottomSheet<_AddRoomResult>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddRoomSheet(
        availableRooms: availableRooms,
      ),
    );

    if (result == null || !mounted) return;

    if (result.isCreateNew) {
      final name = await _editRoomNameDialog(context);
      if (name == null) return;

      final createdRoom = await repo.add(
        name: name,
        groupId: activeGroup.id,
      );

      if (!mounted) return;

      setState(() {
        _rooms.add(createdRoom);
        _sortRooms();
      });
    } else if (result.existingRoom != null) {
      final movedRoom = result.existingRoom!.copyWith(groupId: activeGroup.id);
      await repo.update(movedRoom);

      if (!mounted) return;

      setState(() {
        _rooms.add(movedRoom);
        _sortRooms();
      });
    }
  }

  void _sortRooms() {
    _rooms.sort((a, b) {
      final sortComparison = a.sortOrder.compareTo(b.sortOrder);
      if (sortComparison != 0) return sortComparison;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  Future<void> _renameRoom(Room room) async {
    final repo = context.read<RoomRepository>();

    final nextName = await _editRoomNameDialog(
      context,
      currentName: room.name,
    );
    if (nextName == null) return;

    final updated = room.copyWith(name: nextName);
    await repo.update(updated);

    if (!mounted) return;

    setState(() {
      final index = _rooms.indexWhere((item) => item.id == room.id);
      if (index != -1) {
        _rooms[index] = updated;
      }
    });
  }

  Future<void> _deleteRoom(Room room) async {
    final repo = context.read<RoomRepository>();

    final confirmed = await _confirmDeleteRoomDialog(
      context,
      roomName: room.name,
    );
    if (!confirmed) return;

    await repo.deleteById(room.id);

    if (!mounted) return;

    setState(() {
      _rooms.removeWhere((item) => item.id == room.id);
    });
  }

  void _openRoom(Room room) {
    // TODO: Later this can open a dedicated room details page.
  }

  Future<String?> _editRoomNameDialog(
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

  Future<bool> _confirmDeleteRoomDialog(
    BuildContext context, {
    required String roomName,
  }) async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.roomsDeleteRoomTitle),
        content: Text(context.l10n.roomsDeleteRoomMessage(roomName)),
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

  @override
  Widget build(BuildContext context) {
    final activeGroup = widget.activeGroup;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _RoomsPageHeader(
              title: context.l10n.roomsPageTitle,
              onBackPressed: () => Navigator.of(context).pop(true),
            ),
            Expanded(
              child: activeGroup == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          context.l10n.roomsNoActiveGroupSelected,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                    )
                  : _rooms.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                context.l10n.roomsEmptyForGroup(activeGroup.name),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _RoomsAddButton(
                              tooltip: context.l10n.roomsAddRoomTooltip,
                              onPressed: _addRoom,
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                          itemCount: _rooms.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            if (index == _rooms.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Center(
                                  child: _RoomsAddButton(
                                    tooltip: context.l10n.roomsAddRoomTooltip,
                                    onPressed: _addRoom,
                                  ),
                                ),
                              );
                            }

                            final room = _rooms[index];
                            final equipCount = widget.equipments
                                .where((e) => e.roomId == room.id)
                                .length;

                            return _RoomPillTile(
                              title: room.name,
                              equipmentCount: equipCount,
                              removeTooltip: context.l10n.roomsDeleteRoomTooltip,
                              onTap: () => _openRoom(room),
                              onLongPress: () => _renameRoom(room),
                              onRemove: () => _deleteRoom(room),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomsPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;

  const _RoomsPageHeader({
    required this.title,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBackPressed,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _RoomPillTile extends StatelessWidget {
  final String title;
  final int equipmentCount;
  final String removeTooltip;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRemove;

  const _RoomPillTile({
    required this.title,
    required this.equipmentCount,
    required this.removeTooltip,
    required this.onTap,
    required this.onLongPress,
    required this.onRemove,
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
              onLongPress: onLongPress,
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.l10n.roomsEquipmentCount(equipmentCount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: removeTooltip,
          onPressed: onRemove,
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

class _RoomsAddButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;

  const _RoomsAddButton({
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

class _AddRoomResult {
  final bool isCreateNew;
  final Room? existingRoom;

  const _AddRoomResult.createNew()
      : isCreateNew = true,
        existingRoom = null;

  const _AddRoomResult.existing(Room room)
      : isCreateNew = false,
        existingRoom = room;
}

class _AddRoomSheet extends StatelessWidget {
  final List<Room> availableRooms;

  const _AddRoomSheet({required this.availableRooms});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.roomsAddRoomSheetTitle,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // "Create new room" action row
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.success, size: 20),
            ),
            title: Text(
              l10n.roomsCreateNewRoom,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => Navigator.pop(context, const _AddRoomResult.createNew()),
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
                          color: AppColors.stroke.withValues(alpha: 0.35),
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
                    onTap: () => Navigator.pop(context, _AddRoomResult.existing(room)),
                  );
                },
              ),
            ),
          ] else ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Text(
                l10n.roomsNoAvailableRooms,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}