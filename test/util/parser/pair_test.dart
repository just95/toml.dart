library toml.test.util.parser.pair_test;

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'package:toml/src/util/container/pair.dart';
import 'package:toml/src/util/parser/pair.dart';

void main() {
  group('PairParser', () {
    test('succeeds when both parsers match', () {
      var parser = PairParser(char('a'), char('b'));
      var result = parser.parse('ab');
      expect(result.isSuccess, isTrue);
      expect(result.value, equals(Pair('a', 'b')));
    });
    test('fails when first parser does not match', () {
      var parser = PairParser(char('a'), char('b'));
      var result = parser.parse('cb');
      expect(result.isFailure, isTrue);
      expect(result.position, equals(0));
    });
    test('fails when second parser does not match', () {
      var parser = PairParser(char('a'), char('b'));
      var result = parser.parse('ac');
      expect(result.isFailure, isTrue);
      expect(result.position, equals(1));
    });
    test('succeeds in fast mode when both parsers match', () {
      var parser = PairParser(char('a'), char('b'));
      var result = parser.fastParseOn('ab', 0);
      expect(result, equals(2));
    });
    test('fails in fast mode when first parser does not match', () {
      var parser = PairParser(char('a'), char('b'));
      var result = parser.fastParseOn('cb', 0);
      expect(result, equals(-1));
    });
    test('fails in fast mode when second parser does not match', () {
      var parser = PairParser(char('a'), char('b'));
      var result = parser.fastParseOn('ac', 0);
      expect(result, equals(-1));
    });
    test('has two children', () {
      var parser = PairParser(char('a'), char('b'));
      expect(parser.children.length, 2);
    });
    test('can be copied shallowly', () {
      var original = PairParser(char('a'), char('b'));
      var copy = original.copy();
      expect(copy, isNot(equals(original)));
      expect(copy.firstParser, equals(original.firstParser));
      expect(copy.secondParser, equals(original.secondParser));
    });
    test('can replace first parser', () {
      var a = char('a'), b = char('b'), c = char('c');
      var parser = PairParser(a, b);
      parser.replace(a, c);
      expect(parser.firstParser, equals(c));
      expect(parser.secondParser, equals(b));
    });
    test('can replace second parser', () {
      var a = char('a'), b = char('b'), c = char('c');
      var parser = PairParser(a, b);
      parser.replace(b, c);
      expect(parser.firstParser, equals(a));
      expect(parser.secondParser, equals(c));
    });
  });
}
