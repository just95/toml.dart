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
abstract class TomlValueVisitor<T> {
  /// Visits the given array value.
  T visitArray(TomlArray array);

  /// Visits the given boolean value.
  T visitBoolean(TomlBoolean boolean);

  /// Visits the given date or time value.
  T visitDateTime(TomlDateTime dateTime);

  /// Visits the given floating point number.
  T visitFloat(TomlFloat float);

  /// Visits the given integer.
  T visitInteger(TomlInteger integer);

  /// Visits the given string value.
  T visitString(TomlString string);

  /// Visits the given inline table.
  T visitInlineTable(TomlInlineTable inlineTable);

  /// Visits the given [value].
  ///
  /// This method is using [TomlValue.acceptValueVisitor] to invoke the right
  /// visitor method from above.
  T visitValue(TomlValue value) => value.acceptValueVisitor(this);
}
