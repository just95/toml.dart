import 'package:meta/meta.dart';

import '../../exception.dart';

/// An exception which is thrown when the parser encounters an invalid
/// local time, local date, local date-time or offset date-time.
///
/// Example:
///
///     birthdate = 29-02-2023
///
/// throws an [TomlInvalidDateTimeException] because February 29th, 2023 does
/// not exist since 2023 has not been not a leap year.
@immutable
class TomlInvalidDateTimeException extends TomlException {
  @override
  final String message;

  /// Creates a new exception for an invalid date-time.
  ///
  /// The given [message] should describe why the date-time is invalid.
  TomlInvalidDateTimeException(this.message);

  @override
  bool operator ==(Object other) =>
      other is TomlInvalidDateTimeException && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
