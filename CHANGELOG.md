# Changelog

## 0.4.0 / 2015-06-05

- Removed deprecated `toml.browser` and `toml.server` libraries.
- Dropped support for `dart_config`. There is now a custom `ConfigLoader`
  interface with two default implementations.
- The `use*ConfigLoader` functions are still available for backward
  compatibility, but are deprecated and will be removed in the next
  release. Each of the `ConfigLoader` implementations has a static `use`
  method which you should use instead.

## 0.3.0 / 2015-04-08

- Introduced new `toml.loader` library.
- The `toml.browser` and `toml.server` libraries are now deprecated and will
  be removed in the next release. Use the new `toml.loader` library instead.

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
