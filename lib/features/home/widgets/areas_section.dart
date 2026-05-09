import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/design_system/chips/app_chip.dart';
import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../devices/tv/domain/tv_remote_command.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/cob_led_cct_device.dart';
import '../../../domain/entities/room.dart';
import '../../../domain/entities/tv_device.dart';
import '../../../domain/entities/cob_led_rgb_device.dart';
import '../../../domain/entities/equipment.dart';
import '../../live/controllers/live_polling_controller.dart';
import '../controllers/home_controller.dart';
import '../device_cards/cob_led_cct_card.dart';
import '../device_cards/hygrometer_card.dart';
import '../device_cards/plug_card.dart';
import '../device_cards/thermometer_card.dart';
import '../device_cards/tv_card.dart';
import '../device_cards/cob_led_rgb_card.dart';

/// Areas section with:
/// - Horizontal room chip selector ("All Rooms" + one per room)
/// - 2-column device grid showing all device types in the selected room.
class AreasSection extends StatefulWidget {
  const AreasSection({
    super.key,
    required this.rooms,
    required this.groupId,
    required this.onOpenEquipment,
    required this.onOpenTv,
    required this.onOpenCobLedRgb,
    required this.onOpenCobLedCct,
  });

  final List<Room> rooms;
  final String? groupId;
  final void Function(String equipmentId) onOpenEquipment;
  final void Function(String tvId) onOpenTv;
  final void Function(String deviceId) onOpenCobLedRgb;
  final void Function(String cctId) onOpenCobLedCct;

  @override
  State<AreasSection> createState() => _AreasSectionState();
}

class _AreasSectionState extends State<AreasSection> {
  /// null = "All Rooms"
  String? _selectedRoomId;

  @override
  void didUpdateWidget(AreasSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedRoomId != null) {
      final stillExists = widget.rooms.any((r) => r.id == _selectedRoomId);
      if (!stillExists) setState(() => _selectedRoomId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeCtl = context.watch<HomeController>();
    final liveCtl = context.watch<LivePollingController>();

    final rooms = widget.rooms;

    final displayRooms = _selectedRoomId == null
        ? rooms
        : rooms.where((r) => r.id == _selectedRoomId).toList();

    final deviceItems = _buildDeviceItems(homeCtl, liveCtl, displayRooms);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.gapX3l,
        // Room chip selector
        if (rooms.isNotEmpty) ...[
          _RoomChips(
            rooms: rooms,
            selectedRoomId: _selectedRoomId,
            homeCtl: homeCtl,
            onSelect: (id) => setState(() => _selectedRoomId = id),
          ),
        ],
        AppSpacing.gapX3l,
        // Device grid
        if (deviceItems.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              rooms.isEmpty ? context.l10n.areasNoRooms : context.l10n.areasNoDevices,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 10,
              childAspectRatio: 155 / 150,
            ),
            itemCount: deviceItems.length,
            itemBuilder: (_, i) => deviceItems[i],
          ),
      ],
    );
  }

  List<Widget> _buildDeviceItems(
    HomeController homeCtl,
    LivePollingController liveCtl,
    List<Room> rooms,
  ) {
    final items = <Widget>[];

    for (final room in rooms) {
      for (final eq in homeCtl.equipmentsForRoom(room.id)) {
        items.add(_buildEquipmentCard(eq, liveCtl, homeCtl));
      }
      for (final tv in homeCtl.tvDevicesForRoom(room.id)) {
        items.add(_buildTvCard(tv, homeCtl));
      }
      for (final device in homeCtl.cobLedRgbDevicesForRoom(room.id)) {
        items.add(_buildCobLedRgbCard(device, homeCtl));
      }
      for (final cct in homeCtl.cobLedCctDevicesForRoom(room.id)) {
        items.add(_buildCobLedCctCard(cct, homeCtl));
      }
    }

    return items;
  }

  Widget _buildEquipmentCard(
    Equipment eq,
    LivePollingController liveCtl,
    HomeController homeCtl,
  ) {
    if (eq.type.isThermometer) {
      return ThermometerCard(
        equipment: eq,
        liveState: liveCtl.live[eq.id],
        onTap: () => widget.onOpenEquipment(eq.id),
      );
    }
    if (eq.type.isHygrometer) {
      return HygrometerCard(
        equipment: eq,
        liveState: liveCtl.live[eq.id],
        onTap: () => widget.onOpenEquipment(eq.id),
      );
    }
    return PlugCard(
      equipment: eq,
      liveState: eq.type.isPlug ? liveCtl.live[eq.id] : null,
      onTap: () => widget.onOpenEquipment(eq.id),
      onToggle: eq.showToggle ? () => homeCtl.togglePlug(eq) : null,
    );
  }

  Widget _buildTvCard(TvDevice tv, HomeController homeCtl) {
    final isOn = homeCtl.tvIsOn(tv.id);
    return TvCard(
      tv: tv,
      isOn: isOn,
      onTap: () => widget.onOpenTv(tv.id),
      onHome: () => homeCtl.sendTvCommand(tv, TvRemoteCommand.home),
      onVolumeUp: () => homeCtl.sendTvCommand(tv, TvRemoteCommand.volumeUp),
      onVolumeDown: () => homeCtl.sendTvCommand(tv, TvRemoteCommand.volumeDown),
    );
  }

  Widget _buildCobLedRgbCard(CobLedRgbDevice device, HomeController homeCtl) {
    final state = homeCtl.cobLedRgbStateFor(device.id);
    final isOn = state?.isOn ?? false;
    final brightness = ((state?.brightness ?? 128) / 255.0).clamp(0.0, 1.0);
    final c = state?.primaryColor;
    final color = c != null
        ? Color.fromARGB(255, c.red, c.green, c.blue)
        : Colors.amber;
    return CobLedRgbCard(
      device: device,
      isOn: isOn,
      brightness: brightness,
      sceneName: '',
      color: color,
      onTap: () => widget.onOpenCobLedRgb(device.id),
      onToggle: () => homeCtl.toggleCobLedRgb(device),
      onBrightnessDrag: (v) => homeCtl.setCobLedRgbBrightness(device, v),
    );
  }

  Widget _buildCobLedCctCard(CobLedCctDevice cct, HomeController homeCtl) {
    final state = homeCtl.cctStateFor(cct.id);
    final isOn = state?.isOn ?? false;
    final brightness = state?.brightness ?? 200;
    return CobLedCctCard(
      device: cct,
      isOn: isOn,
      brightness: brightness,
      onTap: () => widget.onOpenCobLedCct(cct.id),
      onToggle: () => homeCtl.toggleCobLedCct(cct),
      onBrightnessDrag: (v) => homeCtl.setCobLedCctBrightness(cct, v),
      onSpeedDown: () => homeCtl.stepCobLedCctSpeed(cct, up: false),
      onSpeedUp: () => homeCtl.stepCobLedCctSpeed(cct, up: true),
    );
  }
}

// ---------------------------------------------------------------------------
// Room chip row
// ---------------------------------------------------------------------------

class _RoomChips extends StatelessWidget {
  const _RoomChips({
    required this.rooms,
    required this.selectedRoomId,
    required this.homeCtl,
    required this.onSelect,
  });

  final List<Room> rooms;
  final String? selectedRoomId;
  final HomeController homeCtl;
  final void Function(String? roomId) onSelect;

  @override
  Widget build(BuildContext context) {
    final totalCount = rooms.fold(
      0,
      (sum, r) => sum + homeCtl.deviceCountForRoom(r.id),
    );

    final chips = <Widget>[
      AppChip(
        label: context.l10n.areasAllRooms(totalCount),
        selected: selectedRoomId == null,
        variant: AppChipVariant.outlined,
        onTap: () => onSelect(null),
      ),
      ...rooms.map((r) {
        final count = homeCtl.deviceCountForRoom(r.id);
        return AppChip(
          label: context.l10n.areasRoomItem(r.name, count),
          selected: selectedRoomId == r.id,
          variant: AppChipVariant.outlined,
          onTap: () => onSelect(r.id),
        );
      }),
    ];

    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => AppSpacing.gapHMd,
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }
}
