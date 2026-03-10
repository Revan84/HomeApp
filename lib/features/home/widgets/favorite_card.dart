import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/secondary_text.dart';

class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.value,
    required this.label,
    required this.room,
    required this.icon,
    required this.isOn,
    this.showPowerButton = false,
    this.powerEnabled = true,
    this.powerLoading = false,
    this.onPowerPressed,
    this.onOpenDetails,
    this.onToggleFavorite,
    this.onEdit,
    this.trend = 0,
    this.updatedLabel = '',
  });

  final String value;
  final String label;
  final String room;
  final IconData icon;
  final bool isOn;

  final VoidCallback? onOpenDetails;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onEdit;
  final int trend;
  final String updatedLabel;

  final bool showPowerButton;
  final bool powerEnabled;
  final bool powerLoading;
  final VoidCallback? onPowerPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onOpenDetails,
        child: Container(
          width: 170,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: radius,
            border: Border.all(color: AppColors.stroke.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    trend > 0
                        ? Icons.arrow_upward_rounded
                        : trend < 0
                        ? Icons.arrow_downward_rounded
                        : Icons.remove_rounded,
                    size: 14,
                    color: trend > 0
                        ? AppColors.success
                        : trend < 0
                        ? Colors.orange
                        : AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  if (updatedLabel.isNotEmpty) ...[
                    const SizedBox(width: 2),
                    Text(
                      updatedLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color.fromARGB(255, 175, 171, 171),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              SecondaryText(label),

              const SizedBox(height: 10),
              SizedBox(
                width: 34,
                height: 34,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Transform.translate(
                    offset: const Offset(-5, 0),
                    child: Icon(icon, color: AppColors.textPrimary),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    room,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    powerEnabled ? Icons.wifi : Icons.wifi_off,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  _MiniSwitchButton(
                    isOn: isOn,
                    enabled: showPowerButton && powerEnabled && !powerLoading,
                    loading: powerLoading,
                    onPressed: onPowerPressed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniSwitchButton extends StatelessWidget {
  const _MiniSwitchButton({
    required this.isOn,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool isOn;
  final bool enabled;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bg = isOn ? AppColors.success : AppColors.bg;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: enabled ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: enabled ? 1 : 0.55,
        child: Container(
          width: 44,
          height: 24,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: bg,
            border: Border.all(color: AppColors.stroke.withValues(alpha: 0.35)),
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Align(
                  alignment: isOn
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
