library toml.src.loader.exception.unexpected_http_status;

import 'package:meta/meta.dart';

import '../../exception.dart';

/// An exception which is thrown when the web loader encounters an HP status
/// code that is not in the range of 200-299.
@immutable
class TomlUnexpectedHttpStatusException extends TomlException {
  /// The HTTP status code.
  final int status;

  /// A human-readable explanation of the [[status]] code.
  ///
  /// Example: "Not Found" for status code 404.
  final String statusText;

  /// Creates a new exception for an unexpected HTTP status code.
  TomlUnexpectedHttpStatusException(this.status, this.statusText);

  @override
  String get message => 'Unexpected HTTP status code: $status $statusText';

  @override
  bool operator ==(Object other) =>
      other is TomlUnexpectedHttpStatusException &&
      other.status == status &&
      other.statusText == statusText;

  @override
  int get hashCode => status ^ statusText.hashCode;
}
