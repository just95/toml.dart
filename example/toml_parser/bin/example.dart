import 'dart:convert';
import 'dart:io';

import 'package:toml/toml.dart';

Future main() async {
  var input = await stdin.transform(utf8.decoder).join();
  var config = TomlDocument.parse(input).toMap();
  print(config['table']['array'][0]['key']);
}
