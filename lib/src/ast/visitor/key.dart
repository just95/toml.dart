library toml.src.ast.visitor.key;

import '../key.dart';

/// Interface for visitors of [TomlKey]s.
abstract class TomlKeyVisitor<T> {
  /// Visits the given key.
  T visitKey(TomlKey key);
}

/// Interface for visitors of [TomlSimpleKey]s.
abstract class TomlSimpleKeyVisitor<T> {
  /// Visits the given quoted key.
  T visitQuotedKey(TomlQuotedKey key);

  /// Visits the given unquoted key.
  T visitUnquotedKey(TomlUnquotedKey key);

  /// Visits the given non-dotted [key].
  ///
  /// This method is using [TomlKey.acceptSimpleKeyVisitor] to invoke the right
  /// visitor method from above.
  T visitSimpleKey(TomlSimpleKey key) => key.acceptSimpleKeyVisitor(this);
}
