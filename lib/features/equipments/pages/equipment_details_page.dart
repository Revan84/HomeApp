import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
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

const _kNoRoom = '__none__';

class _EquipmentDetailsPageState extends State<EquipmentDetailsPage> {
  late final EquipmentDetailsController _controller;

  final GlobalKey _typeKey = GlobalKey();
  final GlobalKey _roomKey = GlobalKey();

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

  RelativeRect? _menuPosition(GlobalKey key) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    final keyCtx = key.currentContext;
    if (keyCtx == null || overlay == null) return null;
    final box = keyCtx.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;
    return RelativeRect.fromRect(
      Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height),
      Offset.zero & overlay.size,
    );
  }

  Future<void> _selectType() async {
    final equipment = _controller.equipment;
    if (equipment == null) return;
    final position = _menuPosition(_typeKey);
    if (position == null) return;

    final nextType = await showMenu<EquipmentType>(
      context: context,
      position: position,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
      items: EquipmentType.values.map((type) => PopupMenuItem<EquipmentType>(
        value: type,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type == equipment.type)
              const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
            else
              const SizedBox(width: 18),
            AppSpacing.gapHMd,
            Text(
              _typeLabel(context, type),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      )).toList(),
    );

    if (nextType == null) return;
    await _controller.updateType(nextType);
  }

  Future<void> _selectRoom() async {
    final equipment = _controller.equipment;
    if (equipment == null) return;
    final position = _menuPosition(_roomKey);
    if (position == null) return;

    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
      items: [
        PopupMenuItem<String>(
          value: _kNoRoom,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (equipment.roomId == null)
                const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
              else
                const SizedBox(width: 18),
              AppSpacing.gapHMd,
              Text(
                context.l10n.none,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ..._controller.rooms.map((room) => PopupMenuItem<String>(
          value: room.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (room.id == equipment.roomId)
                const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
              else
                const SizedBox(width: 18),
              AppSpacing.gapHMd,
              Text(
                room.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        )),
      ],
    );

    if (selected == null) return;
    await _controller.updateRoom(selected == _kNoRoom ? null : selected);
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
      case EquipmentType.shellyHT:
        return 'Shelly HT';
      case EquipmentType.hygrometer:
        return 'Hygrometer';
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
      EquipmentType.shellyHT => 'Shelly HT',
      EquipmentType.hygrometer => 'Hygrometer',
      EquipmentType.other => context.l10n.valueUnknown,
    };

    final energyLabel = energyWh == null
        ? context.l10n.valueUnknown
        : context.l10n.energyWh(energyWh.toStringAsFixed(0));

    final connectionLabel =
        online ? context.l10n.detailsConnectedWifi : context.l10n.netStatusOffline;

    final accentColor = switch (equipment.type) {
      EquipmentType.shellyPlusPlugS || EquipmentType.shellyPlugS =>
        AppColors.plugAccent,
      EquipmentType.shellyHT => AppColors.thermometerAccent,
      EquipmentType.hygrometer => AppColors.hygrometerAccent,
      EquipmentType.other => null,
    };

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
            accentColor: accentColor,
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
                AppSpacing.gapX2l,
                HistoryRangeChips(
                  value: _window,
                  onChanged: _handleWindowChanged,
                ),
                AppSpacing.gapLg,
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
                AppSpacing.gapX2l,
                EquipmentInfoGrid(
                  ipLabel: context.l10n.deviceInfoLocalIp,
                  ip: equipment.ip,
                  onEditIp: _editLocalIp,
                  typeLabelText: context.l10n.typeLabel,
                  typeValue: _typeLabel(context, equipment.type),
                  onSelectType: _selectType,
                  typeAnchorKey: _typeKey,
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
                AppSpacing.gapX4l,
                RoomToggleRow(
                  anchorKey: _roomKey,
                  roomName: _controller.roomName(
                      equipment.roomId, context.l10n.none),
                  onSelectRoom: _selectRoom,
                  isOn: isOn,
                  loading: toggling,
                  onTap: equipment.showToggle
                      ? () => _controller.toggleOutput()
                      : null,
                ),
              ],
            ),
          ),
          AppSpacing.gapX3l,
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
