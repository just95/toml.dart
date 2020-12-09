// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.decoder.exception.redefinition;

import 'package:toml/src/ast.dart';
import 'package:toml/src/exception.dart';

/// An exception which is thrown when a table or key is defined more than once.
///
/// Example:
///
///     a = 1
///     a = 2
///
/// throws a [RedefinitionException] because `a` is defined twice.
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
