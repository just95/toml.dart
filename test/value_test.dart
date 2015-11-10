// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.value_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

import 'tester/value.dart';

main() {
  group('value test:', () {
    test('Basic string', () {
      var cases = {
        '"'
            "I'm a string. "
            r'\"You can quote me\". '
            r'Name\tJos\u00E9\nLocation\tSF.'
            '"':
            "I'm a string. \"You can quote me\". Name\tJos\u00E9\nLocation\tSF."
      };
      cases.forEach(valueTester);

      var errors = {
        r'"some\windows\path"': new InvalidEscapeSequenceError(r'\w')
      };
      errors.forEach(valueErrorTester);
    });

    test('Multi-line basic string', () {
      var cases = {
        '"""'
            'Roses are red\n'
            'Violets are blue'
            '"""': 'Roses are red\n'
            'Violets are blue',
        '"""'
            'The quick brown \\\n\n'
            '\tfox jumps over \\\n'
            '\t\tthe lazy dog.'
            '"""': 'The quick brown fox jumps over the lazy dog.',
        '"""\\\n'
            'The quick brown \\\n'
            'fox jumps over \\\n'
            'the lazy dog.\\\n'
            '"""': 'The quick brown fox jumps over the lazy dog.'
      };
      cases.forEach(valueTester);
    });

    test('Literal string', () {
      var cases = {
        r"'C:\Users\nodejs\templates'": r'C:\Users\nodejs\templates',
        r"'\\ServerX\admin$\system32\'": r'\\ServerX\admin$\system32\',
        "'Tom \"Dubs\" Preston-Werner'": r'Tom "Dubs" Preston-Werner',
        r"'<\i\c*\s*>'": r'<\i\c*\s*>'
      };
      cases.forEach(valueTester);
    });

    test('Multi-line literal string', () {
      var cases = {
        r"'''I [dw]on't need \d{2} apples'''":
            r'''I [dw]on't need \d{2} apples''',
        "'''\n"
            'The first newline is\n'
            'trimmed in raw strings.\n'
            '   All other whitespace\n'
            '   is preserved.\n'
            "'''": 'The first newline is\n'
            'trimmed in raw strings.\n'
            '   All other whitespace\n'
            '   is preserved.\n'
      };
      cases.forEach(valueTester);
    });

    test('Integer', () {
      var cases = {'+99': 99, '42': 42, '0': 0, '-17': -17};
      cases.forEach(valueTester);

      var errors = [
        '0777' // no leading zeros
      ];
      errors.forEach(valueErrorTester);
    });

    test('Large Integer', () {
      var cases = {'1_000': 1000, '5_349_221': 5349221, '1_2_3_4_5': 12345};
      cases.forEach(valueTester);

      var errors = ['_1000', '1000_', '1__00',];
      errors.forEach(valueErrorTester);
    });

    test('Float', () {
      var cases = {
        // Fractional.
        '+1.0': 1.0,
        '3.1415': 3.1415,
        '-0.01': -0.01,

        // Exponent.
        '5e+22': 5e+22,
        '1e6': 1e6,
        '-2E-2': -2E-2,

        // Both.
        '6.626e-34': 6.626e-34
      };
      cases.forEach(valueTester);
    });

    test('Large Float', () {
      var cases = {
        '9_224_617.445_991_228_313': 9224617.445991228313,
        '1e1_000': 1e1000
      };
      cases.forEach(valueTester);

      var errors = [
        '_3.1415',
        '3._1415',
        '3_.1415',
        '3.1415_',
        '3.14__1',
        '1_e1000',
        '1e_1000',
        '1e1000_',
        '1e10__0'
      ];
      errors.forEach(valueErrorTester);
    });

    test('Boolean', () {
      var cases = {'true': true, 'false': false};
      cases.forEach(valueTester);
    });

    test('Datetime', () {
      var cases = {
        '1979-05-27T07:32:00Z': new DateTime.utc(1979, 5, 27, 7, 32, 0),
        '1979-05-27T00:32:00-07:00':
            new DateTime.utc(1979, 5, 27, 0, 32, 0).add(new Duration(hours: 7)),
        '1979-05-27T00:32:00.999999-07:00': new DateTime.utc(1979, 5, 27, 0, 32,
            1, 0 // round(0.999999) = 1
            ).add(new Duration(hours: 7))
      };
      cases.forEach(valueTester);
    });

    test('Array', () {
      var cases = {
        '[ 1, 2, 3 ]': [1, 2, 3],
        '[ 1, 2, ]': [1, 2], // Optional comma at end.
        '[ "red", "yellow", "green" ]': ['red', 'yellow', 'green'],
        '[ [ 1, 2 ], [3, 4, 5] ]': [[1, 2], [3, 4, 5]],
        '[ [ 1, 2 ], ["a", "b", "c"] ]': [[1, 2], ['a', 'b', 'c']],
        '''[
          1, 2, 3
        ]''': [1, 2, 3], // Multi-line array.
        '''[
          1,
          2, # this is ok
        ]''': [1, 2] // Comments within array.
      };
      cases.forEach(valueTester);

      var errors = [
        '[ 1, 2.0 ]', // No mixed types.
        '\n[ 1, 2, 3 ]' // `[` must be in same line as `=`.
      ];
      errors.forEach(valueErrorTester);
    });
  });
}
