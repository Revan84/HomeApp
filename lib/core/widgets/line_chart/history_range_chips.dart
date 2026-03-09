import 'package:flutter/material.dart';

import '../../i18n/loc.dart';
import '../../theme/app_colors.dart';
import '../../../domain/models/history_window.dart';

/// Compact range chips used above the history chart.
///
/// Labels are localized through l10n.
class HistoryRangeChips extends StatelessWidget {
  final HistoryWindow value;
  final ValueChanged<HistoryWindow> onChanged;

  const HistoryRangeChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String _label(BuildContext context, HistoryWindow window) {
    switch (window) {
      case HistoryWindow.d1:
        return context.l10n.historyRange1d;
      case HistoryWindow.w1:
        return context.l10n.historyRange1w;
      case HistoryWindow.m1:
        return context.l10n.historyRange1m;
      case HistoryWindow.y1:
        return context.l10n.historyRange1y;
      case HistoryWindow.max:
        return context.l10n.historyRangeMax;
    }
  }

  @override
  Widget build(BuildContext context) {
    const windows = <HistoryWindow>[
      HistoryWindow.d1,
      HistoryWindow.w1,
      HistoryWindow.m1,
      HistoryWindow.y1,
      HistoryWindow.max,
    ];

    return Row(
      children: [
        for (int index = 0; index < windows.length; index++) ...[
          _HistoryRangeChip(
            label: _label(context, windows[index]),
            selected: value == windows[index],
            onTap: () => onChanged(windows[index]),
          ),
          if (index < windows.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _HistoryRangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HistoryRangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        selected ? AppColors.success : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
        ),
      ),
    );
  }
}