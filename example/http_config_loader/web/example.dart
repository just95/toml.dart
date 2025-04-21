import 'dart:async';

import 'package:toml/toml.dart';
import 'package:web/web.dart' as web;

Future main() async {
  var elem = web.document.getElementById('text')! as web.HTMLElement;
  try {
    var document = await TomlDocument.load('config.toml');
    var config = document.toMap();
    elem.textContent = config['table']['array'][0]['key'].toString();
  } catch (e) {
    elem.style.color = 'red';
    elem.textContent = 'ERROR: $e';
  }
}
