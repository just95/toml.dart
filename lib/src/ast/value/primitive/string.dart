library toml.src.ast.value.primitive.string;

import 'package:petitparser/petitparser.dart';

import '../../visitor/value/primitive.dart';
import '../../visitor/value/primitive/string.dart';
import '../primitive.dart';
import '../type.dart';
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
abstract class TomlString extends TomlPrimitiveValue {
  /// Parser for a TOML string value.
  static final Parser<TomlString> parser = ChoiceParser([
    TomlMultilineString.parser,
    TomlSinglelineString.parser,
  ], failureJoiner: selectFarthestJoined);

  /// The contents of the string.
  String get value;

  /// The type of this string.
  TomlStringType get stringType;

  @override
  TomlValueType get type => TomlValueType.string;

  @override
  T acceptPrimitiveValueVisitor<T>(TomlPrimitiveValueVisitor<T> visitor) =>
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
  ///
  /// Even though `""` and `''` are valid single line strings, this parser
  /// does not accept them if the input starts with `"""` or `'''`.
  /// Without this optimization [TomlString.parser] would always accept
  /// multiline strings that contain syntax errors and the unconsumed quotation
  /// mark would cause a less descriptive error message later.
  static final Parser<TomlSinglelineString> parser = ChoiceParser([
    TomlBasicString.parser
        .skip(before: string(TomlMultilineBasicString.delimiter).not()),
    TomlLiteralString.parser
        .skip(before: string(TomlMultilineLiteralString.delimiter).not()),
  ], failureJoiner: selectFarthestJoined);
}

/// Base class for AST nodes that represent multiline TOML strings.
///
/// This class exists only for the sake of consistency with
/// [TomlSinglelineString].
abstract class TomlMultilineString extends TomlString {
  /// Parser for a multiline TOML string value.
  static final Parser<TomlMultilineString> parser = ChoiceParser([
    TomlMultilineBasicString.parser,
    TomlMultilineLiteralString.parser,
  ], failureJoiner: selectFarthestJoined);
}
