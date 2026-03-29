import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/i18n/loc.dart';

import '../../../domain/models/equipment.dart';
import '../../../domain/models/metric_type.dart';
import '../../../domain/models/room.dart';
import '../../../domain/models/stat_widget.dart';
import '../../../domain/models/time_range.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_repository.dart';

import '../controller/stats_controller.dart';
import '../utils/allowed_widgets.dart';
import '../widgets/stat_widget_factory.dart';

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
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<Room> _allRooms = [];
  List<Equipment> _allEquipments = [];

  String? _selectedGroupId;
  String? _selectedRoomId;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.selectedGroupIdNotifier.value;
    widget.selectedGroupIdNotifier.addListener(_onGroupChangedExternal);
    widget.addWidgetNotifier.addListener(_onAddWidgetRequested);
    _loadData();
  }

  @override
  void dispose() {
    widget.selectedGroupIdNotifier.removeListener(_onGroupChangedExternal);
    widget.addWidgetNotifier.removeListener(_onAddWidgetRequested);
    super.dispose();
  }

  void _onGroupChangedExternal() {
    final newId = widget.selectedGroupIdNotifier.value;
    if (newId == _selectedGroupId) return;
    setState(() => _selectedGroupId = newId);
    _selectFirstRoomOfGroup(newId);
  }

  void _onAddWidgetRequested() {
    final type = widget.addWidgetNotifier.value;
    if (type != null) _showConfigDialog(type);
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadData() async {
    final roomRepo = context.read<RoomRepository>();
    final equipRepo = context.read<EquipmentRepository>();

    final results = await Future.wait([
      roomRepo.loadAll(),
      equipRepo.loadAll(),
    ]);

    if (!mounted) return;

    setState(() {
      _allRooms = results[0] as List<Room>;
      _allEquipments = results[1] as List<Equipment>;
    });

    _selectFirstRoomOfGroup(_selectedGroupId);
  }

  void _selectFirstRoomOfGroup(String? groupId) {
    final roomsInGroup = _roomsForGroup(groupId);
    final newRoomId = roomsInGroup.isNotEmpty ? roomsInGroup.first.id : null;
    _onRoomChanged(newRoomId);
  }

  List<Room> _roomsForGroup(String? groupId) {
    if (groupId == null) return _allRooms;
    return _allRooms.where((r) => r.groupId == groupId).toList();
  }

  List<Equipment> _equipmentsForRoom(String? roomId) {
    if (roomId == null) return [];
    return _allEquipments.where((e) => e.roomId == roomId).toList();
  }

  /// Finds an [Equipment] by id, or null.
  Equipment? _equipmentById(String id) {
    final matches = _allEquipments.where((e) => e.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  // ---------------------------------------------------------------------------
  // Room selection
  // ---------------------------------------------------------------------------

  void _onRoomChanged(String? roomId) {
    if (roomId == _selectedRoomId) return;
    setState(() => _selectedRoomId = roomId);
    final controller = context.read<StatsController>();
    if (roomId != null) {
      controller.loadDashboard(roomId);
    } else {
      controller.clearDashboard();
    }
  }

  // ---------------------------------------------------------------------------
  // Config dialog
  // ---------------------------------------------------------------------------

  Future<void> _showConfigDialog(StatWidgetType widgetType) async {
    final equipments = _equipmentsForRoom(_selectedRoomId);

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
          // TODO(l10n)
          content: const Text('No compatible device for this widget type'),
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
    String chartType = 'line';

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
      extra:
          widgetType == StatWidgetType.chart ? {'chartType': chartType} : null,
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
    required String chartType,
    required StatWidgetType widgetType,
    required void Function(Equipment eq, List<MetricType> metrics)
        onEquipmentChanged,
    required ValueChanged<MetricType> onMetricChanged,
    required ValueChanged<TimeRange> onRangeChanged,
    required ValueChanged<String> onChartTypeChanged,
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
                final eq = equipments.firstWhere((e) => e.id == id);
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
              avatar: Icon(m.icon,
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
            children: ['line', 'bar', 'pie'].map((ct) {
              final selected = ct == chartType;
              return ChoiceChip(
                label: Text(ct[0].toUpperCase() + ct.substring(1),
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
    final l10n = context.l10n;
    final roomsInGroup = _roomsForGroup(_selectedGroupId);

    return Column(
      children: [
        // -- Room chips (filtered by the active group from the header) --
        if (roomsInGroup.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: _buildRoomSelector(roomsInGroup),
          ),

        // -- Dashboard content --
        Expanded(
          child: controller.isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.success))
              : controller.widgets.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      AppColors.stroke.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.bar_chart_rounded,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.statsNoWidgets,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.statsEmptyHint,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildGroupedWidgetList(controller),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Selectors
  // ---------------------------------------------------------------------------

  Widget _buildRoomSelector(List<Room> rooms) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rooms.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final room = rooms[index];
          final selected = room.id == _selectedRoomId;

          return ChoiceChip(
            label: Text(
              room.name,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppColors.bg : AppColors.textSecondary,
              ),
            ),
            selected: selected,
            selectedColor: AppColors.success,
            backgroundColor: AppColors.bg,
            side: BorderSide(
              color: selected
                  ? AppColors.success
                  : AppColors.stroke.withValues(alpha: 0.3),
            ),
            onSelected: (_) => _onRoomChanged(room.id),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
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
        final equipment = _equipmentById(deviceId);
        final deviceName = equipment?.name ?? deviceId;
        // TODO(l10n)
        final deviceTypeLabel = equipment != null
            ? _equipmentTypeLabel(equipment.type)
            : '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _DeviceGroupCard(
            deviceName: deviceName,
            deviceTypeLabel: deviceTypeLabel,
            widgetCount: configs.length,
            initiallyExpanded: false,
            children: configs.map((config) {
              final series = controller.seriesFor(config);
              return _WidgetEntry(
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
  // TODO(l10n)
  String _equipmentTypeLabel(EquipmentType type) {
    switch (type) {
      case EquipmentType.shellyPlusPlugS:
        return 'Smart Plug';
      case EquipmentType.shellyPlugS:
        return 'Smart Plug';
      case EquipmentType.other:
        return 'Device';
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
    final equipments = _equipmentsForRoom(_selectedRoomId);
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
    String chartType = (config.extra?['chartType'] as String?) ?? 'line';

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
      extra:
          config.type == StatWidgetType.chart ? {'chartType': chartType} : null,
    );

    await context.read<StatsController>().updateWidget(updated);
  }
}

// =============================================================================
// Private widgets
// =============================================================================

/// Collapsible card that groups all stat widgets belonging to one device.
class _DeviceGroupCard extends StatelessWidget {
  final String deviceName;
  final String deviceTypeLabel;
  final int widgetCount;
  final bool initiallyExpanded;
  final List<Widget> children;

  const _DeviceGroupCard({
    required this.deviceName,
    required this.deviceTypeLabel,
    required this.widgetCount,
    required this.initiallyExpanded,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Theme(
        // Remove the default divider line from ExpansionTile.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          collapsedBackgroundColor: AppColors.surface,
          backgroundColor: AppColors.surface,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textSecondary,
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (deviceTypeLabel.isNotEmpty)
                      Text(
                        // TODO(l10n)
                        '$deviceTypeLabel · $widgetCount widget${widgetCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Interleave dividers between widget entries.
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  color: AppColors.stroke.withValues(alpha: 0.25),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// A single widget entry inside a device group card, with edit/delete buttons.
class _WidgetEntry extends StatelessWidget {
  final StatWidgetConfig config;
  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WidgetEntry({
    required this.config,
    required this.child,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action row: edit / delete (top-right)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 28,
                width: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.textSecondary),
                  onPressed: onEdit,
                ),
              ),
              SizedBox(
                height: 28,
                width: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  icon:
                      const Icon(Icons.delete_outline, color: AppColors.danger),
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
          // Renderer
          child,
        ],
      ),
    );
  }
}
