// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

import 'dart:async';
import 'dart:html';

import 'package:toml/toml.dart';

Future main() async {
  var elem = document.getElementById('text');
  try {
    var document = await TomlDocument.load('config.toml');
    var config = document.toMap();
    elem.text = config['table']['array'][0]['key'].toString();
  } catch (e) {
    elem.style.color = 'red';
    elem.text = 'ERROR: $e';
  }
}
