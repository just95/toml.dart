#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:toml/toml.dart';

/// Encodes a table.
Map<String, dynamic> encodeTable(Map<String, dynamic> table) {
  var result = <String, dynamic>{};
  table.forEach((key, value) {
    result[key] = encodeValue(value);
  });
  return result;
}

/// Encodes an array.
dynamic encodeArray(Iterable items) => items.map<dynamic>(encodeValue).toList();

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
  while (value is TomlEncodableValue) {
    value = value.toTomlValue();
  }

  // Special cases for tables and arrays.
  if (value is Map<String, dynamic>) return encodeTable(value);
  if (value is Iterable) return encodeArray(value);

  return {'type': getValueType(value), 'value': serializeValue(value)};
}

/// Determines the TOML type of the supplied [value].
///
/// Throws an error if the type is not supported.
String getValueType(dynamic value) {
  if (value is String) return 'string';
  if (value is int) return 'integer';
  if (value is double) return 'float';
  if (value is TomlOffsetDateTime) return 'datetime';
  if (value is TomlLocalDateTime) return 'datetime-local';
  if (value is TomlLocalDate) return 'date-local';
  if (value is TomlLocalTime) return 'time-local';
  if (value is bool) return 'bool';
  throw UnsupportedError('Unsupported value type: $value');
}

/// Converts a value to a string in the format expected by `toml-test`.
String serializeValue(dynamic value) {
  if (value is double) return value.toString().toLowerCase();
  return value.toString();
}

Future<String> readInput() async {
  try {
    return await stdin.transform(utf8.decoder).join();
  } on FormatException catch (e) {
    print('Error reading input: $e');
    exit(1);
  }
}

Future main() async {
  try {
    var input = await readInput();
    var document = TomlDocument.parse(input).toMap();
    print(json.encode(encodeTable(document)));
  } on TomlException catch (e) {
    print('$e');
    exit(1);
  }
}
