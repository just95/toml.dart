// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.decoder.toml;

import 'package:toml/decoder.dart';

/// Implementation of [ConfigDecoder] which handels the TOML format.
class TomlConfigDecoder implements ConfigDecoder {
  /// The parser used by [decodeConfig].
  static final TomlParser parser = new TomlParser();

  @override
  Map<String, dynamic> decodeConfig(String contents) =>
      parser.parse(contents).value;
}
