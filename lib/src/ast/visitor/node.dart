// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.visitor.node;

import 'package:toml/src/ast/document.dart';
import 'package:toml/src/ast/expression.dart';
import 'package:toml/src/ast/key.dart';
import 'package:toml/src/ast/node.dart';
import 'package:toml/src/ast/value.dart';

///
abstract class TomlVisitor<T> {
  /// Visits the given document.
  T visitDocument(TomlDocument document);

  /// Visits the given expression.
  T visitExpression(TomlExpression expr);

  /// Visits the given dotted key.
  T visitKey(TomlKey key);

  /// Visits the given non-dotted key.
  T visitSimpleKey(TomlSimpleKey key);

  /// Visits the given value.
  T visitValue(TomlValue value);

  /// Visits the given [node].
  ///
  /// This method is using [TomlValue.acceptVisitor] to invoke the right
  /// visitor method from above.
  T visit(TomlNode node) => node.acceptVisitor(this);
}
