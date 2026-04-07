import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';

import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/wled_repository.dart';

import '../../equipments/dialogs/equipment_edit_dialogs.dart';
import '../../equipments/widgets/room_toggle_row.dart';
import '../controllers/wled_details_controller.dart';
import '../domain/rgb_color.dart';
import '../../integrations/wled/data/wled_api_client.dart';
import '../widgets/wled_color_wheel.dart';
import '../widgets/wled_effects_list.dart';
import '../widgets/wled_info_grid.dart';
import '../widgets/wled_power_bar.dart';
import '../widgets/wled_scenes_bar.dart';
import '../widgets/wled_slider_row.dart';

/// Converts between domain [RgbColor] and Flutter [Color] at the UI boundary.
extension _RgbColorToFlutter on RgbColor {
  Color toFlutterColor() => Color.fromARGB(255, red, green, blue);
}

RgbColor _flutterColorToRgb(Color c) =>
    RgbColor(red: (c.r * 255).round(), green: (c.g * 255).round(), blue: (c.b * 255).round());

class WledDetailsPage extends StatefulWidget {
  final String deviceId;

  const WledDetailsPage({super.key, required this.deviceId});

  @override
  State<WledDetailsPage> createState() => _WledDetailsPageState();
}

class _WledDetailsPageState extends State<WledDetailsPage> {
  late final WledDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WledDetailsController(
      wledRepo: context.read<WledRepository>(),
      roomRepo: context.read<RoomRepository>(),
      api: WledApiClient(context.read()),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _controller.delete();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final device = _controller.device;
    if (device == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Device not found')),
      );
    }

    final l = context.l10n;
    final wledState = _controller.wledState;
    final color = wledState.primaryColor.toFlutterColor();

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
          if (_controller.isPolling)
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
              onPressed: _controller.refresh,
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
          WledPowerBar(
            isOn: wledState.isOn,
            color: color,
            onToggle: _controller.togglePower,
          ),

          const SizedBox(height: 20),

          if (_controller.presets.isNotEmpty) ...[
            _SectionLabel(l.wledScenesLabel),
            const SizedBox(height: 8),
            WledScenesBar(
              presets: _controller.presets,
              selectedId: wledState.presetId,
              onSelected: _controller.loadPreset,
            ),
            const SizedBox(height: 20),
          ],

          _SectionLabel(l.wledColorsTab),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: WledColorWheel(
              color: color,
              onColorChanged: (c) => _controller.setColor(_flutterColorToRgb(c)),
            ),
          ),

          const SizedBox(height: 20),

          WledSliderRow(
            label: l.wledBrightnessLabel,
            value: wledState.brightness / 255.0,
            onChanged: _controller.setBrightness,
            activeColor: color,
          ),

          const SizedBox(height: 8),

          _SectionLabel(l.wledEffectsTab),
          const SizedBox(height: 8),

          WledSliderRow(
            label: l.wledSpeedLabel,
            value: wledState.effectSpeed / 255.0,
            onChanged: _controller.setEffectSpeed,
            activeColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          WledSliderRow(
            label: l.wledIntensityLabel,
            value: wledState.effectIntensity / 255.0,
            onChanged: _controller.setEffectIntensity,
            activeColor: AppColors.textPrimary,
          ),

          const SizedBox(height: 12),

          if (_controller.effects.isNotEmpty)
            SizedBox(
              height: 200,
              child: WledEffectsList(
                effects: _controller.effects,
                selectedId: wledState.effectId,
                onSelected: _controller.setEffect,
              ),
            ),

          const SizedBox(height: 24),

          RoomToggleRow(
            roomName: _controller.roomName(context.l10n.none),
            onSelectRoom: _selectRoom,
            value: wledState.isOn,
            onChanged: (_) => _controller.togglePower(),
          ),

          const SizedBox(height: 16),

          WledInfoGrid(device: device, isOnline: !_controller.isPolling),
        ],
      ),
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

