@TestOn('vm')
library toml.test.config_test;

import 'package:test/test.dart';

import 'tester/config.dart';

void main() {
  group('config test:', () {
    test('Example', () {
      testConfig('example');
    });
    test('Hard Example', () {
      testConfig('hard_example');
    });
  });
}
