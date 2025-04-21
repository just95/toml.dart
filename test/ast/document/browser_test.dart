@TestOn('browser')
library;

import 'package:test/test.dart';
import 'package:toml/src/ast/document.dart';

void main() {
  group('TomlDocument', () {
    group('load', () {
      test('can load test document in browser', () {
        expect(TomlDocument.load('../../asset/test.toml'), completes);
      });
      test('cannot load test document in browser synchronously', () {
        expect(
          () => TomlDocument.loadSync('test/asset/test.toml'),
          throwsUnsupportedError,
        );
      });
    });
  });
}
