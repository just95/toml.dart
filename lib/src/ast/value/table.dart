import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../decoder/parser/whitespace.dart';
import '../../util/separated_list.dart';
import '../expression/key_value_pair.dart';
import '../value.dart';
import '../visitor/value.dart';

/// AST node that represents a TOML inline table.
///
///     inline-table = inline-table-open [ inline-table-keyvals ]
///                    ws-comment-newline inline-table-close
///
///     inline-table-keyvals =  ws-comment-newline keyval ws-comment-newline
///                             inline-table-sep inline-table-keyvals
///     inline-table-keyvals =/ ws-comment-newline keyval ws-comment-newline
///                             [ inline-table-sep ]
@immutable
class TomlInlineTable extends TomlValue {
  /// The opening delimiter of inline tables.
  ///
  ///     inline-table-open  = %x7B  ; {
  static final String openingDelimiter = '{';

  /// The separator for the key/value pairs in inline tables.
  ///
  ///     inline-table-sep   = %x2C  ; , Comma
  static final String separator = ',';

  /// The closing delimiter of inline tables.
  ///
  ///     inline-table-close = %x7D  ; }
  static final String closingDelimiter = '}';

  /// Parser for a TOML inline-table.
  static final Parser<TomlInlineTable> parser = TomlKeyValuePair.parser
      .skip(
        before: tomlWhitespaceCommentNewline,
        after: tomlWhitespaceCommentNewline,
      )
      .plusSeparated(char(separator))
      .skip(after: char(separator).optional())
      .map(discardSeparators)
      .optionalWith(<TomlKeyValuePair>[])
      .skip(after: tomlWhitespaceCommentNewline)
      .skip(before: char(openingDelimiter), after: char(closingDelimiter))
      .map(TomlInlineTable.new);

  /// The key/value pairs of the inline table.
  final List<TomlKeyValuePair> pairs;

  /// Creates a new inline table.
  TomlInlineTable(Iterable<TomlKeyValuePair> pairs)
    : pairs = List.unmodifiable(pairs);

  @override
  TomlType get type => TomlType.table;

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitInlineTable(this);

  @override
  bool operator ==(Object other) =>
      other is TomlInlineTable &&
      ListEquality<TomlKeyValuePair>().equals(pairs, other.pairs);

  @override
  int get hashCode => Object.hashAll([type, ...pairs]);
}
