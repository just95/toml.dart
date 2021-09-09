library toml.src.ast.visitor.value;

import '../value.dart';
import '../value/compound.dart';
import '../value/primitive.dart';

/// Interface for visitors of [TomlValue]s.
abstract class TomlValueVisitor<R> {
  /// Visits the given primitive value.
  R visitPrimitiveValue(TomlPrimitiveValue value);

  /// Visits the given compound value, i.e., array or inline table.
  R visitCompoundValue(TomlCompoundValue value);
}

/// Mixin that adds a [visitValue] method to classes implementing
/// [TomlValueVisitor] that automatically selects the appropriate
/// visitor method using [TomlValue.acceptValueVisitor].
///
/// This class is usually used when the visitor also implements the
/// [TomlVisitor] interface to provide a default implementation for
/// [TomlVisitor.visitValue].
mixin TomlValueVisitorMixin<R> implements TomlValueVisitor<R> {
  /// Visits the given [value].
  ///
  /// This method is using [TomlValue.acceptValueVisitor] to invoke the right
  /// visitor method from above.
  R visitValue(TomlValue value) => value.acceptValueVisitor(this);
}
