@TestOn('browser')
library toml.test.ast.document.browser_test;

import 'package:test/test.dart';
import 'package:toml/src/ast/document.dart';

void main() {
  group('TomlDocument', () {
    group('load', () {
      test('can load test document in browser', () {
        expect(TomlDocument.load('../../asset/test.toml'), completes);
      });
    });
  });
}
