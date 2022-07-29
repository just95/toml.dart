library toml.src.exception.invalid_int;

import 'package:meta/meta.dart';

import '../ast.dart';
import 'base.dart';

/// An exception which is thrown when a [TomlInteger] is converted to an [int]
/// but cannot be represented losslessly.
///
/// Example:
///
///     very-big-number = 100000000000000000000000
///
/// throws a [TomlInvalidIntException] because `very-big-number` cannot
/// be represented as an [int] without loss of precision.
@immutable
class TomlInvalidIntException extends TomlException {
  /// An accessor for the integer that cannot be represented as an [int]
  /// without loss of precision.
  final TomlInteger integer;

  /// Creates a new exception for the given integer.
  TomlInvalidIntException(this.integer);

  @override
  bool operator ==(Object other) =>
      other is TomlInvalidIntException && integer == other.integer;

  @override
  int get hashCode => integer.hashCode;

  @override
  String get message =>
      'Cannot convert `$integer` to an `int` without loss of precision!';
}
