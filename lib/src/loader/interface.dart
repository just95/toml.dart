// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

part of toml.loader;

/// Interface for configuration file loaders.
abstract class ConfigLoader {
  /// Sets [loader] as the the default instance of this interface.
  /// See also [defaultLoader].
  //
  /// Throws an exception if the default instance has been set already.
  static void use(ConfigLoader loader) {
    if (_defaultLoader != null) {
      throw new StateError('Default config loader has been set already.');
    }
    _defaultLoader = loader;
  }

  /// The instance of this interface which should be used by default
  /// by [loadConfig].
  static ConfigLoader get defaultLoader => _defaultLoader;
  static ConfigLoader _defaultLoader;

  /// Loads the specified file and returns a future of its contents.
  Future<String> loadConfig(String filename);
}
