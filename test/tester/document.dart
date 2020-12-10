library toml.test.tester.document;

import 'package:petitparser/petitparser.dart';
import 'package:toml/toml.dart';

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
