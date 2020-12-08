// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.loader.fs;

import 'dart:async';
import 'dart:io';

/// Loads a configuration file from the local file system using `dart:io`.
Future<String> loadFile(String filename) => File(filename).readAsString();
