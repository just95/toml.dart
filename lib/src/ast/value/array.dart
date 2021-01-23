library toml.src.ast.value.array;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

import '../value.dart';
import '../visitor/value.dart';

/// AST node that represents a TOML array of values of type [V].
///
///     array = array-open [ array-values ] ws-comment-newline array-close
///
///     array-values =  ws-comment-newline val ws-comment-newline array-sep
///                     array-values
///     array-values =/ ws-comment-newline val ws-comment-newline [ array-sep ]
///
class TomlArray<V> extends TomlValue {
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
  ///
  /// The grammar itself does not enforce arrays to be homogeneous.
  /// The requirement of TOML 0.4.0 that value types are not mixed,
  /// is checked by [TomlArray.fromHomogeneous].
  static final Parser<TomlArray> parser = (char(openingDelimiter) &
          (tomlWhitespaceCommentNewline &
                  TomlValue.parser &
                  tomlWhitespaceCommentNewline)
              .pick(1)
              .separatedBy<TomlValue>(
                char(separator),
                includeSeparators: false,
                optionalSeparatorAtEnd: true,
              )
              .optional(<TomlValue>[]) &
          tomlWhitespaceCommentNewline &
          char(closingDelimiter))
      .pick<List<TomlValue>>(1)
      .map(fromHomogeneous);

  /// Creates a new array value from the given [items] but throws an
  /// [FormatException] if multiple element types are mixed.
  static TomlArray fromHomogeneous<V>(Iterable<TomlValue> items) {
    var array = TomlArray(items);
    var types = array.itemTypes.toSet();
    if (types.length > 1) {
      throw FormatException(
        'The items of "$array" must all be of the same type! '
        'Got the following item types: ${types.join(', ')}',
      );
    }
    return array;
  }

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
