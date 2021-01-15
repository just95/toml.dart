library toml.src.ast.value;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/exception/parser.dart';
import 'package:toml/src/decoder/parser/util/non_strict.dart';
import 'package:toml/src/encoder.dart';

import 'key.dart';
import 'node.dart';
import 'value/array.dart';
import 'value/boolean.dart';
import 'value/datetime.dart';
import 'value/float.dart';
import 'value/integer.dart';
import 'value/string.dart';
import 'value/table.dart';
import 'visitor/node.dart';
import 'visitor/value.dart';

/// The possible types of [TomlValue]s.
enum TomlType {
  /// The type of a TOML array.
  array,

  /// The type of a boolean value.
  boolean,

  /// The type of a datetime.
  datetime,

  /// The type of a floating point number.
  float,

  /// The type of an integer.
  integer,

  /// The type of all variations of TOML strings.
  string,

  /// The type of an inline table.
  table
}

/// Base class for AST nodes that represent TOML values.
///
///     val = string
///         / boolean
///         / array
///         / inline-table
///         / date-time
///         / float
///         / integer
abstract class TomlValue<V> extends TomlNode {
  /// Parser for a TOML value.
  ///
  /// We have to use a [NonStrictParser] since values (arrays for example)
  /// can contain values themselves. If we didn't use [NonStrictParser], the
  /// initialization of [parser] would be cyclic which is not allowed.
  ///
  /// It is important that `TomlDateTime` and `TomlFloat` and are parsed before
  /// `TomlInteger`, since a `TomlDateTime` and a `TomlFloat` can start with a
  /// `TomlInteger`.
  static final Parser<TomlValue> parser = NonStrictParser(() =>
      (TomlDateTime.parser |
              TomlFloat.parser |
              TomlInteger.parser |
              TomlBoolean.parser |
              TomlString.parser |
              TomlArray.parser |
              TomlInlineTable.parser)
          .cast<TomlValue>());

  /// Parses the given TOML value.
  ///
  /// Throws a [ParserException] if there is a syntax error.
  static TomlValue parse(String input) =>
      parser.end().parse(input).valueOrTomlException;

  /// Since there is a factory constructor, we have to provide the default
  /// constructor explicitly such that instances of subclasses can be created.
  TomlValue();

  /// Converts the given value to a TOML value.
  ///
  /// Throws a [TomlUnknownValueTypeException] when the given value cannot be
  /// encoded by TOML.
  factory TomlValue.from(V value) =>
      TomlAstBuilder().buildValue(value) as TomlValue<V>;

  /// The Dart value of the TOML value represented by this AST node.
  V get value;

  /// The type of the TOML value represented by this AST node.
  TomlType get type;

  /// Builds the Dart [value] of the TOML value represented by this AST node.
  ///
  /// This should always return the same value as the [value] getter but the
  /// given fully qualified name of the key/value pair can be used to improve
  /// error messages.
  V buildValue(TomlKey key) => value;

  /// Invokes the correct `visit*` method for this value of the given
  /// visitor.
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor);

  @override
  T acceptVisitor<T>(TomlVisitor<T> visitor) => visitor.visitValue(this);
}
