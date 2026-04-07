import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// Top bar on the WLED detail page showing the current color swatch, hex value,
/// on/off status, and a power toggle button.
class WledPowerBar extends StatelessWidget {
  final bool isOn;
  final Color color;
  final VoidCallback onToggle;

  const WledPowerBar({
    super.key,
    required this.isOn,
    required this.color,
    required this.onToggle,
  });

  String _hexString(Color c) {
    final r = (c.r * 255).round().clamp(0, 255);
    final g = (c.g * 255).round().clamp(0, 255);
    final b = (c.b * 255).round().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hex = _hexString(color);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          // Color swatch — tap to copy hex
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: hex));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$hex copied'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Hex label + on/off status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hex,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOn ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isOn ? AppColors.success : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Power toggle
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isOn
                    ? AppColors.success.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOn ? AppColors.success : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.power_settings_new_rounded,
                color: isOn ? AppColors.success : AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
