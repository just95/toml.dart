library toml.src.util.container.late;

/// A suspended computation for a value of type `T`.
typedef Thunk<T> = T Function();

/// Container for a value of type `T` that is lazily evaluated.
class Late<T> {
  /// The suspended computation of the lazily evaluated value.
  final Thunk<T> _thunk;

  /// The lazily evaluated value.
  ///
  /// Reading this value forces the evaluation of the suspended computation.
  late final T value = _thunk();

  /// Creates a new container for a lazily evaluted [value].
  ///
  /// The given computation is suspended until the [value] is used for the
  /// first time. It is evaluated at most once.
  Late(this._thunk);
}
