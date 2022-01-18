library toml.src.ast.primitive.value.date_time.offset_date_time;

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../../../exception.dart';
import '../../../../util/parser.dart';
import '../../../value.dart';
import '../../../visitor/value/primitive/date_time.dart';
import '../date_time.dart';

/// AST node that represents a TOML offset date-time value.
///
///     offset-date-time = full-date time-delim full-time
///
///     time-delim     = "T" / %x20 ; T, t, or space
///     full-time      = partial-time time-offset
@immutable
class TomlOffsetDateTime extends TomlDateTime {
  /// Parser for a TOML offset date-time value.
  static final Parser<TomlOffsetDateTime> parser = PairParser(
      TomlFullDate.parser,
      PairParser(
        anyOf('Tt ').before(TomlPartialTime.parser),
        TomlTimeZoneOffset.parser,
      )).map((pair) => TomlOffsetDateTime(
        pair.first,
        pair.second.first,
        pair.second.second,
      ));

  /// Parses the given string as a TOML offset date-time.
  static TomlOffsetDateTime parse(String input) =>
      parser.end().parse(input).valueOrTomlException;

  /// The date.
  final TomlFullDate date;

  /// The time without time-zone offset.
  final TomlPartialTime time;

  /// The time-zone offset of the date-time.
  final TomlTimeZoneOffset offset;

  /// Creates a new offset date-time value.
  TomlOffsetDateTime(this.date, this.time, this.offset);

  /// Converts a [DateTime] to a TOML offset date-time value.
  TomlOffsetDateTime.fromDateTime(DateTime dateTime)
      : this(
            TomlFullDate(dateTime.year, dateTime.month, dateTime.day),
            TomlPartialTime(
              dateTime.hour,
              dateTime.minute,
              dateTime.second,
              dateTime.microsecond > 0
                  ? [dateTime.millisecond, dateTime.microsecond]
                  : dateTime.millisecond > 0
                      ? [dateTime.millisecond]
                      : [],
            ),
            dateTime.isUtc
                ? TomlTimeZoneOffset.utc()
                : TomlTimeZoneOffset.fromDuration(dateTime.timeZoneOffset));

  /// Converts this AST node to an UTC [DateTime] object.
  DateTime toUtcDateTime() => DateTime.utc(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
        time.second,
        time.millisecond,
        time.microsecond,
      ).subtract(offset.toDuration());

  @override
  TomlType get type => TomlType.offsetDateTime;

  @override
  T acceptDateTimeVisitor<T>(TomlDateTimeVisitor<T> visitor) =>
      visitor.visitOffsetDateTime(this);

  @override
  bool operator ==(Object other) =>
      other is TomlOffsetDateTime &&
      time == other.time &&
      date == other.date &&
      offset == other.offset;

  @override
  int get hashCode => Object.hash(type, date, time, offset);
}
