import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';
import '../../../../domain/entities/cct_scene.dart';
import '../../../../domain/entities/cob_led_cct_device.dart';
import '../../../../domain/repositories/cob_led_cct_repository.dart';
import '../../../../domain/repositories/room_repository.dart';
import '../../../equipments/dialogs/equipment_edit_dialogs.dart';
import '../../shared/mixins/device_detail_mixin.dart';
import '../../shared/widgets/detail_header_card.dart';
import '../../shared/widgets/device_room_card.dart';
import '../../shared/widgets/detail_info_row.dart';
import '../../shared/widgets/detail_menu_item_row.dart';
import '../../shared/widgets/detail_offline_banner.dart';
import '../../shared/widgets/detail_section_card.dart';
import '../controllers/controller.dart';
import '../widgets/active_scene_card.dart';
import '../widgets/colour_temp_section.dart';
import '../widgets/templates_card.dart';
import '../widgets/wled_section.dart';

enum _MenuAction { refresh, editName, editIp, delete }

const _kDebounce = Duration(milliseconds: 60);

class CobLedCctDetailScreen extends StatefulWidget {
  const CobLedCctDetailScreen({super.key, required this.device});

  final CobLedCctDevice device;

  @override
  State<CobLedCctDetailScreen> createState() => _CobLedCctDetailScreenState();
}

class _CobLedCctDetailScreenState extends State<CobLedCctDetailScreen>
    with DeviceDetailMixin<CobLedCctDetailScreen> {
  late final CobLedCctController _ctrl;

  // Local slider values for smooth drag — decoupled from API calls.
  double _brightnessLocal = 200 / 255.0;
  double _colorTempLocal = (3000 - 2700) / (6500 - 2700);
  double _speedLocal = 128 / 255.0;
  bool _sliderDragging = false;

  // Debouncers — fire the API call a short time after each drag frame so the
  // LED updates in real-time without flooding the device. See [_SliderDebouncer].
  late final _SliderDebouncer _briDebouncer;
  late final _SliderDebouncer _ctDebouncer;
  late final _SliderDebouncer _speedDebouncer;

  void _onSliderStart(double _) =>
      setState(() => _sliderDragging = true);

  @override
  void initState() {
    super.initState();
    _ctrl = CobLedCctController(
      repo: context.read<CobLedCctRepository>(),
      roomRepo: context.read<RoomRepository>(),
      // Why: explicit type guards against silent breakage if the controller's
      // parameter type ever changes.
      httpClient: context.read<http.Client>(),
      initialDevice: widget.device,
    );
    _ctrl.addListener(_onUpdate);

    void onRelease() { _sliderDragging = false; _ctrl.saveActiveSceneSnapshot(); }
    _briDebouncer = _SliderDebouncer(onSet: _ctrl.setBrightness, onAfterRelease: onRelease);
    _ctDebouncer = _SliderDebouncer(onSet: _ctrl.setColorTemp, onAfterRelease: onRelease);
    _speedDebouncer = _SliderDebouncer(onSet: _ctrl.setEffectSpeed, onAfterRelease: onRelease);
  }

  @override
  void dispose() {
    _briDebouncer.dispose();
    _ctDebouncer.dispose();
    _speedDebouncer.dispose();
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
    final s = _ctrl.cctState;
    _brightnessLocal = s.brightness / 255.0;
    _colorTempLocal = (s.colorTempK - 2700) / (6500 - 2700);
    _speedLocal = s.effectSpeed / 255.0;
  }

  // ── Menu ─────────────────────────────────────────────────────────────────────

  Future<void> _handleMenuAction(_MenuAction action) async {
    switch (action) {
      case _MenuAction.refresh:
        try { await _ctrl.refresh(); } catch (e) { showDeviceError(e); }
      case _MenuAction.editName:
        await editDeviceName(currentName: _ctrl.device.name, onUpdate: _ctrl.updateName);
      case _MenuAction.editIp:
        await _editIp();
      case _MenuAction.delete:
        if (await confirmDeviceDelete(_ctrl.device.name) != true) return;
        try { await _ctrl.delete(); } catch (e) { showDeviceError(e); return; }
        if (!mounted) return;
        Navigator.of(context).pop(true);
    }
  }

  Future<void> _editIp() async {
    final next = await EquipmentEditDialogs.editLocalIp(context, currentIp: _ctrl.device.ipAddress);
    if (next == null || !mounted) return;
    try { await _ctrl.updateIp(next); } catch (e) { showDeviceError(e); }
  }

  // ── Save-as-scene / edit-scene sheet ────────────────────────────────────────

  /// Opens the "save as template" bottom sheet.
  Future<void> _showAddSceneDialog() async {
    final name = await _showSceneNameSheet(
      title: context.l10n.cobLedCctSaveAsTemplateTitle,
      initialName: '',
    );
    if (name == null || name.isEmpty || !mounted) return;

    final s = _ctrl.cctState;
    await _ctrl.addSceneWithValues(
      name: name,
      colorTempK: s.colorTempK,
      brightness: s.brightness,
      effectId: s.effectId,
      effectSpeed: s.effectSpeed,
    );
  }

  /// Opens an edit sheet for an existing scene and updates it with the current
  /// device state.
  Future<void> _showEditSceneDialog(CctScene scene) async {
    final s = _ctrl.cctState;
    final summaryParts = [
      '${s.colorTempK} K',
      '${(s.brightness / 255.0 * 100).round()} %',
    ];
    final name = await _showSceneNameSheet(
      title: context.l10n.cobLedCctUpdateTemplateTitle,
      initialName: scene.name,
      subtitle: summaryParts.join(' · '),
    );
    if (name == null || !mounted) return;

    await _ctrl.updateScene(scene.copyWith(
      name: name.isEmpty ? scene.name : name,
      colorTempK: s.colorTempK,
      brightness: s.brightness,
      effectId: s.effectId,
      effectSpeed: s.effectSpeed,
    ));
  }

  /// Shared bottom sheet for entering a template name.  Returns the entered
  /// name, or null if the user cancelled.
  Future<String?> _showSceneNameSheet({
    required String title,
    required String initialName,
    String? subtitle,
  }) {
    final nameCtrl = TextEditingController(text: initialName);
    const titleStyle = TextStyle(
      fontFamily: 'ShareTech', fontWeight: FontWeight.w600,
      fontSize: AppFontSizes.heading, color: AppColors.textPrimary,
    );
    const bodyStyle = TextStyle(
      fontFamily: 'ShareTech',
      fontSize: AppFontSizes.body, color: AppColors.textSecondary,
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
                style: const TextStyle(
                  fontFamily: 'ShareTech', color: AppColors.textPrimary,
                ),
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
    const accentColor = AppColors.cobLedCctAccent;
    final d = _ctrl.device;
    final s = _ctrl.cctState;
    final isOnline = _ctrl.isReachable;

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
            onTap: () => editDeviceName(
              currentName: _ctrl.device.name,
              onUpdate: _ctrl.updateName,
            ),
            child: Text(
              d.name,
              style: const TextStyle(
                fontFamily: 'ShareTech',
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
                PopupMenuItem(value: _MenuAction.editName, child: DetailMenuItemRow(
                  icon: Icons.label_outline_rounded,
                  label: context.l10n.detailsEditNameTooltip)),
                PopupMenuItem(value: _MenuAction.editIp, child: DetailMenuItemRow(
                  icon: Icons.router_outlined,
                  label: context.l10n.detailsEditIpTooltip)),
                PopupMenuItem(value: _MenuAction.delete, child: DetailMenuItemRow(
                  icon: Icons.delete_outline_rounded,
                  label: context.l10n.smartPlugMenuDelete,
                  color: AppColors.danger)),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DetailHeaderCard(
                isFavorite: d.isFavorite,
                typeLabel: context.l10n.cobLedCctTypeLabel,
                icon: Icons.wb_incandescent_outlined,
                accentColor: accentColor,
                isOnline: isOnline,
                isOn: s.isOn,
                toggling: false,
                lastUpdatedAt: null,
                onToggle: _ctrl.togglePower,
                onFavorite: _ctrl.toggleFavorite,
              ),
              if (!isOnline) ...[
                AppSpacing.gapMd,
                DetailOfflineBanner(label: context.l10n.deviceOfflineBanner),
              ],
              if (_ctrl.scenes.isNotEmpty) ...[
                AppSpacing.gapXl,
                CobLedCctActiveSceneCard(
                  activeSceneId: d.activeSceneId,
                  scenes: _ctrl.scenes,
                  accentColor: accentColor,
                  onApply: _ctrl.applyScene,
                ),
              ],
              AppSpacing.gapXl,
              CobLedCctColourTempSection(
                value: _colorTempLocal,
                onChangeStart: _onSliderStart,
                onChanged: (v) {
                  setState(() => _colorTempLocal = v);
                  _ctDebouncer.onChanged(v);
                },
                onChangeEnd: _ctDebouncer.onChangeEnd,
                brightness: _brightnessLocal,
                accentColor: accentColor,
                onBrightnessChangeStart: _onSliderStart,
                onBrightnessChanged: (v) {
                  setState(() => _brightnessLocal = v);
                  _briDebouncer.onChanged(v);
                },
                onBrightnessChangeEnd: _briDebouncer.onChangeEnd,
              ),
              AppSpacing.gapXl,
              CobLedCctWledSection(
                effectId: s.effectId,
                effectNames: _ctrl.effectNames,
                speed: _speedLocal,
                accentColor: accentColor,
                onEffectChanged: (id) {
                  _ctrl.setEffect(id);
                  _ctrl.saveActiveSceneSnapshot();
                },
                onSpeedChangeStart: _onSliderStart,
                onSpeedChanged: (v) {
                  setState(() => _speedLocal = v);
                  _speedDebouncer.onChanged(v);
                },
                onSpeedChangeEnd: _speedDebouncer.onChangeEnd,
              ),
              AppSpacing.gapXl,
              CobLedCctTemplatesCard(
                scenes: _ctrl.scenes,
                activeSceneId: d.activeSceneId,
                accentColor: accentColor,
                onAdd: _showAddSceneDialog,
                onApply: _ctrl.applyScene,
                onEdit: _showEditSceneDialog,
                onDelete: (scene) => _ctrl.deleteScene(scene.id),
              ),
              AppSpacing.gapXl,
              DetailSectionCard(
                title: context.l10n.detailSectionInformations,
                child: Column(
                  children: [
                    GestureDetector(onTap: _editIp, child: DetailInfoRow(
                      label: context.l10n.smartPlugInfoLocalIp, value: d.ipAddress)),
                    AppSpacing.gapSm,
                    DetailInfoRow(label: context.l10n.smartPlugInfoModel,
                      value: d.modelName.isEmpty ? '—' : d.modelName),
                    AppSpacing.gapSm,
                    GestureDetector(onTap: _ctrl.toggleFavorite, child: DetailInfoRow(
                      label: context.l10n.favorite,
                      value: d.isFavorite ? context.l10n.valueYes : context.l10n.valueNo)),
                    AppSpacing.gapSm,
                    DetailInfoRow(label: context.l10n.detailInfoStatus,
                      value: isOnline ? context.l10n.netStatusOnline : context.l10n.netStatusOffline),
                  ],
                ),
              ),
              AppSpacing.gapXl,
              DeviceRoomCard(
                roomName: _ctrl.roomName(context.l10n.none),
                onTap: () => pickDeviceRoom(
                  rooms: _ctrl.rooms,
                  currentRoomId: _ctrl.device.roomId,
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
///
/// Why: dragging a slider emits onChanged on every frame; without debouncing,
/// each drag floods the device with HTTP PATCHes. We schedule the API call
/// [_kDebounce] after the last frame; on release we cancel the pending timer
/// and fire one final synchronous call so the device ends exactly where the
/// user dropped.
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
