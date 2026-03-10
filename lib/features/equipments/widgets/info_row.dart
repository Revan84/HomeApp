import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A single info row like:
/// "IP locale : 192.168.1.10  [edit]"
///
/// Requirements:
/// - Label is grey
/// - Value is white (primary)
/// - Trailing icon is aligned right after the value (not at far right of screen)
/// - Whole row tappable
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget trailing;
  final VoidCallback onTap;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium;

    final labelStyle = base?.copyWith(color: AppColors.textSecondary, fontSize: 13);
    final valueStyle = base?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 13
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(text: label, style: labelStyle),
                    TextSpan(text: value, style: valueStyle),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

/// A consistent trailing icon for InfoRow.
/// Keeps a proper tap target and consistent sizing.
class InfoRowIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const InfoRowIcon({
    super.key,
    required this.icon,
    this.size = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Icon(
        icon,
        size: size,
        color: color ?? AppColors.textSecondary,
      ),
    );
  }
}