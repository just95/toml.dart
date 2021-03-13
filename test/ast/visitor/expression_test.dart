library toml.test.ast.visitor.expression_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

/// A visitor that returns the name of its method that visited the node that
/// acceted the visitor.
class TomlExpressionTestVisitor extends TomlExpressionVisitor<String> {
  @override
  String visitArrayTable(_) => 'visitArrayTable';

  @override
  String visitKeyValuePair(_) => 'visitKeyValuePair';

  @override
  String visitStandardTable(_) => 'visitStandardTable';
}

void main() {
  group('TomlSimpleKeyVisitor', () {
    final visitor = TomlExpressionTestVisitor();
    test('visitKeyValuePair', () {
      expect(
        visitor.visitExpression(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        )),
        equals('visitKeyValuePair'),
      );
    });
    test('visitArrayTable', () {
      expect(
        visitor.visitExpression(TomlArrayTable(
          TomlKey([TomlUnquotedKey('key')]),
        )),
        equals('visitArrayTable'),
      );
    });
    test('visitStandardTable', () {
      expect(
        visitor.visitExpression(TomlStandardTable(
          TomlKey([TomlUnquotedKey('key')]),
        )),
        equals('visitStandardTable'),
      );
    });
  });
}
