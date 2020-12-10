library toml.src.ast.value.boolean;

import 'package:petitparser/petitparser.dart';

import '../value.dart';
import '../visitor/value.dart';

/// AST node that represents a boolean TOML value.
///
///     boolean = true / false
///
///     true    = %x74.72.75.65     ; true
///     false   = %x66.61.6C.73.65  ; false
class TomlBoolean extends TomlValue<bool> {
  /// Parser for a boolean TOML value.
  static final Parser<TomlBoolean> parser =
      (string('true').map((_) => TomlBoolean(true)) |
              string('false').map((_) => TomlBoolean(false)))
          .cast<TomlBoolean>();

  @override
  final bool value;

  /// Creates a new boolean value.
  TomlBoolean(this.value);

  @override
  TomlType get type => TomlType.boolean;

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitBoolean(this);
}
