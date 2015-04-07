// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.example.browser;

import 'dart:html';
import 'package:toml/loader.dart';

void main() {
  useHttpConfigLoader();
  var elem = document.getElementById('text');
  loadConfig('config.toml').then(
    (Map config) {
      elem.text = config['table']['array'][0]['key'];
    }
  ).catchError((error) {
    elem.text = '$error';
  });
}