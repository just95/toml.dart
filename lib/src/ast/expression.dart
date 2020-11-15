// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.expression;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/expression/key_value_pair.dart';
import 'package:toml/src/ast/expression/table.dart';
import 'package:toml/src/ast/expression/visitor.dart';
import 'package:toml/src/ast/node.dart';
import 'package:toml/src/parser/util/whitespace.dart';

/// Base class of all TOML expression nodes.
///
/// Expressions are either [TomlKeyValuePair]s or [TomlTable]s.
///
///     expression =  ws [ comment ]
///     expression =/ ws keyval ws [ comment ]
///     expression =/ ws table ws [ comment ]
abstract class TomlExpression extends TomlNode {
  /// Parser for TOML expressions.
  ///
  /// Returns `null` if the expression is just a blank line or comment.
  static final Parser<TomlExpression> parser = (tomlWhitespace &
          (TomlKeyValuePair.parser | TomlTable.parser).optional() &
          tomlWhitespace &
          tomlComment.optional())
      .pick<TomlExpression>(1);

  /// Invokes the correct `visit*` method for this expression of the given
  /// visitor.
  T accept<T>(TomlExpressionVisitor<T> visitor);
}
