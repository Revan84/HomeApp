import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/utils/iterable_ext.dart';
import '../../../core/utils/time_label.dart';
import '../../../core/design_system/layout/app_section_header.dart';

import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_group_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/tv_repository.dart';
import '../../../domain/models/equipment.dart';
import '../../../domain/models/room.dart';
import '../../../domain/models/room_group.dart';
import '../../../domain/models/tv_device.dart';

import '../../../data/mappers/equipment_mappers.dart';
import '../../live/controllers/live_polling_controller.dart';

import '../../equipments/pages/equipment_details_page.dart';
import '../../tv/pages/tv_details_page.dart';

import '../../equipments/widgets/edit_equipment_sheet.dart';
import '../widgets/areas_section.dart';
import '../widgets/favorite_card.dart';

import 'rooms_page.dart';
import 'favorites_page.dart';

class HomeTab extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;
  final ValueNotifier<String?> selectedGroupIdNotifier;

  const HomeTab({
    super.key,
    required this.refreshNotifier,
    required this.selectedGroupIdNotifier,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _loading = true;

  List<RoomGroup> _roomGroups = const [];
  List<Room> _rooms = const [];
  List<Equipment> _equipments = const [];
  List<TvDevice> _tvDevices = const [];

  void _onRefreshRequested() => _load();

  void _onGroupChanged() {
    if (!mounted) return;
    final liveController = context.read<LivePollingController>();
    final endpoints = _followedForHome.map((equipment) => equipment.toEndpoint());
    liveController.syncFollowed(endpoints, forcePollNow: true);
    setState(() {});
  }

  String? get _selectedRoomGroupId => widget.selectedGroupIdNotifier.value;

  bool _isPlug(Equipment equipment) =>
      equipment.type == EquipmentType.shellyPlusPlugS;

  bool _isFavoriteSupported(Equipment equipment) =>
      _isPlug(equipment) && equipment.showToggle;

  Set<String> get _visibleRoomIds =>
      _visibleRooms.map((room) => room.id).toSet();

  /// Favorite plug equipments visible in the selected group.
  List<Equipment> get _favoriteEquipments => _equipments
      .where((equipment) =>
          equipment.isFavorite && _visibleRoomIds.contains(equipment.roomId))
      .toList();

  /// Favorite TV devices visible in the selected group.
  List<TvDevice> get _favoriteTvs => _tvDevices
      .where((tv) => tv.isFavorite && _visibleRoomIds.contains(tv.roomId))
      .toList();

  RoomGroup? get _activeRoomGroup {
    final id = _selectedRoomGroupId;
    if (id == null) return null;

    return _roomGroups
        .where((group) => group.id == id)
        .cast<RoomGroup?>()
        .firstWhere(
          (group) => group != null,
          orElse: () => null,
        );
  }

  List<Room> get _visibleRooms {
    final activeGroupId = _selectedRoomGroupId;
    if (activeGroupId == null) return const [];

    return _rooms
        .where((room) => room.groupId == activeGroupId)
        .toList(growable: false);
  }

  List<Equipment> get _followedForHome {
    final favoriteDevices = _equipments
        .where(
          (equipment) => equipment.isFavorite && _isFavoriteSupported(equipment),
        )
        .toList(growable: false);

    final roomPlugs = <Equipment>[];

    for (final room in _visibleRooms) {
      final plugs = _equipments
          .where(
            (equipment) =>
                _isPlug(equipment) && equipment.roomId == room.id,
          )
          .take(3);
      roomPlugs.addAll(plugs);
    }

    final uniqueById = <String, Equipment>{};

    for (final equipment in [...favoriteDevices, ...roomPlugs]) {
      uniqueById[equipment.id] = equipment;
    }

    return uniqueById.values.toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _load();
    widget.refreshNotifier.addListener(_onRefreshRequested);
    widget.selectedGroupIdNotifier.addListener(_onGroupChanged);
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_onRefreshRequested);
    widget.selectedGroupIdNotifier.removeListener(_onGroupChanged);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final roomGroupRepository = context.read<RoomGroupRepository>();
    final roomRepository = context.read<RoomRepository>();
    final equipmentRepository = context.read<EquipmentRepository>();
    final tvRepository = context.read<TvRepository>();
    final liveController = context.read<LivePollingController>();

    final roomGroups = await roomGroupRepository.loadAll();
    final rooms = await roomRepository.loadAll();
    final equipments = await equipmentRepository.loadAll();
    final tvDevices = await tvRepository.loadAll();

    if (!mounted) return;

    _roomGroups = [...roomGroups]..sort((a, b) {
        final sortComparison = a.sortOrder.compareTo(b.sortOrder);
        if (sortComparison != 0) return sortComparison;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    _rooms = rooms;
    _equipments = equipments;
    _tvDevices = tvDevices;

    // Initialise the shared selected group if needed.
    final currentId = widget.selectedGroupIdNotifier.value;
    if (!_roomGroups.any((g) => g.id == currentId)) {
      widget.selectedGroupIdNotifier.value =
          _roomGroups.isNotEmpty ? _roomGroups.first.id : null;
    }

    final endpoints = _followedForHome.map((equipment) => equipment.toEndpoint());
    liveController.syncFollowed(endpoints, forcePollNow: true);

    setState(() => _loading = false);
  }

  String _roomName(String? roomId) {
    if (roomId == null) return context.l10n.valueUnknown;

    return _rooms
            .where((room) => room.id == roomId)
            .map((room) => room.name)
            .firstOrNull ??
        context.l10n.valueUnknown;
  }

  Future<void> _openDetails(Equipment equipment) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EquipmentDetailsPage(equipmentId: equipment.id),
      ),
    );

    if (changed == true) {
      widget.refreshNotifier.value++;
    }
  }

  Future<void> _openTvDetails(TvDevice tv) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TvDetailsPage(deviceId: tv.id),
      ),
    );
    // Reload to pick up any favorite changes made inside details
    await _load();
  }

  Future<void> _removeTvFromFavorites(TvDevice tv) async {
    final updated = tv.copyWith(isFavorite: false);
    await context.read<TvRepository>().update(updated);
    widget.refreshNotifier.value++;
  }

  Future<void> _openFavoritesPage() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FavoritesPage(
          equipments: _equipments,
          rooms: _rooms,
        ),
      ),
    );

    if (changed == true) {
      widget.refreshNotifier.value++;
    }
  }

  Future<void> _openRoomsPage() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RoomsPage(
          activeGroup: _activeRoomGroup,
          rooms: _visibleRooms,
          equipments: _equipments,
        ),
      ),
    );

    if (changed == true) {
      widget.refreshNotifier.value++;
    }
  }

  Future<void> _editEquipment(Equipment equipment) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EditEquipmentSheet(initial: equipment),
    );

    if (changed == true) {
      widget.refreshNotifier.value++;
    }
  }

  Future<void> _removeFromFavorites(Equipment equipment) async {
    final updated = equipment.copyWith(isFavorite: false);
    await context.read<EquipmentRepository>().update(updated);
    widget.refreshNotifier.value++;
  }

  Future<void> _toggleFavoritePlug(Equipment equipment) async {
    await context.read<LivePollingController>().toggle(equipment.toEndpoint());
  }

  @override
  Widget build(BuildContext context) {
    final liveController = context.watch<LivePollingController>();
    final favoriteEquipments = _favoriteEquipments;
    final favoriteTvs = _favoriteTvs;
    final hasFavorites = favoriteEquipments.isNotEmpty || favoriteTvs.isNotEmpty;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          children: [
            const SizedBox(height: 4),
            SectionHeader(
              title: context.l10n.favorites,
              onTap: _openFavoritesPage,
            ),
            const SizedBox(height: 10),
            if (_loading)
              const SizedBox(
                height: 150,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (!hasFavorites)
              SizedBox(
                height: 150,
                child: Center(
                  child: Text(context.l10n.noFavorites),
                ),
              )
            else
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Equipment (plug) favorites
                    ...favoriteEquipments.map((equipment) {
                      final supported = _isFavoriteSupported(equipment);
                      final state = supported
                          ? liveController.live[equipment.id]
                          : null;

                      final value = supported
                          ? (equipment.showPower
                              ? '${(state?.powerW ?? 0).toStringAsFixed(0)} ${context.l10n.unitWattShort}'
                              : (state?.output == true
                                  ? context.l10n.valueOn
                                  : context.l10n.valueOff))
                          : context.l10n.valueUnknown;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FavoriteCard(
                          value: value,
                          label: equipment.name,
                          room: _roomName(equipment.roomId),
                          icon: supported
                              ? Icons.power_rounded
                              : Icons.devices_other,
                          isOn: state?.output == true,
                          showPowerButton: supported,
                          powerLoading: state?.toggling ?? false,
                          powerEnabled: true,
                          onPowerPressed: supported
                              ? () => _toggleFavoritePlug(equipment)
                              : null,
                          trend: state?.trendPower ?? 0,
                          updatedLabel:
                              ageLabel(context, state?.lastUpdatedAt),
                          onOpenDetails: () => _openDetails(equipment),
                          onToggleFavorite: () =>
                              _removeFromFavorites(equipment),
                          onEdit: () => _editEquipment(equipment),
                        ),
                      );
                    }),

                    // TV device favorites
                    ...favoriteTvs.map((tv) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FavoriteCard(
                          value: tv.source,
                          label: tv.name,
                          room: _roomName(tv.roomId),
                          icon: Icons.tv_rounded,
                          isOn: true,
                          showPowerButton: false,
                          powerEnabled: false,
                          trend: 0,
                          updatedLabel: '',
                          onOpenDetails: () => _openTvDetails(tv),
                          onToggleFavorite: () => _removeTvFromFavorites(tv),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            SectionHeader(
              title: context.l10n.roomsSectionTitle,
              onTap: _openRoomsPage,
            ),
            const SizedBox(height: 10),
            AreasSection(
              rooms: _visibleRooms,
              equipments: _equipments,
              onOpenEquipment: (equipmentId) {
                final equipment = _equipments.firstWhere(
                  (item) => item.id == equipmentId,
                );
                _openDetails(equipment);
              },
            ),
          ],
        ),
      ),
    );
  }
}
