// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.parser;

import 'dart:collection';

import 'grammar.dart';
import 'errors.dart';

/// TOML parser definition.
class TomlParserDefinition extends TomlGrammar {

  // -----------------------------------------------------------------
  // Strings values.
  // -----------------------------------------------------------------
  
  escSeq() => super.escSeq().pick(1);
  
  simpleEscSeq() => super.simpleEscSeq().map((String c) {
    if (TomlGrammar.escTable.containsKey(c)) 
      return new String.fromCharCode(TomlGrammar.escTable[c]);
    throw new InvalidEscapeSequenceError('\\$c');
  });
  
  unicodeEscSeq() => super.unicodeEscSeq().pick(1).map(
      (charCode) => new String.fromCharCode(int.parse(charCode, radix: 16))
  );

  whitespaceEscSeq() => super.whitespaceEscSeq().map((_) => '');
  
  // -----------------------------------------------------------------
  // Integer values.
  // -----------------------------------------------------------------
  
  integer() => super.integer().map((str) => int.parse(str.replaceAll('_', '')));

  // -----------------------------------------------------------------
  // Float values.
  // -----------------------------------------------------------------
  
  float() => super.float().map((str) => double.parse(str.replaceAll('_', '')));

  // -----------------------------------------------------------------
  // Boolean values.
  // -----------------------------------------------------------------

  boolean() => super.boolean().map((str) => str == 'true');

  // -----------------------------------------------------------------
  // Datetime values.
  // -----------------------------------------------------------------
  
  datetime() => super.datetime().map(DateTime.parse);

  // -----------------------------------------------------------------
  // Arrays.
  // -----------------------------------------------------------------
  
  arrayOf(v) => super.arrayOf(v).pick(1);
  
  // -----------------------------------------------------------------
  // Tables.
  // -----------------------------------------------------------------
  
  table() => super.table().map((List def) => {
    'type': 'table',
    'parent': def[0].sublist(0, def[0].length - 1),
    'name': def[0].last,
    'pairs': def[1]
  });
  tableHeader() => super.tableHeader().pick(1);
  
  // -----------------------------------------------------------------
  // Array of Tables.
  // -----------------------------------------------------------------

  tableArray() => super.tableArray().map((List def) => {
    'type': 'table-array',
    'parent': def[0].sublist(0, def[0].length - 1),
    'name': def[0].last,
    'pairs': def[1]
  });
  tableArrayHeader() => super.tableArrayHeader().pick(1);
    
  // -----------------------------------------------------------------
  // Key/value pairs.
  // -----------------------------------------------------------------
  
  keyValuePair() => super.keyValuePair().permute([0, 2]).map((List pair) => {
    'key': pair[0],
    'value': pair[1]
  });
  
  // -----------------------------------------------------------------
  // Document.
  // -----------------------------------------------------------------
  
  document() => super.document().map((List content) {
    var doc = {};
    
    // Set of names of defined keys and tables.
    var defined = new Set();
    
    // Add a name to the set above.
    void define(String name) {
     if (defined.contains(name)) throw new RedefinitionError(name);
     defined.add(name);
    }
    
    Function addPairsTo(Map table, [String tableName]) => (Map pair) {
      var name = tableName == null ? pair['key'] : '$tableName.${pair['key']}';
      define(name);
      
      if (table.containsKey(pair['key'])) throw new RedefinitionError(name);
      table[pair['key']] = pair['value'];
    };
    
    // add top level key/value pairs
    content[1].forEach(addPairsTo(doc));
    
    // Iterate over table definitions.
    content[2].forEach((Map def) {
     // Find parent of the new table.
     var parent = doc;
     var name = [];
     def['parent'].forEach((String key) {
       parent = parent.putIfAbsent(key, () => {});
       if (parent is List) {
         key = '$key[${parent.length - 1}]';
         parent = parent.last;
       }
       name.add(key);
       if (parent is! Map)
         throw new NotATableError(name.join('.'));
     });
     name.add(def['name']);
     name = name.join('.');
     
     // Create the table.
     var tbl;
     
     // Array of Tables.
     if (def['type'] == 'table-array') { 
       var arr = parent.putIfAbsent(def['name'], () {
          // Define array.
         define(name);
         return [];
       });
       if (arr is Map) // Overwrite previous table.
         throw new RedefinitionError(name);
       
       var i = arr.length;
       arr.add(tbl = {});
       name = '$name[$i]'; // Tables in arrays are qualified by index.
     }
     else {
       tbl = parent.putIfAbsent(def['name'], () => {});
     }

     // Add key/value pairs.
     define(name);
     def['pairs'].forEach(addPairsTo(tbl, name));
    });
    
    unmodifiable(toml) {
      if (toml is Map) {
        return new UnmodifiableMapView(
          new Map.fromIterables(
            toml.keys, 
            toml.values.map(unmodifiable)
          )
        );
      }
      if (toml is List) {
        return new UnmodifiableListView(
          toml.map(unmodifiable)
        );
      }
      
      return toml;
    }
    
    return unmodifiable(doc);
  });
  
}
