// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.table;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/expression/key_value_pair.dart';
import 'package:toml/src/ast/key.dart';
import 'package:toml/src/ast/value.dart';
import 'package:toml/src/ast/value/visitor.dart';
import 'package:toml/src/decoder/map_builder.dart';
import 'package:toml/src/parser/util/whitespace.dart';

/// AST node that represents a TOML inline table.
///
///     inline-table =
///         inline-table-open [ inline-table-keyvals ] inline-table-close
///
///     inline-table-open  = %x7B ws     ; {
///     inline-table-close = ws %x7D     ; }
///     inline-table-sep   = ws %x2C ws  ; , Comma
///
///     inline-table-keyvals = keyval [ inline-table-sep inline-table-keyvals ]
class TomlInlineTable extends TomlValue<Map<String, dynamic>> {
  /// Parser for a TOML inline-table.
  ///
  /// Trailing commas are currently not allowed.
  /// See https://github.com/toml-lang/toml/pull/235#issuecomment-73578529
  static final Parser<TomlInlineTable> parser = (char('{') &
          tomlWhitespace &
          (TomlKeyValuePair.parser.separatedBy<TomlKeyValuePair>(
            tomlWhitespace & char(',') & tomlWhitespace,
            includeSeparators: false,
            optionalSeparatorAtEnd: false,
          )).optional(<TomlKeyValuePair>[]) &
          tomlWhitespace &
          char('}'))
      .pick<List<TomlKeyValuePair>>(2)
      .map((List<TomlKeyValuePair> pairs) => TomlInlineTable(pairs));

  /// The key/value pairs of the inline table.
  final List<TomlKeyValuePair> pairs;

  /// Creates a new inline table.
  TomlInlineTable(Iterable<TomlKeyValuePair> pairs)
      : pairs = List.from(pairs, growable: false);

  @override
  Map<String, dynamic> get value => buildValue(TomlKey.topLevel);

  @override
  Map<String, dynamic> buildValue(TomlKey key) {
    var builder = TomlMapBuilder.withPrefix(key);
    pairs.forEach(builder.visitExpression);
    return builder.build();
  }

  @override
  TomlType get type => TomlType.table;

  @override
  T accept<T>(TomlValueVisitor<T> visitor) => visitor.visitInlineTable(this);
}
