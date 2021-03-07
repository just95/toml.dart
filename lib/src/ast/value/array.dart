library toml.src.ast.value.array;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';
import 'package:toml/src/decoder/parser/util/seq_pick.dart';
import 'package:toml/src/decoder/parser/util/separated_without.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

import '../value.dart';
import '../visitor/value.dart';

/// AST node that represents a TOML array value.
///
///     array = array-open [ array-values ] ws-comment-newline array-close
///
///     array-values =  ws-comment-newline val ws-comment-newline array-sep
///                     array-values
///     array-values =/ ws-comment-newline val ws-comment-newline [ array-sep ]
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
      .surroundedBy(tomlWhitespaceCommentNewline)
      .separatedWithout(char(separator), optionalSeparatorAtEnd: true)
      .optionalWith(<TomlValue>[])
      .followedBy(tomlWhitespaceCommentNewline)
      .surroundedBy(char(openingDelimiter), char(closingDelimiter))
      .map((items) => TomlArray(items));

  /// The array items.
  final List<TomlValue> items;

  /// Creates a new array value.
  TomlArray(Iterable<TomlValue> items)
      : items = List.from(items, growable: false);

  /// Gets the TOML types of the [items].
  Iterable<TomlType> get itemTypes => items.map((item) => item.type);

  @override
  TomlType get type => TomlType.array;

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitArray(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlArray && listsEqual(items, other.items);

  @override
  int get hashCode => hashObjects(<dynamic>[type].followedBy(items));
}
