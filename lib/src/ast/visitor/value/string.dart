import '../../value/string.dart';
import '../../value/string/basic.dart';
import '../../value/string/literal.dart';
import '../../value/string/ml_basic.dart';
import '../../value/string/ml_literal.dart';

/// Interface for visitors of [TomlString]s.
abstract class TomlStringVisitor<R> {
  /// Visits the given basic string.
  R visitBasicString(TomlBasicString string);

  /// Visits the given literal string.
  R visitLiteralString(TomlLiteralString string);

  /// Visits the given multiline basic string.
  R visitMultilineBasicString(TomlMultilineBasicString string);

  /// Visits the given multiline literal string.
  R visitMultilineLiteralString(TomlMultilineLiteralString string);
}

/// Mixin that adds a [visitString] method to classes implementing
/// [TomlStringVisitor] that automatically selects the appropriate
/// visitor method using [TomlString.acceptStringVisitor].
///
/// This class is usually used when the visitor also implements the
/// [TomlValueVisitor] interface to provide a default implementation
/// for [TomlValueVisitor.visitString].
mixin TomlStringVisitorMixin<R> implements TomlStringVisitor<R> {
  /// Visits the given [value].
  ///
  /// This method is using [TomlString.acceptStringVisitor] to invoke the right
  /// visitor method from above.
  R visitString(TomlString value) => value.acceptStringVisitor(this);
}
