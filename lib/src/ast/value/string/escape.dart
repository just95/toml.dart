// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.parser.escape;

import 'package:petitparser/petitparser.dart';
import 'package:quiver/collection.dart';

import 'package:toml/src/parser/util/ranges.dart';

abstract class TomlEscapedChar {
  /// The character that is used to escape other characters.
  ///
  ///     escape = %x5C                   ; \
  static final String escapeChar = '\\';

  // Map between escape characters and the corresponding Unicode code point.
  static final BiMap<String, int> escapableChars = BiMap()
    ..addAll({
      'b': 0x08, // Backspace.
      't': 0x09, // Tab.
      'n': 0x0A, // Linefeed.
      'f': 0x0C, // Form feed.
      'r': 0x0D, // Carriage return.
      '"': 0x22, // Quote.
      r'\': 0x5C // Backslash.
    });

  /// Parser for escaped characters.
  ///
  ///     escaped = escape escape-seq-char
  static final Parser<String> parser =
      (char(escapeChar) & (escapedUnicodeParser | escapedCharParser))
          .pick<String>(1);

  /// Parser for escaped characters with shorthand notation.
  ///
  ///     escape-seq-char =  %x22         ; "    quotation mark  U+0022
  ///     escape-seq-char =/ %x5C         ; \    reverse solidus U+005C
  ///     escape-seq-char =/ %x62         ; b    backspace       U+0008
  ///     escape-seq-char =/ %x66         ; f    form feed       U+000C
  ///     escape-seq-char =/ %x6E         ; n    line feed       U+000A
  ///     escape-seq-char =/ %x72         ; r    carriage return U+000D
  ///     escape-seq-char =/ %x74         ; t    tab             U+0009
  ///
  /// This parser accepts any character and throws a 'FormatException' if the
  /// parsed character is not escapable.
  static final Parser<String> escapedCharParser = anyOf(
          escapableChars.keys.join(),
          'escapable character (i.e., any of ' +
              escapableChars.keys.join(', ') +
              ') expected')
      .map((shortcut) => String.fromCharCode(escapableChars[shortcut]));

  /// Parser for unicode escape sequences.
  ///
  ///     escape-seq-char =/ %x75 4HEXDIG ; uXXXX                U+XXXX
  ///     escape-seq-char =/ %x55 8HEXDIG ; UXXXXXXXX            U+XXXXXXXX
  static final Parser<String> escapedUnicodeParser = (char('u') &
              hexDigit().times(4).flatten() |
          char('U') & hexDigit().times(8).flatten())
      .pick<String>(1)
      .map((charCode) => String.fromCharCode(int.parse(charCode, radix: 16)));
}
