library toml.src.ast.value.float;

import 'package:petitparser/petitparser.dart';
import 'package:quiver/core.dart';
import 'package:toml/src/util/iterable/where_not_null.dart';

import '../value.dart';
import '../visitor/value.dart';

/// AST node that represents a TOML floating point number.
///
///     float = float-int-part ( exp / frac [ exp ] )
///     float =/ special-float
class TomlFloat extends TomlValue {
  /// Parser for a TOML floating point value.
  static final Parser<TomlFloat> parser =
      (finalFloatParser | specialFloatParser).cast<TomlFloat>();

  /// Parser for a regular TOML floating point value.
  ///
  ///     float-int-part = dec-int
  ///     frac = decimal-point zero-prefixable-int
  ///     decimal-point = %x2E               ; .
  ///     zero-prefixable-int = DIGIT *( DIGIT / underscore DIGIT )
  ///
  ///     exp = "e" float-exp-part
  ///     float-exp-part = [ minus / plus ] zero-prefixable-int
  static final Parser<TomlFloat> finalFloatParser = (() {
    var floatIntPart = char('0') | digit().plus().separatedBy(char('_'));
    var zeroPrefixableInt = digit().plus().separatedBy(char('_'));
    var decimal = anyOf('+-').optional() & floatIntPart;
    var exp = anyOf('eE') & anyOf('+-').optional() & zeroPrefixableInt;
    var frac = char('.') & zeroPrefixableInt;
    var float = decimal & (exp | frac & exp.optional());
    return float
        .flatten()
        .map((str) => TomlFloat(double.parse(str.replaceAll('_', ''))));
  })();

  /// Parser for a special TOML floating point value.
  ///
  ///     special-float = [ minus / plus ] ( inf / nan )
  ///     inf = %x69.6e.66  ; inf
  ///     nan = %x6e.61.6e  ; nan
  static final Parser<TomlFloat> specialFloatParser = (() {
    var plus = char('+').map((_) => 1.0);
    var minus = char('-').map((_) => -1.0);
    var sign = (plus | minus).optional();
    var inf = string('inf').map((_) => double.infinity);
    var nan = string('nan').map((_) => double.nan);
    return (sign & (inf | nan)).castList<double>().map((pair) =>
        TomlFloat(pair.whereNotNull().reduce((sign, value) => sign * value)));
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
  bool operator ==(dynamic other) => other is TomlFloat && value == other.value;

  @override
  int get hashCode => hash2(type, value);
}
