// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

import 'package:toml/ast.dart';

/// The contents of the TOML document to parse.
const String toml = '''
[table]
  [[table.array]]
  key = "Hello, World!"
''';

void main() {
  var config = TomlDocument.parse(toml).toMap();
  print(config['table']['array'][0]['key']);
}
