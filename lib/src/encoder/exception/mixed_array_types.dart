library toml.src.encoder.exception.mixed_array_types;

import 'package:toml/src/ast.dart';
import 'package:toml/src/exception.dart';

/// An exception which is thrown when an `Iterable` cannot be encoded as an
/// array because it does not have a unique value type.
///
/// Example:
///
///     var encoder = new TomlEncoder();
///     encoder.encode({'a': [1, '2']});
///
/// throws an [TomlMixedArrayTypesException] because `1` and `'2'` are of
/// different types.
class TomlMixedArrayTypesException extends TomlException {
  /// The array which has mixed value types.
  final TomlArray array;

  /// Creates a new exception for the given [array].
  TomlMixedArrayTypesException(this.array);

  @override
  bool operator ==(Object other) =>
      other is TomlMixedArrayTypesException && other.array == array;

  @override
  int get hashCode => array.hashCode;

  @override
  String get message => 'The items of "$array" must all be of the same type!';
}
