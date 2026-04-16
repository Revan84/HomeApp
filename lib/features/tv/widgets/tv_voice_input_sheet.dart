import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Bottom sheet that listens to the user's voice and returns the recognised
/// text. Mirrors the SmartThings voice-search UX.
///
/// Usage:
/// ```dart
/// final text = await TvVoiceInputSheet.show(context);
/// if (text != null && text.isNotEmpty) client.sendText(text);
/// ```
class TvVoiceInputSheet extends StatefulWidget {
  const TvVoiceInputSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const TvVoiceInputSheet(),
    );
  }

  @override
  State<TvVoiceInputSheet> createState() => _TvVoiceInputSheetState();
}

class _TvVoiceInputSheetState extends State<TvVoiceInputSheet>
    with SingleTickerProviderStateMixin {
  final SpeechToText _stt = SpeechToText();

  bool _listening = false;
  String _transcript = '';
  String _error = '';

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _init();
  }

  Future<void> _init() async {
    final available = await _stt.initialize(
      onError: (e) => setState(() {
        _error = e.errorMsg;
        _listening = false;
        _pulseCtrl.stop();
      }),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (!mounted) return;
          setState(() => _listening = false);
          _pulseCtrl.stop();
          _pulseCtrl.reset();
          // Auto-send when speech stops and we have text
          if (_transcript.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 300), _send);
          }
        }
      },
    );
    if (!mounted) return;
    if (available) _startListening();
  }

  Future<void> _startListening() async {
    setState(() {
      _listening = true;
      _transcript = '';
      _error = '';
    });
    _pulseCtrl.repeat(reverse: true);
    await _stt.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _transcript = result.recognizedWords);
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      localeId: 'fr_FR',
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  void _send() {
    if (_transcript.isNotEmpty) Navigator.of(context).pop(_transcript);
  }

  void _retry() {
    _startListening();
  }

  @override
  void dispose() {
    _stt.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.x4lBR,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppRadius.xsBR,
            ),
          ),

          // Mic button with pulse animation
          GestureDetector(
            onTap: _listening ? null : _retry,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: _listening ? _pulseAnim.value : 1.0,
                child: child,
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _listening
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.bg,
                  border: Border.all(
                    color: _error.isNotEmpty
                        ? AppColors.danger
                        : _listening
                            ? AppColors.primary
                            : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _error.isNotEmpty
                      ? Icons.mic_off_rounded
                      : Icons.mic_rounded,
                  size: 36,
                  color: _error.isNotEmpty
                      ? AppColors.danger
                      : _listening
                          ? AppColors.primary
                          : AppColors.textSecondary,
                ),
              ),
            ),
          ),

          AppSpacing.gapX5l,

          // Status / transcript
          if (_error.isNotEmpty)
            Text(
              l.tvVoiceError,
              style: const TextStyle(fontFamily: 'ShareTech', color: AppColors.danger, fontSize: AppFontSizes.body),
              textAlign: TextAlign.center,
            )
          else if (_transcript.isNotEmpty)
            Text(
              _transcript,
              style: const TextStyle(
                fontFamily: 'ShareTech',
                color: AppColors.textPrimary,
                fontSize: AppFontSizes.heading,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              _listening ? l.tvVoiceListening : l.tvVoiceTap,
              style: const TextStyle(
                fontFamily: 'ShareTech',
                color: AppColors.textSecondary,
                fontSize: AppFontSizes.md,
              ),
              textAlign: TextAlign.center,
            ),

          AppSpacing.gapX6l,

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l.cancel,
                  style: const TextStyle(fontFamily: 'ShareTech', color: AppColors.textSecondary),
                ),
              ),
              if (_transcript.isNotEmpty) ...[
                AppSpacing.gapHX3l,
                FilledButton.icon(
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(l.tvKeyboardSend),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
              if (_error.isNotEmpty && _transcript.isEmpty) ...[
                AppSpacing.gapHX3l,
                FilledButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(l.tvReconnect),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.border,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
