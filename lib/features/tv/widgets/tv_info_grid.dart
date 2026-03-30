import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../equipments/widgets/info_row.dart';

/// Info grid for TV details: IP, Type, Favorite, Model, Connection.
/// Reuses [InfoRow] from the equipment feature for consistency.
class TvInfoGrid extends StatelessWidget {
  final String ipLabel;
  final String ip;
  final VoidCallback onEditIp;

  final String typeLabel;
  final String typeValue;

  final String favoriteLabel;
  final String favoriteValue;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  final String modelLabel;
  final String modelValue;

  final bool online;
  final String connectionLabel;

  const TvInfoGrid({
    super.key,
    required this.ipLabel,
    required this.ip,
    required this.onEditIp,
    required this.typeLabel,
    required this.typeValue,
    required this.favoriteLabel,
    required this.favoriteValue,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.modelLabel,
    required this.modelValue,
    required this.online,
    required this.connectionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRow(
                label: '$ipLabel : ',
                value: ip,
                onTap: onEditIp,
                trailing:
                    const InfoRowIcon(icon: Icons.edit_rounded, size: 18),
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: '$typeLabel : ',
                value: typeValue,
                onTap: () {},
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
        // Right column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InfoRow(
                label: modelValue,
                value: '',
                onTap: () {},
                trailing: const InfoRowIcon(
                  icon: Icons.content_copy_rounded,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              InfoRow(
                label: connectionLabel,
                value: '',
                onTap: () {},
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
