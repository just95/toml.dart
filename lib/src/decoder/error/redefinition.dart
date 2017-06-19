// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.decoder.error.redefinition;

/// An error which is thrown when a table or key is defined more than once.
///
/// Example:
///
///     a = 1
///     a = 2
///
/// throws a [RedefinitionError] because `a` is defined twice.
class RedefinitionError {
  /// Fully qualified name of the table or key.
  final String name;

  RedefinitionError(this.name);

  @override
  bool operator ==(other) => other is RedefinitionError && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Cannot redefine "$name"!';
}
