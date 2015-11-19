// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.loader.stream;

import 'dart:async';

import 'package:toml/loader.dart';
export 'package:toml/loader.dart' show loadConfig;

/// Implementation of the [ConfigLoader] interface which reads from a stream.
class StreamConfigLoader implements ConfigLoader {

  /// Sets an instance of this class as the default instance of [ConfigLoader].
  static void use(Stream stream) {
    ConfigLoader.use(new StreamConfigLoader(stream));
  }

  /// A stream of input data.
  final Stream<String> stream;

  StreamConfigLoader(this.stream);

  @override
  Future<String> loadConfig(String filename) => stream.join();
}
