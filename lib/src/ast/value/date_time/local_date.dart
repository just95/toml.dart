library toml.src.ast.value.date_time.local_date;

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../../decoder.dart';
import '../../value.dart';
import '../../visitor/value/date_time.dart';
import '../date_time.dart';
import 'local_date_time.dart';

/// AST node that represents a TOML local date value.
///
///     local-date = full-date
@immutable
class TomlLocalDate extends TomlDateTime {
  /// Parser for a TOML local date value.
  static final Parser<TomlLocalDate> parser = TomlFullDate.parser.map(
    TomlLocalDate.new,
  );

  /// Parses the given string as a TOML local date.
  static TomlLocalDate parse(String input) =>
      parser.end().parse(input).valueOrTomlException;

  /// The date.
  final TomlFullDate date;

  /// Creates a new local date value.
  TomlLocalDate(this.date);

  /// Gets a [TomlLocalDateTime] that represents the given time at this date.
  TomlLocalDateTime atTime(TomlPartialTime time) =>
      TomlLocalDateTime(date, time);

  @override
  TomlType get type => TomlType.localDate;

  @override
  T acceptDateTimeVisitor<T>(TomlDateTimeVisitor<T> visitor) =>
      visitor.visitLocalDate(this);

  @override
  bool operator ==(Object other) =>
      other is TomlLocalDate && date == other.date;

  @override
  int get hashCode => Object.hash(type, date);
}
