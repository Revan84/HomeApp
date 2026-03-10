import 'package:flutter/material.dart';
import 'package:front_end/features/home/pages/favorites_page.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/utils/iterable_ext.dart';
import '../../../core/utils/time_label.dart';
import '../../../core/design_system/layout/app_section_header.dart';

import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/models/equipment.dart';
import '../../../domain/models/room.dart';

import '../../../data/mappers/equipment_mappers.dart';
import '../../live/controllers/live_polling_controller.dart';

import '../../equipments/pages/equipment_details_page.dart';

import '../../equipments/widgets/edit_equipment_sheet.dart';
import '../widgets/areas_section.dart';
import '../widgets/favorite_card.dart';
import '../widgets/home_summary_header.dart';

class HomeTab extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;

  const HomeTab({
    super.key,
    required this.refreshNotifier,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _loading = true;
  List<Room> _rooms = [];
  List<Equipment> _equipments = [];

  void _onRefreshRequested() => _load();

  bool _isPlug(Equipment equipment) =>
      equipment.type == EquipmentType.shellyPlusPlugS;

  bool _isFavoriteSupported(Equipment equipment) =>
      _isPlug(equipment) && equipment.showToggle;

  List<Equipment> get _favorites =>
      _equipments.where((equipment) => equipment.isFavorite).toList();

  List<Equipment> get _followedForHome {
    final favoriteDevices = _equipments
        .where((equipment) => equipment.isFavorite && _isFavoriteSupported(equipment))
        .toList();

    final roomPlugs = <Equipment>[];

    for (final room in _rooms) {
      final plugs = _equipments
          .where((equipment) => _isPlug(equipment) && equipment.roomId == room.id)
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
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_onRefreshRequested);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final roomRepository = context.read<RoomRepository>();
    final equipmentRepository = context.read<EquipmentRepository>();
    final liveController = context.read<LivePollingController>();

    final rooms = await roomRepository.loadAll();
    final equipments = await equipmentRepository.loadAll();

    if (!mounted) return;

    _rooms = rooms;
    _equipments = equipments;

    final endpoints = _followedForHome.map((equipment) => equipment.toEndpoint());
    liveController.syncFollowed(endpoints, forcePollNow: true);

    setState(() => _loading = false);
  }

  String _roomName(String? roomId) => roomId == null
      ? context.l10n.valueUnknown
      : (_rooms.where((room) => room.id == roomId).map((room) => room.name).firstOrNull ??
          context.l10n.valueUnknown);

  Future<void> _openDetails(Equipment equipment) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EquipmentDetailsPage(equipmentId: equipment.id),
      ),
    );

    if (changed == true) {
      await _load();
    }
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
      await _load();
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
      await _load();
    }
  }

  Future<void> _removeFromFavorites(Equipment equipment) async {
    final updated = equipment.copyWith(isFavorite: false);
    await context.read<EquipmentRepository>().update(updated);
    await _load();
  }

  Future<void> _toggleFavoritePlug(Equipment equipment) async {
    await context.read<LivePollingController>().toggle(equipment.toEndpoint());
  }

  @override
  Widget build(BuildContext context) {
    final liveController = context.watch<LivePollingController>();
    final favorites = _favorites;

    final onlineCount = _equipments.where((equipment) {
      final state = liveController.live[equipment.id];
      return state?.online == true;
    }).length;

    final offlineCount = _equipments.where((equipment) {
      final state = liveController.live[equipment.id];
      return state != null && state.online == false;
    }).length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
            children: [
              HomeSummaryHeader(
                areaGroupLabel: context.l10n.homeDefaultAreaGroupName,
                onlineCount: onlineCount,
                offlineCount: offlineCount,
              ),
              const SizedBox(height: 18),
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
              else if (favorites.isEmpty)
                SizedBox(
                  height: 150,
                  child: Center(
                    child: Text(context.l10n.noFavorites),
                  ),
                )
              else
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: favorites.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      final equipment = favorites[index];
                      final supported = _isFavoriteSupported(equipment);
                      final state = supported ? liveController.live[equipment.id] : null;

                      final value = supported
                          ? (equipment.showPower
                              ? '${(state?.powerW ?? 0).toStringAsFixed(0)} ${context.l10n.unitWattShort}'
                              : (state?.output == true
                                  ? context.l10n.valueOn
                                  : context.l10n.valueOff))
                          : context.l10n.valueUnknown;

                      return FavoriteCard(
                        value: value,
                        label: equipment.name,
                        room: _roomName(equipment.roomId),
                        icon: supported
                            ? Icons.power_rounded
                            : Icons.devices_other,
                        isOn: state?.output == true,
                        showPowerButton: supported,
                        powerLoading: state?.toggling ?? false,
                        powerEnabled: state?.online ?? false,
                        onPowerPressed: supported
                            ? () => _toggleFavoritePlug(equipment)
                            : null,
                        trend: state?.trendPower ?? 0,
                        updatedLabel: ageLabel(context, state?.lastUpdatedAt),
                        onOpenDetails: () => _openDetails(equipment),
                        onToggleFavorite: () => _removeFromFavorites(equipment),
                        onEdit: () => _editEquipment(equipment),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 18),
              AreasSection(
                rooms: _rooms,
                equipments: _equipments,
                onOpenEquipment: (equipmentId) {
                  final equipment =
                      _equipments.firstWhere((item) => item.id == equipmentId);
                  _openDetails(equipment);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}