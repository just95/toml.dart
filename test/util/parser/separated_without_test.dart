library toml.test.util.parser.separated_without_test;

import 'package:test/test.dart';
import 'package:petitparser/petitparser.dart';

import 'package:toml/src/util/parser/separated_without.dart';

void main() {
  group('SeparatedWithoutParserExtension', () {
    group('separatedWithout', () {
      test('cannot parse empty list', () {
        var parser = letter().separatedWithout(char(',')).end();
        var result = parser.parse('');
        expect(result.isFailure, isTrue);
      });
      test('can parse one elementry list', () {
        var parser = letter().separatedWithout(char(',')).end();
        var result = parser.parse('a');
        expect(result.isSuccess, isTrue);
        expect(result.value, equals(['a']));
      });
      test('can parse multielementry list', () {
        var parser = letter().separatedWithout(char(',')).end();
        var result = parser.parse('a,b,c');
        expect(result.isSuccess, isTrue);
        expect(result.value, equals(['a', 'b', 'c']));
      });
      test('can parse list with optional comma', () {
        var parser = letter()
            .separatedWithout(
              char(','),
              optionalSeparatorAtEnd: true,
            )
            .end();
        var result = parser.parse('a,b,c,');
        expect(result.isSuccess, isTrue);
        expect(result.value, equals(['a', 'b', 'c']));
      });
      test('can parse list without optional comma', () {
        var parser = letter()
            .separatedWithout(
              char(','),
              optionalSeparatorAtEnd: true,
            )
            .end();
        var result = parser.parse('a,b,c');
        expect(result.isSuccess, isTrue);
        expect(result.value, equals(['a', 'b', 'c']));
      });
    });
  });
}
