library toml.src.ast.visitor.value;

import '../value.dart';
import '../value/array.dart';
import '../value/boolean.dart';
import '../value/date_time.dart';
import '../value/float.dart';
import '../value/integer.dart';
import '../value/string.dart';
import '../value/table.dart';

/// Interface for visitors of [TomlValue]s.
abstract class TomlValueVisitor<R> {
  /// Visits the given array value.
  R visitArray(TomlArray array);

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

  /// Visits the given inline table.
  R visitInlineTable(TomlInlineTable inlineTable);
}

/// Mixin that adds a [visitValue] method to classes implementing
/// [TomlValueVisitor] that automatically selects the appropriate
/// visitor method using [TomlValue.acceptValueVisitor].
///
/// This class is usually used when the visitor also implements the
/// [TomlVisitor] interface to provide a default implementation for
/// [TomlVisitor.visitValue].
mixin TomlValueVisitorMixin<R> implements TomlValueVisitor<R> {
  /// Visits the given [value].
  ///
  /// This method is using [TomlValue.acceptValueVisitor] to invoke the right
  /// visitor method from above.
  R visitValue(TomlValue value) => value.acceptValueVisitor(this);
}
