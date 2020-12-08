// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.encoder.ast_builder;

import 'package:toml/ast.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';

import 'encodable.dart';
import 'exception/unknown_value_type.dart';
import 'exception/mixed_array_types.dart';

/// A builder for various TOML AST nodes.
class TomlAstBuilder {
  /// Builds a TOML document from the given map.
  TomlDocument buildDocument(Map<String, dynamic> map) {
    var pairs = map.entries.map(buildKeyValuePair);
    var expressions = _removeRedundantHeaders(
      _expandKeyValuePairs(pairs, prefix: TomlKey.topLevel),
    );
    return TomlDocument(expressions);
  }

  /// Converts key/value pairs whose value is an inline table or an array of
  /// inline tables to standard tables or arrays of tables.
  Iterable<TomlExpression> _expandKeyValuePairs(
    Iterable<TomlKeyValuePair> pairs, {
    TomlKey prefix,
  }) sync* {
    // Filter all tables and arrays of tables.
    var tables = <Iterable<TomlExpression> Function()>[];
    for (var pair in pairs) {
      // Test whether the value is an inline table.
      var key = pair.key, value = pair.value;
      if (value is TomlInlineTable) {
        tables.add(() sync* {
          var name = prefix.child(key);
          yield TomlStandardTable(name);
          yield* _expandKeyValuePairs(value.pairs, prefix: name);
        });
        continue;
      }

      // Test whether the value is an array of inline tables.
      if (value is TomlArray &&
          value.items.isNotEmpty &&
          value.items.every((item) => item is TomlInlineTable)) {
        tables.add(() sync* {
          var name = prefix.child(key);
          for (var item in value.items.cast<TomlInlineTable>()) {
            yield TomlArrayTable(name);
            yield* _expandKeyValuePairs(item.pairs, prefix: name);
          }
        });
        continue;
      }

      // Otherwise keep the key/value pair.
      yield pair;
    }

    // Add tables and array tables after the key/value pairs.
    for (var table in tables) {
      yield* table();
    }
  }

  /// Removes standard table headers that are not needed because the table
  /// contains no key/value pairs or arrays of tables.
  ///
  /// This method assumes that the tables are sorted such that parent tables
  /// immediately preceed their child tables A table header can be removed
  /// if the corresponding expression is followed by a a table header for
  /// a child table immediately.
  Iterable<TomlExpression> _removeRedundantHeaders(
    Iterable<TomlExpression> expressions,
  ) sync* {
    TomlStandardTable lastTable;
    for (var expression in expressions) {
      if (expression is TomlStandardTable) {
        if (lastTable != null && !lastTable.name.isPrefixOf(expression.name)) {
          // The last table header is not redundant even though the table
          // does not have any key/value pairs because this table header
          // does not create it implicitly. We keep the table header to
          // preserve the empty table.
          yield lastTable;
        }
        lastTable = expression;
        continue;
      } else if (lastTable != null) {
        // The last table header is followed by a key/value pair or an array
        // of tables. Thus, we need to keep it.
        yield lastTable;
        lastTable = null;
      }
      yield expression;
    }

    // If there is an empty table at the end of the document, we want to
    // preserve it.
    if (lastTable != null) yield lastTable;
  }

  // --------------------------------------------------------------------------
  // Key/Value Pairs
  // --------------------------------------------------------------------------

  /// Builds a key valie pair from the given map entry.
  TomlKeyValuePair buildKeyValuePair(MapEntry<String, dynamic> entry) =>
      TomlKeyValuePair(buildSimpleKey(entry.key), buildValue(entry.value));

  // --------------------------------------------------------------------------
  // Keys
  // --------------------------------------------------------------------------

  /// Creates a key from the given string.
  ///
  /// This method preferably creates unquoted keys. If the key contains
  /// characters that are not allowed in unquoted keys, a quoted key is created
  /// instead. Whether a quoted key is a literal or basic string is determined
  /// by the rules of [buildSinglelineString].
  TomlSimpleKey buildSimpleKey(String key) {
    if (TomlUnquotedKey.canEncode(key)) return TomlUnquotedKey(key);
    return TomlQuotedKey(buildSinglelineString(key));
  }

  // --------------------------------------------------------------------------
  // Values
  // --------------------------------------------------------------------------

  /// Converts a [TomlEncodable] object to an object which TOML can represent.
  ///
  /// [TomlEncodable.toToml] will be repeatedly applied on [value] until the
  /// return value is representable by TOML.
  /// Returns [value] if it is not an instance of [TomlEncodable].
  dynamic unwrapValue(dynamic value) {
    while (value is TomlEncodable) {
      value = value.toToml();
    }
    return value;
  }

  /// Builds a [TomlValue] for the given [value] or throws a
  /// [UnknownValueTypeException] if the value cannot be represented by TOML.
  TomlValue buildValue(dynamic value) {
    value = unwrapValue(value);
    if (value is int) return TomlInteger(value);
    if (value is double) return TomlFloat(value);
    if (value is bool) return TomlBoolean(value);
    if (value is DateTime) return TomlDateTime(value);
    if (value is String) return buildString(value);
    if (value is Iterable) return buildArray(value);
    if (value is Map<String, dynamic>) return buildInlineTable(value);
    throw TomlUnknownValueTypeException(value);
  }

  /// Converts the given string to a [TomlString].
  ///
  /// If [allowMultiline] is set to `true` and the given string contains
  /// newlines, a multiline string is created (see [buildMultilineString]).
  /// Otherwise a singleline string is created (see [buildSinglelineString]).
  ///
  /// In both cases a literal string is created preferably. A basic string is
  /// created only if the string contains characters that are not allowed in
  /// literal strings.
  TomlString buildString(String str, {bool allowMultiline = true}) {
    if (allowMultiline && isMultilineString(str)) {
      return buildMultilineString(str);
    }
    return buildSinglelineString(str);
  }

  /// Builds a singleline TOML string with the given value.
  TomlSinglelineString buildSinglelineString(String str) =>
      TomlLiteralString.canEncode(str)
          ? TomlLiteralString(str)
          : TomlBasicString(str);

  /// Builds a multiline TOML string with the given value.
  TomlMultilineString buildMultilineString(String str) =>
      TomlMultilineLiteralString.canEncode(str)
          ? TomlMultilineLiteralString(str)
          : TomlMultilineBasicString(str);

  /// Tests whether the given string contains newlines and thus should be
  /// encoded as a multiline string if possible.
  bool isMultilineString(String str) => str.contains(tomlNewlinePattern);

  /// Converts the given items to TOML values and creates a [TomlArray]
  /// from those values.
  ///
  /// If there are values of different types a [TomlMixedArrayTypesException]
  /// is thrown. In JavaScript the array is allowed to contain integers
  /// and floats. This is because [int] and [double] cannot be distinguished
  /// in this case. If different number types are mixed, all value of the
  /// array will be converted to floats.
  TomlArray buildArray(Iterable items) {
    var array = TomlArray(items.map(buildValue));
    var types = array.itemTypes.toSet();

    // Test whether the array is heterogenous.
    if (types.length > 1) {
      // In JavaScript integers and floats are allowed to be mixed.
      if (identical(1, 1.0) &&
          types.length == 2 &&
          types.contains(TomlType.integer) &&
          types.contains(TomlType.float)) {
        return TomlArray(
          array.items.map((item) => TomlFloat(item.value as double)),
        );
      }

      // Otherwise arrays must be homogenous.
      throw TomlMixedArrayTypesException(array);
    }

    // The array is homogenous.
    return array;
  }

  /// Converts the given map to an inline table.
  TomlInlineTable buildInlineTable(Map<String, dynamic> map) =>
      TomlInlineTable(map.entries.map(buildKeyValuePair));
}
