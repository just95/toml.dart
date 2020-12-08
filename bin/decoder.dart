#!/usr/bin/env dart
// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:toml/toml.dart';

/// Encodes a table.
Map<String, dynamic> encodeTable(Map<String, dynamic> table) {
  var result = <String, dynamic>{};
  table.forEach((String key, dynamic value) {
    result[key] = encodeValue(value);
  });
  return result;
}

/// Encodes an array.
///
/// * Arrays of tables are encoded as a JSON array.
/// * All other arrays are encoded as JSON objects of the form
///   `{"type": "array", "value": [...]}`.
dynamic encodeArray(Iterable items) {
  var encodedItems = items.map<dynamic>(encodeValue).toList();
  if (items.isEmpty ||
      !items.every((dynamic item) => item is Map<String, dynamic>)) {
    return {'type': 'array', 'value': encodedItems};
  }
  return encodedItems;
}

/// Encodes a TOML [value] as a JSON object.
///
/// * `Map`s are encoded as tables. See [encodeTable].
/// * `Iterable`s are encoded as arrays. See [encodeArray].
/// * All other values are encoded as a JSON object of the form
///   `{"type": {TTYPE}, "value": {TVALUE}}`
///
///   `{TTYPE}` is determined by [getValueType] and `{TVALUE}` is
///   the string representation of [value].
dynamic encodeValue(dynamic value) {
  // Unwrap value.
  while (value is TomlEncodable) {
    value = value.toToml();
  }

  // Special cases for tables and arrays.
  if (value is Map<String, dynamic>) return encodeTable(value);
  if (value is Iterable) return encodeArray(value);

  var str = value.toString();
  if (value is DateTime) {
    // In TOML date and time are separated by `T` rather than a space.
    str = str.replaceFirst(' ', 'T').replaceFirst('.000', '');
  }
  return {'type': getValueType(value), 'value': str};
}

/// Determines the TOML type of the supplied [value].
///
/// Throws an error if the type is not supported.
String getValueType(dynamic value) {
  if (value is String) return 'string';
  if (value is int) return 'integer';
  if (value is double) return 'float';
  if (value is DateTime) return 'datetime';
  if (value is bool) return 'bool';
  throw UnsupportedError('Unsupported value type: $value');
}

Future main() async {
  var input = await stdin.transform(utf8.decoder).join();
  var document = TomlDocument.parse(input).toMap();
  print(json.encode(encodeTable(document)));
}
