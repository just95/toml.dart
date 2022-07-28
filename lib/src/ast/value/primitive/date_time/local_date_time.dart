library toml.src.ast.primitive.value.date_time.local_date_time;

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../../../exception.dart';
import '../../../../util/parser.dart';
import '../../../visitor/value/primitive/date_time.dart';
import '../../type.dart';
import '../date_time.dart';
import '../date_time/offset_date_time.dart';

/// AST node that represents a TOML local date-time value.
///
///     local-date-time = full-date time-delim partial-time
///
///     time-delim     = "T" / %x20 ; T, t, or space
@immutable
class TomlLocalDateTime extends TomlDateTime {
  /// Parser for a TOML local date-time value.
  static final Parser<TomlLocalDateTime> parser = PairParser(
    TomlFullDate.parser,
    anyOf('Tt ').before(TomlPartialTime.parser),
  ).map((pair) => TomlLocalDateTime(pair.first, pair.second));

  /// Parses the given string as a TOML local date-time.
  static TomlLocalDateTime parse(String input) =>
      parser.end().parse(input).valueOrTomlException;

  /// The date.
  final TomlFullDate date;

  /// The time.
  final TomlPartialTime time;

  /// Creates a new local date-time value.
  TomlLocalDateTime(this.date, this.time);

  /// Interprets this local date-time as an offset date-time in the given
  /// time-zone.
  TomlOffsetDateTime withOffset(TomlTimeZoneOffset offset) =>
      TomlOffsetDateTime(date, time, offset);

  /// Converts this AST node to a [DateTime] object in the local time zone.
  DateTime toLocalDateTime() => DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
        time.second,
        time.millisecond,
        time.microsecond,
      );

  @override
  TomlValueType get type => TomlValueType.localDateTime;

  @override
  T acceptDateTimeVisitor<T>(TomlDateTimeVisitor<T> visitor) =>
      visitor.visitLocalDateTime(this);

  @override
  bool operator ==(Object other) =>
      other is TomlLocalDateTime && date == other.date && time == other.time;

  @override
  int get hashCode => Object.hash(type, date, time);
}
