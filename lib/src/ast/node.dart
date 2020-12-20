library toml.src.ast.node;

import 'package:toml/src/encoder.dart';

import 'visitor/node.dart';

/// Base class of all TOML AST nodes.
///
/// The [hashCode] and [operator==] methods should be overwritten by
/// subclasses such that they check for deep equality of the data structure.
/// For example, a quoted and an unquoted key with the same
/// name are not considered equal and two inline tables are only equal if
/// all key/value pairs are equal and in the same order. It is most often not
/// correct to use [TomlNode]s as keys of hash maps.
///
/// The [toString] method is overwritten such that the AST is pretty printed
/// with TOML syntax. See [TomlPrettyPrinter] for details.
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
