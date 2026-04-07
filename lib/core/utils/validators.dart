/// Reusable input validators for forms and data boundaries.
abstract final class Validators {
  /// IPv4 format: four octets 0-255 separated by dots.
  static final _ipv4Pattern = RegExp(
    r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
  );

  /// Returns `true` when [value] is a syntactically valid IPv4 address.
  static bool isValidIpv4(String value) => _ipv4Pattern.hasMatch(value.trim());

  /// Returns a validation error message or `null` if the IP is valid.
  /// Designed for use as a `TextFormField.validator`.
  static String? validateIpv4(String? value, {String? errorMessage}) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'IP address is required';
    }
    if (!isValidIpv4(value)) {
      return errorMessage ?? 'Invalid IPv4 address';
    }
    return null;
  }

  /// Returns `true` when [value] is non-null and not blank.
  static bool isNotBlank(String? value) =>
      value != null && value.trim().isNotEmpty;
}
