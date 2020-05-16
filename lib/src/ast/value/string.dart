// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.string;

import 'package:toml/src/ast/value.dart';

/// AST node that represents a TOML string.
///
///     string = ml-basic-string
///            / basic-string
///            / ml-literal-string
///            / literal-string
///
/// ### Basic String
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
///
/// ### Multiline Basic String
///
///     ml-basic-string =
///         ml-basic-string-delim ml-basic-body ml-basic-string-delim
///     ml-basic-string-delim = 3quotation-mark
///     ml-basic-body = *mlb-content *( mlb-quotes 1*mlb-content ) [ mlb-quotes ]
///
///     mlb-content = mlb-char / newline / mlb-escaped-nl
///     mlb-char = mlb-unescaped / escaped
///     mlb-quotes = 1*2quotation-mark
///     mlb-unescaped = wschar / %x21 / %x23-5B / %x5D-7E / non-ascii
///     mlb-escaped-nl = escape ws newline *( wschar / newline )
///
/// ### Literal String
///
///     literal-string = apostrophe *literal-char apostrophe
///
///     apostrophe = %x27 ; ' apostrophe
///
///     literal-char = %x09 / %x20-26 / %x28-7E / non-ascii
///
/// ### Multiline Literal String
///
///     ml-literal-string =
///         ml-literal-string-delim ml-literal-body ml-literal-string-delim
///     ml-literal-string-delim = 3apostrophe
///     ml-literal-body =
///         *mll-content *( mll-quotes 1*mll-content ) [ mll-quotes ]
///
///     mll-content = mll-char / newline
///     mll-char = %x09 / %x20-26 / %x28-7E / non-ascii
///     mll-quotes = 1*2apostrophe

class TomlString extends TomlValue<String> {
  @override
  final String value;

  /// Creates a new string value.
  TomlString(this.value);

  @override
  TomlType get type => TomlType.string;
}
