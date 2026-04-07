import '../../core/utils/validators.dart';

/// Value object ensuring a syntactically valid IPv4 address.
///
/// Prevents raw user-input strings from flowing unchecked into
/// network clients and URL constructors.
class IpAddress {
  final String value;

  /// Creates an [IpAddress] after validation. Throws [FormatException]
  /// if [raw] is not a valid IPv4 string.
  factory IpAddress(String raw) {
    final trimmed = raw.trim();
    if (!Validators.isValidIpv4(trimmed)) {
      throw FormatException('Invalid IPv4 address: "$raw"');
    }
    return IpAddress._(trimmed);
  }

  /// Creates an [IpAddress] without validation. Use only for values
  /// already known to be valid (e.g. loaded from verified storage).
  const IpAddress.trusted(this.value);

  const IpAddress._(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is IpAddress && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
