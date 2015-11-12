// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.tester.toml;

import 'package:test/test.dart';
import 'package:petitparser/petitparser.dart';

import '../matcher/parser_result.dart';

/// Tests whether the [parser] successfully parses the [input] and produces
/// the specified [output].
void testToml(String desciption, {Parser parser, String input, output}) {
  test(desciption, () {
    var res = parser.parse(input);
    expect(res, isSuccess);
    expect(res.value, equals(output));
  });
}

/// Tests whether [parser] fails to parse the [input].
///
/// Optionally tests whether a specific [error] is thrown.
void testTomlFailure(String desciption, {Parser parser, String input, error}) {
  test(desciption, () {
    if (error == null) {
      var res = parser.parse(input);
      expect(res, isFailure);
    } else {
      expect(() => parser.parse(input), throwsA(error));
    }
  });
}
