library toml.src.ast.value.array;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../decoder/parser/whitespace.dart';
import '../../util/parser.dart';
import '../value.dart';
import '../visitor/value.dart';

/// AST node that represents a TOML array value.
///
///     array = array-open [ array-values ] ws-comment-newline array-close
///
///     array-values =  ws-comment-newline val ws-comment-newline array-sep
///                     array-values
///     array-values =/ ws-comment-newline val ws-comment-newline [ array-sep ]
@immutable
class TomlArray extends TomlValue {
  /// The opening delimiter of arrays.
  ///
  ///     array-open =  %x5B ; [
  static final String openingDelimiter = '[';

  /// The separator for the items in arrays.
  ///
  ///     array-sep = %x2C  ; , Comma
  static final String separator = ',';

  /// The closing delimiter of arrays.
  ///
  ///     array-close = %x5D ; ]
  static final String closingDelimiter = ']';

  /// Parser for a TOML array value.
  static final Parser<TomlArray> parser = TomlValue.parser
      .skip(
        before: tomlWhitespaceCommentNewline,
        after: tomlWhitespaceCommentNewline,
      )
      .separatedWithout(char(separator), optionalSeparatorAtEnd: true)
      .optionalWith(<TomlValue>[])
      .skip(after: tomlWhitespaceCommentNewline)
      .skip(before: char(openingDelimiter), after: char(closingDelimiter))
      .map(TomlArray.new);

  /// The array items.
  final List<TomlValue> items;

  /// Creates a new array value.
  TomlArray(Iterable<TomlValue> items) : items = List.unmodifiable(items);

  @override
  TomlType get type => TomlType.array;

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitArray(this);

  @override
  bool operator ==(Object other) =>
      other is TomlArray && ListEquality().equals(items, other.items);

  @override
  int get hashCode => Object.hashAll([type, ...items]);
}
