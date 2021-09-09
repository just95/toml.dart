library toml.src.accessor.key;

import 'package:petitparser/petitparser.dart';

import '../ast.dart';
import '../decoder.dart';
import '../exception.dart';
import '../util/parser.dart';
import 'key/printer.dart';
import 'visitor/key.dart';

/// A key that uniquely identifies a node of the accessor data structure.
abstract class TomlAccessorKey {
  /// The key for the root node of the accessor data structure.
  static TomlRootAccessorKey topLevel = TomlRootAccessorKey._();

  /// Parser for an accessor key.
  ///
  ///     accessor-key = unprefixed-name-accessor-key *( ws accessor-key-part )
  ///     accessor-key-part =  prefixed-name-accessor-key
  ///     accessor-key-part =/ index-accessor-key
  static final Parser<TomlAccessorKey> parser = PairParser(
    TomlNameAccessorKey.unprefixedParser,
    ChoiceParser([
      TomlNameAccessorKey.prefixedParser,
      TomlIndexAccessorKey.parser,
    ]).star(),
  ).map((pair) => [pair.first, ...pair.second].fold(
        topLevel,
        (key, nameOrIndex) => key.childKey(nameOrIndex),
      ));

  /// Parses an accessor key.
  ///
  /// A standard dotted key is also an accessor key. However, there is
  /// additional syntax for identifying array items.
  static TomlAccessorKey parse(String input) => parser
      .surroundedBy(tomlWhitespace)
      .end()
      .parse(input)
      .valueOrTomlException;

  /// Constructs a new key from the given object.
  ///
  /// The [other] object can be
  ///
  ///  * another [TomlAccessorKey] which is returned unchanged,
  ///  * an iterator of `String`s and `int`s which each identify a part of
  ///    the key (see [parts] and [childKey]) or
  ///  * a string which is [parse]d into an accessor key.
  static TomlAccessorKey from(dynamic other) {
    if (other is TomlAccessorKey) return other;
    if (other is Iterable) {
      return other.fold(
        topLevel,
        (parentKey, nameOrIndex) => parentKey.childKey(nameOrIndex),
      );
    }
    if (other is String) return TomlAccessorKey.parse(other);

    throw "TODO";
  }

  /// The parts of of this key.
  ///
  /// The root key does not consist of any parts.
  /// All other keys consists of the parts of the parent key followed
  /// by a `String` for [TomlNameAccessorKey]s and an `int` for
  /// [TomlIndexAccessorKey]s.
  Iterable<dynamic> get parts;

  /// The key that identifies the accessor that the accessor identified by this
  /// key is a child of.
  ///
  /// If this key is an array index, the parent key must identify an array
  /// node. If this key is a name, the parent key must identify a table node.
  TomlAccessorKey get parentKey;

  /// Creates a new key where the [parentKey] has been replaces with the given
  /// new key.
  TomlAccessorKey withParentKey(TomlAccessorKey newParentKey);

  /// Creates a new key that identifies a child of the accessor identified
  /// by this key.
  ///
  /// If the given argument is a string, a [TomlNameAccessorKey] is created.
  /// If the given argument is an integer, a [TomlIndexAccessorKey] is created.
  /// Otherwiese, this method fails.
  TomlAccessorKey childKey(dynamic nameOrIndex) {
    if (nameOrIndex is String) return TomlNameAccessorKey(this, nameOrIndex);
    if (nameOrIndex is int) return TomlIndexAccessorKey(this, nameOrIndex);
    throw "TODO";
  }

  /// Creates a new key that identifies a descendant of the accessor identified
  /// by this key.
  ///
  /// The [topLevel] key in the given [childKey] is replaced by this key.
  TomlAccessorKey deepChildKey(TomlAccessorKey childKey) {
    if (childKey is TomlRootAccessorKey) return this;
    return childKey.withParentKey(deepChildKey(childKey.parentKey));
  }

  /// Invokes the correct `visit*` method for this accessor of the given
  /// visitor.
  R acceptKeyVisitor<R>(TomlAccessorKeyVisitor<R> visitor);

  @override
  String toString() {
    var printer = TomlAccessorKeyPrinter();
    acceptKeyVisitor(printer);
    return printer.toString();
  }
}

/// A key that identifies the root node of the accessor data structure.
class TomlRootAccessorKey extends TomlAccessorKey {
  /// The only instance of this class is [TomlAccessorKey.topLevel].
  TomlRootAccessorKey._();

  @override
  Iterable<dynamic> get parts => [];

  @override
  TomlAccessorKey get parentKey => this;

  @override
  TomlAccessorKey withParentKey(TomlAccessorKey newParentKey) => newParentKey;

  @override
  R acceptKeyVisitor<R>(TomlAccessorKeyVisitor<R> visitor) =>
      visitor.visitRootKey(this);
}

/// A key that identifies a child node of a table accessor.
class TomlNameAccessorKey extends TomlAccessorKey {
  /// Parser for a name key that is not prefixed with a dot.
  ///
  ///     unprefixed-name-accessor-key = simple-key
  static final Parser<String> unprefixedParser =
      TomlSimpleKey.parser.map((key) => key.name);

  /// Parser for a name key prefixed with a dot.
  ///
  ///     prefixed-name-accessor-key = dot-sep unprefixed-name-accessor-key
  static final Parser<String> prefixedParser = char(TomlKey.separator)
      .surroundedBy(tomlWhitespace)
      .before(unprefixedParser);

  @override
  Iterable<dynamic> get parts sync* {
    yield* parentKey.parts;
    yield name;
  }

  @override
  final TomlAccessorKey parentKey;

  /// The name of the child node identified by this key.
  final String name;

  /// Creates a new key that identifies the child with the given [name] of
  /// the table accessor identified by the given [parentKey].
  TomlNameAccessorKey(this.parentKey, this.name);

  @override
  TomlAccessorKey withParentKey(TomlAccessorKey newParentKey) =>
      TomlNameAccessorKey(newParentKey, name);

  @override
  R acceptKeyVisitor<R>(TomlAccessorKeyVisitor<R> visitor) =>
      visitor.visitNameKey(this);
}

/// A key that identifies an item of an array accessor.
class TomlIndexAccessorKey extends TomlAccessorKey {
  /// Parser for an index key.
  ///
  ///     index-accessor-key = ws array-open ws integer ws array-close
  static final Parser<int> parser = tomlWhitespace.before(TomlInteger.parser
      .surroundedBy(tomlWhitespace)
      .surroundedBy(
        char(TomlArray.openingDelimiter),
        char(TomlArray.closingDelimiter),
      )
      .map((index) => index.value.toInt()));

  @override
  Iterable<dynamic> get parts sync* {
    yield* parentKey.parts;
    yield index;
  }

  @override
  final TomlAccessorKey parentKey;

  /// The index of the array item identified by this key.
  final int index;

  /// Creates a new key that identifies the item at the given [index] of the
  /// array accessor identified by the given [parentKey].
  TomlIndexAccessorKey(this.parentKey, this.index);

  @override
  TomlAccessorKey withParentKey(TomlAccessorKey newParentKey) =>
      TomlIndexAccessorKey(newParentKey, index);

  @override
  R acceptKeyVisitor<R>(TomlAccessorKeyVisitor<R> visitor) =>
      visitor.visitIndexKey(this);
}

/// A key that has a mutable reference to another key and delegates all
/// method calls to the other key.
///
/// This is used as the node name of accessor nodes
class TomlSettableAccessorKey extends TomlAccessorKey {
  /// Another key to delegate all method calls to.
  TomlAccessorKey delegate = TomlAccessorKey.topLevel;

  @override
  R acceptKeyVisitor<R>(TomlAccessorKeyVisitor<R> visitor) =>
      delegate.acceptKeyVisitor(visitor);

  @override
  Iterable<dynamic> get parts => delegate.parts;

  @override
  TomlAccessorKey get parentKey => delegate.parentKey;

  @override
  TomlAccessorKey withParentKey(TomlAccessorKey newParentKey) =>
      delegate.withParentKey(newParentKey);
}
