// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

part of toml.encoder;

/// An error which is thrown when an `Iterable` cannot be encoded as an array
/// because it does not have a unique value type.
///
/// Example:
///
///     var encoder = new TomlEncoder();
///     encoder.encode({'a': [1, '2']});
///
/// throws an [MixedArrayTypesError] because `1` and `'2'` are of different
/// types.
class MixedArrayTypesError {

  /// The array which has mixed value types.
  final Iterable array;

  MixedArrayTypesError(this.array);

  @override
  bool operator ==(other) =>
      other is MixedArrayTypesError && other.array == array;

  @override
  int get hashCode => array.hashCode;

  @override
  String toString() => 'The items of "$array" must all be of the same type!';
}
