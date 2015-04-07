// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.tester.config;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:toml/loader.dart';

/// Tests a TOML and a YAML table for deep equality.
void _cmpMaps(Map toml, Map yaml) {
  toml.forEach((key, tomlValue) {
    var yamlValue = yaml[key];
    _cmp(tomlValue, yamlValue);
  });
}

/// Tests a TOML and a YAML value for deep equality.
/// 
/// Because YAML does not support datetimes, YAML values will be parsed using
/// [DateTime.parse] if TOML is a [DateTime] such that both can be compared.
void _cmp(tomlValue, yamlValue) {
  if (tomlValue is Map) {
    expect(yamlValue, new isInstanceOf<Map>());
    _cmpMaps(tomlValue, yamlValue);
  }
  else if (tomlValue is Iterable) {
    expect(yamlValue, new isInstanceOf<Iterable>());
    expect(tomlValue.length, equals(yamlValue.length));
    for (int i = 0; i < tomlValue.length; i++) {
      _cmp(tomlValue[i], yamlValue[i]);
    }
  }
  else if (tomlValue is DateTime) {
    expect(tomlValue, equals(DateTime.parse(yamlValue)));
  }
  else {
    expect(tomlValue, equals(yamlValue));
  }
}
    
/**
 * Uses `dart_config` to load the configuration files located at 
 * `toml/test/config/[name].{toml,yaml}`.
 * Tests the results for deep equality.
 */
/// Uses `dart_config` to load the configuration files located at
/// `toml/test/config/[name].toml` and `toml/test/config/[name].yaml`.
/// Tests the results for deep equality.
void configTester(String name) {
  var future = Future.wait([
    loadConfig('config/$name.toml'),
    loadConfig('config/$name.yaml')
  ]);
  future.then(expectAsync((res) {
    _cmpMaps(res[0], res[1]);
  }));
  expect(future, completes);
}