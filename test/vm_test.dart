// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

@TestOn("vm")
library toml.test.vm_test;

import 'package:test/test.dart';

import 'tester/encoder.dart';

void main() {
  group('Dart VM', () {
    group('Encoder', () {
      group('Floats', () {
        testEncoder('without decimal places',
            input: {'x': 3.0}, output: 'x = 3.0');
      });
      group('Numeric Arrays', () {
        testEncoder('integers',
            input: {
              'a': [1, 2, 3]
            },
            output: 'a = [1, 2, 3]');
        testEncoder('floats without decimal places',
            input: {
              'a': [1.0, 2.0, 3.0]
            },
            output: 'a = [1.0, 2.0, 3.0]');
        testEncoder('floats with decimal places',
            input: {
              'a': [1.4, 2.5, 3.6]
            },
            output: 'a = [1.4, 2.5, 3.6]');
        testEncoderFailure('mixed integers and floats without decimal places',
            input: {
              'a': [1, 2.0, 3]
            });
        testEncoderFailure('mixed integers and floats with decimal places',
            input: {
              'a': [1, 2.0, 3.141]
            });
      });
    });
  });
}
