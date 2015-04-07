// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.loader;

import 'dart:async';

import 'package:dart_config/config.dart';
import 'package:path/path.dart';

// Loaders:
import 'package:dart_config/loaders/config_loader_httprequest.dart' deferred
    as http;
import 'package:dart_config/loaders/config_loader_filesystem.dart' deferred
    as fs;

// Parsers:
import 'package:dart_config/parsers/config_parser_json.dart' deferred as json;
import 'package:dart_config/parsers/config_parser_yaml.dart' deferred as yaml;

import 'config.dart';

Future<ConfigLoader> _loader;

/// Configures [loadConfig] to load files via HTTP.
void useHttpConfigLoader() {
  _loader = http.loadLibrary().then((_) => new http.ConfigHttpRequestLoader());
}

/// Configures [loadConfig] to load files from the local filesystem.
void useFilesystemConfigLoader() {
  _loader = fs.loadLibrary().then((_) => new fs.ConfigFilesystemLoader());
}

/// Configures [loadConfig] to load files using a custom [loader].
void useCustomConfigLoader(ConfigLoader loader) {
  _loader = new Future.value(loader);
}

/// Loads [filename] using the configured loader and parses the contents using
/// the specified [parser].
///
/// If no [parser] was specified the document will be parsed as TOML, YAML or
/// JSON depending on the file extension. By default it is parsed as a
/// TOML document.
///
/// Returns a Future of the loaded configuration file.
/// The Future fails if no loader was set, the file could not be loaded or if
/// it has any syntax errors.
Future<Map> loadConfig(
    [String filename = 'config.toml', ConfigParser parser]) async {
  if (_loader == null) throw new StateError('No configuration loader set.');
  var loader = await _loader;

  if (parser == null) {
    switch (extension(filename)) {
      case '.json':
        await json.loadLibrary();
        parser = new json.JsonConfigParser();
        break;
      case '.yaml':
        await yaml.loadLibrary();
        parser = new yaml.YamlConfigParser();
        break;
      case '.toml':
      default:
        parser = new TomlConfigParser();
        break;
    }
  }

  var config = new Config(filename, loader, parser);
  return config.readConfig();
}
