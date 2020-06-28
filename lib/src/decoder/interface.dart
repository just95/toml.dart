// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.decoder.interface;

import 'package:toml/decoder/json.dart';
import 'package:toml/decoder/toml.dart';
import 'package:toml/decoder/yaml.dart';

/// Interface for configuration file decoders.
///
/// There are three default implementations available to hanlde TOML, YAML and
/// JSON files. They are located in the `lib/decoder/` directory.
abstract class ConfigDecoder {
  /// The instance of this interface which should be returned by
  /// [getByExtension] if no decoder was associated with an extension.
  ///
  /// By default configuration files with unknown extensions are treated as
  /// `.toml` files.
  static ConfigDecoder defaultDecoder = TomlConfigDecoder();

  /// Associates a [decoder] with the specified file extension.
  static void register(ConfigDecoder decoder, {String extension}) {
    _byExtension[extension] = decoder;
  }

  static final Map<String, ConfigDecoder> _byExtension = {
    '.toml': TomlConfigDecoder(),
    '.yaml': YamlConfigDecoder(),
    '.json': JsonConfigDecoder()
  };

  /// Gets the decoder for a file with the specified [extension].
  ///
  /// Returns [defaultDecoder] if no decoder has been [register]ed for the
  /// specified [extension].
  ///
  /// Throws an exception if there is no [defaultDecoder].
  static ConfigDecoder getByExtension(String extension) {
    if (_byExtension.containsKey(extension)) return _byExtension[extension];
    if (defaultDecoder != null) return defaultDecoder;
    throw StateError('There is no decoder for `$extension` files.');
  }

  /// Parses the [contents] of a configuration file and returns
  /// a hash map which represents the data.
  Map<String, dynamic> decodeConfig(String contents);
}
