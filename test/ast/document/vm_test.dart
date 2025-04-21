@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:toml/src/ast/document.dart';

void main() {
  group('TomlDocument', () {
    group('load', () {
      test('can load test document in VM', () {
        expect(TomlDocument.load('test/asset/test.toml'), completes);
      });
      test('can load test document in VM synchronously', () {
        expect(
          () => TomlDocument.loadSync('test/asset/test.toml'),
          returnsNormally,
        );
      });
    });
  });
}
