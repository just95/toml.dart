// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.encoder.exception.mixed_array_types;

/// An error which is thrown when an `Iterable` cannot be encoded as an array
/// because it does not have a unique value type.
///
/// Example:
///
///     var encoder = new TomlEncoder();
///     encoder.encode({'a': [1, '2']});
///
/// throws an [MixedArrayTypesException] because `1` and `'2'` are of different
/// types.
class MixedArrayTypesException implements Exception {
  /// The array which has mixed value types.
  final Iterable array;

  MixedArrayTypesException(this.array);

  @override
  bool operator ==(Object other) =>
      other is MixedArrayTypesException && other.array == array;

  @override
  int get hashCode => array.hashCode;

  @override
  String toString() => 'The items of "$array" must all be of the same type!';
}
