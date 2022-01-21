library toml.src.accessor.base;

import 'dart:collection';

import '../ast.dart';
import '../exception.dart';
import 'key.dart';
import 'visitor/tree.dart';

/// Data type for the different types of nodes of the accessor data structure.
enum TomlAccessorType {
  /// Type of array nodes.
  array,

  /// Type of table nodes.
  table,

  /// Type of value nodes.
  value,
}

/// Base class for a data structure that models a TOML document semantically
/// and provides (extension) methods to access the configuration values.
///
/// This is a tree data structure where the inner nodes represent arrays
/// and tables (including inline tables). Edges are labeled with keys or
/// indicies and the leafs store non-composite values.
abstract class TomlAccessor {
  /// A unique identifier of this accessor in the tree.
  ///
  /// This is the concatenation of edge labels on the path from the root
  /// node to this node.
  late final TomlAccessorKey nodeName = _nodeName;

  /// A settable version of [nodeName].
  final TomlSettableAccessorKey _nodeName = TomlSettableAccessorKey();

  /// The node type of this node.
  TomlAccessorType get type;

  /// Whether this node represents an array of tables or array value.
  bool get isArray => type == TomlAccessorType.array;

  /// Whether this node represents a table or inline table.
  bool get isTable => type == TomlAccessorType.table;

  /// Whether this node represents a non-composite value.
  bool get isValue => type == TomlAccessorType.value;

  /// Ensures that this node is of the given type.
  T _expectType<T extends TomlAccessor>(TomlAccessorType expectedType) {
    if (type == expectedType) return this as T;
    throw TomlTypeException(
      nodeName,
      expectedType: expectedType,
      actualType: type,
    );
  }

  /// Ensures that this node is a [TomlArrayAccessor].
  TomlArrayAccessor expectArray() =>
      _expectType<TomlArrayAccessor>(TomlAccessorType.array);

  /// Ensures that this node is a [TomlTableAccessor].
  TomlTableAccessor expectTable() =>
      _expectType<TomlTableAccessor>(TomlAccessorType.table);

  /// Ensures that this node is a [TomlValueAccessor].
  TomlValueAccessor expectValue() =>
      _expectType<TomlValueAccessor>(TomlAccessorType.value);

  /// Invokes the correct `visit*` method for this value of the given visitor.
  R acceptVisitor<R>(TomlAccessorVisitor<R> visitor);
}

/// Data type for the different methods of defining an array accessor.
enum TomlArrayDefinitionMethod {
  /// The array has been defined by the first header of an array of tables.
  arrayTable,

  /// The array has been defined by an array literal.
  arrayLiteral,
}

/// An inner node of the [TomlAccessor] data structure that represents an array
/// of tables or an array of values.
class TomlArrayAccessor extends TomlAccessor {
  /// An unmodifiable list of tables and values that are part of this array.
  ///
  /// Use [addItem] to add new items.
  late final List<TomlAccessor> items = UnmodifiableListView(_items);

  /// A modifiable version of [items].
  final List<TomlAccessor> _items;

  /// How the array represented by this node has been defined or `null` if
  /// the array has been created programmatically.
  TomlArrayDefinitionMethod? definedBy;

  /// Creates a new array accessor with the given [items].
  ///
  /// Creates an accessor for an empty array if no items are given.
  TomlArrayAccessor([
    List<TomlAccessor> items = const [],
    this.definedBy,
  ]) : _items = List.of(items);

  @override
  TomlAccessorType get type => TomlAccessorType.array;

  /// Gets the child node with the given index from this array.
  TomlAccessor getItem(int index) => items[index];

  /// Adds the given child node to the end of the array.
  void addItem(TomlAccessor item) {
    item._nodeName.delegate = nodeName.childKey(items.length);
    _items.add(item);
  }

  @override
  R acceptVisitor<R>(TomlAccessorVisitor<R> visitor) =>
      visitor.visitArrayAccessor(this);
}

/// The root node of the [TomlAccessor] data structure that represents the
/// top-level table.
class TomlDocumentAccessor extends TomlTableAccessor {
  /// Creates a new document accessor with the given [children].
  ///
  /// Creates an accessor for an empty document if no children are given.
  TomlDocumentAccessor([Map<String, TomlAccessor> children = const {}])
      : super(children);
}

/// Data type for the different methods of defining a table accessor.
enum TomlTableDefinitionMethod {
  /// The table has been defined implicitly by a table header for a subtable.
  childTable,

  /// The table has been defined explicitly by a table header.
  tableHeader,

  /// The table has been defined by an inline table.
  inlineTable,

  /// The table has been defined by a dotted key.
  dottedKey,
}

/// An inner node of the [TomlAccessor] data structure that represents a table
/// or inline table.
class TomlTableAccessor extends TomlAccessor {
  /// An unmodifiable map of child tables and key/value pairs of this table.
  late final Map<String, TomlAccessor> children =
      UnmodifiableMapView(_children);

  /// A modifiable version of [children].
  final Map<String, TomlAccessor> _children;

  /// How the table represented by this node has been defined or `null` if
  /// the table has been created programmatically.
  TomlTableDefinitionMethod? definedBy;

  /// Creates a new table accessor with the given [children].
  ///
  /// Creates an accessor for an empty table if no children are given.
  TomlTableAccessor([
    Map<String, TomlAccessor> children = const {},
    this.definedBy,
  ]) : _children = Map.of(children);

  @override
  TomlAccessorType get type => TomlAccessorType.table;

  /// Gets the child node with the given name.
  ///
  /// If the there is no such child node, the [orCreate] callback is invoked
  /// and the returned node is added to the [children] of this table.
  /// If the [orCreate] callback is not specified an exception is thrown
  /// if the requested node could not be found.
  TomlAccessor getChild(String name, {TomlAccessor Function()? orCreate}) =>
      _children.putIfAbsent(name, () {
        if (orCreate == null) throw "TODO";
        var child = orCreate();
        child._nodeName.delegate = nodeName.childKey(name);
        return child;
      });

  /// Adds the given child node and associates it with the given name.
  ///
  /// If there is a child node already a [TomlRedefinitionException] is thrown.
  void addChild(String name, TomlAccessor child) {
    var childName = nodeName.childKey(name);
    if (children.containsKey(name)) throw TomlRedefinitionException(childName);
    child._nodeName.delegate = childName;
    _children[name] = child;
  }

  @override
  R acceptVisitor<R>(TomlAccessorVisitor<R> visitor) =>
      visitor.visitTableAccessor(this);
}

/// A leaf node of the [TomlAccessor] data structure that stores the value
/// of a key/value pair.
///
/// This node only represents non-coposite values. Array values and inline
/// tables are represented by [TomlArrayAccessor] and [TomlTableAccessor],
/// respectively, instead.
class TomlValueAccessor extends TomlAccessor {
  /// The AST node of the value.
  final TomlPrimitiveValue valueNode;

  /// Creates a new leaf node that stores the given value.
  TomlValueAccessor(this.valueNode);

  @override
  TomlAccessorType get type => TomlAccessorType.value;

  @override
  R acceptVisitor<R>(TomlAccessorVisitor<R> visitor) =>
      visitor.visitValueAccessor(this);
}
