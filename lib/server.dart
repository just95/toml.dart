// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.server;

import 'dart:async';

import 'loader.dart' as loader;

/// Loads [filename] from the local filesystem and parses the contents as a 
/// TOML document.
Future<Map> loadConfig([String filename = 'config.toml']) {
  loader.useFilesystemConfigLoader();
  return loader.loadConfig(filename);
}