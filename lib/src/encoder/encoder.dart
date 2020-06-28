// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.encoder;

import 'builder.dart';

/// TOML encoder.
class TomlEncoder {
  /// Encodes a TOML [document].
  String encode(Map<String, dynamic> document) {
    var builder = TomlDocumentBuilder();
    builder.encodeSubTable(document, name: []);
    return builder.toString();
  }
}
