// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

/// Deprecated library. You should use the new `toml.loader` library.
@deprecated
library toml.browser;

import 'dart:async';

import 'loader.dart' as loader;

/// Loads [filename] via HTTP and parses the response as a TOML document.
Future<Map> loadConfig([String filename = 'config.toml']) {
  loader.useHttpConfigLoader();
  return loader.loadConfig(filename);
}