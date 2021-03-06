library toml.src.util.iterable.where_not_null;

/// An extension on iterables that provides a method for filtering out `null`
/// values.
extension WhereNotNullExtension<T> on Iterable<T?> {
  /// Returns a new lazy iterable with all elements that are not `null`.
  Iterable<T> whereNotNull() => whereType<T>();
}
