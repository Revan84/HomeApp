import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';
import 'card_shared.dart';

class TvCard extends StatelessWidget {
  const TvCard({
    super.key,
    required this.tv,
    required this.onTap,
    this.onHome,
    this.onVolumeDown,
    this.onVolumeUp,
    this.updatedLabel = '',
    this.isOn = true,
  });

  final dynamic tv; // TvDevice
  final VoidCallback onTap;
  final VoidCallback? onHome;
  final VoidCallback? onVolumeDown;
  final VoidCallback? onVolumeUp;
  final String updatedLabel;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    final source = (tv.source as String?) ?? '';

    return CardShell(
      onTap: onTap,
      accentColor: AppColors.tvAccent,
      online: isOn,
      content: Row(
        children: [
          // ── left content ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(
                  icon: Icons.cast_connected_rounded,
                  name: tv.name as String,
                ),
                AppSpacing.gapMd,
                const MetaLabel('Source'),
                AppSpacing.gapXxs,
                Text(
                  source.isNotEmpty ? source : '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'ShareTech',
                    color: AppColors.tvAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSizes.display,
                  ),
                ),
                AppSpacing.gapMd,
                Builder(
                  builder: (ctx) {
                    final accent = DeviceAccentScope.of(ctx);
                    return GestureDetector(
                      onTap: onHome,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: AppRadius.smBR,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.45),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: AppFontSizes.heading,
                              color: accent,
                            ),
                            AppSpacing.gapHXs,
                            Text(
                              'Home',
                              style: TextStyle(
                                fontFamily: 'ShareTech',
                                color: accent,
                                fontSize: AppFontSizes.heading,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          AppSpacing.gapHSm,

          // ── right: volume control ──
          VolumeControl(onVolumeUp: onVolumeUp, onVolumeDown: onVolumeDown),
        ],
      ),
      footer: CardFooter(
        updatedLabel: updatedLabel,
        isOn: isOn,
        toggling: false,
        canToggle: true,
        onToggle: null,
      ),
    );
  }
}

// ============================================================
// VOLUME CONTROL  (vertical pill: vol+ / vol-)
// ============================================================

class VolumeControl extends StatelessWidget {
  const VolumeControl({super.key, this.onVolumeUp, this.onVolumeDown});
  final VoidCallback? onVolumeUp;
  final VoidCallback? onVolumeDown;

  @override
  Widget build(BuildContext context) {
    final accent = DeviceAccentScope.of(context);
    return Container(
      width: 42,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: AppRadius.lgBR,
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xsBR,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onVolumeUp,
              child: SizedBox(
                height: 40,
                child: Center(
                  child: Icon(
                    Icons.volume_up_rounded,
                    size: AppFontSizes.heading,
                    color: accent,
                  ),
                ),
              ),
            ),
            Container(height: 0.5, color: accent.withValues(alpha: 0.3)),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onVolumeDown,
              child: SizedBox(
                height: 40,
                child: Center(
                  child: Icon(
                    Icons.volume_down_rounded,
                    size: AppFontSizes.heading,
                    color: accent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
