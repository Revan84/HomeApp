import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_font_sizes.dart';

/// Section title row with optional chevron and tap handler.
///
/// The chevron is shown by default when [onTap] is provided.
/// Pass [showChevron: false] to suppress it (e.g. non-navigable headers).
///
/// ```dart
/// SectionHeader(title: l10n.favoritesTitle)
/// SectionHeader(title: l10n.roomsTitle, onTap: () => _openRooms(context))
/// SectionHeader(title: 'Devices', showChevron: false)
/// ```
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onTap,
    this.showChevron,
  });

  final String title;
  final VoidCallback? onTap;

  /// Whether to show the right chevron icon.
  /// Defaults to true when [onTap] is set, false otherwise.
  final bool? showChevron;

  @override
  Widget build(BuildContext context) {
    final displayChevron = showChevron ?? (onTap != null);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const Spacer(),
          if (displayChevron)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: AppFontSizes.display,
            ),
        ],
      ),
    );
  }
}
