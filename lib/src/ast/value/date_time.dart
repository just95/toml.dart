library toml.src.ast.value.date_time;

import 'package:petitparser/petitparser.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';
import 'package:toml/src/encoder.dart';
import 'package:toml/src/util/date.dart';

import '../value.dart';
import '../visitor/value.dart';
import '../visitor/value/date_time.dart';
import 'date_time/local_date.dart';
import 'date_time/local_date_time.dart';
import 'date_time/local_time.dart';
import 'date_time/offset_date_time.dart';

/// Praser for four consecutive digits.
Parser<int> _dddd = digit().times(4).flatten().map(int.parse);

/// Parser for one to three consecutive digits.
Parser<int> _ddd = digit()
    .repeat(1, 3)
    .flatten()
    .map((str) => int.parse(str.padRight(3, '0')));

/// Parser for two consecutive digits.
Parser<int> _dd = digit().times(2).flatten().map(int.parse);

/// A date without time and time-zone offset that is used for the internal
/// representation of TOML date and date-time values.
///
///     full-date      = date-fullyear "-" date-month "-" date-mday
///
///     date-fullyear  = 4DIGIT
///     date-month     = 2DIGIT     ; 01-12
///     date-mday      = 2DIGIT     ; 01-28, 01-29, 01-30, 01-31
///                                 ; based on month/year
class TomlFullDate {
  /// Parser for a full date.
  static final Parser<TomlFullDate> parser =
      (_dddd & char('-') & _dd & char('-') & _dd)
          .permute([0, 2, 4])
          .castList<int>()
          .map((xs) => TomlFullDate(xs[0], xs[1], xs[2]));

  /// The full year.
  final int year;

  /// The month as a number from `1` to `12`.
  final int month;

  /// The day of [month] as a number from `1` to `28`, `29`, `30` or `31`
  /// depending on the [year] and [month].
  final int day;

  /// Creates a full date.
  ///
  /// Throws an [ArgumentError] when the given date is invalid.
  TomlFullDate(this.year, this.month, this.day) {
    if (month < 1 || month > 12) {
      var mm = month.toString().padLeft(2, '0');
      throw ArgumentError('Invalid month: $mm');
    }
    if (day < 1 || day > year.daysOfMonth(month)) {
      var yyyy = year.toString().padLeft(4, '0');
      var mm = month.toString().padLeft(2, '0');
      throw ArgumentError('Invalid day of month $yyyy-$mm: $day');
    }
  }

  @override
  bool operator ==(dynamic other) =>
      other is TomlFullDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => hash3(year, month, day);

  @override
  String toString() {
    var printer = TomlPrettyPrinter();
    printer.printFullDate(this);
    return printer.toString();
  }
}

/// A time without time-zone offset that is used for the internal
/// representation of TOML time and date-time values.
///
///     partial-time   =
///         time-hour ":" time-minute ":" time-second [ time-secfrac ]
///
///     time-hour      = 2DIGIT     ; 00-23
///     time-minute    = 2DIGIT     ; 00-59
///     time-second    = 2DIGIT     ; 00-58, 00-59, 00-60
///                                 ; based on leap second rules
///     time-secfrac   = "." 1*DIGIT
class TomlPartialTime {
  /// Parser for a partial time value with microsecond precision.
  static final Parser<TomlPartialTime> parser =
      ((_dd & char(':') & _dd & char(':') & _dd)
                  .permute([0, 2, 4]).castList<int>() &
              (char('.') & _ddd.plus()).pick<List<int>>(1).optional([]))
          .castList<List<int>>()
          .map((xs) => TomlPartialTime(xs[0][0], xs[0][1], xs[0][2], xs[1]));

  /// The hour of the day, expressed as in a 24-hour clock (as a number from
  /// `0` to `23`).
  final int hour;

  /// The minute of the hour as a number from `0` to `59`.
  final int minute;

  /// The second of the minute as a number from `0` to `58`, `59` or `60`
  /// based on leap seconds.
  final int second;

  /// The fractions of the second as numbers from `0` to `999`.
  ///
  /// The first entry are is the [millisecond], the second entry is the
  /// [microsend], the third entry is the [nanosecond] and so on. There
  /// are no getters for more than [nanosecond] precision but a
  /// [TomlPartialTime] can represent fractions of a second of arbitrary
  /// precision.
  ///
  /// Two otherwise equal [TomlPartialTime] values are not considered equal if
  /// their [secondFractions] differ in the number of trailing zeros.
  /// For example, the time `TomlPartialTime(20, 17, 40)` is not equal to
  /// the value `TomlPartialTime(20, 17, 40, [0])`,
  final List<int> secondFractions;

  /// Creates a partial time.
  ///
  /// Throws an [ArgumentError] when any of the given values is invalid.
  /// When no exception is thrown, the time is not necessarily valid on
  /// every date and in every time-zone.
  TomlPartialTime(
    this.hour,
    this.minute,
    this.second, [
    List<int> secondFractions = const [],
  ]) : secondFractions = List.from(secondFractions, growable: false) {
    if (hour < 0 || hour > 23) throw ArgumentError('Invalid hour: $hour');
    if (minute < 0 || minute > 59) {
      throw ArgumentError('Invalid minute: $minute');
    }

    // Due to leap seconds, the second is allowed to count up to be `60` anot
    // not just `59`.
    if (second < 0 || second > 60) {
      throw ArgumentError('Invalid second: $second');
    }
  }

  int getSecondFractions(int i) =>
      i < secondFractions.length ? secondFractions[i] : 0;

  /// The millisecond of the second as a number from `0` to `999`.
  int get millisecond => getSecondFractions(0);

  /// The microsecond of the millisecond as a number from `0` to `999`.
  int get microsecond => getSecondFractions(1);

  /// The nanosecond of the microsecond as a number from `0` to `999`.
  int get nanosecond => getSecondFractions(2);

  @override
  bool operator ==(dynamic other) =>
      other is TomlPartialTime &&
      hour == other.hour &&
      minute == other.minute &&
      second == other.second &&
      listsEqual(secondFractions, other.secondFractions);

  @override
  int get hashCode => hashObjects([hour, minute, second, secondFractions]);

  @override
  String toString() {
    var printer = TomlPrettyPrinter();
    printer.printPartialTime(this);
    return printer.toString();
  }
}

/// A time-zone offset that is used for the representation of
/// TOML date-time values.
///
///     time-offset    = "Z" / time-numoffset
///     time-numoffset = ( "+" / "-" ) time-hour ":" time-minute
class TomlTimeZoneOffset {
  /// Parser for a time-zone offset.
  static final Parser<TomlTimeZoneOffset> parser =
      (_utcParser | _positiveParser | _negativeParser)
          .cast<TomlTimeZoneOffset>();

  /// Parser for the UTC time-zone offset.
  static final Parser<TomlTimeZoneOffset> _utcParser =
      anyOf('zZ').map((_) => TomlTimeZoneOffset.utc());

  /// Parser for a positive time-zone offset.
  static final Parser<TomlTimeZoneOffset> _positiveParser =
      (char('+') & _dd & char(':') & _dd)
          .permute([1, 3])
          .castList<int>()
          .map((xs) => TomlTimeZoneOffset.positive(xs[0], xs[1]));

  /// Parser for a negative time-zone offset.
  static final Parser<TomlTimeZoneOffset> _negativeParser =
      (char('-') & _dd & char(':') & _dd)
          .permute([1, 3])
          .castList<int>()
          .map((xs) => TomlTimeZoneOffset.negative(xs[0], xs[1]));

  /// Whether this offset identifies the UTC time-zone.
  ///
  /// The UTC time zone offset is semanticvally equivalent to a numeric offset
  /// of `+00:00`.
  final bool isUtc;

  /// Whether the time-zone is behind (`false`) or ahead of UTC (`true`).
  final bool isNegative;

  /// The difference of the time-zone offset to UTC in full hours.
  final int hours;

  /// The remaining minutes to the difference of the time-zone offset to UTC
  /// in minutes.
  final int minutes;

  /// Creates the time-zone offset of the UTC time-zone.
  TomlTimeZoneOffset.utc()
      : isUtc = true,
        isNegative = false,
        hours = 0,
        minutes = 0;

  /// Creates a time-zone offset from the given [duration].
  TomlTimeZoneOffset.fromDuration(Duration offset)
      : isUtc = false,
        isNegative = offset.isNegative,
        hours = offset.inHours.remainder(Duration.hoursPerDay).abs() as int,
        minutes =
            offset.inMinutes.remainder(Duration.minutesPerHour).abs() as int;

  /// Creates a positive time-zone offset.
  TomlTimeZoneOffset.positive(int hours, int minutes)
      : this.fromDuration(Duration(hours: hours, minutes: minutes));

  /// Creates a negative time-zone offset.
  TomlTimeZoneOffset.negative(int hours, int minutes)
      : this.fromDuration(-Duration(hours: hours, minutes: minutes));

  /// Creates a time-zone offset for the local time-zone.
  TomlTimeZoneOffset.local() : this.fromDuration(DateTime.now().timeZoneOffset);

  /// Converts this time-zone offset to a [Duration].
  Duration toDuration() {
    final duration = Duration(hours: hours, minutes: minutes);
    if (isNegative) return -duration;
    return duration;
  }

  @override
  bool operator ==(dynamic other) =>
      other is TomlTimeZoneOffset &&
      isUtc == other.isUtc &&
      isNegative == other.isNegative &&
      hours == other.hours &&
      minutes == other.minutes;

  @override
  int get hashCode => hashObjects([isUtc, isNegative, hours, minutes]);

  @override
  String toString() {
    var printer = TomlPrettyPrinter();
    printer.printTimeZoneOffset(this);
    return printer.toString();
  }
}

/// Base class of AST nodes that represents TOML date, time and date-time
/// values.
///
///     date-time      = offset-date-time
///                    / local-date-time
///                    / local-date
///                    / local-time
abstract class TomlDateTime extends TomlValue {
  /// Parser for a TOML date, time or date-time value.
  static final Parser<TomlDateTime> parser = (TomlOffsetDateTime.parser |
          TomlLocalDateTime.parser |
          TomlLocalDate.parser |
          TomlLocalTime.parser)
      .cast<TomlDateTime>();

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitDateTime(this);

  /// Invokes the correct `visit*` method for this date or time value of the
  /// given visitor.
  T acceptDateTimeVisitor<T>(TomlDateTimeVisitor<T> visitor);
}
