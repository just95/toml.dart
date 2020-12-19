library toml.test.decoder.map_builder_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlMapBuilder', () {
    group('visitKeyValuePair', () {
      test('key/value pairs are inserted at top-level by default', () {
        var builder = TomlMapBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key'),
          TomlLiteralString('value'),
        ));
        expect(builder.build(), equals({'key': 'value'}));
      });
      test('throws an exception if the key/value pair is defined already', () {
        var builder = TomlMapBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key'),
          TomlInteger(1),
        ));
        expect(
          () => builder.visitKeyValuePair(TomlKeyValuePair(
            TomlUnquotedKey('key'),
            TomlInteger(2),
          )),
          throwsA(
            equals(
              TomlRedefinitionException(TomlKey([TomlUnquotedKey('key')])),
            ),
          ),
        );
      });
    });

    group('visitStandardTable', () {
      test('standalone standard table headers create empty tables', () {
        var builder = TomlMapBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('table')]),
        ));
        expect(
          builder.build(),
          equals({'table': {}}),
        );
      });
      test('key/value pairs are relative to current standard table', () {
        var builder = TomlMapBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('table')]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key'),
          TomlLiteralString('value'),
        ));
        expect(
          builder.build(),
          equals({
            'table': {'key': 'value'}
          }),
        );
      });
      test('names of standard tables headers are absolute', () {
        var builder = TomlMapBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('table1')]),
        ));
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('table2')]),
        ));
        expect(
          builder.build(),
          equals({'table1': {}, 'table2': {}}),
        );
      });
      test('standard table headers create parent table implicitly', () {
        var builder = TomlMapBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([
            TomlUnquotedKey('parent'),
            TomlUnquotedKey('table'),
          ]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key'),
          TomlLiteralString('value'),
        ));
        expect(
          builder.build(),
          equals({
            'parent': {
              'table': {'key': 'value'}
            }
          }),
        );
      });
      test("explicit declarations don't overwrite implicitly created tables",
          () {
        var builder = TomlMapBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([
            TomlUnquotedKey('parent'),
            TomlUnquotedKey('table'),
          ]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key1'),
          TomlInteger(1),
        ));
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('parent')]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key2'),
          TomlInteger(2),
        ));
        expect(
          builder.build(),
          equals({
            'parent': {
              'table': {'key1': 1},
              'key2': 2
            }
          }),
        );
      });
      test("implicit declarations don't overwrite explicitly created tables",
          () {
        var builder = TomlMapBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('parent')]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key1'),
          TomlInteger(1),
        ));
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([
            TomlUnquotedKey('parent'),
            TomlUnquotedKey('table'),
          ]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key2'),
          TomlInteger(2),
        ));
        expect(
          builder.build(),
          equals({
            'parent': {
              'key1': 1,
              'table': {'key2': 2}
            }
          }),
        );
      });
      test('throws an exception if the table is defined already', () {
        var builder = TomlMapBuilder();
        builder.visitStandardTable(TomlStandardTable(TomlKey([
          TomlUnquotedKey('table'),
        ])));
        expect(
          () => builder.visitStandardTable(TomlStandardTable(TomlKey([
            TomlUnquotedKey('table'),
          ]))),
          throwsA(
            equals(
              TomlRedefinitionException(TomlKey([TomlUnquotedKey('table')])),
            ),
          ),
        );
      });
      test('throws an exception if a value with the same name exists', () {
        var builder = TomlMapBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key'),
          TomlLiteralString('value'),
        ));
        expect(
          () => builder.visitStandardTable(TomlStandardTable(TomlKey([
            TomlUnquotedKey('key'),
          ]))),
          throwsA(
            equals(
              TomlRedefinitionException(TomlKey([TomlUnquotedKey('key')])),
            ),
          ),
        );
      });
      test('throws an exception if a parent is not a table', () {
        var builder = TomlMapBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key'),
          TomlLiteralString('value'),
        ));
        expect(
          () => builder.visitStandardTable(TomlStandardTable(TomlKey([
            TomlUnquotedKey('key'),
            TomlUnquotedKey('child1'),
            TomlUnquotedKey('child2'),
          ]))),
          throwsA(
            equals(
              TomlNotATableException(TomlKey([
                TomlUnquotedKey('key'),
                TomlUnquotedKey('child1'),
              ])),
            ),
          ),
        );
      });
      test('throws an exception if a parent is an inline table', () {
        var builder = TomlMapBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key'),
          TomlInlineTable([]),
        ));
        expect(
          () => builder.visitStandardTable(TomlStandardTable(TomlKey([
            TomlUnquotedKey('key'),
            TomlUnquotedKey('child'),
          ]))),
          throwsA(
            equals(
              TomlNotATableException(TomlKey([
                TomlUnquotedKey('key'),
                TomlUnquotedKey('child'),
              ])),
            ),
          ),
        );
      });
    });

    group('visitArrayTable', () {
      test(
        'standalone array table headers create one elementry arrays of tables',
        () {
          var builder = TomlMapBuilder();
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('array')]),
          ));
          expect(
            builder.build(),
            equals({
              'array': [{}]
            }),
          );
        },
      );
      test(
        'additional array table headers add items to array of tables',
        () {
          var builder = TomlMapBuilder();
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('array')]),
          ));
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('array')]),
          ));
          expect(
            builder.build(),
            equals({
              'array': [{}, {}]
            }),
          );
        },
      );
      test(
        'key/value-pairs are inserted into last item of array of tables',
        () {
          var builder = TomlMapBuilder();
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('array')]),
          ));
          builder.visitKeyValuePair(TomlKeyValuePair(
            TomlUnquotedKey('key1'),
            TomlInteger(1),
          ));
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('array')]),
          ));
          builder.visitKeyValuePair(TomlKeyValuePair(
            TomlUnquotedKey('key2'),
            TomlInteger(2),
          ));
          expect(
            builder.build(),
            equals({
              'array': [
                {'key1': 1},
                {'key2': 2}
              ]
            }),
          );
        },
      );
      test(
        'throws an exception if there is a standard table with the same name',
        () {
          var builder = TomlMapBuilder();
          builder.visitStandardTable(TomlStandardTable(
            TomlKey([TomlUnquotedKey('foo')]),
          ));
          expect(
            () => builder.visitArrayTable(TomlArrayTable(
              TomlKey([TomlUnquotedKey('foo')]),
            )),
            throwsA(equals(TomlRedefinitionException(
              TomlKey([TomlUnquotedKey('foo')]),
            ))),
          );
        },
      );
      test('throws an exception if a parent is not a table', () {
        var builder = TomlMapBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlUnquotedKey('key'),
          TomlLiteralString('value'),
        ));
        expect(
          () => builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('key'), TomlUnquotedKey('array')]),
          )),
          throwsA(equals(TomlNotATableException(
            TomlKey([TomlUnquotedKey('key'), TomlUnquotedKey('array')]),
          ))),
        );
      });
      test('can add child table to array of table entry', () {
        var builder = TomlMapBuilder();
        builder.visitArrayTable(TomlArrayTable(
          TomlKey([TomlUnquotedKey('array')]),
        ));
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('array'), TomlUnquotedKey('table')]),
        ));
        expect(
          builder.build(),
          equals({
            'array': [
              {'table': {}}
            ]
          }),
        );
      });
    });
  });
}
