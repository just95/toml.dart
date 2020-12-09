// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.tester.encoder;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

/// Tests whether the result of encoding the [input] is the specified [output].
void testEncoder(String description,
    {Map<String, dynamic> input, String output}) {
  test(description, () {
    var result = TomlDocument.fromMap(input).toString();
    expect(result, equals(output));
  });
}

/// Tests whether the [TomlEncoder] fails to encode [input].
///
/// Optionally tests whether a particular [error] is thrown.
void testEncoderFailure(String description,
    {Map<String, dynamic> input, dynamic error = anything}) {
  test(description, () {
    expect(() => TomlDocument.fromMap(input).toString(), throwsA(error));
  });
}
