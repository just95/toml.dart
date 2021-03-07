library toml.src.ast.value.string.literal;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/join.dart';
import 'package:toml/src/decoder/parser/util/ranges.dart';
import 'package:toml/src/decoder/parser/util/seq_pick.dart';
import 'package:quiver/core.dart';

import '../../visitor/value/string.dart';
import '../string.dart';

/// AST node that represents literal TOML strings.
///
///     literal-string = apostrophe *literal-char apostrophe
class TomlLiteralString extends TomlSinglelineString {
  /// Delimiter for basic TOML strings.
  ///
  ///     apostrophe = %x27 ; ' apostrophe
  static final String delimiter = "'";

  /// Parser for a literal TOML string value.
  static final Parser<TomlLiteralString> parser = charParser
      .star()
      .join()
      .surroundedBy(char(delimiter))
      .map((value) => TomlLiteralString._fromEncodable(value));

  /// Parser for a single character of a basic TOML string.
  ///
  ///     literal-char = %x09 / %x20-26 / %x28-7E / non-ascii
  ///
  /// Literal strings can contain tabs (i.e., `%x09`) but no `apostrophe`s
  /// (i.e., `%x27`).
  static final Parser<String> charParser =
      (char('\x09') | range(0x20, 0x26) | range(0x28, 0x7E) | tomlNonAscii)
          .flatten();

  /// Tests whether the given string can be represented as a literal string.
  ///
  /// The string must only contain characters matched by [charParser].
  static bool canEncode(String str) => charParser.star().end().accept(str);

  @override
  final String value;

  /// Creates a new literal string value with the given contents.
  ///
  /// Throws a [ArgumentError] when the given value cannot be encoded as a
  /// literal string (see [canEncode]).
  factory TomlLiteralString(String value) {
    if (!canEncode(value)) {
      throw ArgumentError('Invalid literal string: $value');
    }
    return TomlLiteralString._fromEncodable(value);
  }

  /// Creates a new literal string value with the given contents but skips the
  /// check whether the value can be encoded as a literal string.
  TomlLiteralString._fromEncodable(this.value);

  @override
  TomlStringType get stringType => TomlStringType.literal;

  @override
  T acceptStringVisitor<T>(TomlStringVisitor<T> visitor) =>
      visitor.visitLiteralString(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlLiteralString && value == other.value;

  @override
  int get hashCode => hash3(type, stringType, value);
}
