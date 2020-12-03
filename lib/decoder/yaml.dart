// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.decoder.yaml;

import 'package:toml/toml.dart';
import 'package:yaml/yaml.dart';

/// Implementation of [ConfigDecoder] which handels the YAML format.
class YamlConfigDecoder implements ConfigDecoder {
  @override
  Map<String, dynamic> decodeConfig(String contents) {
    dynamic document = loadYaml(contents);
    if (document is YamlMap) {
      if (document.keys.every((key) => key is String)) {
        return Map.fromIterables(
          document.keys.cast<String>(),
          document.values,
        );
      }
    }
    throw FormatException(
      'Expected map at top-level of YAML document, '
      'got ${document.runtimeType}',
    );
  }
}
