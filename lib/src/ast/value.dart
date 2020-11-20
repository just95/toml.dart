// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/node.dart';
import 'package:toml/src/ast/value/array.dart';
import 'package:toml/src/ast/value/boolean.dart';
import 'package:toml/src/ast/value/datetime.dart';
import 'package:toml/src/ast/value/float.dart';
import 'package:toml/src/ast/value/integer.dart';
import 'package:toml/src/ast/value/string.dart';
import 'package:toml/src/ast/value/table.dart';
import 'package:toml/src/ast/value/visitor.dart';
import 'package:toml/src/parser/util/non_strict.dart';

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
  static TomlValue parse(String input) => parser.end().parse(input).value;

  /// The Dart value of the TOML value represented by this AST node.
  V get value;

  /// The type of the TOML value represented by this AST node.
  TomlType get type;

  /// Invokes the correct `visit*` method for this value of the given
  /// visitor.
  T accept<T>(TomlValueVisitor<T> visitor);
}
