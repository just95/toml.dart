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
      test('load test file with UTF-8 BOM', () {
        // When a file with BOM is loaded in the browser, the Byte Order Mark
        // is removed by the loader. Thus, the TOML parser does not have to
        // take the BOM into account.
        expect(
          loadFile('../asset/bom.txt'),
          completion(equals(
            'This file starts with a UTF-8 Byte Order Mark (BOM).\n',
          )),
        );
      });
    });
  });
}
