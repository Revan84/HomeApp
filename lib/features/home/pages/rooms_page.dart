import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/design_system/buttons/app_button.dart';
import '../../../core/design_system/chips/app_chip.dart';
import '../../../core/design_system/tiles/device_list_tile.dart';
import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/room.dart';
import '../../../domain/entities/room_group.dart';
import '../../equipments/widgets/equipments_search_bar.dart';
import '../controllers/home_controller.dart';
import 'room_detail_page.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

/// Full-screen rooms browser — same design language as [FavoritesPage].
///
/// Shows all rooms across all groups, with group chips for filtering,
/// a search bar, and a FAB to add a new room.
class RoomsPage extends StatefulWidget {
  final String? groupId;

  const RoomsPage({super.key, required this.groupId});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedGroupId; // null = all groups

  @override
  void initState() {
    super.initState();
    // Pre-select the active group so the page opens scoped.
    _selectedGroupId = widget.groupId;
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      if (q != _searchQuery) setState(() => _searchQuery = q);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Add room dialog ──────────────────────────────────────────────────────────

  Future<void> _addRoom(HomeController ctrl) async {
    final groups = ctrl.roomGroups;
    if (groups.isEmpty) return;

    final result = await _showAddRoomDialog(groups);
    if (result == null || !mounted) return;

    await ctrl.addRoom(name: result.name, groupId: result.groupId);
    // loadAll not needed — addRoom already calls notifyListeners via addRoom
    // But we reload to keep room list fresh.
    if (mounted) await ctrl.loadAll(widget.groupId);
  }

  Future<_AddRoomResult?> _showAddRoomDialog(List<RoomGroup> groups) async {
    String? selectedGroupId = _selectedGroupId ?? groups.first.id;
    final nameCtrl = TextEditingController();

    // Bottom sheet floats above the keyboard naturally via viewInsetsOf padding.
    return showModalBottomSheet<_AddRoomResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final keyboardPadding = MediaQuery.viewInsetsOf(ctx).bottom;
          return Padding(
            padding: EdgeInsets.fromLTRB(24, 28, 24, keyboardPadding + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ─────────────────────────────────────────────────
                Text(
                  context.l10n.roomsAddRoomTitle,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSizes.sectionTitle,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.x3l),

                // ── Group label ───────────────────────────────────────────
                Text(
                  context.l10n.roomsTargetGroupLabel,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: AppFontSizes.sm,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),

                // ── Group dropdown ────────────────────────────────────────
                DropdownButtonFormField<String>(
                  initialValue: selectedGroupId,
                  dropdownColor: AppColors.surface,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.bg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x2l,
                      vertical: AppSpacing.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.x2lBR,
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.x2lBR,
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.x2lBR,
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  items: groups
                      .map((g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(
                              g.name,
                              style: const TextStyle(
                                fontFamily: 'ShareTech',
                                fontSize: AppFontSizes.body,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setSheetState(() => selectedGroupId = v),
                ),

                const SizedBox(height: AppSpacing.x3l),

                // ── Room name label ───────────────────────────────────────
                Text(
                  context.l10n.roomsRoomNameLabel,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: AppFontSizes.sm,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),

                // ── Room name field ───────────────────────────────────────
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: AppFontSizes.body,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: context.l10n.roomsRoomNameHint,
                    hintStyle: const TextStyle(
                      fontFamily: 'ShareTech',
                      fontSize: AppFontSizes.body,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.bg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x2l,
                      vertical: AppSpacing.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.x2lBR,
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.x2lBR,
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.x2lBR,
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) {
                    final name = nameCtrl.text.trim();
                    if (name.isNotEmpty && selectedGroupId != null) {
                      Navigator.of(ctx).pop(
                        _AddRoomResult(name: name, groupId: selectedGroupId!),
                      );
                    }
                  },
                ),

                const SizedBox(height: AppSpacing.x3l),

                // ── Buttons ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      label: context.l10n.cancel,
                      variant: AppButtonVariant.ghost,
                      compact: true,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    AppButton(
                      label: context.l10n.save,
                      variant: AppButtonVariant.primary,
                      compact: true,
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty || selectedGroupId == null) return;
                        Navigator.of(ctx).pop(
                          _AddRoomResult(name: name, groupId: selectedGroupId!),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Room actions ─────────────────────────────────────────────────────────────

  Future<void> _deleteRoom(HomeController ctrl, Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
        title: Text(context.l10n.roomsDeleteRoomTitle),
        content: Text(context.l10n.roomsDeleteRoomMessage(room.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ctrl.deleteRoom(room);
    if (mounted) await ctrl.loadAll(widget.groupId);
  }

  Future<void> _openRoomDetail(HomeController ctrl, Room room) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RoomDetailPage(room: room, groupId: widget.groupId),
      ),
    );
    if (changed == true && mounted) await ctrl.loadAll(widget.groupId);
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<HomeController>();

    final allGroups = ctrl.roomGroups;
    final allRooms = ctrl.allRooms;

    // Stats
    final totalRooms = allRooms.length;
    final totalGroups = allGroups.length;

    // Apply group chip filter
    final groupFilteredRooms = _selectedGroupId == null
        ? allRooms
        : allRooms.where((r) => r.groupId == _selectedGroupId).toList();

    // Apply search filter
    final visibleRooms = _searchQuery.isEmpty
        ? groupFilteredRooms
        : groupFilteredRooms
            .where((r) => r.name.toLowerCase().contains(_searchQuery))
            .toList();

    // Room counts per group (for chips) — always from allRooms, not filtered
    final groupCounts = {
      for (final g in allGroups) g.id: allRooms.where((r) => r.groupId == g.id).length,
    };

    // Device count per room
    int deviceCountForRoom(String roomId) => ctrl.deviceCountForRoom(roomId);

    // Build tile list: DeviceListTile + outside X button
    Widget removeRow({required Widget tile, required VoidCallback onRemove}) =>
        Row(
          children: [
            Expanded(child: tile),
            IconButton(
              tooltip: context.l10n.roomsDeleteRoomTooltip,
              onPressed: onRemove,
              icon: const Icon(
                Icons.close_rounded,
                size: 20,
                color: AppColors.danger,
              ),
            ),
          ],
        );

    final tiles = <Widget>[
      for (final room in visibleRooms)
        removeRow(
          onRemove: () => _deleteRoom(ctrl, room),
          tile: DeviceListTile(
            icon: Icons.meeting_room_outlined,
            iconColor: AppColors.primary,
            title: room.name,
            subtitle: allGroups
                .where((g) => g.id == room.groupId)
                .firstOrNull
                ?.name ?? '',
            liveValue: context.l10n.roomsEquipmentCount(deviceCountForRoom(room.id)),
            dotColor: AppColors.textSecondary,
            onTap: () => _openRoomDetail(ctrl, room),
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.45),
        leading: const BackButton(),
        title: Text(
          context.l10n.roomsPageTitle,
          style: const TextStyle(
            fontFamily: 'ShareTech',
            fontWeight: FontWeight.w600,
            fontSize: AppFontSizes.heading,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => ctrl.loadAll(widget.groupId),
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x3l,
                AppSpacing.x3l,
                AppSpacing.x3l,
                0,
              ),
              child: Text(
                '$totalRooms rooms · $totalGroups groups',
                style: const TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.sm,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            AppSpacing.gapX2l,

            // ── Search ────────────────────────────────────────────────────────
            EquipmentsSearchBar(
              controller: _searchCtrl,
              isFiltered: false,
              onFilterTap: () {},
              hintText: context.l10n.roomsSearchHint,
            ),

            AppSpacing.gapX2l,

            // ── Group chips ───────────────────────────────────────────────────
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.x3l),
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemCount: allGroups.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return AppChip(
                      label: context.l10n.equipmentsRoomAll(totalRooms),
                      selected: _selectedGroupId == null,
                      variant: AppChipVariant.filter,
                      onTap: () => setState(() => _selectedGroupId = null),
                    );
                  }
                  final group = allGroups[i - 1];
                  final count = groupCounts[group.id] ?? 0;
                  return AppChip(
                    label: '${group.name} ($count)',
                    selected: _selectedGroupId == group.id,
                    variant: AppChipVariant.filter,
                    onTap: () =>
                        setState(() => _selectedGroupId = group.id),
                  );
                },
              ),
            ),

            AppSpacing.gapX5l,

            // ── Room list ─────────────────────────────────────────────────────
            Expanded(
              child: ctrl.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : tiles.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.l10n.roomsEmptyState,
                              style: const TextStyle(
                                fontFamily: 'ShareTech',
                                fontSize: AppFontSizes.body,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.x3l),
                            GestureDetector(
                              onTap: () => _addRoom(ctrl),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surface,
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 22,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.x3l,
                            0,
                            AppSpacing.x3l,
                            100,
                          ),
                          itemCount: tiles.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.x3l),
                          itemBuilder: (_, i) {
                            if (i < tiles.length) return tiles[i];
                            // Circle add-room button at the bottom of the list
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.x2l),
                                child: GestureDetector(
                                  onTap: () => _addRoom(ctrl),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.surface,
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      size: 22,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
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

// ── Small data class for dialog result ────────────────────────────────────────

class _AddRoomResult {
  final String name;
  final String groupId;
  const _AddRoomResult({required this.name, required this.groupId});
}
