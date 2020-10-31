// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.parser.util.join;

import 'package:petitparser/petitparser.dart';

/// An extension for parsers that adds an operation for concatenating the
/// string representations of the parse results for parsers that produce
/// lists.
extension JoinParserExtension<T> on Parser<List<T>> {
  /// Returns a parser that concatenates the string representation for of the
  /// parse results of this parser.
  Parser<String> join([String separator = '']) =>
      map((items) => items.join(separator));
}
