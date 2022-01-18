library toml.src.accessor.key.printer;

import '../../encoder.dart';
import '../key.dart';
import '../visitor/key.dart';

/// A visitor for keys of the accessor data structure that converts the keys
/// into a human readable format.
///
/// The `visit*` methods return `true` if and only if they added text to
/// the buffer, i.e., if it is not the root node.
class TomlAccessorKeyPrinter with TomlAccessorKeyVisitorMixin<bool> {
  /// Buffer for constructing the formatted string.
  final StringBuffer _buffer = StringBuffer();

  /// An AST builder that is used to convert the names of accessor keys to
  /// key nodes that can be printed with the pretty printer.
  final TomlAstBuilder _astBuilder = TomlAstBuilder();

  @override
  String toString() => _buffer.toString();

  @override
  bool visitIndexKey(TomlIndexAccessorKey key) {
    key.parentKey.acceptKeyVisitor(this);
    _buffer.write('[');
    _buffer.write(key.index);
    _buffer.write(']');
    return true;
  }

  @override
  bool visitNameKey(TomlNameAccessorKey key) {
    // Separate the key from the parent key if the parent is not the root key.
    if (key.parentKey.acceptKeyVisitor(this)) _buffer.write('.');
    _buffer.write(_astBuilder.buildSimpleKey(key.name));
    return true;
  }

  @override
  bool visitRootKey(TomlRootAccessorKey key) {
    return false;
  }
}
