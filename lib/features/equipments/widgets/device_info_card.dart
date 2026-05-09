import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../integrations/shelly/data/dto/shelly_device_info_dto.dart';

/// Card showing discovered device info after a successful connection test.
class DeviceInfoCard extends StatelessWidget {
  final ShellyDeviceInfoDto data;
  const DeviceInfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.x2l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBR,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.name.isNotEmpty) _InfoLine('Name', data.name),
          if (data.model.isNotEmpty) _InfoLine('Model', data.model),
          if (data.mac.isNotEmpty) _InfoLine('MAC', data.mac),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  const _InfoLine(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: AppFontSizes.xs,
            color: AppColors.textSecondary,
          ),
        ),
      );
}
