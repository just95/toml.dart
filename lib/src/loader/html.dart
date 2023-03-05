library toml.src.loader.html;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

/// Loads a configuration file from the server via HTTP using `dart:html`.
///
/// Instead of using [HttpRequest.getString] to load the file, the
/// [HttpRequest.request] method is used, such that the raw bytes of
/// the file can be loaded and decoded as UTF-8. This is necessary since
/// [HttpRequest.getString] would not throw an error when the file is
/// not a valid UTF-8 encoded document as required by the TOML specification.
Future<String> loadFile(String filename) =>
    HttpRequest.request(filename, responseType: 'arraybuffer').then((xhr) {
      var response = xhr.response as ByteBuffer;
      return utf8.decode(response.asUint8List());
    });

/// Throws an [UnsupportedError] because loading configuration files
/// synchronously via HTTP is not supported using `dart:html`.
String loadFileSync(String filename) => throw UnsupportedError(
      'Cannot load file "$filename" synchronously: Configuration files cannot '
      'be loaded synchronously on the web.',
    );
