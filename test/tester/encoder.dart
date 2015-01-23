// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.tester.encoder;

import 'package:unittest/unittest.dart';
import 'package:toml/encoder.dart';

var _encoder = new TomlEncoder();

/// Tests whether the result of encoding [document] is [toml].
void encoderTester(String toml, Map document) {
  var str = _encoder.encode(document);
  expect(str, equals(toml));
}

/// Tests whether the [TomlEncoder] fails to encode [document].
/// 
/// Optionally tests whether a particular [err]or is thrown.
void encoderErrorTester(Map document, [err]) {
  if (err == null) {
    expect(
        () => _encoder.encode(document),
        throws);
  }
  else {
    expect(
        () => _encoder.encode(document),
        throwsA(err));
  }
}