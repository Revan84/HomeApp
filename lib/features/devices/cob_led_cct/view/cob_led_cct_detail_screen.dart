import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';
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
import '../controllers/cob_led_cct_controller.dart';
import '../widgets/cob_led_cct_active_scene_card.dart';
import '../widgets/cob_led_cct_colour_temp_section.dart';
import '../widgets/cob_led_cct_luminosity_section.dart';
import '../widgets/cob_led_cct_templates_card.dart';
import '../widgets/cob_led_cct_wled_section.dart';

enum _MenuAction { refresh, editName, editIp, delete }

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

  @override
  void initState() {
    super.initState();
    _ctrl = CobLedCctController(
      repo: context.read<CobLedCctRepository>(),
      roomRepo: context.read<RoomRepository>(),
      httpClient: context.read(),
      initialDevice: widget.device,
    );
    _ctrl.addListener(_onUpdate);
  }

  @override
  void dispose() {
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
        try {
          await _ctrl.refresh();
        } catch (e) {
          showDeviceError(e);
        }
      case _MenuAction.editName:
        await editDeviceName(
          currentName: _ctrl.device.name,
          onUpdate: _ctrl.updateName,
        );
      case _MenuAction.editIp:
        await _editIp();
      case _MenuAction.delete:
        if (await confirmDeviceDelete(_ctrl.device.name) != true) return;
        try {
          await _ctrl.delete();
        } catch (e) {
          showDeviceError(e);
          return;
        }
        if (!mounted) return;
        Navigator.of(context).pop(true);
    }
  }

  Future<void> _editIp() async {
    final next = await EquipmentEditDialogs.editLocalIp(
      context,
      currentIp: _ctrl.device.ipAddress,
    );
    if (next == null || !mounted) return;
    try {
      await _ctrl.updateIp(next);
    } catch (e) {
      showDeviceError(e);
    }
  }

  // ── Save-as-scene dialog ─────────────────────────────────────────────────────

  Future<void> _showAddSceneDialog() async {
    final nameCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          context.l10n.cobLedCctSaveAsTemplateTitle,
          style: const TextStyle(
              fontFamily: 'ShareTech', color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_ctrl.cctState.colorTempK} K · '
              '${(_brightnessLocal * 100).round()} %',
              style: const TextStyle(
                fontFamily: 'ShareTech',
                color: AppColors.textSecondary,
                fontSize: AppFontSizes.body,
              ),
            ),
            AppSpacing.gapMd,
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: const TextStyle(
                  fontFamily: 'ShareTech', color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: context.l10n.cobLedCctTemplateNameHint,
                hintStyle: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;
    await _ctrl.addSceneWithValues(
      name: name,
      colorTempK: _ctrl.cctState.colorTempK,
      brightness: _ctrl.cctState.brightness,
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
                    label: context.l10n.smartPlugMenuDelete,
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
                onChangeStart: (_) => setState(() => _sliderDragging = true),
                onChanged: (v) => setState(() => _colorTempLocal = v),
                onChangeEnd: (v) {
                  _sliderDragging = false;
                  _ctrl.setColorTemp(v);
                },
              ),
              AppSpacing.gapXl,
              CobLedCctLuminositySection(
                brightness: _brightnessLocal,
                accentColor: accentColor,
                onChangeStart: (_) => setState(() => _sliderDragging = true),
                onChanged: (v) => setState(() => _brightnessLocal = v),
                onChangeEnd: (v) {
                  _sliderDragging = false;
                  _ctrl.setBrightness(v);
                },
              ),
              AppSpacing.gapXl,
              CobLedCctWledSection(
                effectId: s.effectId,
                effectNames: _ctrl.effectNames,
                speed: _speedLocal,
                audioReactive: s.audioReactive,
                accentColor: accentColor,
                onEffectChanged: _ctrl.setEffect,
                onSpeedChangeStart: (_) =>
                    setState(() => _sliderDragging = true),
                onSpeedChanged: (v) => setState(() => _speedLocal = v),
                onSpeedChangeEnd: (v) {
                  _sliderDragging = false;
                  _ctrl.setEffectSpeed(v);
                },
                onAudioChanged: _ctrl.setAudio,
              ),
              AppSpacing.gapXl,
              CobLedCctTemplatesCard(
                scenes: _ctrl.scenes,
                activeSceneId: d.activeSceneId,
                accentColor: accentColor,
                onAdd: _showAddSceneDialog,
                onApply: _ctrl.applyScene,
                onDelete: (scene) => _ctrl.deleteScene(scene.id),
              ),
              AppSpacing.gapXl,
              DetailSectionCard(
                title: context.l10n.detailSectionInformations,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _editIp,
                      child: DetailInfoRow(
                        label: context.l10n.smartPlugInfoLocalIp,
                        value: d.ipAddress,
                      ),
                    ),
                    AppSpacing.gapSm,
                    DetailInfoRow(
                      label: context.l10n.smartPlugInfoModel,
                      value: d.modelName.isEmpty ? '—' : d.modelName,
                    ),
                    AppSpacing.gapSm,
                    GestureDetector(
                      onTap: _ctrl.toggleFavorite,
                      child: DetailInfoRow(
                        label: context.l10n.favorite,
                        value: d.isFavorite ? context.l10n.valueYes : context.l10n.valueNo,
                      ),
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
