import '../ast.dart';

/// A visitor for TOML AST nodes that converts them to a TOML formatted string.
///
/// To pretty print an AST node, call the corresponding `visit*` method.
/// To get the TOML formatted string of the visited AST node call the
/// [toString] method of the pretty printer.
class TomlPrettyPrinter
    with
        TomlVisitorMixin<void>,
        TomlExpressionVisitorMixin<void>,
        TomlSimpleKeyVisitorMixin<void>,
        TomlValueVisitorMixin<void>,
        TomlDateTimeVisitorMixin<void>,
        TomlStringVisitorMixin<void> {
  /// Buffer for constructing the TOML formatted string.
  final StringBuffer _buffer;

  /// Creates a new pretty printer for TOML AST nodes.
  TomlPrettyPrinter() : _buffer = StringBuffer();

  @override
  String toString() => _buffer.toString();

  // --------------------------------------------------------------------------
  // Utility Methods
  // --------------------------------------------------------------------------

  /// Writes the given [token] into the [_buffer] and optionally adds
  /// whitespace [before] and [after] the token.
  void _writeToken(String token, {bool before = false, bool after = false}) {
    if (before) {
      _buffer.write(' ');
    }
    _buffer.write(token);
    if (after) {
      _buffer.write(' ');
    }
  }

  /// Writes a newline sequence into the [_buffer].
  void _writeNewline() {
    _buffer.writeln();
  }

  /// Runs the given function for writing [nodes] of type [T] to the [_buffer]
  /// for every node of the given iterable and separated the nodes by running
  /// the given separator function.
  void _separatedBy<T>(
    Iterable<T> nodes, {
    required void Function(T node) write,
    required void Function(T node) writeSeparator,
  }) {
    if (nodes.isNotEmpty) {
      write(nodes.first);
      for (var node in nodes.skip(1)) {
        writeSeparator(node);
        write(node);
      }
    }
  }

  // --------------------------------------------------------------------------
  // Documents
  // --------------------------------------------------------------------------

  @override
  void visitDocument(TomlDocument document) {
    _separatedBy(
      document.expressions,
      write: visitExpression,
      writeSeparator: (next) {
        // All expressions are are on a line by themselves but there is an
        // additional blank line before every table header (except if it is
        // the very first expression of the document).
        if (next is TomlTable) _writeNewline();
        _writeNewline();
      },
    );
    // There should be a newline at the end of every file.
    _writeNewline();
  }

  // --------------------------------------------------------------------------
  // Expressions
  // --------------------------------------------------------------------------

  @override
  void visitKeyValuePair(TomlKeyValuePair pair) {
    visitKey(pair.key);
    _writeToken(TomlKeyValuePair.separator, before: true, after: true);
    visitValue(pair.value);
  }

  @override
  void visitStandardTable(TomlStandardTable table) {
    _writeToken(TomlStandardTable.openingDelimiter);
    visitKey(table.name);
    _writeToken(TomlStandardTable.closingDelimiter);
  }

  @override
  void visitArrayTable(TomlArrayTable table) {
    _writeToken(TomlArrayTable.openingDelimiter);
    visitKey(table.name);
    _writeToken(TomlArrayTable.closingDelimiter);
  }

  // --------------------------------------------------------------------------
  // Keys
  // --------------------------------------------------------------------------

  @override
  void visitKey(TomlKey key) {
    _separatedBy(
      key.parts,
      write: visitSimpleKey,
      writeSeparator: (dynamic _) => _writeToken(TomlKey.separator),
    );
  }

  @override
  void visitQuotedKey(TomlQuotedKey key) {
    visitString(key.string);
  }

  @override
  void visitUnquotedKey(TomlUnquotedKey key) {
    _buffer.write(key.name);
  }

  // --------------------------------------------------------------------------
  // Values
  // --------------------------------------------------------------------------

  @override
  void visitArray(TomlArray array) {
    _writeToken(TomlArray.openingDelimiter);
    _separatedBy(
      array.items,
      write: visitValue,
      writeSeparator: (dynamic _) =>
          _writeToken(TomlInlineTable.separator, after: true),
    );
    _writeToken(TomlArray.closingDelimiter);
  }

  @override
  void visitBoolean(TomlBoolean boolean) {
    _writeToken(boolean.value.toString());
  }

  @override
  void visitFloat(TomlFloat float) {
    if (float.value.isFinite) {
      _writeToken(float.value.toString());
      if (float.value is int) _writeToken('.0');
    } else {
      if (float.value.isNegative) _writeToken('-');
      if (float.value.isNaN) {
        _writeToken('nan');
      } else if (float.value.isInfinite) {
        _writeToken('inf');
      }
    }
  }

  @override
  void visitInlineTable(TomlInlineTable inlineTable) {
    _writeToken(
      TomlInlineTable.openingDelimiter,
      after: inlineTable.pairs.isNotEmpty,
    );
    _separatedBy(
      inlineTable.pairs,
      write: visitKeyValuePair,
      writeSeparator: (dynamic _) =>
          _writeToken(TomlInlineTable.separator, after: true),
    );
    _writeToken(
      TomlInlineTable.closingDelimiter,
      before: inlineTable.pairs.isNotEmpty,
    );
  }

  @override
  void visitInteger(TomlInteger integer) {
    _writeToken(integer.format.prefix);
    _writeToken(integer.value.toRadixString(integer.format.base));
  }

  // --------------------------------------------------------------------------
  // Date-Times
  // --------------------------------------------------------------------------

  /// Converts the given number to a string of length 4 with leading zeros.
  String _dddd(int n) {
    return n.toString().padLeft(4, '0');
  }

  /// Converts the given number to a string of length 3 with leading zeros.
  String _ddd(int n) {
    return n.toString().padLeft(3, '0');
  }

  /// Converts the given number to a string of length 2 with a leading.
  String _dd(int n) {
    return n.toString().padLeft(2, '0');
  }

  /// Prints a full date.
  void printFullDate(TomlFullDate date) {
    var yyyy = _dddd(date.year);
    var mm = _dd(date.month);
    var dd = _dd(date.day);
    _writeToken('$yyyy-$mm-$dd');
  }

  /// Prints a time without time-zone offset.
  void printPartialTime(TomlPartialTime time) {
    var h = _dd(time.hour);
    var min = _dd(time.minute);
    var sec = _dd(time.second);
    _writeToken('$h:$min:$sec');

    // Optionally add fractions of a second.
    if (time.secondFractions.isNotEmpty) _writeToken('.');
    time.secondFractions.map(_ddd).forEach(_writeToken);
  }

  /// Prints a time-zone offset.
  void printTimeZoneOffset(TomlTimeZoneOffset offset) {
    if (offset.isUtc) {
      _writeToken('Z');
    } else {
      var sign = offset.isNegative ? '-' : '+';
      var hours = _dd(offset.hours);
      var min = _dd(offset.minutes);
      _writeToken('$sign$hours:$min');
    }
  }

  @override
  void visitLocalDate(TomlLocalDate localDate) {
    printFullDate(localDate.date);
  }

  @override
  void visitLocalDateTime(TomlLocalDateTime localDateTime) {
    printFullDate(localDateTime.date);
    _writeToken(' ');
    printPartialTime(localDateTime.time);
  }

  @override
  void visitLocalTime(TomlLocalTime localTime) {
    printPartialTime(localTime.time);
  }

  @override
  void visitOffsetDateTime(TomlOffsetDateTime offsetDateTime) {
    printFullDate(offsetDateTime.date);
    _writeToken(' ');
    printPartialTime(offsetDateTime.time);
    printTimeZoneOffset(offsetDateTime.offset);
  }

  // --------------------------------------------------------------------------
  // Strings
  // --------------------------------------------------------------------------

  @override
  void visitBasicString(TomlBasicString string) {
    _writeToken(TomlBasicString.delimiter);
    _writeToken(TomlBasicString.escape(string.value));
    _writeToken(TomlBasicString.delimiter);
  }

  @override
  void visitLiteralString(TomlLiteralString string) {
    _writeToken(TomlLiteralString.delimiter);
    _writeToken(string.value);
    _writeToken(TomlLiteralString.delimiter);
  }

  @override
  void visitMultilineBasicString(TomlMultilineBasicString string) {
    _writeToken(TomlMultilineBasicString.delimiter);
    _writeNewline();
    _writeToken(TomlMultilineBasicString.escape(string.value));
    _writeToken(TomlMultilineBasicString.delimiter);
  }

  @override
  void visitMultilineLiteralString(TomlMultilineLiteralString string) {
    _writeToken(TomlMultilineLiteralString.delimiter);
    _writeNewline();
    _writeToken(string.value);
    _writeToken(TomlMultilineLiteralString.delimiter);
  }
}
