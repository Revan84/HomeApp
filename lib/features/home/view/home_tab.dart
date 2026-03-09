import 'package:flutter/material.dart';
import 'package:front_end/core/i18n/loc.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/section_header.dart';
import 'widgets/favorite_card.dart';
import '../../../core/utils/time_label.dart';
import '../../../core/utils/iterable_ext.dart';

import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../equipments/model/equipment_mappers.dart';

import '../../live/controller/live_polling_controller.dart';

import '../../equipments/model/equipment.dart';
import '../../equipments/view/edit_equipment_sheet.dart';
import '../../equipments/view/equipment_details_page.dart';

import '../model/room.dart';
import 'areas_section.dart';

class HomeTab extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;
  const HomeTab({super.key, required this.refreshNotifier});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _loading = true;
  List<Room> _rooms = [];
  List<Equipment> _equipments = [];

  void _onRefreshRequested() => _load();

  bool _isPlug(Equipment e) => e.type == EquipmentType.shellyPlusPlugS;
  bool _isFavoriteSupported(Equipment e) => _isPlug(e) && e.showToggle;

  List<Equipment> get _favorites =>
      _equipments.where((e) => e.isFavorite).toList();

  List<Equipment> get _followedForHome {
    final fav = _equipments
        .where((e) => e.isFavorite && _isFavoriteSupported(e))
        .toList();

    final roomPlugs = <Equipment>[];
    for (final r in _rooms) {
      final plugs = _equipments
          .where((e) => _isPlug(e) && e.roomId == r.id)
          .take(3);
      roomPlugs.addAll(plugs);
    }

    final map = <String, Equipment>{};
    for (final e in [...fav, ...roomPlugs]) {
      map[e.id] = e;
    }
    return map.values.toList();
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

    final roomRepo = context.read<RoomRepository>();
    final eqRepo = context.read<EquipmentRepository>();
    final liveCtl = context.read<LivePollingController>();

    final rooms = await roomRepo.loadAll();
    final eqs = await eqRepo.loadAll();

    if (!mounted) return;

    _rooms = rooms;
    _equipments = eqs;

    final endpoints = _followedForHome.map((e) => e.toEndpoint()).toList();
    liveCtl.syncFollowed(endpoints, forcePollNow: true);

    setState(() => _loading = false);
  }

  String _roomName(String? roomId) => roomId == null
      ? context.l10n.valueUnknown
      : (_rooms.where((r) => r.id == roomId).map((r) => r.name).firstOrNull ??
            context.l10n.valueUnknown);

  Future<void> _openDetails(Equipment e) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EquipmentDetailsPage(equipmentId: e.id)),
    );
    if (changed == true) await _load();
  }

  Future<void> _editEquipment(Equipment e) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EditEquipmentSheet(initial: e),
    );
    if (changed == true) await _load();
  }

  Future<void> _removeFromFavorites(Equipment e) async {
    final updated = e.copyWith(isFavorite: false);
    await context.read<EquipmentRepository>().update(updated);
    await _load();
  }

  Future<void> _toggleFavoritePlug(Equipment e) async {
    await context.read<LivePollingController>().toggle(e.toEndpoint());
  }

  @override
  Widget build(BuildContext context) {
    final liveCtl = context.watch<LivePollingController>();
    final favorites = _favorites;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
            children: [
              SectionHeader(title: context.l10n.favorites),
              const SizedBox(height: 10),

              if (_loading)
                const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (favorites.isEmpty)
                SizedBox(
                  height: 150,
                  child: Center(child: Text(context.l10n.noFavorites)),
                )
              else
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: favorites.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final e = favorites[i];
                      final supported = _isFavoriteSupported(e);
                      final st = supported ? liveCtl.live[e.id] : null;

                      final value = supported
                          ? (e.showPower
                                ? '${(st?.powerW ?? 0).toStringAsFixed(0)} W'
                                : (st?.output == true
                                      ? context.l10n.valueOn
                                      : context.l10n.valueOff))
                          : context.l10n.valueUnknown;

                      return FavoriteCard(
                        value: value,
                        label: e.name,
                        room: _roomName(e.roomId),
                        icon: supported
                            ? Icons.power_rounded
                            : Icons.devices_other,
                        isOn: st?.output == true,
                        showPowerButton: supported,
                        powerLoading: st?.toggling ?? false,
                        powerEnabled: st?.online ?? false,
                        onPowerPressed: supported
                            ? () => _toggleFavoritePlug(e)
                            : null,
                        trend: st?.trendPower ?? 0,
                        updatedLabel: ageLabel(context, st?.lastUpdatedAt),
                        onOpenDetails: () => _openDetails(e),
                        onToggleFavorite: () => _removeFromFavorites(e),
                        onEdit: () => _editEquipment(e),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 18),

              AreasSection(
                rooms: _rooms,
                equipments: _equipments,
                onOpenEquipment: (deviceId) {
                  final eq = _equipments.firstWhere((x) => x.id == deviceId);
                  _openDetails(eq);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
