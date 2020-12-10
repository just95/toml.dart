library toml.src.decoder.exception.invalid_escape_sequence;

import 'package:toml/src/exception.dart';

/// An exception which is thrown when the parser encounters an unspecified
/// escape sequence.
///
/// Example:
///
///     dir = "some\windows\path"
///
/// throws an [TomlInvalidEscapeSequenceException] with [escapeSequence]
/// set to `r'\w'`.
///
/// An exception of thos type is also thrown when there are Unicode escape
/// sequences for non-scalar values.
///
/// Example:
///
///     invalid = "\uD801"
///
/// throws an [TomlInvalidEscapeSequenceException] with [escapeSequence]
/// set to `r'\uD801'` because `0xD800` is a high-surrogate code unit.
class TomlInvalidEscapeSequenceException extends TomlException {
  /// The invalid escape sequence.
  final String escapeSequence;

  /// Creates a new exception for the given invalid [escapeSequence].
  TomlInvalidEscapeSequenceException(this.escapeSequence);

  @override
  bool operator ==(Object other) =>
      other is TomlInvalidEscapeSequenceException &&
      other.escapeSequence == escapeSequence;

  @override
  int get hashCode => escapeSequence.hashCode;

  @override
  String get message => 'The escape sequence "$escapeSequence" is invalid!';
}
