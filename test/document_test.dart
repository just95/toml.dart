// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.document_test;

import 'package:unittest/unittest.dart';
import 'package:toml/toml.dart';

import 'tester/document.dart';

main() {
  group('document test:', () {
    test('Tables', () {
      var cases = {
        '''
          [table]
        ''': {'table': {}},
        '''
          [dog."tater.man"]
          type = "pug"
        ''': { 'dog': { 'tater.man': { 'type': 'pug' } } },
        '''
          [a.b.c]          # this is best practice
          [ d.e.f ]        # same as [d.e.f]
          [ g .  h  . i ]  # same as [g.h.i]
          [ j . "ʞ" . l ]  # same as [j."ʞ".l]
        ''': {
           'a': {'b': {'c': {}}},
           'd': {'e': {'f': {}}},
           'g': {'h': {'i': {}}},
           'j': {'ʞ': {'l': {}}}
         },
        '''
          # [x] you
          # [x.y] don't
          # [x.y.z] need these
          [x.y.z.w] # for this to work
        ''': {'x': {'y': {'z': {'w': {}}}}},
        '''
          [a.b]
          c = 1
          
          [a]
          d = 2
        ''': {'a': {'b': {'c': 1}, 'd': 2}}
      };
      cases.forEach(documentTester);
      
      var errors = {
        '''
          # DO NOT DO THIS
          
          [a]
          b = 1
          
          [a]
          c = 2
        ''': new RedefinitionError('a'),
        '''
          # DO NOT DO THIS EITHER
          
          [a]
          b = 1
          
          [a.b]
          c = 2
        ''': new RedefinitionError('a.b'),
        '''
          [a]
          b = 1
          
          [a.b.c]
          d = 2
        ''': new NotATableError('a.b'),
        '''
          [a.b.c]
          d = 1
      
          [a]
          b = 2
        ''': new RedefinitionError('a.b')
      };
      errors.forEach(documentErrorTester);
      
      errors = [
        '[]',
        '[a.]',
        '[a..b]',
        '[.b]',
        '[.]',
        '= "no key name"'
      ];
      errors.forEach(documentErrorTester);
    });
    
    test('Array of Tables', () {
      var cases = {
        '''
          [[products]]
          name = "Hammer"
          sku = 738594937
          
          [[products]]
          
          [[products]]
          name = "Nail"
          sku = 284758393
          color = "gray"
        ''': {
          'products': [
            { 'name': 'Hammer', 'sku': 738594937 },
            { },
            { 'name': 'Nail', 'sku': 284758393, 'color': 'gray' }
          ]
        },
        '''
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
        ''': {
          'fruit': [
            {
              'name': 'apple',
              'physical': {
                'color': 'red',
                'shape': 'round'
              },
              'variety': [
                { 'name': 'red delicious' },
                { 'name': 'granny smith' }
              ]
            },
            {
              'name': 'banana',
              'variety': [
                { 'name': 'plantain' }
              ]
            }
          ]
        }
      };
      cases.forEach(documentTester);
      
      var errors = {
                    '''
          # INVALID TOML DOC
          [[fruit]]
            name = "apple"
          
            [[fruit.variety]]
              name = "red delicious"
          
            # This table conflicts with the previous table
            [fruit.variety]
             name = "granny smith"
        ''': new RedefinitionError('fruit[0].variety'),
        '''
          # INVALID TOML DOC
          [[fruit]]
            name = "apple"
          
            [fruit.variety]
             name = "granny smith"
          
            # This table conflicts with the previous table
            [[fruit.variety]]
              name = "red delicious"
        ''': new RedefinitionError('fruit[0].variety')              
      };
      errors.forEach(documentErrorTester);
    });
    
    test('Inline Tables', () {
      var cases = {
        '''
          name = { first = "Tom", last = "Preston-Werner" }
          point = { x = 1, y = 2 }
          address = { proto = "http", ip = "10.0.0.1", port = 8080 }
          points = [ { x = 1, y = 2, z = 3 },
                     { x = 7, y = 8, z = 9 },
                     { x = 2, y = 4, z = 8 } ]
        ''': {
          'name': {'first': 'Tom', 'last': 'Preston-Werner'},
          'point': {'x': 1, 'y': 2},
          'address': {'proto': 'http', 'ip': '10.0.0.1', 'port': 8080},
          'points': [
             {'x': 1, 'y': 2, 'z': 3},
             {'x': 7, 'y': 8, 'z': 9},   
             {'x': 2, 'y': 4, 'z': 8}         
          ]
        }
      };
      cases.forEach(documentTester);
    });
     
    test('Example', () {
      var examples = {
        '''
          # This is a TOML document. Boom.

          title = "TOML Example"
          
          [owner]
          name = "Lance Uppercut"
          dob = 1979-05-27T07:32:00-08:00 # First class dates? Why not?
          
          [database]
          server = "192.168.1.1"
          ports = [ 8001, 8001, 8002 ]
          connection_max = 5000
          enabled = true
          
          [servers]
          
            # You can indent as you please. Tabs or spaces. TOML don't care.
            [servers.alpha]
            ip = "10.0.0.1"
            dc = "eqdc10"
          
            [servers.beta]
            ip = "10.0.0.2"
            dc = "eqdc10"
          
          [clients]
          data = [ ["gamma", "delta"], [1, 2] ]
          
          # Line breaks are OK when inside arrays
          hosts = [
            "alpha",
            "omega"
          ]
        ''': {
          'title': 'TOML Example',
          'owner': {
            'name': 'Lance Uppercut',
            'dob': new DateTime.utc(1979, 5, 27, 7, 32)
                               .add(new Duration(hours: 8))
          },
          'database': {
            'server': '192.168.1.1',
            'ports': [ 8001, 8001, 8002 ],
            'connection_max': 5000,
            'enabled': true
          },
          'servers': {
            'alpha': {
              'ip': '10.0.0.1',
              'dc': 'eqdc10'
            },
            'beta': {
              'ip': '10.0.0.2',
              'dc': 'eqdc10'
            }
          },
          'clients': {
            'data': [ ['gamma', 'delta'], [1, 2] ],
            'hosts': [
              'alpha',
              'omega'
            ]
          }
        }
      };
      examples.forEach(documentTester);
    });
  });
}
