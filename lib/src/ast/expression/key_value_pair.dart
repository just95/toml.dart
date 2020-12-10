library toml.src.ast.expression.key_value_pair;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';

import '../expression.dart';
import '../key.dart';
import '../value.dart';
import '../visitor/expression.dart';

/// A TOML expression AST node that represents a key/value pair.
///
///     keyval = key keyval-sep val
///
/// TODO `dotted-key`s were added in TOML 0.5.0 and are not fully implemented
/// yet. The left-hand side of a key/value pair must be a [TomlSimpleKey] at
/// the moment.
class TomlKeyValuePair extends TomlExpression {
  /// The separator between the key and value.
  ///
  ///     keyval-sep = ws %x3D ws ; =
  static final String separator = '=';

  /// Parser for a TOML key/value pair.
  static final Parser<TomlKeyValuePair> parser = (TomlSimpleKey.parser &
          tomlWhitespace &
          char(separator) &
          tomlWhitespace &
          TomlValue.parser)
      .permute([0, 4]).map((List pair) => TomlKeyValuePair(
            pair[0] as TomlSimpleKey,
            pair[1] as TomlValue,
          ));

  /// The AST node that represents the key of the key/value pair.
  final TomlSimpleKey key;

  /// The AST node that represents the value of the key/value pair.
  final TomlValue value;

  /// Creates a new key/value pair.
  TomlKeyValuePair(this.key, this.value);

  @override
  T acceptExpressionVisitor<T>(TomlExpressionVisitor<T> visitor) =>
      visitor.visitKeyValuePair(this);
}
