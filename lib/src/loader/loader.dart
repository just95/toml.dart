// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

part of toml.loader;

/// Loads [filename] using the default loader and decodes the contents
/// with the decoder associated with the file extension.
///
/// Files with unknown extensions are treated as TOML files by default.
///
/// Returns a Future of a hash map which contains the the loaded
/// configuration options.
/// The Future fails if no loader was set, the file could not be loaded or if
/// it has any syntax errors.
Future<Map> loadConfig([String filename = 'config.toml']) async {
  final loader = ConfigLoader.defaultLoader;
  final decoder = ConfigDecoder.getByExtension(extension(filename));
  final contents = await loader.loadConfig(filename);
  return decoder.decodeConfig(contents);
}
