// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.datetime;

import 'package:toml/src/ast/value.dart';

/// AST node that represents a TOML date-time value.
///
///     date-time      = offset-date-time / local-date-time / local-date / local-time
///
///     date-fullyear  = 4DIGIT
///     date-month     = 2DIGIT  ; 01-12
///     date-mday      = 2DIGIT  ; 01-28, 01-29, 01-30, 01-31 based on month/year
///     time-delim     = "T" / %x20 ; T, t, or space
///     time-hour      = 2DIGIT  ; 00-23
///     time-minute    = 2DIGIT  ; 00-59
///     time-second    = 2DIGIT  ; 00-58, 00-59, 00-60 based on leap second rules
///     time-secfrac   = "." 1*DIGIT
///     time-numoffset = ( "+" / "-" ) time-hour ":" time-minute
///     time-offset    = "Z" / time-numoffset
///
///     partial-time   = time-hour ":" time-minute ":" time-second [ time-secfrac ]
///     full-date      = date-fullyear "-" date-month "-" date-mday
///     full-time      = partial-time time-offset
///
/// ### Offset Date-Time
///
///     offset-date-time = full-date time-delim full-time
///
/// ### Local Date-Time
///
///     local-date-time = full-date time-delim partial-time
///
/// ### Local Date
///
///     local-date = full-date
///
/// ### Local Time
///
///     local-time = partial-time
///
/// TODO the distinction between the four different types of date and time
/// objects was added in 0.5.0 and is not supported yet.
class TomlDateTime extends TomlValue<DateTime> {
  @override
  final DateTime value;

  /// Creates a new date-time value.
  TomlDateTime(this.value);

  @override
  TomlType get type => TomlType.datetime;
}
