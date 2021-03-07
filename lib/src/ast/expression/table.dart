library toml.src.ast.expression.table;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';
import 'package:toml/src/decoder/parser/util/seq_pick.dart';
import 'package:quiver/core.dart';

import '../expression.dart';
import '../key.dart';
import '../visitor/expression.dart';

/// The two types of TOML tables that can be declared by a table header
/// expression.
enum TomlTableType {
  /// The type of a table header that declares a standard table.
  standardTable,

  /// The type of a table header that declares an array of tables.
  arrayTable
}

/// Base class of all TOML table header expressions.
///
/// There are two types of tables [TomlStandardTable]s and [TomlArrayTable]s.
///
///     table = std-table / array-table
abstract class TomlTable extends TomlExpression {
  /// Parser for a TOML table header.
  static final Parser<TomlTable> parser =
      ChoiceParser([TomlStandardTable.parser, TomlArrayTable.parser]);

  /// The name of the table or array of tables.
  final TomlKey name;

  /// Creates a new table.
  TomlTable(this.name);

  /// The type of table declared by this table header.
  TomlTableType get type;
}

/// A TOML expression AST node that represents the header of a standard TOML
/// table.
///
///     std-table = std-table-open key std-table-close
class TomlStandardTable extends TomlTable {
  /// The opening delimited of the standard table header.
  ///
  ///     std-table-open  = %x5B ws     ; [ Left square bracket
  static final String openingDelimiter = '[';

  /// The opening delimited of the standard table header.
  ///     std-table-close = ws %x5D     ; ] Right square bracket
  static final String closingDelimiter = ']';

  /// Parser for a standard TOML table header.
  static final Parser<TomlStandardTable> parser = TomlKey.parser
      .surroundedBy(tomlWhitespace)
      .surroundedBy(char(openingDelimiter), char(closingDelimiter))
      .map((key) => TomlStandardTable(key));

  /// Creates a new TOML standard table.
  TomlStandardTable(TomlKey name) : super(name);

  @override
  TomlTableType get type => TomlTableType.standardTable;

  @override
  T acceptExpressionVisitor<T>(TomlExpressionVisitor<T> visitor) =>
      visitor.visitStandardTable(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlStandardTable && name == other.name;

  @override
  int get hashCode => hash2(type, name);
}

/// A TOML expression AST node that represents the header of an entry of
/// an array of tables.
///
///     array-table = array-table-open key array-table-close
class TomlArrayTable extends TomlTable {
  /// The opening delimited of the array of tables header.
  ///
  ///     array-table-open  = %x5B.5B ws  ; [[ Double left square bracket
  static final String openingDelimiter = '[[';

  /// The opening delimited of the array of tables header.
  ///
  ///     array-table-close = ws %x5D.5D  ; ]] Double right square bracket
  static final String closingDelimiter = ']]';

  /// Parser for a TOML array of tables header.
  static final Parser<TomlArrayTable> parser = TomlKey.parser
      .surroundedBy(tomlWhitespace)
      .surroundedBy(string(openingDelimiter), string(closingDelimiter))
      .map((TomlKey key) => TomlArrayTable(key));

  /// Creates a new TOML array table.
  TomlArrayTable(TomlKey name) : super(name);

  @override
  TomlTableType get type => TomlTableType.arrayTable;

  @override
  T acceptExpressionVisitor<T>(TomlExpressionVisitor<T> visitor) =>
      visitor.visitArrayTable(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlArrayTable && name == other.name;

  @override
  int get hashCode => hash2(type, name);
}
