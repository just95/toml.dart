// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.tester.toml;

import 'package:unittest/unittest.dart';
import 'package:petitparser/petitparser.dart';

import '../matcher/parser_result.dart';

/// Returns a function which tests whether [parser] successfully parses its
/// first argument and the result equals its second argument.
Function tomlTester(Parser parser) => (String input, output) {
  var res = parser.parse(input);
  expect(res, isSuccess);
  expect(res.value, equals(output));
};

/// Returns a function which tests whether [parser] fails to parse its first
/// argument.
///
/// Optionally tests whether a specific error is thrown by passing a second
/// argument to the returned function.
Function tomlErrorTester(Parser parser) => (String input, [err]) {
  if (err == null) {
    var res = parser.parse(input);
    expect(res, isFailure);
  } else {
    expect(() => parser.parse(input), throwsA(err));
  }
};
