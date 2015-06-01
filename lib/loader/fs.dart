// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.loader.fs;

import 'dart:async';
import 'dart:io';

import 'package:toml/loader.dart';
export 'package:toml/loader.dart' show loadConfig;

/// Implementation of the [ConfigLoader] interface which loads configuration 
/// files from the local file system.
class FilesystemConfigLoader implements ConfigLoader {

  /// Sets an instance of this class as the default instance of [ConfigLoader].
  static void use() {
    ConfigLoader.use(new FilesystemConfigLoader());
  }

  @override
  Future<String> loadConfig(String filename) => 
      new File(filename).readAsString();

}
