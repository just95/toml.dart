library toml.src.decoder.parser.util.separated_without;

import 'package:petitparser/petitparser.dart';

extension SeparatedWithoutParserExtension<T> on Parser<T> {
  /// Returns a parser that consumes the receiver one or more times separated
  /// by the [separator] parser. Unlike [separatedBy] a list of parse results
  /// of the receiving parser is returned that is not interleaved with the
  /// [separator]'s results.
  ///
  /// This parser adds type safety when the `includeSeparators` flag of
  /// [separatedBy] is used.
  ///
  /// The [optionalSeparatorAtEnd] flag is passed to [separatedBy] unchanged.
  Parser<List<T>> separatedWithout(
    Parser separator, {
    bool optionalSeparatorAtEnd = false,
  }) =>
      separatedBy<T>(
        separator,
        includeSeparators: false,
        optionalSeparatorAtEnd: optionalSeparatorAtEnd,
      );
}
