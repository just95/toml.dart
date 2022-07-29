library toml.src.accessor.tree.decode;

import '../../ast/value/primitive/date_time.dart';
import '../../ast/value/primitive/date_time/local_date_time.dart';
import '../../exception.dart';
import '../tree.dart';
import 'match.dart';

/// An extension that adds methods to accessors to convert the TOML values
/// to a Dart values.
extension TomlAccessorDecodeExtension on TomlAccessor {
  /// Gets the value of this accessor as a [bool].
  ///
  /// Throws a [TomlValueTypeException] when this is not an accessor for a
  /// TOML boolean value.
  bool asBool() => match(
        boolean: (boolean) => boolean.value,
      );

  /// Gets the value of this accessor as a [BigInt].
  ///
  /// Throws a [TomlValueTypeException] when this is not an accessor for a
  /// TOML integer value.
  BigInt asBigInt() => match(
        integer: (integer) => integer.value,
      );

  /// Gets the value of this accessor as an [int].
  ///
  /// Throws a [TomlValueTypeException] when this is not an accessor for a
  /// TOML integer value.
  ///
  /// **Warning:** Due to the differences in integer precision, the conversion
  /// may succeed on some platforms but throw on others given the same input.
  /// When the integer cannot be represented as an [int] without losing
  /// precision a [TomlInvalidIntException] is thrown.
  int asInt() => match(integer: (integer) {
        if (integer.value.isValidInt) return integer.value.toInt();
        throw TomlInvalidIntException(integer);
      });

  /// Gets the value of this accessor as a [double].
  ///
  /// Throws a [TomlValueTypeException] when this is neither an accessor for a
  /// TOML float nor integer value. To disable the conversion of integer values
  /// to floats set the [allowInteger] flag to `false`.
  ///
  /// If the conversion from an integer value is enabled (default) and the
  /// integer cannot be represented as a [double] without loss of precision, an
  /// approximation is returned. The approximation may be non-finite in case of
  /// numerically large integers.
  double asDouble({bool allowInteger = true}) => match(
        float: (float) => float.value,
        integer: allowInteger ? (integer) => integer.value.toDouble() : null,
      );

  /// Gets the value of this accessor as a [String].
  ///
  /// Throws a [TomlValueTypeException] when this is not an accessor for a
  /// TOML string value.
  String asString() => match(
        string: (string) => string.value,
      );

  /// Gets the value of this accessor as a [DateTime].
  ///
  /// Throws a [TomlValueTypeException] when this is not an accessor for one
  /// of the following:
  ///  - a TOML offset date-time,
  ///  - a TOML local date-time,
  ///  - a TOML local date and [defaultTime] is not `null` or
  ///  - a TOML local time and [defaultDate] is not `null`.
  ///
  /// If this is an offset date-time, the returned [DateTime] is an UTC
  /// date-time.
  ///
  /// If this is a local date-time, local date or local time and
  /// [defaultTimeZoneOffset] is specified, the returned [DateTime] is an UTC
  /// date-time adjusted by the given offset. Without a default time zone
  /// offset, the returned [DateTime] is in the local time zone.
  ///
  /// If this is a local time or local date, the missing date or time have
  /// to be specified via [defaultDate] or [defaultTime], respectively.
  DateTime asDateTime({
    TomlTimeZoneOffset? defaultTimeZoneOffset,
    TomlPartialTime? defaultTime,
    TomlFullDate? defaultDate,
  }) {
    DateTime convertLocalDateTime(TomlLocalDateTime localDateTime) =>
        defaultTimeZoneOffset == null
            ? localDateTime.toLocalDateTime()
            : localDateTime.withOffset(defaultTimeZoneOffset).toUtcDateTime();

    return match(
      offsetDateTime: (offsetDateTime) => offsetDateTime.toUtcDateTime(),
      localDateTime: convertLocalDateTime,
      localDate: defaultTime != null
          ? (localDate) => convertLocalDateTime(localDate.atTime(defaultTime))
          : null,
      localTime: defaultDate != null
          ? (localTime) => convertLocalDateTime(localTime.atDate(defaultDate))
          : null,
    );
  }
}
