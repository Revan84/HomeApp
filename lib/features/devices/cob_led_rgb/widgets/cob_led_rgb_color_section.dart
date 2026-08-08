import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../shared/widgets/detail_section_card.dart';
import '../domain/rgb_color.dart';
import 'cob_led_rgb_color_wheel.dart';

/// Section card: hex label → editable hex box → colour square, full-width
/// colour wheel, and luminosity slider — all in one container.
class CobLedRgbColorSection extends StatefulWidget {
  const CobLedRgbColorSection({
    super.key,
    required this.color,
    required this.rgbColor,
    required this.accentColor,
    required this.onColorChanged,
    required this.brightness,
    required this.onBrightnessChangeStart,
    required this.onBrightnessChanged,
    required this.onBrightnessChangeEnd,
  });

  final Color color;
  final RgbColor rgbColor;

  /// Device accent color — used for the luminosity slider track.
  final Color accentColor;

  final ValueChanged<Color> onColorChanged;

  /// Brightness in [0, 1].
  final double brightness;
  final VoidCallback onBrightnessChangeStart;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onBrightnessChangeEnd;

  @override
  State<CobLedRgbColorSection> createState() => _CobLedRgbColorSectionState();
}

class _CobLedRgbColorSectionState extends State<CobLedRgbColorSection> {
  late final TextEditingController _hexCtrl;
  late final FocusNode _hexFocus;
  bool _hexEditing = false;

  @override
  void initState() {
    super.initState();
    _hexCtrl = TextEditingController(text: widget.rgbColor.hex);
    _hexFocus = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CobLedRgbColorSection old) {
    super.didUpdateWidget(old);
    if (!_hexEditing && widget.rgbColor != old.rgbColor) {
      _hexCtrl.text = widget.rgbColor.hex;
    }
  }

  @override
  void dispose() {
    _hexFocus
      ..removeListener(_onFocusChange)
      ..dispose();
    _hexCtrl.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_hexFocus.hasFocus) {
      setState(() => _hexEditing = true);
    } else {
      setState(() => _hexEditing = false);
      _applyHex(_hexCtrl.text);
    }
  }

  void _applyHex(String value) {
    final hex = value.trim().replaceAll('#', '');
    if (hex.length == 6) {
      try {
        final rgb = int.parse(hex, radix: 16);
        final r = (rgb >> 16) & 0xFF;
        final g = (rgb >> 8) & 0xFF;
        final b = rgb & 0xFF;
        widget.onColorChanged(Color.fromARGB(255, r, g, b));
        return;
      } catch (_) {}
    }
    _hexCtrl.text = widget.rgbColor.hex;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final accent = widget.accentColor;

    return DetailSectionCard(
      title: context.l10n.cobLedRgbSectionColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: label | hex box | colour square ───────────────────────
          Row(
            children: [
              Text(
                '${context.l10n.cobLedHexCodeLabel} :',
                style: const TextStyle(
                  fontSize: AppFontSizes.body,
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.gapHSm,
              // Fixed-width hex input box
              SizedBox(
                width: 96,
                child: TextField(
                  controller: _hexCtrl,
                  focusNode: _hexFocus,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSizes.body,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mdBR,
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.mdBR,
                      borderSide: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.mdBR,
                      borderSide: BorderSide(color: color, width: 1.5),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (v) {
                    _hexFocus.unfocus();
                    _applyHex(v);
                  },
                ),
              ),
              AppSpacing.gapHSm,
              // Colour square preview
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppRadius.smBR,
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.gapX2l,

          // ── Full-width colour wheel ─────────────────────────────────────
          LayoutBuilder(
            builder: (_, constraints) {
              final size = math.min(constraints.maxWidth, 280.0);
              return Center(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: CobLedRgbColorWheel(
                    color: color,
                    onColorChanged: widget.onColorChanged,
                  ),
                ),
              );
            },
          ),

          AppSpacing.gapX2l,

          // ── Luminosity ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.cobLedSectionLuminosity,
                style: const TextStyle(
                  fontSize: AppFontSizes.body,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(widget.brightness * 100).round()} %',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSizes.body,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapXs,
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined,
                  size: 16, color: AppColors.textSecondary),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: accent,
                    inactiveTrackColor:
                        AppColors.border.withValues(alpha: 0.35),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                      elevation: 4,
                    ),
                    overlayColor: accent.withValues(alpha: 0.12),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 18),
                  ),
                  child: Slider(
                    value: widget.brightness,
                    onChangeStart: (_) => widget.onBrightnessChangeStart(),
                    onChanged: widget.onBrightnessChanged,
                    onChangeEnd: widget.onBrightnessChangeEnd,
                  ),
                ),
              ),
              const Icon(Icons.wb_sunny_rounded,
                  size: 22, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
