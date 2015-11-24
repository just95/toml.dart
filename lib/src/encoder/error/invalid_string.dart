// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

part of toml.encoder;

/// An error which is thrown when the encoder encounters a character in a
/// string which cannot be represented by TOML.
class InvalidStringError {

  /// A message which describes the error.
  final String msg;

  InvalidStringError(this.msg);

  @override
  bool operator ==(other) => other is InvalidStringError && other.msg == msg;

  @override
  int get hashCode => msg.hashCode;

  @override
  String toString() => msg;
}
