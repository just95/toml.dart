library toml.src.encoder.encodable;

/// An object which can be encoded as a TOML value or table.
abstract class TomlEncodable {
  /// Converts this object to an object which can natively be represented as
  /// a TOML value or table.
  dynamic toToml();
}
