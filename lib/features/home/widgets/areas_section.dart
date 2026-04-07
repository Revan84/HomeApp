import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/i18n/loc.dart';

import '../../live/controllers/live_polling_controller.dart';

import '../../../domain/entities/room.dart';

import '../controllers/home_controller.dart';
import 'area_card.dart';

class AreasSection extends StatefulWidget {
  const AreasSection({
    super.key,
    required this.rooms,
    required this.onOpenEquipment,
  });

  final List<Room> rooms;
  final void Function(String equipmentId) onOpenEquipment;

  @override
  State<AreasSection> createState() => _AreasSectionState();
}

class _AreasSectionState extends State<AreasSection> {
  bool _expanded = false;

  String _dash(BuildContext context, String? v) =>
      (v == null || v.isEmpty) ? context.l10n.valueUnknown : v;

  String _onOffLabel(BuildContext context, bool? on) {
    if (on == null) return context.l10n.valueUnknown;
    return on ? context.l10n.valueOn : context.l10n.valueOff;
  }

  @override
  Widget build(BuildContext context) {
    final liveCtl = context.watch<LivePollingController>();
    final homeCtl = context.watch<HomeController>();

    final rooms = widget.rooms;
    final hasToggle = rooms.length > 2;

    final visibleRooms = (!hasToggle || _expanded) ? rooms : rooms.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (rooms.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(context.l10n.noRoomsYet),
          )
        else ...[
          ...visibleRooms.map((r) {
            final plugs = homeCtl.plugsForRoom(r.id);

            final items = plugs.map((e) {
              final st = liveCtl.live[e.id];
              final on = st?.output;

              final value = e.showPower
                  ? (st?.powerW == null
                      ? context.l10n.valueUnknown
                      : '${st!.powerW!.toStringAsFixed(0)} W')
                  : _onOffLabel(context, on);

              return AreaDeviceItem(
                id: e.id,
                label: e.name,
                value: value,
                isOn: on,
              );
            }).toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AreaCard(
                title: _dash(context, r.name),
                devices: items,
                onDeviceTap: (deviceId) => widget.onOpenEquipment(deviceId),
              ),
            );
          }),

          if (hasToggle) ...[
            const SizedBox(height: 14),
            Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(
                    color: AppColors.stroke.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? context.l10n.seeLess : context.l10n.seeAll,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
