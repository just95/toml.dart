import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'package:toml/src/util/parser/late.dart';

void main() {
  group('LateParser', () {
    test('can build circular parser', () {
      var parser = LateParser.fix((parser) => letter() & parser.optional());
      var result = parser.parse('abc');
      expect(result, isA<Success>());
      expect(
        result.value,
        equals([
          'a',
          [
            'b',
            ['c', null],
          ],
        ]),
      );
    });
    test('can use circular parser in fast mode', () {
      var parser = LateParser.fix((parser) => letter() & parser.optional());
      var result = parser.fastParseOn('abc', 0);
      expect(result, equals(3));
    });
    test('copy shares lazy computation of delegate with original', () {
      var counter = 0;
      var delegate = letter();
      var parser = LateParser(() {
        counter++;
        return delegate;
      });
      var copy = parser.copy();
      expect(parser.children, equals(copy.children));
      expect(counter, equals(1));
    });
    test('has the delegate as its only child', () {
      var delegate = letter();
      var parser = LateParser(() => delegate);
      expect(parser.children, equals([delegate]));
    });
    test('can replace delegate', () {
      var delegate = letter();
      var replacement = digit();
      var parser = LateParser(() => delegate);
      parser.replace(delegate, replacement);
      expect(parser.children, equals([replacement]));
    });
  });
}
