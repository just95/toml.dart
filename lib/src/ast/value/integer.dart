library toml.src.ast.value.integer;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/ranges.dart';
import 'package:toml/src/util/parser.dart';
import 'package:quiver/core.dart';

import '../value.dart';
import '../visitor/value.dart';

/// A TOML integer can be formatted with one of four bases.
class TomlIntegerFormat {
  /// Format of a binary (base `2`) integer.
  ///
  ///     bin-prefix = %x30.62               ; 0b
  static const TomlIntegerFormat bin =
      TomlIntegerFormat._(base: 2, prefix: '0b');

  /// Format of an octal (base `8`) integer.
  ///
  ///     oct-prefix = %x30.6f               ; 0o
  static const TomlIntegerFormat oct =
      TomlIntegerFormat._(base: 8, prefix: '0o');

  /// Format of a decimal (base `10`) integer.
  static const TomlIntegerFormat dec =
      TomlIntegerFormat._(base: 10, prefix: '');

  /// Format of a hexadecimal (base `16`) integer.
  ///
  ///     hex-prefix = %x30.78               ; 0x
  static const TomlIntegerFormat hex =
      TomlIntegerFormat._(base: 16, prefix: '0x');

  /// The base of an integer of this format.
  final int base;

  /// Prefix for integers of this format.
  final String prefix;

  /// Creates a new format for integers of the given base.
  const TomlIntegerFormat._({required this.base, required this.prefix});
}

/// AST node that represents a TOML integer.
///
///     integer = dec-int / hex-int / oct-int / bin-int
class TomlInteger extends TomlValue {
  /// Parser for a TOML interger value.
  ///
  /// Decimal integers have to be parsed last such that the zero in the
  /// prefixes of non-decimal numbers is not consumed by the [decParser].
  static final Parser<TomlInteger> parser =
      ChoiceParser([binParser, octParser, hexParser, decParser]);

  /// Parser for a binary TOML integer value.
  ///
  ///     bin-int = bin-prefix digit0-1 *( digit0-1 / underscore digit0-1 )
  static final Parser<TomlInteger> binParser = TomlInteger._makeParser(
    format: TomlIntegerFormat.bin,
    digitParser: tomlBinDigit(),
    message: 'Binary integer expected',
  ).map((n) => TomlInteger.bin(n));

  /// Parser for a binary TOML integer value.
  ///
  ///     oct-int = oct-prefix digit0-7 *( digit0-7 / underscore digit0-7 )
  static final Parser<TomlInteger> octParser = TomlInteger._makeParser(
    format: TomlIntegerFormat.oct,
    digitParser: tomlOctDigit(),
    message: 'Octal integer expected',
  ).map((n) => TomlInteger.oct(n));

  /// Parser for a decimal TOML interger value.
  ///
  ///     dec-int = [ minus / plus ] unsigned-dec-int
  ///     minus = %x2D                       ; -
  ///     plus = %x2B                        ; +
  ///
  ///     unsigned-dec-int = DIGIT / digit1-9 1*( DIGIT / underscore DIGIT )
  ///     underscore = %x5F                  ; _
  ///     digit1-9 = %x31-39                 ; 1-9
  ///     DIGIT = %x30-39 ; 0-9
  static final Parser<TomlInteger> decParser = (() {
    var digits = digit().plus().separatedBy(char('_'));
    var decimal = anyOf('+-').optional() & (char('0') | digits);
    return decimal.flatten('Decimal integer expected').map(
          (str) => TomlInteger.dec(BigInt.parse(
            str.replaceAll('_', ''),
            radix: TomlIntegerFormat.dec.base,
          )),
        );
  })();

  /// Parser for a binary TOML integer value.
  ///
  ///     hex-int = hex-prefix HEXDIG *( HEXDIG / underscore HEXDIG )
  static final Parser<TomlInteger> hexParser = TomlInteger._makeParser(
          format: TomlIntegerFormat.hex,
          digitParser: tomlHexDigit(),
          message: 'Hexadecimal integer expected')
      .map((n) => TomlInteger.hex(n));

  /// Creates a parser for an decimal integer parser.
  ///
  /// All production rules for integers with a base other than `10` have
  /// the following form
  ///
  ///     x-int = x-prefix x-digit *( x-digit / underscore x-digit )
  ///
  ///  where `x` in `x-int` and `x-prefix` is either `bin`, `oct` or `hex`
  ///  and `x-digit` is a non-terminal that matches a single digit of an
  ///  integer of base `x`.
  ///
  ///  `x-prefix` is controlled by [prefix] and the provided [digitParser] is
  ///  used in place of `x-digit`. The parsed number is converted to a [int]
  ///  using [int.parse] with `radix` set to the [base] of the integer.
  static Parser<BigInt> _makeParser({
    required TomlIntegerFormat format,
    required Parser digitParser,
    required String message,
  }) {
    var digitsParser = digitParser.plus().separatedBy(char('_'));
    var integerParser = digitsParser.flatten(message).map(
          (str) => BigInt.parse(
            str.replaceAll('_', ''),
            radix: format.base,
          ),
        );
    return string(format.prefix).before(integerParser).orFailure(message);
  }

  /// The number represented by this node.
  final BigInt value;

  /// The format of this integer.
  final TomlIntegerFormat format;

  /// Creates a new binary integer value.
  ///
  /// The [value] must be non-negative.
  TomlInteger.bin(this.value) : format = TomlIntegerFormat.bin {
    if (value.isNegative) {
      throw ArgumentError(
        'Binary TOML integer must be non-negative, got $value.',
      );
    }
  }

  /// Creates a new octal integer value.
  ///
  /// The [value] must be non-negative
  TomlInteger.oct(this.value) : format = TomlIntegerFormat.oct {
    if (value.isNegative) {
      throw ArgumentError(
        'Octal TOML integer must be non-negative, got $value.',
      );
    }
  }

  /// Creates a new decimal integer value.
  TomlInteger.dec(this.value) : format = TomlIntegerFormat.dec;

  /// Creates a new hexadecimal integer value.
  ///
  /// The [value] must be non-negative
  TomlInteger.hex(this.value) : format = TomlIntegerFormat.hex {
    if (value.isNegative) {
      throw ArgumentError(
        'Hexadecimal TOML integer must be non-negative, got $value.',
      );
    }
  }

  @override
  TomlType get type => TomlType.integer;

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitInteger(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlInteger && value == other.value && format == other.format;

  @override
  int get hashCode => hash3(type, value, format);
}
