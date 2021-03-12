library toml.test.ast.document_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

void main() {
  group('TomlDocument', () {
    test('parsing stringified document yields original document', () {
      var document = TomlDocument([
        TomlStandardTable(TomlKey([TomlUnquotedKey('table')])),
        TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        )
      ]);
      expect(TomlDocument.parse(document.toString()), equals(document));
    });
    test('building a docment from its map yields original document', () {
      var document = TomlDocument([
        TomlStandardTable(TomlKey([TomlUnquotedKey('table')])),
        TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        )
      ]);
      expect(TomlDocument.fromMap(document.toMap()), equals(document));
    });
  });
}
