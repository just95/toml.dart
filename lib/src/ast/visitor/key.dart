import '../key.dart';

/// Interface for visitors of [TomlSimpleKey]s.
abstract class TomlSimpleKeyVisitor<R> {
  /// Visits the given quoted key.
  R visitQuotedKey(TomlQuotedKey key);

  /// Visits the given unquoted key.
  R visitUnquotedKey(TomlUnquotedKey key);
}

/// Mixin that adds a [visitSimpleKey] method to classes implementing
/// [TomlSimpleKeyVisitor] that automatically selects the appropriate
/// visitor method using [TomlSimpleKey.acceptSimpleKeyVisitor].
///
/// This class is usually used when the visitor also implements the
/// [TomlVisitor] interface to provide a default implementation for
/// [TomlVisitor.visitSimpleKey].
mixin TomlSimpleKeyVisitorMixin<R> implements TomlSimpleKeyVisitor<R> {
  /// Visits the given non-dotted [key].
  ///
  /// This method is using [TomlSimpleKey.acceptSimpleKeyVisitor] to invoke the
  /// right visitor method from above.
  R visitSimpleKey(TomlSimpleKey key) => key.acceptSimpleKeyVisitor(this);
}
