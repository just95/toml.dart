// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

import 'package:toml/toml.dart';

/// Example for a class that can be encoded by the TOML encoder even though
/// it is not a TOML value.
class Point implements TomlEncodable {
  final int x, y;

  const Point(this.x, this.y);

  @override
  dynamic toToml() {
    return {'x': x, 'y': y};
  }
}

/// The map to encode as a TOML document.
const Map<String, dynamic> document = {
  'shape': {
    'type': 'rectangle',
    'points': [
      const Point(1, 1),
      const Point(1, -1),
      const Point(-1, -1),
      const Point(-1, 1)
    ],
  }
};

void main() {
  var toml = TomlDocument.fromMap(document).toString();
  print(toml);
}
