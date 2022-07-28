library toml.src.util.parser.surrounded;

import 'package:petitparser/petitparser.dart';

/// Extension for utility methods to construct [skip] parsers.
extension SurroundedParserExtension<T> on Parser<T> {
  /// Returns a new parser for the sequence of the receiver and [other] parser
  /// that discards the result of the receiver.
  Parser<S> before<S>(Parser<S> other) => other.skip(before: this);

  /// Returns a new parser for the sequence of the receiver and [other] parser
  /// that discards the result of the [other] parser.
  Parser<T> followedBy(Parser other) => skip(after: other);

  /// Returns a new parser that parses the [prefix] before the receiver
  /// followed by the [suffix].
  ///
  /// The result of the returned parser is the result of the receiver. The
  /// result of the prefix and suffix are discarded.
  ///
  /// The [suffix] defaults to the [prefix].
  Parser<T> surroundedBy(Parser prefix, [Parser? suffix]) => skip(
        before: prefix,
        after: suffix ?? prefix,
      );
}
