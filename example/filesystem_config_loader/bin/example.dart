import 'dart:async';

import 'package:toml/toml.dart';

Future main() async {
  try {
    var document = await TomlDocument.load('config.toml');
    var config = document.toMap();
    print(config['table']['array'][0]['key']);
  } catch (e) {
    print('ERROR: $e');
  }
}
