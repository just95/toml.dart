// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.key;

import 'package:toml/src/ast/node.dart';
import 'package:toml/src/ast/value.dart';

/// AST node that represents a dot separated list of [TomlSimpleKey]s.
///
///     key = simple-key / dotted-key
///     dotted-key = simple-key 1*( dot-sep simple-key )
///
///     dot-sep   = ws %x2E ws  ; . Period
///     keyval-sep = ws %x3D ws ; =
///
/// TODO `dotted-keys` were added in TOML 0.5.0 and have not been fully
/// implemented yet. The keys in key/value pairs must be [TomlSimpleKey]s at
/// the moment. This class is used to represent the names of tables.
class TomlKey extends TomlNode {
  /// The individual [TomlSimpleKey]s that make up this dotted key.
  List<TomlSimpleKey> parts;

  /// Creates a new dotted key.
  TomlKey(Iterable<TomlKey> parts)
      : parts = new List.from(parts, growable: false);
}

/// Base class of all AST nodes that represent simple TOML keys
/// (i.e. non-dotted keys).
///
///     simple-key = quoted-key / unquoted-key
abstract class TomlSimpleKey extends TomlNode {
  /// The actual name of this key.
  String get name;
}

/// AST node that represents a quoted key.
///
///     quoted-key = basic-string / literal-string
class TomlQuotedKey extends TomlSimpleKey {
  /// The string literal that represents this key.
  final TomlValue<String> string;

  TomlQuotedKey(this.string);

  @override
  String get name => string.value;
}

/// AST node that represents an unquoted key.
///
///     unquoted-key = 1*( ALPHA / DIGIT / %x2D / %x5F )
///                  ; A-Z / a-z / 0-9 / - / _
class TomlUnquotedKey extends TomlSimpleKey {
  @override
  final String name;

  TomlUnquotedKey(this.name);
}
