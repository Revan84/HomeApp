import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/time_label.dart';

import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/history_window.dart';
import '../../../domain/entities/live_point.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_repository.dart';

import '../../live/controllers/live_polling_controller.dart';
import '../../live/widgets/charts/line_chart/chart_bounds.dart';
import '../../live/widgets/charts/line_chart/history_range_chips.dart';
import '../../live/widgets/charts/line_chart/interactive_line_chart.dart';

import '../controllers/equipment_details_controller.dart';
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
  late final EquipmentDetailsController _controller;

  // Pure UI state: not part of the domain or business logic.
  HistoryWindow _window = HistoryWindow.d1;
  LivePoint? _hoverPoint;

  @override
  void initState() {
    super.initState();
    _controller = EquipmentDetailsController(
      equipmentRepo: context.read<EquipmentRepository>(),
      roomRepo: context.read<RoomRepository>(),
      live: context.read<LivePollingController>(),
    );
    _controller.addListener(_onControllerUpdate);
    _reload();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _reload() async {
    final found = await _controller.load(widget.equipmentId);
    if (!found && mounted) Navigator.of(context).pop(false);
  }

  // ---------------------------------------------------------------------------
  // Actions — dialog orchestration only; logic lives in the controller
  // ---------------------------------------------------------------------------

  Future<void> _editName() async {
    final equipment = _controller.equipment;
    if (equipment == null) return;
    final nextName = await EquipmentEditDialogs.editName(
      context,
      currentName: equipment.name,
    );
    if (nextName == null) return;
    await _controller.updateName(nextName);
  }

  Future<void> _editLocalIp() async {
    final equipment = _controller.equipment;
    if (equipment == null) return;
    final nextIp = await EquipmentEditDialogs.editLocalIp(
      context,
      currentIp: equipment.ip,
    );
    if (nextIp == null) return;
    await _controller.updateIp(nextIp);
  }

  Future<void> _selectType() async {
    final equipment = _controller.equipment;
    if (equipment == null) return;
    final nextType = await EquipmentEditDialogs.pickType(
      context,
      current: equipment.type,
      labelOf: (type) => _typeLabel(context, type),
    );
    if (nextType == null) return;
    await _controller.updateType(nextType);
  }

  Future<void> _selectRoom() async {
    final equipment = _controller.equipment;
    if (equipment == null) return;
    final nextRoomId = await EquipmentEditDialogs.pickRoom(
      context,
      currentRoomId: equipment.roomId,
      rooms: _controller.rooms,
      noneLabel: context.l10n.none,
    );
    await _controller.updateRoom(nextRoomId);
  }

  Future<void> _deleteEquipment() async {
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
    await _controller.delete();
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

  // ---------------------------------------------------------------------------
  // Presentation helpers (label formatting, no logic)
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading || _controller.equipment == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final equipment = _controller.equipment!;
    final liveController = context.watch<LivePollingController>();
    final liveState = liveController.live[equipment.id];

    final history =
        liveController.historyFor(equipment.id, _window).toList(growable: false);

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

    final connectionLabel =
        online ? context.l10n.detailsConnectedWifi : context.l10n.netStatusOffline;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(
            tooltip: context.l10n.refresh,
            onPressed: _reload,
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
                  onRefresh: _reload,
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
                    setState(() => _hoverPoint = point);
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
                  onToggleFavorite: _controller.toggleFavorite,
                  energyLabel: energyLabel,
                  modelLabel: modelLabel,
                  online: online,
                  connectionLabel: connectionLabel,
                ),
                const SizedBox(height: 18),
                RoomToggleRow(
                  roomName: _controller.roomName(
                      equipment.roomId, context.l10n.none),
                  onSelectRoom: _selectRoom,
                  value: isOn,
                  onChanged: (!toggling && equipment.showToggle)
                      ? (_) => _controller.toggleOutput()
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
