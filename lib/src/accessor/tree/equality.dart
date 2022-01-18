library toml.src.accessor.tree.equality;

import 'package:collection/collection.dart';

import '../../ast.dart';
import '../tree.dart';
import '../tree/match.dart';

/// Equality on 'TomlAccessor's.
class TomlAccessorEquality implements Equality<TomlAccessor> {
  /// The equality to use to compare items of array accessors.
  late final ListEquality itemEquality = ListEquality(this);

  /// The equality to use to compare the children of table accessors.
  late final MapEquality childrenEquality = MapEquality(
    keys: DefaultEquality(),
    values: this,
  );

  /// The equality to use to compare the value AST nodes of value accessors.
  final Equality<TomlPrimitiveValue> valueEquality = DefaultEquality();

  @override
  bool equals(TomlAccessor e1, TomlAccessor e2) => e1.match(
        array: (array) =>
            e2 is TomlArrayAccessor &&
            itemEquality.equals(array.items, e2.items),
        table: (table) =>
            e2 is TomlTableAccessor &&
            childrenEquality.equals(table.children, e2.children),
        value: (value) =>
            e2 is TomlValueAccessor &&
            valueEquality.equals(value.valueNode, e2.valueNode),
      );

  @override
  int hash(TomlAccessor e) => e.match(
        array: (array) => itemEquality.hash(array.items),
        table: (table) => childrenEquality.hash(table.children),
        value: (value) => valueEquality.hash(value.valueNode),
      );

  @override
  bool isValidKey(Object? o) => o is TomlAccessor;
}
