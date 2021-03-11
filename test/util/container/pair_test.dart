library toml.test.util.container.pair_test;

import 'package:test/test.dart';

import 'package:toml/src/util/container/pair.dart';

void main() {
  group('Pair', () {
    test('pairs with equal components are equal', () {
      var p1 = Pair(1, 2);
      var p2 = Pair(1, 2);
      expect(p1, equals(p2));
    });
    test('pairs with non-equal components are not equal', () {
      var p1 = Pair(1, 2);
      var p2 = Pair(3, 4);
      expect(p1, isNot(equals(p2)));
    });
    test('hash code depends on first component', () {
      var p1 = Pair(1, 2);
      var p2 = Pair(3, 2);
      expect(p1.hashCode, isNot(equals(p2.hashCode)));
    });
    test('hash code depends on second component', () {
      var p1 = Pair(1, 2);
      var p2 = Pair(1, 3);
      expect(p1.hashCode, isNot(equals(p2.hashCode)));
    });
    test('string representation contains both components', () {
      expect(Pair(1, 2).toString(), equals('Pair(1, 2)'));
    });
  });
}
