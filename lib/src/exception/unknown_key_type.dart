library toml.src.exception.unknown_key_type;

import 'package:meta/meta.dart';

import 'base.dart';

/// An error which is thrown when an object cannot be encoded as a key.
///
/// Only `String`s are allowed as keys by TOML. All other objects that are
/// used as keys in hash maps must implement the `TomlEncodableKey` interface.
///
/// Example:
///
///     var encoder = new TomlEncoder();
///     encoder.encode({42: 'Answer to the Ultimate Question'});
///
/// throws an [TomlUnknownKeyTypeException] because integers cannot be used as
/// a key in TOML.
@immutable
class TomlUnknownKeyTypeException extends TomlException {
  /// The object which cannot be encoded as a TOML value.
  final dynamic value;

  /// Creates a new exception for the given [value].
  TomlUnknownKeyTypeException(this.value);

  @override
  bool operator ==(Object other) =>
      other is TomlUnknownKeyTypeException && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String get message => '`$value` cannot be encoded as a TOML key!';
}
