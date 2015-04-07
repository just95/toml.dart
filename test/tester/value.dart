// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.tester.value;

import 'package:toml/toml.dart';

import 'toml.dart';

var _parser = new TomlValueParser();

/// A function which tests whether [TomlValueParser] successfully parses its
/// first argument and the the result equals its second argument.
final valueTester = tomlTester(_parser);

/// Tests whether [TomlValueParser] fails to parse the first argument.
///
/// An optional second argument specifies the exception which is expected to be
/// thrown.
final valueErrorTester = tomlErrorTester(_parser);
