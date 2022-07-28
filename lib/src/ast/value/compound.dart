library toml.src.ast.value.compound;

import './type.dart';
import '../value.dart';
import '../visitor/value.dart';
import '../visitor/value/compound.dart';

/// Base class for AST nodes that represent TOML values that consist of other
/// TOML values, i.e., arrays and inline tables.
abstract class TomlCompoundValue extends TomlValue {
  /// Set of [TomlType]s that are allowed as the [type] of subclasses.
  static Set<TomlValueType> types = {TomlValueType.array, TomlValueType.table};

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitCompoundValue(this);

  /// Invokes the correct `visit*` method for this value of the given visitor.
  T acceptCompoundValueVisitor<T>(TomlCompoundValueVisitor<T> visitor);
}
