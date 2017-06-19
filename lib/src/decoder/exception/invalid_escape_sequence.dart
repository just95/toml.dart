// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.decoder.error.invalid_escape_sequence;

/// An error which is thrown when the parser encounters an unspecified escape
/// sequence.
///
/// Example:
///
///     dir = "some\windows\path"
///
/// throws an [InvalidEscapeSequenceException] with `[escapeSequence] = r'\w'`.
class InvalidEscapeSequenceException implements Exception {
  /// The invalid escape sequence.
  final String escapeSequence;

  InvalidEscapeSequenceException(this.escapeSequence);

  @override
  bool operator ==(other) =>
      other is InvalidEscapeSequenceException &&
      other.escapeSequence == escapeSequence;

  @override
  int get hashCode => escapeSequence.hashCode;

  @override
  String toString() => 'The escape sequence "$escapeSequence" is invalid!';
}
