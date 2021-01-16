@TestOn('js')
library toml.test.encoder.pretty_printer_test.js_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('JS', () {
    group('TomlPrettyPrinter', () {
      group('visitValue', () {
        group('visitDateTime', () {
          test(
            'pretty prints UTC date-time with milli- and microseconds with '
            'millisecond precision only',
            () {
              var prettyPrinter = TomlPrettyPrinter();
              prettyPrinter.visitDateTime(TomlDateTime(
                DateTime.utc(1969, 7, 20, 20, 17, 0, 123, 456),
              ));
              expect(
                  prettyPrinter.toString(), equals('1969-07-20T20:17:00.123Z'));
            },
          );
          test(
            'pretty prints UTC date-time with microseconds with second '
            'precision only',
            () {
              var prettyPrinter = TomlPrettyPrinter();
              prettyPrinter.visitDateTime(TomlDateTime(
                DateTime.utc(1969, 7, 20, 20, 17, 0, 0, 456),
              ));
              expect(prettyPrinter.toString(), equals('1969-07-20T20:17:00Z'));
            },
          );
        });
      });
    });
  });
}
