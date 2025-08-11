import 'package:meta/meta.dart';

import '../../exception.dart';

/// An exception which is thrown when the encoder encounters a [rune] that
/// cannot be represented using a TOML escape sequence.
///
/// Example: TODO
@immutable
class TomlImpossibleEscapeSequenceException extends TomlException {
  /// The rune that could not be encoded.
  final int rune;

  /// A human readable description of the reason why the rune could not be
  /// encoded.
  final String reason;

  /// Creates a new exception for the given unencodable [rune].
  TomlImpossibleEscapeSequenceException._({
    required this.rune,
    required this.reason,
  });

  /// Creates a new exception for a [rune] that cannot be encoded since it
  /// is not a Unicode scalar value.
  factory TomlImpossibleEscapeSequenceException.nonScalar(int rune) =>
      TomlImpossibleEscapeSequenceException._(
        rune: rune,
        reason: 'Not a Unicode scalar value',
      );

  /// Creates a new exception for a [rune] that cannot be encoded since it
  /// requires more than 8 hexadecimal digits to represent.
  factory TomlImpossibleEscapeSequenceException.tooLong(int rune) =>
      TomlImpossibleEscapeSequenceException._(
        rune: rune,
        reason: 'Requires more than 8 hexadecimal digits to represent',
      );

  @override
  bool operator ==(Object other) =>
      other is TomlImpossibleEscapeSequenceException &&
      other.rune == rune &&
      other.reason == reason;

  @override
  int get hashCode => rune.hashCode ^ reason.hashCode;

  @override
  String get message =>
      'The rune "0x${rune.toRadixString(16)}" cannot be encoded: $reason';
}
