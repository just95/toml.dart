// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.array;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/key.dart';
import 'package:toml/src/ast/value.dart';
import 'package:toml/src/ast/visitor/value.dart';
import 'package:toml/src/parser/util/whitespace.dart';

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
class TomlArray<V> extends TomlValue<Iterable<V>> {
  /// Parser for a TOML array value.
  ///
  /// The grammar itself does not enforce arrays to be homogeneous.
  /// The requirement of TOML 0.4.0 that value types are not mixed,
  /// is checked by [TomlArray.fromHomogeneous].
  static final Parser<TomlArray> parser = (char('[') &
          (tomlWhitespaceCommentNewline & TomlValue.parser & tomlWhitespace)
              .pick(1)
              .separatedBy<TomlValue>(
                char(','),
                includeSeparators: false,
                optionalSeparatorAtEnd: true,
              )
              .optional(<TomlValue>[]) &
          tomlWhitespaceCommentNewline &
          char(']'))
      .pick<List<TomlValue>>(1)
      .map(fromHomogeneous);

  /// Creates a new array value from the given [items] but throws an
  /// [FormatException] if multiple element types are mixed.
  static TomlArray<V> fromHomogeneous<V>(Iterable<TomlValue<V>> items) {
    var array = TomlArray(items);
    var types = array.itemTypes.toSet();
    if (types.length > 1) {
      throw FormatException(
        'The items of "$array" must all be of the same type! '
        'Got the following item types: ${types.join(', ')}',
      );
    }
    return array;
  }

  /// The array items.
  final List<TomlValue<V>> items;

  /// Creates a new array value.
  TomlArray(Iterable<TomlValue<V>> items)
      : items = List.from(items, growable: false);

  /// Gets the TOML types of the [items].
  Iterable<TomlType> get itemTypes => items.map((item) => item.type);

  @override
  Iterable<V> get value => buildValue(TomlKey.topLevel);

  @override
  Iterable<V> buildValue(TomlKey key) =>
      items.map((item) => item.buildValue(key));

  @override
  TomlType get type => TomlType.array;

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitArray(this);
}
