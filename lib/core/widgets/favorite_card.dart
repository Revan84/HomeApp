import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/secondary_text.dart';

class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.value,
    required this.label,
    required this.room,
    required this.icon,
    required this.isOn,
  });

  final String value;   // "21 °C"
  final String label;   // "Thermomètre"
  final String room;    // "Salon"
  final IconData icon;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke.withOpacity(0.35)),
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
              const Spacer(),
              Icon(Icons.settings, color: AppColors.textSecondary, size: 18),
            ],
          ),
          const SizedBox(height: 2),
          SecondaryText(label),
          const SizedBox(height: 14),

          Icon(icon, color: AppColors.textPrimary, size: 28),

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
              Icon(Icons.wifi, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 10),
              _MiniSwitch(isOn: isOn),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch({required this.isOn});
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 24,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isOn ? AppColors.success : AppColors.bg,
        border: Border.all(color: AppColors.stroke.withOpacity(0.35)),
      ),
      child: Align(
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
