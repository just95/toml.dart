library toml.test.accessor.matcher;

import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:toml/toml.dart';

/// The result of a 'TomlAccessorMatcher'.
///
/// Implementations of this interface encode the reason that two accessors
/// don't match such that a better error message can be provided.
abstract class TomlAccessorMismatch {
  /// The name of the node that does not match.
  TomlAccessorKey get key;

  /// Adds a description of the mismatch to the given description.
  Description describe(Description description);
}

/// A mismatch that indicates that the types of two accessors does not match.
class TomlAccessorTypeMismatch implements TomlAccessorMismatch {
  @override
  final TomlAccessorKey key;

  /// The expected type of the accessor.
  final TomlAccessorType expectedType;

  /// The actual type of the accessor.
  final TomlAccessorType actualType;

  /// Creates a new mismatch for accessors of different types.
  TomlAccessorTypeMismatch({
    required this.key,
    required this.expectedType,
    required this.actualType,
  });

  @override
  Description describe(Description description) => description.add(
        'expected ${_typeToString(expectedType)}, '
        'but got ${_typeToString(actualType)}',
      );

  /// Gets the string to use for the given type in the description of this
  /// mismatch.
  String _typeToString(TomlAccessorType type) {
    switch (type) {
      case TomlAccessorType.array:
        return 'an array';
      case TomlAccessorType.table:
        return 'a table';
      case TomlAccessorType.value:
        return 'a primitive value';
    }
  }
}

/// A mismatch that indicates that two array accessors have a different number
/// of items.
class TomlAccessorArrayLengthMismatch implements TomlAccessorMismatch {
  @override
  final TomlAccessorKey key;

  /// The expected number of items.
  final int expectedLength;

  /// The actual number of items.
  final int actualLength;

  /// Creates a new mismatch for array accessors of different length.
  TomlAccessorArrayLengthMismatch({
    required this.key,
    required this.expectedLength,
    required this.actualLength,
  });

  @override
  Description describe(Description description) =>
      description.add('expected $expectedLength items, but got $actualLength');
}

/// A mismatch that indicates that two table accessors have different key sets.
class TomlAccessorTableKeysMismatch implements TomlAccessorMismatch {
  @override
  final TomlAccessorKey key;

  /// The keys that are missing from the table.
  final Set<String> missingKeys;

  /// The keys that the table was not expected to have.
  final Set<String> unexpectedKeys;

  /// Creates a new mismatch for two table accessors that habe different key
  /// sets.
  TomlAccessorTableKeysMismatch({
    required this.key,
    required this.missingKeys,
    required this.unexpectedKeys,
  });

  @override
  Description describe(Description description) {
    if (missingKeys.isNotEmpty) {
      var missingKeyStr = missingKeys
          .map(TomlAccessorKey.topLevel.childKey)
          .map((key) => '`$key`')
          .join(', ');
      description = description.add(missingKeys.length == 1
          ? 'missing expected key $missingKeyStr'
          : 'missing expected keys $missingKeyStr');
    }
    if (unexpectedKeys.isNotEmpty) {
      if (missingKeys.isNotEmpty) {
        description.add(' and ');
      }
      var unexpectedKeysStr = unexpectedKeys
          .map(TomlAccessorKey.topLevel.childKey)
          .map((key) => '`$key`')
          .join(', ');
      description = description.add(unexpectedKeys.length == 1
          ? "didn't expect key $unexpectedKeysStr"
          : "didn't expect keys $unexpectedKeysStr");
    }
    return description;
  }
}

/// A mismatch that indicates that two values didn't match.
class TomlAccessorValueMismatch implements TomlAccessorMismatch {
  @override
  final TomlAccessorKey key;

  /// The expected value.
  final TomlValue expectedValue;

  /// The actual value.
  final TomlValue actualValue;

  /// Creates a new mismatch for two values that are not equal.
  TomlAccessorValueMismatch({
    required this.key,
    required this.expectedValue,
    required this.actualValue,
  });

  @override
  Description describe(Description description) => description
      .add('expected ')
      .addDescriptionOf(expectedValue)
      .add(', but got ')
      .addDescriptionOf(actualValue);
}

/// A custom matcher that uses the custom 'TomlAccessorEquality' to compare
/// accessors.
///
/// The [equals] matcher cannot be used because 'TomlAccessor' does not
/// override `operator ==` since it is not immutable.
class TomlAccessorMatcher extends Matcher {
  /// The accessor that is expected by this matcher.
  final TomlAccessor expected;

  /// Creates a new matcher for the given expected accessor.
  const TomlAccessorMatcher(this.expected);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! TomlAccessor) return false;
    var mismatch = _matchAccessors(item, expected);
    matchState['mismatch'] = mismatch;
    return mismatch == null;
  }

  /// Matches the given two accessors.
  TomlAccessorMismatch? _matchAccessors(
    TomlAccessor current,
    TomlAccessor other,
  ) {
    // Ensure that both nodes are of the same node type.
    if (current.type != other.type) {
      return TomlAccessorTypeMismatch(
        key: current.nodeName,
        expectedType: other.type,
        actualType: current.type,
      );
    }

    // Invoke the match method corresponding to the node type.
    return current.match(
      array: (array) => _matchArrayAccessors(array, other.expectArray()),
      table: (table) => _matchTableAccessors(table, other.expectTable()),
      value: (value) => _matchValueAccessors(value, other.expectValue()),
    );
  }

  /// Compares two array accessors.
  TomlAccessorMismatch? _matchArrayAccessors(
    TomlArrayAccessor current,
    TomlArrayAccessor other,
  ) {
    // Test whether both arrays have the same number of items.
    if (current.items.length != other.items.length) {
      return TomlAccessorArrayLengthMismatch(
        key: current.nodeName,
        expectedLength: other.items.length,
        actualLength: current.items.length,
      );
    }

    // Test whether the items match.
    return Iterable<int>.generate(current.items.length)
        .map((i) => _matchAccessors(current.items[i], other.items[i]))
        .whereNotNull()
        .firstOrNull;
  }

  /// Compares two table accessors.
  TomlAccessorMismatch? _matchTableAccessors(
    TomlTableAccessor current,
    TomlTableAccessor other,
  ) {
    // Test whether the tables have the same key set.
    var currentKeys = current.children.keys.toSet();
    var otherKeys = other.children.keys.toSet();
    if (!SetEquality().equals(currentKeys, otherKeys)) {
      return TomlAccessorTableKeysMismatch(
        key: current.nodeName,
        missingKeys: otherKeys.difference(currentKeys),
        unexpectedKeys: currentKeys.difference(otherKeys),
      );
    }

    // Test whether the values with the same key match.
    return currentKeys
        .map((key) => _matchAccessors(
              current.children[key]!,
              other.children[key]!,
            ))
        .whereNotNull()
        .firstOrNull;
  }

  /// Compares two value accessors.
  TomlAccessorMismatch? _matchValueAccessors(
    TomlValueAccessor current,
    TomlValueAccessor other,
  ) {
    if (current.valueNode != other.valueNode) {
      return TomlAccessorValueMismatch(
        key: current.nodeName,
        expectedValue: other.valueNode,
        actualValue: current.valueNode,
      );
    }
    return null;
  }

  @override
  Description describe(Description description) =>
      description.add('matching accessors');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    var mismatch = matchState['mismatch'];
    if (mismatch is! TomlAccessorMismatch) {
      return mismatchDescription.add('is not an accessor');
    }
    return mismatch.describe(mismatchDescription.add(
      mismatch.key.isTopLevelKey
          ? 'differs at top-level: '
          : 'differs at `${mismatch.key}`: ',
    ));
  }
}

/// Returns a matcher that matches if the value is equal to the given
/// [accessor] according to [TomlAccessorEquality].
TomlAccessorMatcher equalsAccessor(TomlAccessor accessor) =>
    TomlAccessorMatcher(accessor);
