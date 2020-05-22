// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.string.basic;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/value/string.dart';

/// AST node that represents basic TOML strings.
///
///     basic-string = quotation-mark *basic-char quotation-mark
///
///     quotation-mark = %x22            ; "
///
///     basic-char = basic-unescaped / escaped
///     basic-unescaped = wschar / %x21 / %x23-5B / %x5D-7E / non-ascii
///     escaped = escape escape-seq-char
///
///     escape = %x5C                   ; \
///     escape-seq-char =  %x22         ; "    quotation mark  U+0022
///     escape-seq-char =/ %x5C         ; \    reverse solidus U+005C
///     escape-seq-char =/ %x62         ; b    backspace       U+0008
///     escape-seq-char =/ %x66         ; f    form feed       U+000C
///     escape-seq-char =/ %x6E         ; n    line feed       U+000A
///     escape-seq-char =/ %x72         ; r    carriage return U+000D
///     escape-seq-char =/ %x74         ; t    tab             U+0009
///     escape-seq-char =/ %x75 4HEXDIG ; uXXXX                U+XXXX
///     escape-seq-char =/ %x55 8HEXDIG ; UXXXXXXXX            U+XXXXXXXX
abstract class TomlBasicString extends TomlString {
  /// Parser for a TOML string value.
  static final Parser<TomlBasicString> parser = failure('not yet implemented');
}
