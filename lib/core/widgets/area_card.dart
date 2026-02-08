import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/secondary_text.dart';

class AreaCard extends StatelessWidget {
  const AreaCard({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Icon(Icons.settings, color: AppColors.textSecondary, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              _MiniDeviceCard(),
              SizedBox(width: 10),
              _MiniDeviceCard(),
              SizedBox(width: 10),
              _MiniDeviceCard(),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniDeviceCard extends StatelessWidget {
  const _MiniDeviceCard();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.stroke.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '21 °C',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
            SecondaryText('Thermomètre'),
          ],
        ),
      ),
    );
  }
}
