@TestOn('browser')
library toml.test.loader.browser_test;

import 'package:test/test.dart';

import 'package:toml/src/loader.dart';

void main() {
  group('Loader', () {
    group('Browser', () {
      test('load test file', () {
        expect(
          loadFile('../asset/test.txt'),
          completion(equals('Test\n')),
        );
      });
    });
  });
}
