import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../domain/tv_app.dart';

/// Grid of TV application shortcut buttons styled like brand logos (B&W).
class TvAppsGrid extends StatelessWidget {
  final List<TvApp> apps;
  final ValueChanged<TvApp> onAppTap;

  const TvAppsGrid({
    super.key,
    required this.apps,
    required this.onAppTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: apps.length,
      itemBuilder: (_, i) => _AppButton(
        appId: apps[i].id,
        label: apps[i].label,
        onTap: () => onAppTap(apps[i]),
      ),
    );
  }
}

/// Renders an app button with logo-like text styling on a dark background.
class _AppButton extends StatelessWidget {
  final String appId;
  final String label;
  final VoidCallback onTap;

  const _AppButton({
    required this.appId,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasBorderAccent = appId == 'primevideo';

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBR,
        side: BorderSide(
          color: hasBorderAccent ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.lgBR,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 105, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          alignment: Alignment.center,
          child: _buildLogo(),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    switch (appId) {
      case 'netflix':
        return const Text(
          'NETFLIX',
          style: TextStyle(
            fontFamily: 'ShareTech',
            color: Colors.white,
            fontSize: AppFontSizes.sectionTitle,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
          ),
        );

      case 'canalplus':
        return Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'CANAL',
                style: TextStyle(
                  fontFamily: 'ShareTech',
                  color: Colors.white,
                  fontSize: AppFontSizes.sectionTitle,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  margin: const EdgeInsets.only(left: 2),
                  child: const Text(
                    '+',
                    style: TextStyle(
                      fontFamily: 'ShareTech',
                      color: Colors.white,
                      fontSize: AppFontSizes.display,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'disneyplus':
        // Disney+ logo has a distinctive italic script feel
        return const Text(
          'Disney+',
          style: TextStyle(
            fontFamily: 'ShareTech',
            color: Colors.white,
            fontSize: AppFontSizes.sectionTitle,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ),
        );

      case 'youtube':
        return const Text(
          'YouTube',
          style: TextStyle(
            fontFamily: 'ShareTech',
            color: Colors.white,
            fontSize: AppFontSizes.lg,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        );

      case 'twitch':
        return const Text(
          'twitch',
          style: TextStyle(
            fontFamily: 'ShareTech',
            color: Colors.white,
            fontSize: AppFontSizes.sectionTitle,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.3,
          ),
        );

      case 'primevideo':
        return const Text(
          'prime video',
          style: TextStyle(
            fontFamily: 'ShareTech',
            color: Colors.white,
            fontSize: AppFontSizes.md,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        );

      default:
        return Text(
          label,
          style: const TextStyle(
            fontFamily: 'ShareTech',
            color: AppColors.textPrimary,
            fontSize: AppFontSizes.md,
            fontWeight: FontWeight.w700,
          ),
        );
    }
  }
}
