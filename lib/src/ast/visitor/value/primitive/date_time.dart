library toml.src.ast.visitor.value.primitive.date_time;

import '../../../value/primitive/date_time.dart';
import '../../../value/primitive/date_time/local_date.dart';
import '../../../value/primitive/date_time/local_date_time.dart';
import '../../../value/primitive/date_time/local_time.dart';
import '../../../value/primitive/date_time/offset_date_time.dart';

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
}

/// Mixin that adds a [visitDateTime] method to classes implementing
/// [TomlDateTimeVisitor] that automatically selects the appropriate
/// visitor method using [TomlDateTime.acceptDateTimeVisitor].
///
/// This class is usually used when the visitor also implements the
/// [TomlValueVisitor] interface to provide a default implementation
/// for [TomlValueVisitor.visitDateTime].
mixin TomlDateTimeVisitorMixin<R> implements TomlDateTimeVisitor<R> {
  /// Visits the given [value].
  ///
  /// This method is using [TomlDateTime.acceptDateTimeVisitor] to invoke the
  /// right visitor method from above.
  R visitDateTime(TomlDateTime value) => value.acceptDateTimeVisitor(this);
}
