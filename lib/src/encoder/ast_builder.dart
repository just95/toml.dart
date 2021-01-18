library toml.src.encoder.ast_builder;

import 'package:toml/src/ast.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';

import 'encodable.dart';
import 'exception/mixed_array_types.dart';
import 'exception/unknown_key_type.dart';
import 'exception/unknown_value_type.dart';

/// A builder for various TOML AST nodes.
class TomlAstBuilder {
  /// Builds a TOML document from the given map.
  TomlDocument buildDocument(Map map) {
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
          var name = prefix.deepChild(key);
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
          var name = prefix.deepChild(key);
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
  TomlKeyValuePair buildKeyValuePair(MapEntry entry) => TomlKeyValuePair(
        TomlKey([buildSimpleKey(entry.key)]),
        buildValue(entry.value),
      );

  // --------------------------------------------------------------------------
  // Keys
  // --------------------------------------------------------------------------

  /// Converts a [TomlEncodableKey] to an object which TOML can represent as a
  /// key.
  ///
  /// [TomlEncodableKey.toTomlKey] will be repeatedly applied on [value] until
  /// the return value is representable by TOML as a key.
  /// Returns [value] if it is not an instance of [TomlEncodableKey].
  dynamic unwrapKey(dynamic value) {
    while (value is TomlEncodableKey) {
      value = value.toTomlKey();
    }
    return value;
  }

  /// Creates a key from the given string.
  ///
  /// This method preferably creates unquoted keys. If the key contains
  /// characters that are not allowed in unquoted keys, a quoted key is created
  /// instead. Whether a quoted key is a literal or basic string is determined
  /// by the rules of [buildSinglelineString].
  TomlSimpleKey buildSimpleKey(dynamic key) {
    key = unwrapKey(key);
    if (key is String) {
      if (TomlUnquotedKey.canEncode(key)) return TomlUnquotedKey(key);
      return TomlQuotedKey(buildSinglelineString(key));
    }
    throw TomlUnknownKeyTypeException(key);
  }

  // --------------------------------------------------------------------------
  // Values
  // --------------------------------------------------------------------------

  /// Converts a [TomlEncodableValue] to an object which TOML can represent.
  ///
  /// [TomlEncodableValue.toTomlValue] will be repeatedly applied on [value]
  /// until the return value is representable by TOML.
  /// Returns [value] if it is not an instance of [TomlEncodableValue].
  dynamic unwrapValue(dynamic value) {
    while (value is TomlEncodableValue) {
      value = value.toTomlValue();
    }
    return value;
  }

  /// Builds a [TomlValue] for the given [value] or throws a
  /// [TomlUnknownValueTypeException] if the value cannot be represented by
  /// TOML.
  TomlValue buildValue(dynamic value) {
    value = unwrapValue(value);
    if (value is int) return TomlInteger.dec(BigInt.from(value));
    if (value is BigInt) return TomlInteger.dec(value);
    if (value is double) return TomlFloat(value);
    if (value is bool) return TomlBoolean(value);
    if (value is DateTime) return TomlDateTime(value);
    if (value is String) return buildString(value);
    if (value is Iterable) return buildArray(value);
    if (value is Map) return buildInlineTable(value);
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
        return TomlArray(array.items.map((item) {
          if (item is TomlFloat) return item;
          if (item is TomlInteger) return TomlFloat(item.value as double);
          throw ArgumentError('Expected number, but got ${item.type}.');
        }));
      }

      // Otherwise arrays must be homogenous.
      throw TomlMixedArrayTypesException(array);
    }

    // The array is homogenous.
    return array;
  }

  /// Converts the given map to an inline table.
  TomlInlineTable buildInlineTable(Map map) =>
      TomlInlineTable(map.entries.map(buildKeyValuePair));
}
