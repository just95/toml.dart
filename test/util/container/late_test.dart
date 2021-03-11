library toml.test.util.container.late_test;

import 'package:test/test.dart';

import 'package:toml/src/util/container/late.dart';

void main() {
  group('Late', () {
    test("doesn't evaluate thunk if the value is not used", () {
      var n = 0;
      Late(() => n++);
      expect(n, equals(0));
    });
    test('evaluates thunk if the value is used', () {
      var n = 0;
      var inc = Late(() => n++);
      expect([inc.value, n], equals([0, 1]));
    });
    test('evaluates thunk only once if the value is used twice', () {
      var n = 0;
      var inc = Late(() => n++);
      expect([inc.value, inc.value, n], equals([0, 0, 1]));
    });
  });
}
