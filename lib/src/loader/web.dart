library toml.src.loader.web;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'exception/unexpected_http_status.dart';

/// Loads a configuration file from the server via HTTP using `package:web`.
Future<String> loadFile(String filename) async {
  var response = await web.window.fetch(filename.toJS).toDart;
  if (!response.ok) {
    throw TomlUnexpectedHttpStatusException(
      response.status,
      response.statusText,
    );
  }

  // Instead of using `response.text()` to get the string, we use
  // `response.bytes()` to get the raw bytes and decode them ourselves
  // to ensure that an exception is thrown if the file is not a valid UTF-8.
  var buffer = await response.bytes().toDart;
  return utf8.decode(buffer.toDart);
}

/// Throws an [UnsupportedError] because loading configuration files
/// synchronously via HTTP is not supported using `package:web`.
String loadFileSync(String filename) =>
    throw UnsupportedError(
      'Cannot load file "$filename" synchronously: Configuration files cannot '
      'be loaded synchronously on the web.',
    );
