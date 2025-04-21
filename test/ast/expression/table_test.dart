import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

void main() {
  group('TomlTable', () {
    group('hashCode', () {
      test('equal standard tables have the same hash code', () {
        var d1 = TomlStandardTable(TomlKey([TomlUnquotedKey('table')]));
        var d2 = TomlStandardTable(TomlKey([TomlUnquotedKey('table')]));
        expect(d1.hashCode, equals(d2.hashCode));
      });
      test('equal array tables have the same hash code', () {
        var d1 = TomlArrayTable(TomlKey([TomlUnquotedKey('table')]));
        var d2 = TomlArrayTable(TomlKey([TomlUnquotedKey('table')]));
        expect(d1.hashCode, equals(d2.hashCode));
      });
      test('standard tables with different key have different hash code', () {
        var d1 = TomlStandardTable(TomlKey([TomlUnquotedKey('table1')]));
        var d2 = TomlStandardTable(TomlKey([TomlUnquotedKey('table2')]));
        expect(d1.hashCode, isNot(equals(d2.hashCode)));
      });
      test('array tables with different key have different hash code', () {
        var d1 = TomlArrayTable(TomlKey([TomlUnquotedKey('table1')]));
        var d2 = TomlArrayTable(TomlKey([TomlUnquotedKey('table2')]));
        expect(d1.hashCode, isNot(equals(d2.hashCode)));
      });
      test(
        'different kinds of tables with the same key have different hash code',
        () {
          var d1 = TomlStandardTable(TomlKey([TomlUnquotedKey('table')]));
          var d2 = TomlArrayTable(TomlKey([TomlUnquotedKey('table')]));
          expect(d1.hashCode, isNot(equals(d2.hashCode)));
        },
      );
    });
  });
}
