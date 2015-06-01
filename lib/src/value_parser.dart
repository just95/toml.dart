// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.value_parser;

import 'parser.dart';

/// TOML value parser definition.
///
/// This is very similar to [TomlParserDefinition] but the start rule is set
/// such that only TOML values are accepted.
/// This class is intended for testing purposes.
class TomlValueParserDefinition extends TomlParserDefinition {
  start() => ref(value).end();
}
