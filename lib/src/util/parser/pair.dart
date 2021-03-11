library toml.src.util.parser.pair;

import 'package:quiver/core.dart';
import 'package:petitparser/petitparser.dart';

/// Utility class that stores a pair of values of types `F` and `S`.
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
  bool operator ==(other) =>
      other is Pair && first == other.first && second == other.second;

  @override
  String toString() => 'Pair($first, $second)';
}

/// A parser for the sequence of two parsers that preserves type information.
class PairParser<F, S> extends Parser<Pair<F, S>> {
  /// Parser for the first component of the pair.
  final Parser<F> firstParser;

  /// Parser for the second component of the pair.
  final Parser<S> secondParser;

  /// Creates a new parser for a pair from the given two component parsers.
  PairParser(this.firstParser, this.secondParser);

  @override
  Parser<Pair<F, S>> copy() => PairParser(firstParser, secondParser);

  @override
  Result<Pair<F, S>> parseOn(Context context) {
    final firstResult = firstParser.parseOn(context);
    if (firstResult.isFailure) {
      return firstResult.failure(firstResult.message);
    }

    final secondResult = secondParser.parseOn(firstResult);
    if (secondResult.isFailure) {
      return secondResult.failure(secondResult.message);
    }

    return secondResult.success(Pair(firstResult.value, secondResult.value));
  }
}
