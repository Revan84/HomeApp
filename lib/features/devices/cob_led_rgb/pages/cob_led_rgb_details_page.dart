import 'package:flutter/material.dart';
import 'package:front_end/core/theme/app_radius.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../shared/mixins/device_detail_mixin.dart';
import '../../shared/widgets/device_room_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';

import '../../../../domain/repositories/room_repository.dart';
import '../../../../domain/repositories/cob_led_rgb_repository.dart';

import '../../../equipments/dialogs/equipment_edit_dialogs.dart';
import '../../shared/widgets/detail_header_card.dart';
import '../../shared/widgets/detail_info_row.dart';
import '../../shared/widgets/detail_menu_item_row.dart';
import '../../shared/widgets/detail_offline_banner.dart';
import '../../shared/widgets/detail_section_card.dart';
import '../controllers/cob_led_rgb_details_controller.dart';
import '../domain/rgb_color.dart';
import '../../../integrations/cob_led_rgb/data/cob_led_rgb_api_client.dart';
import '../widgets/cob_led_rgb_active_preset_section.dart';
import '../widgets/cob_led_rgb_color_section.dart';
import '../widgets/cob_led_rgb_controls_section.dart';
import '../widgets/cob_led_rgb_luminosity_section.dart';
import '../widgets/cob_led_rgb_presets_section.dart';

/// Converts between domain [RgbColor] and Flutter [Color] at the UI boundary.
extension _RgbColorToFlutter on RgbColor {
  Color toFlutterColor() => Color.fromARGB(255, red, green, blue);
}

RgbColor _flutterColorToRgb(Color c) =>
    RgbColor(red: (c.r * 255).round(), green: (c.g * 255).round(), blue: (c.b * 255).round());

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────

enum _MenuAction { refresh, editName, editIp, delete }

class CobLedRgbDetailsPage extends StatefulWidget {
  final String deviceId;

  const CobLedRgbDetailsPage({super.key, required this.deviceId});

  @override
  State<CobLedRgbDetailsPage> createState() => _CobLedRgbDetailsPageState();
}

class _CobLedRgbDetailsPageState extends State<CobLedRgbDetailsPage>
    with DeviceDetailMixin<CobLedRgbDetailsPage> {
  late final CobLedRgbDetailsController _ctrl;

  // Local slider values for smooth drag (decoupled from API calls).
  double _brightnessLocal = 128 / 255.0;
  double _speedLocal = 128 / 255.0;
  double _intensityLocal = 128 / 255.0;
  bool _sliderDragging = false;

  @override
  void initState() {
    super.initState();
    _ctrl = CobLedRgbDetailsController(
      cobLedRgbRepo: context.read<CobLedRgbRepository>(),
      roomRepo: context.read<RoomRepository>(),
      api: CobLedRgbApiClient(context.read()),
    );
    _ctrl.addListener(_onUpdate);
    _ctrl.init(widget.deviceId);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onUpdate);
    _ctrl.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (!mounted) return;
    if (!_sliderDragging) {
      _syncSlidersFromState();
    }
    setState(() {});
  }

  void _syncSlidersFromState() {
    final s = _ctrl.cobLedRgbState;
    _brightnessLocal = s.brightness / 255.0;
    _speedLocal = s.effectSpeed / 255.0;
    _intensityLocal = s.effectIntensity / 255.0;
  }

  // ── Menu ─────────────────────────────────────────────────────────────────────

  Future<void> _handleMenuAction(_MenuAction action) async {
    switch (action) {
      case _MenuAction.refresh:
        try {
          await _ctrl.refresh();
        } catch (err) {
          showDeviceError(err);
        }
      case _MenuAction.editName:
        final device = _ctrl.device;
        if (device == null) return;
        await editDeviceName(
          currentName: device.name,
          onUpdate: (next) async {
            final updated = device.copyWith(name: next);
            await context.read<CobLedRgbRepository>().update(updated);
            await _ctrl.init(widget.deviceId);
          },
        );
      case _MenuAction.editIp:
        await _editIp();
      case _MenuAction.delete:
        if (await confirmDeviceDelete(_ctrl.device?.name ?? '') != true) return;
        try {
          await _ctrl.delete();
        } catch (err) {
          showDeviceError(err);
          return;
        }
        if (!mounted) return;
        Navigator.of(context).pop(true);
    }
  }

  Future<void> _editIp() async {
    final device = _ctrl.device;
    if (device == null) return;
    final next = await EquipmentEditDialogs.editLocalIp(
      context,
      currentIp: device.ipAddress,
    );
    if (next == null || !mounted) return;
    try {
      final updated = device.copyWith(ipAddress: next);
      await context.read<CobLedRgbRepository>().update(updated);
      await _ctrl.init(widget.deviceId);
    } catch (err) {
      showDeviceError(err);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_ctrl.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final device = _ctrl.device;
    if (device == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l10n.deviceNotFound)),
      );
    }

    const accentColor = AppColors.cobLedRgbAccent;
    final s = _ctrl.cobLedRgbState;
    final color = s.primaryColor.toFlutterColor();
    final isOnline = !_ctrl.isPolling;

    return DeviceAccentScope(
      accentColor: accentColor,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.card,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.45),
          leading: const BackButton(),
          title: GestureDetector(
            onTap: () {
              final device = _ctrl.device;
              if (device == null) return;
              editDeviceName(
                currentName: device.name,
                onUpdate: (next) async {
                  final updated = device.copyWith(name: next);
                  await context.read<CobLedRgbRepository>().update(updated);
                  await _ctrl.init(widget.deviceId);
                },
              );
            },
            child: Text(
              device.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppFontSizes.heading,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _handleMenuAction(_MenuAction.refresh),
              tooltip: context.l10n.refresh,
            ),
            PopupMenuButton<_MenuAction>(
              icon: const Icon(Icons.more_vert),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
              onSelected: _handleMenuAction,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _MenuAction.editName,
                  child: DetailMenuItemRow(
                    icon: Icons.label_outline_rounded,
                    label: context.l10n.detailsEditNameTooltip,
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.editIp,
                  child: DetailMenuItemRow(
                    icon: Icons.router_outlined,
                    label: context.l10n.detailsEditIpTooltip,
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: DetailMenuItemRow(
                    icon: Icons.delete_outline_rounded,
                    label: context.l10n.deviceMenuDelete,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Header card ───────────────────────────────────────────────
              DetailHeaderCard(
                isFavorite: device.isFavorite,
                typeLabel: context.l10n.cobLedRgbTypeLabel,
                icon: Icons.color_lens_outlined,
                accentColor: accentColor,
                isOnline: isOnline,
                isOn: s.isOn,
                toggling: false,
                lastUpdatedAt: null,
                onToggle: () => _ctrl.togglePower(),
                onFavorite: () {},
              ),

              if (!isOnline) ...[
                AppSpacing.gapMd,
                DetailOfflineBanner(label: context.l10n.deviceOfflineBanner),
              ],

              // ── 2. Active preset section ─────────────────────────────────────
              if (_ctrl.presets.isNotEmpty) ...[
                AppSpacing.gapXl,
                CobLedRgbActivePresetSection(
                  activePresetId: s.presetId,
                  presets: _ctrl.presets,
                  accentColor: accentColor,
                  onApply: (preset) => _ctrl.loadPreset(preset.id),
                ),
              ],

              AppSpacing.gapXl,

              // ── 3. Colour section ────────────────────────────────────────────
              CobLedRgbColorSection(
                color: color,
                rgbColor: s.primaryColor,
                onColorChanged: (c) => _ctrl.setColor(_flutterColorToRgb(c)),
              ),

              AppSpacing.gapXl,

              // ── 4. Luminosity section ────────────────────────────────────────
              CobLedRgbLuminositySection(
                brightness: _brightnessLocal,
                color: color,
                onChangeStart: () => setState(() => _sliderDragging = true),
                onChanged: (v) => setState(() => _brightnessLocal = v),
                onChangeEnd: (v) {
                  _sliderDragging = false;
                  _ctrl.setBrightness(v);
                },
              ),

              AppSpacing.gapXl,

              // ── 5. WLED Controls section ─────────────────────────────────────
              CobLedRgbControlsSection(
                speed: _speedLocal,
                intensity: _intensityLocal,
                audioReactive: s.audioReactive,
                effectId: s.effectId,
                effectNames: _ctrl.effects,
                accentColor: accentColor,
                onDragStart: () => setState(() => _sliderDragging = true),
                onSpeedChanged: (v) => setState(() => _speedLocal = v),
                onSpeedEnd: (v) {
                  _sliderDragging = false;
                  _ctrl.setEffectSpeed(v);
                },
                onIntensityChanged: (v) => setState(() => _intensityLocal = v),
                onIntensityEnd: (v) {
                  _sliderDragging = false;
                  _ctrl.setEffectIntensity(v);
                },
                onAudioChanged: (v) => _ctrl.setAudio(v),
                onEffectChanged: (idx) => _ctrl.setEffect(idx),
              ),

              AppSpacing.gapXl,

              // ── 6. Templates (WLED presets) ──────────────────────────────────
              CobLedRgbPresetsSection(
                presets: _ctrl.presets,
                activePresetId: s.presetId,
                accentColor: accentColor,
                onApply: (preset) => _ctrl.loadPreset(preset.id),
              ),

              AppSpacing.gapXl,

              // ── 7. Informations ──────────────────────────────────────────────
              DetailSectionCard(
                title: context.l10n.detailSectionInformations,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _editIp,
                      child: DetailInfoRow(
                        label: context.l10n.deviceInfoLocalIp,
                        value: device.ipAddress,
                      ),
                    ),
                    AppSpacing.gapSm,
                    DetailInfoRow(
                      label: context.l10n.deviceInfoModelLabel,
                      value: device.modelName.isEmpty ? '—' : device.modelName,
                    ),
                    AppSpacing.gapSm,
                    DetailInfoRow(
                      label: context.l10n.detailInfoStatus,
                      value: isOnline ? context.l10n.netStatusOnline : context.l10n.netStatusOffline,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapXl,

              // ── 8. Room picker card ──────────────────────────────────────────
              DeviceRoomCard(
                roomName: _ctrl.roomName(context.l10n.none),
                onTap: () => pickDeviceRoom(
                  rooms: _ctrl.rooms,
                  currentRoomId: _ctrl.device?.roomId,
                  onUpdate: _ctrl.updateRoom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

