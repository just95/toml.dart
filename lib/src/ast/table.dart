// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.table;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/expression.dart';
import 'package:toml/src/ast/key.dart';
import 'package:toml/src/parser/util/whitespace.dart';

/// Base class of all TOML table header expressions.
///
/// There are two types of tables [TomlStandardTable]s and [TomlArrayTable]s.
///
///     table = std-table / array-table
abstract class TomlTable extends TomlExpression {
  /// Parser for a TOML table header.
  static final Parser<TomlTable> parser =
      (TomlStandardTable.parser | TomlArrayTable.parser).cast<TomlTable>();

  /// The name of the table or array of tables.
  final TomlKey name;

  /// Creates a new table.
  TomlTable(this.name);
}

/// A TOML expression AST node that represents the header of a standard TOML
/// table.
///
///     std-table = std-table-open key std-table-close
///
///     std-table-open  = %x5B ws     ; [ Left square bracket
///     std-table-close = ws %x5D     ; ] Right square bracket
class TomlStandardTable extends TomlTable {
  /// Parser for a standard TOML table header.
  static final Parser<TomlStandardTable> parser =
      (char('[') & tomlWhitespace & TomlKey.parser & tomlWhitespace & char(']'))
          .pick<TomlKey>(2)
          .map((TomlKey key) => TomlStandardTable(key));

  /// Creates a new TOML standard table.
  TomlStandardTable(TomlKey name) : super(name);
}

/// A TOML expression AST node that represents the header of an entry of
/// an array of tables.
///
///     array-table = array-table-open key array-table-close
///
///     array-table-open  = %x5B.5B ws  ; [[ Double left square bracket
///     array-table-close = ws %x5D.5D  ; ]] Double right square bracket
class TomlArrayTable extends TomlTable {
  /// Parser for a TOML array of tables header.
  static final Parser<TomlArrayTable> parser = (string('[[') &
          tomlWhitespace &
          TomlKey.parser &
          tomlWhitespace &
          string(']]'))
      .pick<TomlKey>(2)
      .map((TomlKey key) => TomlArrayTable(key));

  /// Creates a new TOML array table.
  TomlArrayTable(TomlKey name) : super(name);
}
