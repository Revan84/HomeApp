import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/history_window.dart';
import '../../../live/controllers/live_polling_controller.dart';
import '../../../live/widgets/charts/line_chart/history_range_chips.dart';
import '../../../live/widgets/charts/line_chart/interactive_line_chart.dart';
import '../../shared/widgets/detail_section_card.dart';

/// Self-contained consumption line chart section with its own window state.
class SmartPlugConsumptionSection extends StatefulWidget {
  const SmartPlugConsumptionSection({
    super.key,
    required this.equipmentId,
    required this.unitLabel,
  });

  final String equipmentId;
  final String unitLabel;

  @override
  State<SmartPlugConsumptionSection> createState() =>
      _SmartPlugConsumptionSectionState();
}

class _SmartPlugConsumptionSectionState
    extends State<SmartPlugConsumptionSection> {
  HistoryWindow _window = HistoryWindow.d1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final liveCtl = context.watch<LivePollingController>();
    final history = liveCtl.historyFor(widget.equipmentId, _window);

    final double maxY = history.isEmpty
        ? 100
        : history.map((p) => p.powerW).reduce(max) * 1.2;

    return DetailSectionCard(
      title: l10n.smartPlugSectionConsumption,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HistoryRangeChips(
            value: _window,
            onChanged: (w) => setState(() => _window = w),
          ),
          AppSpacing.gapLg,
          InteractiveLineChart(
            points: history,
            window: _window,
            minY: 0,
            maxY: maxY,
            height: 160,
            powerUnitLabel: widget.unitLabel,
          ),
        ],
      ),
    );
  }
}
