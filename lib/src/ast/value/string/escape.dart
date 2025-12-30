import 'package:petitparser/petitparser.dart';

import '../../../decoder/exception/invalid_escape_sequence.dart';
import '../../../decoder/parser/ranges.dart';
import '../../../decoder/parser/whitespace.dart';
import '../../../encoder.dart';

/// Collection of parsers for escape sequences.
abstract class TomlEscapedChar {
  /// The character that is used to escape other characters.
  ///
  ///     escape = %x5C                   ; \
  static final String escapeChar = r'\';

  /// Unicode code point of a line feed.
  static final int backspaceCodePoint = 0x08;

  /// Unicode code point of an escape character.
  static final int escapeCodePoint = 0x1B;

  /// Unicode code point of a line feed.
  static final int formFeedCodePoint = 0x0C;

  /// Unicode code point of a line feed.
  static final int lineFeedCodePoint = 0x0A;

  /// Unicode code point of a carriage return.
  static final int carriageReturnCodePoint = 0x0D;

  /// Unicode code point of a line feed.
  static final int tabCodePoint = 0x09;

  /// Unicode code point of a double quote.
  static final int doubleQuoteCodePoint = 0x22;

  /// Unicode code point of a backslash.
  static final int backslashCodePoint = 0x5C;

  /// Map between escape characters and the corresponding Unicode code point.
  static final Map<String, int> escapableChars = {
    'b': backspaceCodePoint,
    'e': escapeCodePoint,
    'f': formFeedCodePoint,
    'n': lineFeedCodePoint,
    'r': carriageReturnCodePoint,
    't': tabCodePoint,
    '"': doubleQuoteCodePoint,
    r'\': backslashCodePoint,
  };

  /// The inverse mapping to [escapableChars].
  static final Map<int, String> escapableCharsInverse = Map.fromIterables(
    escapableChars.values,
    escapableChars.keys,
  );

  /// Parser for escaped characters.
  ///
  ///     escaped = escape escape-seq-char
  static final Parser<String> parser = _parser.skip(before: char(escapeChar));

  /// Like [parser] but without the [escapeChar].
  static final Parser<String> _parser = ChoiceParser([
    escapedUnicodeParser,
    escapedCharParser,
  ], failureJoiner: selectFarthest);

  /// Parser for escaped characters with shorthand notation.
  ///
  ///     escape-seq-char =  %x22         ; "    quotation mark  U+0022
  ///     escape-seq-char =/ %x5C         ; \    reverse solidus U+005C
  ///     escape-seq-char =/ %x62         ; b    backspace       U+0008
  ///     escape-seq-char =/ %x65         ; e    escape          U+001B
  ///     escape-seq-char =/ %x66         ; f    form feed       U+000C
  ///     escape-seq-char =/ %x6E         ; n    line feed       U+000A
  ///     escape-seq-char =/ %x72         ; r    carriage return U+000D
  ///     escape-seq-char =/ %x74         ; t    tab             U+0009
  ///
  /// This parser accepts any non-whitespace and non-newline character and
  /// throws a [TomlInvalidEscapeSequenceException] if the parsed character
  /// is not escapable.
  static final Parser<String> escapedCharParser =
      ChoiceParser([tomlNewline, tomlWhitespaceChar]).neg().map((shortcut) {
        if (!escapableChars.containsKey(shortcut)) {
          throw TomlInvalidEscapeSequenceException.unspecified("\\$shortcut");
        }
        return String.fromCharCode(escapableChars[shortcut]!);
      });

  /// Parser for Unicode escape sequences.
  ///
  ///     escape-seq-char =/ %x78 2HEXDIG ; xHH                  U+00HH
  ///     escape-seq-char =/ %x75 4HEXDIG ; uXXXX                U+XXXX
  ///     escape-seq-char =/ %x55 8HEXDIG ; UXXXXXXXX            U+XXXXXXXX
  static final Parser<String> escapedUnicodeParser =
      ChoiceParser([
        tomlHexDigit()
            .times(2)
            .flatten(message: "Two hexadecimal digits expected")
            .skip(before: char('x')),
        tomlHexDigit()
            .times(4)
            .flatten(message: 'Four hexadecimal digits expected')
            .skip(before: char('u')),
        tomlHexDigit()
            .times(8)
            .flatten(message: 'Eight hexadecimal digits expected')
            .skip(before: char('U')),
      ]).map((charCodeStr) {
        var charCode = int.parse(charCodeStr, radix: 16);
        if (isScalarUnicodeValue(charCode)) {
          return String.fromCharCode(charCode);
        }
        var prefix = _unicodeEscapeSequencePrefix(charCodeStr.length);
        throw TomlInvalidEscapeSequenceException.nonScalar(
          '$escapeChar$prefix$charCodeStr',
        );
      });

  /// Tests whether the given code point is a scalar Unicode value, i.e., in
  /// the range `U+0000` to `U+D7FF` or `U+E000` to `U+10FFFF`.
  static bool isScalarUnicodeValue(int charCode) =>
      0x0000 <= charCode && charCode <= 0xD7FF ||
      0xE000 <= charCode && charCode <= 0x10FFFF;

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
    } else if (escapableCharsInverse.containsKey(rune)) {
      // The current rune must be escaped and there is a shortcut.
      buffer.write(escapeChar);
      buffer.write(escapableCharsInverse[rune]);
    } else {
      // The current rune must be escaped but there is no shortcut, i.e., the
      // Unicode code point must be escaped. However, Unicode escape sequences
      // are only allowed for scalar Unicode values.
      var length = _unicodeEscapeSequenceLength(rune);
      var prefix = _unicodeEscapeSequencePrefix(length);
      var hexCode = rune.toRadixString(16).padLeft(length, '0');
      if (!isScalarUnicodeValue(rune)) {
        throw TomlImpossibleEscapeSequenceException.nonScalar(rune);
      }
      buffer.write(escapeChar);
      buffer.write(prefix);
      buffer.write(hexCode);
    }
  }

  /// Returns the number of hexadecimal digits that are required to represent
  /// the given [rune] in a Unicode escape sequence.
  static int _unicodeEscapeSequenceLength(int rune) {
    if (rune & 0xff == rune) {
      return 2; // 0xHH
    } else if (rune & 0xffff == rune) {
      return 4; // 0xHHHH
    } else if (rune & 0xffffffff == rune) {
      return 8; // 0xHHHHHHHH
    }
    throw TomlImpossibleEscapeSequenceException.tooLong(rune);
  }

  /// Returns the prefix for a Unicode escape sequence with the given number of
  /// hexadecimal digits.
  static String _unicodeEscapeSequencePrefix(int length) {
    if (length == 2) {
      return 'x'; // \xHH
    } else if (length == 4) {
      return 'u'; // \uHHHH
    } else if (length == 8) {
      return 'U'; // \UHHHHHHHH
    }
    throw ArgumentError.value(
      length,
      'length',
      'Length must be 2, 4, or 8 for Unicode escape sequences',
    );
  }
}
