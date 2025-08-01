import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../decoder/parser/whitespace.dart';
import '../expression.dart';
import '../key.dart';
import '../value.dart';
import '../visitor/expression.dart';

/// A TOML expression AST node that represents a key/value pair.
///
///     keyval = key keyval-sep val
@immutable
class TomlKeyValuePair extends TomlExpression {
  /// The separator between the key and value.
  ///
  ///     keyval-sep = ws %x3D ws ; =
  static final String separator = '=';

  /// Parser for a TOML key/value pair.
  static final Parser<TomlKeyValuePair> parser = (
    TomlKey.parser.skip(
      after: tomlWhitespace & char(separator) & tomlWhitespace,
    ),
    TomlValue.parser,
  ).toSequenceParser().map((pair) => TomlKeyValuePair(pair.$1, pair.$2));

  /// The AST node that represents the key of the key/value pair.
  final TomlKey key;

  /// The AST node that represents the value of the key/value pair.
  final TomlValue value;

  /// Creates a new key/value pair.
  TomlKeyValuePair(this.key, this.value);

  @override
  T acceptExpressionVisitor<T>(TomlExpressionVisitor<T> visitor) =>
      visitor.visitKeyValuePair(this);

  @override
  bool operator ==(Object other) =>
      other is TomlKeyValuePair && key == other.key && value == other.value;

  @override
  int get hashCode => Object.hash(key, value);
}
