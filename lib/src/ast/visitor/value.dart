// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.visitor.value;

import 'package:toml/src/ast/value.dart';
import 'package:toml/src/ast/value/array.dart';
import 'package:toml/src/ast/value/boolean.dart';
import 'package:toml/src/ast/value/datetime.dart';
import 'package:toml/src/ast/value/float.dart';
import 'package:toml/src/ast/value/integer.dart';
import 'package:toml/src/ast/value/string.dart';
import 'package:toml/src/ast/value/table.dart';

/// Interface for visitors of [TomlValue]s.
abstract class TomlValueVisitor<T> {
  /// Visits the given array value.
  T visitArray(TomlArray array);

  /// Visits the given boolean value.
  T visitBoolean(TomlBoolean boolean);

  /// Visits the given date-time value.
  T visitDateTime(TomlDateTime datetime);

  /// Visits the given floating point number.
  T visitFloat(TomlFloat float);

  /// Visits the given integer.
  T visitInteger(TomlInteger integer);

  /// Visits the given string value.
  T visitString(TomlString string);

  /// Visits the given inline table.
  T visitInlineTable(TomlInlineTable inlineTable);

  /// Visits the given [value].
  ///
  /// This method is using [TomlValue.acceptValueVisitor] to invoke the right
  /// visitor method from above.
  T visitValue(TomlValue value) => value.acceptValueVisitor(this);
}
