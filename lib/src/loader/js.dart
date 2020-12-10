library toml.src.loader.http;

import 'dart:async';
import 'dart:html';

/// Loads a configuration file from the server via HTTP using `dart:html`.
Future<String> loadFile(String filename) => HttpRequest.getString(filename);
