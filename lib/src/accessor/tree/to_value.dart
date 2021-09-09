library toml.src.accessor.tree.to_value;

import '../../ast.dart';
import '../tree.dart';
import '../visitor/tree.dart';

/// A visitor that converts the accessor data structure to a Dart value, i.e.,
/// nested hash maps and lists of `bool`s, `int`s, `double`s, `Strings` and
/// so on.
class _TomlAccessorToValueVisitor with TomlAccessorVisitorMixin {
  /// A visitor to use to convert non-compound TOML values to Dart values.
  final TomlPrimitiveValueVisitor valueVisitor;

  /// Creates a new visitor that uses the given value visitor to convert
  /// non-compound TOML values to Dart values.
  _TomlAccessorToValueVisitor(this.valueVisitor);

  @override
  List visitArrayAccessor(TomlArrayAccessor array) =>
      array.items.map(visitAccessor).toList();

  @override
  Map<String, dynamic> visitTableAccessor(TomlTableAccessor table) =>
      table.children.map((key, value) => MapEntry(key, visitAccessor(value)));

  @override
  dynamic visitValueAccessor(TomlValueAccessor value) =>
      value.valueNode.acceptPrimitiveValueVisitor(valueVisitor);
}

/// An extension that adds a [toValue] method to [TomlAccessor]s to convert
/// them to a Dart value, i.e., nested hash maps and lists of `bool`s, `int`s,
/// `double`s, `Strings` and so on.
extension TomlAccessorToValueExtension on TomlAccessor {
  /// Recursively converts the subtree rooted at this node to a Dart value.
  ///
  /// The given visitor is used to convert the leafs of the accessor data
  /// structure to Dart values.
  dynamic toValue(TomlPrimitiveValueVisitor valueVisitor) =>
      acceptVisitor(_TomlAccessorToValueVisitor(valueVisitor));
}

/// An extension that adds a [toList] method to [TomlAccessor]s to convert
/// them to a [List] of Dart values.
extension TomlAccessorToListExtension on TomlArrayAccessor {
  /// Recursively converts the subtree rooted at this array node to a [List]
  /// of Dart values.
  ///
  /// The given visitor is used to convert the leafs of the accessor data
  /// structure to Dart values.
  List<dynamic> toList(TomlPrimitiveValueVisitor valueVisitor) =>
      _TomlAccessorToValueVisitor(valueVisitor).visitArrayAccessor(this);
}

/// An extension that adds a [toMap] method to [TomlAccessor]s to convert
/// them to a [Map] of `String`s to Dart values.
extension TomlAccessorToMapExtension on TomlTableAccessor {
  /// Recursively converts the subtree rooted at this table node to a [Map]
  /// of `String`s  Dart values.
  ///
  /// The given visitor is used to convert the leafs of the accessor data
  /// structure to Dart values.
  Map<String, dynamic> toMap(TomlPrimitiveValueVisitor valueVisitor) =>
      _TomlAccessorToValueVisitor(valueVisitor).visitTableAccessor(this);
}
