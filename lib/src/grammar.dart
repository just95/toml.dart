// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.grammar;

import 'package:petitparser/petitparser.dart';

/// The grammar definition of TOML.
class TomlGrammar extends GrammarDefinition {
  
  /// Specified escape sequences.
  /// 
  /// Additionally any unicode character may be escaped with the `\uXXXX`
  /// and `\UXXXXXXXX` forms.
  static final Map<String, int> escTable = {
     'b': 0x08,
     't': 0x09,
     'n': 0x0A,
     'f': 0x0C,
     'r': 0x0D,
     '"': 0x22,
     '/': 0x2F,
    r'\': 0x5C
  };
  
  /// Cache for [reverseEscTable].
  static Map<int, String> _reverseEscTable;
  
  /// Gets the reverse of [escTable].
  static Map<int, String> get reverseEscTable {
    if (_reverseEscTable == null) {
      _reverseEscTable = {};
      escTable.forEach((k, v) {
        _reverseEscTable[v] = k;
      });
    }
    return _reverseEscTable;
  }
  
  start() => ref(document).end();
  token(p, [bool multiLineLeft = false, bool multiLineRight]) {
    // multiLineRight defaults to the value of multiLineLeft
    if (multiLineRight == null) multiLineRight = multiLineLeft;
    
    // wrap functions
    if (p is Function) p = ref(p);
    
    return p.flatten().trim(
      ref(ignore, multiLineLeft),
      ref(ignore, multiLineRight)
    ); 
  }

  // -----------------------------------------------------------------
  // Whitespace and comments.
  // -----------------------------------------------------------------
  
  ignore([bool multiLine = false]) => 
      multiLine ?
        ref(ignore) | ref(newline) :
        ref(whitespace) | ref(comment);
  
  whitespace() => char(' ') | 
                  char('\t');
  newline() => char('\n') | 
               char('\r') & char('\n');

  comment() => char('#') & ref(newline).neg().star();
  
  // -----------------------------------------------------------------
  // Values.
  // -----------------------------------------------------------------
  
  value() => ref(datetime) | 
             ref(float) | 
             ref(integer) | 
             ref(boolean) | 
             ref(str) | 
             ref(array);

  // -----------------------------------------------------------------
  // String values.
  // -----------------------------------------------------------------

  /// Generates a new parser for a string.
  /// 
  /// A string is delimited by a pair of [quotes] and contains any charcters
  /// but [quotes].
  /// [newline]s are only allowed if [multiline] is set to `true`.
  /// Special characters can be expressed using [esc]ape sequences.
  /// The first line of a [multiline] string is skipped if it is empty.
  Parser _str({Parser quotes, Parser esc, bool multiline: false}) {    
    var start = quotes;    
    
    // Skip first line if it is empty.
    if (multiline) start = (start & ref(emptyLine).optional()).pick(0);
    
    // No quotes within strings.
    var forbidden = quotes;
    
    // Allow newline only for multiLine strings.
    if (!multiline) forbidden |= ref(newline);
    
    var char = forbidden.neg();
    
    // Allow escape sequences.
    if (esc != null) char = esc | char;
        
    return (start & char.star() & quotes).trim(ref(ignore)).pick(1).map(
        (List chars) => chars.join());
  }
  
  str() => ref(multiLineBasicStr) | 
           ref(basicStr) | 
           ref(multiLineLiteralStr) | 
           ref(literalStr);
  
  // -----------------------------------------------------------------
  // Basic strings.
  // -----------------------------------------------------------------

  basicStr() => _str(
      quotes: char('"'),
      esc: ref(escSeq));
  
  escSeq() => char('\\') & (ref(unicodeEscSeq) | ref(simpleEscSeq));
  
  unicodeEscSeq() => char('u') & ref(hexDigit).times(4).flatten() | 
                     char('U') & ref(hexDigit).times(8).flatten();
  simpleEscSeq() => any();
  
  hexDigit() => pattern('0-9a-fA-F');
  
  // -----------------------------------------------------------------
  // Multi-line basic strings.
  // -----------------------------------------------------------------

  multiLineBasicStr() => _str(
      quotes: string('"""'),
      esc: ref(multiLineEscSeq),
      multiline: true);

  multiLineEscSeq() => ref(whitespaceEscSeq) | 
                       ref(escSeq);
  
  whitespaceEscSeq() => char('\\') & 
                        ref(emptyLine).plus() & 
                        ref(whitespace).star();
  
  emptyLine() => ref(whitespace).star() & ref(newline);
  
  // -----------------------------------------------------------------
  // Literal strings.
  // -----------------------------------------------------------------

  literalStr() => _str(
      quotes: string("'"));

  // -----------------------------------------------------------------
  // Multi-line literal strings.
  // -----------------------------------------------------------------

  multiLineLiteralStr() => _str(
      quotes: string("'''"),
      multiline: true);
  
  // -----------------------------------------------------------------
  // Integer values.
  // -----------------------------------------------------------------
  
  integer() => ref(token, _integer);  
  _integer() => anyIn('+-').optional() & 
                char('0').or(digit().plus());

  // -----------------------------------------------------------------
  // Float values.
  // -----------------------------------------------------------------
  
  float() => ref(token, _float);
  _float() => ref(_integer) & (
                ref(fractionalPart) & ref(exponentPart).optional() | 
                ref(exponentPart)
              );
  
  fractionalPart() => char('.') & digit().plus();
  exponentPart() => anyIn('eE') & ref(_integer);

  // -----------------------------------------------------------------
  // Boolean values.
  // -----------------------------------------------------------------
  
  boolean() => ref(token, _boolean);
  _boolean() => string('true') | 
                string('false');

  // -----------------------------------------------------------------
  // Datetime values. (RFC 3339)
  // -----------------------------------------------------------------
   
  datetime() => ref(token, _datetime);
  _datetime() => ref(fullDate) & char('T') & ref(fullTime);
  
  fullDate() => ref(dddd) & char('-') & 
                ref(dd) & char('-') & 
                ref(dd);
  
  fullTime() => ref(partialTime) & ref(timeOffset);  
  partialTime() => ref(dd) & char(':') & 
                   ref(dd) & char(':') & 
                   ref(dd) & (char('.') & digit().repeat(1, 6)).optional();
  
  timeOffset() => char('Z') | ref(timeNumOffset);
  timeNumOffset() => anyIn('+-') & ref(dd) & char(':') & ref(dd);
  
  dd() => digit().times(2);
  dddd() => digit().times(4);

  // -----------------------------------------------------------------
  // Arrays.
  // -----------------------------------------------------------------
 
  array() => arrayOf(datetime) | 
             arrayOf(float) | 
             arrayOf(integer) | 
             arrayOf(boolean) | 
             arrayOf(str) | 
             arrayOf(array);
  
  arrayOf(v) => ref(token, char('['), false, true) & 
                ref(v).separatedBy(
                    ref(token, char(','), true), 
                    optionalSeparatorAtEnd: true,
                    includeSeparators: false).optional([]) & 
                ref(token, char(']'), true, false);
  
  // -----------------------------------------------------------------
  // Tables.
  // -----------------------------------------------------------------
  
  table() => ref(tableHeader).trim(ref(ignore, true)) & 
             ref(keyValuePairs);
  tableHeader() => char('[') & ref(tableName) & char(']');
  
  // -----------------------------------------------------------------
  // Array of Tables.
  // -----------------------------------------------------------------

  tableArray() => ref(tableArrayHeader).trim(ref(ignore, true)) & 
                  ref(keyValuePairs);
  tableArrayHeader() => char('[') & ref(tableHeader) & char(']');
  
  // -----------------------------------------------------------------
  // Keys.
  // -----------------------------------------------------------------
  
  key() => ref(token, bareKey) | 
           ref(quotedKey);
 
  bareKey() => pattern('A-Za-z0-9_-').plus();
  quotedKey() => ref(basicStr);
  
  tableName() => ref(key).separatedBy(
      char('.'), 
      includeSeparators: false);
      
  // -----------------------------------------------------------------
  // Key/value pairs.
  // -----------------------------------------------------------------
  
  keyValuePair() => ref(key) & char('=') & ref(value);
  keyValuePairs() => ref(keyValuePair).separatedBy(
                         ref(newline) & ref(ignore, true).star(),
                         includeSeparators: false,
                         optionalSeparatorAtEnd: true).optional([]);
  
  // -----------------------------------------------------------------
  // Document.
  // -----------------------------------------------------------------
  
  document() => ref(ignore, true).star() & 
                ref(keyValuePairs) & 
                (ref(table) | ref(tableArray)).star();
  
}
