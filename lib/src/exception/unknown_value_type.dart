library toml.src.exception.unknown_value_type;

import 'package:meta/meta.dart';

import 'base.dart';

/// An error which is thrown when an object cannot be encoded as a value.
///
/// Example:
///
///     var encoder = new TomlEncoder();
///     encoder.encode({'a': null});
///
/// throws an [TomlUnknownValueTypeException] because `null` is not a valid
/// TOML value.
@immutable
class TomlUnknownValueTypeException extends TomlException {
  /// The object which cannot be encoded as a TOML value.
  final dynamic value;

  /// Creates a new exception for the given [value].
  TomlUnknownValueTypeException(this.value);

  @override
  bool operator ==(Object other) =>
      other is TomlUnknownValueTypeException && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String get message => '`$value` cannot be encoded as a TOML value!';
}
