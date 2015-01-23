// Copyright (c) 2015 Justin Andresen. All rights reserved. 
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.example.custom;

import 'dart:async';
import 'package:dart_config/config.dart';
import 'package:toml/config.dart';

class MyConfigLoader extends ConfigLoader{
  
  Map<String, String> _cache = {
    'config.yaml': '''
      [table]
        [[table.array]]
        key = "Hello, World!"
    '''
  };
  
  Future<String> loadConfig(pathOrUrl){
    return new Future.value(_cache[pathOrUrl]);
  }
  
}

void main() {
  var config = new Config(
    'config.yaml',
    new MyConfigLoader(),
    new TomlConfigParser()
  );
  config.readConfig().then(
    (Map config) {
      print(config['table']['array'][0]['key']);
    }
  ).catchError((error) => print(error));
}