// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.example.server;

import 'dart:async';

import 'package:toml/loader/fs.dart';

Future main() async {
  FilesystemConfigLoader.use();
  try {
    var cfg = await loadConfig();
    print(cfg['table']['array'][0]['key']);
  } catch (e) {
    print('ERROR: $e');
  }
}
