import 'package:petitparser/petitparser.dart';

/// Extension that adds a type safe method for reporting custom error messages
/// to parsers.
extension OrFailureParserExtension<T> on Parser<T> {
  /// Returns a new parser that applies the receiver but overwrites error
  /// messages of the receiver with the given [message].
  ///
  /// This method is equivalent to `.or(failure(message))` but preserves the
  /// type of the receiver.
  Parser<T> orFailure(String message) =>
      ChoiceParser([this, failure(message)], failureJoiner: selectFarthest);
}
