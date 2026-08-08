import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/connected_camera_device.dart';
import '../../../../domain/repositories/connected_camera_repository.dart';
import '../../../../domain/repositories/room_repository.dart';
import '../../../equipments/dialogs/equipment_edit_dialogs.dart';
import '../../../integrations/cameras/data/camera_api_client_factory.dart';
import '../../shared/mixins/device_detail_mixin.dart';
import '../../shared/widgets/detail_info_row.dart';
import '../../shared/widgets/detail_section_card.dart';
import '../../shared/widgets/device_room_card.dart';
import '../controllers/controller.dart';

enum _MenuAction { editName, editIp, refresh, delete }

class ConnectedCameraDetailScreen extends StatefulWidget {
  const ConnectedCameraDetailScreen({super.key, required this.device});

  final ConnectedCameraDevice device;

  @override
  State<ConnectedCameraDetailScreen> createState() =>
      _ConnectedCameraDetailScreenState();
}

class _ConnectedCameraDetailScreenState
    extends State<ConnectedCameraDetailScreen>
    with DeviceDetailMixin<ConnectedCameraDetailScreen> {
  late final ConnectedCameraController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ConnectedCameraController(
      repo: context.read<ConnectedCameraRepository>(),
      roomRepo: context.read<RoomRepository>(),
      apiClientFactory: context.read<CameraApiClientFactory>(),
      initialDevice: widget.device,
    );
    _ctrl.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onUpdate);
    _ctrl.dispose();
    super.dispose();
  }

  // ── Menu ─────────────────────────────────────────────────────────────────────

  Future<void> _onMenuSelected(_MenuAction action) async {
    switch (action) {
      case _MenuAction.editName:
        await editDeviceName(
          currentName: _ctrl.device.name,
          onUpdate: _ctrl.updateName,
        );
      case _MenuAction.editIp:
        final next = await EquipmentEditDialogs.editLocalIp(
          context,
          currentIp: _ctrl.device.ipAddress,
        );
        if (next != null && mounted) await _ctrl.updateIp(next);
      case _MenuAction.refresh:
        await _ctrl.refresh();
      case _MenuAction.delete:
        final confirmed = await confirmDeviceDelete(_ctrl.device.name);
        if (confirmed == true && mounted) {
          await _ctrl.delete();
          if (mounted) Navigator.of(context).pop(true);
        }
    }
  }

  // ── Status indicator ──────────────────────────────────────────────────────────

  Widget _buildStatusChip(BuildContext context) {
    final l = context.l10n;
    final probed = _ctrl.isOnlineProbed;

    if (probed == null) {
      // Still probing
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 8,
            height: 8,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
          AppSpacing.gapHSm,
          Text(
            '…',
            style: const TextStyle(
              fontSize: AppFontSizes.sm,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: probed
                ? AppColors.connectedCameraAccent
                : AppColors.textSecondary,
          ),
        ),
        AppSpacing.gapHSm,
        Text(
          probed ? l.netStatusOnline : l.netStatusOffline,
          style: TextStyle(
            fontSize: AppFontSizes.sm,
            color: probed
                ? AppColors.connectedCameraAccent
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final device = _ctrl.device;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(
          device.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: AppFontSizes.heading,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(
              device.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: device.isFavorite
                  ? AppColors.connectedCameraAccent
                  : AppColors.textSecondary,
            ),
            onPressed: _ctrl.toggleFavorite,
          ),
          PopupMenuButton<_MenuAction>(
            color: AppColors.surface,
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: _onMenuSelected,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _MenuAction.editName,
                child: Text(l.deviceMenuEdit,
                    style: const TextStyle(color: AppColors.textPrimary)),
              ),
              PopupMenuItem(
                value: _MenuAction.editIp,
                child: Text(l.deviceInfoLocalIp,
                    style: const TextStyle(color: AppColors.textPrimary)),
              ),
              PopupMenuItem(
                value: _MenuAction.refresh,
                child: Row(
                  children: [
                    const Icon(Icons.refresh_rounded,
                        size: 16, color: AppColors.textPrimary),
                    AppSpacing.gapHMd,
                    Text(l.refresh,
                        style:
                            const TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.delete,
                child: Text(l.deviceMenuDelete,
                    style: const TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        children: [
          // ── Status chip ────────────────────────────────────────────────────
          _buildStatusChip(context),

          AppSpacing.gapX2l,

          // ── Live stream (placeholder) ──────────────────────────────────────
          DetailSectionCard(
            title: l.connectedCameraStreamSectionTitle,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off_rounded,
                        color: AppColors.textSecondary, size: 36),
                    AppSpacing.gapMd,
                    Text(
                      l.connectedCameraStreamComingSoon,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppFontSizes.sm,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AppSpacing.gapX2l,

          // ── Device info ────────────────────────────────────────────────────
          DetailSectionCard(
            title: l.deviceSectionInformations,
            child: Column(
              children: [
                DetailInfoRow(
                    label: l.deviceInfoLocalIp, value: device.ipAddress),
                if (device.modelName.isNotEmpty) ...[
                  AppSpacing.gapMd,
                  DetailInfoRow(
                      label: l.deviceInfoModelLabel, value: device.modelName),
                ],
                if (device.firmwareVersion.isNotEmpty) ...[
                  AppSpacing.gapMd,
                  DetailInfoRow(
                      label: l.deviceInfoConnection,
                      value: device.firmwareVersion),
                ],
              ],
            ),
          ),

          AppSpacing.gapX2l,

          // ── Camera credentials ─────────────────────────────────────────────
          DetailSectionCard(
            title: l.connectedCameraRtspLabel,
            child: Column(
              children: [
                DetailInfoRow(
                  label: l.cameraAccountUserLabel,
                  value: device.cameraAccountUser.isEmpty
                      ? '—'
                      : device.cameraAccountUser,
                ),
                AppSpacing.gapMd,
                DetailInfoRow(
                  label: l.cameraAccountPasswordLabel,
                  value: device.cameraAccountPassword.isEmpty
                      ? '—'
                      : '•' * device.cameraAccountPassword.length.clamp(0, 8),
                ),
              ],
            ),
          ),

          AppSpacing.gapX2l,

          // ── Room ───────────────────────────────────────────────────────────
          DeviceRoomCard(
            roomName: _ctrl.roomName(l.none),
            onTap: () => pickDeviceRoom(
              rooms: _ctrl.rooms,
              currentRoomId: device.roomId,
              onUpdate: _ctrl.updateRoom,
            ),
          ),

          AppSpacing.gapX3l,

          // ── Danger zone ────────────────────────────────────────────────────
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger.withValues(alpha: 0.12),
              foregroundColor: AppColors.danger,
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l.deviceMenuDelete),
            onPressed: () => _onMenuSelected(_MenuAction.delete),
          ),

          AppSpacing.gapX3l,
        ],
      ),
    );
  }

}
