// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.errors;

/// An error which is thrown when the parser encounters an unspecified escape
/// sequence.
///
/// Example:
///     dir = "some\windows\path"
/// throws an [InvalidEscapeSequenceError] with `[escapeSequence] = r'\w'`.
class InvalidEscapeSequenceError {

  /// The invalid escape sequence.
  final String escapeSequence;

  InvalidEscapeSequenceError(this.escapeSequence);

  @override
  bool operator ==(other) => other is InvalidEscapeSequenceError &&
      other.escapeSequence == escapeSequence;

  @override
  int get hashCode => escapeSequence.hashCode;

  @override
  String toString() => 'The escape sequence "$escapeSequence" is invalid!';
}

/// An error which is thrown when the encoder encounters a character in a
/// string which cannot be represented by TOML.
class InvalidStringError {

  /// A messga which describes the error.
  final String msg;

  InvalidStringError(this.msg);

  @override
  bool operator ==(other) => other is InvalidStringError && other.msg == msg;

  @override
  int get hashCode => msg.hashCode;

  @override
  String toString() => msg;
}

/// An error which is thrown when a table or key is defined more than once.
class RedefinitionError {

  /// Fully qualified name of the table or key.
  final String name;

  RedefinitionError(this.name);

  @override
  bool operator ==(other) => other is RedefinitionError && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Cannot redefine "$name"!';
}

/// An error which is thrown when the parent element of a table is not
/// a table.
///
/// Example:
///     [a]
///     b = 1
///
///     [a.b.c]
///     d = 2
/// throws a [NotATableError] because `a.b.c` fails to create a sub-table of
/// `a.b` which is an integer rather than not a table.
class NotATableError {

  /// The name of the table which could not be created because its parent
  /// is not a table
  final String name;

  NotATableError(this.name);

  @override
  bool operator ==(other) => other is NotATableError && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Cannot define table "$name"! Parent must be a table!';
}

/// An error which is thrown when an object cannot be encoded.
///
/// Example:
///     var encoder = new TomlEncoder();
///     encoder.encode({'a': null});
/// throws an [UnknownValueTypeError] because `null` is not a valid TOML value.
class UnknownValueTypeError {

  /// The object which cannot be encoded as a TOML value.
  final value;

  UnknownValueTypeError(this.value);

  @override
  bool operator ==(other) =>
      other is UnknownValueTypeError && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '"$value" cannot be encoded as a TOMl value!';
}

/// An error which is thrown when an `Iterable` cannot be encoded as an array
/// because it does not have a unique value type.
///
/// Example:
///     var encoder = new TomlEncoder();
///     encoder.encode({'a': [1, '2']});
/// throws an [MixedArrayTypesError] because `1` and `'2'` are of different
/// types.
class MixedArrayTypesError {

  /// The array which has mixed value types.
  final Iterable array;

  MixedArrayTypesError(this.array);

  @override
  bool operator ==(other) =>
      other is MixedArrayTypesError && other.array == array;

  @override
  int get hashCode => array.hashCode;

  @override
  String toString() => 'The items of "$array" must all be of the same type!';
}
