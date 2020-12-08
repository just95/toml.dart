// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

import 'dart:async';

import 'package:toml/toml.dart';

Future main() async {
  try {
    var document = await TomlDocument.load('config.toml');
    var config = document.toMap();
    print(config['table']['array'][0]['key']);
  } catch (e) {
    print('ERROR: $e');
  }
}
