// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.encoder_test;

import 'package:test/test.dart';

import 'tester/encoder.dart';

void main() {
  group('Encoder', () {
    group('Strings', () {
      group('Literal', () {
        testEncoder('strings are encoded as literal strings by default',
            input: {'s': 'Hello World!'}, output: "s = 'Hello World!'\n");
        testEncoder('double quotes are not escaped',
            input: {'s': 'Double "Quotes"!'},
            output: "s = 'Double \"Quotes\"!'\n");
        testEncoder('backshlashes are not escaped',
            input: {'s': r'C:\Windows\System32'},
            output: "s = 'C:\\Windows\\System32'\n");
        testEncoder('tab character is not escaped',
            input: {'s': 'col 1\tcol 2'}, output: "s = 'col 1\tcol 2'\n");
        testEncoder(
            'if there are any newline characters a multi-line string is created',
            input: {'s': 'line 1\nline 2'},
            output: "s = '''\nline 1\nline 2'''\n");
      });
      group('Basic', () {
        testEncoder(
            'strings which contain single quotes are encoded as basic strings',
            input: {'s': "Single 'Quotes'!"},
            output: 's = "Single \'Quotes\'!"\n');
        testEncoder('tab character is not escaped',
            input: {'s': '\'col 1\tcol 2\''},
            output: 's = "\'col 1\tcol 2\'"\n');
        testEncoder('form feed character is escaped',
            input: {'s': 'page 1\fpage 2'}, output: 's = "page 1\\fpage 2"\n');
        testEncoder('control characters are escaped as unicode',
            input: {'s': 'foo\x00bar'}, output: 's = "foo\\u0000bar"\n');
        testEncoder(
            'if there are any newline characters a multi-line string is created',
            input: {
              's': 'line 1.1\'\'\'line 1.2\n'
                  'line 2.1\'\'\'line 2.2'
            },
            output: 's = """\nline 1.1\'\'\'line 1.2\n'
                'line 2.1\'\'\'line 2.2"""\n');
      });
    });

    group('Integers', () {
      testEncoder('positive', input: {'n': 1}, output: 'n = 1\n');
      testEncoder('negative', input: {'n': -1}, output: 'n = -1\n');
    });
    group('Floats', () {
      // See also platform specific encoder tests.
      testEncoder('with decimal places',
          input: {'pi': 3.141}, output: 'pi = 3.141\n');
    });

    group('Booleans', () {
      testEncoder('true', input: {'b': true}, output: 'b = true\n');
      testEncoder('false', input: {'b': false}, output: 'b = false\n');
    });

    group('Arrays', () {
      // See also platform specific encoder tests.
      testEncoder('array of strings',
          input: {
            'a': ['x', 'y', 'z']
          },
          output: "a = ['x', 'y', 'z']\n");
      testEncoder('array of booleans',
          input: {
            'a': [true, false]
          },
          output: 'a = [true, false]\n');
      testEncoder('array of arrays',
          input: {
            'a': [
              [1, 2],
              ['a', 'b']
            ]
          },
          output: "a = [[1, 2], ['a', 'b']]\n");
      testEncoderFailure('mixed arrays are not allowed', input: {
        'a': [
          [1, 'two']
        ]
      });
    });

    group('Tables', () {
      testEncoder('empty table',
          input: {'A': <String, dynamic>{}}, output: '[A]\n');
      testEncoder('non-empty table',
          input: {
            'A': {'a': 1, 'b': 2}
          },
          output: '[A]\n'
              'a = 1\n'
              'b = 2\n');
      testEncoder('multiple tables',
          input: {
            'A': {'a': 1, 'b': 2},
            'B': {'c': 3}
          },
          output: '[A]\n'
              'a = 1\n'
              'b = 2\n'
              '\n'
              '[B]\n'
              'c = 3\n');
      testEncoder('subtables',
          input: {
            'A': {
              'B': {'a': 1}
            }
          },
          output: '[A.B]\n'
              'a = 1\n');
      testEncoder('quoted keys',
          input: {
            'A.B': {
              'C': {'ä': 1}
            }
          },
          output: "['A.B'.C]\n"
              "'ä' = 1\n");
    });
  });
}
