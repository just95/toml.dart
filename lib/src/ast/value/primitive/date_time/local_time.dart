library toml.src.ast.primitive.value.date_time.local_time;

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../../../exception.dart';
import '../../../value.dart';
import '../../../visitor/value/primitive/date_time.dart';
import '../date_time.dart';
import 'local_date_time.dart';

/// AST node that represents a TOML local time value.
///
///     local-time = partial-time
@immutable
class TomlLocalTime extends TomlDateTime {
  /// Parser for a TOML local time value.
  static final Parser<TomlLocalTime> parser =
      TomlPartialTime.parser.map(TomlLocalTime.new);

  /// Parses the given string as a TOML local time.
  static TomlLocalTime parse(String input) =>
      parser.end().parse(input).valueOrTomlException;

  /// The time without time-zone offset.
  final TomlPartialTime time;

  /// Creates a new local time value.
  TomlLocalTime(this.time);

  /// Gets a [TomlLocalDateTime] that represents this time at the given date.
  TomlLocalDateTime atDate(TomlFullDate date) => TomlLocalDateTime(date, time);

  @override
  TomlValueType get type => TomlValueType.localTime;

  @override
  T acceptDateTimeVisitor<T>(TomlDateTimeVisitor<T> visitor) =>
      visitor.visitLocalTime(this);

  @override
  bool operator ==(Object other) =>
      other is TomlLocalTime && time == other.time;

  @override
  int get hashCode => Object.hash(type, time);
}
