library toml.src.ast.expression;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';

import 'expression/key_value_pair.dart';
import 'expression/table.dart';
import 'node.dart';
import 'visitor/expression.dart';
import 'visitor/node.dart';

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
  T acceptExpressionVisitor<T>(TomlExpressionVisitor<T> visitor);

  @override
  T acceptVisitor<T>(TomlVisitor<T> visitor) => visitor.visitExpression(this);
}
