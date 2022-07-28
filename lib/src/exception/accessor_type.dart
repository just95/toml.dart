library toml.src.exception.accessor_type;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../accessor.dart';
import 'base.dart';

/// An exception which is thrown when the wrong type of accessor is excepted.
///
/// Example:
///
///     [a]
///     b = 1
///
///     [a.b.c]
///     d = 2
///
/// throws a [TomlAccessorTypeException] because `a.b.c` fails to create a
/// sub-table of `a.b` which is an integer rather than a table. The
/// [expectType] is [TomlAccessorType.table] in this case but the
/// [actualType] is [TomlAccessorType.value].
@immutable
class TomlAccessorTypeException extends TomlException {
  /// The name of the node which was expected to be of a different type.
  final TomlAccessorKey name;

  /// The type the node was expected to have.
  final TomlAccessorType expectedType;

  /// The type the node actually has.
  final TomlAccessorType actualType;

  /// Creates a new exception for a table with the given [name].
  TomlAccessorTypeException(
    this.name, {
    required this.expectedType,
    required this.actualType,
  });

  @override
  bool operator ==(Object other) =>
      other is TomlAccessorTypeException &&
      ListEquality().equals(name.parts.toList(), other.name.parts.toList()) &&
      expectedType == other.expectedType &&
      actualType == other.actualType;

  @override
  int get hashCode => Object.hashAll([expectedType, actualType, ...name.parts]);

  @override
  String get message =>
      'Expected `$name` to be ${_typeToString(expectedType)}, '
      'but it is defined as ${_typeToString(actualType)}.';

  /// Gets the string to use for the given type in the [message].
  String _typeToString(TomlAccessorType type) {
    switch (type) {
      case TomlAccessorType.array:
        return 'an array';
      case TomlAccessorType.table:
        return 'a table';
      case TomlAccessorType.value:
        return 'a primitive value';
    }
  }
}
