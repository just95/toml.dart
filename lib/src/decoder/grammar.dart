// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.decoder.grammar;

import 'package:petitparser/petitparser.dart';
import 'package:quiver/collection.dart';

/// The grammar definition of TOML.
class TomlGrammar extends GrammarDefinition {
  /// Specified escape sequences.
  ///
  /// Additionally any Unicode character may be escaped with the `\uXXXX`
  /// and `\UXXXXXXXX` forms.
  static final BiMap<String, int> escTable = new BiMap()
    ..addAll({
      'b': 0x08, // Backspace.
      't': 0x09, // Tab.
      'n': 0x0A, // Linefeed.
      'f': 0x0C, // Form feed.
      'r': 0x0D, // Carriage return.
      '"': 0x22, // Quote.
      r'\': 0x5C // Backslash.
    });

  Parser start() => ref(document).end();

  // -----------------------------------------------------------------
  // Tokens.
  // -----------------------------------------------------------------

  /// Parses the specified string ignoring whitespace on either side.
  ///
  /// Optionally allows whitespace on the [left], [right] or [both] sides.
  Parser token(String str, {bool both: false, bool left, bool right}) =>
      string(str).trim(ref(ignore, left ?? both), ref(ignore, right ?? both));

  // -----------------------------------------------------------------
  // Whitespace and comments.
  // -----------------------------------------------------------------

  Parser ignore([bool multiLine = false]) =>
      multiLine ? ref(ignore) | ref(newline) : ref(whitespace) | ref(comment);

  Parser whitespace() => char(' ') | char('\t');
  Parser newline() => char('\n') | char('\r') & char('\n');

  Parser comment() => char('#') & ref(newline).neg().star();

  // -----------------------------------------------------------------
  // Values.
  // -----------------------------------------------------------------

  Parser value() =>
      ref(datetime) |
      ref(float) |
      ref(integer) |
      ref(boolean) |
      ref(str) |
      ref(array) |
      ref(inlineTable);

  // -----------------------------------------------------------------
  // String values.
  // -----------------------------------------------------------------

  Parser str() =>
      ref(multiLineBasicStr) |
      ref(basicStr) |
      ref(multiLineLiteralStr) |
      ref(literalStr);

  Parser strData(String quotes, {bool literal: false, bool multiLine: false}) {
    var forbidden = string(quotes);
    if (!literal) forbidden |= char('\\');
    if (!multiLine) forbidden |= ref(newline);
    return forbidden.neg().plus();
  }

  Parser strParser(String quotes, {Parser esc, bool multiLine: false}) {
    var data = strData(quotes, literal: esc == null, multiLine: multiLine);
    if (esc != null) data = esc | data;
    var first = multiLine ? ref(blankLine).optional() : epsilon();
    return string(quotes) & first & data.star() & string(quotes);
  }

  // -----------------------------------------------------------------
  // Basic strings.
  // -----------------------------------------------------------------

  Parser basicStr() => strParser('"', esc: ref(escSeq));

  Parser multiLineBasicStr() =>
      strParser('"""', esc: ref(multiLineEscSeq), multiLine: true);

  // -----------------------------------------------------------------
  // Literal strings.
  // -----------------------------------------------------------------

  Parser literalStr() => strParser("'");

  Parser multiLineLiteralStr() => strParser("'''", multiLine: true);

  // -----------------------------------------------------------------
  // Escape Sequences.
  // -----------------------------------------------------------------

  Parser escSeq() => char('\\') & (ref(unicodeEscSeq) | ref(compactEscSeq));

  Parser unicodeEscSeq() =>
      char('u') & ref(hexDigit).times(4).flatten() |
      char('U') & ref(hexDigit).times(8).flatten();
  Parser hexDigit() => pattern('0-9a-fA-F');

  Parser compactEscSeq() => any();

  Parser multiLineEscSeq() =>
      char('\\') &
      (ref(whitespaceEscSeq) | ref(unicodeEscSeq) | ref(compactEscSeq));

  Parser whitespaceEscSeq() => ref(blankLine).plus() & ref(whitespace).star();

  Parser blankLine() => ref(whitespace).star() & ref(newline);

  // -----------------------------------------------------------------
  // Integer values.
  // -----------------------------------------------------------------

  Parser integer() => ref(integralPart);

  // -----------------------------------------------------------------
  // Float values.
  // -----------------------------------------------------------------

  Parser float() =>
      ref(integralPart) &
      (ref(fractionalPart) & ref(exponentPart).optional() | ref(exponentPart));

  Parser integralPart() => anyIn('+-').optional() & (char('0') | ref(digits));
  Parser fractionalPart() => char('.') & ref(digits);
  Parser exponentPart() => anyIn('eE') & ref(integralPart);

  Parser digits() => digit().plus().separatedBy(char('_'));

  // -----------------------------------------------------------------
  // Boolean values.
  // -----------------------------------------------------------------

  Parser boolean() => string('true') | string('false');

  // -----------------------------------------------------------------
  // Datetime values. (RFC 3339)
  // -----------------------------------------------------------------

  Parser datetime() => ref(fullDate) & char('T') & ref(fullTime);

  Parser fullDate() => ref(dddd) & char('-') & ref(dd) & char('-') & ref(dd);

  Parser fullTime() => ref(partialTime) & ref(timeOffset);
  Parser partialTime() =>
      ref(dd) &
      char(':') &
      ref(dd) &
      char(':') &
      ref(dd) &
      (char('.') & digit().repeat(1, 6)).optional();

  Parser timeOffset() => char('Z') | ref(timeNumOffset);
  Parser timeNumOffset() => anyIn('+-') & ref(dd) & char(':') & ref(dd);

  Parser dd() => digit().times(2);
  Parser dddd() => digit().times(4);

  // -----------------------------------------------------------------
  // Arrays.
  // -----------------------------------------------------------------

  Parser array() =>
      arrayOf(ref(datetime)) |
      arrayOf(ref(float)) |
      arrayOf(ref(integer)) |
      arrayOf(ref(boolean)) |
      arrayOf(ref(str)) |
      arrayOf(ref(array)) |
      arrayOf(ref(inlineTable));

  Parser arrayOf(Parser valueParser) =>
      token('[', right: true) &
      valueParser
          .separatedBy(token(',', both: true),
              optionalSeparatorAtEnd: true, includeSeparators: false)
          .optional([]) &
      token(']', left: true);

  // -----------------------------------------------------------------
  // Tables.
  // -----------------------------------------------------------------

  Parser table() =>
      ref(tableHeader).trim(ref(ignore, true)) & ref(keyValuePairs);
  Parser tableHeader() =>
      token('[', left: true) & ref(keyPath) & token(']', right: true);

  // -----------------------------------------------------------------
  // Array of Tables.
  // -----------------------------------------------------------------

  Parser tableArray() =>
      ref(tableArrayHeader).trim(ref(ignore, true)) & ref(keyValuePairs);
  Parser tableArrayHeader() =>
      token('[[', left: true) & ref(keyPath) & token(']]', right: true);

  // -----------------------------------------------------------------
  // Inline Tables.
  // -----------------------------------------------------------------

  Parser inlineTable() =>
      token('{') &
      ref(keyValuePair)
          .separatedBy(token(','),

              /// Trailing commas are currently not allowed.
              /// See https://github.com/toml-lang/toml/pull/235#issuecomment-73578529
              optionalSeparatorAtEnd: false,
              includeSeparators: false)
          .optional([]) &
      token('}');

  // -----------------------------------------------------------------
  // Keys.
  // -----------------------------------------------------------------

  Parser key() => ref(bareKey) | ref(quotedKey);

  Parser bareKey() => pattern('A-Za-z0-9_-').plus();
  Parser quotedKey() => ref(basicStr);

  Parser keyPath() =>
      ref(key).separatedBy(token('.'), includeSeparators: false);

  // -----------------------------------------------------------------
  // Key/value pairs.
  // -----------------------------------------------------------------

  Parser keyValuePair() => ref(key) & token('=') & ref(value);
  Parser keyValuePairs() => ref(keyValuePair)
      .separatedBy(ref(ignore).star() & ref(newline) & ref(ignore, true).star(),
          includeSeparators: false, optionalSeparatorAtEnd: true)
      .optional([]);

  // -----------------------------------------------------------------
  // Document.
  // -----------------------------------------------------------------

  Parser document() =>
      ref(ignore, true).star() &
      ref(keyValuePairs) &
      (ref(table) | ref(tableArray)).star();
}
