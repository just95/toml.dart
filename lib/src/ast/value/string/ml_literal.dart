// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.string.ml_literal;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/value/string.dart';

/// AST node that represents multiline literal TOML strings.
///
///     ml-literal-string =
///         ml-literal-string-delim ml-literal-body ml-literal-string-delim
///     ml-literal-string-delim = 3apostrophe
///     ml-literal-body =
///         *mll-content *( mll-quotes 1*mll-content ) [ mll-quotes ]
///
///     mll-content = mll-char / newline
///     mll-char = %x09 / %x20-26 / %x28-7E / non-ascii
///     mll-quotes = 1*2apostrophe
abstract class TomlMultilineLiteralString extends TomlString {
  /// Parser for a TOML string value.
  static final Parser<TomlMultilineLiteralString> parser =
      failure('not yet implemented');
}
