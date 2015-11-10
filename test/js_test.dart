// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

@TestOn("browser")
library toml.test.js_test;

import 'package:test/test.dart';

import 'js/encoder_test.dart' as encoder_test;

void main() {
  group('JavaScript', () {
    encoder_test.main();
  });
}
