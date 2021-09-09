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
  group('SurroundedParser', () {
    group('parseOn', () {
      test('succeeds when prefix, delegate and suffix match', () {
        var a = char('a'), b = char('b'), c = char('c');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        var result = parser.parse('bac');
        expect(result.isSuccess, true);
        expect(result.value, equals('a'));
      });
      test('succeeds when prefix is absent', () {
        var a = char('a'), b = char('b');
        var parser = SurroundedParser(a, suffix: b);
        var result = parser.parse('ab');
        expect(result.isSuccess, true);
        expect(result.value, equals('a'));
      });
      test('succeeds when suffix is absent', () {
        var a = char('a'), b = char('b');
        var parser = SurroundedParser(a, prefix: b);
        var result = parser.parse('ba');
        expect(result.isSuccess, true);
        expect(result.value, equals('a'));
      });
      test('succeeds when prefix and suffix are absent', () {
        var a = char('a');
        var parser = SurroundedParser(a);
        var result = parser.parse('a');
        expect(result.isSuccess, true);
        expect(result.value, equals('a'));
      });
      test('fails when prefix does not match', () {
        var a = char('a'), b = char('b'), c = char('c');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        var result = parser.parse('xac');
        expect(result.isFailure, true);
      });
      test('fails when suffix does not match', () {
        var a = char('a'), b = char('b'), c = char('c');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        var result = parser.parse('bax');
        expect(result.isFailure, true);
      });
      test('fails when delegate does not match', () {
        var a = char('a'), b = char('b'), c = char('c');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        var result = parser.parse('bxc');
        expect(result.isFailure, true);
      });
    });
    group('fastParseOn', () {
      test('succeeds in fast mode when prefix, delegate and suffix match', () {
        var a = char('a'), b = char('b'), c = char('c');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        expect(parser.fastParseOn('bac', 0), 3);
      });
      test('succeeds in fast mode when prefix is absent', () {
        var a = char('a'), b = char('b');
        var parser = SurroundedParser(a, suffix: b);
        expect(parser.fastParseOn('ab', 0), 2);
      });
      test('succeeds in fast mode when suffix is absent', () {
        var a = char('a'), b = char('b');
        var parser = SurroundedParser(a, prefix: b);
        expect(parser.fastParseOn('ba', 0), 2);
      });
      test('succeeds in fast mode when prefix and suffix are absent', () {
        var a = char('a');
        var parser = SurroundedParser(a);
        expect(parser.fastParseOn('a', 0), 1);
      });
      test('fails in fast mode when prefix does not match', () {
        var a = char('a'), b = char('b'), c = char('c');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        expect(parser.fastParseOn('xac', 0), -1);
      });
      test('fails in fast mode when suffix does not match', () {
        var a = char('a'), b = char('b'), c = char('c');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        expect(parser.fastParseOn('bax', 0), -1);
      });
      test('fails in fast mode when delegate does not match', () {
        var a = char('a'), b = char('b'), c = char('c');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        expect(parser.fastParseOn('bxc', 0), -1);
      });
    });
    group('children', () {
      test('has three children if prefix and suffix are present', () {
        var a = char('a'), b = char('b'), c = char('c');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        expect(parser.children.length, 3);
      });
      test('has only two children if suffix is absent', () {
        var a = char('a'), b = char('b');
        var parser = SurroundedParser(a, prefix: b);
        expect(parser.children.length, 2);
      });
      test('has only two children if prefix is absent', () {
        var a = char('a'), b = char('b');
        var parser = SurroundedParser(a, suffix: b);
        expect(parser.children.length, 2);
      });
      test('has just one child if prefix and suffix are absent', () {
        var a = char('a');
        var parser = SurroundedParser(a);
        expect(parser.children.length, 1);
      });
    });
    group('copy', () {
      test('can be copied shallowly', () {
        var a = char('a'), b = char('b'), c = char('c');
        var original = SurroundedParser(a, prefix: b, suffix: c);
        var copy = original.copy();
        expect(copy, isNot(equals(original)));
        expect(copy.delegate, equals(original.delegate));
        expect(copy.prefix, equals(original.prefix));
        expect(copy.suffix, equals(original.suffix));
      });
    });
    group('replace', () {
      test('can replace surrounded parser', () {
        var a = char('a'), b = char('b'), c = char('c'), d = char('d');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        parser.replace(a, d);
        expect(parser.delegate, equals(d));
        expect(parser.prefix, equals(b));
        expect(parser.suffix, equals(c));
      });
      test('can replace prefix parser', () {
        var a = char('a'), b = char('b'), c = char('c'), d = char('d');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        parser.replace(b, d);
        expect(parser.delegate, equals(a));
        expect(parser.prefix, equals(d));
        expect(parser.suffix, equals(c));
      });
      test('can replace suffix parser', () {
        var a = char('a'), b = char('b'), c = char('c'), d = char('d');
        var parser = SurroundedParser(a, prefix: b, suffix: c);
        parser.replace(c, d);
        expect(parser.delegate, equals(a));
        expect(parser.prefix, equals(b));
        expect(parser.suffix, equals(d));
      });
    });
  });
}
