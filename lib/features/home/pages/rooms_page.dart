import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/room.dart';
import '../../../domain/entities/room_group.dart';
import '../controllers/home_controller.dart';
import '../dialogs/room_group_dialogs.dart';
import '../widgets/room_pill_tile.dart';
import '../widgets/rooms_pick_sheet.dart';

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
    _rooms = [...widget.rooms];
    _sortRooms();
  }

  Future<void> _addRoom() async {
    final activeGroup = widget.activeGroup;
    if (activeGroup == null) return;

    final controller = context.read<HomeController>();
    final currentGroupRoomIds = _rooms.map((r) => r.id).toSet();

    try {
      final allAvailable = await controller.availableRoomsForGroup(activeGroup.id);
      final availableRooms = allAvailable
          .where((r) => !currentGroupRoomIds.contains(r.id))
          .toList();

      if (!mounted) return;

      final result = await showModalBottomSheet<RoomsPickResult>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => RoomsPickSheet(availableRooms: availableRooms),
      );

      if (result == null || !mounted) return;

      if (result.isCreateNew) {
        final name = await RoomGroupDialogs.editRoomName(context);
        if (name == null) return;

        final createdRoom = await controller.addRoom(
          name: name,
          groupId: activeGroup.id,
        );

        if (!mounted) return;

        setState(() {
          _rooms.add(createdRoom);
          _sortRooms();
        });
      } else if (result.existingRoom != null) {
        final existing = result.existingRoom!;
        await controller.moveRoomToGroup(existing, activeGroup.id);

        if (!mounted) return;

        setState(() {
          _rooms.add(existing.copyWith(groupId: activeGroup.id));
          _sortRooms();
        });
      }
    } catch (_) {
      // Errors are surfaced by the controller; no silent swallowing.
      rethrow;
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
    final controller = context.read<HomeController>();
    final nextName = await RoomGroupDialogs.editRoomName(
      context,
      currentName: room.name,
    );
    if (nextName == null) return;

    final updated = room.copyWith(name: nextName);
    try {
      await controller.renameRoom(room, nextName);
    } catch (_) {
      rethrow;
    }

    if (!mounted) return;

    setState(() {
      final index = _rooms.indexWhere((item) => item.id == room.id);
      if (index != -1) {
        _rooms[index] = updated;
      }
    });
  }

  Future<void> _deleteRoom(Room room) async {
    final controller = context.read<HomeController>();
    final confirmed = await RoomGroupDialogs.confirmDelete(
      context,
      title: context.l10n.roomsDeleteRoomTitle,
      message: context.l10n.roomsDeleteRoomMessage(room.name),
    );
    if (!confirmed) return;

    try {
      await controller.deleteRoom(room);
    } catch (_) {
      rethrow;
    }

    if (!mounted) return;

    setState(() {
      _rooms.removeWhere((item) => item.id == room.id);
    });
  }

  void _openRoom(Room room) {
    // No-op: a dedicated room details page is not yet implemented.
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

                            return RoomPillTile(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip:
                    MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBackPressed,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
