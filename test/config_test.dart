// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.config_test;

import 'package:unittest/unittest.dart';

import 'tester/config.dart';

void main() {
  group('config test:', () {
    test('Example', () {
      configTester('example');
    });
  });
}
