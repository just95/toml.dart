library toml.src.accessor.visitor.key;

import '../key.dart';

/// Interface for visitors of [TomlKey]s.
abstract class TomlAccessorKeyVisitor<R> {
  /// Visits the given root key.
  R visitRootKey(TomlRootAccessorKey key);

  /// Visits the given name key.
  R visitNameKey(TomlNameAccessorKey key);

  /// Visits the given index key.
  R visitIndexKey(TomlIndexAccessorKey key);
}

/// Mixin that adds a [visitAccessorKey] method to classes implementing
/// [TomlAccessorKeyVisitor] that automatically selects the appropriate
/// visitor method using [TomlAccessorKey.acceptKeyVisitor].
mixin TomlAccessorKeyVisitorMixin<R> implements TomlAccessorKeyVisitor<R> {
  /// Visits the given [key].
  ///
  /// This method is using [TomlAccessorKey.acceptKeyVisitor] to invoke the
  /// right visitor method from above.
  R visitAccessorKey(TomlAccessorKey key) => key.acceptKeyVisitor(this);
}
