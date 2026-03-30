import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/time_label.dart';

import '../../../domain/models/room.dart';
import '../../../domain/models/tv_app.dart';
import '../../../domain/models/tv_device.dart';
import '../../../domain/models/tv_remote_command.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/tv_repository.dart';

import '../../equipments/dialogs/equipment_edit_dialogs.dart';
import '../../equipments/widgets/prototype_card.dart';
import '../../equipments/widgets/room_toggle_row.dart';
import '../../integrations/samsung/data/samsung_ws_client.dart';
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
  late final SamsungWsClient _client;
  late TvConnectionState _connState;
  StreamSubscription<TvConnectionState>? _sub;
  StreamSubscription<String>? _tokenSub;

  TvDevice? _device;
  bool _loadingDevice = true;
  List<Room> _rooms = const [];
  bool _isOn = true;

  /// Tracks the last successful connection time.
  DateTime? _lastConnectedAt;

  @override
  void initState() {
    super.initState();
    _client = SamsungWsClient();
    _connState = _client.state;
    _sub = _client.stateStream.listen((s) {
      if (!mounted) return;
      setState(() {
        _connState = s;
        if (s == TvConnectionState.connected) {
          _lastConnectedAt = DateTime.now();
        }
      });
    });
    // Persist the pairing token when the TV sends one
    _tokenSub = _client.onTokenReceived.listen(_onTokenReceived);
    _loadDevice();
    _loadRooms();
  }

  Future<void> _loadDevice() async {
    final device = await context.read<TvRepository>().loadById(widget.deviceId);
    if (!mounted) return;
    setState(() {
      _device = device;
      _loadingDevice = false;
    });
    if (device != null) _connect();
  }

  Future<void> _connect() async {
    final d = _device;
    if (d == null) return;
    await _client.connect(d.ipAddress, savedToken: d.wsToken);
  }

  /// Called when the TV sends a new pairing token.
  /// Persists the token AND immediately reconnects with it so the current
  /// session gets full permissions (app launch, etc.) right away.
  void _onTokenReceived(String token) {
    if (!mounted || _device == null) return;
    final updated = _device!.copyWith(wsToken: token);
    context.read<TvRepository>().update(updated);
    setState(() => _device = updated);
    _connect(); // reconnect immediately with the new token
  }

  Future<void> _loadRooms() async {
    final rooms = await context.read<RoomRepository>().loadAll();
    if (!mounted) return;
    setState(() => _rooms = rooms);
  }

  @override
  void dispose() {
    _tokenSub?.cancel();
    _sub?.cancel();
    _client.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Commands
  // ---------------------------------------------------------------------------

  void _onCommand(TvRemoteCommand cmd) {
    _client.sendKey(cmd);
  }

  void _onAppTap(TvApp app) {
    _client.launchApp(app.samsungAppId);
  }

  void _togglePower(bool value) {
    setState(() => _isOn = value);
    _client.sendKey(
      value ? TvRemoteCommand.powerOn : TvRemoteCommand.powerOff,
    );
  }

  // ---------------------------------------------------------------------------
  // Editing
  // ---------------------------------------------------------------------------

  Future<void> _editName() async {
    if (_device == null) return;
    final repo = context.read<TvRepository>();
    final next = await EquipmentEditDialogs.editName(
      context,
      currentName: _device!.name,
    );
    if (next == null) return;

    final updated = _device!.copyWith(name: next);
    await repo.update(updated);
    if (!mounted) return;
    setState(() => _device = updated);
  }

  Future<void> _editLocalIp() async {
    if (_device == null) return;
    final repo = context.read<TvRepository>();
    final next = await EquipmentEditDialogs.editLocalIp(
      context,
      currentIp: _device!.ipAddress,
    );
    if (next == null) return;

    final updated = _device!.copyWith(ipAddress: next);
    await repo.update(updated);
    if (!mounted) return;
    setState(() => _device = updated);
    _connect(); // reconnect to new IP
  }

  Future<void> _toggleFavorite() async {
    if (_device == null) return;
    final repo = context.read<TvRepository>();
    final updated = _device!.copyWith(isFavorite: !_device!.isFavorite);
    await repo.update(updated);
    if (!mounted) return;
    setState(() => _device = updated);
  }

  Future<void> _selectRoom() async {
    if (_device == null) return;
    final repo = context.read<TvRepository>();
    final nextRoomId = await EquipmentEditDialogs.pickRoom(
      context,
      currentRoomId: _device!.roomId,
      rooms: _rooms,
      noneLabel: context.l10n.none,
    );
    if (nextRoomId == _device!.roomId) return;

    final updated = _device!.copyWith(roomId: nextRoomId);
    await repo.update(updated);
    if (!mounted) return;
    setState(() => _device = updated);
  }

  void _cycleSource() {
    _client.sendKey(TvRemoteCommand.source);
  }

  void _sendHome() {
    _client.sendKey(TvRemoteCommand.home);
  }

  Future<void> _showVoiceInput() async {
    final text = await TvVoiceInputSheet.show(context);
    if (text != null && text.isNotEmpty) {
      _client.sendText(text);
    }
  }

  Future<void> _delete() async {
    if (_device == null) return;
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

    if (confirm != true || !mounted) return;
    await context.read<TvRepository>().deleteById(_device!.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _roomName() {
    final roomId = _device?.roomId;
    if (roomId == null) return context.l10n.none;
    final match = _rooms.cast<Room?>().firstWhere(
          (r) => r?.id == roomId,
          orElse: () => null,
        );
    return match?.name ?? context.l10n.none;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (_loadingDevice || _device == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final d = _device!;
    final updatedLabel = ageLabel(context, _lastConnectedAt);
    final isConnected = _connState == TvConnectionState.connected;

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
                // Header: source name, update label, refresh
                _TvHeader(
                  sourceName: d.source,
                  updatedLabel: updatedLabel,
                  onRefresh: _connect,
                ),
                const SizedBox(height: 4),

                // Subtitle: name + edit
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

                // Source + Home buttons
                Row(
                  children: [
                    _SourceButton(onTap: _cycleSource),
                    const SizedBox(width: 10),
                    _HomeButton(onTap: _sendHome),
                  ],
                ),
                const SizedBox(height: 16),

                // Remote control area
                TvRemoteWidget(
                  onCommand: _onCommand,
                  onKeyboardTap: _showVoiceInput,
                ),
                const SizedBox(height: 20),

                // Applications section
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
                  onAppTap: _onAppTap,
                ),
                const SizedBox(height: 18),

                // Info grid
                TvInfoGrid(
                  ipLabel: l.ipLocalLabel,
                  ip: d.ipAddress,
                  onEditIp: _editLocalIp,
                  typeLabel: l.typeLabel,
                  typeValue: l.tvTypeSmartTv,
                  favoriteLabel: l.favorite,
                  favoriteValue:
                      d.isFavorite ? l.valueYes : l.valueNo,
                  isFavorite: d.isFavorite,
                  onToggleFavorite: _toggleFavorite,
                  modelLabel: d.modelName.isEmpty
                      ? l.tvDefaultModel
                      : d.modelName,
                  modelValue: d.modelName.isEmpty
                      ? l.tvDefaultModel
                      : d.modelName,
                  online: isConnected,
                  connectionLabel: connectionLabel,
                ),
                const SizedBox(height: 18),

                // Room + power toggle
                RoomToggleRow(
                  roomName: _roomName(),
                  onSelectRoom: _selectRoom,
                  value: _isOn,
                  onChanged: (v) => _togglePower(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Delete button
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
