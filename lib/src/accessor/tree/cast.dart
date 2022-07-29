library toml.src.accessor.tree.cast;

import '../../ast.dart';
import '../../exception.dart';
import '../tree.dart';

/// Extension that adds methods to test and assert the type of accessor nodes.
extension TomlAccessorCastExtension on TomlAccessor {
  /// Whether this node represents an array of tables or array value.
  bool get isArray => this is TomlArrayAccessor;

  /// Whether this node represents a table or inline table.
  bool get isTable => this is TomlTableAccessor;

  /// Whether this node represents a non-composite value.
  bool get isValue => this is TomlValueAccessor;

  /// Ensures that this node is of the given type.
  ///
  /// Returns this node or throws a [TomlValueTypeException] if the runtime
  /// type don't match [T]. The [expectedTypes] are not used for the comparison
  /// but only for the error message in case of a mismatch.
  T _expectType<T extends TomlAccessor>(Set<TomlValueType> expectedTypes) {
    var self = this;
    if (self is T) return self;
    throw TomlValueTypeException(
      nodeName,
      expectedTypes: expectedTypes,
      actualType: type,
    );
  }

  /// Ensures that this node is a [TomlArrayAccessor].
  TomlArrayAccessor expectArray() =>
      _expectType<TomlArrayAccessor>({TomlValueType.array});

  /// Ensures that this node is a [TomlTableAccessor].
  TomlTableAccessor expectTable() =>
      _expectType<TomlTableAccessor>({TomlValueType.table});

  /// Ensures that this node is a [TomlValueAccessor].
  TomlValueAccessor expectValue() =>
      _expectType<TomlValueAccessor>(TomlPrimitiveValue.types);
}
