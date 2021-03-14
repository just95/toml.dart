library toml.src.ast.visitor.key;

import '../key.dart';

/// Interface for visitors of [TomlSimpleKey]s.
abstract class TomlSimpleKeyVisitor<R> {
  /// Visits the given quoted key.
  R visitQuotedKey(TomlQuotedKey key);

  /// Visits the given unquoted key.
  R visitUnquotedKey(TomlUnquotedKey key);

  /// Visits the given non-dotted [key].
  ///
  /// This method is using [TomlSimpleKey.acceptSimpleKeyVisitor] to invoke the
  /// right visitor method from above.
  R visitSimpleKey(TomlSimpleKey key) => key.acceptSimpleKeyVisitor(this);
}
