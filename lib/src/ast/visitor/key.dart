library toml.src.ast.visitor.key;

import '../key.dart';

/// Interface for visitors of [TomlSimpleKey]s.
abstract class TomlSimpleKeyVisitor<T> {
  /// Visits the given quoted key.
  T visitQuotedKey(TomlQuotedKey key);

  /// Visits the given unquoted key.
  T visitUnquotedKey(TomlUnquotedKey key);

  /// Visits the given non-dotted [key].
  ///
  /// This method is using [TomlSimpleKey.acceptSimpleKeyVisitor] to invoke the
  /// right visitor method from above.
  T visitSimpleKey(TomlSimpleKey key) => key.acceptSimpleKeyVisitor(this);
}
