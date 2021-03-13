library toml.test.ast.visitor.key_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

/// A visitor that returns the name of its method that visited the node that
/// acceted the visitor.
class TomlSimpleKeyTestVisitor extends TomlSimpleKeyVisitor<String> {
  @override
  String visitQuotedKey(_) => 'visitQuotedKey';

  @override
  String visitUnquotedKey(_) => 'visitUnquotedKey';
}

void main() {
  group('TomlSimpleKeyVisitor', () {
    final visitor = TomlSimpleKeyTestVisitor();
    test('visitQuotedKey', () {
      expect(
        visitor.visitSimpleKey(TomlQuotedKey(TomlLiteralString('key'))),
        equals('visitQuotedKey'),
      );
    });
    test('visitUnquotedKey', () {
      expect(
        visitor.visitSimpleKey(TomlUnquotedKey('key')),
        equals('visitUnquotedKey'),
      );
    });
  });
}
