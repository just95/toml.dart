library toml.src.ast.decoder.value_builder;

import '../ast.dart';

/// A visitor for [TomlValue]s that builds Dart values from their internal
/// representatons.
class TomlValueBuilder
    with
        TomlPrimitiveValueVisitorMixin<dynamic>,
        TomlStringVisitorMixin<String> {
  @override
  bool visitBoolean(TomlBoolean boolean) => boolean.value;

  @override
  TomlDateTime visitDateTime(TomlDateTime dateTime) => dateTime;

  @override
  double visitFloat(TomlFloat float) => float.value;

  @override
  dynamic visitInteger(TomlInteger integer) {
    // Use `int` only if the number can be represented as a 64-bit signed
    // integer (or can be represented by a JavaScript number if the code
    // has been compiled to JS), otherwise return a `BigInt`.
    if (integer.value.isValidInt) return integer.value.toInt();
    return integer.value;
  }

  @override
  String visitBasicString(TomlBasicString string) => string.value;

  @override
  String visitLiteralString(TomlLiteralString string) => string.value;

  @override
  String visitMultilineBasicString(TomlMultilineBasicString string) =>
      string.value;

  @override
  String visitMultilineLiteralString(TomlMultilineLiteralString string) =>
      string.value;
}
