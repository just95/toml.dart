library toml.test.ast.value.string.ml_basic_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlMultilineBasicString', () {
    group('escape', () {
      test('does not escape double quotes', () {
        expect(TomlMultilineBasicString.escape('"'), equals('"'));
      });
      test('escapes every third consecutive double quote', () {
        expect(
          TomlMultilineBasicString.escape('"""""""" """'),
          equals(r'""\"""\""" ""\"'),
        );
      });
      test('does not escape single quotes', () {
        expect(TomlMultilineBasicString.escape("'"), equals("'"));
      });
      test('does not escape newlines', () {
        expect(TomlMultilineBasicString.escape('\n'), equals('\n'));
      });
      test('does not escape windows newlines', () {
        expect(TomlMultilineBasicString.escape('\r\n'), equals('\r\n'));
      });
      test('escapes standalone carriage return', () {
        expect(TomlMultilineBasicString.escape('\r'), equals(r'\r'));
      });
      test('does not escape tabs', () {
        expect(TomlMultilineBasicString.escape('\t'), equals('\t'));
      });
      test('escapes control characters', () {
        expect(TomlMultilineBasicString.escape('\x07'), equals(r'\u0007'));
      });
      test('does not escape surrogate pairs', () {
        expect(
          TomlMultilineBasicString.escape('\u{1f9a6}'),
          equals('\u{1f9a6}'),
        );
      });
      test('escapes standalone high surrogate characters', () {
        expect(TomlMultilineBasicString.escape('\ud83e'), equals(r'\ud83e'));
      });
      test('escapes standalone low surrogate characters', () {
        expect(TomlMultilineBasicString.escape('\udda6'), equals(r'\udda6'));
      });
    });
    group('hashCode', () {
      test('two equal multiline basic strings have the same hash code', () {
        var s1 = TomlMultilineBasicString('value');
        var s2 = TomlMultilineBasicString('value');
        expect(s1.hashCode, equals(s2.hashCode));
      });
      test('different multiline basic strings have different hash codes', () {
        var s1 = TomlMultilineBasicString('value1');
        var s2 = TomlMultilineBasicString('value2');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
      test('multiline basic and literal strings have different hash codes', () {
        var s1 = TomlMultilineBasicString('value');
        var s2 = TomlMultilineLiteralString('value');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
    });
  });
}
