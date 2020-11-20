// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.decoder.map_builder;

import 'package:toml/ast.dart';

import 'exception/redefinition.dart';
import 'exception/not_a_table.dart';

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

  /// Creates a map builder for the top-level table.
  factory TomlMapBuilder() => TomlMapBuilder.withPrefix(TomlKey.topLevel);

  /// Creates a map builder for the table with the given name.
  TomlMapBuilder.withPrefix(TomlKey prefix) : _topLevel = _TomlTreeMap(prefix) {
    _current = _topLevel;
  }

  /// Builds the map for the visited AST nodes.
  Map<String, dynamic> build() => _topLevel.value;

  @override
  void visitKeyValuePair(TomlKeyValuePair pair) {
    var key = _current.nodeName.child(pair.key),
        value = pair.value.buildValue(key);
    _current.addChild(pair.key, _TomlTreeLeaf(key, value));
  }

  @override
  void visitStandardTable(TomlStandardTable table) {
    // Create the standard table.
    var parent = _topLevel.findOrAddChild(table.name.parentKey),
        child = parent.getOrAddChild(
          table.name.childKey,
          () => _TomlTreeMap(table.name),
        );

    // Throw an exception if the table has been defined explicitly already or
    // there is another entity with the same name.
    if (child is _TomlTreeMap) {
      if (child.isExplicitlyDefined) {
        throw TomlRedefinitionException(table.name);
      }
      // The table does not exist or has been defined implicitly only.
      child.isExplicitlyDefined = true;
      _current = child;
    } else {
      throw TomlRedefinitionException(table.name);
    }
  }

  @override
  void visitArrayTable(TomlArrayTable table) {
    var parent = _topLevel.findOrAddChild(table.name.parentKey),
        child = parent.getOrAddChild(
          table.name.childKey,
          () => _TomlTreeList(table.name),
        );

    // Create a new array entry or throw an exception if there is a non-array
    // of tables entity with the same name already.
    if (child is _TomlTreeList) {
      var next = _TomlTreeMap(table.name);
      next.isExplicitlyDefined = true;
      child.elements.add(next);
      _current = next;
    } else {
      throw TomlRedefinitionException(table.name);
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
  /// The key that identifies this node.
  final TomlKey nodeName;

  /// Creates a new node of the tree.
  _TomlTree(this.nodeName);

  /// The value of this node.
  ///
  /// The value of inner nodes is a [Map] for tables and a [List] of [Map]s
  /// for arrays of tables.
  V get value;

  /// Gets the child node from the edge that is labeled with the given [key]
  /// or uses the given function to create a new child node if there is no
  /// such edge already.
  _TomlTree getOrAddChild(TomlSimpleKey key, _TomlTree Function() buildChild);

  /// Traverses the tree along the edges identified by the given [key] and
  /// returns the final sub-tree.
  ///
  /// If a node does not exist, a new [_TomlTreeMap] is created. This behavior
  /// corresponds to the implicit creation of parent tables in TOML.
  _TomlTree findOrAddChild(TomlKey key) {
    _TomlTree current = this;
    for (var part in key.parts) {
      current = current.getOrAddChild(
        part,
        () => _TomlTreeMap(current.nodeName.child(part)),
      );
    }
    return current;
  }
}

/// A node of the [_TomlTree] data structure that stores the value of a
/// key/value pair.
class _TomlTreeLeaf<V> extends _TomlTree<V> {
  @override
  final V value;

  /// Creates a new leaf node that stores the given value of the given type.
  _TomlTreeLeaf(TomlKey nodeName, this.value) : super(nodeName);

  @override
  _TomlTree getOrAddChild(TomlSimpleKey key, _TomlTree Function() buildChild) {
    throw TomlNotATableException(nodeName.child(key));
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
  bool isExplicitlyDefined;

  /// Creates a new node for a standard table.
  _TomlTreeMap(TomlKey nodeName)
      : children = {},
        isExplicitlyDefined = false,
        super(nodeName);

  @override
  Map<String, dynamic> get value =>
      children.map((k, v) => MapEntry(k, v.value));

  /// Adds a new child to the map and throws an exception if the child exists
  /// already.
  void addChild(TomlSimpleKey key, _TomlTree child) {
    if (children.containsKey(key.name)) {
      throw TomlRedefinitionException(nodeName.child(key));
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
  _TomlTreeList(TomlKey nodeName)
      : elements = [],
        super(nodeName);

  @override
  List<Map<String, dynamic>> get value => elements.map((v) => v.value).toList();

  @override
  _TomlTree getOrAddChild(TomlSimpleKey key, _TomlTree Function() buildChild) =>
      elements.last.getOrAddChild(key, buildChild);
}
