library toml.src.decoder.parser.util.seq_pick;

import 'package:petitparser/petitparser.dart';

/// Extension for utility methods for common combinations of [seq] and [pick].
extension SequencePickParserExtension<T> on Parser<T> {
  /// Returns a new parser for the sequence of the receiver and [other] parser
  /// that discards the result of the receiver.
  Parser<S> before<S>(Parser<S> other) => seq(other).pick<S>(1);

  /// Returns a new parser for the sequence of the receiver and [other] parser
  /// that discards the result of the [other] parser.
  Parser<T> followedBy(Parser other) => seq(other).pick<T>(0);

  /// Returns a new parser that parses the [prefix] before the receiver
  /// followed by the [suffix].
  ///
  /// The result of the returned parser is the result of the receiver. The
  /// result of the prefix and suffix are discarded.
  ///
  /// The [suffix] defaults to the [prefix].
  Parser<T> surroundedBy<S, U>(Parser<S> prefix, [Parser? suffix]) =>
      prefix.seq(this).seq(suffix ?? prefix).pick<T>(1);
}
