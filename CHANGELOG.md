# Changelog

## Unreleased (TOML 1.1)

- Support for TOML [v1.1.0][toml-spec/v1.1.0] has been added.
  - Newlines and trailing commas are now allowed in inline tables.
  - The seconds part of offset date-times, local date-times and local times is now optional.
    - If the seconds part is omitted `TomlPartialTime.seconds` is set to `0`.
    - If a `TomlPartialTime` with `TomlPartialTime.seconds == 0` is encoded and `TomlPartialTime.secondFractions` is empty, the seconds part is omitted.
  - Added escape sequence `\e` for the escape character (`U+001B`).
  - Added escape sequence `\xHH` for code points in the range of `U+0000` to `U+00FF`.
    - The encoder will use this type of escape sequence to encode control characters in basic strings and multiline basic strings that do not have a corresponding one letter escape sequence.
- The encoder will now throw a `TomlImpossibleEscapeSequenceException` instead of a `TomlInvalidEscapeSequenceException` if it encounters a code point that cannot be represented using any supported escape sequence.
  This can happen for example, when the encoded string contains unpaired UTF-16 surrogate code points.

## 0.17.0

- Dart 3.8 is now required.

- Upgraded dependencies.

- `TomlEncodableValue` and `TomlEncodableKey` are now `interface class`es and must not be extended anymore.

  - If you have previously extended `TomlEncodableValue`, you must now use the `implements` keyword instead of `extends`.
  - If you have previously extended `TomlEncodableKey` and overwrote the `toTomlKey` method, you must now use the `implements` keyword instead of `extends`.
  - If you have previously extended `TomlEncodableKey` and used the default implementation of the `toTomlKey` method, you must now mixin `TomlEncodableKeyMixin` instead of extending `TomlEncodableKey`.

- On the web `TomlDocument.load` now uses `package:web` instead of `dart:html`.
  - If you handled exceptions from `dart:html` in your code you now have to handle the corresponding exceptions from `package:web` instead.
  - If the web server responds with an HTTP status code that is not in the range of 200-299, `TomlDocument.load` now throws a `TomlUnexpectedHttpStatusException`.

## 0.16.0

- Parsing an invalid local date, local time, local date-time or offset date-time now throws a `TomlInvalidDateTimeException` instead of an `ArgumentError`.
- Upgraded dependencies.

## 0.15.0

- Dart 3.2 is now required.
- Upgraded dependencies.

## 0.14.0

- Dart 2.18 is now required.
- Upgraded dependencies.
- Added `TomlDocument.loadSync` to load TOML documents synchronously.
  This new method is not supported on the web.

## 0.13.1

- Downgraded `meta` dependency from `^1.8.0` to `^1.7.0` for compatibility with Flutter `3.0.1`.

## 0.13.0

- Dart 2.17 is now required.
- Upgraded dependencies.
- Removed dependency on `package:quiver` in favor of `package:collection` and Dart 2.14's `Object.hash` and `Object.hashAll` methods.

## 0.12.0

- Dart 2.13 is now required.
- Upgraded dependencies.
- Added support for 1.0.0 compliant version of `toml-test` test suite.
- Fixed parsing of multi-line literal and multi-line basic strings with up to two (unescaped) double quotes or single quotes before the closing delimiter.
- Fixed immutability of AST.
  The AST is intended to be immutable, but `List` properties of the AST were only ungrowable not unmodifiable.

## 0.11.0

- Disallowed non-scalar Unicode values when encoding (multiline) basic strings.
  - Added `TomlBasicString.canEncode` and `TomlMultilineBasicString.canEncode`.
  - The constructors of `TomlBasicString` and `TomlMultilineBasicString` methods throw an `ArgumentError` if a string cannot be encoded.
  - The `TomlBasicString.escape` and `TomlMultilineBasicString.escape` methods throw a `TomlInvalidEscapeSequenceException` if a string cannot be encoded.
- Fixed `hashCode` and `operator ==` of some AST nodes.
  - Two `TomlDocument`s with equal expressions now have the same hash codes.
  - Two `TomlPartialTime`s with equal fractional seconds now have the same hash code.
  - Two `TomlFloat`s that both represent a `nan` value are now considered equal.
- Added `TomlSimpleKey.from` factory method.
- Allowed leading and trailing whitespace in `TomlKey.parse`.
- Fixed `TomlKey.parentKey` for `TomlKey.topLevel`.
- Removed unused getter `TomlArray.itemTypes`.
- Removed redundant `TomlKeyVisitor` interface.
- Improved error messages.
- Upgraded dependencies.

## 0.10.0

- Added support for null-safety.
  - Dart 2.12 is now required.

## 0.9.1

- Fixed pretty-printing of Windows line endings in multiline basic strings.
  The `\r` in a `\r\n` sequence is not escaped anymore.
  A carriage return that is not followed by a line feed is still escaped.
- Fixed parsing of multiline basic strings with Windows newlines.
  A `\r\n` sequence caused a runtime type error in previous releases because it was represented as a `List` instead of a `String` internally.

## 0.9.0

- Updated to [v1.0.0][toml-spec/v1.0.0] of the TOML specification.
  - Allowed leading zeros in exponent part.
  - Allowed heterogeneous arrays.
  - Disallowed tables created by dotted key/value pairs to be redefined in `[table]` form and vice versa.

## 0.8.0

- Updated to [v0.5.0][toml-spec/v0.5.0] of the TOML specification.
  - Added binary, octal and hexadecimal integer notation.
  - Added special floating point values `inf` and `nan`.
  - Added offset date-times, local date-times, local dates and local times.
    - The decoder produces `TomlOffsetDateTime`, `TomlLocalDateTime`, `TomlLocalDate` or `TomlLocalTime` values.
      There are methods to map `TomlOffsetDateTime` to a `DateTime`.
      To convert the other values to `DateTime`s, missing information such as date, time or offset has to be provided by the application.
    - UTC and local `DateTime`s are now encoded as offset date-times.
- Added support for `BigInt`s.

## 0.7.0

This is a major update that does not only bring along many changes to the internal architecture of the library but also to its public interface.

- Removed the `TomlParser` class.
  Use `TomlDocument.parse` and `TomlDocument.toMap` instead.
- In preparation to support TOML [v0.5.0][toml-spec/v0.5.0] in an upcoming version of the library, the parser is now based on TOML's official ABNF.
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

- Updated to [v0.4.0][toml-spec/v0.4.0] of the TOML specification.
- Added bare/quoted keys.
- Added inline table syntax.
- Allowed underscores in numbers.
- Removed forward slash as an escapable character.

## 0.1.1

- Fixed links and markdown.

## 0.1.0

- Initial version, implements [v0.3.1][toml-spec/v0.3.1] of the TOML specification.

[toml-spec/v0.3.1]: https://toml.io/en/v0.3.1 "TOML: English v0.3.1"
[toml-spec/v0.4.0]: https://toml.io/en/v0.4.0 "TOML: English v0.4.0"
[toml-spec/v0.5.0]: https://toml.io/en/v0.5.0 "TOML: English v0.5.0"
[toml-spec/v1.0.0]: https://toml.io/en/v1.0.0 "TOML: English v1.0.0"
[toml-spec/v1.1.0]: https://toml.io/en/v1.1.0 "TOML: English v1.1.0"
[toml-test]: https://github.com/toml-lang/toml-test "A language agnostic test suite for TOML parsers."
