library toml.src.ast.visitor.expression;

import '../expression.dart';
import '../expression/key_value_pair.dart';
import '../expression/table.dart';

/// Interface for visitors of [TomlExpression]s.
abstract class TomlExpressionVisitor<R> {
  /// Visits the given key/value pair.
  R visitKeyValuePair(TomlKeyValuePair pair);

  /// Visits the given array of tables header.
  R visitArrayTable(TomlArrayTable table);

  /// Visits the given standard table header.
  R visitStandardTable(TomlStandardTable table);
}

/// Mixin that adds a [visitExpression] method to classes implementing
/// [TomlExpressionVisitor] that automatically selects the appropriate
/// visitor method using [TomlExpression.acceptExpressionVisitor].
///
/// This class is usually used when the visitor also implements the
/// [TomlVisitor] interface to provide a default implementation for
/// [TomlVisitor.visitExpression].
mixin TomlExpressionVisitorMixin<R> implements TomlExpressionVisitor<R> {
  /// Visits the given [expression].
  ///
  /// This method is using [TomlExpression.acceptExpressionVisitor] to invoke
  /// the right visitor method from above.
  R visitExpression(TomlExpression expression) =>
      expression.acceptExpressionVisitor(this);
}
