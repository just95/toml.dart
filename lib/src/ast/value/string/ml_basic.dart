// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.string.ml_basic;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/value/string.dart';
import 'package:toml/src/ast/value/string/basic.dart';
import 'package:toml/src/ast/value/string/escape.dart';
import 'package:toml/src/parser/util/join.dart';
import 'package:toml/src/parser/util/ranges.dart';
import 'package:toml/src/parser/util/whitespace.dart';

/// AST node that represents multiline basic TOML strings.
///
///     ml-basic-string =
///         ml-basic-string-delim ml-basic-body ml-basic-string-delim
class TomlMultilineBasicString extends TomlString {
  /// Delimiter for multiline basic TOML strings.
  ///
  ///     ml-basic-string-delim = 3quotation-mark
  static final String delimiter = TomlBasicString.delimiter * 3;

  /// Parser for a multiline basic TOML string value.
  static final Parser<TomlMultilineBasicString> parser = (string(delimiter) &
          tomlNewline.optional() &
          bodyParser &
          string(delimiter))
      .pick<String>(2)
      .map((body) => TomlMultilineBasicString(body));

  /// Parser for the body of a multiline basic TOML string.
  ///
  ///     ml-basic-body =
  ///       *mlb-content *( mlb-quotes 1*mlb-content ) [ mlb-quotes ]
  static final Parser<String> bodyParser = (charParser.star().join() &
          (quotesParser & charParser.plus().join()).join().star().join() &
          quotesParser.optional(''))
      .castList<String>()
      .join();

  /// Parser for one or two quotation marks.
  ///
  /// The body of a multiline basic string can contain up to two double
  /// quotes since they do not form a valid [delimiter]. Additional double
  /// quotes have to be escaped.
  ///
  ///     mlb-quotes = 1*2quotation-mark
  static final Parser<String> quotesParser = char(TomlBasicString.delimiter)
      .repeatLazy(char(TomlBasicString.delimiter).not(), 1, 2)
      .join();

  /// Parser for a single character of a multiline basic TOML string.
  ///
  ///     mlb-content = mlb-char / newline / mlb-escaped-nl
  ///     mlb-char = mlb-unescaped / escaped
  static final Parser<String> charParser = (unescapedParser |
          TomlEscapedChar.parser |
          tomlNewline |
          escapedNewlineParser)
      .cast<String>();

  /// Parser for a single unescaped character of a multiline basic TOML string.
  ///
  ///     mlb-unescaped = wschar / %x21 / %x23-5B / %x5D-7E / non-ascii
  ///
  ///  This range excludes `%x22` which is the `quotation-mark` character `"`
  ///  and `%x5C` which is the `escape` character `\`.
  static final Parser<String> unescapedParser = (tomlWhitespaceChar |
          char(0x21) |
          range(0x23, 0x5B) |
          range(0x5D, 0x7E) |
          tomlNonAscii)
      .flatten();

  /// Parser for an escaped newline.
  ///
  ///     mlb-escaped-nl = escape ws newline *( wschar / newline )
  static final Parser<String> escapedNewlineParser =
      (TomlEscapedChar.escapedCharParser &
              tomlWhitespace &
              tomlNewline &
              (tomlWhitespaceChar | tomlNewline).star())
          .map((_) => '');

  /// Escapes all characters of the given string that are not allowed to
  /// occur unescaped in a multiline basic string.
  static String escape(String value) {
    var buffer = StringBuffer();
    var unescapedOrNewline = unescapedParser | tomlNewline;
    var quotes = 0;
    for (var rune in value.runes) {
      // If the current rune is a quotation mark and it is preceeded by less
      // than two quotation marks, it does not have to be escaped, because only
      // three or more quotation marks can be confused for a closing delimiter.
      if (rune == TomlBasicString.delimiter.runes.first && quotes < 2) {
        buffer.writeCharCode(rune);
        quotes++;
      } else {
        TomlEscapedChar.writeEscapedChar(rune, buffer, unescapedOrNewline);
        quotes = 0;
      }
    }
    return buffer.toString();
  }

  @override
  final String value;

  /// Creates a new multiline basic TOML string value with the given contents.
  TomlMultilineBasicString(this.value);
}
