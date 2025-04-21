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
    return decodeArray(value);
  }
  if (value is Map<String, dynamic>) {
    if (value.length == 2 &&
        value.containsKey('type') &&
        value.containsKey('value')) {
      final type = value['type'] as String;
      if (type == 'array') {
        return decodeArray(value['value'] as Iterable);
      }

      final stringValue = value['value'] as String;
      switch (type) {
        case 'string':
          return stringValue;
        case 'integer':
          return int.parse(stringValue);
        case 'float':
          switch (value['value']) {
            case 'nan':
              return double.nan;
            case 'inf':
            case '+inf':
              return double.infinity;
            case '-inf':
              return double.negativeInfinity;
            case String stringValue:
              return double.parse(stringValue);
          }
        case 'datetime':
          return TomlOffsetDateTime.parse(stringValue);
        case 'datetime-local':
          return TomlLocalDateTime.parse(stringValue);
        case 'date-local':
          return TomlLocalDate.parse(stringValue);
        case 'time-local':
          return TomlLocalTime.parse(stringValue);
        case 'bool':
          return stringValue == 'true';
        default:
          throw UnsupportedError('Unsupported value type: $type');
      }
    }
    return decodeTable(value);
  }
  throw UnsupportedError('Unsupported value: $value');
}

/// Decodes a JSON encoded TOML array or array of tables.
dynamic decodeArray(Iterable items) => items.map(decodeValue).toList();

Future main() async {
  var input = await stdin.transform(utf8.decoder).join();
  var document = json.decode(input);
  if (document is Map<String, dynamic>) {
    print(
      TomlDocument.fromMap(
        decodeTable(document),
      ).toString().replaceAll('.000', ''),
    );
  } else {
    throw FormatException('Expected object at top-level of JSON document.');
  }
}
