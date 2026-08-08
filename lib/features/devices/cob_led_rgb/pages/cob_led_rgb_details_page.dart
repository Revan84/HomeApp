import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';
import '../../../../domain/entities/rgb_scene.dart';
import '../../../../domain/repositories/cob_led_rgb_repository.dart';
import '../../../../domain/repositories/room_repository.dart';
import '../../../equipments/dialogs/equipment_edit_dialogs.dart';
import '../../shared/mixins/device_detail_mixin.dart';
import '../../shared/widgets/cob_led_active_scene_card.dart';
import '../../shared/widgets/cob_led_templates_card.dart';
import '../../shared/widgets/cob_led_wled_section.dart';
import '../../shared/widgets/detail_header_card.dart';
import '../../shared/widgets/detail_info_row.dart';
import '../../shared/widgets/detail_menu_item_row.dart';
import '../../shared/widgets/detail_offline_banner.dart';
import '../../shared/widgets/detail_section_card.dart';
import '../../shared/widgets/device_room_card.dart';
import '../controllers/cob_led_rgb_details_controller.dart';
import '../domain/rgb_color.dart';
import '../../../integrations/cob_led_rgb/data/cob_led_rgb_api_client.dart';
import '../widgets/cob_led_rgb_active_preset_section.dart';
import '../widgets/cob_led_rgb_color_section.dart';
import '../widgets/cob_led_rgb_presets_section.dart';

/// Converts between domain [RgbColor] and Flutter [Color] at the UI boundary.
extension _RgbColorToFlutter on RgbColor {
  Color toFlutterColor() => Color.fromARGB(255, red, green, blue);
}

RgbColor _flutterColorToRgb(Color c) =>
    RgbColor(red: (c.r * 255).round(), green: (c.g * 255).round(), blue: (c.b * 255).round());

// ─────────────────────────────────────────────────────────────────────────────

enum _MenuAction { refresh, editName, editIp, delete }

const _kDebounce = Duration(milliseconds: 60);

class CobLedRgbDetailsPage extends StatefulWidget {
  final String deviceId;

  const CobLedRgbDetailsPage({super.key, required this.deviceId});

  @override
  State<CobLedRgbDetailsPage> createState() => _CobLedRgbDetailsPageState();
}

class _CobLedRgbDetailsPageState extends State<CobLedRgbDetailsPage>
    with DeviceDetailMixin<CobLedRgbDetailsPage> {
  late final CobLedRgbDetailsController _ctrl;

  double _brightnessLocal = 128 / 255.0;
  double _speedLocal = 128 / 255.0;
  double _intensityLocal = 128 / 255.0;
  bool _sliderDragging = false;

  late final _SliderDebouncer _briDebouncer;
  late final _SliderDebouncer _speedDebouncer;
  late final _SliderDebouncer _intensityDebouncer;

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

    void onRelease() {
      _sliderDragging = false;
      _ctrl.saveActiveSceneSnapshot();
    }

    _briDebouncer = _SliderDebouncer(onSet: _ctrl.setBrightness, onAfterRelease: onRelease);
    _speedDebouncer = _SliderDebouncer(onSet: _ctrl.setEffectSpeed, onAfterRelease: onRelease);
    _intensityDebouncer = _SliderDebouncer(onSet: _ctrl.setEffectIntensity, onAfterRelease: onRelease);
  }

  @override
  void dispose() {
    _briDebouncer.dispose();
    _speedDebouncer.dispose();
    _intensityDebouncer.dispose();
    _ctrl.removeListener(_onUpdate);
    _ctrl.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (!mounted) return;
    if (!_sliderDragging) _syncSlidersFromState();
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

  // ── Scene / template management ───────────────────────────────────────────────

  Future<void> _showAddSceneDialog() async {
    final name = await _showSceneNameSheet(
      title: context.l10n.cobLedCctSaveAsTemplateTitle,
      initialName: '',
    );
    if (name == null || name.isEmpty || !mounted) return;
    final s = _ctrl.cobLedRgbState;
    await _ctrl.addSceneWithValues(
      name: name,
      colorRed: s.primaryColor.red,
      colorGreen: s.primaryColor.green,
      colorBlue: s.primaryColor.blue,
      brightness: s.brightness,
      effectId: s.effectId,
      effectSpeed: s.effectSpeed,
      effectIntensity: s.effectIntensity,
    );
  }

  Future<void> _showEditSceneDialog(RgbScene scene) async {
    final s = _ctrl.cobLedRgbState;
    final name = await _showSceneNameSheet(
      title: context.l10n.cobLedCctUpdateTemplateTitle,
      initialName: scene.name,
      subtitle: '${(s.brightness / 255.0 * 100).round()} % · #${s.primaryColor.hex}',
    );
    if (name == null || !mounted) return;
    await _ctrl.updateScene(scene.copyWith(
      name: name.isEmpty ? scene.name : name,
      colorRed: s.primaryColor.red,
      colorGreen: s.primaryColor.green,
      colorBlue: s.primaryColor.blue,
      brightness: s.brightness,
      effectId: s.effectId,
      effectSpeed: s.effectSpeed,
      effectIntensity: s.effectIntensity,
    ));
  }

  Future<String?> _showSceneNameSheet({
    required String title,
    required String initialName,
    String? subtitle,
  }) {
    final nameCtrl = TextEditingController(text: initialName);
    const titleStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: AppFontSizes.heading,
      color: AppColors.textPrimary,
    );
    const bodyStyle = TextStyle(
      fontSize: AppFontSizes.body,
      color: AppColors.textSecondary,
    );
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle),
              if (subtitle != null) ...[
                AppSpacing.gapSm,
                Text(subtitle, style: bodyStyle),
              ],
              AppSpacing.gapX2l,
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: context.l10n.cobLedCctTemplateNameHint,
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              AppSpacing.gapX3l,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  AppSpacing.gapHX2l,
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
                      child: Text(context.l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
              final d = _ctrl.device;
              if (d == null) return;
              editDeviceName(
                currentName: d.name,
                onUpdate: (next) async {
                  final updated = d.copyWith(name: next);
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
                onFavorite: () => _ctrl.toggleFavorite(),
              ),

              if (!isOnline) ...[
                AppSpacing.gapMd,
                DetailOfflineBanner(label: context.l10n.deviceOfflineBanner),
              ],

              // ── 2. Active scene card (user templates) ────────────────────────
              if (_ctrl.scenes.isNotEmpty) ...[
                AppSpacing.gapXl,
                CobLedActiveSceneCard<RgbScene>(
                  activeSceneId: _ctrl.activeSceneId,
                  scenes: _ctrl.scenes,
                  accentColor: accentColor,
                  idOf: (s) => s.id,
                  nameOf: (s) => s.name,
                  noActiveLabel: context.l10n.cobLedNoActiveScene,
                  activeLabel: context.l10n.cobLedCctSceneActive,
                  onApply: _ctrl.applyScene,
                ),
              ],

              // ── 3. Active WLED preset section ────────────────────────────────
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

              // ── 4. Colour + luminosity section ──────────────────────────────
              CobLedRgbColorSection(
                color: color,
                rgbColor: s.primaryColor,
                accentColor: accentColor,
                onColorChanged: (c) => _ctrl.setColor(_flutterColorToRgb(c)),
                brightness: _brightnessLocal,
                onBrightnessChangeStart: () =>
                    setState(() => _sliderDragging = true),
                onBrightnessChanged: (v) {
                  setState(() => _brightnessLocal = v);
                  _briDebouncer.onChanged(v);
                },
                onBrightnessChangeEnd: _briDebouncer.onChangeEnd,
              ),

              AppSpacing.gapXl,

              // ── 5. WLED Controls section ─────────────────────────────────────
              CobLedWledSection(
                effectId: s.effectId,
                effectNames: _ctrl.effects,
                speed: _speedLocal,
                intensity: _intensityLocal,
                accentColor: accentColor,
                isLoadingEffects: !_ctrl.effectsLoaded,
                onDragStart: () => setState(() => _sliderDragging = true),
                onSpeedChanged: (v) {
                  setState(() => _speedLocal = v);
                  _speedDebouncer.onChanged(v);
                },
                onSpeedEnd: _speedDebouncer.onChangeEnd,
                onIntensityChanged: (v) {
                  setState(() => _intensityLocal = v);
                  _intensityDebouncer.onChanged(v);
                },
                onIntensityEnd: _intensityDebouncer.onChangeEnd,
                onEffectChanged: (idx) {
                  _ctrl.setEffect(idx);
                  _ctrl.saveActiveSceneSnapshot();
                },
              ),

              AppSpacing.gapXl,

              // ── 6. Templates (locally stored scenes) ─────────────────────────
              CobLedTemplatesCard<RgbScene>(
                scenes: _ctrl.scenes,
                activeSceneId: _ctrl.activeSceneId,
                accentColor: accentColor,
                title: context.l10n.cobLedSectionTemplates,
                emptyLabel: context.l10n.cobLedRgbNoScenes,
                deleteTitle: context.l10n.cobLedRgbDeleteSceneTitle,
                deleteBody: (name) =>
                    context.l10n.cobLedRgbDeleteSceneBody(name),
                idOf: (scene) => scene.id,
                nameOf: (scene) => scene.name,
                colorDotOf: (scene) => Color.fromARGB(
                  255,
                  scene.colorRed,
                  scene.colorGreen,
                  scene.colorBlue,
                ),
                paramsOf: (ctx, scene) {
                  final parts = <String>[
                    '${(scene.brightness / 255.0 * 100).round()} %',
                    if (scene.effectId != 0) 'FX ${scene.effectId}',
                    if (scene.effectId != 0)
                      '${(scene.effectSpeed / 255.0 * 100).round()} spd',
                  ];
                  return parts.join(' · ');
                },
                onAdd: _showAddSceneDialog,
                onApply: _ctrl.applyScene,
                onEdit: _showEditSceneDialog,
                onDelete: (scene) => _ctrl.deleteScene(scene.id),
              ),

              AppSpacing.gapXl,

              // ── 7. WLED device presets ───────────────────────────────────────
              if (_ctrl.presets.isNotEmpty) ...[
                CobLedRgbPresetsSection(
                  presets: _ctrl.presets,
                  activePresetId: s.presetId,
                  accentColor: accentColor,
                  onApply: (preset) => _ctrl.loadPreset(preset.id),
                ),
                AppSpacing.gapXl,
              ],

              // ── 8. Informations ──────────────────────────────────────────────
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
                      value: isOnline
                          ? context.l10n.netStatusOnline
                          : context.l10n.netStatusOffline,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapXl,

              // ── 9. Room picker card ──────────────────────────────────────────
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

// ── Slider debouncer ─────────────────────────────────────────────────────────

/// Coalesces rapid slider drag events into a single trailing API call.
class _SliderDebouncer {
  _SliderDebouncer({required this.onSet, required this.onAfterRelease});
  final ValueChanged<double> onSet;
  final VoidCallback onAfterRelease;
  Timer? _timer;

  void onChanged(double v) {
    _timer?.cancel();
    _timer = Timer(_kDebounce, () => onSet(v));
  }

  void onChangeEnd(double v) {
    _timer?.cancel();
    onSet(v);
    onAfterRelease();
  }

  void dispose() => _timer?.cancel();
}
