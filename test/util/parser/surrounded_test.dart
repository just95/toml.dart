library toml.test.util.parser.surrounded_test;

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'package:toml/src/util/parser/surrounded.dart';

void main() {
  group('SurroundedParserExtension', () {
    group('before', () {
      test('just returns the result of the passed parser', () {
        var parser = char('a').before(char('b'));
        var result = parser.parse('ab');
        expect(result.isSuccess, isTrue);
        expect(result.value, equals('b'));
      });
    });
    group('followedBy', () {
      test('just returns the result of the receiving parser', () {
        var parser = char('a').followedBy(char('b'));
        var result = parser.parse('ab');
        expect(result.isSuccess, isTrue);
        expect(result.value, equals('a'));
      });
    });
    group('surroundedBy', () {
      test('just returns the result of the receiving parser', () {
        var parser = char('a').surroundedBy(char('x'));
        var result = parser.parse('xax');
        expect(result.isSuccess, isTrue);
        expect(result.value, equals('a'));
      });
      test('can have different prefix and suffix parsers', () {
        var parser = char('a').surroundedBy(char('x'), char('y'));
        var result = parser.parse('xay');
        expect(result.isSuccess, isTrue);
        expect(result.value, equals('a'));
      });
    });
  });
}
