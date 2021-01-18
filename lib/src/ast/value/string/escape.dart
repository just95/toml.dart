library toml.src.parser.escape;

import 'package:petitparser/petitparser.dart';
import 'package:quiver/collection.dart';
import 'package:toml/src/decoder/exception/invalid_escape_sequence.dart';
import 'package:toml/src/decoder/parser/util/ranges.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';

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
  /// This parser accepts any non-whitespace and non-newline character and
  /// throws a [TomlInvalidEscapeSequenceException] if the parsed character
  /// is not escapable.
  static final Parser<String> escapedCharParser =
      (tomlNewline | tomlWhitespaceChar).neg().map((shortcut) {
    if (!escapableChars.containsKey(shortcut)) {
      throw TomlInvalidEscapeSequenceException('\\$shortcut');
    }
    return String.fromCharCode(escapableChars[shortcut]);
  });

  /// Parser for unicode escape sequences.
  ///
  ///     escape-seq-char =/ %x75 4HEXDIG ; uXXXX                U+XXXX
  ///     escape-seq-char =/ %x55 8HEXDIG ; UXXXXXXXX            U+XXXXXXXX
  static final Parser<String> escapedUnicodeParser =
      (char('u') & hexDigit().times(4).flatten() |
              char('U') & hexDigit().times(8).flatten())
          .cast<List>()
          .pick<String>(1)
          .map((charCodeStr) {
    // Test whether the code point is a scalar Unicode value.
    var charCode = int.parse(charCodeStr, radix: 16);
    if (0x0000 <= charCode && charCode <= 0xD7FF ||
        0xE000 <= charCode && charCode <= 0x10FFFF) {
      return String.fromCharCode(charCode);
    }
    throw TomlInvalidEscapeSequenceException(
      charCodeStr.length == 4 ? '\\u$charCodeStr' : '\\U$charCodeStr',
    );
  });

  /// Writes the given [rune] into the [buffer] and escapes it if necessary.
  ///
  /// The [unescapedParser] is a parser that accepts all strings that don't
  /// have to be encoded.
  static void writeEscapedChar(
    int rune,
    StringBuffer buffer,
    Parser unescapedParser,
  ) {
    if (unescapedParser.accept(String.fromCharCode(rune))) {
      // The current rune can be encoded unescaped.
      buffer.writeCharCode(rune);
    } else if (escapableChars.inverse.containsKey(rune)) {
      // The current rune must be escaped and there is a shortcut.
      buffer.write(escapeChar);
      buffer.write(escapableChars.inverse[rune]);
    } else {
      // The current rune must be escaped but there is no shortcut, i.e., the
      // Unicode code point must be escaped.
      var length = rune & 0xffff == rune ? 4 : 8;
      buffer.write(escapeChar);
      buffer.write(length == 4 ? r'u' : r'U');
      buffer.write(rune.toRadixString(16).padLeft(length, '0'));
    }
  }
}
