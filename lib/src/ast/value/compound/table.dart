library toml.src.ast.value.compound.table;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../../decoder/parser/whitespace.dart';
import '../../../util/parser.dart';
import '../../expression/key_value_pair.dart';
import '../../visitor/value/compound.dart';
import '../compound.dart';
import '../type.dart';

/// AST node that represents a TOML inline table.
///
///     inline-table =
///         inline-table-open [ inline-table-keyvals ] inline-table-close
///
///     inline-table-keyvals = keyval [ inline-table-sep inline-table-keyvals ]
@immutable
class TomlInlineTable extends TomlCompoundValue {
  /// The opening delimiter of inline tables.
  ///
  ///     inline-table-open  = %x7B ws     ; {
  static final String openingDelimiter = '{';

  /// The separator for the key/value pairs in inline tables.
  ///
  ///     inline-table-sep   = ws %x2C ws  ; , Comma
  static final String separator = ',';

  /// The closing delimiter of inline tables.
  ///
  ///     inline-table-close = ws %x7D     ; }
  static final String closingDelimiter = '}';

  /// Parser for a TOML inline-table.
  ///
  /// Trailing commas are currently not allowed.
  /// See https://github.com/toml-lang/toml/pull/235#issuecomment-73578529
  static final Parser<TomlInlineTable> parser = TomlKeyValuePair.parser
      .separatedWithout(tomlWhitespace & char(separator) & tomlWhitespace)
      .optionalWith(<TomlKeyValuePair>[])
      .trim(tomlWhitespaceChar)
      .skip(before: char(openingDelimiter), after: char(closingDelimiter))
      .map(TomlInlineTable.new);

  /// The key/value pairs of the inline table.
  final List<TomlKeyValuePair> pairs;

  /// Creates a new inline table.
  TomlInlineTable(Iterable<TomlKeyValuePair> pairs)
      : pairs = List.unmodifiable(pairs);

  @override
  TomlValueType get type => TomlValueType.table;

  @override
  T acceptCompoundValueVisitor<T>(TomlCompoundValueVisitor<T> visitor) =>
      visitor.visitInlineTable(this);

  @override
  bool operator ==(Object other) =>
      other is TomlInlineTable && ListEquality().equals(pairs, other.pairs);

  @override
  int get hashCode => Object.hashAll([type, ...pairs]);
}
