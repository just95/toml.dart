// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

part of toml.decoder;

/// The grammar definition of TOML.
class TomlGrammar extends GrammarDefinition {
  /// Specified escape sequences.
  ///
  /// Additionally any Unicode character may be escaped with the `\uXXXX`
  /// and `\UXXXXXXXX` forms.
  static final BiMap<String, int> escTable = BiMap()
    ..addAll({
      'b': 0x08, // Backspace.
      't': 0x09, // Tab.
      'n': 0x0A, // Linefeed.
      'f': 0x0C, // Form feed.
      'r': 0x0D, // Carriage return.
      '"': 0x22, // Quote.
      r'\': 0x5C // Backslash.
    });

  start() => ref(document).end();

  // -----------------------------------------------------------------
  // Tokens.
  // -----------------------------------------------------------------

  /// Parses the specified string ignoring whitespace on either side.
  ///
  /// Optionally allows whitespace on the [left], [right] or [both] sides.
  token(String str, {bool both: false, bool left, bool right}) =>
      string(str).trim(ref(ignore, left ?? both), ref(ignore, right ?? both));

  // -----------------------------------------------------------------
  // Whitespace and comments.
  // -----------------------------------------------------------------

  ignore([bool multiLine = false]) =>
      multiLine ? ref(ignore) | ref(newline) : ref(whitespace) | ref(comment);

  whitespace() => char(' ') | char('\t');
  newline() => char('\n') | char('\r') & char('\n');

  comment() => char('#') & ref(newline).neg().star();

  // -----------------------------------------------------------------
  // Values.
  // -----------------------------------------------------------------

  value() =>
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

  str() =>
      ref(multiLineBasicStr) |
      ref(basicStr) |
      ref(multiLineLiteralStr) |
      ref(literalStr);

  strData(String quotes, {bool literal: false, bool multiLine: false}) {
    var forbidden = string(quotes);
    if (!literal) forbidden |= char('\\');
    if (!multiLine) forbidden |= ref(newline);
    return forbidden.neg().plus();
  }

  strParser(String quotes, {Parser esc, bool multiLine: false}) {
    var data = strData(quotes, literal: esc == null, multiLine: multiLine);
    if (esc != null) data = esc | data;
    var first = multiLine ? ref(blankLine).optional() : epsilon();
    return string(quotes) & first & data.star() & string(quotes);
  }

  // -----------------------------------------------------------------
  // Basic strings.
  // -----------------------------------------------------------------

  basicStr() => strParser('"', esc: ref(escSeq));

  multiLineBasicStr() =>
      strParser('"""', esc: ref(multiLineEscSeq), multiLine: true);

  // -----------------------------------------------------------------
  // Literal strings.
  // -----------------------------------------------------------------

  literalStr() => strParser("'");

  multiLineLiteralStr() => strParser("'''", multiLine: true);

  // -----------------------------------------------------------------
  // Escape Sequences.
  // -----------------------------------------------------------------

  escSeq() => char('\\') & (ref(unicodeEscSeq) | ref(compactEscSeq));

  unicodeEscSeq() =>
      char('u') & ref(hexDigit).times(4).flatten() |
      char('U') & ref(hexDigit).times(8).flatten();
  hexDigit() => pattern('0-9a-fA-F');

  compactEscSeq() => any();

  multiLineEscSeq() =>
      char('\\') &
      (ref(whitespaceEscSeq) | ref(unicodeEscSeq) | ref(compactEscSeq));

  whitespaceEscSeq() => ref(blankLine).plus() & ref(whitespace).star();

  blankLine() => ref(whitespace).star() & ref(newline);

  // -----------------------------------------------------------------
  // Integer values.
  // -----------------------------------------------------------------

  integer() => ref(integralPart);

  // -----------------------------------------------------------------
  // Float values.
  // -----------------------------------------------------------------

  float() =>
      ref(integralPart) &
      (ref(fractionalPart) & ref(exponentPart).optional() | ref(exponentPart));

  integralPart() => anyIn('+-').optional() & (char('0') | ref(digits));
  fractionalPart() => char('.') & ref(digits);
  exponentPart() => anyIn('eE') & ref(integralPart);

  digits() => digit().plus().separatedBy(char('_'));

  // -----------------------------------------------------------------
  // Boolean values.
  // -----------------------------------------------------------------

  boolean() => string('true') | string('false');

  // -----------------------------------------------------------------
  // Datetime values. (RFC 3339)
  // -----------------------------------------------------------------

  datetime() => ref(fullDate) & char('T') & ref(fullTime);

  fullDate() => ref(dddd) & char('-') & ref(dd) & char('-') & ref(dd);

  fullTime() => ref(partialTime) & ref(timeOffset);
  partialTime() =>
      ref(dd) &
      char(':') &
      ref(dd) &
      char(':') &
      ref(dd) &
      (char('.') & digit().repeat(1, 6)).optional();

  timeOffset() => char('Z') | ref(timeNumOffset);
  timeNumOffset() => anyIn('+-') & ref(dd) & char(':') & ref(dd);

  dd() => digit().times(2);
  dddd() => digit().times(4);

  // -----------------------------------------------------------------
  // Arrays.
  // -----------------------------------------------------------------

  array() =>
      arrayOf(datetime) |
      arrayOf(float) |
      arrayOf(integer) |
      arrayOf(boolean) |
      arrayOf(str) |
      arrayOf(array) |
      arrayOf(inlineTable);

  arrayOf(v) =>
      token('[', right: true) &
      ref(v)
          .separatedBy(token(',', both: true),
              optionalSeparatorAtEnd: true, includeSeparators: false)
          .optional([]) &
      token(']', left: true);

  // -----------------------------------------------------------------
  // Tables.
  // -----------------------------------------------------------------

  table() => ref(tableHeader).trim(ref(ignore, true)) & ref(keyValuePairs);
  tableHeader() =>
      token('[', left: true) & ref(keyPath) & token(']', right: true);

  // -----------------------------------------------------------------
  // Array of Tables.
  // -----------------------------------------------------------------

  tableArray() =>
      ref(tableArrayHeader).trim(ref(ignore, true)) & ref(keyValuePairs);
  tableArrayHeader() =>
      token('[[', left: true) & ref(keyPath) & token(']]', right: true);

  // -----------------------------------------------------------------
  // Inline Tables.
  // -----------------------------------------------------------------

  inlineTable() =>
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

  key() => ref(bareKey) | ref(quotedKey);

  bareKey() => pattern('A-Za-z0-9_-').plus();
  quotedKey() => ref(basicStr);

  keyPath() => ref(key).separatedBy(token('.'), includeSeparators: false);

  // -----------------------------------------------------------------
  // Key/value pairs.
  // -----------------------------------------------------------------

  keyValuePair() => ref(key) & token('=') & ref(value);
  keyValuePairs() => ref(keyValuePair)
      .separatedBy(ref(ignore).star() & ref(newline) & ref(ignore, true).star(),
          includeSeparators: false, optionalSeparatorAtEnd: true)
      .optional([]);

  // -----------------------------------------------------------------
  // Document.
  // -----------------------------------------------------------------

  document() =>
      ref(ignore, true).star() &
      ref(keyValuePairs) &
      (ref(table) | ref(tableArray)).star();
}
