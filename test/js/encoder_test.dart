// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.js_encoder;

import 'package:test/test.dart';

import '../tester/encoder.dart';

void main() {
  group('encoder test:', () {
    test('Numeric Arrays', () {
      var cases = {
        'a = [1]': {'a': [1]},
        'a = [1, 2]': {'a': [1, 2.0]},
        'a = [1, 2, 3]': {'a': [1.0, 2.0, 3.0]},

        // Only allowed in JavaScript.
        'a = [1.0, 2.0, 3.141]': {'a': [1, 2.0, 3.141]}
      };
      cases.forEach(encoderTester);
    });
  });
}
