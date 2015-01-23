// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.js;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';

import 'encoder_test.dart' as encoder_test;

void main() {
  useHtmlConfiguration();
  group('JavaScript', () {
    encoder_test.main();
  });
}
