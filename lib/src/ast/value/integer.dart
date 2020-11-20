// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.integer;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/value.dart';
import 'package:toml/src/ast/value/visitor.dart';

/// AST node that represents a TOML integer.
///
///     integer = dec-int / hex-int / oct-int / bin-int
///
///     digit0-7 = %x30-37                 ; 0-7
///     digit0-1 = %x30-31                 ; 0-1
///
///     hex-prefix = %x30.78               ; 0x
///     oct-prefix = %x30.6f               ; 0o
///     bin-prefix = %x30.62               ; 0b
///
///     hex-int = hex-prefix HEXDIG *( HEXDIG / underscore HEXDIG )
///     oct-int = oct-prefix digit0-7 *( digit0-7 / underscore digit0-7 )
///     bin-int = bin-prefix digit0-1 *( digit0-1 / underscore digit0-1 )
///
/// TODO hexadecimal, octal and binary notation was added in TOML 0.5.0 and
/// is not supported yet.
class TomlInteger extends TomlValue<int> {
  /// Parser for a TOML interger value.
  static final Parser<TomlInteger> parser = decParser;

  /// Parser for a decimal TOML interger value..
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
    return decimal
        .flatten()
        .map((str) => TomlInteger(int.parse(str.replaceAll('_', ''))));
  })();

  @override
  final int value;

  /// Creates a new integer value.
  TomlInteger(this.value);

  @override
  TomlType get type => TomlType.integer;

  @override
  T accept<T>(TomlValueVisitor<T> visitor) => visitor.visitInteger(this);
}
