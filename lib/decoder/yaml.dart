// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.decoder.yaml;

import 'package:toml/decoder.dart';
import 'package:yaml/yaml.dart';

/// Implementation of [ConfigDecoder] which handels the YAML format.
class YamlConfigDecoder implements ConfigDecoder {
  @override
  Map<String, dynamic> decodeConfig(String contents) => loadYaml(contents);
}
