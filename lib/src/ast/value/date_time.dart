library toml.src.ast.value.date_time;

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';

import '../../encoder.dart';
import '../../util/container.dart';
import '../../util/date.dart';
import '../../util/parser.dart';
import '../value.dart';
import '../visitor/value.dart';
import '../visitor/value/date_time.dart';
import 'date_time/local_date.dart';
import 'date_time/local_date_time.dart';
import 'date_time/local_time.dart';
import 'date_time/offset_date_time.dart';

/// Praser for four consecutive digits.
Parser<int> _dddd =
    digit().times(4).flatten('Four digit number expected').map(int.parse);

/// Parser for one to three consecutive digits.
Parser<int> _ddd = digit()
    .repeat(1, 3)
    .flatten('Number with one to three digits expected')
    .map((str) => int.parse(str.padRight(3, '0')));

/// Parser for two consecutive digits.
Parser<int> _dd =
    digit().times(2).flatten('Two digit number expected').map(int.parse);

/// A date without time and time-zone offset that is used for the internal
/// representation of TOML date and date-time values.
///
///     full-date      = date-fullyear "-" date-month "-" date-mday
///
///     date-fullyear  = 4DIGIT
///     date-month     = 2DIGIT     ; 01-12
///     date-mday      = 2DIGIT     ; 01-28, 01-29, 01-30, 01-31
///                                 ; based on month/year
@immutable
class TomlFullDate {
  /// Parser for a full date.
  static final Parser<TomlFullDate> parser = SequenceParser([
    _dddd.followedBy(char('-')),
    _dd.followedBy(char('-')),
    _dd,
  ]).map((xs) => TomlFullDate(xs[0], xs[1], xs[2]));

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
  bool operator ==(Object other) =>
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
@immutable
class TomlPartialTime {
  /// Parser for a partial time value with microsecond precision.
  static final Parser<TomlPartialTime> parser = PairParser(
          SequenceParser([
            _dd.followedBy(char(':')),
            _dd.followedBy(char(':')),
            _dd,
          ]),
          char('.').before(_ddd.plus()).optionalWith(<int>[]))
      .map((pair) => TomlPartialTime(
            pair.first[0],
            pair.first[1],
            pair.first[2],
            pair.second,
          ));

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
  /// [microsecond], the third entry is the [nanosecond] and so on. There
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

    // Due to leap seconds, the second is allowed to count up to be `60` and
    // not just `59`.
    if (second < 0 || second > 60) {
      throw ArgumentError('Invalid second: $second');
    }

    for (var secondFraction in secondFractions) {
      if (secondFraction < 0 || secondFraction > 999) {
        throw ArgumentError('Invalid fraction of a second: $secondFraction');
      }
    }
  }

  /// Gets the [i]th entry of [secondFractions] or `0` if it does not exist.
  int getSecondFractions(int i) =>
      i < secondFractions.length ? secondFractions[i] : 0;

  /// The millisecond of the second as a number from `0` to `999`.
  int get millisecond => getSecondFractions(0);

  /// The microsecond of the millisecond as a number from `0` to `999`.
  int get microsecond => getSecondFractions(1);

  /// The nanosecond of the microsecond as a number from `0` to `999`.
  int get nanosecond => getSecondFractions(2);

  @override
  bool operator ==(Object other) =>
      other is TomlPartialTime &&
      hour == other.hour &&
      minute == other.minute &&
      second == other.second &&
      listsEqual(secondFractions, other.secondFractions);

  @override
  int get hashCode => hashObjects([hour, minute, second] + secondFractions);

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
@immutable
class TomlTimeZoneOffset {
  /// Parser for a time-zone offset.
  static final Parser<TomlTimeZoneOffset> parser = ChoiceParser([
    _utcParser,
    _positiveParser,
    _negativeParser,
  ]);

  /// Parser for the UTC time-zone offset.
  static final Parser<TomlTimeZoneOffset> _utcParser =
      anyOf('zZ').map((_) => TomlTimeZoneOffset.utc());

  /// Parser for a positive time-zone offset.
  static final Parser<TomlTimeZoneOffset> _positiveParser = char('+')
      .before(_unsignedParser)
      .map((pair) => TomlTimeZoneOffset.positive(pair.first, pair.second));

  /// Parser for a negative time-zone offset.
  static final Parser<TomlTimeZoneOffset> _negativeParser = char('-')
      .before(_unsignedParser)
      .map((pair) => TomlTimeZoneOffset.negative(pair.first, pair.second));

  /// Parser for an unsigned time-zone offset.
  static final Parser<Pair<int, int>> _unsignedParser =
      PairParser(_dd.followedBy(char(':')), _dd);

  /// Whether this offset identifies the UTC time-zone.
  ///
  /// The UTC time zone offset is semanticvally equivalent to a numeric offset
  /// of `+00:00`.
  final bool isUtc;

  /// Whether the time-zone is behind (`false`) or ahead of UTC (`true`).
  final bool isNegative;

  /// The difference of the time-zone offset to UTC in full hours as a number
  /// from `0` to `23`.
  final int hours;

  /// The remaining minutes to the difference of the time-zone offset to UTC
  /// in minutes as a number from `0` to `59`.
  final int minutes;

  /// Creates a new time-zone offset and validates the ranges of the
  /// [hours] and [minutes] arguments.
  TomlTimeZoneOffset._({
    required this.isUtc,
    required this.isNegative,
    required this.hours,
    required this.minutes,
  }) {
    if (hours < 0 || hours > 23) {
      throw ArgumentError('Invalid hours of time-zone offset: $hours');
    }
    if (minutes < 0 || minutes > 59) {
      throw ArgumentError('Invalid minutes of time-zone offset: $minutes');
    }
  }

  /// Creates the time-zone offset of the UTC time-zone.
  factory TomlTimeZoneOffset.utc() => TomlTimeZoneOffset._(
        isUtc: true,
        isNegative: false,
        hours: 0,
        minutes: 0,
      );

  /// Creates a time-zone offset from the given duration.
  ///
  /// Throws an [ArgumentError] when the given duration does not correspond to
  /// a valid time zone offset.
  factory TomlTimeZoneOffset.fromDuration(Duration offset) =>
      TomlTimeZoneOffset._(
        isUtc: false,
        isNegative: offset.isNegative,
        hours: offset.inHours.abs(),
        minutes: offset.inMinutes.remainder(Duration.minutesPerHour).abs(),
      );

  /// Creates a positive time-zone offset.
  factory TomlTimeZoneOffset.positive(int hours, int minutes) =>
      TomlTimeZoneOffset._(
        isUtc: false,
        isNegative: false,
        hours: hours,
        minutes: minutes,
      );

  /// Creates a negative time-zone offset.
  factory TomlTimeZoneOffset.negative(int hours, int minutes) =>
      TomlTimeZoneOffset._(
        isUtc: false,
        isNegative: true,
        hours: hours,
        minutes: minutes,
      );

  /// Creates a time-zone offset for the local time-zone at the current instant.
  ///
  /// When this constructor is invoked twice and there is a daylight-saving
  /// change between the two invocations, the returned time-zone offsets will
  /// be different.
  factory TomlTimeZoneOffset.local() =>
      TomlTimeZoneOffset.localAtInstant(DateTime.now());

  /// Creates a time-zone offset for the local time-zone at the given [instant].
  ///
  /// Due to daylight-savings the local time zone of a country can change.
  factory TomlTimeZoneOffset.localAtInstant(DateTime instant) =>
      TomlTimeZoneOffset.fromDuration(instant.toLocal().timeZoneOffset);

  /// Converts this time-zone offset to a [Duration].
  Duration toDuration() {
    final duration = Duration(hours: hours, minutes: minutes);
    if (isNegative) return -duration;
    return duration;
  }

  @override
  bool operator ==(Object other) =>
      other is TomlTimeZoneOffset &&
      isUtc == other.isUtc &&
      isNegative == other.isNegative &&
      hours == other.hours &&
      minutes == other.minutes;

  @override
  int get hashCode => hash4(isUtc, isNegative, hours, minutes);

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
  static final Parser<TomlDateTime> parser = ChoiceParser([
    TomlOffsetDateTime.parser,
    TomlLocalDateTime.parser,
    TomlLocalDate.parser,
    TomlLocalTime.parser,
  ], failureJoiner: selectFarthestJoined);

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitDateTime(this);

  /// Invokes the correct `visit*` method for this date or time value of the
  /// given visitor.
  T acceptDateTimeVisitor<T>(TomlDateTimeVisitor<T> visitor);
}
