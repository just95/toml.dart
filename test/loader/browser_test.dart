@TestOn('browser')
library toml.test.loader.browser_test;

import 'package:test/test.dart';

import 'package:toml/src/loader.dart';
import 'package:toml/src/loader/exception/unexpected_http_status.dart';

void main() {
  group('Loader', () {
    group('Browser', () {
      test('can load test file', () {
        expect(loadFile('../asset/test.txt'), completion(equals('Test\n')));
      });
      test('throws exception if file does not exist', () {
        expect(
          () => loadFile('../no/such/file.txt'),
          throwsA(equals(TomlUnexpectedHttpStatusException(404, "Not Found"))),
        );
      });
      test('can load test file with UTF-8 BOM', () {
        // When a file with BOM is loaded in the browser, the Byte Order Mark
        // is removed by the loader. Thus, the TOML parser does not have to
        // take the BOM into account.
        expect(
          loadFile('../asset/bom.txt'),
          completion(
            equals('This file starts with a UTF-8 Byte Order Mark (BOM).\n'),
          ),
        );
      });
      test('rejects test file with malformed UTF-8 octet sequence', () {
        // When a file with an malformed octet sequence is loaded in the
        // browser, an exception is thrown.
        expect(
          loadFile('../asset/malformed-utf8.txt'),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
