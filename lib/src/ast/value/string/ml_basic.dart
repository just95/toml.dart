// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.string.ml_basic;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/value/string.dart';

/// AST node that represents multiline basic TOML strings.
///
///     ml-basic-string =
///         ml-basic-string-delim ml-basic-body ml-basic-string-delim
///     ml-basic-string-delim = 3quotation-mark
///     ml-basic-body = *mlb-content *( mlb-quotes 1*mlb-content ) [ mlb-quotes ]
///
///     mlb-content = mlb-char / newline / mlb-escaped-nl
///     mlb-char = mlb-unescaped / escaped
///     mlb-quotes = 1*2quotation-mark
///     mlb-unescaped = wschar / %x21 / %x23-5B / %x5D-7E / non-ascii
///     mlb-escaped-nl = escape ws newline *( wschar / newline )
abstract class TomlMultilineBasicString extends TomlString {
  /// Parser for a TOML string value.
  static final Parser<TomlMultilineBasicString> parser =
      failure('not yet implemented');
}
