library toml.src.ast.node;

import 'package:toml/src/encoder.dart';

import 'visitor/node.dart';

/// Base class of all TOML AST nodes.
abstract class TomlNode {
  /// Invokes the correct `visit*` method for this value of the given
  /// visitor.
  T acceptVisitor<T>(TomlVisitor<T> visitor);

  @override
  String toString() {
    var printer = TomlPrettyPrinter();
    printer.visit(this);
    return printer.toString();
  }
}
