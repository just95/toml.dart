library toml.src.ast.decoder.value_builder;

import 'package:toml/src/ast.dart';

import 'map_builder.dart';

/// A visitor for [TomlValue]s that builds Dart values from their internal
/// representatons.
class TomlValueBuilder extends TomlValueVisitor<dynamic>
    with TomlStringVisitor<String> {
  /// A that identifies the currently converted value.
  ///
  /// This value is used for error reporting only.
  final TomlKey _currentKey;

  /// Creates a new value builder.
  TomlValueBuilder(this._currentKey);

  @override
  Iterable visitArray(TomlArray array) => array.items.map(visitValue).toList();

  @override
  bool visitBoolean(TomlBoolean boolean) => boolean.value;

  @override
  DateTime visitDateTime(TomlDateTime datetime) => datetime.value;

  @override
  double visitFloat(TomlFloat float) => float.value;

  @override
  Map<String, dynamic> visitInlineTable(TomlInlineTable inlineTable) {
    var builder = TomlMapBuilder.withPrefix(_currentKey);
    inlineTable.pairs.forEach(builder.visitExpression);
    return builder.build();
  }

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
