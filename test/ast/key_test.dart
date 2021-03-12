library toml.test.ast.document_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

void main() {
  group('TomlKey', () {
    group('parse', () {
      test('can parse simple unquoted key', () {
        expect(TomlKey.parse('key'), equals(TomlKey([TomlUnquotedKey('key')])));
      });
      test('can parse simple quoted literal key', () {
        expect(
          TomlKey.parse("'key'"),
          equals(TomlKey([TomlQuotedKey(TomlLiteralString('key'))])),
        );
      });
      test('can parse simple quoted basic key', () {
        expect(
          TomlKey.parse('"key"'),
          equals(TomlKey([TomlQuotedKey(TomlBasicString('key'))])),
        );
      });
      test('can parse dotted key', () {
        expect(
          TomlKey.parse('unquoted.\'literal\'."basic"'),
          equals(TomlKey([
            TomlUnquotedKey('unquoted'),
            TomlQuotedKey(TomlLiteralString('literal')),
            TomlQuotedKey(TomlBasicString('basic')),
          ])),
        );
      });
      test('ignores whitespace around dots', () {
        expect(
          TomlKey.parse('unquoted . \'literal\' . "basic"'),
          equals(TomlKey([
            TomlUnquotedKey('unquoted'),
            TomlQuotedKey(TomlLiteralString('literal')),
            TomlQuotedKey(TomlBasicString('basic')),
          ])),
        );
      });
      test('ignores leading and trailing whitespace', () {
        expect(
          TomlKey.parse(' unquoted.\'literal\'."basic" '),
          equals(TomlKey([
            TomlUnquotedKey('unquoted'),
            TomlQuotedKey(TomlLiteralString('literal')),
            TomlQuotedKey(TomlBasicString('basic')),
          ])),
        );
      });
      test('preserves whitespace in quoted strings', () {
        expect(
          TomlKey.parse('unquoted.\' l i t e r a l \'." b a s i c "'),
          equals(TomlKey([
            TomlUnquotedKey('unquoted'),
            TomlQuotedKey(TomlLiteralString(' l i t e r a l ')),
            TomlQuotedKey(TomlBasicString(' b a s i c ')),
          ])),
        );
      });
    });
    group('isPrefixOf', () {
      test('returns true for idential keys', () {
        var key = TomlKey([TomlUnquotedKey('key')]);
        expect(key.isPrefixOf(key), isTrue);
      });
      test('returns true if top-level key is receiver and argument', () {
        expect(TomlKey.topLevel.isPrefixOf(TomlKey.topLevel), isTrue);
      });
      test('returns true if receiver is top-level key', () {
        var key = TomlKey([TomlUnquotedKey('key')]);
        expect(TomlKey.topLevel.isPrefixOf(key), isTrue);
      });
      test('returns false if argument is top-level key', () {
        var key = TomlKey([TomlUnquotedKey('key')]);
        expect(key.isPrefixOf(TomlKey.topLevel), isFalse);
      });
      test('returns false if the argument is a prefix of the receiver', () {
        var key = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
          TomlUnquotedKey('c'),
        ]);
        var prefix = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
        ]);
        expect(key.isPrefixOf(prefix), isFalse);
      });
      test('returns true if the argument is a prefix', () {
        var key = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
          TomlUnquotedKey('c'),
        ]);
        var prefix = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
        ]);
        expect(prefix.isPrefixOf(key), isTrue);
      });
      test('returns false for unreleated smaller keys', () {
        var key = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
          TomlUnquotedKey('c'),
        ]);
        var smallerKey = TomlKey([
          TomlUnquotedKey('d'),
          TomlUnquotedKey('e'),
        ]);
        expect(key.isPrefixOf(smallerKey), isFalse);
      });
      test('returns false for unreleated larger keys', () {
        var key = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
        ]);
        var largerKey = TomlKey([
          TomlUnquotedKey('c'),
          TomlUnquotedKey('d'),
          TomlUnquotedKey('e'),
        ]);
        expect(key.isPrefixOf(largerKey), isFalse);
      });
      test('returns false for different keys of the same length', () {
        var key = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
          TomlUnquotedKey('c'),
        ]);
        var smallerKey = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('x'),
          TomlUnquotedKey('c'),
        ]);
        expect(key.isPrefixOf(smallerKey), isFalse);
      });
    });
    group('hashCode', () {
      test('equals keys have the same hash code', () {
        var k1 = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
          TomlUnquotedKey('c'),
        ]);
        var k2 = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
          TomlUnquotedKey('c'),
        ]);
        expect(k1.hashCode, equals(k2.hashCode));
      });
      test('keys with different components have the different hash codes', () {
        var k1 = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
          TomlUnquotedKey('c'),
        ]);
        var k2 = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('x'),
          TomlUnquotedKey('c'),
        ]);
        expect(k1.hashCode, isNot(equals(k2.hashCode)));
      });
    });
  });
}
