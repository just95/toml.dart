// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.config;

import 'dart:async';

import 'package:dart_config/config.dart';

import 'toml.dart';

/// Implementation of the [ConfigParser] for TOML documents.
class TomlConfigParser extends ConfigParser {

  /// Instance of [TomlParser] which is used to parse the configuration file.
  final parser = new TomlParser();

  @override
  Future<Map<String, Object>> parse(String configText) {
    return new Future.microtask(() => parser.parse(configText).value);
  }
}
