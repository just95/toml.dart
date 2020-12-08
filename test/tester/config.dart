// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.tester.config;

import 'dart:async';

import 'package:test/test.dart';
import 'package:toml/toml.dart';
import 'package:toml/src/loader.dart';
import 'package:yaml/yaml.dart';

/// Tests a [toml] and a [yaml] table for deep equality.
void _cmpMaps({Map toml, Map yaml}) {
  toml.forEach((key, tomlValue) {
    var yamlValue = yaml[key];
    _cmp(tomlValue: tomlValue, yamlValue: yamlValue);
  });
}

/// Tests a [tomlValue] and a [yamlValue] value for deep equality.
///
/// Because YAML does not support datetimes, YAML values will be parsed
/// first if the [tomlValue] is a `DateTime` object.
void _cmp({tomlValue, yamlValue}) {
  if (tomlValue is Map) {
    expect(yamlValue, isA<Map>());
    if (yamlValue is Map) {
      _cmpMaps(toml: tomlValue, yaml: yamlValue);
    }
  } else if (tomlValue is Iterable) {
    expect(yamlValue, isA<Iterable>());
    expect(tomlValue.length, equals(yamlValue.length));
    for (var i = 0; i < tomlValue.length; i++) {
      _cmp(
        tomlValue: tomlValue.elementAt(i),
        yamlValue: yamlValue.elementAt(i),
      );
    }
  } else if (tomlValue is DateTime) {
    expect(yamlValue, isA<String>());
    if (yamlValue is String) {
      expect(tomlValue, equals(DateTime.parse(yamlValue)));
    }
  } else {
    expect(tomlValue, equals(yamlValue));
  }
}

/// Loads a TOML document from the given file.
Future<Map<String, dynamic>> loadTomlConfig(String filename) =>
    TomlDocument.load(filename).then((document) => document.toMap());

/// Loads a YAML document from the given file.
Future<Map<String, dynamic>> loadYamlConfig(String filename) async {
  var contents = await loadFile(filename);
  var document = loadYaml(contents);
  if (document is YamlMap) {
    if (document.keys.every((key) => key is String)) {
      return Map.fromIterables(
        document.keys.cast<String>(),
        document.values,
      );
    }
  }
  throw FormatException(
    'Expected map at top-level of YAML document, got ${document.runtimeType}',
  );
}

/// Loads the TOML and YAML files with the specified [name] located in
/// the `test/config` directory and compares the resulting hash maps.
void testConfig(String name) {
  var future = Future.wait([
    loadTomlConfig('test/config/$name.toml'),
    loadYamlConfig('test/config/$name.yaml')
  ]);
  future.then(expectAsync1((res) {
    _cmpMaps(toml: res[0], yaml: res[1]);
  }));
  expect(future, completes);
}
