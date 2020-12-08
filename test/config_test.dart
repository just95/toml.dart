// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

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
