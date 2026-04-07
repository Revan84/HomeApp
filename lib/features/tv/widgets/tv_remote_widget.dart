import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/tv_remote_command.dart';

/// TV remote control area matching the mockup layout:
/// - Left: D-pad (cross in a bordered box) with OK center button
/// - Center column: Back, Settings, Keyboard buttons
/// - Far right: vertical volume buttons (vol+, vol-, mute)
class TvRemoteWidget extends StatelessWidget {
  final void Function(TvRemoteCommand cmd) onCommand;
  final VoidCallback? onKeyboardTap;

  const TvRemoteWidget({
    super.key,
    required this.onCommand,
    this.onKeyboardTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // D-pad
        _buildDpad(context),
        const SizedBox(width: 14),

        // Side buttons: Back / Settings / Keyboard
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SideButton(
              icon: Icons.chevron_left_rounded,
              label: l.tvKeyBack,
              onTap: () => onCommand(TvRemoteCommand.back),
            ),
            const SizedBox(height: 10),
            _SideButton(
              icon: Icons.menu_rounded,
              label: l.tvKeySettings,
              onTap: () => onCommand(TvRemoteCommand.menu),
            ),
            const SizedBox(height: 10),
            _SideButton(
              icon: Icons.keyboard_rounded,
              label: l.tvKeyKeyboard,
              onTap: onKeyboardTap ?? () {},
            ),
          ],
        ),

        const Spacer(),

        // Volume buttons (vertical)
        _VolumeButtons(
          onVolUp: () => onCommand(TvRemoteCommand.volumeUp),
          onVolDown: () => onCommand(TvRemoteCommand.volumeDown),
          onMute: () => onCommand(TvRemoteCommand.mute),
        ),
      ],
    );
  }

  Widget _buildDpad(BuildContext context) {
    const boxSize = 160.0;
    const okSize = 52.0;

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Diagonal lines from corners toward center
          CustomPaint(
            size: const Size(boxSize, boxSize),
            painter: _DpadDiagonalPainter(),
          ),

          // Up arrow
          Positioned(
            top: 8,
            child: _DpadArrowButton(
              icon: Icons.keyboard_arrow_up_rounded,
              onTap: () => onCommand(TvRemoteCommand.up),
            ),
          ),

          // Down arrow
          Positioned(
            bottom: 8,
            child: _DpadArrowButton(
              icon: Icons.keyboard_arrow_down_rounded,
              onTap: () => onCommand(TvRemoteCommand.down),
            ),
          ),

          // Left arrow
          Positioned(
            left: 8,
            child: _DpadArrowButton(
              icon: Icons.keyboard_arrow_left_rounded,
              onTap: () => onCommand(TvRemoteCommand.left),
            ),
          ),

          // Right arrow
          Positioned(
            right: 8,
            child: _DpadArrowButton(
              icon: Icons.keyboard_arrow_right_rounded,
              onTap: () => onCommand(TvRemoteCommand.right),
            ),
          ),

          // OK center button
          SizedBox(
            width: okSize,
            height: okSize,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bg,
                foregroundColor: AppColors.textPrimary,
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.stroke, width: 1.5),
                ),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              onPressed: () => onCommand(TvRemoteCommand.enter),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints diagonal lines from the four corners toward the center.
class _DpadDiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.stroke.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const margin = 12.0;
    const gap = 32.0; // distance from center to stop the line

    // Top-left to center
    canvas.drawLine(
      Offset(margin, margin),
      Offset(cx - gap, cy - gap),
      paint,
    );
    // Top-right to center
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(cx + gap, cy - gap),
      paint,
    );
    // Bottom-left to center
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(cx - gap, cy + gap),
      paint,
    );
    // Bottom-right to center
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(cx + gap, cy + gap),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Transparent arrow button for the D-pad.
class _DpadArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DpadArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: AppColors.textPrimary, size: 28),
      ),
    );
  }
}

/// Side button with icon + label (e.g. "< Back").
class _SideButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SideButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.stroke, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three vertical volume buttons: vol+, vol-, mute.
class _VolumeButtons extends StatelessWidget {
  final VoidCallback onVolUp;
  final VoidCallback onVolDown;
  final VoidCallback onMute;

  const _VolumeButtons({
    required this.onVolUp,
    required this.onVolDown,
    required this.onMute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _VolBtn(icon: Icons.volume_up_rounded, onTap: onVolUp),
        const SizedBox(height: 8),
        _VolBtn(icon: Icons.volume_down_rounded, onTap: onVolDown),
        const SizedBox(height: 8),
        _VolBtn(icon: Icons.volume_off_rounded, onTap: onMute),
      ],
    );
  }
}

class _VolBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _VolBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.stroke, width: 1),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
