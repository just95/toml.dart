library toml.src.encoder.encodable;

/// Interface for an object which can be encoded as a TOML value or table.
abstract class TomlEncodableValue {
  /// Constant default constructor to allow subclasses with `const`
  /// constructors.
  const TomlEncodableValue();

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
/// An object can have to different representations depending on whether it is
/// used as a key or a value. By default the object is converted using
/// [toTomlValue] in both cases. You have to `extend` or `mixin` this interface
/// in order to use the default implementation of [toTomlKey].
abstract class TomlEncodableKey extends TomlEncodableValue {
  /// Constant default constructor to allow subclasses with `const`
  /// constructors.
  const TomlEncodableKey();

  /// Like [toTomlValue] but is invoked when the object is used as a key
  /// of a `Map` instead of as a value.
  dynamic toTomlKey() => toTomlValue();
}
