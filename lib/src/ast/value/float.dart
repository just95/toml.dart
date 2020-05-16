// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.float;

import 'package:toml/src/ast/value.dart';

/// AST node that represents a TOML floating point number.
///
///     float = float-int-part ( exp / frac [ exp ] )
///     float =/ special-float
///
///     float-int-part = dec-int
///     frac = decimal-point zero-prefixable-int
///     decimal-point = %x2E               ; .
///     zero-prefixable-int = DIGIT *( DIGIT / underscore DIGIT )
///
///     exp = "e" float-exp-part
///     float-exp-part = [ minus / plus ] zero-prefixable-int
///
///     special-float = [ minus / plus ] ( inf / nan )
///     inf = %x69.6e.66  ; inf
///     nan = %x6e.61.6e  ; nan
///
/// TODO The special values `inf` and `nan` were added in TOML 0.5.0 and are
/// not supported yet.
class TomlFloat extends TomlValue<double> {
  @override
  final double value;

  /// Creates a new floating point value.
  TomlFloat(this.value);

  @override
  TomlType get type => TomlType.float;
}
