import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/i18n/loc.dart';

import '../../../domain/entities/equipment.dart';
import '../domain/metric_type.dart';
import '../domain/stat_widget.dart';

import '../controller/stats_controller.dart';
import '../utils/allowed_widgets.dart';
import '../widgets/stat_device_group_card.dart';
import '../widgets/stat_widget_config_dialog.dart';
import '../widgets/stat_widget_entry.dart';
import '../widgets/stat_widget_factory.dart';
import '../widgets/stats_empty_state.dart';
import '../widgets/stats_room_selector.dart';

/// Main statistics tab with two-level room group → room filtering
/// and a configurable widget dashboard grouped by device.
class StatsTab extends StatefulWidget {
  /// Shared notifier driven by AppShell's room group picker.
  final ValueNotifier<String?> selectedGroupIdNotifier;

  /// Set by AppShell FAB popup to trigger the add-widget config dialog
  /// for a specific [StatWidgetType].
  final ValueNotifier<StatWidgetType?> addWidgetNotifier;

  const StatsTab({
    super.key,
    required this.selectedGroupIdNotifier,
    required this.addWidgetNotifier,
  });

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  // Pure UI state: the group filter driven by the shell header notifier.
  String? _selectedGroupId;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.selectedGroupIdNotifier.value;
    widget.selectedGroupIdNotifier.addListener(_onGroupChangedExternal);
    widget.addWidgetNotifier.addListener(_onAddWidgetRequested);
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    widget.selectedGroupIdNotifier.removeListener(_onGroupChangedExternal);
    widget.addWidgetNotifier.removeListener(_onAddWidgetRequested);
    super.dispose();
  }

  Future<void> _init() async {
    if (!mounted) return;
    final controller = context.read<StatsController>();
    try {
      await controller.loadRoomsAndEquipments();
    } catch (_) {
      // Error state is exposed via controller.error.
    }
    if (!mounted) return;
    controller.selectFirstRoomOfGroup(_selectedGroupId);
  }

  void _onGroupChangedExternal() {
    final newId = widget.selectedGroupIdNotifier.value;
    if (newId == _selectedGroupId) return;
    setState(() => _selectedGroupId = newId);
    context.read<StatsController>().selectFirstRoomOfGroup(newId);
  }

  void _onAddWidgetRequested() {
    final type = widget.addWidgetNotifier.value;
    if (type != null) _showConfigDialog(type);
  }

  // ---------------------------------------------------------------------------
  // Config dialog (add)
  // ---------------------------------------------------------------------------

  Future<void> _showConfigDialog(StatWidgetType widgetType) async {
    final controller = context.read<StatsController>();
    final equipments = controller.equipmentsForRoom(controller.selectedRoomId);

    if (equipments.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.statsNoDevicesInRoom),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
      ));
      return;
    }

    final compatible =
        equipments.where((eq) => widgetTypesFor(eq).contains(widgetType)).toList();

    if (compatible.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.statsNoCompatibleDevice),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
      ));
      return;
    }

    final result = await StatWidgetConfigDialog.show(
      context,
      widgetType: widgetType,
      equipments: compatible,
    );
    if (result == null || !mounted) return;

    await context.read<StatsController>().addWidget(StatWidgetConfig(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          type: widgetType,
          title: '${result.equipment.name} · ${result.metric.label}',
          deviceId: result.equipment.id,
          metric: result.metric,
          range: result.range,
          chartType: widgetType == StatWidgetType.chart ? result.chartType : null,
        ));
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StatsController>();
    final roomsInGroup = controller.roomsForGroup(_selectedGroupId);

    return Column(
      children: [
        // -- Room chips (filtered by the active group from the header) --
        if (roomsInGroup.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: StatsRoomSelector(
              rooms: roomsInGroup,
              controller: controller,
            ),
          ),

        // -- Dashboard content --
        Expanded(
          child: controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : controller.widgets.isEmpty
                  ? const StatsEmptyState()
                  : _buildGroupedWidgetList(controller),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Grouped widget list (by device)
  // ---------------------------------------------------------------------------

  Widget _buildGroupedWidgetList(StatsController controller) {
    final grouped = controller.widgetsByDevice;
    final deviceIds = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: deviceIds.length,
      itemBuilder: (context, index) {
        final deviceId = deviceIds[index];
        final configs = grouped[deviceId]!;
        final equipment = controller.equipmentById(deviceId);
        final deviceName = equipment?.name ?? deviceId;
        final deviceTypeLabel = equipment != null
            ? _equipmentTypeLabel(context, equipment.type)
            : '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StatDeviceGroupCard(
            deviceName: deviceName,
            deviceTypeLabel: deviceTypeLabel,
            widgetCount: configs.length,
            initiallyExpanded: false,
            children: configs.map((config) {
              final series = controller.seriesFor(config);
              return StatWidgetEntry(
                config: config,
                child: StatWidgetFactory.build(
                  config,
                  series,
                  onRangeChanged: (range) {
                    controller.refreshSeries(
                        config.deviceId, config.metric, range);
                  },
                ),
                onEdit: () => _showEditConfigDialog(config),
                onDelete: () => _confirmDelete(config),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Human-readable equipment type label.
  String _equipmentTypeLabel(BuildContext context, EquipmentType type) {
    final l10n = context.l10n;
    switch (type) {
      case EquipmentType.shellyPlusPlugS:
      case EquipmentType.shellyPlugS:
        return l10n.statsDeviceTypeSmartPlug;
      case EquipmentType.shellyHT:
        return 'Thermometer';
      case EquipmentType.hygrometer:
        return 'Hygrometer';
      case EquipmentType.other:
        return l10n.statsDeviceTypeGeneric;
    }
  }

  // ---------------------------------------------------------------------------
  // Delete confirmation
  // ---------------------------------------------------------------------------

  Future<void> _confirmDelete(StatWidgetConfig config) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.statsDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      context.read<StatsController>().removeWidget(config.id);
    }
  }

  // ---------------------------------------------------------------------------
  // Edit dialog — pre-populated with current widget config
  // ---------------------------------------------------------------------------

  Future<void> _showEditConfigDialog(StatWidgetConfig config) async {
    final controller = context.read<StatsController>();
    final equipments = controller.equipmentsForRoom(controller.selectedRoomId);
    if (equipments.isEmpty) return;

    final initialEquipment = equipments.firstWhere(
      (e) => e.id == config.deviceId,
      orElse: () => equipments.first,
    );

    final result = await StatWidgetConfigDialog.show(
      context,
      widgetType: config.type,
      equipments: equipments,
      initialEquipment: initialEquipment,
      initialMetric: config.metric,
      initialRange: config.range,
      initialChartType: config.chartType,
      isEdit: true,
    );
    if (result == null || !mounted) return;

    await context.read<StatsController>().updateWidget(config.copyWith(
          title: '${result.equipment.name} · ${result.metric.label}',
          deviceId: result.equipment.id,
          metric: result.metric,
          range: result.range,
          chartType: config.type == StatWidgetType.chart ? result.chartType : null,
        ));
  }
}

