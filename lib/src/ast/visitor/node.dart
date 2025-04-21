import '../document.dart';
import '../expression.dart';
import '../key.dart';
import '../node.dart';
import '../value.dart';

/// Interface for visitors of [TomlNode]s.
abstract class TomlVisitor<R> {
  /// Visits the given document.
  R visitDocument(TomlDocument document);

  /// Visits the given expression.
  R visitExpression(TomlExpression expr);

  /// Visits the given dotted key.
  R visitKey(TomlKey key);

  /// Visits the given non-dotted key.
  R visitSimpleKey(TomlSimpleKey key);

  /// Visits the given value.
  R visitValue(TomlValue value);
}

/// Mixin that adds a [visitExpression] method to classes implementing
/// [TomlExpressionVisitor] that automatically selects the appropriate
/// visitor method using [TomlValue.acceptVisitor].
mixin TomlVisitorMixin<R> implements TomlVisitor<R> {
  /// Visits the given [node].
  ///
  /// This method is using [TomlValue.acceptVisitor] to invoke the right
  /// visitor method from above.
  R visit(TomlNode node) => node.acceptVisitor(this);
}
