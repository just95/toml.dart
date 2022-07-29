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
  final TomlValueType expectedType;

  /// The actual type of the accessor.
  final TomlValueType actualType;

  /// Creates a new mismatch for accessors of different types.
  TomlAccessorTypeMismatch({
    required this.key,
    required this.expectedType,
    required this.actualType,
  });

  @override
  Description describe(Description description) => description.add(
        'expected ${expectedType.description}, '
        'but got ${actualType.description}',
      );
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

  /// Creates a new mismatch for two table accessors that have different key
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
///
/// - Two [TomlAccessor]s of different [TomlAccessor.type]s do not match.
/// - Two [TomlArrayAccessor]s of different lengths do not match.
/// - Two [TomlTableAccessor]s with different key sets do not match.
/// - Two [TomlValueAccessor]s only match if the [TomlValueAccessor.valueNode]s
///   are equal according to their implementation of `operator ==`.
class TomlAccessorMatcher extends Matcher {
  /// The accessor that is expected by this matcher.
  final TomlAccessor expected;

  /// Creates a new matcher for the given expected accessor.
  const TomlAccessorMatcher(this.expected);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! TomlAccessor) return false;
    var matcher = _TomlAccessorMatcher(expected);
    var mismatch = item.acceptVisitor(matcher);
    matchState['mismatch'] = mismatch;
    return mismatch == null;
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

/// A visitor that matches two accessors.
class _TomlAccessorMatcher
    with TomlAccessorVisitorMixin<TomlAccessorMismatch?> {
  /// The accessor that visited accessor are expected to match.
  final TomlAccessor expected;

  /// Creates a new matcher that compares accessors to the given [expected]
  /// accessor.
  _TomlAccessorMatcher(this.expected);

  @override
  TomlAccessorMismatch? visitAccessor(TomlAccessor accessor) {
    // Ensure that both nodes are of the same node type.
    if (accessor.type != expected.type) {
      return TomlAccessorTypeMismatch(
        key: accessor.nodeName,
        expectedType: expected.type,
        actualType: accessor.type,
      );
    }

    // Invoke the match method corresponding to the node type.
    return super.visitAccessor(accessor);
  }

  @override
  TomlAccessorMismatch? visitArrayAccessor(TomlArrayAccessor actualArray) {
    var expectedArray = expected.expectArray();

    // Test whether both arrays have the same number of items.
    if (actualArray.items.length != expectedArray.items.length) {
      return TomlAccessorArrayLengthMismatch(
        key: actualArray.nodeName,
        expectedLength: expectedArray.items.length,
        actualLength: actualArray.items.length,
      );
    }

    // Test whether the items match.
    return Iterable<int>.generate(actualArray.items.length)
        .map((i) {
          var actualItem = actualArray.items[i];
          var expectedItem = expectedArray.items[i];
          var matcher = _TomlAccessorMatcher(expectedItem);
          return matcher.visitAccessor(actualItem);
        })
        .whereNotNull()
        .firstOrNull;
  }

  @override
  TomlAccessorMismatch? visitTableAccessor(TomlTableAccessor actualTable) {
    var expectedTable = expected.expectTable();

    // Test whether the tables have the same key set.
    var currentKeys = actualTable.children.keys.toSet();
    var otherKeys = expectedTable.children.keys.toSet();
    if (!SetEquality().equals(currentKeys, otherKeys)) {
      return TomlAccessorTableKeysMismatch(
        key: actualTable.nodeName,
        missingKeys: otherKeys.difference(currentKeys),
        unexpectedKeys: currentKeys.difference(otherKeys),
      );
    }

    // Test whether the values with the same key match.
    return currentKeys
        .map((key) {
          // Since the key sets are the same, the lookups always succeed.
          var actualChild = actualTable.children[key]!;
          var expectedChild = expectedTable.children[key]!;
          var matcher = _TomlAccessorMatcher(expectedChild);
          return matcher.visitAccessor(actualChild);
        })
        .whereNotNull()
        .firstOrNull;
  }

  @override
  TomlAccessorMismatch? visitValueAccessor(TomlValueAccessor actualValue) {
    var expectedValue = expected.expectValue();

    if (actualValue.valueNode != expectedValue.valueNode) {
      return TomlAccessorValueMismatch(
        key: actualValue.nodeName,
        expectedValue: expectedValue.valueNode,
        actualValue: actualValue.valueNode,
      );
    }

    return null;
  }
}

/// Returns a matcher that matches if the value is equal to the given
/// [accessor] according to [TomlAccessorMatcher].
TomlAccessorMatcher equalsAccessor(TomlAccessor accessor) =>
    TomlAccessorMatcher(accessor);
