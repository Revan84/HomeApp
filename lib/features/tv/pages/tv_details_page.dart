import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/time_label.dart';

import '../domain/tv_app.dart';
import '../domain/tv_remote_command.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/tv_repository.dart';

import '../../equipments/dialogs/equipment_edit_dialogs.dart';
import '../../equipments/widgets/prototype_card.dart';
import '../../equipments/widgets/room_toggle_row.dart';
import '../../integrations/samsung/data/samsung_ws_client.dart';
import '../controllers/tv_details_controller.dart';
import '../widgets/tv_apps_grid.dart';
import '../widgets/tv_info_grid.dart';
import '../widgets/tv_remote_widget.dart';
import '../widgets/tv_voice_input_sheet.dart';

class TvDetailsPage extends StatefulWidget {
  final String deviceId;

  const TvDetailsPage({super.key, required this.deviceId});

  @override
  State<TvDetailsPage> createState() => _TvDetailsPageState();
}

const _kNoRoom = '__none__';

class _TvDetailsPageState extends State<TvDetailsPage> {
  late final TvDetailsController _controller;

  final GlobalKey _roomKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = TvDetailsController(
      tvRepo: context.read<TvRepository>(),
      roomRepo: context.read<RoomRepository>(),
    );
    _controller.addListener(_onControllerUpdate);
    _controller.init(widget.deviceId);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _editName() async {
    final device = _controller.device;
    if (device == null) return;
    final next = await EquipmentEditDialogs.editName(
      context,
      currentName: device.name,
    );
    if (next == null) return;
    await _controller.updateName(next);
  }

  Future<void> _editLocalIp() async {
    final device = _controller.device;
    if (device == null) return;
    final next = await EquipmentEditDialogs.editLocalIp(
      context,
      currentIp: device.ipAddress,
    );
    if (next == null) return;
    await _controller.updateIp(next);
  }

  Future<void> _selectRoom() async {
    final device = _controller.device;
    if (device == null) return;

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    final keyCtx = _roomKey.currentContext;
    if (keyCtx == null || overlay == null) return;
    final box = keyCtx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(pos.dx, pos.dy, box.size.width, box.size.height),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
      items: [
        PopupMenuItem<String>(
          value: _kNoRoom,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (device.roomId == null)
                const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
              else
                const SizedBox(width: 18),
              AppSpacing.gapHMd,
              Text(
                context.l10n.none,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ..._controller.rooms.map((room) => PopupMenuItem<String>(
          value: room.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (room.id == device.roomId)
                const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
              else
                const SizedBox(width: 18),
              AppSpacing.gapHMd,
              Text(
                room.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        )),
      ],
    );

    if (selected == null) return;
    await _controller.updateRoom(selected == _kNoRoom ? null : selected);
  }

  Future<void> _showVoiceInput() async {
    final text = await TvVoiceInputSheet.show(context);
    if (text != null && text.isNotEmpty) {
      _controller.sendText(text);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.delete),
        content: Text(context.l10n.tvDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.delete,
              style: const TextStyle(fontFamily: 'ShareTech', color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _controller.delete();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (_controller.isLoading || _controller.device == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final d = _controller.device!;
    final updatedLabel = ageLabel(context, _controller.lastConnectedAt);
    final isConnected =
        _controller.connectionState == TvConnectionState.connected;
    final connectionLabel =
        isConnected ? l.tvStatusConnectedWifi : l.tvStatusDisconnected;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          PrototypeCard(
            accentColor: AppColors.tvAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TvHeader(
                  sourceName: d.source,
                  updatedLabel: updatedLabel,
                  onRefresh: _controller.connect,
                ),
                AppSpacing.gapXs,
                Row(
                  children: [
                    Text(
                      d.name,
                      style: const TextStyle(
                        fontFamily: 'ShareTech',
                        color: AppColors.textSecondary,
                        fontSize: AppFontSizes.body,
                      ),
                    ),
                    AppSpacing.gapHSm,
                    InkResponse(
                      onTap: _editName,
                      radius: 14,
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapXl,
                Row(
                  children: [
                    _SourceButton(
                      onTap: () =>
                          _controller.sendCommand(TvRemoteCommand.source),
                    ),
                    AppSpacing.gapHLg,
                    _HomeButton(
                      onTap: () =>
                          _controller.sendCommand(TvRemoteCommand.home),
                    ),
                  ],
                ),
                AppSpacing.gapX3l,
                TvRemoteWidget(
                  onCommand: _controller.sendCommand,
                  onKeyboardTap: _showVoiceInput,
                ),
                AppSpacing.gapX5l,
                Text(
                  l.tvAppsTitle,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    color: AppColors.textSecondary,
                    fontSize: 12.0,
                  ),
                ),
                AppSpacing.gapLg,
                TvAppsGrid(
                  apps: defaultTvApps,
                  onAppTap: _controller.launchApp,
                ),
                AppSpacing.gapX4l,
                TvInfoGrid(
                  ipLabel: l.ipLocalLabel,
                  ip: d.ipAddress,
                  onEditIp: _editLocalIp,
                  typeLabel: l.typeLabel,
                  typeValue: l.tvTypeSmartTv,
                  favoriteLabel: l.favorite,
                  favoriteValue: d.isFavorite ? l.valueYes : l.valueNo,
                  isFavorite: d.isFavorite,
                  onToggleFavorite: _controller.toggleFavorite,
                  modelLabel:
                      d.modelName.isEmpty ? l.tvDefaultModel : d.modelName,
                  modelValue:
                      d.modelName.isEmpty ? l.tvDefaultModel : d.modelName,
                  online: isConnected,
                  connectionLabel: connectionLabel,
                ),
                AppSpacing.gapX4l,
                RoomToggleRow(
                  anchorKey: _roomKey,
                  roomName: _controller.roomName(context.l10n.none),
                  onSelectRoom: _selectRoom,
                  isOn: _controller.isOn,
                  onTap: () => _controller.togglePower(_controller.isOn),
                ),
              ],
            ),
          ),
          AppSpacing.gapX3l,
          Center(
            child: TextButton(
              onPressed: _delete,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l.delete,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textSecondary,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header row: cast icon + source name + update label + refresh icon.
class _TvHeader extends StatelessWidget {
  final String sourceName;
  final String updatedLabel;
  final VoidCallback onRefresh;

  const _TvHeader({
    required this.sourceName,
    required this.updatedLabel,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.cast_rounded, size: 20, color: AppColors.textPrimary),
        AppSpacing.gapHLg,
        Text(
          sourceName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        AppSpacing.gapHLg,
        Expanded(
          child: Text(
            updatedLabel,
            style: const TextStyle(
              fontFamily: 'ShareTech',
              color: AppColors.textSecondary,
              fontSize: AppFontSizes.sm,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          iconSize: 20,
          tooltip: context.l10n.refresh,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

/// Button that sends KEY_SOURCE to cycle through TV inputs.
class _SourceButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SourceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.smBR,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: AppRadius.smBR,
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.input_rounded, color: AppColors.primary, size: 16),
            AppSpacing.gapHSm,
            Text(
              context.l10n.tvKeySource,
              style: const TextStyle(
                fontFamily: 'ShareTech',
                color: AppColors.primary,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Button that sends KEY_HOME.
class _HomeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _HomeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.smBR,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: AppRadius.smBR,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_rounded, color: AppColors.textPrimary, size: 16),
            const SizedBox(width: 6),
            Text(
              context.l10n.tvKeyHome,
              style: const TextStyle(
                fontFamily: 'ShareTech',
                color: AppColors.textPrimary,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
