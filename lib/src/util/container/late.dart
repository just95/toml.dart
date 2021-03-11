library toml.src.util.container.late;

/// A suspended computation for a value of type `T`.
typedef Thunk<T> = T Function();

/// Container for a value of type `T` that can be evaluated lazily.
abstract class Late<T> {
  T get value;

  /// Creates a new container for a lazily evaluted [value].
  ///
  /// The given computation is suspended until the [value] is used for the
  /// first time. It is evaluated at most once.
  factory Late(Thunk<T> thunk) => _Lazy(thunk);

  /// Creates a new container for an eagerly evaluated [value].
  factory Late.eager(T value) => _Eager(value);
}

/// Container for a value of type `T` that is evaluated lazily.
class _Lazy<T> implements Late<T> {
  @override
  late final T value = _thunk();

  /// The suspended computation of the lazily evaluated value.
  final Thunk<T> _thunk;

  /// Creates a new container for a lazily evaluted [value].
  ///
  /// The given computation is suspended until the [value] is used for the
  /// first time. It is evaluated at most once.
  _Lazy(this._thunk);
}

/// Container for a value of type `T` that is evaluated eagerly.
class _Eager<T> implements Late<T> {
  @override
  final T value;

  _Eager(this.value);
}
