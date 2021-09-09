library toml.src.ast.decoder.map_builder;

import '../accessor/tree/to_value.dart';
import '../ast.dart';
import 'accessor_builder.dart';
import 'value_builder.dart';

/// A visitor for [TomlExpression]s that builds a [Map] from a TOML document.
class TomlMapBuilder extends TomlAccessorBuilder {
  /// Builds the map for the visited AST nodes.
  Map<String, dynamic> build() => topLevel.toMap(TomlValueBuilder());
}
