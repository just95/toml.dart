# Changelog

## 0.7.0 / Unreleased

This is a major update that does not only bring along many changes to the internal architecture of the library but also to its public interface.

- Removed the `TomlParser` class.
  Use `TomlDocument.parse` and `TomlDocument.toMap` instead.
- Removed the `TomlEncoder` class.
  Use `TomlDocument.fromMap` and `TomlDocument.toString` instead.
- Removed the `toml.loader` library.
  Use `TomlDocument.load` instead.
- Removed the `yaml` dependency.
  JSON and YAML documents cannot be loaded with this package anymore.
  Since YAML documents are needed for testing, there is still a `dep_dependency` for the `yaml` package.
- In preparation to support TOML v0.5.0 in an upcoming version of the library, the parser is now based on TOML's official ABNF.

## 0.6.1 / 2020-11-19

- Upgraded dependencies.

## 0.6.0 / 2020-05-22

- Upgraded to Dart 2.

## 0.5.1 / 2017-06-19

- Upgraded dependencies.

## 0.5.0 / 2016-07-24

- Removed deprecated `use*ConfigLoader` functions.
- Improved testing and added support for BurntSushi's [`toml-test`][toml-test] suite.

## 0.4.0 / 2015-06-05

- Removed deprecated `toml.browser` and `toml.server` libraries.
- Dropped support for `dart_config`. There is now a custom `ConfigLoader` interface with two default implementations.
- The `use*ConfigLoader` functions are still available for backward compatibility, but are deprecated and will be removed in the next release.
  Each of the `ConfigLoader` implementations has a static `use` method which you should use instead.

## 0.3.0 / 2015-04-08

- Introduced new `toml.loader` library.
- The `toml.browser` and `toml.server` libraries are now deprecated and will be removed in the next release. Use the new `toml.loader` library instead.

## 0.2.0 / 2015-02-12

- Updated to v0.4.0 of the TOML spec.
- Added bare/quoted keys.
- Added inline table syntax.
- Allowed underscores in numbers.
- Removed forward slash as an escapable character.

## 0.1.1 / 2015-01-26

- Fixed links and markdown.

## 0.1.0 / 2015-01-23

- Initial version, implements v0.3.1 of the TOML spec.

[toml-test]:
  https://github.com/BurntSushi/toml-test
  "A language agnostic test suite for TOML parsers."
