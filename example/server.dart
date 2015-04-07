// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.example.server;

import 'package:toml/loader.dart';

void main() {
  useFilesystemConfigLoader();
  loadConfig('config.toml').then(
    (Map config) {
      print(config['table']['array'][0]['key']);
    }
  ).catchError((error) => print(error));
}