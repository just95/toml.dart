library toml.src.ast.value.primitive.boolean;

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../value.dart';
import '../../visitor/value/primitive.dart';
import '../primitive.dart';

/// AST node that represents a boolean TOML value.
///
///     boolean = true / false
///
///     true    = %x74.72.75.65     ; true
///     false   = %x66.61.6C.73.65  ; false
@immutable
class TomlBoolean extends TomlPrimitiveValue {
  /// Parser for a boolean TOML value.
  static final Parser<TomlBoolean> parser = ChoiceParser([
    string('true').map((_) => TomlBoolean(true)),
    string('false').map((_) => TomlBoolean(false))
  ], failureJoiner: selectFarthestJoined);

  /// The boolean value represented by this node.
  final bool value;

  /// Creates a new boolean value.
  TomlBoolean(this.value);

  @override
  TomlValueType get type => TomlValueType.boolean;

  @override
  T acceptPrimitiveValueVisitor<T>(TomlPrimitiveValueVisitor<T> visitor) =>
      visitor.visitBoolean(this);

  @override
  bool operator ==(Object other) =>
      other is TomlBoolean && value == other.value;

  @override
  int get hashCode => Object.hash(type, value);
}
