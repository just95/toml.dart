library toml.test.decoder.accessor_builder_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

import '../accessor/matcher.dart';

void main() {
  group('TomlAccessorBuilder', () {
    group('visitKeyValuePair', () {
      test('key/value pairs are inserted at top-level by default', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        ));
        expect(
          builder.topLevel,
          equalsAccessor(TomlDocumentAccessor({
            'key': TomlValueAccessor(TomlLiteralString('value')),
          })),
        );
      });
      test('dotted key/value pairs are inserted into child tables', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([
            TomlUnquotedKey('a'),
            TomlUnquotedKey('b'),
            TomlUnquotedKey('c'),
          ]),
          TomlLiteralString('value'),
        ));
        expect(
          builder.topLevel,
          equalsAccessor(TomlDocumentAccessor({
            'a': TomlTableAccessor({
              'b': TomlTableAccessor({
                'c': TomlValueAccessor(TomlLiteralString('value')),
              })
            })
          })),
        );
      });
      test('allows multiple dotted keys with same parent', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([
            TomlUnquotedKey('a'),
            TomlUnquotedKey('b'),
            TomlUnquotedKey('c'),
          ]),
          TomlInteger.dec(BigInt.from(1)),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([
            TomlUnquotedKey('a'),
            TomlUnquotedKey('d'),
          ]),
          TomlInteger.dec(BigInt.from(2)),
        ));
        expect(
          builder.topLevel,
          equalsAccessor(TomlDocumentAccessor({
            'a': TomlTableAccessor({
              'b': TomlTableAccessor({
                'c': TomlValueAccessor(TomlInteger.dec(BigInt.from(1))),
              }),
              'd': TomlValueAccessor(TomlInteger.dec(BigInt.from(2))),
            })
          })),
        );
      });
      test('throws an exception if the key/value pair is defined already', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlInteger.dec(BigInt.from(1)),
        ));
        expect(
          () => builder.visitKeyValuePair(TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key')]),
            TomlInteger.dec(BigInt.from(2)),
          )),
          throwsA(equals(
            TomlRedefinitionException(TomlAccessorKey.from(['key'])),
          )),
        );
      });
      test(
        'throws an exception if the immediate parent of dotted key exists and '
        'is not a table',
        () {
          var builder = TomlAccessorBuilder();
          builder.visitKeyValuePair(TomlKeyValuePair(
            TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
            ]),
            TomlLiteralString('value'),
          ));
          expect(
            () => builder.visitKeyValuePair(TomlKeyValuePair(
              TomlKey([
                TomlUnquotedKey('a'),
                TomlUnquotedKey('b'),
                TomlUnquotedKey('c'),
              ]),
              TomlLiteralString('value'),
            )),
            throwsA(equals(
              TomlTypeException(
                TomlAccessorKey.from(['a', 'b']),
                expectedType: TomlAccessorType.table,
                actualType: TomlAccessorType.value,
              ),
            )),
          );
        },
      );
      test(
        'throws an exception if a parent of dotted key exists and is not a '
        'table',
        () {
          var builder = TomlAccessorBuilder();
          builder.visitKeyValuePair(TomlKeyValuePair(
            TomlKey([
              TomlUnquotedKey('a'),
            ]),
            TomlLiteralString('value'),
          ));
          expect(
            () => builder.visitKeyValuePair(TomlKeyValuePair(
              TomlKey([
                TomlUnquotedKey('a'),
                TomlUnquotedKey('b'),
                TomlUnquotedKey('c'),
              ]),
              TomlLiteralString('value'),
            )),
            throwsA(equals(
              TomlTypeException(
                TomlAccessorKey.from(['a']),
                expectedType: TomlAccessorType.table,
                actualType: TomlAccessorType.value,
              ),
            )),
          );
        },
      );
      test(
        'cannot insert key/value pair into inline table',
        () {
          var builder = TomlAccessorBuilder();
          builder.visitKeyValuePair(TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('table')]),
            TomlInlineTable([]),
          ));
          expect(
            () => builder.visitKeyValuePair(TomlKeyValuePair(
              TomlKey([
                TomlUnquotedKey('table'),
                TomlUnquotedKey('key'),
              ]),
              TomlLiteralString('value'),
            )),
            throwsA(equals(
              TomlRedefinitionException(TomlAccessorKey.from(['table'])),
            )),
          );
        },
      );
    });

    group('visitStandardTable', () {
      test('standalone standard table headers create empty tables', () {
        var builder = TomlAccessorBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('table')]),
        ));
        expect(
          builder.topLevel,
          equalsAccessor(TomlDocumentAccessor({'table': TomlTableAccessor()})),
        );
      });
      test('key/value pairs are relative to current standard table', () {
        var builder = TomlAccessorBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('table')]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        ));
        expect(
          builder.topLevel,
          equalsAccessor(TomlDocumentAccessor({
            'table': TomlTableAccessor({
              'key': TomlValueAccessor(TomlLiteralString('value')),
            })
          })),
        );
      });
      test('names of standard tables headers are absolute', () {
        var builder = TomlAccessorBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('table1')]),
        ));
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('table2')]),
        ));
        expect(
          builder.topLevel,
          equalsAccessor(TomlDocumentAccessor({
            'table1': TomlTableAccessor(),
            'table2': TomlTableAccessor(),
          })),
        );
      });
      test('standard table headers create parent table implicitly', () {
        var builder = TomlAccessorBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([
            TomlUnquotedKey('parent'),
            TomlUnquotedKey('table'),
          ]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        ));
        expect(
          builder.topLevel,
          equalsAccessor(TomlDocumentAccessor({
            'parent': TomlTableAccessor({
              'table': TomlTableAccessor({
                'key': TomlValueAccessor(TomlLiteralString('value')),
              })
            })
          })),
        );
      });
      test("explicit declarations don't overwrite implicitly created tables",
          () {
        var builder = TomlAccessorBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([
            TomlUnquotedKey('parent'),
            TomlUnquotedKey('table'),
          ]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key1')]),
          TomlInteger.dec(BigInt.from(1)),
        ));
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('parent')]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key2')]),
          TomlInteger.dec(BigInt.from(2)),
        ));
        expect(
          builder.topLevel,
          equalsAccessor(TomlDocumentAccessor({
            'parent': TomlTableAccessor({
              'table': TomlTableAccessor(
                  {'key1': TomlValueAccessor(TomlInteger.dec(BigInt.from(1)))}),
              'key2': TomlValueAccessor(TomlInteger.dec(BigInt.from(2)))
            })
          })),
        );
      });
      test("implicit declarations don't overwrite explicitly created tables",
          () {
        var builder = TomlAccessorBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('parent')]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key1')]),
          TomlInteger.dec(BigInt.from(1)),
        ));
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([
            TomlUnquotedKey('parent'),
            TomlUnquotedKey('table'),
          ]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key2')]),
          TomlInteger.dec(BigInt.from(2)),
        ));
        expect(
          builder.topLevel,
          equalsAccessor(TomlDocumentAccessor({
            'parent': TomlTableAccessor({
              'key1': TomlValueAccessor(TomlInteger.dec(BigInt.from(1))),
              'table': TomlTableAccessor(
                  {'key2': TomlValueAccessor(TomlInteger.dec(BigInt.from(2)))})
            })
          })),
        );
      });
      test('throws an exception if the table is defined already', () {
        var builder = TomlAccessorBuilder();
        builder.visitStandardTable(TomlStandardTable(TomlKey([
          TomlUnquotedKey('table'),
        ])));
        expect(
          () => builder.visitStandardTable(TomlStandardTable(TomlKey([
            TomlUnquotedKey('table'),
          ]))),
          throwsA(
            equals(
              TomlRedefinitionException(TomlAccessorKey.from(['table'])),
            ),
          ),
        );
      });
      test('throws an exception if a value with the same name exists', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        ));
        expect(
          () => builder.visitStandardTable(TomlStandardTable(TomlKey([
            TomlUnquotedKey('key'),
          ]))),
          throwsA(
            equals(
              TomlRedefinitionException(TomlAccessorKey.from(['key'])),
            ),
          ),
        );
      });
      test('throws an exception if a parent is not a table', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        ));
        expect(
          () => builder.visitStandardTable(TomlStandardTable(TomlKey([
            TomlUnquotedKey('key'),
            TomlUnquotedKey('child1'),
            TomlUnquotedKey('child2'),
          ]))),
          throwsA(equals(TomlTypeException(
            TomlAccessorKey.from(['key']),
            expectedType: TomlAccessorType.table,
            actualType: TomlAccessorType.value,
          ))),
        );
      });
      test('throws an exception if a parent is an inline table', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlInlineTable([]),
        ));
        expect(
          () => builder.visitStandardTable(TomlStandardTable(TomlKey([
            TomlUnquotedKey('key'),
            TomlUnquotedKey('child'),
          ]))),
          throwsA(
            equals(
              TomlRedefinitionException(TomlAccessorKey.from(['key'])),
            ),
          ),
        );
      });
      test('cannot redefine tables already defined using key/value pair', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('table'), TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        ));
        expect(
            () => builder.visitStandardTable(
                  TomlStandardTable(TomlKey([TomlUnquotedKey('table')])),
                ),
            throwsA(equals(TomlRedefinitionException(
              TomlAccessorKey.from(['table']),
            ))));
      });
      test('can create sub-tables within tables defined via dotted keys', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('parent'), TomlUnquotedKey('key1')]),
          TomlInteger.dec(BigInt.from(1)),
        ));
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('parent'), TomlUnquotedKey('child')]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key2')]),
          TomlInteger.dec(BigInt.from(2)),
        ));
        expect(
          builder.topLevel,
          equalsAccessor(TomlDocumentAccessor({
            'parent': TomlTableAccessor({
              'key1': TomlValueAccessor(TomlInteger.dec(BigInt.from(1))),
              'child': TomlTableAccessor(
                  {'key2': TomlValueAccessor(TomlInteger.dec(BigInt.from(2)))})
            })
          })),
        );
      });
      test(
        'marks previously implicitly created tables that are defined by '
        'dotted key/value pairs as explicitly defined',
        () {
          var builder = TomlAccessorBuilder();
          builder.visitStandardTable(TomlStandardTable(TomlKey([
            TomlUnquotedKey('parent'),
            TomlUnquotedKey('table'),
            TomlUnquotedKey('child'),
          ])));
          builder.visitStandardTable(
              TomlStandardTable(TomlKey([TomlUnquotedKey('parent')])));
          builder.visitKeyValuePair(TomlKeyValuePair(
            TomlKey([
              TomlUnquotedKey('table'),
              TomlUnquotedKey('key'),
            ]),
            TomlLiteralString('value'),
          ));
          expect(
            () => builder.visitStandardTable(
              TomlStandardTable(TomlKey([
                TomlUnquotedKey('parent'),
                TomlUnquotedKey('table'),
              ])),
            ),
            throwsA(equals(TomlRedefinitionException(
              TomlAccessorKey.from(['parent', 'table']),
            ))),
          );
        },
      );
      test('cannot open inline table', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('table')]),
          TomlInlineTable([]),
        ));
        expect(
          () => builder.visitStandardTable(TomlStandardTable(
            TomlKey([TomlUnquotedKey('table')]),
          )),
          throwsA(equals(
            TomlRedefinitionException(TomlAccessorKey.from(['table'])),
          )),
        );
      });
      test('cannot create child of inline table', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('table')]),
          TomlInlineTable([]),
        ));
        expect(
          () => builder.visitStandardTable(TomlStandardTable(
            TomlKey([
              TomlUnquotedKey('table'),
              TomlUnquotedKey('child'),
            ]),
          )),
          throwsA(equals(
            TomlRedefinitionException(TomlAccessorKey.from(['table'])),
          )),
        );
      });
      test('cannot redefine table defined with standard table header', () {
        var builder = TomlAccessorBuilder();
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([
            TomlUnquotedKey('a'),
            TomlUnquotedKey('b'),
          ]),
        ));
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([
            TomlUnquotedKey('c'),
            TomlUnquotedKey('key1'),
          ]),
          TomlInteger.dec(BigInt.from(1)),
        ));
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([
            TomlUnquotedKey('a'),
          ]),
        ));
        expect(
          () => builder.visitKeyValuePair(TomlKeyValuePair(
            TomlKey([
              TomlUnquotedKey('b'),
              TomlUnquotedKey('c'),
              TomlUnquotedKey('key2'),
            ]),
            TomlInteger.dec(BigInt.from(2)),
          )),
          throwsA(equals(
            TomlRedefinitionException(TomlAccessorKey.from(['a', 'b'])),
          )),
        );
      });
    });

    group('visitArrayTable', () {
      test(
        'standalone array table headers create one elementry arrays of tables',
        () {
          var builder = TomlAccessorBuilder();
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('array')]),
          ));
          expect(
            builder.topLevel,
            equalsAccessor(TomlDocumentAccessor({
              'array': TomlArrayAccessor([
                TomlTableAccessor(),
              ])
            })),
          );
        },
      );
      test(
        'additional array table headers add items to array of tables',
        () {
          var builder = TomlAccessorBuilder();
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('array')]),
          ));
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('array')]),
          ));
          expect(
            builder.topLevel,
            equalsAccessor(TomlDocumentAccessor({
              'array': TomlArrayAccessor([
                TomlTableAccessor(),
                TomlTableAccessor(),
              ])
            })),
          );
        },
      );
      test(
        'key/value-pairs are inserted into last item of array of tables',
        () {
          var builder = TomlAccessorBuilder();
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('array')]),
          ));
          builder.visitKeyValuePair(TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key1')]),
            TomlInteger.dec(BigInt.from(1)),
          ));
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('array')]),
          ));
          builder.visitKeyValuePair(TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key2')]),
            TomlInteger.dec(BigInt.from(2)),
          ));
          expect(
            builder.topLevel,
            equalsAccessor(TomlDocumentAccessor({
              'array': TomlArrayAccessor([
                TomlTableAccessor({
                  'key1': TomlValueAccessor(TomlInteger.dec(BigInt.from(1)))
                }),
                TomlTableAccessor({
                  'key2': TomlValueAccessor(TomlInteger.dec(BigInt.from(2)))
                })
              ])
            })),
          );
        },
      );
      test(
        'throws an exception if there is a standard table with the same name',
        () {
          var builder = TomlAccessorBuilder();
          builder.visitStandardTable(TomlStandardTable(
            TomlKey([TomlUnquotedKey('foo')]),
          ));
          expect(
            () => builder.visitArrayTable(TomlArrayTable(
              TomlKey([TomlUnquotedKey('foo')]),
            )),
            throwsA(equals(TomlRedefinitionException(
              TomlAccessorKey.from(['foo']),
            ))),
          );
        },
      );
      test('throws an exception if a parent is not a table', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        ));
        expect(
          () => builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('key'), TomlUnquotedKey('array')]),
          )),
          throwsA(equals(TomlTypeException(
            TomlAccessorKey.from(['key']),
            expectedType: TomlAccessorType.table,
            actualType: TomlAccessorType.value,
          ))),
        );
      });
      test('can add child table to array of table entry', () {
        var builder = TomlAccessorBuilder();
        builder.visitArrayTable(TomlArrayTable(
          TomlKey([TomlUnquotedKey('array')]),
        ));
        builder.visitStandardTable(TomlStandardTable(
          TomlKey([TomlUnquotedKey('array'), TomlUnquotedKey('table')]),
        ));
        expect(
          builder.topLevel,
          equalsAccessor(TomlDocumentAccessor({
            'array': TomlArrayAccessor([
              TomlTableAccessor({
                'table': TomlTableAccessor(),
              })
            ])
          })),
        );
      });
      test('cannot insert into static array', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('array')]),
          TomlArray([]),
        ));
        expect(
          () => builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('array')]),
          )),
          throwsA(equals(
            TomlRedefinitionException(TomlAccessorKey.from(['array'])),
          )),
        );
      });
      test('cannot create child of inline table', () {
        var builder = TomlAccessorBuilder();
        builder.visitKeyValuePair(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('table')]),
          TomlInlineTable([]),
        ));
        expect(
          () => builder.visitArrayTable(TomlArrayTable(
            TomlKey([
              TomlUnquotedKey('table'),
              TomlUnquotedKey('array'),
            ]),
          )),
          throwsA(equals(
            TomlRedefinitionException(TomlAccessorKey.from(['table'])),
          )),
        );
      });
      test(
        'cannot add key to last entry of array of tables using dotted keys',
        () {
          var builder = TomlAccessorBuilder();
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('table'), TomlUnquotedKey('array')]),
          ));
          builder.visitStandardTable(TomlStandardTable(
            TomlKey([TomlUnquotedKey('table')]),
          ));
          expect(
            () => builder.visitKeyValuePair(TomlKeyValuePair(
              TomlKey([
                TomlUnquotedKey('array'),
                TomlUnquotedKey('key'),
              ]),
              TomlLiteralString('value'),
            )),
            throwsA(equals(TomlTypeException(
              TomlAccessorKey.from(['table', 'array']),
              expectedType: TomlAccessorType.table,
              actualType: TomlAccessorType.array,
            ))),
          );
        },
      );
      test(
        'cannot add sub-table to last entry of array of tables using '
        'dotted keys',
        () {
          var builder = TomlAccessorBuilder();
          builder.visitArrayTable(TomlArrayTable(
            TomlKey([TomlUnquotedKey('table'), TomlUnquotedKey('array')]),
          ));
          builder.visitStandardTable(TomlStandardTable(
            TomlKey([TomlUnquotedKey('table')]),
          ));
          expect(
            () => builder.visitKeyValuePair(TomlKeyValuePair(
              TomlKey([
                TomlUnquotedKey('array'),
                TomlUnquotedKey('child'),
                TomlUnquotedKey('key'),
              ]),
              TomlLiteralString('value'),
            )),
            throwsA(equals(TomlTypeException(
              TomlAccessorKey.from(['table', 'array']),
              expectedType: TomlAccessorType.table,
              actualType: TomlAccessorType.array,
            ))),
          );
        },
      );
    });
  });
}
