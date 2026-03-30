import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';

import '../../../domain/models/room.dart';
import '../../../domain/models/wled_device.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/wled_repository.dart';

import '../../equipments/dialogs/equipment_edit_dialogs.dart';
import '../../equipments/widgets/room_toggle_row.dart';
import '../../integrations/wled/data/wled_api_client.dart';
import '../widgets/wled_color_wheel.dart';

class WledDetailsPage extends StatefulWidget {
  final String deviceId;

  const WledDetailsPage({super.key, required this.deviceId});

  @override
  State<WledDetailsPage> createState() => _WledDetailsPageState();
}

class _WledDetailsPageState extends State<WledDetailsPage>
    with SingleTickerProviderStateMixin {
  WledDevice? _device;
  bool _loadingDevice = true;

  WledState _wledState = WledState.defaultState;
  List<String> _effects = const [];
  List<WledPreset> _presets = const [];
  List<Room> _rooms = const [];

  bool _polling = false;
  Timer? _pollTimer;

  late final WledApiClient _api;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _api = WledApiClient(context.read());
    _tabController = TabController(length: 2, vsync: this);
    _loadDevice();
    _loadRooms();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDevice() async {
    final device =
        await context.read<WledRepository>().loadById(widget.deviceId);
    if (!mounted) return;
    setState(() {
      _device = device;
      _loadingDevice = false;
    });
    if (device != null) _refresh();
  }

  Future<void> _loadRooms() async {
    final rooms = await context.read<RoomRepository>().loadAll();
    if (!mounted) return;
    setState(() => _rooms = rooms);
  }

  Future<void> _refresh() async {
    final ip = _device?.ipAddress;
    if (ip == null) return;

    setState(() => _polling = true);

    final results = await Future.wait([
      _api.getState(ip),
      _api.getEffects(ip),
      _api.getPresets(ip),
    ]);

    if (!mounted) return;

    final state = results[0] as WledState?;
    final effects = results[1] as List<String>;
    final presets = results[2] as List<WledPreset>;

    setState(() {
      if (state != null) _wledState = state;
      if (effects.isNotEmpty) _effects = effects;
      if (presets.isNotEmpty) _presets = presets;
      _polling = false;
    });
  }

  Future<void> _togglePower() async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final newOn = !_wledState.isOn;
    setState(() => _wledState = _wledState.copyWith(isOn: newOn));
    await _api.setOn(ip, on: newOn);
  }

  Future<void> _onColorChanged(Color color) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    setState(() => _wledState = _wledState.copyWith(primaryColor: color));
    await _api.setColor(ip, color);
  }

  Future<void> _onBrightnessChanged(double value) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final bri = (value * 255).round();
    setState(() => _wledState = _wledState.copyWith(brightness: bri));
    await _api.setBrightness(ip, bri);
  }

  Future<void> _onEffectSelected(int effectId) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    setState(() => _wledState = _wledState.copyWith(effectId: effectId));
    await _api.setEffect(
      ip,
      effectId,
      speed: _wledState.effectSpeed,
      intensity: _wledState.effectIntensity,
    );
  }

  Future<void> _onSpeedChanged(double value) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final speed = (value * 255).round();
    setState(() =>
        _wledState = _wledState.copyWith(effectSpeed: speed));
    await _api.setEffect(
      ip,
      _wledState.effectId,
      speed: speed,
      intensity: _wledState.effectIntensity,
    );
  }

  Future<void> _onIntensityChanged(double value) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final intensity = (value * 255).round();
    setState(() =>
        _wledState = _wledState.copyWith(effectIntensity: intensity));
    await _api.setEffect(
      ip,
      _wledState.effectId,
      speed: _wledState.effectSpeed,
      intensity: intensity,
    );
  }

  Future<void> _onPresetSelected(int presetId) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    setState(() => _wledState = _wledState.copyWith(presetId: presetId));
    await _api.loadPreset(ip, presetId);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _refresh();
  }

  Future<void> _selectRoom() async {
    final d = _device;
    if (d == null) return;
    final repo = context.read<WledRepository>();
    final noneLabel = context.l10n.none;
    final nextRoomId = await EquipmentEditDialogs.pickRoom(
      context,
      currentRoomId: d.roomId,
      rooms: _rooms,
      noneLabel: noneLabel,
    );
    if (nextRoomId == d.roomId) return;
    final updated =
        d.copyWith(roomId: nextRoomId, clearRoomId: nextRoomId == null);
    await repo.update(updated);
    if (!mounted) return;
    setState(() => _device = updated);
  }

  String _roomName() {
    final d = _device;
    if (d == null || d.roomId == null) return context.l10n.none;
    return _rooms
        .cast<Room?>()
        .firstWhere((r) => r?.id == d.roomId, orElse: () => null)
        ?.name ??
        context.l10n.none;
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.wledDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<WledRepository>().deleteById(widget.deviceId);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_loadingDevice) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final device = _device;
    if (device == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Device not found')),
      );
    }

    final l = context.l10n;
    final color = _wledState.primaryColor;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_polling)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: l.refresh,
            ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: l.delete,
            color: AppColors.danger,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Power + hex display ─────────────────────────────────────────
          _PowerBar(
            isOn: _wledState.isOn,
            color: color,
            onToggle: _togglePower,
          ),

          const SizedBox(height: 20),

          // ── Presets / scenes bar ────────────────────────────────────────
          if (_presets.isNotEmpty) ...[
            _SectionLabel(l.wledScenesLabel),
            const SizedBox(height: 8),
            _ScenesBar(
              presets: _presets,
              selectedId: _wledState.presetId,
              onSelected: _onPresetSelected,
            ),
            const SizedBox(height: 20),
          ],

          // ── Color wheel ─────────────────────────────────────────────────
          _SectionLabel(l.wledColorsTab),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: WledColorWheel(
              color: color,
              onColorChanged: _onColorChanged,
            ),
          ),

          const SizedBox(height: 20),

          // ── Brightness slider ───────────────────────────────────────────
          _SliderRow(
            label: l.wledBrightnessLabel,
            value: _wledState.brightness / 255.0,
            onChanged: _onBrightnessChanged,
            activeColor: color,
          ),

          const SizedBox(height: 8),

          // ── Tab bar: Effects ────────────────────────────────────────────
          _SectionLabel(l.wledEffectsTab),
          const SizedBox(height: 8),

          // Speed + Intensity sliders (only relevant when effect ≠ 0)
          _SliderRow(
            label: l.wledSpeedLabel,
            value: _wledState.effectSpeed / 255.0,
            onChanged: _onSpeedChanged,
            activeColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          _SliderRow(
            label: l.wledIntensityLabel,
            value: _wledState.effectIntensity / 255.0,
            onChanged: _onIntensityChanged,
            activeColor: AppColors.textPrimary,
          ),

          const SizedBox(height: 12),

          // Effects list
          if (_effects.isNotEmpty)
            SizedBox(
              height: 200,
              child: _EffectsList(
                effects: _effects,
                selectedId: _wledState.effectId,
                onSelected: _onEffectSelected,
              ),
            ),

          const SizedBox(height: 24),

          // ── Room + power toggle ─────────────────────────────────────────
          RoomToggleRow(
            roomName: _roomName(),
            onSelectRoom: _selectRoom,
            value: _wledState.isOn,
            onChanged: (_) => _togglePower(),
          ),

          const SizedBox(height: 16),

          // ── Info grid ───────────────────────────────────────────────────
          _InfoGrid(device: device, isOnline: !_polling),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Power bar
// ---------------------------------------------------------------------------

class _PowerBar extends StatelessWidget {
  final bool isOn;
  final Color color;
  final VoidCallback onToggle;

  const _PowerBar({
    required this.isOn,
    required this.color,
    required this.onToggle,
  });

  String _hexString(Color c) {
    final r = (c.r * 255).round().clamp(0, 255);
    final g = (c.g * 255).round().clamp(0, 255);
    final b = (c.b * 255).round().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          // Color swatch
          GestureDetector(
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: _hexString(color)));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_hexString(color)} copied'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Hex label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hexString(color),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOn ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOn ? AppColors.success : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Power toggle
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isOn
                    ? AppColors.success.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOn ? AppColors.success : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.power_settings_new_rounded,
                color: isOn ? AppColors.success : AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scenes bar
// ---------------------------------------------------------------------------

class _ScenesBar extends StatelessWidget {
  final List<WledPreset> presets;
  final int selectedId;
  final ValueChanged<int> onSelected;

  const _ScenesBar({
    required this.presets,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final p = presets[i];
          final selected = p.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected(p.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      selected ? AppColors.success : Colors.white.withValues(alpha: 0.1),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                p.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Effects list
// ---------------------------------------------------------------------------

class _EffectsList extends StatelessWidget {
  final List<String> effects;
  final int selectedId;
  final ValueChanged<int> onSelected;

  const _EffectsList({
    required this.effects,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: effects.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          itemBuilder: (_, i) {
            final selected = i == selectedId;
            return InkWell(
              onTap: () => onSelected(i),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppColors.success
                            : Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        effects[i],
                        style: TextStyle(
                          fontSize: 13,
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slider row
// ---------------------------------------------------------------------------

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final Color activeColor;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor.withValues(alpha: 0.85),
              inactiveTrackColor: AppColors.stroke,
              thumbColor: activeColor,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 3,
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 14),
              overlayColor: activeColor.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value.clamp(0.0, 1.0),
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '${(value * 100).round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info grid
// ---------------------------------------------------------------------------

class _InfoGrid extends StatelessWidget {
  final WledDevice device;
  final bool isOnline;

  const _InfoGrid({required this.device, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'IP',
            value: device.ipAddress,
          ),
          if (device.modelName.isNotEmpty) ...[
            const Divider(height: 20, color: Colors.white12),
            _InfoRow(
              label: context.l10n.tvModelLabel,
              value: device.modelName,
            ),
          ],
          const Divider(height: 20, color: Colors.white12),
          _InfoRow(
            label: 'Status',
            value: isOnline ? 'Online' : 'Offline',
            valueColor: isOnline ? AppColors.success : AppColors.danger,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
