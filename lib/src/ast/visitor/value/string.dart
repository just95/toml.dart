// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.visitor.string;

import 'package:toml/src/ast/value/string.dart';
import 'package:toml/src/ast/value/string/basic.dart';
import 'package:toml/src/ast/value/string/literal.dart';
import 'package:toml/src/ast/value/string/ml_basic.dart';
import 'package:toml/src/ast/value/string/ml_literal.dart';

/// Interface for visitors of [TomlStrings]s.
abstract class TomlStringVisitor<T> {
  /// Visits the given basic string.
  T visitBasicString(TomlBasicString string);

  /// Visits the given literal string.
  T visitLiteralString(TomlLiteralString string);

  /// Visits the given multiline basic string.
  T visitMultilineBasicString(TomlMultilineBasicString string);

  /// Visits the given multiline literal string.
  T visitMultilineLiteralString(TomlMultilineLiteralString string);

  /// Visits the given [value].
  ///
  /// This method is using [TomlString.acceptStringVisitor] to invoke the right
  /// visitor method from above.
  T visitString(TomlString value) => value.acceptStringVisitor(this);
}
