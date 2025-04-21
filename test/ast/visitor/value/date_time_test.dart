import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

/// A visitor that returns the name of its method that visited the node that
/// accepted the visitor.
class TomlDateTimeStringVisitor with TomlDateTimeVisitorMixin<String> {
  @override
  String visitLocalDate(_) => 'visitLocalDate';

  @override
  String visitLocalDateTime(_) => 'visitLocalDateTime';

  @override
  String visitLocalTime(_) => 'visitLocalTime';

  @override
  String visitOffsetDateTime(_) => 'visitOffsetDateTime';
}

void main() {
  group('TomlDateTimeVisitor', () {
    final visitor = TomlDateTimeStringVisitor();
    test('visitOffsetDateTime', () {
      expect(
        visitor.visitDateTime(
          TomlOffsetDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(17, 53, 0),
            TomlTimeZoneOffset.utc(),
          ),
        ),
        equals('visitOffsetDateTime'),
      );
    });
    test('visitLocalDateTime', () {
      expect(
        visitor.visitDateTime(
          TomlLocalDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(17, 53, 0),
          ),
        ),
        equals('visitLocalDateTime'),
      );
    });
    test('visitLocalDate', () {
      expect(
        visitor.visitDateTime(TomlLocalDate(TomlFullDate(1989, 11, 9))),
        equals('visitLocalDate'),
      );
    });
    test('visitLocalTime', () {
      expect(
        visitor.visitDateTime(TomlLocalTime(TomlPartialTime(17, 53, 0))),
        equals('visitLocalTime'),
      );
    });
  });
}
