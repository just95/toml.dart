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
  Parser strData(String quotes, {bool literal: false, bool multiLine: false}) =>
      super.strData(quotes, literal: literal, multiLine: multiLine).flatten();

  @override
  Parser strParser(String quotes, {Parser esc, bool multiLine: false}) => super
      .strParser(quotes, esc: esc, multiLine: multiLine)
      .pick(2)
      .map((data) => data.join());

  // -----------------------------------------------------------------
  // Escape Sequences.
  // -----------------------------------------------------------------

  @override
  Parser escSeq() => super.escSeq().pick(1);

  @override
  Parser unicodeEscSeq() => super.unicodeEscSeq().pick(1).map(
      (charCode) => new String.fromCharCode(int.parse(charCode, radix: 16)));

  @override
  Parser compactEscSeq() => super.compactEscSeq().map((String c) {
        if (TomlGrammar.escTable.containsKey(c)) {
          return new String.fromCharCode(TomlGrammar.escTable[c]);
        }
        throw new InvalidEscapeSequenceException('\\$c');
      });

  @override
  Parser multiLineEscSeq() => super.multiLineEscSeq().pick(1);

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
  Parser arrayOf(Parser valueParser) => super.arrayOf(valueParser).pick(1);

  // -----------------------------------------------------------------
  // Tables.
  // -----------------------------------------------------------------

  @override
  Parser table() => super.table().map((List def) => {
        'type': 'table',
        'parent': def[0].sublist(0, def[0].length - 1),
        'name': def[0].last,
        'pairs': def[1]
      });
  @override
  Parser tableHeader() => super.tableHeader().pick(1);

  // -----------------------------------------------------------------
  // Array of Tables.
  // -----------------------------------------------------------------

  @override
  Parser tableArray() => super.tableArray().map((List def) => {
        'type': 'table-array',
        'parent': def[0].sublist(0, def[0].length - 1),
        'name': def[0].last,
        'pairs': def[1]
      });
  @override
  Parser tableArrayHeader() => super.tableArrayHeader().pick(1);

  // -----------------------------------------------------------------
  // Inline Tables.
  // -----------------------------------------------------------------

  @override
  Parser inlineTable() => super.inlineTable().pick(1).map((List pairs) {
        var map = {};
        pairs.forEach((Map pair) {
          map[pair['key']] = pair['value'];
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
      .permute([0, 2]).map((List pair) => {'key': pair[0], 'value': pair[1]});

  // -----------------------------------------------------------------
  // Document.
  // -----------------------------------------------------------------

  @override
  Parser document() => super.document().map((List content) {
        var doc = {};

        // Set of names of defined keys and tables.
        var defined = new Set();

        // Add a name to the set above.
        void define(String name) {
          if (defined.contains(name)) throw new RedefinitionException(name);
          defined.add(name);
        }

        Function addPairsTo(Map table, [String tableName]) => (Map pair) {
              var name =
                  tableName == null ? pair['key'] : '$tableName.${pair['key']}';
              define(name);

              if (table.containsKey(pair['key']))
                throw new RedefinitionException(name);
              table[pair['key']] = pair['value'];
            };

        // add top level key/value pairs
        content[1].forEach(addPairsTo(doc));

        // Iterate over table definitions.
        content[2].forEach((Map def) {
          // Find parent of the new table.
          var parent = doc;
          var nameParts = [];
          def['parent'].forEach((String key) {
            var child = parent.putIfAbsent(key, () => {});
            if (child is List) {
              key = '$key[${child.length - 1}]';
              child = child.last;
            }
            nameParts.add(key);
            if (child is Map) {
              parent = child;
            } else {
              throw new NotATableException(nameParts.join('.'));
            }
          });
          nameParts.add(def['name']);
          var name = nameParts.join('.');

          // Create the table.
          var tbl;

          // Array of Tables.
          if (def['type'] == 'table-array') {
            var arr = parent.putIfAbsent(def['name'], () {
              // Define array.
              define(name);
              return [];
            });

            // Overwrite previous table.
            if (arr is Map) throw new RedefinitionException(name);

            var i = arr.length;
            arr.add(tbl = {});
            name = '$name[$i]'; // Tables in arrays are qualified by index.
          } else {
            tbl = parent.putIfAbsent(def['name'], () => {});
          }

          // Add key/value pairs.
          define(name);
          def['pairs'].forEach(addPairsTo(tbl, name));
        });

        dynamic unmodifiable(dynamic toml) {
          if (toml is Map) {
            return new UnmodifiableMapView(new Map.fromIterables(
                toml.keys, toml.values.map(unmodifiable)));
          }
          if (toml is List) {
            return new UnmodifiableListView(toml.map(unmodifiable));
          }

          return toml;
        }

        return unmodifiable(doc);
      });
}

/// A TOML document parser.
class TomlParser extends GrammarParser {
  /// Creates a new parser for TOML documents.
  TomlParser() : super(new TomlParserDefinition());
}
