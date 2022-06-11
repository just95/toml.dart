library toml.src.decoder.parser.whitespace;

import 'package:petitparser/petitparser.dart';

import '../../util/parser.dart';
import 'ranges.dart';

/// Parser for TOML whitespace.
///
///     ws = *wschar
final Parser<String> tomlWhitespace =
    tomlWhitespaceChar.star().join().orFailure('whitespace expected');

/// Parser for a single TOML whitespace character.
///     wschar =  %x20  ; Space
///     wschar =/ %x09  ; Horizontal tab
final Parser<String> tomlWhitespaceChar = ChoiceParser([char(' '), char('\t')])
    .orFailure('single whitespace character expected');

/// Parser for a TOML newline.
///
///     newline =  %x0A     ; LF
///     newline =/ %x0D.0A  ; CRLF
final Parser<String> tomlNewline =
    ChoiceParser([char('\n'), string('\r\n')]).orFailure('newline expected');

/// A regular expression for [tomlNewline].
final RegExp tomlNewlinePattern = RegExp('\n|\r\n');

/// Parser for a TOML comment.
///
///     comment-start-symbol = %x23 ; #
///     comment = comment-start-symbol *non-eol
final Parser tomlComment =
    (char('#') & tomlNonEol.star()).orFailure('comment expected');

/// Parser for arbitrarily many [tomlWhitespaceChar]s, [tomlNewline]s and
/// [tomlComment]s.
///
///     ws-comment-newline = *( wschar / [ comment ] newline )
final Parser tomlWhitespaceCommentNewline = ChoiceParser([
  tomlWhitespaceChar,
  tomlComment.optional() & tomlNewline,
]).star().orFailure('whitespace, comments and newlines expected');
