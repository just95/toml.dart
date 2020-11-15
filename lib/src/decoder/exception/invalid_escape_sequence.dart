// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.decoder.exception.invalid_escape_sequence;

import 'package:toml/exception.dart';

/// An exception which is thrown when the parser encounters an unspecified
/// escape sequence.
///
/// Example:
///
///     dir = "some\windows\path"
///
/// throws an [InvalidEscapeSequenceException] with `[escapeSequence] = r'\w'`.
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
