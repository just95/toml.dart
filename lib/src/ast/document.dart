// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.document;

import 'package:toml/src/ast/expression.dart';
import 'package:toml/src/ast/node.dart';

/// Abstract syntax tree for a TOML document.
///
///     toml = expression *( newline expression )
class TomlDocument extends TomlNode {
  /// The table headers and key/value pairs of the TOML document.
  final List<TomlExpression> expressions;

  /// Creates a TOML document with the given expressions.
  TomlDocument(Iterable<TomlExpression> expressions)
      : expressions = List.from(expressions, growable: false);
}
