// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.string.literal;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/value/string.dart';
import 'package:toml/src/parser/util/ranges.dart';

/// AST node that represents literal TOML strings.
///
///     literal-string = apostrophe *literal-char apostrophe
///
///     apostrophe = %x27 ; ' apostrophe
///
///     literal-char = %x09 / %x20-26 / %x28-7E / non-ascii
class TomlLiteralString extends TomlString {
  /// Parser for a TOML string value.
  static final Parser<TomlLiteralString> parser = (() {
    var literalChar = char('\x09') |
        range('\x20', '\x26') |
        range('\x28', '\x7E') |
        tomlNonAscii;
    var literalString = char("'") & literalChar.star().flatten() & char("'");
    return literalString
        .pick<String>(1)
        .map((str) => new TomlLiteralString(str));
  })();

  @override
  final String value;

  /// Creates a new literal string value with the given contents.
  TomlLiteralString(this.value);
}
