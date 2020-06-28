// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.decoder.parser;

import 'dart:collection';

import 'package:petitparser/petitparser.dart';

import 'grammar.dart';
import 'exception/invalid_escape_sequence.dart';
import 'exception/not_a_table.dart';
import 'exception/redefinition.dart';

/// TOML parser definition.
class TomlParserDefinition extends TomlGrammar {
  // -----------------------------------------------------------------
  // Strings values.
  // -----------------------------------------------------------------

  @override
  Parser strData(Parser quotes,
          {bool literal = false, bool multiLine = false}) =>
      super.strData(quotes, literal: literal, multiLine: multiLine).flatten();

  @override
  Parser strParser(Parser quotes, {Parser esc, bool multiLine = false}) => super
      .strParser(quotes, esc: esc, multiLine: multiLine)
      .castList()
      .pick(2)
      .map((data) => data.join());

  // -----------------------------------------------------------------
  // Escape Sequences.
  // -----------------------------------------------------------------

  @override
  Parser escSeq() => super.escSeq().castList().pick(1);

  @override
  Parser unicodeEscSeq() => super
      .unicodeEscSeq()
      .castList()
      .pick<String>(1)
      .map((charCode) => String.fromCharCode(int.parse(charCode, radix: 16)));

  @override
  Parser compactEscSeq() =>
      super.compactEscSeq().cast<String>().map((String c) {
        if (TomlGrammar.escTable.containsKey(c)) {
          return String.fromCharCode(TomlGrammar.escTable[c]);
        }
        throw InvalidEscapeSequenceException('\\$c');
      });

  @override
  Parser multiLineEscSeq() => super.multiLineEscSeq().castList().pick(1);

  @override
  Parser whitespaceEscSeq() => super.whitespaceEscSeq().map((_) => '');

  // -----------------------------------------------------------------
  // Integer values.
  // -----------------------------------------------------------------

  @override
  Parser integer() => super
      .integer()
      .flatten()
      .map((str) => int.parse(str.replaceAll('_', '')));

  // -----------------------------------------------------------------
  // Float values.
  // -----------------------------------------------------------------

  @override
  Parser float() => super
      .float()
      .flatten()
      .map((str) => double.parse(str.replaceAll('_', '')));

  // -----------------------------------------------------------------
  // Boolean values.
  // -----------------------------------------------------------------

  @override
  Parser boolean() => super.boolean().map((str) => str == 'true');

  // -----------------------------------------------------------------
  // Datetime values.
  // -----------------------------------------------------------------

  @override
  Parser datetime() => super.datetime().flatten().map(DateTime.parse);

  // -----------------------------------------------------------------
  // Arrays.
  // -----------------------------------------------------------------

  @override
  Parser arrayOf(Parser valueParser) =>
      super.arrayOf(valueParser).castList().pick(1);

  // -----------------------------------------------------------------
  // Tables.
  // -----------------------------------------------------------------

  @override
  Parser table() => super.table().castList().map((List def) => {
        'type': 'table',
        'parent': def[0].sublist(0, def[0].length - 1),
        'name': def[0].last,
        'pairs': def[1]
      });
  @override
  Parser tableHeader() => super.tableHeader().castList().pick(1);

  // -----------------------------------------------------------------
  // Array of Tables.
  // -----------------------------------------------------------------

  @override
  Parser tableArray() => super.tableArray().castList().map((List def) => {
        'type': 'table-array',
        'parent': def[0].sublist(0, def[0].length - 1),
        'name': def[0].last,
        'pairs': def[1]
      });
  @override
  Parser tableArrayHeader() => super.tableArrayHeader().castList().pick(1);

  // -----------------------------------------------------------------
  // Inline Tables.
  // -----------------------------------------------------------------

  @override
  Parser inlineTable() =>
      super.inlineTable().castList().pick<List<Map>>(1).map((List<Map> pairs) {
        var map = <String, dynamic>{};
        pairs.forEach((Map pair) {
          map[pair['key'] as String] = pair['value'];
        });
        return map;
      });

  // -----------------------------------------------------------------
  // Keys.
  // -----------------------------------------------------------------

  @override
  Parser bareKey() => super.bareKey().flatten();

  // -----------------------------------------------------------------
  // Key/value pairs.
  // -----------------------------------------------------------------

  @override
  Parser keyValuePair() => super
      .keyValuePair()
      .castList()
      .permute([0, 2]).map((List pair) => {'key': pair[0], 'value': pair[1]});

  // -----------------------------------------------------------------
  // Document.
  // -----------------------------------------------------------------

  @override
  Parser document() => super.document().castList().map((List content) {
        var doc = <String, dynamic>{};

        // Set of names of defined keys and tables.
        var defined = <String>{};

        // Add a name to the set above.
        void define(String name) {
          if (defined.contains(name)) throw RedefinitionException(name);
          defined.add(name);
        }

        Function addPairsTo(Map table, [String tableName]) =>
            (Map<String, dynamic> pair) {
              var name = tableName == null
                  ? pair['key'] as String
                  : '$tableName.${pair['key']}';
              define(name);

              if (table.containsKey(pair['key'])) {
                throw RedefinitionException(name);
              }
              table[pair['key']] = pair['value'];
            };

        // add top-level key/value pairs
        var topLevelDefinitions = content[1].cast<Map<String, dynamic>>();
        topLevelDefinitions.forEach(addPairsTo(doc));

        // Iterate over table definitions.
        var tableDefinitions = content[2].cast<Map<String, dynamic>>();
        tableDefinitions.forEach((Map<String, dynamic> def) {
          // Find parent of the new table.
          var parent = doc;
          var nameParts = [];
          def['parent'].cast<String>().forEach((String key) {
            var child = parent.putIfAbsent(key, () => <String, dynamic>{});
            if (child is List) {
              key = '$key[${child.length - 1}]';
              child = child.last;
            }
            nameParts.add(key);
            if (child is Map<String, dynamic>) {
              parent = child;
            } else {
              throw NotATableException(nameParts.join('.'));
            }
          });
          nameParts.add(def['name']);
          var name = nameParts.join('.');

          // Create the table.
          var table = <String, dynamic>{};

          // Array of Tables.
          if (def['type'] == 'table-array') {
            var arr = parent.putIfAbsent(def['name'] as String, () {
              // Define array.
              define(name);
              return [];
            });

            // Add new table to array of tables or throw an error if this
            // is not an array of tables.
            if (arr is List) {
              // The name of the table is qualified with
              var i = arr.length;
              arr.add(table);
              name = '$name[$i]';
              define(name);
            } else {
              throw RedefinitionException(name);
            }
          } else {
            // Add table to parent table or lookup implicitly created table.
            var tbl = parent.putIfAbsent(def['name'] as String, () => table);
            define(name);

            // Throw an exception if the parent table does contain a value
            // already which is not an implicitly created table.
            if (tbl is Map<String, dynamic>) {
              table = tbl;
            } else {
              throw NotATableException(name);
            }
          }

          // Add key/value pairs.
          def['pairs']
              .cast<Map<String, dynamic>>()
              .forEach(addPairsTo(table, name));
        });

        dynamic unmodifiable(dynamic toml) {
          if (toml is Map<String, dynamic>) {
            return UnmodifiableMapView(
                Map.fromIterables(toml.keys, toml.values.map(unmodifiable)));
          }
          if (toml is List) {
            return UnmodifiableListView(toml.map(unmodifiable));
          }

          return toml;
        }

        return unmodifiable(doc);
      });
}

/// A TOML document parser.
class TomlParser extends GrammarParser {
  /// Creates a new parser for TOML documents.
  TomlParser() : super(TomlParserDefinition());

  /// Since [GrammarParser] does not have a type argument, we have to
  /// override [parse] to fix the return type.
  @override
  Result<Map<String, dynamic>> parse(String input) =>
      super.parse(input).map((dynamic res) => res as Map<String, dynamic>);
}
