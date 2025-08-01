import 'package:meta/meta.dart';

import '../../ast.dart';
import '../../exception.dart';

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
  /// Fully qualified name of the table or key.
  final TomlKey name;

  /// Creates a new exception for the table or key with the given name.
  TomlRedefinitionException(this.name);

  @override
  bool operator ==(Object other) =>
      other is TomlRedefinitionException && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String get message => 'Cannot redefine "$name"!';
}
