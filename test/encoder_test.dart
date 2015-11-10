// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.encoder_test;

import 'package:test/test.dart';

import 'tester/encoder.dart';

main() {
  group('encoder test:', () {
    test('Strings', () {
      var cases = {
        // Literal strings.
        "s = 'Hello World!'": {'s': 'Hello World!'},
        "s = 'Double \"Quotes\"!'": {'s': 'Double "Quotes"!'},
        r"s = 'C:\Windows\System32'": {'s': r'C:\Windows\System32'},

        // Basic strings.
        's = "Single \'Quotes\'!"': {'s': "Single 'Quotes'!"},
        r's = "col 1\tcol 2"': {'s': 'col 1\tcol 2'},

        // Multi-line literal strings.
        "s = '''\nline 1\nline 2'''": {'s': 'line 1\nline 2'},
        's = """\nline 1.1\\tline 1.2\n'
            'line 2.1\\tline 2.2"""': {
          's': 'line 1.1\tline 1.2\n'
              'line 2.1\tline 2.2'
        }
      };
      cases.forEach(encoderTester);
    });
    test('Values', () {
      var cases = {
        'v = 1': {'v': 1},
        'v = 3.0': {'v': 3.0},
        'v = 3.141': {'v': 3.141},
        'v = true': {'v': true},
        'v = false': {'v': false}
      };
      cases.forEach(encoderTester);
    });
    test('Arrays', () {
      var cases = {
        "a = ['x', 'y', 'z']": {'a': ['x', 'y', 'z']},
        'a = [1, 2, 3]': {'a': [1, 2, 3]},
        'a = [1.0, 2.0, 3.0]': {'a': [1.0, 2.0, 3.0]},
        'a = [true, false]': {'a': [true, false]},
        'a = [[1, 2], [1.0, 2.0]]': {'a': [[1, 2], [1.0, 2.0]]}
      };
      cases.forEach(encoderTester);

      var errors = [
        // Mixed array.
        {'a': [1, 'two']},

        // Only allowed in JavaScript.
        {'a': [1, 2.0, 3.141]}
      ];
      errors.forEach(encoderErrorTester);
    });
    test('Tables', () {
      var cases = {
        '': {'A': {}},
        '[A]\n'
            'a = 1': {'A': {'a': 1}},
        '[A]\n'
            'a = 1\n'
            'b = 2': {'A': {'a': 1, 'b': 2}},
        '[A]\n'
            'a = 1\n'
            'b = 2\n'
            '\n'
            '[B]\n'
            'c = 3': {'A': {'a': 1, 'b': 2}, 'B': {'c': 3}},
        '[A.B]\n'
            'a = 1': {'A': {'B': {'a': 1}}},
        '["A.B".C]\n'
            '"ä" = 1': {'A.B': {'C': {'ä': 1}}}
      };
      cases.forEach(encoderTester);
    });
  });
}
