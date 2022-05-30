library toml.src.ast.value.primitive.string.basic;

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../../../decoder/parser/ranges.dart';
import '../../../../decoder/parser/whitespace.dart';
import '../../../../util/parser.dart';
import '../../../visitor/value/primitive/string.dart';
import '../string.dart';
import 'escape.dart';

/// AST node that represents basic TOML strings.
///
///     basic-string = quotation-mark *basic-char quotation-mark
@immutable
class TomlBasicString extends TomlSinglelineString {
  /// Delimiter for basic TOML strings.
  ///
  ///     quotation-mark = %x22            ; "
  static final String delimiter = '"';

  /// Parser for a basic TOML string value.
  static final Parser<TomlBasicString> parser = charParser
      .star()
      .join()
      .surroundedBy(
        char(delimiter, "opening '$delimiter' expected"),
        char(delimiter, "closing '$delimiter' expected"),
      )
      .map(TomlBasicString._fromEncodable);

  /// Parser for a single character of a basic TOML string.
  ///
  ///     basic-char = basic-unescaped / escaped
  static final Parser<String> charParser = ChoiceParser([
    unescapedParser,
    TomlEscapedChar.parser,
  ], failureJoiner: selectFarthestJoined);

  /// Parser for a single unescaped character of a basic TOML string.
  ///
  ///     basic-unescaped = wschar / %x21 / %x23-5B / %x5D-7E / non-ascii
  ///
  ///  This range excludes `%x22` which is the `quotation-mark` character `"`
  ///  and `%x5C` which is the `escape` character `\`.
  static final Parser<String> unescapedParser = ChoiceParser([
    tomlWhitespaceChar,
    char('\x21'),
    range('\x23', '\x5B'),
    range('\x5D', '\x7E'),
    tomlNonAscii
  ]).flatten('Basic string character expected');

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
  bool operator ==(Object other) =>
      other is TomlBasicString && value == other.value;

  @override
  int get hashCode => Object.hash(type, stringType, value);
}
