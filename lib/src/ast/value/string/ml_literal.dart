library toml.src.ast.value.string.ml_literal;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/join.dart';
import 'package:toml/src/decoder/parser/util/ranges.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';
import 'package:toml/src/decoder/parser/util/seq_pick.dart';
import 'package:quiver/core.dart';

import '../../visitor/value/string.dart';
import '../string.dart';
import 'literal.dart';

/// AST node that represents multiline literal TOML strings.
///
///     ml-literal-string = ml-literal-string-delim [ newline ] ml-literal-body
///                         ml-literal-string-delim
class TomlMultilineLiteralString extends TomlMultilineString {
  /// Delimiter for multiline literal TOML strings.
  ///
  ///     ml-literal-string-delim = 3apostrophe
  static final String delimiter = TomlLiteralString.delimiter * 3;

  /// Parser for a TOML string value.
  ///
  /// A newline immediately following the opening delimiter is trimmed.
  static final Parser<TomlMultilineLiteralString> parser = tomlNewline
      .optional()
      .before(bodyParser)
      .surroundedBy(string(delimiter))
      .map((body) => TomlMultilineLiteralString._fromEncodable(body));

  ///
  ///
  ///     ml-literal-body =
  ///         *mll-content *( mll-quotes 1*mll-content ) [ mll-quotes ]
  static final Parser<String> bodyParser = SequenceParser([
    contentParser.star().join(),
    (quotesParser & contentParser.plus().join()).join().star().join(),
    quotesParser.optionalWith('')
  ]).join();

  /// Parser for one or two apostrophes.
  ///
  /// The body of a multiline literal string can contain up to two apostrophes
  /// since they do not form a valid [delimiter].
  ///
  ///     mll-quotes = 1*2apostrophe
  static final Parser<String> quotesParser = char(TomlLiteralString.delimiter)
      .repeatLazy(char(TomlLiteralString.delimiter).not(), 1, 2)
      .join();

  /// Parser for a single character of a multiline basic TOML string.
  ///
  ///     mll-content = mll-char / newline
  ///     mll-char = %x09 / %x20-26 / %x28-7E / non-ascii
  ///
  /// Literal strings can contain tabs (i.e., `%x09`) but no `apostrophe`s
  /// (i.e., `%x27`).
  static final Parser<String> contentParser = (char(0x09) |
          range(0x20, 0x26) |
          range(0x28, 0x7E) |
          tomlNonAscii |
          tomlNewline)
      .flatten();

  /// Tests whether the given string can be represented as a literal string.
  ///
  /// The string must only contain characters matched by [contentParser] or up
  /// to two consequtive `apostrophe`s.
  static bool canEncode(String str) => bodyParser.end().accept(str);

  @override
  final String value;

  /// Creates a new multiline literal TOML string value with the given contents.
  ///
  /// Throws a [ArgumentError] when the given value cannot be encoded as a
  /// multiline literal string (see [canEncode]).
  factory TomlMultilineLiteralString(String value) {
    if (!canEncode(value)) {
      throw ArgumentError('Invalid multiline literal string: $value');
    }
    return TomlMultilineLiteralString._fromEncodable(value);
  }

  /// Creates a new multiline literal string value with the given contents
  /// but skips the check whether the value can be encoded as a multiline
  /// literal string.
  TomlMultilineLiteralString._fromEncodable(this.value);

  @override
  TomlStringType get stringType => TomlStringType.multilineLiteral;

  @override
  T acceptStringVisitor<T>(TomlStringVisitor<T> visitor) =>
      visitor.visitMultilineLiteralString(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlMultilineLiteralString && value == other.value;

  @override
  int get hashCode => hash3(type, stringType, value);
}
