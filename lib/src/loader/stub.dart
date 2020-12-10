library toml.src.loader.interface;

import 'dart:async';

/// Implementation stub for configuration file loaders.
///
/// An implementation that uses HTTP to load the configuration file can be
/// found in `js.dart`. An implementation that uses `dart:io` can be found
/// in `io.dart`.
Future<String> loadFile(String filename) => throw UnsupportedError(
      'Cannot load file "$filename": No configuration file loader'
      'implementation is available on the current platform.',
    );
