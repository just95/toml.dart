library toml.src.ast.key;

import 'package:petitparser/petitparser.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';
import 'package:toml/src/decoder/exception/parser.dart';
import 'package:toml/src/decoder/parser/whitespace.dart';
import 'package:toml/src/util/parser.dart';

import 'node.dart';
import 'value/string.dart';
import 'visitor/key.dart';
import 'visitor/node.dart';

/// AST node that represents a dot separated list of [TomlSimpleKey]s.
///
///     key = simple-key / dotted-key
///     dotted-key = simple-key 1*( dot-sep simple-key )
class TomlKey extends TomlNode {
  /// Separator for dotted keys.
  ///
  ///     dot-sep   = ws %x2E ws  ; . Period
  static final String separator = '.';

  /// Parser for a dotted TOML key.
  static final Parser<TomlKey> parser = TomlSimpleKey.parser
      .separatedWithout(tomlWhitespace & char(separator) & tomlWhitespace)
      .map((parts) => TomlKey(parts));

  /// Parses the given TOML key.
  ///
  /// Throws a [ParserException] if there is a syntax error.
  static TomlKey parse(String input) =>
      parser.end().parse(input).valueOrTomlException;

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

  /// Gets the last key part (i.e., the name of this key within the table
  /// called [parentKey]).
  TomlSimpleKey get childKey => parts.last;

  /// Creates a new key that identifies the given child in the table identified
  /// by this key.
  TomlKey child(TomlSimpleKey child) => TomlKey(parts + [child]);

  /// Creates a new key that identifies the given deeply nested child in the
  /// table identified by this key.
  TomlKey deepChild(TomlKey child) => TomlKey(parts + child.parts);

  /// Tests whether the [parts] of the given key start with all parts of
  /// this key.
  bool isPrefixOf(TomlKey child) {
    if (child.parts.length < parts.length) return false;
    for (var i = 0; i < parts.length; i++) {
      if (parts[i] != child.parts[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => hashObjects(parts);

  @override
  bool operator ==(Object other) =>
      other is TomlKey && listsEqual(parts, other.parts);

  @override
  T acceptVisitor<T>(TomlVisitor<T> visitor) => visitor.visitKey(this);
}

/// Base class of all AST nodes that represent simple TOML keys
/// (i.e. non-dotted keys).
///
///     simple-key = quoted-key / unquoted-key
abstract class TomlSimpleKey extends TomlNode {
  /// Parser for a simple TOML key.
  static final Parser<TomlSimpleKey> parser =
      ChoiceParser([TomlQuotedKey.parser, TomlUnquotedKey.parser]);

  /// The actual name of this key.
  String get name;

  /// Invokes the correct `visit*` method for this value of the given
  /// visitor.
  T acceptSimpleKeyVisitor<T>(TomlSimpleKeyVisitor<T> visitor);

  @override
  T acceptVisitor<T>(TomlVisitor<T> visitor) => visitor.visitSimpleKey(this);
}

/// AST node that represents a quoted key.
///
///     quoted-key = basic-string / literal-string
class TomlQuotedKey extends TomlSimpleKey {
  /// Parser for a quoted TOML key.
  static final Parser<TomlQuotedKey> parser = TomlSinglelineString.parser
      .map((TomlSinglelineString string) => TomlQuotedKey(string));

  /// The string literal that represents this key.
  final TomlSinglelineString string;

  /// Creates a new quoted key node.
  TomlQuotedKey(this.string);

  @override
  String get name => string.value;

  @override
  T acceptSimpleKeyVisitor<T>(TomlSimpleKeyVisitor<T> visitor) =>
      visitor.visitQuotedKey(this);

  @override
  bool operator ==(Object other) =>
      other is TomlQuotedKey && string == other.string;

  @override
  int get hashCode => string.hashCode;
}

/// AST node that represents an unquoted key.
///
///     unquoted-key = 1*( ALPHA / DIGIT / %x2D / %x5F )
///                  ; A-Z / a-z / 0-9 / - / _
class TomlUnquotedKey extends TomlSimpleKey {
  /// Parser for an unquoted TOML key.
  static final Parser<TomlUnquotedKey> parser = pattern('A-Za-z0-9_-')
      .plus()
      .flatten('Unquoted key expected')
      .map((String name) => TomlUnquotedKey(name));

  /// Tests whether the given key does not have to be quoted.
  static bool canEncode(String key) => parser.end().accept(key);

  @override
  final String name;

  /// Creates a new unquoted key node.
  TomlUnquotedKey(this.name);

  @override
  T acceptSimpleKeyVisitor<T>(TomlSimpleKeyVisitor<T> visitor) =>
      visitor.visitUnquotedKey(this);

  @override
  bool operator ==(Object other) =>
      other is TomlUnquotedKey && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
