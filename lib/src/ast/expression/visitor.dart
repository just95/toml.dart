library toml.src.ast.expression.visitor;

import 'package:toml/src/ast/expression.dart';
import 'package:toml/src/ast/expression/key_value_pair.dart';
import 'package:toml/src/ast/expression/table.dart';

/// Interface for visitors of [TomlExpression]s.
abstract class TomlExpressionVisitor<T> {
  /// Visits the given key/value pair.
  T visitKeyValuePair(TomlKeyValuePair pair);

  /// Visits the given array of tables header.
  T visitArrayTable(TomlArrayTable table);

  /// Visits the given standard table header.
  T visitStandardTable(TomlStandardTable table);

  /// Visits the given [expression].
  ///
  /// This method is uses [TomlExpression.accept] to invoke the right visitor
  /// method from above.
  T visitExpression(TomlExpression expression) => expression.accept(this);
}
