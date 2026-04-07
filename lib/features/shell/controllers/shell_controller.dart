import 'package:flutter/foundation.dart';

import '../../../domain/entities/room_group.dart';
import '../../../domain/repositories/room_group_repository.dart';

/// Manages app-shell level state: room groups, selected group, navigation.
class ShellController extends ChangeNotifier {
  final RoomGroupRepository _roomGroupRepo;

  ShellController({required RoomGroupRepository roomGroupRepo})
      : _roomGroupRepo = roomGroupRepo;

  List<RoomGroup> _roomGroups = const [];
  List<RoomGroup> get roomGroups => _roomGroups;

  String? _selectedGroupId;
  String? get selectedGroupId => _selectedGroupId;

  String? _error;
  String? get error => _error;

  set selectedGroupId(String? id) {
    if (_selectedGroupId == id) return;
    _selectedGroupId = id;
    notifyListeners();
  }

  /// Loads room groups and validates the selected group ID.
  Future<void> loadRoomGroups() async {
    _error = null;

    try {
      final groups = await _roomGroupRepo.loadAll();

      final sorted = [...groups]..sort((a, b) {
          final s = a.sortOrder.compareTo(b.sortOrder);
          return s != 0 ? s : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

      _roomGroups = sorted;

      if (!sorted.any((g) => g.id == _selectedGroupId)) {
        _selectedGroupId = sorted.isNotEmpty ? sorted.first.id : null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Returns the label for the active room group.
  String activeRoomGroupLabel(String fallback) {
    if (_selectedGroupId == null) return fallback;
    final group =
        _roomGroups.where((g) => g.id == _selectedGroupId).firstOrNull;
    return group?.name ?? fallback;
  }
}
