// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

import 'dart:convert';
import 'dart:io';

import 'package:toml/toml.dart';

Future main() async {
  var input = await stdin.transform(utf8.decoder).join();
  var config = TomlDocument.parse(input).toMap();
  print(config['table']['array'][0]['key']);
}
