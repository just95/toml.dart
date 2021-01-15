library toml.src.ast.document;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';
import 'package:toml/src/encoder.dart';
import 'package:toml/src/loader.dart';
import 'package:quiver/collection.dart';

import 'expression.dart';
import 'node.dart';
import 'visitor/node.dart';

/// Abstract syntax tree for a TOML document.
///
///     toml = expression *( newline expression )
class TomlDocument extends TomlNode {
  /// Parser for TOML documents.
  ///
  /// If an `expression` is just a blank line or comment,
  /// [TomlExpression.parser] returns `null`. These expressions
  /// are not part of the AST and must be filtered out.
  static final Parser<TomlDocument> parser = TomlExpression.parser
      .separatedBy<TomlExpression>(tomlNewline, includeSeparators: false)
      .map((expressions) =>
          TomlDocument(expressions.where((expression) => expression != null)));

  /// Parses the given TOML document.
  ///
  /// Throws a [ParserException] if there is a syntax error.
  static TomlDocument parse(String input) =>
      parser.end().parse(input).valueOrTomlException;

  /// Loads the file with the given name and [parse]s the contents as a
  /// TOML document.
  ///
  /// Throws a [ParserException] if there is a syntax error.
  ///
  /// Uses HTTP to load the file when the code is running in the browser and
  /// loads the file from the local file system when the code is running in
  /// the Dart VM or natively.
  static Future<TomlDocument> load(String filename) async =>
      parse(await loadFile(filename));

  /// The table headers and key/value pairs of the TOML document.
  final List<TomlExpression> expressions;

  /// Creates a TOML document with the given expressions.
  TomlDocument(Iterable<TomlExpression> expressions)
      : expressions = List.from(expressions, growable: false);

  /// Creates a TOML document from the given map.
  factory TomlDocument.fromMap(Map map) => TomlAstBuilder().buildDocument(map);

  /// Converts this document to a map from keys to values.
  Map<String, dynamic> toMap() {
    var builder = TomlMapBuilder();
    expressions.forEach(builder.visitExpression);
    return builder.build();
  }

  @override
  T acceptVisitor<T>(TomlVisitor<T> visitor) => visitor.visitDocument(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlDocument && listsEqual(expressions, other.expressions);

  @override
  int get hashCode => expressions.hashCode;
}
