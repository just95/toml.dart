// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.decoder.json;

import 'dart:convert';

import 'package:toml/decoder.dart';

/// Implementation of [ConfigDecoder] which handels the JSON format.
class JsonConfigDecoder implements ConfigDecoder {
  @override
  Map<String, dynamic> decodeConfig(String contents) => JSON.decode(contents);
}
