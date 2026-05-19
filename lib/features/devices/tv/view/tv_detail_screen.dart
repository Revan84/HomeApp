import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';
import '../../../../domain/entities/tv_device.dart';
import '../../../../domain/repositories/room_repository.dart';
import '../../../../domain/repositories/tv_repository.dart';
import '../../../equipments/dialogs/equipment_edit_dialogs.dart';
import '../../../integrations/samsung/data/samsung_ws_client.dart';
import '../../shared/mixins/device_detail_mixin.dart';
import '../../shared/widgets/detail_header_card.dart';
import '../../shared/widgets/detail_menu_item_row.dart';
import '../../shared/widgets/detail_offline_banner.dart';
import '../../shared/widgets/detail_section_card.dart';
import '../../shared/widgets/device_room_card.dart';
import '../controllers/tv_details_controller.dart';
import '../domain/tv_app.dart';
import '../widgets/tv_apps_grid.dart';
import '../widgets/tv_info_section.dart';
import '../widgets/tv_remote_widget.dart';
import '../widgets/tv_source_card.dart';
import '../widgets/tv_voice_input_sheet.dart';

enum _MenuAction { refresh, edit, delete }

class TvDetailScreen extends StatefulWidget {
  const TvDetailScreen({super.key, required this.device});

  final TvDevice device;

  @override
  State<TvDetailScreen> createState() => _TvDetailScreenState();
}

class _TvDetailScreenState extends State<TvDetailScreen>
    with DeviceDetailMixin<TvDetailScreen> {
  late final TvDetailsController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TvDetailsController(
      tvRepo: context.read<TvRepository>(),
      roomRepo: context.read<RoomRepository>(),
      initialDevice: widget.device,
    );
    _ctrl.addListener(_onUpdate);
    _ctrl.init(widget.device.id);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onUpdate);
    _ctrl.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  // ── Menu actions ─────────────────────────────────────────────────────────────

  Future<void> _handleMenuAction(_MenuAction action) async {
    switch (action) {
      case _MenuAction.refresh:
        try {
          await _ctrl.connect();
        } catch (err) {
          showDeviceError(err);
        }
      case _MenuAction.edit:
        await _showEditSheet();
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

  // ── Edit sheet ───────────────────────────────────────────────────────────────

  Future<void> _showEditSheet() async {
    final l10n = context.l10n;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTopBR),
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (_, setSheetState) {
          final d = _ctrl.device;
          if (d == null) return const SizedBox.shrink();

          Future<void> run(Future<void> Function() action) async {
            await action();
            setSheetState(() {});
          }

          Widget sheetRow({
            required IconData icon,
            required String label,
            required String value,
            required VoidCallback onTap,
          }) =>
              ListTile(
                leading: Icon(icon, color: AppColors.textSecondary, size: 20),
                title: Text(label,
                    style: const TextStyle(
                        fontSize: AppFontSizes.sm,
                        color: AppColors.textSecondary)),
                subtitle: Text(value,
                    style: const TextStyle(
                        fontSize: AppFontSizes.body,
                        color: AppColors.textPrimary)),
                trailing: const Icon(Icons.edit_outlined,
                    size: 15, color: AppColors.textSecondary),
                onTap: onTap,
              );

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpacing.gapXl,
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: AppRadius.xsBR,
                  ),
                ),
                AppSpacing.gapX2l,
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.deviceMenuEdit,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: AppFontSizes.sectionTitle,
                            color: AppColors.textPrimary)),
                  ),
                ),
                AppSpacing.gapMd,
                const Divider(height: 1, color: AppColors.border),
                sheetRow(
                  icon: Icons.label_outline_rounded,
                  label: l10n.detailsEditNameTooltip,
                  value: d.name,
                  onTap: () => run(() async {
                    final next = await EquipmentEditDialogs.editName(
                        context, currentName: d.name);
                    if (next == null) return;
                    await _ctrl.updateName(next);
                  }),
                ),
                const Divider(indent: 56, height: 1, color: AppColors.border),
                sheetRow(
                  icon: Icons.router_outlined,
                  label: l10n.deviceInfoLocalIp,
                  value: d.ipAddress,
                  onTap: () => run(() async {
                    final next = await EquipmentEditDialogs.editLocalIp(
                        context, currentIp: d.ipAddress);
                    if (next == null) return;
                    await _ctrl.updateIp(next);
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Keyboard input ───────────────────────────────────────────────────────────

  Future<void> _openKeyboard() async {
    final text = await TvVoiceInputSheet.show(context);
    if (text != null && text.isNotEmpty) _ctrl.sendText(text);
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final device = _ctrl.device;
    final connState = _ctrl.connectionState;
    final isOnline = connState == TvConnectionState.connected;
    final isOn = _ctrl.isOn;

    return DeviceAccentScope(
      accentColor: AppColors.tvAccent,
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
              editDeviceName(currentName: d.name, onUpdate: _ctrl.updateName);
            },
            child: Flexible(
              child: Text(
                device?.name ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSizes.heading,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          actions: [
            PopupMenuButton<_MenuAction>(
              icon: const Icon(Icons.more_vert),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
              onSelected: _handleMenuAction,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _MenuAction.refresh,
                  child: DetailMenuItemRow(
                      icon: Icons.refresh_rounded, label: l10n.deviceMenuRefresh),
                ),
                PopupMenuItem(
                  value: _MenuAction.edit,
                  child: DetailMenuItemRow(
                      icon: Icons.edit_outlined, label: l10n.deviceMenuEdit),
                ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: DetailMenuItemRow(
                    icon: Icons.delete_outline_rounded,
                    label: l10n.deviceMenuDelete,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: device == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    DetailHeaderCard(
                      isFavorite: device.isFavorite,
                      typeLabel: l10n.tvSubtitle,
                      icon: Icons.tv_rounded,
                      accentColor: AppColors.tvAccent,
                      isOnline: isOnline,
                      isOn: isOn,
                      toggling: false,
                      lastUpdatedAt: _ctrl.lastConnectedAt,
                      onToggle: () => _ctrl.togglePower(!isOn),
                      onFavorite: _ctrl.toggleFavorite,
                    ),
                    AppSpacing.gapXl,
                    if (!isOnline) ...[
                      DetailOfflineBanner(label: l10n.deviceLastKnownValues),
                      AppSpacing.gapMd,
                    ],
                    TvSourceCard(
                      source: device.source,
                      onCommand: _ctrl.sendCommand,
                    ),
                    AppSpacing.gapXl,
                    DetailSectionCard(
                      title: l10n.tvSectionRemote,
                      child: TvRemoteWidget(
                        onCommand: _ctrl.sendCommand,
                        onKeyboardTap: _openKeyboard,
                      ),
                    ),
                    AppSpacing.gapXl,
                    DetailSectionCard(
                      title: l10n.tvSectionApplications,
                      child: TvAppsGrid(
                        apps: defaultTvApps,
                        onAppTap: _ctrl.launchApp,
                      ),
                    ),
                    AppSpacing.gapXl,
                    TvInfoSection(
                      device: device,
                      connectionState: connState,
                    ),
                    AppSpacing.gapXl,
                    DeviceRoomCard(
                      roomName: _ctrl.roomName(l10n.none),
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
