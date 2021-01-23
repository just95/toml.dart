library toml.src.ast.value.local_date;

import 'package:petitparser/petitparser.dart';
import 'package:quiver/core.dart';

import '../../value.dart';
import '../../visitor/value/date_time.dart';
import '../date_time.dart';

/// AST node that represents a TOML local date value.
///
///     local-date = full-date
class TomlLocalDate extends TomlDateTime {
  /// Parser for a TOML local date value.
  static final Parser<TomlLocalDate> parser =
      TomlFullDate.parser.map((date) => TomlLocalDate(date));

  /// The date.
  final TomlFullDate date;

  /// Creates a new local date value.
  TomlLocalDate(this.date);

  @override
  TomlType get type => TomlType.localDate;

  @override
  T acceptDateTimeVisitor<T>(TomlDateTimeVisitor<T> visitor) =>
      visitor.visitLocalDate(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlLocalDate && date == other.date;

  @override
  int get hashCode => hash2(type, date);
}
