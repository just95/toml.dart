// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.table;

import 'package:toml/src/ast/expression.dart';
import 'package:toml/src/ast/key.dart';

/// Base class of all TOML table header expressions.
///
/// There are two types of tables [TomlStandardTable]s and [TomlArrayTable]s.
///
///     table = std-table / array-table
class TomlTable extends TomlExpression {
  final TomlKey name;

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
  TomlArrayTable(TomlKey name) : super(name);
}
