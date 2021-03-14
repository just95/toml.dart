library toml.test.ast.visitor.value.string_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

/// A visitor that returns the name of its method that visited the node that
/// acceted the visitor.
class TomlStringTestVisitor with TomlStringVisitorMixin<String> {
  @override
  String visitBasicString(_) => 'visitBasicString';

  @override
  String visitLiteralString(_) => 'visitLiteralString';

  @override
  String visitMultilineBasicString(_) => 'visitMultilineBasicString';

  @override
  String visitMultilineLiteralString(_) => 'visitMultilineLiteralString';
}

void main() {
  group('TomlSimpleKeyVisitor', () {
    final visitor = TomlStringTestVisitor();
    test('visitBasicString', () {
      expect(
        visitor.visitString(TomlBasicString('test')),
        equals('visitBasicString'),
      );
    });
    test('visitLiteralString', () {
      expect(
        visitor.visitString(TomlLiteralString('test')),
        equals('visitLiteralString'),
      );
    });
    test('visitMultilineBasicString', () {
      expect(
        visitor.visitString(TomlMultilineBasicString('test')),
        equals('visitMultilineBasicString'),
      );
    });
    test('visitMultilineLiteralString', () {
      expect(
        visitor.visitString(TomlMultilineLiteralString('test')),
        equals('visitMultilineLiteralString'),
      );
    });
  });
}
