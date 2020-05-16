// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.encoder.builder;

import 'package:toml/decoder.dart';

import 'encodable.dart';
import 'exception/invalid_string.dart';
import 'exception/mixed_array_types.dart';
import 'exception/unknown_value_type.dart';

/// A function which encodes an object as a TOML value.
typedef void TomlValueEncoder<V>(V value);

// Possible types of TOML values.
enum TomlType {
  /// The type of a TOML array.
  array,

  /// The type of a boolean value.
  boolean,

  /// The type of a datetime.
  datetime,

  /// The type of a floating point number.
  float,

  /// The type of an integer.
  integer,

  /// The type of an interger or floating point number in JavaScript.
  number,

  /// The type of all variations of TOML strings.
  string,

  /// The type of an inline table.
  table
}

/// TOML document builder.
class TomlDocumentBuilder {
  /// Regular expression of a bare key.
  static final RegExp bareKeyRegExp = new RegExp(r'^[A-Za-z0-9_-]+$');

  /// A buffer which holds the textual representation of the document.
  final StringBuffer _buf = new StringBuffer();

  /// Inserts a new line.
  ///
  /// No new line will be added at the beginning of the document.
  void insertNewline() {
    if (_buf.isNotEmpty) _buf.writeln();
  }

  /// Inserts the header of a table.
  ///
  /// [name] is a list of keys. Each item represents one of the dot separated
  /// parts of the table name. The name is written in square brackets.
  ///
  /// If [array] is set to `true`, the table belongs to an array of tables.
  /// There will be therefore two pairs of square brackets.
  ///
  /// This method does nothing if [name] is empty.
  void insertHeader(List<String> name, {bool array: false}) {
    if (name.isNotEmpty) {
      insertNewline();
      insertNewline();
      _buf.write(array ? '[[' : '[');
      for (int i = 0; i < name.length; i++) {
        if (i != 0) _buf.write('.');
        encodeKey(name[i]);
      }
      _buf.write(array ? ']]' : ']');
    }
  }

  /// Converts a [TomlEncodable] object to an object which TOML can represent.
  ///
  /// [TomlEncodable.toToml] will be repeatedly applied on [value] until the
  /// return value is representable by TOML.
  /// Returns [value] if it is not an instance of [TomlEncodable].
  dynamic unwrapValue(dynamic value) {
    while (value is TomlEncodable) value = value.toToml();
    return value;
  }

  /// Encodes a map as a TOML table.
  ///
  /// This method generates a table header automatically if required.
  /// [name] is the qualified name of the [table]. Each item represents one of
  /// the dot separated parts of the table name.
  ///
  /// If [array] is set to `true`, [table] is an item of the array of tables
  /// called [name].
  ///
  /// The key/value pairs are encoded before the sub-tables of [table].
  void encodeSubTable(Map<String, dynamic> table,
      {List<String> name, bool array: false}) {
    var pairs = <String, dynamic>{};
    var sections = <String, dynamic>{};
    table.forEach((key, wrapableValue) {
      final value = unwrapValue(wrapableValue);
      if (value is Map) {
        sections[key] = value;
      } else if (value is Iterable && value.length > 0) {
        final items = value.map(unwrapValue);
        if (items.every((item) => item is Map)) {
          sections[key] = items;
        } else {
          pairs[key] = items;
        }
      } else {
        pairs[key] = value;
      }
    });

    // Encode key/value pairs.
    if (array || pairs.isNotEmpty || table.isEmpty) {
      insertHeader(name, array: array);
      pairs.forEach(insertKeyValuePair);
    }

    // Encode sub-tables.
    sections.forEach((key, value) {
      name.add(key);

      if (value is Map<String, dynamic>) {
        encodeSubTable(value, name: name);
      } else if (value is Iterable<Map<String, dynamic>>) {
        value.forEach((item) {
          encodeSubTable(item, name: name, array: true);
        });
      } else {
        throw new UnknownValueTypeException(value);
      }

      name.removeLast();
    });
  }

  /// Inserts a key/value pair.
  ///
  /// [key] is the unqualified name of this entry.
  /// [value] is an object which can be represented by TOML or is a
  /// `TomlEncodable`.
  void insertKeyValuePair(String key, dynamic value) {
    insertNewline();
    encodeKey(key);
    _buf.write(' = ');
    encodeValue(value);
  }

  /// Encodes a [key].
  void encodeKey(String key) {
    if (bareKeyRegExp.hasMatch(key)) {
      _buf.write(key);
    } else {
      encodeBasicString(key);
    }
  }

  /// Applies the right `encode*` method on the given [value] based on its
  /// runtime type.
  ///
  /// Throws an [UnknownValueTypeException] if there is no matching encoder.
  void encodeValue(dynamic value) {
    value = unwrapValue(value);
    if (value is num) return encodeNumber(value);
    if (value is bool) return encodeBoolean(value);
    if (value is DateTime) return encodeDatetime(value);
    if (value is String) return encodeString(value);
    if (value is Iterable) return encodeArray(value);
    throw new UnknownValueTypeException(value);
  }

  /// Encodes an integer or float.
  void encodeNumber(num value) {
    _buf.write('$value');
  }

  /// Encodes a boolean value.
  void encodeBoolean(bool value) {
    _buf.write(value ? 'true' : 'false');
  }

  /// Encodes a `DateTime` object.
  void encodeDatetime(DateTime value) {
    _buf.write(value.toIso8601String());
  }

  /// Tests whether all items of an array are of the same type.
  ///
  /// If the content type of [array] is not unique, a [MixedArrayTypesException]
  /// will be thrown.
  /// Returns the content type or `null` if [array] is empty.
  ///
  /// [int] and [double] are not distinct when compiled to JavaScript.
  /// A return type of [num] indicates that [array] contains at least one
  /// number which could in theory be represented either way but there is
  /// another number with has decimal places and thus must be represented as
  /// a float.
  /// To prevent the generation of malformed arrays `'.0'` sould be inserted
  /// behind an integer in this case.
  TomlType validateArrayType(Iterable array) {
    if (array.isEmpty) return null;

    // JavaScript: Numeric array with mixed content types.
    if (identical(1, 1.0) &&
        array.every((item) => item is num) &&
        array.any((item) => item is int) &&
        array.any((item) => item is! int)) {
      return TomlType.number;
    }

    return array.map(tomlValueTypeOf).reduce((a, b) {
      if (a != b) throw new MixedArrayTypesException(array);
      return a;
    });
  }

  /// Gets the type of the given value.
  ///
  /// Throws an [UnknownValueTypeException] exception if the type is not known.
  TomlType tomlValueTypeOf(dynamic value) {
    if (value is Iterable) return TomlType.array;
    if (value is bool) return TomlType.boolean;
    if (value is DateTime) return TomlType.datetime;
    if (value is double) return TomlType.float;
    if (value is Map<String, dynamic>) return TomlType.table;
    if (value is int) return TomlType.integer;
    if (value is String) return TomlType.string;
    throw new UnknownValueTypeException(value);
  }

  /// Encodes an array.
  ///
  /// The contents of [value] will be validated using [validateArrayType]
  /// before it is encoded.
  /// If it returns `num`, `'.0'` will be inserted behind integer values such
  /// that the value type of the array remains consistent.
  void encodeArray(Iterable value) {
    var type = validateArrayType(value);
    _buf.write('[');
    for (var i = 0; i < value.length; i++) {
      var item = value.elementAt(i);

      if (i != 0) _buf.write(', ');

      encodeValue(item);
      // Mixed numeric array.
      if (type == TomlType.number && item is int) _buf.write('.0');
    }
    _buf.write(']');
  }

  /// Determines which syntactic variation fits best the requirements of a
  /// string.
  ///
  /// By default the literal string encoder is considered the best choise.
  /// If [value] contains any character which is not allowed to appear in
  /// a literal string (that is a single quote or a special character which
  /// needs to be escaped except for the double quotes and the backslash),
  /// a basic string is used instead.
  ///
  /// If [value] contains multiple lines, multi-line literal strings are
  /// preferred over multi-line basic strings. The latter are only used
  /// if any line contains a character which needs to be escaped except
  /// for double quotes and the backslash.
  TomlValueEncoder<String> getStringEncoder(String value) {
    var allowedEscSeq = [TomlGrammar.escTable['"'], TomlGrammar.escTable['\\']];

    bool containsEscSeq(String s) => TomlGrammar.escTable.values
        .where((codeUnit) => !allowedEscSeq.contains(codeUnit))
        .any(s.codeUnits.contains);

    // Multi-line string.
    if (value.contains('\n') || value.contains('\r')) {
      // There is a line which contains a character that must be escaped.
      if (value.split(new RegExp('\n|\r')).any(containsEscSeq)) {
        return encodeMultiLineBasicString;
      }
      return encodeMultiLineLiteralString;
    }

    // Literal strings cannot contain "'" or characters which have to be
    // escaped except for '"' or '\\' which are allowed in literal strings.
    if (value.contains("'") || containsEscSeq(value)) {
      return encodeBasicString;
    }
    return encodeLiteralString;
  }

  /// Applies the [TomlValueEncoder] recommended by [getStringEncoder] on
  /// [value].
  void encodeString(String value) {
    var encoder = getStringEncoder(value);
    encoder(value);
  }

  /// Private generic implementation of a string encoder.
  ///
  /// Encodes [value] as a string delimited by a pair of [quotes].
  /// The start quotes are followed by an empty line for [multiline] strings.
  /// Escapes the code units specified by [esc].
  /// Throws an [InvalidStringException] if [value] contains some characters
  /// which are not allowed.
  void _encodeString(String value,
      {String quotes, Iterable<int> esc: const [], bool multiline: false}) {
    // Escape value.
    if (esc.isNotEmpty) {
      value = value.codeUnits.map((int codeUnit) {
        if (esc.contains(codeUnit)) {
          return '\\${TomlGrammar.escTable.inverse[codeUnit]}';
        }
        return new String.fromCharCode(codeUnit);
      }).join();
    }

    if (multiline) {
      if (quotes == '"""') value = value.replaceAll('"""', r'\"\"\"');
    } else if (value.contains('\n') || value.contains('\r')) {
      throw new InvalidStringException(
          'Newlines are only allowed in multi-line strings!');
    }

    // Unescaped quotes are illegal.
    if (!esc.contains(quotes.codeUnitAt(0)) && value.contains(quotes)) {
      throw new InvalidStringException(
          '"$quotes" are prohibited in non-basic strings.');
    }

    _buf.write(quotes);
    if (multiline) _buf.writeln();
    _buf.write(value);
    _buf.write(quotes);
  }

  /// Encodes [value] as a basic string.
  void encodeBasicString(String value) =>
      _encodeString(value, quotes: '"', esc: TomlGrammar.escTable.values);

  /// Encodes [value] as a multi-line basic string.
  void encodeMultiLineBasicString(String value) => _encodeString(value,
      quotes: '"""',
      esc: TomlGrammar.escTable.values.where((c) =>
          c != TomlGrammar.escTable['"'] &&
          c != TomlGrammar.escTable['n'] &&
          c != TomlGrammar.escTable['r']),
      multiline: true);

  /// Encodes [value] as a literal string.
  void encodeLiteralString(String value) => _encodeString(value, quotes: "'");

  /// Encodes [value] as a multi-line literal string.
  void encodeMultiLineLiteralString(String value) =>
      _encodeString(value, quotes: "'''", multiline: true);

  @override
  String toString() => _buf.toString();
}
