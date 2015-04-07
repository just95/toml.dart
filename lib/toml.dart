// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml;

import 'package:petitparser/petitparser.dart';

import 'src/parser.dart';
import 'src/value_parser.dart';

export 'src/errors.dart';

/// TOML parser.
class TomlParser extends GrammarParser {
  TomlParser() : super(new TomlParserDefinition());
}

/// TOML value parser.
///
/// Similiar to [TomlParser] but only accepts TOML values rather than entire
/// documents.
/// Indended for test purposes.
class TomlValueParser extends GrammarParser {
  TomlValueParser() : super(new TomlValueParserDefinition());
}
