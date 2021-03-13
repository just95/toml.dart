library toml.src.ast.value.string.basic;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/ranges.dart';
import 'package:toml/src/decoder/parser/whitespace.dart';
import 'package:toml/src/util/parser.dart';
import 'package:quiver/core.dart';

import '../../visitor/value/string.dart';
import '../string.dart';
import 'escape.dart';

/// AST node that represents basic TOML strings.
///
///     basic-string = quotation-mark *basic-char quotation-mark
class TomlBasicString extends TomlSinglelineString {
  /// Delimiter for basic TOML strings.
  ///
  ///     quotation-mark = %x22            ; "
  static final String delimiter = '"';

  /// Parser for a basic TOML string value.
  static final Parser<TomlBasicString> parser = charParser
      .star()
      .join()
      .surroundedBy(char(delimiter))
      .map((value) => TomlBasicString._fromEncodable(value));

  /// Parser for a single character of a basic TOML string.
  ///
  ///     basic-char = basic-unescaped / escaped
  static final Parser<String> charParser =
      ChoiceParser([unescapedParser, TomlEscapedChar.parser]);

  /// Parser for a single unescaped character of a basic TOML string.
  ///
  ///     basic-unescaped = wschar / %x21 / %x23-5B / %x5D-7E / non-ascii
  ///
  ///  This range excludes `%x22` which is the `quotation-mark` character `"`
  ///  and `%x5C` which is the `escape` character `\`.
  static final Parser<String> unescapedParser = ChoiceParser([
    tomlWhitespaceChar,
    char(0x21),
    range(0x23, 0x5B),
    range(0x5D, 0x7E),
    tomlNonAscii
  ]);

  /// Escapes all characters of the given string that are not allowed to
  /// occur unescaped in a basic string.
  static String escape(String value) {
    var buffer = StringBuffer();
    for (var rune in value.runes) {
      TomlEscapedChar.writeEscapedChar(rune, buffer, unescapedParser);
    }
    return buffer.toString();
  }

  /// Tests whether the given string can be represented as a basic string.
  ///
  /// Basic strings can represent all strings that do only contain scalar
  /// Unicode values. While a basic string can contain surrogate pairs,
  /// there must be no unpaired high or low surrogate characters.
  static bool canEncode(String value) =>
      value.runes.every(TomlEscapedChar.isScalarUnicodeValue);

  @override
  final String value;

  /// Creates a new basic TOML string value with the given contents.
  ///
  /// Throws a [ArgumentError] when the given value cannot be encoded as a
  /// basic string (see [canEncode]).
  factory TomlBasicString(String value) {
    if (!canEncode(value)) {
      throw ArgumentError('Invalid basic string: $value');
    }
    return TomlBasicString._fromEncodable(value);
  }

  /// Creates a new basic string value with the given contents but skips the
  /// check whether the value can be encoded as a basic string.
  TomlBasicString._fromEncodable(this.value);

  @override
  TomlStringType get stringType => TomlStringType.basic;

  @override
  T acceptStringVisitor<T>(TomlStringVisitor<T> visitor) =>
      visitor.visitBasicString(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlBasicString && value == other.value;

  @override
  int get hashCode => hash3(type, stringType, value);
}
