// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.loader;

import 'dart:async';
import 'dart:convert' deferred as convert;

import 'package:yaml/yaml.dart' deferred as yaml;
import 'package:path/path.dart';

import 'toml.dart';
import 'loader/http.dart' deferred as http;
import 'loader/fs.dart' deferred as fs;

/// Interface for configuration file loaders.
abstract class ConfigLoader {

  /// Sets [loader] as the the default instance of this interface.
  ///
  /// [loader] must be either an instance or future of [ConfigLoader].
  /// Throws an exception if the default instance has been set already.
  static void use(loader) {
    _defaultInstance.complete(loader);
  }
  static final _defaultInstance = new Completer<ConfigLoader>();

  /// Loads the specified file and returns a future of its contents.
  Future<String> loadConfig(String filename);
}

/// Configures [loadConfig] to load files via HTTP.
///
/// This function is deprecated. You should use [http.HttpConfigLoader.use]
/// instead.
@deprecated
Future useHttpConfigLoader() async {
  ConfigLoader.use(http.loadLibrary().then((_) => new http.HttpConfigLoader()));
}

/// Configures [loadConfig] to load files from the local file system.
///
/// This function is deprecated. You should use
/// [fs.FilesystemConfigLoader.use] instead.
@deprecated
Future useFilesystemConfigLoader() async {
  ConfigLoader.use(fs.loadLibrary().then(
      (_) => new fs.FilesystemConfigLoader()));
}

/// Configures [loadConfig] to load files using a custom [loader].
///
/// This function is deprecated. You should use [ConfigLoader.use] or write
/// your own static `use` method.
@deprecated
void useCustomConfigLoader(ConfigLoader loader) {
  ConfigLoader.use(loader);
}

/// Loads [filename] using the default loader and parses the contents as either
/// a TOML, YAML or JSON document depending on the file extension.
///
/// Returns a Future of the loaded configuration file.
/// The Future fails if no loader was set, the file could not be loaded or if
/// it has any syntax errors.
Future<Map> loadConfig([String filename = 'config.toml']) async {
  var loader = await ConfigLoader._defaultInstance.future;
  var contents = loader.loadConfig(filename);
  switch (extension(filename)) {
    case '.json':
      await convert.loadLibrary();
      return convert.JSON.decode(await contents);
    case '.yaml':
      await yaml.loadLibrary();
      return yaml.loadYaml(await contents);
    case '.toml':
    default:
      var parser = new TomlParser();
      return parser.parse(await contents).value;
  }
}
