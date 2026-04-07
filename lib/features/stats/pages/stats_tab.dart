import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/i18n/loc.dart';

import '../domain/chart_type.dart';
import '../../../domain/entities/equipment.dart';
import '../domain/metric_type.dart';
import '../domain/stat_widget.dart';
import '../domain/time_range.dart';

import '../controller/stats_controller.dart';
import '../utils/allowed_widgets.dart';
import '../widgets/stat_device_group_card.dart';
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
  // Config dialog
  // ---------------------------------------------------------------------------

  Future<void> _showConfigDialog(StatWidgetType widgetType) async {
    final controller = context.read<StatsController>();
    final equipments = controller.equipmentsForRoom(controller.selectedRoomId);

    if (equipments.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.statsNoDevicesInRoom),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
        ),
      );
      return;
    }

    // Filter equipments whose DeviceType supports this widgetType.
    final compatibleEquipments = equipments.where((eq) {
      return widgetTypesFor(eq).contains(widgetType);
    }).toList();

    if (compatibleEquipments.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.statsNoCompatibleDevice),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
        ),
      );
      return;
    }

    Equipment selectedEquipment = compatibleEquipments.first;
    List<MetricType> availableMetrics = metricsFor(selectedEquipment);
    MetricType selectedMetric =
        availableMetrics.isNotEmpty ? availableMetrics.first : MetricType.power;
    TimeRange selectedRange = TimeRange.day1;
    ChartType chartType = ChartType.line;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(ctx.l10n.statsConfigTitle),
              content: SingleChildScrollView(
                child: _buildConfigFields(
                  ctx: ctx,
                  setDialogState: setDialogState,
                  equipments: compatibleEquipments,
                  selectedEquipment: selectedEquipment,
                  availableMetrics: availableMetrics,
                  selectedMetric: selectedMetric,
                  selectedRange: selectedRange,
                  chartType: chartType,
                  widgetType: widgetType,
                  onEquipmentChanged: (eq, metrics) {
                    selectedEquipment = eq;
                    availableMetrics = metrics;
                    if (!metrics.contains(selectedMetric)) {
                      selectedMetric = metrics.isNotEmpty
                          ? metrics.first
                          : MetricType.power;
                    }
                  },
                  onMetricChanged: (m) => selectedMetric = m,
                  onRangeChanged: (r) => selectedRange = r,
                  onChartTypeChanged: (ct) => chartType = ct,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(ctx.l10n.cancel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(ctx.l10n.add),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final config = StatWidgetConfig(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: widgetType,
      title: '${selectedEquipment.name} · ${selectedMetric.label}',
      deviceId: selectedEquipment.id,
      metric: selectedMetric,
      range: selectedRange,
      chartType: widgetType == StatWidgetType.chart ? chartType : null,
    );

    await context.read<StatsController>().addWidget(config);
  }

  /// Shared form fields used by both add and edit config dialogs.
  Widget _buildConfigFields({
    required BuildContext ctx,
    required StateSetter setDialogState,
    required List<Equipment> equipments,
    required Equipment selectedEquipment,
    required List<MetricType> availableMetrics,
    required MetricType selectedMetric,
    required TimeRange selectedRange,
    required ChartType chartType,
    required StatWidgetType widgetType,
    required void Function(Equipment eq, List<MetricType> metrics)
        onEquipmentChanged,
    required ValueChanged<MetricType> onMetricChanged,
    required ValueChanged<TimeRange> onRangeChanged,
    required ValueChanged<ChartType> onChartTypeChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Equipment dropdown --
        Text(ctx.l10n.statsDeviceLabel,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.stroke.withValues(alpha: 0.4)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedEquipment.id,
              isExpanded: true,
              dropdownColor: AppColors.bg,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13),
              items: equipments.map((eq) {
                return DropdownMenuItem(
                  value: eq.id,
                  child: Text(eq.name),
                );
              }).toList(),
              onChanged: (id) {
                if (id == null) return;
                final eq = equipments.where((e) => e.id == id).firstOrNull;
                if (eq == null) return;
                final newMetrics = metricsFor(eq);
                setDialogState(() => onEquipmentChanged(eq, newMetrics));
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // -- Metric picker --
        Text(ctx.l10n.statsMetricLabel,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: availableMetrics.map((m) {
            final selected = m == selectedMetric;
            return ChoiceChip(
              avatar: Icon(_metricIcon(m),
                  size: 16,
                  color:
                      selected ? AppColors.bg : AppColors.textSecondary),
              label: Text(m.label,
                  style: TextStyle(
                      fontSize: 11,
                      color: selected
                          ? AppColors.bg
                          : AppColors.textSecondary)),
              selected: selected,
              selectedColor: AppColors.success,
              backgroundColor: AppColors.bg,
              onSelected: (_) =>
                  setDialogState(() => onMetricChanged(m)),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // -- Time range picker --
        Text(ctx.l10n.statsTimeRangeLabel,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: TimeRange.values.map((r) {
            final selected = r == selectedRange;
            return ChoiceChip(
              label: Text(r.shortLabel,
                  style: TextStyle(
                      fontSize: 11,
                      color: selected
                          ? AppColors.bg
                          : AppColors.textSecondary)),
              selected: selected,
              selectedColor: AppColors.success,
              backgroundColor: AppColors.bg,
              onSelected: (_) =>
                  setDialogState(() => onRangeChanged(r)),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),

        // -- Chart type (only for chart widgets) --
        if (widgetType == StatWidgetType.chart) ...[
          const SizedBox(height: 16),
          Text(ctx.l10n.statsChartTypeLabel,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: ChartType.values.map((ct) {
              final selected = ct == chartType;
              return ChoiceChip(
                label: Text('${ct.name[0].toUpperCase()}${ct.name.substring(1)}',
                    style: TextStyle(
                        fontSize: 11,
                        color: selected
                            ? AppColors.bg
                            : AppColors.textSecondary)),
                selected: selected,
                selectedColor: AppColors.success,
                backgroundColor: AppColors.bg,
                onSelected: (_) =>
                    setDialogState(() => onChartTypeChanged(ct)),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ],
    );
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
                  child: CircularProgressIndicator(color: AppColors.success))
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
      case EquipmentType.other:
        return l10n.statsDeviceTypeGeneric;
    }
  }

  /// Returns the icon for a [MetricType] in the presentation layer.
  IconData _metricIcon(MetricType type) {
    switch (type) {
      case MetricType.state:
        return Icons.toggle_on;
      case MetricType.temperature:
        return Icons.thermostat;
      case MetricType.humidity:
        return Icons.water_drop;
      case MetricType.power:
        return Icons.bolt;
      case MetricType.energy:
        return Icons.electrical_services;
      case MetricType.brightness:
        return Icons.light_mode;
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

    Equipment selectedEquipment = equipments.firstWhere(
      (e) => e.id == config.deviceId,
      orElse: () => equipments.first,
    );
    List<MetricType> availableMetrics = metricsFor(selectedEquipment);
    MetricType selectedMetric = availableMetrics.contains(config.metric)
        ? config.metric
        : (availableMetrics.isNotEmpty
            ? availableMetrics.first
            : MetricType.power);
    TimeRange selectedRange = config.range;
    ChartType chartType = config.chartType ?? ChartType.line;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(ctx.l10n.statsEditWidget),
              content: SingleChildScrollView(
                child: _buildConfigFields(
                  ctx: ctx,
                  setDialogState: setDialogState,
                  equipments: equipments,
                  selectedEquipment: selectedEquipment,
                  availableMetrics: availableMetrics,
                  selectedMetric: selectedMetric,
                  selectedRange: selectedRange,
                  chartType: chartType,
                  widgetType: config.type,
                  onEquipmentChanged: (eq, metrics) {
                    selectedEquipment = eq;
                    availableMetrics = metrics;
                    if (!metrics.contains(selectedMetric)) {
                      selectedMetric = metrics.isNotEmpty
                          ? metrics.first
                          : MetricType.power;
                    }
                  },
                  onMetricChanged: (m) => selectedMetric = m,
                  onRangeChanged: (r) => selectedRange = r,
                  onChartTypeChanged: (ct) => chartType = ct,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(ctx.l10n.cancel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(ctx.l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final updated = config.copyWith(
      title: '${selectedEquipment.name} · ${selectedMetric.label}',
      deviceId: selectedEquipment.id,
      metric: selectedMetric,
      range: selectedRange,
      chartType: config.type == StatWidgetType.chart ? chartType : null,
    );

    await context.read<StatsController>().updateWidget(updated);
  }
}

