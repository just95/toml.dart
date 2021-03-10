library toml.test.util.iterable.where_not_null_test;

import 'package:test/test.dart';

import 'package:toml/src/util/iterable/where_not_null.dart';

void main() {
  group('WhereNotNullExtension', () {
    group('whereNotNull', () {
      test('filters null values', () {
        expect([1, null, 2, null, 3].whereNotNull(), equals([1, 2, 3]));
      });
      test('makes new list element type non-nullable', () {
        expect([1, null, 2, null, 3].whereNotNull(), isA<Iterable<int>>());
      });
    });
  });
}
