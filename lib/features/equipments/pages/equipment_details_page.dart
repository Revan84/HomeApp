import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/time_label.dart';

import '../../../domain/models/history_window.dart';
import '../../../domain/models/live_point.dart';
import '../../../domain/models/room.dart';
import '../../../domain/models/equipment.dart';

import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_repository.dart';

import '../../live/widgets/charts/line_chart/chart_bounds.dart';
import '../../live/widgets/charts/line_chart/history_range_chips.dart';
import '../../live/widgets/charts/line_chart/interactive_line_chart.dart';

import '../../live/controllers/live_polling_controller.dart';

import '../../../data/mappers/equipment_mappers.dart';
import '../dialogs/equipment_edit_dialogs.dart';

import '../widgets/equipment_header.dart';
import '../widgets/equipment_info_grid.dart';
import '../widgets/prototype_card.dart';
import '../widgets/room_toggle_row.dart';

class EquipmentDetailsPage extends StatefulWidget {
  final String equipmentId;

  const EquipmentDetailsPage({super.key, required this.equipmentId});

  @override
  State<EquipmentDetailsPage> createState() => _EquipmentDetailsPageState();
}

class _EquipmentDetailsPageState extends State<EquipmentDetailsPage> {
  late final EquipmentRepository _equipmentRepo;
  late final RoomRepository _roomRepo;
  late final LivePollingController _live;

  Equipment? _equipment;
  List<Room> _rooms = const [];

  HistoryWindow _window = HistoryWindow.d1;

  bool _loading = true;
  bool _depsReady = false;

  LivePoint? _hoverPoint;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_depsReady) return;

    _equipmentRepo = context.read<EquipmentRepository>();
    _roomRepo = context.read<RoomRepository>();
    _live = context.read<LivePollingController>();

    _depsReady = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final equipments = await _equipmentRepo.loadAll();
    final rooms = await _roomRepo.loadAll();

    if (!mounted) return;

    final equipment = equipments.cast<Equipment?>().firstWhere(
      (item) => item?.id == widget.equipmentId,
      orElse: () => null,
    );

    if (equipment == null) {
      Navigator.of(context).pop(false);
      return;
    }

    _live.syncFollowed([equipment.toEndpoint()], forcePollNow: true);

    setState(() {
      _equipment = equipment;
      _rooms = rooms;
      _loading = false;
    });
  }

  Future<void> _editName() async {
    final equipment = _equipment;
    if (equipment == null) return;

    final nextName = await EquipmentEditDialogs.editName(
      context,
      currentName: equipment.name,
    );
    if (nextName == null) return;

    await _equipmentRepo.update(equipment.copyWith(name: nextName));

    await _load();
  }

  Future<void> _editLocalIp() async {
    final equipment = _equipment;
    if (equipment == null) return;

    final nextIp = await EquipmentEditDialogs.editLocalIp(
      context,
      currentIp: equipment.ip,
    );
    if (nextIp == null) return;

    await _equipmentRepo.update(equipment.copyWith(ip: nextIp));

    await _load();
  }

  Future<void> _toggleFavorite() async {
    final equipment = _equipment;
    if (equipment == null) return;

    await _equipmentRepo.update(
      equipment.copyWith(isFavorite: !equipment.isFavorite),
    );

    await _load();
  }

  Future<void> _selectType() async {
    final equipment = _equipment;
    if (equipment == null) return;

    final nextType = await EquipmentEditDialogs.pickType(
      context,
      current: equipment.type,
      labelOf: (type) => _typeLabel(context, type),
    );

    if (nextType == null || nextType == equipment.type) return;

    await _equipmentRepo.update(equipment.copyWith(type: nextType));

    await _load();
  }

  Future<void> _selectRoom() async {
    final equipment = _equipment;
    if (equipment == null) return;

    final nextRoomId = await EquipmentEditDialogs.pickRoom(
      context,
      currentRoomId: equipment.roomId,
      rooms: _rooms,
      noneLabel: context.l10n.none,
    );

    if (nextRoomId == equipment.roomId) return;

    await _equipmentRepo.update(equipment.copyWith(roomId: nextRoomId));

    await _load();
  }

  Future<void> _deleteEquipment() async {
    final equipment = _equipment;
    if (equipment == null) return;

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.delete),
        content: Text(context.l10n.confirmDeleteEquipment),
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

    if (isConfirmed != true) return;

    await _equipmentRepo.deleteById(equipment.id);

    // Remove the deleted device from live tracking and local history.
    _live.unfollowDevice(equipment.id);
    await _live.deleteHistoryForDevice(equipment.id);

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  void _handleWindowChanged(HistoryWindow nextWindow) {
    if (_window == nextWindow) return;

    setState(() {
      _window = nextWindow;
      _hoverPoint = null;
    });
  }

  String _typeLabel(BuildContext context, EquipmentType type) {
    switch (type) {
      case EquipmentType.shellyPlusPlugS:
        return context.l10n.equipmentTypeShellyPlusPlugS;
      case EquipmentType.shellyPlugS:
        return context.l10n.equipmentTypeShellyPlugS;
      case EquipmentType.other:
        return context.l10n.equipmentTypeOther;
    }
  }

  String _roomName(BuildContext context, String? roomId) {
    if (roomId == null) return context.l10n.none;

    final matchingRooms = _rooms
        .where((room) => room.id == roomId)
        .toList(growable: false);

    return matchingRooms.isEmpty ? context.l10n.none : matchingRooms.first.name;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _equipment == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final equipment = _equipment!;
    final liveController = context.watch<LivePollingController>();
    final liveState = liveController.live[equipment.id];

    final history =
        liveController.historyFor(equipment.id, _window).toList(growable: true)
          ..sort((a, b) => a.at.compareTo(b.at));

    final bounds = computeNicePowerBounds(history);

    final powerW = liveState?.powerW;
    final energyWh = liveState?.energyWh;
    final online = liveState?.online ?? false;
    final toggling = liveState?.toggling ?? false;
    final isOn = liveState?.output == true;

    final updatedLabel = ageLabel(context, liveState?.lastUpdatedAt);
    final trend = liveState?.trendPower ?? 0;

    final displayedPowerW = _hoverPoint?.powerW ?? powerW;

    final modelLabel = switch (equipment.type) {
      EquipmentType.shellyPlusPlugS =>
        context.l10n.equipmentTypeShellyPlusPlugS,
      EquipmentType.shellyPlugS => context.l10n.equipmentTypeShellyPlugS,
      EquipmentType.other => context.l10n.valueUnknown,
    };

    final energyLabel = energyWh == null
        ? context.l10n.valueUnknown
        : context.l10n.energyWh(energyWh.toStringAsFixed(0));

    final connectionLabel = online
        ? context.l10n.detailsConnectedWifi
        : context.l10n.netStatusOffline;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(
            tooltip: context.l10n.refresh,
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          PrototypeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EquipmentHeader(
                  powerW: displayedPowerW?.toDouble(),
                  updatedLabel: updatedLabel,
                  trend: trend,
                  name: equipment.name,
                  onEditName: _editName,
                  onRefresh: _load,
                ),
                const SizedBox(height: 14),
                HistoryRangeChips(
                  value: _window,
                  onChanged: _handleWindowChanged,
                ),
                const SizedBox(height: 10),
                InteractiveLineChart(
                  points: history,
                  window: _window,
                  minY: bounds.minY,
                  maxY: bounds.maxY,
                  height: 180,
                  powerUnitLabel: context.l10n.unitWattShort,
                  onHoverPoint: (point) {
                    setState(() {
                      _hoverPoint = point;
                    });
                  },
                ),
                const SizedBox(height: 14),
                EquipmentInfoGrid(
                  ipLabel: context.l10n.ipLocalLabel,
                  ip: equipment.ip,
                  onEditIp: _editLocalIp,
                  typeLabelText: context.l10n.typeLabel,
                  typeValue: _typeLabel(context, equipment.type),
                  onSelectType: _selectType,
                  favoriteLabel: context.l10n.favorite,
                  favoriteValue: equipment.isFavorite
                      ? context.l10n.valueYes
                      : context.l10n.valueNo,
                  isFavorite: equipment.isFavorite,
                  onToggleFavorite: _toggleFavorite,
                  energyLabel: energyLabel,
                  modelLabel: modelLabel,
                  online: online,
                  connectionLabel: connectionLabel,
                ),
                const SizedBox(height: 18),
                RoomToggleRow(
                  roomName: _roomName(context, equipment.roomId),
                  onSelectRoom: _selectRoom,
                  value: isOn,
                  onChanged: (!toggling && equipment.showToggle)
                      ? (_) => _live.toggle(equipment.toEndpoint())
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _deleteEquipment,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                context.l10n.delete,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
