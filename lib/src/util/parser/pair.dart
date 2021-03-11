library toml.src.util.parser.pair;

import 'package:petitparser/petitparser.dart';

import '../container/pair.dart';

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
