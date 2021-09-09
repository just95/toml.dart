library toml.src.ast.value.primitive;

import '../value.dart';
import '../visitor/value.dart';
import '../visitor/value/primitive.dart';

/// Base class for AST nodes that represent non-compound TOML values, i.e.,
/// values that do not consist of other TOML values like booleans, integers,
/// floats, strings and date-times.
abstract class TomlPrimitiveValue extends TomlValue {
  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitPrimitiveValue(this);

  /// Invokes the correct `visit*` method for this value of the given visitor.
  T acceptPrimitiveValueVisitor<T>(TomlPrimitiveValueVisitor<T> visitor);
}
