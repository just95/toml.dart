library toml.src.util.container.pair;

import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

/// Utility class that stores a pair of values of types `F` and `S`.
@immutable
class Pair<F, S> {
  /// The first component of the pair.
  final F first;

  /// The second component of the pair.
  final S second;

  /// Creates a new pair.
  Pair(this.first, this.second);

  @override
  int get hashCode => hash2(first, second);

  @override
  bool operator ==(Object other) =>
      other is Pair && first == other.first && second == other.second;

  @override
  String toString() => 'Pair($first, $second)';
}
