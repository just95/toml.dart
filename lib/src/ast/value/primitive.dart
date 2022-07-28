library toml.src.ast.value.primitive;

import './compound.dart';
import './type.dart';
import '../value.dart';
import '../visitor/value.dart';
import '../visitor/value/primitive.dart';

/// Base class for AST nodes that represent non-compound TOML values, i.e.,
/// values that do not consist of other TOML values like booleans, integers,
/// floats, strings and date-times.
abstract class TomlPrimitiveValue extends TomlValue {
  /// Set of [TomlType]s that are allowed as the [type] of subclasses.
  static Set<TomlValueType> types =
      TomlValueType.values.toSet().difference(TomlCompoundValue.types);

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitPrimitiveValue(this);

  /// Invokes the correct `visit*` method for this value of the given visitor.
  T acceptPrimitiveValueVisitor<T>(TomlPrimitiveValueVisitor<T> visitor);
}
