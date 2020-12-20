library toml.src.ast.value.string.ml_literal;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/join.dart';
import 'package:toml/src/decoder/parser/util/ranges.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';
import 'package:quiver/core.dart';

import '../../visitor/value/string.dart';
import '../string.dart';
import 'literal.dart';

/// AST node that represents multiline literal TOML strings.
///
///     ml-literal-string =
///         ml-literal-string-delim ml-literal-body ml-literal-string-delim
class TomlMultilineLiteralString extends TomlMultilineString {
  /// Delimiter for multiline literal TOML strings.
  ///
  ///     ml-literal-string-delim = 3apostrophe
  static final String delimiter = TomlLiteralString.delimiter * 3;

  /// Parser for a TOML string value.
  ///
  /// A newline immediately following the opening delimiter is trimmed.
  static final Parser<TomlMultilineLiteralString> parser = (string(delimiter) &
          tomlNewline.optional() &
          bodyParser &
          string(delimiter))
      .pick<String>(2)
      .map((body) => TomlMultilineLiteralString(body));

  ///
  ///
  ///     ml-literal-body =
  ///         *mll-content *( mll-quotes 1*mll-content ) [ mll-quotes ]
  static final Parser<String> bodyParser = (charParser.star().join() &
          (quotesParser & charParser.plus().join()).join().star().join() &
          quotesParser.optional(''))
      .castList<String>()
      .join();

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
  static final Parser<String> charParser = (char(0x09) |
          range(0x20, 0x26) |
          range(0x28, 0x7E) |
          tomlNonAscii |
          tomlNewline)
      .flatten();

  /// Tests whether the given string can be represented as a literal string.
  ///
  /// The string must only contain characters matched by [charParser] or up
  /// to two consequtive `apostrophe`s.
  static bool canEncode(String str) => bodyParser.end().accept(str);

  @override
  final String value;

  /// Creates a new multiline literal TOML string value with the given contents.
  TomlMultilineLiteralString(this.value);

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
