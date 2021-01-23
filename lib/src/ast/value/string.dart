library toml.src.ast.value.string;

import 'package:petitparser/petitparser.dart';

import '../value.dart';
import '../visitor/value.dart';
import '../visitor/value/string.dart';
import 'string/basic.dart';
import 'string/literal.dart';
import 'string/ml_basic.dart';
import 'string/ml_literal.dart';

/// The four types of TOML strings.
enum TomlStringType {
  /// Type of a [TomlBasicString].
  basic,

  /// Type of a [TomlLiteralString].
  literal,

  /// Type of a [TomlMultilineBasicString].
  multilineBasic,

  /// Type of a [TomlMultilineLiteralString].
  multilineLiteral
}

/// Base class for AST nodes that represent a TOML strings.
///
///     string = ml-basic-string
///            / basic-string
///            / ml-literal-string
///            / literal-string
abstract class TomlString extends TomlValue {
  /// Parser for a TOML string value.
  static final Parser<TomlString> parser = (TomlMultilineBasicString.parser |
          TomlBasicString.parser |
          TomlMultilineLiteralString.parser |
          TomlLiteralString.parser)
      .cast<TomlString>();

  /// The contents of the string.
  String get value;

  /// The type of this string.
  TomlStringType get stringType;

  @override
  TomlType get type => TomlType.string;

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitString(this);

  /// Invokes the correct `visit*` method for this string value of the given
  /// visitor.
  T acceptStringVisitor<T>(TomlStringVisitor<T> visitor);
}

/// Base class for AST nodes that represent non-multiline TOML strings (i.e.,
/// literal and basic strings).
///
/// This class is used such that quoted keys can restrict the type of the
/// string on type level.
abstract class TomlSinglelineString extends TomlString {
  /// Parser for a singleline TOML string value.
  static final Parser<TomlSinglelineString> parser =
      (TomlBasicString.parser | TomlLiteralString.parser)
          .cast<TomlSinglelineString>();
}

/// Base class for AST nodes that represent multiline TOML strings.
///
/// This class exists only for the sake of consistency with
/// [TomlSinglelineString].
abstract class TomlMultilineString extends TomlString {
  /// Parser for a multiline TOML string value.
  static final Parser<TomlMultilineString> parser =
      (TomlMultilineBasicString.parser | TomlMultilineLiteralString.parser)
          .cast<TomlMultilineString>();
}
