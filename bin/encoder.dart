#!/usr/bin/env dart

// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

import 'dart:convert';
import 'dart:io';

import 'package:toml/encoder.dart';
import 'package:toml/loader/stream.dart';
import 'package:toml/toml.dart';

/// Decodes a JSON encoded TOML table.
Map<String, dynamic> decodeTable(Map<String, dynamic> json) {
  var table = {};
  json.forEach((String key, value) {
    table[key] = decodeValue(value);
  });
  return table;
}

/// Decodes a JSON encoded TOML value.
///
/// * If [value] is an `Iterable`, it will be treated as an array value.
/// * If [value] is a `Map` of the form
///   `{"type": {TTYPE}, "value": {TVALUE}}`
///   {TVALUE} is parsed as a TOML value of the specified {TTYPE}.
///   If `{TTYPE}` is not a valid TOML type, an error is thrown.
/// * All other `Maps` are decoded as a table. See [decodeTable].
dynamic decodeValue(value) {
  if (value is Iterable) value = {'type': 'array', 'value': value};
  if (value is Map) {
    if (value.length == 2 &&
        value.containsKey('type') &&
        value.containsKey('value')) {
      var type = value['type'];
      switch (type) {
        case 'string': return value['value'];
        case 'integer': return int.parse(value['value']);
        case 'float': return double.parse(value['value']);
        case 'datetime': return DateTime.parse(value['value']);
        case 'bool': return value['value'] == 'true';
        case 'array': return value['value'].map(decodeValue).toList();
        default: throw new UnsupportedError('Unsupported value type: $type');
      }
    }
    return decodeTable(value);
  }
  throw new UnsupportedError('Unsupported value: $value');
}

Future main() async {
  StreamConfigLoader.use(stdin.transform(UTF8.decoder));

  var json = await loadConfig('config.json');
  var encoder = new TomlEncoder();
  print(encoder.encode(decodeTable(json)).replaceAll('.000', ''));
}
