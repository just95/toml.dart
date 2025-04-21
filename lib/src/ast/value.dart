library toml.src.ast.value;

import 'package:petitparser/petitparser.dart';

import '../decoder/exception/parser.dart';
import '../encoder.dart';
import '../util/parser.dart';
import 'node.dart';
import 'value/array.dart';
import 'value/boolean.dart';
import 'value/date_time.dart';
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

/// Base class for AST nodes that represent TOML values.
///
///     val = string
///         / boolean
///         / array
///         / inline-table
///         / date-time
///         / float
///         / integer
abstract class TomlValue extends TomlNode {
  /// Parser for a TOML value.
  ///
  /// We have to use a [LateParser] since values (arrays for example)
  /// can contain values themselves. If we didn't use [LateParser], the
  /// initialization of [parser] would be cyclic which is not allowed.
  ///
  /// It is important that `TomlDateTime` and `TomlFloat` and are parsed before
  /// `TomlInteger`, since a `TomlDateTime` and a `TomlFloat` can start with a
  /// `TomlInteger`.
  static final Parser<TomlValue> parser = LateParser(
    () => ChoiceParser<TomlValue>([
      TomlDateTime.parser,
      TomlFloat.parser,
      TomlInteger.parser,
      TomlBoolean.parser,
      TomlString.parser,
      TomlArray.parser,
      TomlInlineTable.parser,
    ], failureJoiner: selectFarthestJoined).orFailure('value expected'),
  );

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
  factory TomlValue.from(dynamic value) => TomlAstBuilder().buildValue(value);

  /// The type of the TOML value represented by this AST node.
  TomlType get type;

  /// Invokes the correct `visit*` method for this value of the given
  /// visitor.
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor);

  @override
  T acceptVisitor<T>(TomlVisitor<T> visitor) => visitor.visitValue(this);
}
