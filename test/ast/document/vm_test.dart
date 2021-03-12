@TestOn('vm')
library toml.test.ast.document.vm_test;

import 'package:test/test.dart';
import 'package:toml/src/ast/document.dart';

void main() {
  group('TomlDocument', () {
    group('load', () {
      test('can load test document in VM', () {
        expect(TomlDocument.load('test/asset/test.toml'), completes);
      });
    });
  });
}
