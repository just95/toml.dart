import 'package:toml/toml.dart';

/// Example for a class that can be encoded by the TOML encoder even though
/// it is not a TOML value.
class Point implements TomlEncodableValue {
  final int x, y;

  const Point(this.x, this.y);

  @override
  dynamic toTomlValue() {
    return {'x': x, 'y': y};
  }
}

/// The map to encode as a TOML document.
const Map<String, dynamic> document = {
  'shape': {
    'type': 'rectangle',
    'points': [Point(1, 1), Point(1, -1), Point(-1, -1), Point(-1, 1)],
  }
};

void main() {
  var toml = TomlDocument.fromMap(document).toString();
  print(toml);
}
