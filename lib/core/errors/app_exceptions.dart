/// Base exception for all domain-level failures.
sealed class AppException implements Exception {
  final String message;
  final Object? cause;

  const AppException(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message';
}

/// A network or connectivity failure occurred.
class NetworkException extends AppException {
  const NetworkException(super.message, [super.cause]);
}

/// Data could not be parsed or is structurally invalid.
class DataParsingException extends AppException {
  const DataParsingException(super.message, [super.cause]);
}

/// A persistence operation (read/write) failed.
class StorageException extends AppException {
  const StorageException(super.message, [super.cause]);
}

/// A device did not respond or returned an error status.
class DeviceUnreachableException extends AppException {
  const DeviceUnreachableException(super.message, [super.cause]);
}

/// An operation was attempted on an entity that does not exist.
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.cause]);
}
