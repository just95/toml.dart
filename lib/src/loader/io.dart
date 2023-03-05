library toml.src.loader.io;

import 'dart:async';
import 'dart:io';

/// Loads a configuration file from the local file system using `dart:io`.
Future<String> loadFile(String filename) => File(filename).readAsString();

/// Synchronously Loads a configuration file from the local file system using
/// `dart:io`.
String loadFileSync(String filename) => File(filename).readAsStringSync();
