// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.document;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/expression.dart';
import 'package:toml/src/ast/node.dart';
import 'package:toml/src/decoder/map_builder.dart';
import 'package:toml/src/parser/util/whitespace.dart';

/// Abstract syntax tree for a TOML document.
///
///     toml = expression *( newline expression )
class TomlDocument extends TomlNode {
  /// Parser for TOML documents.
  ///
  /// If an `expression` is just a blank line or comment,
  /// [TomlExpression.parser] returns `null`. These expressions
  /// are not part of the AST and must be filtered out.
  static final Parser<TomlDocument> parser = TomlExpression.parser
      .separatedBy<TomlExpression>(tomlNewline, includeSeparators: false)
      .map((expressions) =>
          TomlDocument(expressions.where((expression) => expression != null)));

  /// Parses the given TOML document.
  ///
  /// Throws a [ParserException] if there is a syntax error.
  static TomlDocument parse(String input) => parser.end().parse(input).value;

  /// The table headers and key/value pairs of the TOML document.
  final List<TomlExpression> expressions;

  /// Creates a TOML document with the given expressions.
  TomlDocument(Iterable<TomlExpression> expressions)
      : expressions = List.from(expressions, growable: false);

  /// Converts this document to a map from keys to values.
  Map<String, dynamic> toMap() {
    var builder = TomlMapBuilder();
    expressions.forEach(builder.visitExpression);
    return builder.build();
  }
}
