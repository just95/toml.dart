library toml.src.ast.expression;

import 'package:petitparser/petitparser.dart';

import '../decoder/parser/whitespace.dart';
import '../util/parser.dart';
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
  static final Parser<TomlExpression?> parser = ChoiceParser<TomlExpression>([
    TomlKeyValuePair.parser,
    TomlTable.parser,
  ], failureJoiner: selectFarthestJoined)
      .optional()
      .surroundedBy(tomlWhitespace)
      .followedBy(tomlComment.optional());

  /// Invokes the correct `visit*` method for this expression of the given
  /// visitor.
  T acceptExpressionVisitor<T>(TomlExpressionVisitor<T> visitor);

  @override
  T acceptVisitor<T>(TomlVisitor<T> visitor) => visitor.visitExpression(this);
}
