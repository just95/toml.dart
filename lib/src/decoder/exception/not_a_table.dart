import 'package:meta/meta.dart';

import '../../ast.dart';
import '../../exception.dart';

/// An exception which is thrown when the parent element of a table is not
/// a table or array of tables.
///
/// Example:
///
///     [a]
///     b = 1
///
///     [a.b.c]
///     d = 2
///
/// throws a [TomlNotATableException] because `a.b.c` fails to create a
/// sub-table of `a.b` which is an integer rather than a table.
@immutable
class TomlNotATableException extends TomlException {
  /// The name of the table which could not be created because its parent
  /// is not a table.
  final TomlKey name;

  /// Creates a new exception for a table with the given [name].
  TomlNotATableException(this.name);

  @override
  bool operator ==(Object other) =>
      other is TomlNotATableException && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String get message => 'Cannot define table "$name"! Parent must be a table!';
}
