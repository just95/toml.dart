// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.document_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

import 'tester/document.dart';

void main() {
  group('Document', () {
    group('Tables', () {
      testDocument('empty table', input: '[table]', output: {'table': {}});
      testDocument('quoted keys',
          input: '[dog."tater.man"]\n'
              'type = "pug"',
          output: {
            'dog': {
              'tater.man': {'type': 'pug'}
            }
          });
      testDocument('unquoted keys', input: '[a.b.c]', output: {
        'a': {
          'b': {'c': {}}
        }
      });
      testDocument('whitespace after opening and before closing brackets',
          input: '[ d.e.f ]',
          output: {
            'd': {
              'e': {'f': {}}
            }
          });
      testDocument('whitespace around keys', input: '[ g .  h  . i ]', output: {
        'g': {
          'h': {'i': {}}
        }
      });
      testDocument('non latin letters in table names',
          input: '[ j . "ʞ" . l ]',
          output: {
            'j': {
              'ʞ': {'l': {}}
            }
          });
      testDocument('empty super-tables are not required',
          input: '''
          # [x] you
          # [x.y] don't
          # [x.y.z] need these
          [x.y.z.w] # for this to work
        ''',
          output: {
            'x': {
              'y': {
                'z': {'w': {}}
              }
            }
          });
      testDocument('super-tables do not need to preceed their children',
          input: '''
          [a.b]
          c = 1

          [a]
          d = 2
        ''',
          output: {
            'a': {
              'b': {'c': 1},
              'd': 2
            }
          });
      testDocumentFailure('tables cannot be defined more than once',
          input: '''
          # DO NOT DO THIS

          [a]
          b = 1

          [a]
          c = 2
        ''',
          error: new RedefinitionError('a'));
      testDocumentFailure('tables cannot overwrite keys',
          input: '''
          # DO NOT DO THIS EITHER

          [a]
          b = 1

          [a.b]
          c = 2
        ''',
          error: new RedefinitionError('a.b'));
      testDocumentFailure('parent of table must be table',
          input: '''
          [a]
          b = 1

          [a.b.c]
          d = 2
        ''',
          error: new NotATableError('a.b'));
      testDocumentFailure(
          'an implicitly created super-table cannot be overwritten',
          input: '''
          [a.b.c]
          d = 1

          [a]
          b = 2
        ''',
          error: new RedefinitionError('a.b'));
      testDocumentFailure('table name must not be empty', input: '[]');
      testDocumentFailure('table name must not end with a dot', input: '[a.]');
      testDocumentFailure('table name must not contain empty parts',
          input: '[a..b]');
      testDocumentFailure('table name must not start with a dot',
          input: '[.b]');
      testDocumentFailure('table name must not be a dot', input: '[.]');
      testDocumentFailure('key must not be empty', input: '= "no key name"');
    });

    group('Array of Tables', () {
      testDocument('empty table',
          input: '''
          [[products]]
          name = "Hammer"
          sku = 738594937

          [[products]]

          [[products]]
          name = "Nail"
          sku = 284758393
          color = "gray"
        ''',
          output: {
            'products': [
              {'name': 'Hammer', 'sku': 738594937},
              {},
              {'name': 'Nail', 'sku': 284758393, 'color': 'gray'}
            ]
          });
      testDocument('sub-tables',
          input: '''
          [[fruit]]
            name = "apple"

            [fruit.physical]
              color = "red"
              shape = "round"

            [[fruit.variety]]
              name = "red delicious"

            [[fruit.variety]]
              name = "granny smith"

          [[fruit]]
            name = "banana"

            [[fruit.variety]]
              name = "plantain"
        ''',
          output: {
            'fruit': [
              {
                'name': 'apple',
                'physical': {'color': 'red', 'shape': 'round'},
                'variety': [
                  {'name': 'red delicious'},
                  {'name': 'granny smith'}
                ]
              },
              {
                'name': 'banana',
                'variety': [
                  {'name': 'plantain'}
                ]
              }
            ]
          });
      testDocumentFailure('table cannot overwrite array of tables',
          input: '''
          # INVALID TOML DOC
          [[fruit]]
            name = "apple"

            [[fruit.variety]]
              name = "red delicious"

            # This table conflicts with the previous table
            [fruit.variety]
             name = "granny smith"
        ''',
          error: new RedefinitionError('fruit[0].variety'));
      testDocumentFailure('array of tables cannot overwrite table',
          input: '''
          # INVALID TOML DOC
          [[fruit]]
            name = "apple"

            [fruit.variety]
             name = "granny smith"

            # This table conflicts with the previous table
            [[fruit.variety]]
              name = "red delicious"
        ''',
          error: new RedefinitionError('fruit[0].variety'));
    });

    group('Inline Tables', () {
      testDocument('whitespace around key/value pairs',
          input: '''
          name = { first = "Tom", last = "Preston-Werner" }
        ''',
          output: {
            'name': {'first': 'Tom', 'last': 'Preston-Werner'}
          });
      testDocument('no whitespace around key/value pairs',
          input: '''
          point = {x=1,y=2}
        ''',
          output: {
            'point': {'x': 1, 'y': 2}
          });
      testDocument('newlines are allowed in values',
          input: '''
          points = [ { x = 1, y = 2, z = 3 },
                     { x = 7, y = 8, z = 9 },
                     { x = 2, y = 4, z = 8 } ]
        ''',
          output: {
            'points': [
              {'x': 1, 'y': 2, 'z': 3},
              {'x': 7, 'y': 8, 'z': 9},
              {'x': 2, 'y': 4, 'z': 8}
            ]
          });
      testDocumentFailure('newlines are not allowed in the table',
          input: '''
          address = {
            proto = "http",
            ip = "10.0.0.1",
            port = 8080
          }
        ''');
    });
  });
}
