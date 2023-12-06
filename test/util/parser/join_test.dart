library toml.test.util.parser.join_test;

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'package:toml/src/util/parser/join.dart';

void main() {
  group('JoinParserExtension', () {
    group('join', () {
      test('joins iterable resulting from receiver', () {
        var parser = (char('a') & char('b') & char('c')).join();
        var result = parser.parse('abc');
        expect(result, isA<Success>());
        expect(result.value, equals('abc'));
      });
      test('joins iterable resulting from receiver with separator', () {
        var parser = (char('a') & char('b') & char('c')).join('-');
        var result = parser.parse('abc');
        expect(result, isA<Success>());
        expect(result.value, equals('a-b-c'));
      });
      test('can join empty list', () {
        var parser = epsilonWith(<dynamic>[]).join();
        var result = parser.parse('abc');
        expect(result, isA<Success>());
        expect(result.value, equals(''));
      });
      test('can join singleton list', () {
        var parser = epsilonWith(['x']).join();
        var result = parser.parse('abc');
        expect(result, isA<Success>());
        expect(result.value, equals('x'));
      });
      test('joins non-string iterables', () {
        var parser = digit().map(int.parse).plus().join();
        var result = parser.parse('123');
        expect(result, isA<Success>());
        expect(result.value, equals('123'));
      });
      test('fails when joined parser fails', () {
        var parser = failure<Iterable<int>>().join();
        var result = parser.parse('123');
        expect(result, isA<Failure>());
      });
    });
  });
}
