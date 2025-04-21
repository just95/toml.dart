import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

void main() {
  group('TomlDocument', () {
    group('parse and toString', () {
      test('parsing stringified document yields original document', () {
        var document = TomlDocument([
          TomlStandardTable(TomlKey([TomlUnquotedKey('table')])),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key')]),
            TomlLiteralString('value'),
          ),
        ]);
        expect(TomlDocument.parse(document.toString()), equals(document));
      });
    });
    group('fromMap and toMap', () {
      test('building a document from its map yields original document', () {
        var document = TomlDocument([
          TomlStandardTable(TomlKey([TomlUnquotedKey('table')])),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key')]),
            TomlLiteralString('value'),
          ),
        ]);
        expect(TomlDocument.fromMap(document.toMap()), equals(document));
      });
    });
    group('hashCode', () {
      test('equal documents have the same hash code', () {
        var d1 = TomlDocument([
          TomlStandardTable(TomlKey([TomlUnquotedKey('table')])),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key')]),
            TomlLiteralString('value'),
          ),
        ]);
        var d2 = TomlDocument([
          TomlStandardTable(TomlKey([TomlUnquotedKey('table')])),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key')]),
            TomlLiteralString('value'),
          ),
        ]);
        expect(d1.hashCode, equals(d2.hashCode));
      });
      test('slightly different documents have different hash codes', () {
        var d1 = TomlDocument([
          TomlStandardTable(TomlKey([TomlUnquotedKey('table')])),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key1')]),
            TomlLiteralString('value'),
          ),
        ]);
        var d2 = TomlDocument([
          TomlStandardTable(TomlKey([TomlUnquotedKey('table')])),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key2')]),
            TomlLiteralString('value'),
          ),
        ]);
        expect(d1.hashCode, isNot(equals(d2.hashCode)));
      });
    });
  });
}
