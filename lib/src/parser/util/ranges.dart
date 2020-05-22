// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.parser.ranges;

import 'package:petitparser/petitparser.dart';

/// Parser for non-EOL characters that are allowed in TOML comments.
///     non-eol = %x09 / %x20-7F / non-ascii
final Parser tomlNonEol = char(0x09) | range(0x20, 0x7F) | tomlNonAscii;

/// Parser for non-ASCII characters that are allowed in TOML comments and
/// literal strings.
///
///     non-ascii = %x80-D7FF / %xE000-10FFFF
///
/// The subrange `%x10000-10FFFF` is represented as surrogate pairs by Dart.
/// Since `petitparser` can only work with 16-Bit code units, we have to
/// parse the surrogate pairs manually.
final Parser tomlNonAscii =
    range(0x80, 0xD7FF) | range(0xE000, 0xFFFF) | tomlSurrogatePair;

/// Parser for a UTF-16 surrogate pair.
///
/// Returns the combined Unicode code-point of the surrogate pair.
final Parser<int> tomlSurrogatePair = (tomlHighSurrogate & tomlLowSurrogate)
    .flatten()
    .map((str) => str.runes.first);

/// Parser for high surrogates (`%xD800-DBFF`).
final Parser tomlHighSurrogate = range(0xD800, 0xDBFF);

/// Parser for low surrogates (`%xDC00-DFFF`).
final Parser tomlLowSurrogate = range(0xDC00, 0xDFFF);
