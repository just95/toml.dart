library toml.src.accessor.tree.match;

import '../../ast.dart';
import '../../exception.dart';
import '../tree.dart';
import '../visitor/tree.dart';

/// An accessor visitor whose `visit*` methods invoke callbacks.
class _TomlAccessorCallbackVisitor<R> with TomlAccessorVisitorMixin<R> {
  /// The callback to invoke when an array accessor is visited.
  final R Function(TomlArrayAccessor) arrayCallback;

  /// The callback to invoke when a table accessor is visited.
  final R Function(TomlTableAccessor) tableCallback;

  /// The callback to invoke when a value accessor is visited.
  final R Function(TomlValueAccessor) valueCallback;

  /// Creates a new visitor that invokes the callback that corresponds to
  /// the type of the visited accessor.
  _TomlAccessorCallbackVisitor({
    required this.arrayCallback,
    required this.tableCallback,
    required this.valueCallback,
  });

  @override
  R visitArrayAccessor(TomlArrayAccessor array) => arrayCallback(array);

  @override
  R visitTableAccessor(TomlTableAccessor table) => tableCallback(table);

  @override
  R visitValueAccessor(TomlValueAccessor value) => valueCallback(value);
}

/// A value visitor whose `visit*` methods invoke callbacks.
class _TomlValueCallbackVisitor<R>
    with TomlPrimitiveValueVisitorMixin<R>, TomlDateTimeVisitorMixin<R> {
  /// The callback to invoke when a boolean is visited.
  final R Function(TomlBoolean) booleanCallback;

  /// The callback to invoke when a float is visited.
  final R Function(TomlFloat) floatCallback;

  /// The callback to invoke when an integer is visited.
  final R Function(TomlInteger) integerCallback;

  /// The callback to invoke when a string is visited.
  final R Function(TomlString) stringCallback;

  /// The callback to invoke when an offset date-time is visited.
  final R Function(TomlOffsetDateTime) offsetDateTimeCallback;

  /// The callback to invoke when a local date-time is visited.
  final R Function(TomlLocalDateTime) localDateTimeCallback;

  /// The callback to invoke when a local date is visited.
  final R Function(TomlLocalDate) localDateCallback;

  /// The callback to invoke when a local time is visited.
  final R Function(TomlLocalTime) localTimeCallback;

  /// Creates a new visitor that invokes the callback that corresponds to
  /// the type of the visited value.
  _TomlValueCallbackVisitor({
    required this.booleanCallback,
    required this.floatCallback,
    required this.integerCallback,
    required this.stringCallback,
    required this.offsetDateTimeCallback,
    required this.localDateTimeCallback,
    required this.localDateCallback,
    required this.localTimeCallback,
  });

  @override
  R visitBoolean(TomlBoolean boolean) => booleanCallback(boolean);

  @override
  R visitFloat(TomlFloat float) => floatCallback(float);

  @override
  R visitInteger(TomlInteger integer) => integerCallback(integer);

  @override
  R visitString(TomlString string) => stringCallback(string);

  @override
  R visitOffsetDateTime(TomlOffsetDateTime offsetDateTime) =>
      offsetDateTimeCallback(offsetDateTime);

  @override
  R visitLocalDate(TomlLocalDate localDate) => localDateCallback(localDate);

  @override
  R visitLocalDateTime(TomlLocalDateTime localDateTime) =>
      localDateTimeCallback(localDateTime);

  @override
  R visitLocalTime(TomlLocalTime localTime) => localTimeCallback(localTime);
}

/// An extension that adds a method for pattern matching to accessors.
extension TomlAccessorMatchExtension on TomlAccessor {
  /// Performs pattern matching on this accessor.
  ///
  /// Invokes the callback whose run-time type best matches the run-time type
  /// of this accessor and returns its result. All callbacks are optional.
  ///
  /// When this accessor is a [TomlArrayAccessor] or [TomlTableAccessor], the
  /// [array] and [table] callbacks are invoked, respectively.
  ///
  /// When this accessor is a [TomlValueAccessor], based on the type of the
  /// [TomlValueAccessor.valueNode] one of the following callbacks is invoked:
  ///   - [boolean],
  ///   - [integer],
  ///   - [float],
  ///   - [string],
  ///   - [offsetDateTime],
  ///   - [localDateTime],
  ///   - [localDate] or
  ///   - [localTime]
  /// If none of the above matches, the [TomlValueAccessor] is handled by the
  /// [value] callback.
  ///
  /// If no other callback matches, the [other] callback is invoked.
  /// If there is neither a matching callback nor an [other] callback, a
  /// [TomlValueTypeException] is thrown.
  /// The [TomlValueTypeException.expectedTypes] depend on the provided
  /// callbacks.
  R match<R>({
    R Function(TomlArrayAccessor)? array,
    R Function(TomlTableAccessor)? table,
    R Function(TomlValueAccessor)? value,
    R Function(TomlBoolean)? boolean,
    R Function(TomlInteger)? integer,
    R Function(TomlFloat)? float,
    R Function(TomlString)? string,
    R Function(TomlOffsetDateTime)? offsetDateTime,
    R Function(TomlLocalDateTime)? localDateTime,
    R Function(TomlLocalDate)? localDate,
    R Function(TomlLocalTime)? localTime,
    R Function(TomlAccessor)? other,
  }) {
    // By default a type exception is thrown when there is no matching handler.
    other ??= (accessor) {
      throw TomlValueTypeException(
        accessor.nodeName,
        expectedTypes: {
          if (array != null) TomlValueType.array,
          if (table != null) TomlValueType.table,
          if (value != null) ...TomlPrimitiveValue.types,
          if (boolean != null) TomlValueType.boolean,
          if (integer != null) TomlValueType.integer,
          if (float != null) TomlValueType.float,
          if (string != null) TomlValueType.string,
          if (offsetDateTime != null) TomlValueType.offsetDateTime,
          if (localDateTime != null) TomlValueType.localDateTime,
          if (localDate != null) TomlValueType.localDate,
          if (localTime != null) TomlValueType.localTime,
          // We do not need a case for the [other] callback, since it must have
          // been `null` for this function to be created.
        },
        actualType: accessor.type,
      );
    };

    // When a value accessor is encountered, the accessor's value node is
    // visited using the given callbacks for primitive values. If there is
    // no callback for the type of the value node, the supplied value accessor
    // or default accessor handler is invoked instead.
    var otherValueAccessor = value ?? other;
    R valueCallback(TomlValueAccessor accessor) {
      R otherValue(_) => otherValueAccessor(accessor);
      var valueVisitor = _TomlValueCallbackVisitor(
        booleanCallback: boolean ?? otherValue,
        floatCallback: float ?? otherValue,
        integerCallback: integer ?? otherValue,
        stringCallback: string ?? otherValue,
        offsetDateTimeCallback: offsetDateTime ?? otherValue,
        localDateTimeCallback: localDateTime ?? otherValue,
        localDateCallback: localDate ?? otherValue,
        localTimeCallback: localTime ?? otherValue,
      );
      return accessor.valueNode.acceptPrimitiveValueVisitor(valueVisitor);
    }

    // Visit this accessor to invoke the correct callback.
    return acceptVisitor(_TomlAccessorCallbackVisitor(
      arrayCallback: array ?? other,
      tableCallback: table ?? other,
      valueCallback: valueCallback,
    ));
  }
}
