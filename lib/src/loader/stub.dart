import 'dart:async';

/// Implementation stub for configuration file loaders.
///
/// An implementation that uses HTTP to load the configuration file can be
/// found in `html.dart`. An implementation that uses `dart:io` can be found
/// in `io.dart`.
Future<String> loadFile(String filename) =>
    throw UnsupportedError(
      'Cannot load file "$filename": No configuration file loader '
      'implementation is available on the current platform.',
    );

/// Implementation stub for synchronous configuration file loaders.
///
/// An implementation that uses `dart:io` can be in `io.dart`.
/// There is no implementation for the web.
String loadFileSync(String filename) =>
    throw UnsupportedError(
      'Cannot load file "$filename" synchronously: No synchronous '
      'configuration file loader implementation is available on the current '
      'platform.',
    );
