import '../errors/app_exceptions.dart';

/// A lightweight result type to replace raw try/catch at API boundaries.
///
/// Wraps either a success [value] or a typed [AppException].
sealed class Result<T> {
  const Result._();

  /// Creates a successful result.
  const factory Result.ok(T value) = Ok<T>;

  /// Creates a failure result.
  const factory Result.error(AppException error) = Err<T>;

  /// Pattern-matches the result.
  R when<R>({
    required R Function(T value) ok,
    required R Function(AppException error) error,
  });

  /// Returns the value or `null` on failure.
  T? get valueOrNull;

  /// Returns the error or `null` on success.
  AppException? get errorOrNull;

  /// Returns `true` if this is a success.
  bool get isOk;
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value) : super._();

  @override
  R when<R>({
    required R Function(T value) ok,
    required R Function(AppException error) error,
  }) => ok(value);

  @override
  T? get valueOrNull => value;

  @override
  AppException? get errorOrNull => null;

  @override
  bool get isOk => true;
}

final class Err<T> extends Result<T> {
  final AppException error;
  const Err(this.error) : super._();

  @override
  R when<R>({
    required R Function(T value) ok,
    required R Function(AppException error) error,
  }) => error(this.error);

  @override
  T? get valueOrNull => null;

  @override
  AppException? get errorOrNull => error;

  @override
  bool get isOk => false;
}
