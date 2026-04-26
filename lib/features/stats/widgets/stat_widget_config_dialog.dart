import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/equipment.dart';
import '../domain/chart_type.dart';
import '../domain/metric_type.dart';
import '../domain/stat_widget.dart';
import '../domain/time_range.dart';
import '../utils/allowed_widgets.dart';

/// Result returned when the user confirms the config dialog.
class StatWidgetConfigResult {
  final Equipment equipment;
  final MetricType metric;
  final TimeRange range;
  final ChartType chartType;

  const StatWidgetConfigResult({
    required this.equipment,
    required this.metric,
    required this.range,
    required this.chartType,
  });
}

/// Dialog for configuring (add or edit) a stat widget.
///
/// Use [StatWidgetConfigDialog.show] to open it and await the result:
/// ```dart
/// final result = await StatWidgetConfigDialog.show(
///   context,
///   widgetType: StatWidgetType.chart,
///   equipments: compatibleEquipments,
/// );
/// if (result != null) { ... }
/// ```
class StatWidgetConfigDialog extends StatefulWidget {
  final StatWidgetType widgetType;
  final List<Equipment> equipments;
  final Equipment? initialEquipment;
  final MetricType? initialMetric;
  final TimeRange? initialRange;
  final ChartType? initialChartType;
  final bool isEdit;

  const StatWidgetConfigDialog({
    super.key,
    required this.widgetType,
    required this.equipments,
    this.initialEquipment,
    this.initialMetric,
    this.initialRange,
    this.initialChartType,
    this.isEdit = false,
  });

  /// Opens the config dialog and returns the result, or null if cancelled.
  static Future<StatWidgetConfigResult?> show(
    BuildContext context, {
    required StatWidgetType widgetType,
    required List<Equipment> equipments,
    Equipment? initialEquipment,
    MetricType? initialMetric,
    TimeRange? initialRange,
    ChartType? initialChartType,
    bool isEdit = false,
  }) {
    return showDialog<StatWidgetConfigResult>(
      context: context,
      builder: (_) => StatWidgetConfigDialog(
        widgetType: widgetType,
        equipments: equipments,
        initialEquipment: initialEquipment,
        initialMetric: initialMetric,
        initialRange: initialRange,
        initialChartType: initialChartType,
        isEdit: isEdit,
      ),
    );
  }

  @override
  State<StatWidgetConfigDialog> createState() => _StatWidgetConfigDialogState();
}

class _StatWidgetConfigDialogState extends State<StatWidgetConfigDialog> {
  late Equipment _selectedEquipment;
  late List<MetricType> _availableMetrics;
  late MetricType _selectedMetric;
  late TimeRange _selectedRange;
  late ChartType _chartType;

  @override
  void initState() {
    super.initState();
    _selectedEquipment =
        widget.initialEquipment ?? widget.equipments.first;
    _availableMetrics = metricsFor(_selectedEquipment);
    _selectedMetric = widget.initialMetric != null &&
            _availableMetrics.contains(widget.initialMetric)
        ? widget.initialMetric!
        : (_availableMetrics.isNotEmpty
            ? _availableMetrics.first
            : MetricType.power);
    _selectedRange = widget.initialRange ?? TimeRange.day1;
    _chartType = widget.initialChartType ?? ChartType.line;
  }

  void _onEquipmentChanged(String? id) {
    if (id == null) return;
    final eq = widget.equipments.where((e) => e.id == id).firstOrNull;
    if (eq == null) return;
    final newMetrics = metricsFor(eq);
    setState(() {
      _selectedEquipment = eq;
      _availableMetrics = newMetrics;
      if (!newMetrics.contains(_selectedMetric)) {
        _selectedMetric =
            newMetrics.isNotEmpty ? newMetrics.first : MetricType.power;
      }
    });
  }

  IconData _metricIcon(MetricType type) => switch (type) {
        MetricType.state => Icons.toggle_on,
        MetricType.temperature => Icons.thermostat,
        MetricType.humidity => Icons.water_drop,
        MetricType.power => Icons.bolt,
        MetricType.energy => Icons.electrical_services,
        MetricType.brightness => Icons.light_mode,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(widget.isEdit ? l10n.statsEditWidget : l10n.statsConfigTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Equipment dropdown ─────────────────────────────────────────
            Text(l10n.statsDeviceLabel,
                style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: 12.0,
                    color: AppColors.textSecondary)),
            AppSpacing.gapSm,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: AppRadius.xlBR,
                border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.4)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedEquipment.id,
                  isExpanded: true,
                  borderRadius: AppRadius.xlBR,
                  dropdownColor: AppColors.bg,
                  style: const TextStyle(
                      fontFamily: 'ShareTech',
                      color: AppColors.textPrimary,
                      fontSize: AppFontSizes.body),
                  items: widget.equipments.map((eq) {
                    return DropdownMenuItem(
                      value: eq.id,
                      child: Text(eq.name),
                    );
                  }).toList(),
                  onChanged: _onEquipmentChanged,
                ),
              ),
            ),

            AppSpacing.gapX3l,

            // ── Metric chips ───────────────────────────────────────────────
            Text(l10n.statsMetricLabel,
                style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: 12.0,
                    color: AppColors.textSecondary)),
            AppSpacing.gapSm,
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _availableMetrics.map((m) {
                final selected = m == _selectedMetric;
                return ChoiceChip(
                  avatar: Icon(_metricIcon(m),
                      size: 16,
                      color: selected
                          ? AppColors.bg
                          : AppColors.textSecondary),
                  label: Text(m.label,
                      style: TextStyle(
                          fontFamily: 'ShareTech',
                          fontSize: AppFontSizes.sm,
                          color: selected
                              ? AppColors.bg
                              : AppColors.textSecondary)),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.bg,
                  onSelected: (_) => setState(() => _selectedMetric = m),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),

            AppSpacing.gapX3l,

            // ── Time range chips ───────────────────────────────────────────
            Text(l10n.statsTimeRangeLabel,
                style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: 12.0,
                    color: AppColors.textSecondary)),
            AppSpacing.gapSm,
            Wrap(
              spacing: 6,
              children: TimeRange.values.map((r) {
                final selected = r == _selectedRange;
                return ChoiceChip(
                  label: Text(r.shortLabel,
                      style: TextStyle(
                          fontFamily: 'ShareTech',
                          fontSize: AppFontSizes.sm,
                          color: selected
                              ? AppColors.bg
                              : AppColors.textSecondary)),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.bg,
                  onSelected: (_) => setState(() => _selectedRange = r),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),

            // ── Chart type chips (only for chart widgets) ──────────────────
            if (widget.widgetType == StatWidgetType.chart) ...[
              AppSpacing.gapX3l,
              Text(l10n.statsChartTypeLabel,
                  style: const TextStyle(
                      fontFamily: 'ShareTech',
                      fontSize: 12.0,
                      color: AppColors.textSecondary)),
              AppSpacing.gapSm,
              Wrap(
                spacing: 6,
                children: ChartType.values.map((ct) {
                  final selected = ct == _chartType;
                  return ChoiceChip(
                    label: Text(
                        '${ct.name[0].toUpperCase()}${ct.name.substring(1)}',
                        style: TextStyle(
                            fontFamily: 'ShareTech',
                            fontSize: AppFontSizes.sm,
                            color: selected
                                ? AppColors.bg
                                : AppColors.textSecondary)),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.bg,
                    onSelected: (_) => setState(() => _chartType = ct),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(
            StatWidgetConfigResult(
              equipment: _selectedEquipment,
              metric: _selectedMetric,
              range: _selectedRange,
              chartType: _chartType,
            ),
          ),
          child: Text(widget.isEdit ? l10n.save : l10n.add),
        ),
      ],
    );
  }
}
