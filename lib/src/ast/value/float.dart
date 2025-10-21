import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../value.dart';
import '../visitor/value.dart';

/// AST node that represents a TOML floating point number.
///
///     float = float-int-part ( exp / frac [ exp ] )
///     float =/ special-float
@immutable
class TomlFloat extends TomlValue {
  /// Parser for a TOML floating point value.
  static final Parser<TomlFloat> parser = ChoiceParser([
    finalFloatParser,
    specialFloatParser,
  ], failureJoiner: selectFarthest);

  /// Parser for a regular TOML floating point value.
  ///
  ///     float-int-part = dec-int
  ///     frac = decimal-point zero-prefixable-int
  ///     decimal-point = %x2E               ; .
  ///     zero-prefixable-int = DIGIT *( DIGIT / underscore DIGIT )
  ///
  ///     exp = "e" float-exp-part
  ///     float-exp-part = [ minus / plus ] zero-prefixable-int
  static final Parser<TomlFloat> finalFloatParser =
      (() {
        var floatIntPart = ChoiceParser([
          char('0'),
          digit().plus().plusSeparated(char('_')),
        ]);
        var zeroPrefixableInt = digit().plus().plusSeparated(char('_'));
        var decimal = anyOf('+-').optional() & floatIntPart;
        var exp = anyOf('eE') & anyOf('+-').optional() & zeroPrefixableInt;
        var frac = char('.') & zeroPrefixableInt;
        var float = decimal & ChoiceParser([exp, frac & exp.optional()]);
        return float
            .flatten(message: 'Floating point number expected')
            .map((str) => TomlFloat(double.parse(str.replaceAll('_', ''))));
      })();

  /// Parser for a special TOML floating point value.
  ///
  ///     special-float = [ minus / plus ] ( inf / nan )
  ///     inf = %x69.6e.66  ; inf
  ///     nan = %x6e.61.6e  ; nan
  static final Parser<TomlFloat> specialFloatParser =
      (() {
        var plus = char('+').map((_) => 1.0);
        var minus = char('-').map((_) => -1.0);
        var sign = ChoiceParser([plus, minus]).optionalWith(1.0);
        var inf = string('inf').map((_) => double.infinity);
        var nan = string('nan').map((_) => double.nan);
        return (
          sign,
          ChoiceParser([inf, nan]),
        ).toSequenceParser().map((pair) => TomlFloat(pair.$1 * pair.$2));
      })();

  /// The number represented by this node.
  final double value;

  /// Creates a new floating point value.
  TomlFloat(this.value);

  @override
  TomlType get type => TomlType.float;

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitFloat(this);

  @override
  bool operator ==(Object other) =>
      other is TomlFloat &&
      (value == other.value || value.isNaN && other.value.isNaN);

  @override
  int get hashCode => Object.hash(type, value);
}
