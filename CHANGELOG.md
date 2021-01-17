# Changelog

## 0.7.0

This is a major update that does not only bring along many changes to the internal architecture of the library but also to its public interface.

- Removed the `TomlParser` class.
  Use `TomlDocument.parse` and `TomlDocument.toMap` instead.
- In preparation to support TOML v0.5.0 in an upcoming version of the library, the parser is now based on TOML's official ABNF.
- Removed the `TomlEncoder` class.
  Use `TomlDocument.fromMap` and `TomlDocument.toString` instead.
- Removed the `toml.decoder` and `toml.encoder` libraries.
  You should always use the `toml` library instead.
- Removed the `toml.loader` library as well as the `toml.loader.*` libraries.
  Use `TomlDocument.load` instead.
  In order to implement a custom loading mechanism, use `TomlDocument.parse` instead.
- Removed the `yaml` dependency.
  JSON and YAML documents cannot be loaded with this package anymore.
- Renamed `TomlEncodable` to `TomlEncodableValue` and `toToml` to `toTomlValue`.
- Added `TomlEncodableKey` interface.
  Objects that implement this interface are allowed to be used as keys in hash maps instead of strings.
  Their `toTomlKey` method must return a `TomlEncodeableKey` itself or a string that can be used as a TOML key.
  By default `toTomlKey` is implemented via `toTomlValue`.

## 0.6.1

- Upgraded dependencies.

## 0.6.0

- Upgraded to Dart 2.

## 0.5.1

- Upgraded dependencies.

## 0.5.0

- Removed deprecated `use*ConfigLoader` functions.
- Improved testing and added support for BurntSushi's [`toml-test`][toml-test] suite.

## 0.4.0

- Removed deprecated `toml.browser` and `toml.server` libraries.
- Dropped support for `dart_config`. There is now a custom `ConfigLoader` interface with two default implementations.
- The `use*ConfigLoader` functions are still available for backward compatibility, but are deprecated and will be removed in the next release.
  Each of the `ConfigLoader` implementations has a static `use` method which you should use instead.

## 0.3.0

- Introduced new `toml.loader` library.
- The `toml.browser` and `toml.server` libraries are now deprecated and will be removed in the next release. Use the new `toml.loader` library instead.

## 0.2.0

- Updated to v0.4.0 of the TOML spec.
- Added bare/quoted keys.
- Added inline table syntax.
- Allowed underscores in numbers.
- Removed forward slash as an escapable character.

## 0.1.1

- Fixed links and markdown.

## 0.1.0

- Initial version, implements v0.3.1 of the TOML spec.

[toml-test]:
  https://github.com/BurntSushi/toml-test
  "A language agnostic test suite for TOML parsers."
