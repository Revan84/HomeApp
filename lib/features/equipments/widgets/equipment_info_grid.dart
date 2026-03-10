import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'info_row.dart';

/// Grid like the Figma prototype:
/// - Left column: IP / Type / Favorite with trailing icons aligned to the value.
/// - Right column: Energy (value + icon), Model (text + icon), Connection (text + icon).
class EquipmentInfoGrid extends StatelessWidget {
  // Left column (translated labels)
  final String ipLabel;
  final String ip;
  final VoidCallback onEditIp;

  final String typeLabelText;
  final String typeValue;
  final VoidCallback onSelectType;

  final String favoriteLabel;
  final String favoriteValue;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  // Right column
  final String energyLabel;
  final String modelLabel;

  final bool online;
  final String connectionLabel;

  const EquipmentInfoGrid({
    super.key,
    required this.ipLabel,
    required this.ip,
    required this.onEditIp,
    required this.typeLabelText,
    required this.typeValue,
    required this.onSelectType,
    required this.favoriteLabel,
    required this.favoriteValue,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.energyLabel,
    required this.modelLabel,
    required this.online,
    required this.connectionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRow(
                label: '$ipLabel : ',
                value: ip,
                onTap: onEditIp,
                trailing: const InfoRowIcon(icon: Icons.edit_rounded, size: 18),
              ),
              const SizedBox(height: 12),

              InfoRow(
                label: '$typeLabelText : ',
                value: typeValue,
                onTap: onSelectType,
                trailing: const InfoRowIcon(
                  icon: Icons.keyboard_arrow_down_rounded,
                  size: 18,
                ),
              ),
              const SizedBox(height: 12),

              InfoRow(
                label: '$favoriteLabel : ',
                value: favoriteValue,
                onTap: onToggleFavorite,
                trailing: InfoRowIcon(
                  icon: isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: isFavorite
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // RIGHT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Energy value + icon aligned with the value (same baseline feel)
              InfoRow(
                label: energyLabel,
                value: '',
                onTap: () => (),
                trailing: const InfoRowIcon(
                  icon: Icons.bolt_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              InfoRow(
                label: modelLabel,
                value: '',
                onTap: () => (),
                trailing: const InfoRowIcon(
                  icon: Icons.device_hub_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              InfoRow(
                label: connectionLabel,
                value: '',
                onTap: () => (),
                trailing: InfoRowIcon(
                  icon: online ? Icons.wifi : Icons.wifi_off,
                  size: 18,
                  color: online
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
