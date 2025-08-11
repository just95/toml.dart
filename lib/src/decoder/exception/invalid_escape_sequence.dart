import 'package:meta/meta.dart';

import '../../ast/value/string/escape.dart';
import '../../exception.dart';

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
/// An exception of this type is also thrown when there are Unicode escape
/// sequences for non-scalar values.
///
/// Example:
///
///     invalid = "\uD801"
///
/// throws an [TomlInvalidEscapeSequenceException] with [escapeSequence]
/// set to `r'\uD801'` because `0xD800` is a high-surrogate code unit.
@immutable
class TomlInvalidEscapeSequenceException extends TomlException {
  /// The invalid escape sequence.
  final String escapeSequence;

  /// A human readable description of the reason why the escape sequence is
  /// invalid.
  final String reason;

  /// Creates a new exception for the given invalid [escapeSequence].
  TomlInvalidEscapeSequenceException._({
    required this.escapeSequence,
    required this.reason,
  });

  /// Creates a new exception for a non-Unicode [escapeSequence] that is not
  /// one of [TomlEscapedChar.escapableChars].
  factory TomlInvalidEscapeSequenceException.unspecified(
    String escapeSequence,
  ) {
    var allowedEscapeSequences = TomlEscapedChar.escapableChars.keys
        .map((escapableChar) => "\\$escapableChar")
        .join(', ');
    return TomlInvalidEscapeSequenceException._(
      escapeSequence: escapeSequence,
      reason: 'Must be one of $allowedEscapeSequences',
    );
  }

  /// Creates a new exception for a Unicode [escapeSequence] that is not a
  /// Unicode scalar value.
  factory TomlInvalidEscapeSequenceException.nonScalar(String escapeSequence) =>
      TomlInvalidEscapeSequenceException._(
        escapeSequence: escapeSequence,
        reason: 'Not a Unicode scalar value',
      );

  @override
  bool operator ==(Object other) =>
      other is TomlInvalidEscapeSequenceException &&
      other.escapeSequence == escapeSequence &&
      other.reason == reason;

  @override
  int get hashCode => escapeSequence.hashCode ^ reason.hashCode;

  @override
  String get message =>
      'The escape sequence "$escapeSequence" is invalid: $reason';
}
