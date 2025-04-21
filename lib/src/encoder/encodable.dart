/// Interface for an object which can be encoded as a TOML value or table.
abstract interface class TomlEncodableValue {
  /// Converts this object to an object which can natively be represented as
  /// a TOML value or table.
  ///
  /// If a [TomlEncodableValue] is returned from this method, it is converted
  /// recursively by the encoder.
  dynamic toTomlValue();
}

/// Interface for an object which can be encoded as a TOML key.
///
/// This interface extends the [TomlEncodableValue] interface since a value
/// that can be encoded as a TOML key, can always also be encoded as a TOML
/// value since keys are strings and strings are TOML values.
///
/// An object can have two different representations depending on whether it is
/// used as a key or a value. Use [TomlEncodableKeyMixin] if the key
/// representation is the same as the value representation.
abstract interface class TomlEncodableKey extends TomlEncodableValue {
  /// Like [toTomlValue] but is invoked when the object is used as a key
  /// of a `Map` instead of as a value.
  dynamic toTomlKey();
}

/// Mixin for [TomlEncodableKey]s whose key representation is the same as
/// their value representation.
mixin TomlEncodableKeyMixin implements TomlEncodableKey {
  @override
  dynamic toTomlKey() => toTomlValue();
}
