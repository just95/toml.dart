library toml.test.util.parser.or_failure_test;

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'package:toml/src/util/parser/or_failure.dart';

void main() {
  group('OrFailureParserExtension', () {
    group('orFailure', () {
      test('tries to parse using the receiver', () {
        var parser = letter().orFailure('message');
        var result = parser.parse('a');
        expect(result, isA<Success>());
        expect(result.value, equals('a'));
      });
      test('uses custom message on failure', () {
        var parser = letter().orFailure('message');
        var result = parser.parse('1');
        expect(result, isA<Failure>());
        expect(result.message, equals('message'));
      });
    });
  });
}
