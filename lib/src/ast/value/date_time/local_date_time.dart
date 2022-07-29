library toml.src.ast.value.date_time.local_date_time;

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../../decoder.dart';
import '../../../util/parser.dart';
import '../../value.dart';
import '../../visitor/value/date_time.dart';
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
    TomlPartialTime.parser.skip(before: anyOf('Tt ')),
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

  @override
  TomlType get type => TomlType.localDateTime;

  @override
  T acceptDateTimeVisitor<T>(TomlDateTimeVisitor<T> visitor) =>
      visitor.visitLocalDateTime(this);

  @override
  bool operator ==(Object other) =>
      other is TomlLocalDateTime && date == other.date && time == other.time;

  @override
  int get hashCode => Object.hash(type, date, time);
}
