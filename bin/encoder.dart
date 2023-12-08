#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:toml/toml.dart';

/// Decodes a JSON encoded TOML table.
Map<String, dynamic> decodeTable(Map<String, dynamic> table) {
  var result = <String, dynamic>{};
  table.forEach((key, value) {
    result[key] = decodeValue(value);
  });
  return result;
}

/// Decodes a JSON encoded TOML value.
///
/// * If [value] is an `Iterable`, it will be treated as an array value.
/// * If [value] is a `Map` of the form
///   `{"type": {TTYPE}, "value": {TVALUE}}`
///   {TVALUE} is parsed as a TOML value of the specified {TTYPE}.
///   If `{TTYPE}` is not a valid TOML type, an error is thrown.
/// * All other `Maps` are decoded as a table. See [decodeTable].
dynamic decodeValue(dynamic value) {
  if (value is Iterable) {
    value = <String, dynamic>{'type': 'array', 'value': value};
  }
  if (value is Map<String, dynamic>) {
    if (value.length == 2 &&
        value.containsKey('type') &&
        value.containsKey('value')) {
      var type = value['type'] as String;
      switch (type) {
        case 'string':
          return value['value'] as String;
        case 'integer':
          return int.parse(value['value'] as String);
        case 'float':
          var stringValue = value['value'] as String;
          switch (stringValue.toLowerCase()) {
            case 'nan':
              return double.nan;
            case 'inf':
            case '+inf':
              return double.infinity;
            case '-inf':
              return double.negativeInfinity;
            default:
              return double.parse(stringValue);
          }
        case 'datetime':
          return TomlOffsetDateTime.parse(value['value'] as String);
        case 'datetime-local':
          return TomlLocalDateTime.parse(value['value'] as String);
        case 'date-local':
          return TomlLocalDate.parse(value['value'] as String);
        case 'time-local':
          return TomlLocalTime.parse(value['value'] as String);
        case 'bool':
          return value['value'] == 'true';
        case 'array':
          return value['value'].map(decodeValue).toList();
        default:
          throw UnsupportedError('Unsupported value type: $type');
      }
    }
    return decodeTable(value);
  }
  throw UnsupportedError('Unsupported value: $value');
}

Future main() async {
  var input = await stdin.transform(utf8.decoder).join();
  var document = json.decode(input);
  if (document is Map<String, dynamic>) {
    print(TomlDocument.fromMap(decodeTable(document))
        .toString()
        .replaceAll('.000', ''));
  } else {
    throw FormatException('Expected object at top-level of JSON document.');
  }
}
