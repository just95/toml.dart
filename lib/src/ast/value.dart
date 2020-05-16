// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value;

import 'package:toml/src/ast/node.dart';

/// The possible types of [TomlValue]s.
enum TomlType {
  /// The type of a TOML array.
  array,

  /// The type of a boolean value.
  boolean,

  /// The type of a datetime.
  datetime,

  /// The type of a floating point number.
  float,

  /// The type of an integer.
  integer,

  /// The type of all variations of TOML strings.
  string,

  /// The type of an inline table.
  table
}

/// Base class for AST nodes that represent TOML values.
///
///     val = string
///         / boolean
///         / array
///         / inline-table
///         / date-time
///         / float
///         / integer
abstract class TomlValue<V> extends TomlNode {
  /// The Dart value of the TOML value represented by this AST node.
  V get value;

  /// The type of the TOML value represented by this AST node.
  TomlType get type;
}
