library toml.src.exception.base;

/// Base class for all TOML related exceptions.
abstract class TomlException implements Exception {
  /// A human readable description of the error.
  String get message;

  @override
  String toString() => 'TOML exception: $message';
}
