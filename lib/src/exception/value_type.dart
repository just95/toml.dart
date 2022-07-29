library toml.src.exception.accessor_type;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../accessor.dart';
import '../ast.dart';
import 'base.dart';

/// An exception which is thrown when the wrong type of value is excepted.
///
/// Example:
///
///     [a]
///     b = 1
///
///     [a.b.c]
///     d = 2
///
/// throws a [TomlValueTypeException] because `a.b.c` fails to create a
/// sub-table of `a.b` which is an integer rather than a table. The
/// [expectType] is [TomlValueType.table] in this case but the
/// [actualType] is [TomlValueType.integer].
@immutable
class TomlValueTypeException extends TomlException {
  /// The name of the node which was expected to be of a different type.
  final TomlAccessorKey name;

  /// A set of types the value was expected to have one of.
  final Set<TomlValueType> expectedTypes;

  /// The type the value actually has.
  final TomlValueType actualType;

  /// Creates a new exception for a table with the given [name].
  TomlValueTypeException(
    this.name, {
    required this.expectedTypes,
    required this.actualType,
  });

  @override
  bool operator ==(Object other) =>
      other is TomlValueTypeException &&
      ListEquality().equals(name.parts.toList(), other.name.parts.toList()) &&
      SetEquality().equals(expectedTypes, other.expectedTypes) &&
      actualType == other.actualType;

  @override
  int get hashCode =>
      Object.hashAll([...expectedTypes, actualType, ...name.parts]);

  @override
  String get message {
    var expectedTypeDescriptions = expectedTypes.map((t) => t.description);
    return 'Expected `$name` to be ${expectedTypeDescriptions.join(' or ')},'
        ' but it is defined as ${actualType.description}.';
  }
}
