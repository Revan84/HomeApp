import '../entities/connected_camera_device.dart';

/// Repository interface for persisting and retrieving [ConnectedCameraDevice] records.
abstract interface class ConnectedCameraRepository {
  Future<List<ConnectedCameraDevice>> loadAll();
  Future<void> add(ConnectedCameraDevice device);
  Future<void> update(ConnectedCameraDevice device);
  Future<void> deleteById(String id);
  Future<ConnectedCameraDevice?> loadById(String id);
}
