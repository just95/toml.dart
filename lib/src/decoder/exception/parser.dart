library toml.src.decoder.exception.parser;

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

import '../../exception.dart';

/// An exception which is thrown when there is an error while parsing a TOML
/// document or value.
///
/// Example:
///
///     [table
///
/// throws a [TomlParserException] because the closing bracket of the table
/// definition is missing.
@immutable
class TomlParserException extends TomlException implements FormatException {
  /// Gets the value of the given parse [result] if it represents a [Success]
  /// or throws a [TomlParserException] if it is a [Failure].
  static T fromResult<T>(Result<T> result) {
    try {
      return result.value;
    } on ParserException catch (e) {
      throw TomlParserException.from(e);
    }
  }

  @override
  final String message;

  @override
  final int offset;

  @override
  final String source;

  /// Creates a parser exception with the given message, source code and offset
  /// within the source code.
  TomlParserException({
    required this.message,
    required this.source,
    required this.offset,
  });

  /// Converts a [ParserException] from `petitparser` to a
  /// [TomlParserException].
  factory TomlParserException.from(ParserException e) => TomlParserException(
        message: e.message,
        source: e.source,
        offset: e.offset,
      );

  /// Lazily evaluated tuple of the [line] and [column].
  late final List<int> _lineAndColumn = Token.lineAndColumnOf(source, offset);

  /// The line that contains the [offset] within the [source].
  int get line => _lineAndColumn[0];

  /// The column within the [line] that corresponds to the [offset] within
  /// the [source].
  int get column => _lineAndColumn[1];

  @override
  bool operator ==(Object other) =>
      other is TomlParserException &&
      other.message == message &&
      other.offset == offset &&
      other.source == source;

  @override
  int get hashCode => Object.hash(message, offset, source);

  @override
  String toString() => 'TOML parse error: $message at $line:$column';
}

/// An extension method on parser [Result]s that adds a [valueOrTomlException]
/// method that behaves like [Result.value] but throws a [TomlParserException]
/// instead of a [ParserException] when the result is a [Failure].
extension TomlParserExceptionExtension<T> on Result<T> {
  /// Returns the parsed value of this result, or throws a TOML parser
  /// exception if this is a parse failure.
  T get valueOrTomlException => TomlParserException.fromResult(this);
}
