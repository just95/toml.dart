library toml.src.ast.visitor.value.date_time;

import '../../value/date_time.dart';
import '../../value/date_time/local_date.dart';
import '../../value/date_time/local_date_time.dart';
import '../../value/date_time/local_time.dart';
import '../../value/date_time/offset_date_time.dart';

/// Interface for visitors of [TomlString]s.
abstract class TomlDateTimeVisitor<R> {
  /// Visits the given offset date-time value.
  R visitOffsetDateTime(TomlOffsetDateTime offsetDateTime);

  /// Visits the given local date-time value.
  R visitLocalDateTime(TomlLocalDateTime localDateTime);

  /// Visits the given local date value.
  R visitLocalDate(TomlLocalDate localDate);

  /// Visits the given local time value.
  R visitLocalTime(TomlLocalTime localTime);

  /// Visits the given [value].
  ///
  /// This method is using [TomlDateTime.acceptDateTimeVisitor] to invoke the
  /// right visitor method from above.
  R visitDateTime(TomlDateTime value) => value.acceptDateTimeVisitor(this);
}
