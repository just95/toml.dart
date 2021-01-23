library toml.src.ast.visitor.value.date_time;

import '../../value/date_time.dart';
import '../../value/date_time/local_date.dart';
import '../../value/date_time/local_date_time.dart';
import '../../value/date_time/local_time.dart';
import '../../value/date_time/offset_date_time.dart';

/// Interface for visitors of [TomlString]s.
abstract class TomlDateTimeVisitor<T> {
  /// Visits the given offset date-time value.
  T visitOffsetDateTime(TomlOffsetDateTime offsetDateTime);

  /// Visits the given local date-time value.
  T visitLocalDateTime(TomlLocalDateTime localDateTime);

  /// Visits the given local date value.
  T visitLocalDate(TomlLocalDate localDate);

  /// Visits the given local time value.
  T visitLocalTime(TomlLocalTime localTime);

  /// Visits the given [value].
  ///
  /// This method is using [TomlDateTime.acceptDateTimeVisitor] to invoke the
  /// right visitor method from above.
  T visitDateTime(TomlDateTime value) => value.acceptDateTimeVisitor(this);
}
