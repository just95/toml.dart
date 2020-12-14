@TestOn('vm')
library toml.test.loader.vm_test;

import 'package:test/test.dart';

import 'package:toml/src/loader.dart';

void main() {
  group('Loader', () {
    group('VM', () {
      test('load test file', () {
        expect(
          loadFile('test/asset/test.txt'),
          completion(equals('Test\n')),
        );
      });
    });
  });
}
