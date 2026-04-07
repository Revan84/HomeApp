/// Centralized unique ID generation.
///
/// Avoids scattered DateTime-based ID creation throughout the codebase.
/// Uses microsecond timestamps by default; can be overridden for testing.
abstract class IdGenerator {
  String generate();
}

class TimestampIdGenerator implements IdGenerator {
  const TimestampIdGenerator();

  @override
  String generate() => DateTime.now().microsecondsSinceEpoch.toString();
}
