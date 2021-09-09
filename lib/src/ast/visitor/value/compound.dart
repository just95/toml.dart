library toml.src.ast.visitor.value.compound;

import '../../value/compound.dart';
import '../../value/compound/array.dart';
import '../../value/compound/table.dart';

/// Interface for visitors of [TomlCompoundValue]s.
abstract class TomlCompoundValueVisitor<R> {
  /// Visits the given array value.
  R visitArray(TomlArray array);

  /// Visits the given inline table.
  R visitInlineTable(TomlInlineTable inlineTable);
}

/// Mixin that adds a [visitCompoundValue] method to classes implementing
/// [TomlCompoundValueVisitor] that automatically selects the appropriate
/// visitor method using [TomlValue.acceptCompoundValueVisitor].
///
/// This class is usually used when the visitor also implements the
/// [TomlValueVisitor] interface to provide a default implementation for
/// [TomlValueVisitor.visitCompoundValue].
mixin TomlCompoundValueVisitorMixin<R> implements TomlCompoundValueVisitor<R> {
  /// Visits the given [value].
  ///
  /// This method is using [TomlValue.acceptValueVisitor] to invoke the right
  /// visitor method from above.
  R visitCompoundValue(TomlCompoundValue value) =>
      value.acceptCompoundValueVisitor(this);
}
