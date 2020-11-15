// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.key;

import 'package:petitparser/petitparser.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

import 'package:toml/src/ast/node.dart';
import 'package:toml/src/ast/value/string.dart';
import 'package:toml/src/ast/value/string/basic.dart';
import 'package:toml/src/ast/value/string/literal.dart';
import 'package:toml/src/parser/util/whitespace.dart';

/// AST node that represents a dot separated list of [TomlSimpleKey]s.
///
///     key = simple-key / dotted-key
///     dotted-key = simple-key 1*( dot-sep simple-key )
///     dot-sep   = ws %x2E ws  ; . Period
///
/// TODO `dotted-keys` were added in TOML 0.5.0 and have not been fully
/// implemented yet. The keys in key/value pairs must be [TomlSimpleKey]s at
/// the moment. This class is used to represent the names of tables.
class TomlKey extends TomlNode {
  /// Parser for a dotted TOML key.
  static final Parser<TomlKey> parser = TomlSimpleKey.parser
      .separatedBy<TomlSimpleKey>(tomlWhitespace & char('.') & tomlWhitespace,
          includeSeparators: false)
      .map((List<TomlSimpleKey> parts) => TomlKey(parts));

  /// Parses the given TOML key.
  ///
  /// Throws a [ParserException] if there is a syntax error.
  static TomlKey parse(String input) => parser.end().parse(input).value;

  /// A key that identifies the top-level table.
  static TomlKey topLevel = TomlKey([]);

  /// The individual [TomlSimpleKey]s that make up this dotted key.
  final List<TomlSimpleKey> parts;

  /// Creates a new dotted key with the given parts.
  TomlKey(Iterable<TomlSimpleKey> parts)
      : parts = List.from(parts, growable: false);

  /// Gets a key for the parent table of this key.
  ///
  /// If this key identifies the [topLevel] table, a key for the [topLevel]
  /// table is returned.
  TomlKey get parentKey => TomlKey(parts.take(parts.length - 1));

  /// Gets the last key part (i.e., the name of this key within [parent]).
  TomlSimpleKey get childKey => parts.last;

  /// Creates a new key that identifies the given child in the table identified
  /// by this key.
  TomlKey child(TomlSimpleKey child) => TomlKey(parts + [child]);

  @override
  int get hashCode => hashObjects(parts);

  @override
  bool operator ==(Object other) =>
      other is TomlKey && listsEqual(parts, other.parts);
}

/// Base class of all AST nodes that represent simple TOML keys
/// (i.e. non-dotted keys).
///
///     simple-key = quoted-key / unquoted-key
abstract class TomlSimpleKey extends TomlNode {
  /// Parser for a simple TOML key.
  static final Parser<TomlSimpleKey> parser =
      (TomlQuotedKey.parser | TomlUnquotedKey.parser).cast<TomlSimpleKey>();

  /// The actual name of this key.
  String get name;

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is TomlSimpleKey && name == other.name;
}

/// AST node that represents a quoted key.
///
///     quoted-key = basic-string / literal-string
class TomlQuotedKey extends TomlSimpleKey {
  /// Parser for a quoted TOML key.
  static final Parser<TomlQuotedKey> parser =
      (TomlBasicString.parser | TomlLiteralString.parser)
          .cast<TomlString>()
          .map((TomlString string) => TomlQuotedKey(string));

  /// The string literal that represents this key.
  final TomlString string;

  /// Creates a new quoted key node.
  TomlQuotedKey(this.string);

  @override
  String get name => string.value;
}

/// AST node that represents an unquoted key.
///
///     unquoted-key = 1*( ALPHA / DIGIT / %x2D / %x5F )
///                  ; A-Z / a-z / 0-9 / - / _
class TomlUnquotedKey extends TomlSimpleKey {
  /// Parser for an unquoted TOML key.
  static final Parser<TomlUnquotedKey> parser = pattern('A-Za-z0-9_-')
      .plus()
      .flatten()
      .map((String name) => TomlUnquotedKey(name));

  @override
  final String name;

  /// Creates a new unquoted key node.
  TomlUnquotedKey(this.name);
}
