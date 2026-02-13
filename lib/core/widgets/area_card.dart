import 'package:flutter/material.dart';
import 'package:front_end/core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/secondary_text.dart';

class AreaCard extends StatelessWidget {
  const AreaCard({
    super.key,
    required this.title,
    required this.devices,
    this.onSettings,
    this.onDeviceTap,
  });

  final String title;
  final List<AreaDeviceItem> devices;
  final VoidCallback? onSettings;
  final void Function(String deviceId)? onDeviceTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke.withValues(alpha: 0.35)),
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
              if (onSettings != null)
                IconButton(
                  onPressed: onSettings,
                  icon: Icon(
                    Icons.more_horiz,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (devices.isEmpty)
            SecondaryText(context.l10n.noEquipments)
          else
            SizedBox(
              height: 95, // hauteur fixe pour mini cards
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: devices.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final d = devices[i];

                  return _MiniDeviceCard(
                    item: d,
                    onTap: onDeviceTap == null
                        ? null
                        : () => onDeviceTap!(d.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class AreaDeviceItem {
  final String id;
  final String value;
  final String label;
  final bool? isOn;
  final int trend;
  final String updatedLabel;

  AreaDeviceItem({
    required this.id,
    required this.value,
    required this.label,
    required this.isOn,
    this.trend = 0,
    this.updatedLabel = '',
  });
}

class _MiniDeviceCard extends StatelessWidget {
  const _MiniDeviceCard({required this.item, this.onTap});

  final AreaDeviceItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 110, // largeur fixe comme favoris
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stroke.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // pastille ON/OFF
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isOn == null
                        ? Colors.grey
                        : (item.isOn == true ? Colors.green : Colors.red),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            SecondaryText(item.label),
            if (item.updatedLabel.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                item.updatedLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
