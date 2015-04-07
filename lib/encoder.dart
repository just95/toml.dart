// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.encoder;

import 'src/builder.dart';
export 'src/builder.dart' show TomlEncodable;

/// TOML encoder.
class TomlEncoder {

  /// Encodes a TOML [document].
  String encode(Map<String, dynamic> document) {
    var builder = new TomlDocumentBuilder();
    builder.subTable(document, name: []);
    return builder.toString();
  }
}
