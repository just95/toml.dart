#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:toml/toml.dart';

/// A script that converts TOML documents to JSON.
///
/// If multiple TOML documents are converted, the contents of the documents
/// is [merge]d.
Future main(List<String> args) async {
  if (args.any((arg) => arg == '--help' || arg == '-h')) {
    stderr
      ..writeln('Usage: ${Platform.script.pathSegments.last} [INPUT-FILE...]')
      ..writeln('')
      ..writeln('Converts TOML documents to JSON. If multiple TOML documents')
      ..writeln('are specified, the resulting hash maps are merged before they')
      ..writeln('are converted to JSON.')
      ..writeln('')
      ..writeln('Reads from stdin when no input file is specified.');
    return;
  }

  // Convert TOML document on stdin if no file has been specified.
  var merged = <String, dynamic>{};
  if (args.isEmpty) {
    var input = await stdin.transform(utf8.decoder).join();
    merged = TomlDocument.parse(input).toMap();
  }

  // Load every input file and merge the resulting hash maps.
  for (var file in args) {
    var document = await TomlDocument.load(file);
    merged = merge(merged, document.toMap());
  }

  // Convert the merged hash map to a JSON document.
  var encoder = JsonEncoder.withIndent('  ', (obj) => obj.toString());
  print(encoder.convert(merged));
}

/// Merges two TOML documents or tables.
///
/// Returns a new map that contains the contents of both documents.
/// Tables are merged recursively. Arrays (including arrays of tables) are
/// combined by adding the items of the second document to the items in the
/// first one. All other values are overwritten in favor of the second document.
Map<String, dynamic> merge(
  Map<String, dynamic> doc1,
  Map<String, dynamic> doc2,
) {
  var merged = Map<String, dynamic>.from(doc1);
  for (var key in doc2.keys) {
    var val2 = doc2[key];
    if (merged.containsKey(key)) {
      // A value for the key exists already. Both values must be merged.
      var val1 = merged[key];
      if (val1 is Map<String, dynamic> && val2 is Map<String, dynamic>) {
        // Tables are merged recursively.
        merged[key] = merge(val1, val2);
      } else if (val1 is Iterable<dynamic> && val2 is Iterable<dynamic>) {
        // Arrays and arrays of tables are merged by adding items to the array.
        merged[key] = List<dynamic>.from(val1)..addAll(val2);
      } else {
        // All other values overwrite existing entries.
        merged[key] = val2;
      }
    } else {
      // The key is new. A new entry can be added to the hash map.
      merged[key] = val2;
    }
  }
  return merged;
}
