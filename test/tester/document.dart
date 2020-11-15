// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.tester.document;

import 'package:toml/ast.dart';

import 'toml.dart';

/// Tests whether [TomlParser] successfully parses the [input] string
/// and produces the specified [output].
void testDocument(String desciption, {String input, dynamic output}) =>
    testToml(
      desciption,
      parser: TomlDocument.parser.end().map((result) => result.toMap()),
      input: input,
      output: output,
    );

/// Tests whether [TomlParser] fails to parse [input].
///
/// Optionally tests whether a specific [error] is thrown.
void testDocumentFailure(String desciption, {String input, dynamic error}) =>
    testTomlFailure(
      desciption,
      parser: TomlDocument.parser.end().map((result) => result.toMap()),
      input: input,
      error: error,
    );
