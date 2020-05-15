// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.value_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

import 'tester/value.dart';

void main() {
  group('Values', () {
    group('Strings', () {
      group('Basic', () {
        testValue('empty', input: '""', output: '');
        testValue('escape sequences',
            input: '"I\'m a string. '
                '\\"You can quote me\\". '
                'Name\\tJos\\u00E9\\nLocation\\tSF."',
            output: 'I\'m a string. '
                '\"You can quote me\". '
                'Name\tJos\u00E9\nLocation\tSF.');
        testValueFailure('invalid escape sequences',
            input: r'"some\windows\path"',
            error: InvalidEscapeSequenceError(r'\w'));
        testValue('multi-line',
            input: '"""Roses are red\n'
                'Violets are blue"""',
            output: 'Roses are red\n'
                'Violets are blue');
        testValue('escape newline characters',
            input: '"""\\\n'
                'The quick brown \\\n'
                'fox jumps over \\\n'
                'the lazy dog.\\\n'
                '"""',
            output: 'The quick brown fox jumps over the lazy dog.');
        testValue('escape newline and tab characters',
            input: '"""\n'
                'The quick brown \\\n\n'
                '\tfox jumps over \\\n'
                '\t\tthe lazy dog."""',
            output: 'The quick brown fox jumps over the lazy dog.');
      });

      group('Literal', () {
        testValue('empty', input: "''", output: '');
        testValue('windows path',
            input: r"'C:\Users\nodejs\templates'",
            output: r'C:\Users\nodejs\templates');
        testValue('windows network path',
            input: r"'\\ServerX\admin$\system32\'",
            output: r'\\ServerX\admin$\system32\');
        testValue('contain double quotes',
            input: r"'<\i\c*\s*>'", output: '<\\i\\c*\\s*>');
        testValue('regular expression',
            input: "'Tom \"Dubs\" Preston-Werner'",
            output: 'Tom "Dubs" Preston-Werner');
        testValue('multi-line regular expression',
            input: r"'''I [dw]on't need \d{2} apples'''",
            output: 'I [dw]on\'t need \\d{2} apples');
        testValue('trim first newline',
            input: "'''\n"
                'The first newline is\n'
                'trimmed in raw strings.\n'
                '   All other whitespace\n'
                '   is preserved.\n'
                "'''",
            output: 'The first newline is\n'
                'trimmed in raw strings.\n'
                '   All other whitespace\n'
                '   is preserved.\n');
      });
    });

    group('Integer', () {
      testValue('positive number', input: '+99', output: 99);
      testValue('plus sign is optional', input: '42', output: 42);
      testValue('zero', input: '0', output: 0);
      testValue('negative number', input: '-17', output: -17);
      testValueFailure('leading zeros atre not allowed', input: '0777');
      testValue('underscore', input: '1_000', output: 1000);
      testValue('underscores', input: '5_349_221', output: 5349221);
      testValue('inadvisable usage of underscores',
          input: '1_2_3_4_5', output: 12345);
      testValueFailure('leading underscores are not allowed', input: '_1000');
      testValueFailure('trailing underscores are not allowed', input: '1000_');
      testValueFailure('consecutive underscores are not allowed',
          input: '1__000');
    });

    group('Float', () {
      testValue('positive number', input: '+1.0', output: 1.0);
      testValue('plus sign is optional', input: '3.1415', output: 3.1415);
      testValue('negative number', input: '-0.01', output: -0.01);
      testValue('positve exponent part', input: '5e+22', output: 5e+22);
      testValue('plus sign of exponent part is optional',
          input: '1e6', output: 1e6);
      testValue('negative number', input: '-2E-2', output: -2E-2);
      testValue('fractional and exponent part',
          input: '6.626e-34', output: 6.626e-34);
      testValue('underscores in integer and fractional part',
          input: '9_224_617.445_991_228_313', output: 9224617.445991228313);
      testValue('underscores in exponent part',
          input: '1e1_000', output: 1e1000);
      testValueFailure(
          'leading underscores are not allowed in the integer part',
          input: '_3.1415');
      testValueFailure(
          'leading underscores are not allowed in the fractional part',
          input: '3._1415');
      testValueFailure(
          'trailing underscores are not allowed in the integer part',
          input: '3_.1415');
      testValueFailure(
          'trailing underscores are not allowed in the fractional part',
          input: '3.1415_');
      testValueFailure(
          'consecutive underscores are not allowed in the fractional part',
          input: '3.14__1');
      testValueFailure(
          'trailing underscores are not allowed before the exponent',
          input: '1_e1000');
      testValueFailure(
          'leading underscores are not allowed in the exponent part',
          input: '1e_1000');
      testValueFailure(
          'trailing underscores are not allowed in the exponent part',
          input: '1e1000_');
      testValueFailure(
          'consecutive underscores are not allowed in the exponent part',
          input: '1e10__0');
    });

    group('Boolean', () {
      testValue('true', input: 'true', output: true);
      testValue('false', input: 'false', output: false);
    });

    group('Datetime', () {
      testValue('utc',
          input: '1979-05-27T07:32:00Z',
          output: DateTime.utc(1979, 5, 27, 7, 32, 0));
      testValue('timezone',
          input: '1979-05-27T00:32:00-07:00',
          output: DateTime.utc(1979, 5, 27, 0, 32, 0).add(Duration(hours: 7)));
      testValue('fractions of a second',
          input: '1979-05-27T00:32:00.999999-07:00',
          output: DateTime.utc(1979, 5, 27, 0, 32, 0, 999, 999)
              .add(Duration(hours: 7)));
    });

    group('Array', () {
      testValue('array', input: '[]', output: []);
      testValue('array of integers', input: '[ 1, 2, 3 ]', output: [1, 2, 3]);
      testValue('optional trailing comma', input: '[ 1, 2, ]', output: [1, 2]);
      testValue('array of strings',
          input: '[ "red", "yellow", "green" ]',
          output: ['red', 'yellow', 'green']);
      testValue('array of arrays of the same type',
          input: '[ [ 1, 2 ], [3, 4, 5] ]',
          output: [
            [1, 2],
            [3, 4, 5]
          ]);
      testValue('array of arrays of different types',
          input: '[ [ 1, 2 ], ["a", "b", "c"] ]',
          output: [
            [1, 2],
            ['a', 'b', 'c']
          ]);
      testValue('there can be newlines in an array', input: '''[
          1, 2, 3
        ]''', output: [1, 2, 3]);
      testValue('there can be comments in an array', input: '''[
          1,
          2, # this is ok
        ]''', output: [1, 2]);
      testValueFailure('arrays of mixed types are not allowed',
          input: '[ 1, 2.0 ]');
      testValueFailure(
          'the opening bracket must be on the same line as the key',
          input: '\n[ 1, 2, 3 ]');
    });
  });
}
