// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.decoder.error.not_a_table;

/// An error which is thrown when the parent element of a table is not
/// a table.
///
/// Example:
///
///     [a]
///     b = 1
///
///     [a.b.c]
///     d = 2
///
/// throws a [NotATableError] because `a.b.c` fails to create a sub-table of
/// `a.b` which is an integer rather than a table.
class NotATableError {
  /// The name of the table which could not be created because its parent
  /// is not a table
  final String name;

  NotATableError(this.name);

  @override
  bool operator ==(other) => other is NotATableError && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Cannot define table "$name"! Parent must be a table!';
}
