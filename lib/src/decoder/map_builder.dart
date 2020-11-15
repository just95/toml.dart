library toml.src.ast.decoder.map_builder;

import 'package:toml/ast.dart';
import 'package:toml/exception.dart';

/// A visitor for [TomlExpression]s that builds a [Map] for
class TomlMapBuilder extends TomlExpressionVisitor<void> {
  /// Internal representation of the top-level table.
  final _TomlTreeMap _topLevel;

  /// Internal representation of the currently open table.
  ///
  /// By default the [_topLevel] table is open.
  /// Visited key/value pairs are added to this table.
  /// When a standard table header is visited, the corresponding table is
  /// created if it does not exist already and it is opened. When an array of
  /// tables header is visited, a new table is added to the array of tables
  /// and it is opened.
  _TomlTreeMap _current;

  /// Creates a map builder.
  TomlMapBuilder() : _topLevel = _TomlTreeMap() {
    _current = _topLevel;
  }

  /// Builds the map for the visited AST nodes.
  Map<String, dynamic> build() => _topLevel.value;

  @override
  void visitKeyValuePair(TomlKeyValuePair pair) {
    _current.addChild(pair.key, _TomlTreeLeaf.fromValue(pair.value));
  }

  @override
  void visitStandardTable(TomlStandardTable table) {
    // Create the standard table.
    var parent = _topLevel.findOrAddChild(table.name.parent);
    var child = parent.getOrAddChild(table.name.child, () => _TomlTreeMap());

    // Throw an exception if the table has been defined explicitly already or
    // there is another entity with the same name.
    if (child is _TomlTreeMap) {
      if (child.isExplicitlyDefined) {
        throw TomlException('Cannot redefine table ${table.name}.');
      }
      // The table does not exist or has been defined implicitly only.
      child.isExplicitlyDefined = true;
      _current = child;
    } else {
      throw TomlException('Cannot create table ${table.name}: '
          'Entity with same name exists already.');
    }
  }

  @override
  void visitArrayTable(TomlArrayTable table) {
    var parent = _topLevel.findOrAddChild(table.name.parent);
    var child = parent.getOrAddChild(table.name.child, () => _TomlTreeList());

    // Create a new array entry or throw an exception if there is a non-array
    // of tables entity with the same name already.
    if (child is _TomlTreeList) {
      var next = _TomlTreeMap();
      next.isExplicitlyDefined = true;
      child.elements.add(next);
      _current = next;
    } else {
      throw TomlException('Cannot create array of tables ${table.name}: '
          'Entity with same name exists already.');
    }
  }
}

/// Base class for the data type that is used internally by the [MapBuilder]
/// to store information about the map that is currently constructed.
///
/// This data structure is a tree where the inner nodes represent tables and
/// arrays of tables. Edges are labeled with keys and the leafs store the
/// values.
abstract class _TomlTree<V> {
  /// The value of this node.
  ///
  /// The value of inner nodes is a [Map] for tables and a [List] of [Map]s
  /// for arrays of tables.
  V get value;

  /// Gets the child node from the edge that is labeled with the given [key]
  /// or uses the given function to create a new child node if there is no
  /// such edge already.
  _TomlTree getOrAddChild(TomlSimpleKey key, _TomlTree Function() buildChild);

  /// TODO
  _TomlTree findOrAddChild(TomlKey key) {
    _TomlTree current = this;
    for (var part in key.parts) {
      current = current.getOrAddChild(part, () => _TomlTreeMap());
    }
    return current;
  }
}

/// A node of the [_TomlTree] data structure that stores the value of a
/// key/value pair.
class _TomlTreeLeaf<V> extends _TomlTree<V> {
  @override
  final V value;

  /// The TOML type of the stored value.
  ///
  /// This is only used to improve error messages.
  final TomlType valueType;

  /// Creates a new leaf node that stores the given value of the given type.
  _TomlTreeLeaf(this.value, this.valueType);

  /// Creates a new leaf node for the given [TomlValue].
  factory _TomlTreeLeaf.fromValue(TomlValue<V> node) =>
      _TomlTreeLeaf(node.value, node.type);

  @override
  _TomlTree getOrAddChild(TomlSimpleKey key, _TomlTree Function() buildChild) {
    throw TomlException(
        'Cannot get or add child ${key} for value of type ${valueType}.');
  }
}

/// A node of the [_TomlTree] data structure that stores information about a
/// standard table.
class _TomlTreeMap extends _TomlTree<Map<String, dynamic>> {
  /// The child tables and key/value pairs of this table.
  final Map<String, _TomlTree> children;

  /// Whether the table that is represented by this node has been created
  /// explicitly or implicitly.
  ///
  /// By default all tables are created implicitly (i.e., this flag is set
  /// to `false`). When a table header is visited by the [TomlMapBuilder],
  /// the flag is set to `true` for the corresponding table. This information
  /// is needed to reject TOML documents that explicitly define the same table
  /// twice.
  bool isExplicitlyDefined = false;

  /// Creates a new node for a standard table.
  _TomlTreeMap([Map<String, _TomlTree> children]) : children = children ?? {};

  @override
  Map<String, dynamic> get value =>
      children.map((k, v) => MapEntry(k, v.value));

  /// Adds a new child to the map and throws an exception if the child exists
  /// already.
  void addChild(TomlSimpleKey key, _TomlTree child) {
    if (children.containsKey(key.name)) {
      throw TomlException('Cannot redefine ${key}.');
    }
    children[key.name] = child;
  }

  @override
  _TomlTree getOrAddChild(TomlSimpleKey key, _TomlTree Function() buildChild) =>
      children.putIfAbsent(key.name, buildChild);
}

/// A node of the [_TomlTree] data structure that stores information about an
/// array of tables.
class _TomlTreeList extends _TomlTree<List<Map<String, dynamic>>> {
  /// The tables that are part of this array.
  final List<_TomlTreeMap> elements;

  /// Creates a new node for an array of tables.
  _TomlTreeList([List<_TomlTreeMap> elements]) : elements = elements ?? [];

  @override
  List<Map<String, dynamic>> get value => elements.map((v) => v.value).toList();

  @override
  _TomlTree getOrAddChild(TomlSimpleKey key, _TomlTree Function() buildChild) =>
      elements.last.getOrAddChild(key, buildChild);
}
