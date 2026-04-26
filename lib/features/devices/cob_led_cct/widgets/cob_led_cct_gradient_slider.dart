import 'package:flutter/material.dart';

/// A custom slider with a warm-to-cool gradient track for colour temperature.
class CobLedCctGradientSlider extends StatelessWidget {
  const CobLedCctGradientSlider({
    super.key,
    required this.value,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double value;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const trackH = 8.0;
        const thumbR = 11.0;

        return SizedBox(
          height: thumbR * 2 + 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: thumbR,
                right: thumbR,
                child: Container(
                  height: trackH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(trackH / 2),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF9F00),
                        Color(0xFFFFD080),
                        Color(0xFFFFFFE0),
                        Color(0xFFE8F4FF),
                      ],
                    ),
                  ),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: trackH,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withValues(alpha: 0.2),
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: thumbR),
                ),
                child: Slider(
                  value: value,
                  onChangeStart: onChangeStart,
                  onChanged: onChanged,
                  onChangeEnd: onChangeEnd,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
