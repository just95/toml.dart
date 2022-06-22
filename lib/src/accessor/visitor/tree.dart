library toml.src.accessor.visitor.tree;

import '../tree.dart';

/// Interface for visitors of [TomlAccessor]s.
abstract class TomlAccessorVisitor<R> {
  /// Visits the given array accessor.
  R visitArrayAccessor(TomlArrayAccessor array);

  /// Visits the given table accessor.
  R visitTableAccessor(TomlTableAccessor table);

  /// Visits the given value accessor.
  R visitValueAccessor(TomlValueAccessor value);
}

/// Mixin that adds a [visitAccessor] method to classes implementing
/// [TomlAccessorVisitor] that automatically selects the appropriate
/// visitor method using [TomlAccessor.acceptVisitor].
mixin TomlAccessorVisitorMixin<R> implements TomlAccessorVisitor<R> {
  /// Visits the given [accessor].
  ///
  /// This method using [TomlAccessor.acceptVisit] to invoke the right visitor
  /// method from above.
  R visitAccessor(TomlAccessor accessor) => accessor.acceptVisitor(this);
}
