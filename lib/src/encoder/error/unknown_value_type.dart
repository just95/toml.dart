// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

part of toml.encoder;

/// An error which is thrown when an object cannot be encoded.
///
/// Example:
///
///     var encoder = new TomlEncoder();
///     encoder.encode({'a': null});
///
/// throws an [UnknownValueTypeError] because `null` is not a valid TOML value.
class UnknownValueTypeError {
  /// The object which cannot be encoded as a TOML value.
  final value;

  UnknownValueTypeError(this.value);

  @override
  bool operator ==(other) =>
      other is UnknownValueTypeError && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '"$value" cannot be encoded as a TOMl value!';
}
