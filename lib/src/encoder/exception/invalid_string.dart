// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.encoder.exception.invalid_string;

/// An exception which is thrown when the encoder encounters a character in a
/// string which cannot be represented by TOML.
class InvalidStringException implements Exception {
  /// A message which describes the exception.
  final String msg;

  /// Creates a new exception for an invalid string.
  ///
  /// The given message [msg] describes the reason why the string is invalid.
  InvalidStringException(this.msg);

  @override
  bool operator ==(Object other) =>
      other is InvalidStringException && other.msg == msg;

  @override
  int get hashCode => msg.hashCode;

  @override
  String toString() => msg;
}
