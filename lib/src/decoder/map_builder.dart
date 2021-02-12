library toml.src.ast.decoder.map_builder;

import 'package:toml/src/ast.dart';

import 'exception/not_a_table.dart';
import 'exception/redefinition.dart';
import 'value_builder.dart';

/// A visitor for [TomlExpression]s that builds a [Map] from a TOML document.
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
    var key = _current.nodeName.deepChild(pair.key),
        valueBuilder = TomlValueBuilder(key),
        value = valueBuilder.visitValue(pair.value),
        parent = _current.findOrAddChild(pair.key.parentKey,
            onBeforeGetChild: (node, part) {
              if (node is! _TomlTreeMap) {
                throw TomlNotATableException(node.nodeName.child(part));
              }
            },
            buildChild: (dottedTableName) => _TomlTreeMap(dottedTableName),
            onAfterGetChild: (node) {
              if (node is _TomlTreeMap) node.isExplicitlyDefined = true;
            });
    if (parent is _TomlTreeMap) {
      parent.addChild(pair.key.childKey, _TomlTreeLeaf(key, value));
    } else {
      throw TomlNotATableException(key);
    }
  }

  @override
  void visitStandardTable(TomlStandardTable table) {
    // Create the standard table.
    var parent = _topLevel.findOrAddChild(
          table.name.parentKey,
          buildChild: (implicitTableName) => _TomlTreeMap(implicitTableName),
        ),
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
    var parent = _topLevel.findOrAddChild(
          table.name.parentKey,
          buildChild: (implicitTableName) => _TomlTreeMap(implicitTableName),
        ),
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
  /// If a node does not exist, a new node is created with the provided
  /// function. Usually a [_TomlTreeMap] is created by this function. This
  /// behavior corresponds to the implicit creation of parent tables in TOML.
  ///
  /// The optional [onBeforeGetChild] and [onAfterGetChild] callbacks are
  /// invoked before and after a child node is looked up. They are used by
  /// key/value pairs to ensure that dotted keys cannot be used to insert
  /// values into arrays of tables and to mark each table in the dotted
  /// key as explicitly defined.
  _TomlTree findOrAddChild(TomlKey key,
      {bool makeExplicit,
      void Function(_TomlTree node, TomlSimpleKey part) onBeforeGetChild,
      _TomlTree Function(TomlKey childNodeName) buildChild,
      void Function(_TomlTree node) onAfterGetChild}) {
    _TomlTree current = this;
    for (var part in key.parts) {
      if (onBeforeGetChild != null) onBeforeGetChild(current, part);
      current = current.getOrAddChild(
        part,
        () => buildChild(current.nodeName.child(part)),
      );
      if (onAfterGetChild != null) onAfterGetChild(current);
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
  /// to `false`). When a table header is visited by the [TomlMapBuilder] or
  /// it looks up the parent node to write the value of a dotted key into,
  /// the flag is set to `true` for the corresponding table or tables. This
  /// information is needed to reject TOML documents that explicitly define the
  /// same table twice or a table in both dotted key and `[table]` form.
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
