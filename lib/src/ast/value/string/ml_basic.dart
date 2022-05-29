library toml.src.ast.value.string.ml_basic;

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../../decoder/parser/ranges.dart';
import '../../../decoder/parser/whitespace.dart';
import '../../../util/parser.dart';
import '../../visitor/value/string.dart';
import '../string.dart';
import 'basic.dart';
import 'escape.dart';

/// AST node that represents multiline basic TOML strings.
///
///     ml-basic-string = ml-basic-string-delim [ newline ] ml-basic-body
///                       ml-basic-string-delim
@immutable
class TomlMultilineBasicString extends TomlMultilineString {
  /// Delimiter for multiline basic TOML strings.
  ///
  ///     ml-basic-string-delim = 3quotation-mark
  static final String delimiter = TomlBasicString.delimiter * 3;

  /// Parser for a multiline basic TOML string value.
  static final Parser<TomlMultilineBasicString> parser = tomlNewline
      .optional()
      .before(bodyParser)
      .surroundedBy(
        string(delimiter, "opening '$delimiter' expected"),
        string(delimiter, "closing '$delimiter' expected"),
      )
      .map(TomlMultilineBasicString._fromEncodable);

  /// Parser for the body of a multiline basic TOML string.
  ///
  ///     ml-basic-body =
  ///       *mlb-content *( mlb-quotes 1*mlb-content ) [ mlb-quotes ]
  static final Parser<String> bodyParser = SequenceParser([
    contentParser.star().join(),
    (quotesParser & contentParser.plus().join()).join().star().join(),
    quotesParser.optionalWith(''),
  ]).join();

  /// Parser for one or two quotation marks.
  ///
  /// The body of a multiline basic string can contain up to two double
  /// quotes since they do not form a valid [delimiter]. Additional double
  /// quotes have to be escaped.
  ///
  ///     mlb-quotes = 1*2quotation-mark
  static final Parser<String> quotesParser = char(TomlBasicString.delimiter)
      .repeatLazy(
        string(delimiter).optional() & char(TomlBasicString.delimiter).not(),
        1,
        2,
      )
      .join();

  /// Parser for a single character of a multiline basic TOML string.
  ///
  ///     mlb-content = mlb-char / newline / mlb-escaped-nl
  ///     mlb-char = mlb-unescaped / escaped
  static final Parser<String> contentParser = ChoiceParser([
    unescapedParser,
    TomlEscapedChar.parser,
    tomlNewline,
    escapedNewlineParser,
  ], failureJoiner: selectFarthestJoined);

  /// Parser for a single unescaped character of a multiline basic TOML string.
  ///
  ///     mlb-unescaped = wschar / %x21 / %x23-5B / %x5D-7E / non-ascii
  ///
  ///  This range excludes `%x22` which is the `quotation-mark` character `"`
  ///  and `%x5C` which is the `escape` character `\`.
  static final Parser<String> unescapedParser = ChoiceParser([
    tomlWhitespaceChar,
    char('\x21'),
    range('\x23', '\x5B'),
    range('\x5D', '\x7E'),
    tomlNonAscii
  ]).flatten('Unescaped multiline basic string character expected');

  /// Parser for an escaped newline.
  ///
  ///     mlb-escaped-nl = escape ws newline *( wschar / newline )
  static final Parser<String> escapedNewlineParser =
      (char(TomlEscapedChar.escapeChar) &
              tomlWhitespace &
              tomlNewline &
              ChoiceParser(
                [tomlWhitespaceChar, tomlNewline],
                failureJoiner: selectFarthestJoined,
              ).star())
          .map((_) => '');

  /// Escapes all characters of the given string that are not allowed to
  /// occur unescaped in a multiline basic string.
  static String escape(String value) {
    var buffer = StringBuffer();
    var unescapedOrNewline = ChoiceParser(
      [unescapedParser, tomlNewline],
      failureJoiner: selectFarthestJoined,
    );
    var quotes = 0;
    var iterator = value.runes.iterator;
    while (iterator.moveNext()) {
      final rune = iterator.current;

      // If the current rune is a quotation mark and it is preceeded by less
      // than two quotation marks, it does not have to be escaped, because only
      // three or more quotation marks can be confused for a closing delimiter.
      if (rune == TomlBasicString.delimiter.runes.first && quotes < 2) {
        buffer.writeCharCode(rune);
        quotes++;
      } else {
        quotes = 0;

        // If the current rune is a carriage return and the next rune is a
        // line feed, the carriage return does not have to be escaped.
        if (rune == TomlEscapedChar.carriageReturn &&
            _peekNext(iterator) == TomlEscapedChar.lineFeed) {
          buffer.writeCharCode(rune);
        } else {
          TomlEscapedChar.writeEscapedChar(rune, buffer, unescapedOrNewline);
        }
      }
    }
    return buffer.toString();
  }

  /// Tests whether the given string can be represented as a multiline basic
  /// string.
  ///
  /// Multiline basic strings can represent all strings that do only contain
  /// scalar Unicode values. While a basic string can contain surrogate pairs,
  /// there must be no unpaired high or low surrogate characters.
  static bool canEncode(String value) => TomlBasicString.canEncode(value);

  /// Reads the next rune from the given iterator without advancing the
  /// iterator.
  ///
  /// Returns `null` if there is no next rune.
  static int? _peekNext(RuneIterator iterator) {
    if (iterator.moveNext()) {
      var next = iterator.current;
      iterator.movePrevious();
      return next;
    }
    return null;
  }

  @override
  final String value;

  /// Creates a new multiline basic TOML string value with the given contents.
  ///
  /// Throws a [ArgumentError] when the given value cannot be encoded as a
  /// multiline basic string (see [canEncode]).
  factory TomlMultilineBasicString(String value) {
    if (!canEncode(value)) {
      throw ArgumentError('Invalid multiline basic string: $value');
    }
    return TomlMultilineBasicString._fromEncodable(value);
  }

  /// Creates a new basic string value with the given contents but skips the
  /// check whether the value can be encoded as a basic string.
  TomlMultilineBasicString._fromEncodable(this.value);

  @override
  TomlStringType get stringType => TomlStringType.multilineBasic;

  @override
  T acceptStringVisitor<T>(TomlStringVisitor<T> visitor) =>
      visitor.visitMultilineBasicString(this);

  @override
  bool operator ==(Object other) =>
      other is TomlMultilineBasicString && value == other.value;

  @override
  int get hashCode => Object.hash(type, stringType, value);
}
