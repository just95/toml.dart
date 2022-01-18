library toml.src.decoder.accessor_builder;

import '../accessor.dart';
import '../ast.dart';
import '../exception.dart';
import 'value_builder.dart';

/// Extension that adds a method to 'TomlDocument' for converting the abstract
/// syntax tree to an accessor.
extension TomlDocumentToAccessorExtension on TomlDocument {
  /// Converts this document to a 'TomlDocumentAccessor'.
  TomlDocumentAccessor toAccessor() {
    var builder = TomlAccessorBuilder();
    expressions.forEach(builder.visitExpression);
    return builder.topLevel;
  }

  /// Converts this document to a map from keys to values.
  Map<String, dynamic> toMap() => toAccessor().toMap(TomlValueBuilder());
}

/// A visitor for [TomlExpression]s that builds a [TomlAccessor] from a TOML
/// document's abstract syntax tree (AST).
///
/// This visitor implements the semantics of the TOML document represented by
/// the visited AST.
class TomlAccessorBuilder
    with
        TomlExpressionVisitorMixin<void>,
        TomlValueVisitorMixin<void>,
        TomlCompoundValueVisitorMixin<void> {
  /// Accessor for the top-level table.
  final TomlDocumentAccessor topLevel;

  /// Accessor for the currently open table or array.
  ///
  /// Nodes are added to the currently open table or array for every visited
  /// non-compound value using the [_addChild] callback.
  ///
  /// By default the [topLevel] table is open.
  ///
  /// When a standard table header is visited, the corresponding table is
  /// created if it does not exist already and it is opened. When an array of
  /// tables header is visited, a new table is added to the array of tables
  /// and the added table is opened.
  ///
  /// When an array literal is visited, a new array accessor is opened.
  /// When an inline table is visited, a new table accessor is opened.
  late TomlAccessor _current;

  /// A callback to use to add a child to the [_current]ly open table.
  ///
  /// Before a key/value pair is visited, this function is `null` and visiting
  /// a value node fails.
  void Function(TomlAccessor)? _addChildCallback;

  /// Creates a builder for the top-level table accessor.
  TomlAccessorBuilder() : topLevel = TomlDocumentAccessor() {
    _current = topLevel;
  }

  @override
  void visitKeyValuePair(TomlKeyValuePair pair) => _context(() {
        // Find the parent table of the dotted-key.
        var tableAccessor = _findNode(
          _current,
          pair.key.parentKey,
          orCreate: _createImplicitTable,
          forEach: _setDefinedByDottedKey,
        ).expectTable();

        // Open the parent table temporarily. When a children is added to the
        // opened table, the last part of the dotted-key is used as an edge
        // label.
        _setCurrent(
          tableAccessor,
          onAddChild: (child) =>
              tableAccessor.addChild(pair.key.childKey.name, child),
        );

        // Visit the right-hand side of the key/value pair to add the value.
        pair.value.acceptValueVisitor(this);
      });

  @override
  void visitStandardTable(TomlStandardTable table) {
    // Find or create the accessor for the table and all parent accessors.
    var tableAccessor = _findNode(
      topLevel,
      table.name,
      orCreate: _createImplicitTable,
      forEach: _expectExtendableTable,
    );

    // The table must not have been explicitly defined by a table header or
    // dotted key before and there must be no array or value with the same name
    // already. We already know that the table is extendable, i.e., not an
    // inline table.
    if (tableAccessor is! TomlTableAccessor ||
        tableAccessor.definedBy == TomlTableDefinitionMethod.tableHeader ||
        tableAccessor.definedBy == TomlTableDefinitionMethod.dottedKey) {
      throw TomlRedefinitionException(tableAccessor.nodeName);
    }

    // Open the table and remember that it has been explicitly defined.
    tableAccessor.definedBy = TomlTableDefinitionMethod.tableHeader;
    _setCurrent(tableAccessor);
  }

  @override
  void visitArrayTable(TomlArrayTable table) {
    // Find or create the accessors for the array's parents.
    var parentAccessor = _findNode(
      topLevel,
      table.name.parentKey,
      orCreate: _createImplicitTable,
      forEach: _expectExtendableTable,
    );

    // Get or create the accessor for the array of tables.
    var arrayAccessor = _getNode(
      parentAccessor,
      table.name.childKey.name,
      orCreate: _createArrayTable,
    );

    // The accessor must have been created by an array of tables.
    if (arrayAccessor is! TomlArrayAccessor ||
        arrayAccessor.definedBy != TomlArrayDefinitionMethod.arrayTable) {
      throw TomlRedefinitionException(arrayAccessor.nodeName);
    }

    // Create a new entry for the array of tables.
    var tableAccessor = TomlTableAccessor();
    tableAccessor.definedBy = TomlTableDefinitionMethod.tableHeader;

    // Add the new table to the array and open the table.
    arrayAccessor.addItem(tableAccessor);
    _setCurrent(tableAccessor);
  }

  @override
  void visitPrimitiveValue(TomlPrimitiveValue value) {
    _addChild(TomlValueAccessor(value));
  }

  @override
  void visitArray(TomlArray array) => _context(() {
        // Create and open a new accessor for the array literal. If a child
        // is added in this context, it is added to the end of the array.
        var accessor = _addChild(TomlArrayAccessor());
        accessor.definedBy = TomlArrayDefinitionMethod.arrayLiteral;
        _setCurrent(accessor, onAddChild: (child) => accessor.addItem(child));

        // Visit the array items to add accessors for them to the array.
        for (var item in array.items) {
          item.acceptValueVisitor(this);
        }
      });

  @override
  void visitInlineTable(TomlInlineTable inlineTable) => _context(() {
        // Create and open a new accessor for the inline table.
        var accessor = _addChild(TomlTableAccessor());
        accessor.definedBy = TomlTableDefinitionMethod.inlineTable;
        _setCurrent(accessor);

        // Visit the key/value pairs of the inline table to add their values
        // to the table accessor.
        for (var pair in inlineTable.pairs) {
          pair.acceptExpressionVisitor(this);
        }
      });

  /// Sets the [_current]ly open node.
  ///
  /// Optionally a callback can be specified for how to add children to the
  /// the newly opened node.
  void _setCurrent(
    TomlAccessor newCurrent, {
    void Function(TomlAccessor)? onAddChild,
  }) {
    _current = newCurrent;
    _addChildCallback = onAddChild;
  }

  /// Invokes the last callback in the [_addChildStatck] with the given node.
  ///
  /// Returns the added child.
  T _addChild<T extends TomlAccessor>(T child) {
    _addChildCallback?.call(child);
    return child;
  }

  /// Executes the given callback and restores the state of the builder
  /// afterwards.
  T _context<T>(T Function() callback) {
    var oldCurrent = _current;
    var oldAddChild = _addChildCallback;
    try {
      return callback();
    } finally {
      _current = oldCurrent;
      _addChildCallback = oldAddChild;
    }
  }

  /// Creates a new accessor for an implicitly defined table.
  TomlAccessor _createImplicitTable() {
    var accessor = TomlTableAccessor();
    accessor.definedBy = TomlTableDefinitionMethod.childTable;
    return accessor;
  }

  /// Creates a new accessor for an array of tables.
  TomlAccessor _createArrayTable() {
    var accessor = TomlArrayAccessor();
    accessor.definedBy = TomlArrayDefinitionMethod.arrayTable;
    return accessor;
  }

  /// Tests whether a sub-table of the table represented by the given accessor
  /// can be defined using a table header.
  ///
  /// A table header cannot be used to define sub-tables of inline tables.
  /// However, they can be used to define sub-tables of dotted keys.
  void _expectExtendableTable(TomlAccessor accessor) {
    if (accessor is TomlTableAccessor) {
      if (accessor.definedBy == TomlTableDefinitionMethod.inlineTable) {
        throw TomlRedefinitionException(accessor.nodeName);
      }
    }
  }

  /// Marks the given table accessor as defined by a dotted key.
  ///
  /// If the given accessor does not represent a table or the table
  /// represented by the accessor has been defined by a method that is
  /// incompatible with dotted keys, an exception is thrown.
  void _setDefinedByDottedKey(TomlAccessor accessor) {
    var tableAccessor = accessor.expectTable();
    if (tableAccessor.definedBy == TomlTableDefinitionMethod.tableHeader ||
        tableAccessor.definedBy == TomlTableDefinitionMethod.inlineTable) {
      throw TomlRedefinitionException(tableAccessor.nodeName);
    }
    tableAccessor.definedBy = TomlTableDefinitionMethod.dottedKey;
  }

  /// Gets the child node with the given name of a table accessor.
  ///
  /// If the given accessor does not represent a table but an array of tables,
  /// the child of the last entry in the array is returned instead.
  ///
  /// If the child node does not exist, the given [orCreate] function is used
  /// to construct
  TomlAccessor _getNode(
    TomlAccessor accessor,
    String name, {
    TomlAccessor Function()? orCreate,
  }) {
    while (accessor.isArray) {
      accessor = accessor.expectArray().items.last;
    }
    return accessor.expectTable().getChild(name, orCreate: orCreate);
  }

  /// Finds a decendant node of the given accessor by successive
  /// applications of [_getNode] on the parts of the given key.
  ///
  /// If a node on the path does not exist, it is created using the [orCreate]
  /// callback. If the [forEach] callback is specified, it is invoked for every
  /// node on the path except for the initial node.
  TomlAccessor _findNode(
    TomlAccessor initialAccessor,
    TomlKey key, {
    TomlAccessor Function()? orCreate,
    void Function(TomlAccessor)? forEach,
  }) =>
      key.parts.fold(
        initialAccessor,
        (currentAccessor, part) {
          var nextAccessor = _getNode(
            currentAccessor,
            part.name,
            orCreate: orCreate,
          );
          if (forEach != null) forEach(nextAccessor);
          return nextAccessor;
        },
      );
}
