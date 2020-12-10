library toml.src.ast.value.string.literal;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/join.dart';
import 'package:toml/src/decoder/parser/util/ranges.dart';

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
  static final Parser<TomlLiteralString> parser =
      (char(delimiter) & charParser.star().join() & char(delimiter))
          .pick<String>(1)
          .map((value) => TomlLiteralString(value));

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
  TomlLiteralString(this.value);

  @override
  T acceptStringVisitor<T>(TomlStringVisitor<T> visitor) =>
      visitor.visitLiteralString(this);
}
