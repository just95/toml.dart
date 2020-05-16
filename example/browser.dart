// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.example.browser;

import 'dart:async';
import 'dart:html';

import 'package:toml/loader/http.dart';

Future main() async {
  HttpConfigLoader.use();
  var elem = document.getElementById('text');
  try {
    var cfg = await loadConfig();
    elem.text = cfg['table']['array'][0]['key'].toString();
  } catch (e) {
    elem.style.color = 'red';
    elem.text = 'ERROR: $e';
  }
}
