// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.example.string;

import 'package:toml/decoder.dart';

/// The contents of the toml document to parse.
const String toml = '''
[table]
  [[table.array]]
  key = "Hello, World!"
''';

void main() {
  var parser = new TomlParser();
  var result = parser.parse(toml);
  var config = result.value;
  print(config['table']['array'][0]['key']);
}
