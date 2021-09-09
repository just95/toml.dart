library toml.src.exception.redefinition;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../accessor.dart';
import 'base.dart';

/// An exception which is thrown when a table or key is defined more than once.
///
/// Example:
///
///     a = 1
///     a = 2
///
/// throws a [TomlRedefinitionException] because `a` is defined twice.
@immutable
class TomlRedefinitionException extends TomlException {
  /// Fully qualified name of the redefined node.
  final TomlAccessorKey name;

  /// Creates a new exception for the node identified by the given name.
  TomlRedefinitionException(this.name);

  @override
  bool operator ==(Object other) =>
      other is TomlRedefinitionException &&
      ListEquality().equals(name.parts.toList(), other.name.parts.toList());

  @override
  int get hashCode => Object.hashAll(name.parts);

  @override
  String get message => 'Cannot redefine `$name`!';
}
