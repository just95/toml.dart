library toml.src.ast.visitor.value.primitive;

import '../../value/primitive.dart';
import '../../value/primitive/boolean.dart';
import '../../value/primitive/date_time.dart';
import '../../value/primitive/float.dart';
import '../../value/primitive/integer.dart';
import '../../value/primitive/string.dart';

/// Interface for visitors of [TomlPrimitiveValue]s.
abstract class TomlPrimitiveValueVisitor<R> {
  /// Visits the given boolean value.
  R visitBoolean(TomlBoolean boolean);

  /// Visits the given date or time value.
  R visitDateTime(TomlDateTime dateTime);

  /// Visits the given floating point number.
  R visitFloat(TomlFloat float);

  /// Visits the given integer.
  R visitInteger(TomlInteger integer);

  /// Visits the given string value.
  R visitString(TomlString string);
}

/// Mixin that adds a [visitPrimitiveValue] method to classes implementing
/// [TomlPrimitiveValueVisitor] that automatically selects the appropriate
/// visitor method using [TomlValue.acceptPrimitiveValueVisitor].
///
/// This class is usually used when the visitor also implements the
/// [TomlVisitor] interface to provide a default implementation for
/// [TomlVisitor.visitValue].
mixin TomlPrimitiveValueVisitorMixin<R>
    implements TomlPrimitiveValueVisitor<R> {
  /// Visits the given [value].
  ///
  /// This method is using [TomlValue.acceptValueVisitor] to invoke the right
  /// visitor method from above.
  R visitPrimitiveValue(TomlPrimitiveValue value) =>
      value.acceptPrimitiveValueVisitor(this);
}
