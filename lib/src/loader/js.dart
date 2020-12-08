// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.loader.http;

import 'dart:async';
import 'dart:html';

/// Loads a configuration file from the server via HTTP using `dart:html`.
Future<String> loadFile(String filename) => HttpRequest.getString(filename);
