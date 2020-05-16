// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.integer;

import 'package:toml/src/ast/value.dart';

/// AST node that represents a TOML integer.
///
///     integer = dec-int / hex-int / oct-int / bin-int
///
///     minus = %x2D                       ; -
///     plus = %x2B                        ; +
///     underscore = %x5F                  ; _
///     digit1-9 = %x31-39                 ; 1-9
///     digit0-7 = %x30-37                 ; 0-7
///     digit0-1 = %x30-31                 ; 0-1
///
///     hex-prefix = %x30.78               ; 0x
///     oct-prefix = %x30.6f               ; 0o
///     bin-prefix = %x30.62               ; 0b
///
///     dec-int = [ minus / plus ] unsigned-dec-int
///     unsigned-dec-int = DIGIT / digit1-9 1*( DIGIT / underscore DIGIT )
///
///     hex-int = hex-prefix HEXDIG *( HEXDIG / underscore HEXDIG )
///     oct-int = oct-prefix digit0-7 *( digit0-7 / underscore digit0-7 )
///     bin-int = bin-prefix digit0-1 *( digit0-1 / underscore digit0-1 )
///
/// TODO hexadecimal, octal and binary notation was added in TOML 0.5.0 and
/// is not supported yet.
class TomlInteger extends TomlValue<int> {
  @override
  final int value;

  /// Creates a new integer value.
  TomlInteger(this.value);

  @override
  TomlType get type => TomlType.integer;
}
