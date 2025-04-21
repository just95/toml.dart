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
          equals(
            TomlKey([
              TomlUnquotedKey('unquoted'),
              TomlQuotedKey(TomlLiteralString('literal')),
              TomlQuotedKey(TomlBasicString('basic')),
            ]),
          ),
        );
      });
      test('ignores whitespace around dots', () {
        expect(
          TomlKey.parse('unquoted . \'literal\' . "basic"'),
          equals(
            TomlKey([
              TomlUnquotedKey('unquoted'),
              TomlQuotedKey(TomlLiteralString('literal')),
              TomlQuotedKey(TomlBasicString('basic')),
            ]),
          ),
        );
      });
      test('ignores leading and trailing whitespace', () {
        expect(
          TomlKey.parse(' unquoted.\'literal\'."basic" '),
          equals(
            TomlKey([
              TomlUnquotedKey('unquoted'),
              TomlQuotedKey(TomlLiteralString('literal')),
              TomlQuotedKey(TomlBasicString('basic')),
            ]),
          ),
        );
      });
      test('preserves whitespace in quoted strings', () {
        expect(
          TomlKey.parse('unquoted.\' l i t e r a l \'." b a s i c "'),
          equals(
            TomlKey([
              TomlUnquotedKey('unquoted'),
              TomlQuotedKey(TomlLiteralString(' l i t e r a l ')),
              TomlQuotedKey(TomlBasicString(' b a s i c ')),
            ]),
          ),
        );
      });
    });
    group('isPrefixOf', () {
      test('returns true for identical keys', () {
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
        var prefix = TomlKey([TomlUnquotedKey('a'), TomlUnquotedKey('b')]);
        expect(key.isPrefixOf(prefix), isFalse);
      });
      test('returns true if the argument is a prefix', () {
        var key = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
          TomlUnquotedKey('c'),
        ]);
        var prefix = TomlKey([TomlUnquotedKey('a'), TomlUnquotedKey('b')]);
        expect(prefix.isPrefixOf(key), isTrue);
      });
      test('returns false for unrelated smaller keys', () {
        var key = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
          TomlUnquotedKey('c'),
        ]);
        var smallerKey = TomlKey([TomlUnquotedKey('d'), TomlUnquotedKey('e')]);
        expect(key.isPrefixOf(smallerKey), isFalse);
      });
      test('returns false for unrelated larger keys', () {
        var key = TomlKey([TomlUnquotedKey('a'), TomlUnquotedKey('b')]);
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
    group('parentKey', () {
      test('returns top-level key for top-level key', () {
        expect(TomlKey.topLevel.parentKey, equals(TomlKey.topLevel));
      });
      test('returns top-level key for singleton key', () {
        var key = TomlKey([TomlUnquotedKey('key')]);
        expect(key.parentKey, equals(TomlKey.topLevel));
      });
      test('returns parent key for key with more than one element', () {
        var key = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
          TomlUnquotedKey('c'),
        ]);
        var parent = TomlKey([TomlUnquotedKey('a'), TomlUnquotedKey('b')]);
        expect(key.parentKey, equals(parent));
      });
    });
    group('childKey', () {
      test('throws an exception for the top-level key', () {
        expect(() => TomlKey.topLevel.childKey, throwsA(isA<StateError>()));
      });
      test('returns only part for singleton key', () {
        var part = TomlUnquotedKey('key');
        var key = TomlKey([part]);
        expect(key.childKey, equals(part));
      });
      test('returns last part for key with more than one element', () {
        var a = TomlUnquotedKey('a'),
            b = TomlUnquotedKey('b'),
            c = TomlUnquotedKey('c');
        var key = TomlKey([a, b, c]);
        expect(key.childKey, equals(c));
      });
    });
    group('child', () {
      test('append the child key', () {
        var key = TomlKey([TomlUnquotedKey('key')]);
        var childKey = TomlUnquotedKey('child');
        var compositeKey = TomlKey([
          TomlUnquotedKey('key'),
          TomlUnquotedKey('child'),
        ]);
        expect(key.child(childKey), compositeKey);
      });
      test('creates a new key', () {
        var key = TomlKey([TomlUnquotedKey('key')]);
        var childKey = TomlUnquotedKey('child');
        key.child(childKey);
        expect(key.parts.length, 1);
      });
    });
    group('deepChild', () {
      test('appends all parts of the child key', () {
        var key = TomlKey([TomlUnquotedKey('a')]);
        var childKey = TomlKey([TomlUnquotedKey('b'), TomlUnquotedKey('c')]);
        var compositeKey = TomlKey([
          TomlUnquotedKey('a'),
          TomlUnquotedKey('b'),
          TomlUnquotedKey('c'),
        ]);
        expect(key.deepChild(childKey), compositeKey);
      });
      test('creates a new key', () {
        var key = TomlKey([TomlUnquotedKey('a')]);
        var childKey = TomlKey([TomlUnquotedKey('b'), TomlUnquotedKey('c')]);
        key.deepChild(childKey);
        expect(key.parts.length, 1);
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
  group('TomlSimpleKey', () {
    group('name', () {
      test('is the same as the key for unquoted keys', () {
        var key = TomlUnquotedKey('key');
        expect(key.name, equals('key'));
      });
      test('is the content of the string for quoted literal keys', () {
        var key = TomlQuotedKey(TomlLiteralString('key'));
        expect(key.name, equals('key'));
      });
      test('is the content of the string for quoted basic keys', () {
        var key = TomlQuotedKey(TomlBasicString('key'));
        expect(key.name, equals('key'));
      });
    });
    group('hashCode', () {
      test('equal unquoted keys have the same hash code', () {
        var k1 = TomlUnquotedKey('key');
        var k2 = TomlUnquotedKey('key');
        expect(k1.hashCode, equals(k2.hashCode));
      });
      test('different unquoted keys have the different hash codes', () {
        var k1 = TomlUnquotedKey('key1');
        var k2 = TomlUnquotedKey('key2');
        expect(k1.hashCode, isNot(equals(k2.hashCode)));
      });
      test('equal quoted literal keys have the same hash code', () {
        var k1 = TomlQuotedKey(TomlLiteralString('key'));
        var k2 = TomlQuotedKey(TomlLiteralString('key'));
        expect(k1.hashCode, equals(k2.hashCode));
      });
      test('different quoted literal keys have the different hash codes', () {
        var k1 = TomlQuotedKey(TomlLiteralString('key1'));
        var k2 = TomlQuotedKey(TomlLiteralString('key2'));
        expect(k1.hashCode, isNot(equals(k2.hashCode)));
      });
      test('equal quoted basic keys have the same hash code', () {
        var k1 = TomlQuotedKey(TomlBasicString('key'));
        var k2 = TomlQuotedKey(TomlBasicString('key'));
        expect(k1.hashCode, equals(k2.hashCode));
      });
      test('different quoted basic keys have the different hash codes', () {
        var k1 = TomlQuotedKey(TomlBasicString('key1'));
        var k2 = TomlQuotedKey(TomlBasicString('key2'));
        expect(k1.hashCode, isNot(equals(k2.hashCode)));
      });
      test('unquoted and quoted literal keys have different hash codes', () {
        var k1 = TomlUnquotedKey('key');
        var k2 = TomlQuotedKey(TomlLiteralString('key'));
        expect(k1.hashCode, isNot(equals(k2.hashCode)));
      });
      test('unquoted and quoted basic keys have different hash codes', () {
        var k1 = TomlUnquotedKey('key');
        var k2 = TomlQuotedKey(TomlBasicString('key'));
        expect(k1.hashCode, isNot(equals(k2.hashCode)));
      });
      test('quoted literal and basic keys have different hash codes', () {
        var k1 = TomlQuotedKey(TomlLiteralString('key'));
        var k2 = TomlQuotedKey(TomlBasicString('key'));
        expect(k1.hashCode, isNot(equals(k2.hashCode)));
      });
    });
  });
  group('TomlUnquotedKey', () {
    group('canEncode', () {
      test('cannot encode empty key', () {
        expect(TomlUnquotedKey.canEncode(''), isFalse);
      });
      test('can encode lower case key', () {
        expect(TomlUnquotedKey.canEncode('abc'), isTrue);
      });
      test('can encode upper case key', () {
        expect(TomlUnquotedKey.canEncode('ABC'), isTrue);
      });
      test('can encode numeric key', () {
        expect(TomlUnquotedKey.canEncode('123'), isTrue);
      });
      test('can encode mixed case key', () {
        expect(TomlUnquotedKey.canEncode('Key'), isTrue);
      });
      test('can encode key with dashes', () {
        expect(TomlUnquotedKey.canEncode('This-Is-A-Key'), isTrue);
      });
      test('can encode key with underscores', () {
        expect(TomlUnquotedKey.canEncode('this_is_a_key'), isTrue);
      });
      test('cannot encode key with non-ascii characters', () {
        expect(TomlUnquotedKey.canEncode('ä'), isFalse);
      });
      test('cannot encode key with leading whitespace', () {
        expect(TomlUnquotedKey.canEncode(' key'), isFalse);
      });
      test('cannot encode key with trailing whitespace', () {
        expect(TomlUnquotedKey.canEncode('key '), isFalse);
      });
      test('cannot encode key with whitespace', () {
        expect(TomlUnquotedKey.canEncode('k e y'), isFalse);
      });
    });
  });
}
