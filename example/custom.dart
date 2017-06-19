// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.example.custom;

import 'dart:async';

import 'package:toml/loader.dart';

/// A custom implementation of the [ConfigLoader] interface that loads
/// configuration files from an internal cache.
class MyConfigLoader implements ConfigLoader {
  /// Sets an instance of this class as the default instance of [ConfigLoader].
  static void use() {
    ConfigLoader.use(new MyConfigLoader());
  }

  /// The cached configuration files by filename.
  final Map<String, String> _cache = {
    'config.toml': '''
      [table]
        [[table.array]]
        key = "Hello, World!"
    '''
  };

  @override
  Future<String> loadConfig(String filename) {
    return new Future.value(_cache[filename]);
  }
}

Future main() async {
  MyConfigLoader.use();
  try {
    var cfg = await loadConfig();
    print(cfg['table']['array'][0]['key']);
  } catch (e) {
    print('ERROR: $e');
  }
}
