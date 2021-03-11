library toml.test.util.parser.or_failure_test;

import 'package:test/test.dart';
import 'package:petitparser/petitparser.dart';

import 'package:toml/src/util/parser/or_failure.dart';

void main() {
  group('OrFailureParserExtension', () {
    group('orFailure', () {
      test('tries to parse using the receiver', () {
        var parser = letter().orFailure('message');
        var result = parser.parse('a');
        expect(result.isSuccess, isTrue);
        expect(result.value, equals('a'));
      });
      test('uses custom message on failure', () {
        var parser = letter().orFailure('message');
        var result = parser.parse('1');
        expect(result.isFailure, isTrue);
        expect(result.message, equals('message'));
      });
    });
  });
}
