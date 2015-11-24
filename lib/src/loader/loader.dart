// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

part of toml.loader;

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
