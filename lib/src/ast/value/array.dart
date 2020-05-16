// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.array;

import 'package:toml/src/ast/value.dart';

/// AST node that represents a TOML array of values of type [T].
///
///     array = array-open [ array-values ] ws-comment-newline array-close
///
///     array-open =  %x5B ; [
///     array-close = %x5D ; ]
///
///     array-values =  ws-comment-newline val ws array-sep array-values
///     array-values =/ ws-comment-newline val ws [ array-sep ]
///
///     array-sep = %x2C  ; , Comma
///
///     ws-comment-newline = *( wschar / [ comment ] newline )
class TomlArray<T> extends TomlValue<Iterable<T>> {
  /// The array items.
  final List<TomlValue<T>> items;

  /// Creates a new array value.
  TomlArray(Iterable<TomlValue<T>> items)
      : items = List.from(items, growable: false);

  @override
  Iterable<T> get value => items.map((item) => item.value);

  @override
  TomlType get type => TomlType.array;
}
