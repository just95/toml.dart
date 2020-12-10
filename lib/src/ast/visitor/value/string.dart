library toml.src.ast.value.visitor.string;

import '../../value/string.dart';
import '../../value/string/basic.dart';
import '../../value/string/literal.dart';
import '../../value/string/ml_basic.dart';
import '../../value/string/ml_literal.dart';

/// Interface for visitors of [TomlString]s.
abstract class TomlStringVisitor<T> {
  /// Visits the given basic string.
  T visitBasicString(TomlBasicString string);

  /// Visits the given literal string.
  T visitLiteralString(TomlLiteralString string);

  /// Visits the given multiline basic string.
  T visitMultilineBasicString(TomlMultilineBasicString string);

  /// Visits the given multiline literal string.
  T visitMultilineLiteralString(TomlMultilineLiteralString string);

  /// Visits the given [value].
  ///
  /// This method is using [TomlString.acceptStringVisitor] to invoke the right
  /// visitor method from above.
  T visitString(TomlString value) => value.acceptStringVisitor(this);
}
