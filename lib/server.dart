// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.server;

import 'dart:async';

import 'package:dart_config/config.dart';
import 'package:dart_config/loaders/config_loader_filesystem.dart';

import 'config.dart';

/// Loads [filename] from the local filesystem and parses the contents as a 
/// TOML document.
Future<Map> loadConfig([String filename = "config.toml"]) {
  var config = new Config(filename,
      new ConfigFilesystemLoader(),
      new TomlConfigParser());
  
  return config.readConfig();
}