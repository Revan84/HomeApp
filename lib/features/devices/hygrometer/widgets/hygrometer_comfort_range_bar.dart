import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

// ── Comfort helpers (used by bar and by HygrometerLiveSection) ────────────────

String comfortLabel(double humidity) {
  if (humidity < 30) return 'Dry';
  if (humidity <= 60) return 'Good';
  return 'Humid';
}

Color comfortColor(double humidity) {
  if (humidity < 30) return Colors.orange;
  if (humidity <= 60) return AppColors.success;
  return AppColors.hygrometerAccent;
}

// ── Widget ────────────────────────────────────────────────────────────────────

/// Visual 0%→100% scale with the comfort zone (40–60%) highlighted and a
/// coloured dot showing the current humidity position.
class HygrometerComfortRangeBar extends StatelessWidget {
  const HygrometerComfortRangeBar({super.key, required this.humidity});

  final double humidity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        const comfortStart = 0.40;
        const comfortEnd = 0.60;
        final indicator = (humidity / 100.0).clamp(0.0, 1.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
              child: Stack(
                children: [
                  // Background track
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  // Comfort zone overlay (40–60%)
                  Positioned(
                    left: w * comfortStart,
                    width: w * (comfortEnd - comfortStart),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Current value indicator dot
                  Positioned(
                    left: (w * indicator - 5).clamp(0.0, w - 10),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      decoration: BoxDecoration(
                        color: comfortColor(humidity),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.card, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapXxs,
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Label('0%'),
                _Label('40%'),
                _Label('60%'),
                _Label('100%'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: AppColors.textSecondary,
        ),
      );
}
