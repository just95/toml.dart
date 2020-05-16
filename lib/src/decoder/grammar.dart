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

  @override
  Parser start() => ref(document).end();

  // -----------------------------------------------------------------
  // Tokens.
  // -----------------------------------------------------------------

  /// Parses the specified string ignoring whitespace on either side.
  ///
  /// Optionally allows newlines on the [left], [right] or [both] sides.
  Parser token(String str, {bool both: false, bool left, bool right}) =>
      string(str).trim(ref(ignore, left ?? both), ref(ignore, right ?? both));

  // -----------------------------------------------------------------
  // Whitespace and comments.
  // -----------------------------------------------------------------

  /// Ignores whitespace and comments.
  ///
  /// Optionally ignores newlines if [multiLine] is set to `true`.
  Parser ignore([bool multiLine = false]) =>
      multiLine ? ref(ignore) | ref(newline) : ref(whitespace) | ref(comment);

  /// Whitespace means tab (0x09) or space (0x20).
  Parser whitespace() => char(' ') | char('\t');

  /// Newline means LF (0x0A) or CRLF (0x0D0A).
  Parser newline() => char('\n') | char('\r') & char('\n');

  /// A hash symbol marks the rest of the line as a comment.
  Parser comment() => char('#') & ref(newline).neg().star();

  // -----------------------------------------------------------------
  // Values.
  // -----------------------------------------------------------------

  /// A TOML value.
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

  /// A string value.
  Parser str() =>
      ref(multiLineBasicStr) |
      ref(basicStr) |
      ref(multiLineLiteralStr) |
      ref(literalStr);

  /// Creates a parser for the contents of a string.
  ///
  /// The string is not allowed to contain [quotes].
  /// Only [literal] strings are allowed to contain a backslash character.
  /// Only [multiLine] strings are allowed to contain newlines.
  Parser strData(Parser quotes, {bool literal: false, bool multiLine: false}) {
    var forbidden = quotes;
    if (!literal) forbidden |= char('\\');
    if (!multiLine) forbidden |= ref(newline);
    return forbidden.neg().plus();
  }

  /// Creates a parser for a string delimited by a set of the
  /// specified [quotes].
  ///
  /// [esc] is a parser for the allowed escape sequences.
  /// [multiLine] strings are allowed to contain newline characters and
  /// may start with a blank line that is ignored.
  Parser strParser(Parser quotes, {Parser esc, bool multiLine: false}) {
    var data = strData(quotes, literal: esc == null, multiLine: multiLine);
    if (esc != null) data = esc | data;
    var first = multiLine ? ref(blankLine).optional() : epsilon(null);
    return quotes & first & data.star() & quotes;
  }

  // -----------------------------------------------------------------
  // Basic strings.
  // -----------------------------------------------------------------

  /// Creates a parser for a basic string.
  Parser basicStr() => strParser(string('"'), esc: ref(escSeq));

  /// Creates a parser for a multi-line basic string.
  Parser multiLineBasicStr() =>
      strParser(string('"""'), esc: ref(multiLineEscSeq), multiLine: true);

  // -----------------------------------------------------------------
  // Literal strings.
  // -----------------------------------------------------------------

  /// Creates a parser for a literal string.
  Parser literalStr() => strParser(string("'"));

  /// Creates a parser for a multi-line literal string.
  Parser multiLineLiteralStr() => strParser(string("'''"), multiLine: true);

  // -----------------------------------------------------------------
  // Escape Sequences.
  // -----------------------------------------------------------------

  /// Escape sequences that are allowed in basic strings.
  Parser escSeq() => char('\\') & (ref(unicodeEscSeq) | ref(compactEscSeq));

  /// An escape sequence for a unicode character (without the leading backslash
  /// character).
  Parser unicodeEscSeq() =>
      char('u') & ref(hexDigit).times(4).flatten() |
      char('U') & ref(hexDigit).times(8).flatten();

  /// A case insensitive hexadecimal digit.
  Parser hexDigit() => pattern('0-9a-fA-F');

  /// An escape sequence that consists of a single character (without the
  /// leading white backslash chracter).
  Parser compactEscSeq() => any();

  /// Escape sequences that are allowed in multi-line basic strings.
  Parser multiLineEscSeq() =>
      char('\\') &
      (ref(whitespaceEscSeq) | ref(unicodeEscSeq) | ref(compactEscSeq));

  /// An escape sequence that trims all remaining white space on the current
  /// and all following lines until the a non-whitespace character is reached.
  Parser whitespaceEscSeq() => ref(blankLine).plus() & ref(whitespace).star();

  /// A blank line is a line that consist of whitespace characters only.
  Parser blankLine() => ref(whitespace).star() & ref(newline);

  // -----------------------------------------------------------------
  // Integer values.
  // -----------------------------------------------------------------

  /// Creates a parser for integer values.
  Parser integer() => ref(integralPart);

  // -----------------------------------------------------------------
  // Float values.
  // -----------------------------------------------------------------

  /// Creates a parser for floating point number.
  ///
  /// Consists of an integral part followed either just a fractional part or
  /// just an exponent part or both.
  Parser float() =>
      ref(integralPart) &
      (ref(fractionalPart) & ref(exponentPart).optional() | ref(exponentPart));

  /// The integral part of a float.
  ///
  /// Starts with an optional sign.
  Parser integralPart() => anyOf('+-').optional() & (char('0') | ref(digits));

  /// The fractional part of a float.
  ///
  /// Starts with a decimal point.
  Parser fractionalPart() => char('.') & ref(digits);

  /// The exponent part of a float.
  ///
  /// An integer part that is preceded by an `e` or `E`.
  Parser exponentPart() => anyOf('eE') & ref(integralPart);

  /// Creates a parser for one or more digits.
  ///
  /// Groups of digits can be separated by underscore characters.
  Parser digits() => digit().plus().separatedBy(char('_'));

  // -----------------------------------------------------------------
  // Boolean values.
  // -----------------------------------------------------------------

  /// Creates a parser for the boolean values `true` and `false`.
  Parser boolean() => string('true') | string('false');

  // -----------------------------------------------------------------
  // Datetime values. (RFC 3339)
  // -----------------------------------------------------------------

  /// Creates a parser for a [RFC 3339](https://tools.ietf.org/html/rfc3339)
  /// datetime.
  Parser datetime() => ref(fullDate) & char('T') & ref(fullTime);

  /// Creates a parser for a full date.
  Parser fullDate() => ref(dddd) & char('-') & ref(dd) & char('-') & ref(dd);

  /// Creates a parser for a time with an offset.
  Parser fullTime() => ref(partialTime) & ref(timeOffset);

  /// Creates a parser for a time without an offset.
  Parser partialTime() =>
      ref(dd) &
      char(':') &
      ref(dd) &
      char(':') &
      ref(dd) &
      (char('.') & digit().repeat(1, 6)).optional();

  /// Creates a parser for a time zone offset.
  Parser timeOffset() => char('Z') | ref(timeNumOffset);

  /// Creates a parser for a numerical time zone offset.
  Parser timeNumOffset() => anyOf('+-') & ref(dd) & char(':') & ref(dd);

  /// Creates a parser for two digits.
  Parser dd() => digit().times(2);

  /// Creates a parser for four digits.
  Parser dddd() => digit().times(4);

  // -----------------------------------------------------------------
  // Arrays.
  // -----------------------------------------------------------------

  /// Creates a parser for an array value.
  Parser array() =>
      arrayOf(ref(datetime)) |
      arrayOf(ref(float)) |
      arrayOf(ref(integer)) |
      arrayOf(ref(boolean)) |
      arrayOf(ref(str)) |
      arrayOf(ref(array)) |
      arrayOf(ref(inlineTable));

  /// Creates a parser for an array value.
  ///
  /// Uses [valueParser] to parse the values of the array.
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

  /// Creates a parser for a table.
  ///
  /// A table consists of a header and a list of key/value pairs.
  Parser table() =>
      ref(tableHeader).trim(ref(ignore, true)) & ref(keyValuePairs);

  /// Creates a parser for the header of a table.
  Parser tableHeader() =>
      token('[', left: true) & ref(keyPath) & token(']', right: true);

  // -----------------------------------------------------------------
  // Array of Tables.
  // -----------------------------------------------------------------

  /// Creates a parser for an entry of an array of tables.
  ///
  /// An entry of an array of tables consists of a header and a list of
  /// key/value pai.rs
  Parser tableArray() =>
      ref(tableArrayHeader).trim(ref(ignore, true)) & ref(keyValuePairs);

  /// Creates a parser for the header of an array of tables.
  Parser tableArrayHeader() =>
      token('[[', left: true) & ref(keyPath) & token(']]', right: true);

  // -----------------------------------------------------------------
  // Inline Tables.
  // -----------------------------------------------------------------

  /// Creates a parser for an inline table.
  Parser inlineTable() =>
      token('{') &
      ref(keyValuePair)
          .separatedBy<Map<String, dynamic>>(token(','),

              /// Trailing commas are currently not allowed.
              /// See https://github.com/toml-lang/toml/pull/235#issuecomment-73578529
              optionalSeparatorAtEnd: false,
              includeSeparators: false)
          .optional(<Map<String, dynamic>>[]) &
      token('}');

  // -----------------------------------------------------------------
  // Keys.
  // -----------------------------------------------------------------

  /// Creates a parser for a bare or quoted key.
  Parser key() => ref(bareKey) | ref(quotedKey);

  /// Creates a parser for a bare key.
  Parser bareKey() => pattern('A-Za-z0-9_-').plus();

  /// Creates a parser for a quoted key..
  Parser quotedKey() => ref(basicStr);

  /// Create a parser for a list of `.` separated keys.
  Parser keyPath() =>
      ref(key).separatedBy<String>(token('.'), includeSeparators: false);

  // -----------------------------------------------------------------
  // Key/value pairs.
  // -----------------------------------------------------------------

  /// Creates a parser for a key/value pair.
  Parser keyValuePair() => ref(key) & token('=') & ref(value);

  /// Creates a parser for a list of key/value pairs.
  ///
  /// The list may be empty.
  /// Every key/value pair starts on a new line.
  Parser keyValuePairs() => ref(keyValuePair)
      .separatedBy<Map<String, dynamic>>(
          ref(ignore).star() & ref(newline) & ref(ignore, true).star(),
          includeSeparators: false,
          optionalSeparatorAtEnd: true)
      .optional(<Map<String, dynamic>>[]);

  // -----------------------------------------------------------------
  // Document.
  // -----------------------------------------------------------------

  /// Creates a parser for a TOML document.
  ///
  /// A TOML document consists of a list of top level kety/value pairs
  /// followdd by tables and array of tables.
  Parser document() =>
      ref(ignore, true).star() &
      ref(keyValuePairs) &
      (ref(table) | ref(tableArray)).star();
}
