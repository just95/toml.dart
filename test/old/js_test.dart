@TestOn('js')
library toml.test.js_test;

import 'package:test/test.dart';

import 'tester/encoder.dart';

void main() {
  group('JavaScript', () {
    group('Encoder', () {
      group('Floats', () {
        testEncoder('without decimal places',
            input: {'x': 3.0}, output: 'x = 3\n');
      });
      group('Numeric Arrays', () {
        testEncoder('integers',
            input: {
              'a': [1, 2, 3]
            },
            output: 'a = [1, 2, 3]\n');
        testEncoder('floats without decimal places',
            input: {
              'a': [1.0, 2.0, 3.0]
            },
            output: 'a = [1, 2, 3]\n');
        testEncoder('floats with decimal places',
            input: {
              'a': [1.4, 2.5, 3.6]
            },
            output: 'a = [1.4, 2.5, 3.6]\n');
        testEncoder('mixed integers and floats without decimal places',
            input: {
              'a': [1, 2.0, 3]
            },
            output: 'a = [1, 2, 3]\n');
        testEncoder('mixed integers and floats with decimal places',
            input: {
              'a': [1, 2.0, 3.141]
            },
            output: 'a = [1.0, 2.0, 3.141]\n');
      });
    });
  });
}
