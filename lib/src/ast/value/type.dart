library toml.src.ast.value.type;

/// The possible types of [TomlValue]s.
enum TomlValueType {
  /// The type of a TOML array.
  array,

  /// The type of a boolean value.
  boolean,

  /// The type of a floating point number.
  float,

  /// The type of an integer.
  integer,

  /// The type of all variations of TOML strings.
  string,

  /// The type of an inline table.
  table,

  /// The type of an offset date-time.
  offsetDateTime,

  /// The type of a local date-time.
  localDateTime,

  /// The type of a local date.
  localDate,

  /// The type of a local time.
  localTime,
}
