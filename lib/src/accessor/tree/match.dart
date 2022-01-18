library toml.src.accessor.tree.match;

import '../tree.dart';
import '../visitor/tree.dart';

/// A visitor that invokes a callback when an accessor is visited.
class _TomlAccessorCallbackVisitor<R> with TomlAccessorVisitorMixin<R> {
  /// The callback for [visitArrayAccessor].
  final R Function(TomlArrayAccessor) arrayAccessorCallback;

  /// The callback for [visitTableAccessor].
  final R Function(TomlTableAccessor) tableAccessorCallback;

  /// The callback for [visitValueAccessor].
  final R Function(TomlValueAccessor) valueAccessorCallback;

  /// A visitor that uses the given callbacks to visit the
  _TomlAccessorCallbackVisitor({
    required this.arrayAccessorCallback,
    required this.tableAccessorCallback,
    required this.valueAccessorCallback,
  });

  @override
  R visitArrayAccessor(TomlArrayAccessor array) => arrayAccessorCallback(array);

  @override
  R visitTableAccessor(TomlTableAccessor table) => tableAccessorCallback(table);

  @override
  R visitValueAccessor(TomlValueAccessor value) => valueAccessorCallback(value);
}

/// An extension that adds a method for pattern matching to accessors.
extension TomlAccessorMatchExtension on TomlAccessor {
  /// Performs pattern matching on this accessor.
  ///
  /// Selects the right callback based on the runtime type of this accessor,
  /// invokes the callback with this accessor and returns the callback's
  /// result.
  R match<R>({
    required R Function(TomlArrayAccessor) array,
    required R Function(TomlTableAccessor) table,
    required R Function(TomlValueAccessor) value,
  }) =>
      acceptVisitor(_TomlAccessorCallbackVisitor(
        arrayAccessorCallback: array,
        tableAccessorCallback: table,
        valueAccessorCallback: value,
      ));
}
