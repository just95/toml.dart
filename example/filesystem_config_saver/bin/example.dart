import 'dart:async';
import 'dart:io';

import 'package:toml/toml.dart';

extension on TomlDocument {
  Future<void> save(String filename) {
    return File(filename).writeAsString(toString());
  }
}

Future main() async {
  try {
    var document = TomlDocument.fromMap({'key': 'Hello, World!'});
    await document.save('config.toml');
  } catch (e) {
    print('ERROR: $e');
  }
}
