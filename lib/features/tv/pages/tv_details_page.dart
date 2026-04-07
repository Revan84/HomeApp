import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
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

class _TvDetailsPageState extends State<TvDetailsPage> {
  late final TvDetailsController _controller;

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
    final nextRoomId = await EquipmentEditDialogs.pickRoom(
      context,
      currentRoomId: device.roomId,
      rooms: _controller.rooms,
      noneLabel: context.l10n.none,
    );
    await _controller.updateRoom(nextRoomId);
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
              style: const TextStyle(color: AppColors.danger),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TvHeader(
                  sourceName: d.source,
                  updatedLabel: updatedLabel,
                  onRefresh: _controller.connect,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      d.name,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    _SourceButton(
                      onTap: () =>
                          _controller.sendCommand(TvRemoteCommand.source),
                    ),
                    const SizedBox(width: 10),
                    _HomeButton(
                      onTap: () =>
                          _controller.sendCommand(TvRemoteCommand.home),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TvRemoteWidget(
                  onCommand: _controller.sendCommand,
                  onKeyboardTap: _showVoiceInput,
                ),
                const SizedBox(height: 20),
                Text(
                  l.tvAppsTitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                TvAppsGrid(
                  apps: defaultTvApps,
                  onAppTap: _controller.launchApp,
                ),
                const SizedBox(height: 18),
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
                const SizedBox(height: 18),
                RoomToggleRow(
                  roomName:
                      _controller.roomName(context.l10n.none),
                  onSelectRoom: _selectRoom,
                  value: _controller.isOn,
                  onChanged: (v) => _controller.togglePower(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
        const SizedBox(width: 10),
        Text(
          sourceName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            updatedLabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
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
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.success, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.input_rounded, color: AppColors.success, size: 16),
            const SizedBox(width: 6),
            Text(
              context.l10n.tvKeySource,
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 12,
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
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.stroke, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_rounded, color: AppColors.textPrimary, size: 16),
            const SizedBox(width: 6),
            Text(
              context.l10n.tvKeyHome,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
