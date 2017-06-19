// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.tester.value;

import 'package:toml/toml.dart';

import 'toml.dart';

var _parser = new TomlValueParser();

/// Tests whether [TomlValueParser] successfully parses the [input] string
/// and produces the specified [output].
void testValue(String desciption, {String input, dynamic output}) =>
    testToml(desciption, parser: _parser, input: input, output: output);

/// Tests whether [TomlValueParser] fails to parse [input].
///
/// Optionally tests whether a specific [error] is thrown.
void testValueFailure(String desciption, {String input, dynamic error}) =>
    testTomlFailure(desciption, parser: _parser, input: input, error: error);
