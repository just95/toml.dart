library toml.src.ast.value.compound;

import '../value.dart';
import '../visitor/value.dart';
import '../visitor/value/compound.dart';

/// Base class for AST nodes that represent TOML values that consist of other
/// TOML values, i.e., arrays and inline tables.
abstract class TomlCompoundValue extends TomlValue {
  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitCompoundValue(this);

  /// Invokes the correct `visit*` method for this value of the given visitor.
  T acceptCompoundValueVisitor<T>(TomlCompoundValueVisitor<T> visitor);
}
