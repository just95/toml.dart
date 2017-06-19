// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.encoder.exception.unknown_value_type;

/// An error which is thrown when an object cannot be encoded.
///
/// Example:
///
///     var encoder = new TomlEncoder();
///     encoder.encode({'a': null});
///
/// throws an [UnknownValueTypeException] because `null` is not a valid TOML
/// value.
class UnknownValueTypeException implements Exception {
  /// The object which cannot be encoded as a TOML value.
  final dynamic value;

  /// Creates a new exception for the given [value].
  UnknownValueTypeException(this.value);

  @override
  bool operator ==(Object other) =>
      other is UnknownValueTypeException && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '"$value" cannot be encoded as a TOMl value!';
}
