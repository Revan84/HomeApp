import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/history_window.dart';
import '../../../live/controllers/live_polling_controller.dart';
import '../../../live/widgets/charts/line_chart/history_range_chips.dart';
import '../../shared/widgets/detail_section_card.dart';
import 'smart_plug_timeline_bar_chart.dart';

/// Self-contained timeline bar chart section with its own window state.
class SmartPlugTimelineSection extends StatefulWidget {
  const SmartPlugTimelineSection({
    super.key,
    required this.equipmentId,
    required this.unitLabel,
  });

  final String equipmentId;
  final String unitLabel;

  @override
  State<SmartPlugTimelineSection> createState() =>
      _SmartPlugTimelineSectionState();
}

class _SmartPlugTimelineSectionState extends State<SmartPlugTimelineSection> {
  HistoryWindow _window = HistoryWindow.d1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final liveCtl = context.watch<LivePollingController>();
    final history = liveCtl.historyFor(widget.equipmentId, _window);

    return DetailSectionCard(
      title: l10n.smartPlugSectionTimeline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HistoryRangeChips(
            value: _window,
            onChanged: (w) => setState(() => _window = w),
          ),
          AppSpacing.gapLg,
          SmartPlugTimelineBarChart(
            points: history,
            window: _window,
            height: 140,
            unitLabel: widget.unitLabel,
          ),
        ],
      ),
    );
  }
}
