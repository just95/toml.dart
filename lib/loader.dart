// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.loader;

import 'dart:async';
import 'dart:convert' deferred as convert;

import 'package:yaml/yaml.dart' deferred as yaml;
import 'package:path/path.dart';

import 'decoder.dart';
import 'loader/http.dart' deferred as http;
import 'loader/fs.dart' deferred as fs;

part 'src/loader/interface.dart';
part 'src/loader/loader.dart';
