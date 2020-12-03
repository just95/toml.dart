// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.node;

import 'package:toml/encoder.dart';

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
