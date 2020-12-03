// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.loader.http;

import 'dart:async';
import 'dart:html';

import 'package:toml/loader.dart';

export 'package:toml/loader.dart' show loadConfig;

/// Implementation of the [ConfigLoader] interface which uses XHR to load
/// the configuration file.
class HttpConfigLoader implements ConfigLoader {
  /// Sets an instance of this class as the default instance of [ConfigLoader].
  static void use() {
    ConfigLoader.use(HttpConfigLoader());
  }

  @override
  Future<String> loadConfig(String filename) => HttpRequest.getString(filename);
}
