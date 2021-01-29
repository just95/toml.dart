@TestOn('vm')
library toml.test.loader.vm_test;

import 'dart:io';

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
      test('load test file with UTF-8 BOM', () {
        // When a file with BOM is loaded in the VM, the Byte Order Mark
        // is removed by the loader. Thus, the TOML parser does not have to
        // take the BOM into account.
        expect(
          loadFile('test/asset/bom.txt'),
          completion(equals(
            'This file starts with a UTF-8 Byte Order Mark (BOM).\n',
          )),
        );
      });
      test('rejects test file with invalid UTF-8 octet sequence', () {
        // When a file with an invalid octet sequence is loaded in the browser,
        // an exception is thrown.
        expect(
          loadFile('test/asset/invalid-utf8.txt'),
          throwsA(isA<FileSystemException>()),
        );
      });
    });
  });
}
