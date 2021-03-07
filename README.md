# toml.dart

[![Dart CI](https://github.com/just95/toml.dart/workflows/Dart%20CI/badge.svg?branch=main)][toml-dart/actions/main]
[![Coverage Status](https://coveralls.io/repos/github/just95/toml.dart/badge.svg?branch=main)][coveralls/toml-dart]
[![Pub Package](https://img.shields.io/pub/v/toml.svg)][pub/toml]
[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)][toml-dart/LICENSE]

This package provides an implementation of a [TOML][toml-spec/website] parser and encoder for Dart.

It currently supports version [1.0.0][toml-spec/v1.0.0] of the TOML specification.

## Table of Contents

 1. [Installation](#installation)
 2. [Usage](#usage)
    1. [Loading TOML](#loading-toml)
    3. [Parsing TOML](#parsing-toml)
    4. [Decoding TOML](#decoding-toml)
    5. [Encoding TOML](#encoding-toml)
 3. [Data Structure](#data-structure)
    1. [Table and Inline Table](#table-and-inline-table)
    2. [Array and Array of Tables](#array-and-array-of-tables)
    3. [String](#string)
    4. [Integer](#integer)
    5. [Float](#float)
    6. [Boolean](#boolean)
    7. [Offset Date-Time](#offset-date-time)
    8. [Local Date-Time](#local-date-time)
    9. [Local Date](#local-date)
    10. [Local Time](#local-time)
 4. [Testing](#testing)
 5. [License](#license)

## Installation

To get started add `toml` as a dependency to your `pubspec.yaml` and run the
`dart pub get` or `flutter pub get` command.

```yaml
dependencies:
  toml: "^0.10.0"
```

## Usage

The `toml.dart` package can be used for loading, decoding and encoding TOML documents.
To get started, just add the following import.

```dart
import 'package:toml/toml.dart';
```

The subsequent sections describe how to use the library in more detail.
Additional examples can be found in the [`./example`][toml-dart/example] directory.

### Loading TOML

In order to load a TOML document, invoke the static `TomlDocument.load` method and pass the name of the configuration file to load.
The method returns a `Future` of the loaded `TomlDocument`.

```dart
void main() async {
  var document = await TomlDocument.load('config.toml');
  // ...
}
```

When the code is running in the browser, HTTP is used to fetch the configuration file.
When the code is running on the Dart VM or natively, the file is loaded from
the local file system.

If the loaded TOML file contains a syntax error, a `TomlParserException` is thrown.

Full examples for loading a configuration file via HTTP and from a file can be found in [`./example/http_config_loader`][toml-dart/example/http_config_loader] and [`./example/filesystem_config_loader`][toml-dart/example/filesystem_config_loader], respectively.

### Parsing TOML

Sometimes the two default mechanisms for loading TOML documents with `TomlDocument.load` are not sufficient.
In those cases, you can simply load the contents of the configuration file yourself and parse them as a TOML document manually using the static `TomlDocument.parse` function.

```dart
void main() {
  var contents = '...';
  var document = TomlDocument.parse(contents);
  // ...
}
```

If the loaded TOML file contains a syntax error, a `TomlParserException` is thrown.

An example for writing a custom configuration file loader and parsing the loaded file manually can be found in [`./example/toml_parser`][toml-dart/example/toml_parser].

### Decoding TOML

In the last two subsections we've learned how to load or parse a `TomlDocument`.
Such a `TomlDocument` is an abstract representation of the syntax of a TOML document.
In order to access the configuration options that are stored in the TOML document, we first have to convert it to a hash map with the `TomlDocument.toMap` method.

```dart
void main() {
  var config = TomlDocument.parse('...').toMap();
  // ...
}
```

If the TOML document is semantically invalid, a `TomlException` is thrown.

In the [next section](#data-structure) the type and structure of the generated hash map will be elaborated in more detail.

### Encoding TOML

This package also includes a TOML encoder that can convert a hash map to a TOML document.
Simply use the `TomlDocument.fromMap` factory constructor to convert the hash map into the internal representation.
The resulting document can be converted to a TOML encoded string using the `toString` method.

```dart
var document = TomlDocument.fromMap({
  // ...
}).toString();
```

The type and structure of the hash map should match the format described in the [next section](#data-structure).
Additionally, the map may contain arbitrary keys and values that implement the `TomlEncodableKey` and `TomlEncodableValue` interfaces, respectively.
Classes which implement those interfaces must define a `toTomlKey` or `toTomlValue` method, whose return value is either implements the interface itself or is natively encodable by TOML.
If an object cannot be encoded as a TOML key or value, a `TomlUnknownKeyTypeException` or `TomlUnknownValueTypeException` is thrown by `TomlDocument.fromMap`.

An example for using the encoder and the `TomlEncodableValue` interface to encode a `Map` can be found in [`./example/toml_encoder`][toml-dart/example/toml_encoder].

## Data Structure

This section describes how the decoder (i.e., `TomlDocument.toMap`) maps TOML values to Dart values and which Dart values are accepted by the encoder (i.e., `TomlDocument.fromMap`).

### Table and Inline Table

TOML documents and tables including inline tables are represented through nested `Map` objects whose keys are `String`s and values `dynamic` representations of the corresponding TOML value or sub-table.

For example, given the following TOML document

```toml
[parent.table]
key = 'value'
```

the decoder produces the following `Map`.

```dart
<String, dynamic>{
  'parent': <String, dynamic>{
    'table': <String, dynamic>{'key': 'value'}
  }
}
```

The encoder does not require all keys to have the static type `String`.
A map of type `Map<MyKey, dynamic>` can be encoded, provided that the class `MyKey` implements the `TomlEncodableKey` interface.
The encoder never produces inline-tables or dotted keys at the moment.

### Array and Array of Tables

The decoder produces `List` objects for all kinds of arrays including arrays of tables.
For example, given the following TOML document

```toml
[[items]]
name = 'A'

[[items]]
name = 'B'

[[items]]
name = 'C'
```

the decoder produces the following `List`.

```dart
<String, dynamic>{
  'items': [
    <String, dynamic>{'name': 'A'},
    <String, dynamic>{'name': 'B'},
    <String, dynamic>{'name': 'C'},
  ]
}
```

The encoder accepts any `Iterable`.

### String

All string variants produce regular dart `String`s.
For example, all strings in the listing below map to the Dart value `'Hello, World!'`.

```toml
str1 = "Hello, World!"
str2 = 'Hello, World!'
str3 = """\
  Hello, \
  World!\
"""
str4 = '''
Hello, World!'''
```

The encoder preferably generates literal strings.
If a string contains apostrophes or other characters that are not allowed in literal strings, a basic string is produced instead.
Strings that contain newlines produce multiline strings.
Whether a multiline literal or multiline basic string is generated depends on the remaining characters in the string.
All produced multiline strings start with a trimmed newline and multiline basic strings never contain escaped whitespace.

If you need more control over the type of string that is produced by the encoder, you can wrap the value with a `TomlLiteralString`, `TomlBasicString`, `TomlMultilineLiteralString` or `TomlMultilineBasicString`.

### Integer

Integers are represented by `int`s or `BigInt`s.

The decoder produces an `int` only if the number can be represented losslessly by an `int`.
Whether a number can be represented by an `int` is platform specific.
When the code is running in the VM, numbers between `-2^63` and `2^63 - 1` can be represented as an `int`.
In JavaScript, only numbers in the range from `-(2^53 - 1)` to `2^53 - 1` are guaranteed to be converted to `int` but smaller or larger numbers may still produce an `int` if they can be represented without loss of precision.

The encoder accepts either representation and uses the decimal integer format by default.
If you need more control over the format used by the encoder, the value has to be wrapped in a `TomlInteger`.

For example, the following map

```dart
<String, dynamic>{
  'decimal': 255,
  'hexadecimal': TomlInteger.hex(255)
}
```

is encoded as shown below.

```toml
decimal = 255
hexadecimal = 0xff
```

### Float

Floating point numbers are represented as `double`s.
The special floating point values `inf`, `-inf` and `nan` are mapped to `double.infinity`, `double.negativeInfinity` and `double.nan`, respectively.
The value `-nan` is also mapped to `double.nan`.

When compiled to JavaScript, a `double` without decimal places cannot be distinguished from an `int`.
Thus, the encoder produces an integer for `double` values without decimal place.
If you want to force a JavaScript number to be encoded as a float, it has to be wrapped in a `TomlFloat`.

### Boolean

Boolean values are represented as values of type `bool`.
The encoder produces the TOML values `true` and `false`.

### Offset Date-Time

Offset Date-Time values are represented by the `TomlOffsetDateTime` class.
They can be converted to a UTC `DateTime` object with the `toUtcDateTime` method.

The encoder accepts `TomlOffsetDateTime` as well as `DateTime` objects.
A UTC `DateTime` is encoded as a offset date-time in the UTC time-zone.
A local `DateTime` is encoded as a offset date0time in the local time-zone.
For example, the following dates

```dart
<String, dynamic>{
  'utc': DateTime.utc(1969, 7, 20, 20, 17),
  'local': DateTime(1969, 7, 20, 20, 17),
}
```

are encoded as shown below when the code runs in the UTC+01:00 time-zone.

```toml
utc = 1969-07-20 20:17:00Z
local = 1969-07-20 20:17:00+01:00
```

### Local Date-Time

Local Date-Time values are represented by the `TomlLocalDateTime` class.
Before they can be converted to a `DateTime`, you must provide a time-zone information in which to interpret the date-time.
For example, to interpret a local date-time in the time-zone the code is running in, type the following.

```dart
localDateTime.withOffset(TomlTimeZoneOffset.local()) // interpret in local time-zone
```

To interpret the local date-time value in a specific time-zone, write the following for example.

```dart
localDateTime.withOffset(TomlTimeZoneOffset.positive(1, 0)) // interpret in UTC+01:00
```

In both cases the result is a `TomlOffsetDateTime` that can be converted to a `DateTime` as described above.
The encoder accepts `TomlLocalDateTime` objects only, i.e., a `DateTime` will never be encoded as a local date-time automatically.

### Local Date

Local Date values are represented by the `TomlLocalDate` class.
Before they can be converted to a `DateTime`, both a time and time-zone offset have to be provided.
First add a time with the `atTime` method and use `withOffset` from the resulting `TomlLocalDateTime` to obtain a offset date-time that can then be converted to a `DateTime`.

```dart
localDate.atTime(time).withOffset(timeZoneOffset)
```

### Local Time

Local Time values are represented by the `TomlLocalTime` class.
Before they can be converted to a `DateTime`, both a date and time-zone offset have to be provided.
First add a date with the `atDate` method and use `withOffset` from the resulting `TomlLocalDateTime` to obtain a offset date-time that can then be converted to a `DateTime`.

```dart
localTime.atDate(date).withOffset(timeZoneOffset)
```

## Testing

To see whether everything is working correctly change into the root directory of this package and run the included tests as follows:

```sh
dart test
```

You may pass the `--platform` command line argument to test the package on other platforms than the VM.
Run `dart test --help` for a list of all available platforms.

Alternatively, you can run [`toml-test`][toml-test] (again from the package root):

```sh
$GOPATH/bin/toml-test bin/decoder.dart
$GOPATH/bin/toml-test -encoder bin/encoder.dart
```

To speedup the tests, it is recommended to compile the encoder and decoder scripts before running `toml-test`.

```sh
mkdir -p build/bin
dart compile exe -o build/bin/decoder bin/decoder.dart
dart compile exe -o build/bin/encoder bin/encoder.dart

$GOPATH/bin/toml-test build/bin/decoder
$GOPATH/bin/toml-test -encoder build/bin/encoder
```

Unfortunately, `toml-test` supports version 0.4.0 of the TOML specification only such that some tests will fail.

## License

`toml.dart` is licensed under the MIT license agreement.
See the [LICENSE][toml-dart/LICENSE] file for details.

[coveralls/toml-dart]:
  https://coveralls.io/github/just95/toml.dart?branch=main
  "just95/toml.dart | Coveralls - Test Coverage History & Statistics"

[pub/toml]:
  https://pub.dev/packages/toml
  "toml | Dart Package"

[toml-dart/actions/main]:
  https://github.com/just95/toml.dart/actions?query=workflow%3A%22Dart+CI%22
  "toml.dart CI Pipeline"
[toml-dart/example]:
  https://github.com/just95/toml.dart/tree/main/example
  "toml.dart Examples"
[toml-dart/example/filesystem_config_loader]:
  https://github.com/just95/toml.dart/tree/main/example/filesystem_config_loader
  "dart:io Example | toml.dart"
[toml-dart/example/http_config_loader]:
  https://github.com/just95/toml.dart/tree/main/example/http_config_loader
  "HTTP Example | toml.dart"
[toml-dart/example/toml_parser]:
  https://github.com/just95/toml.dart/tree/main/example/toml_parser
  "TOML Parser Example | toml.dart"
[toml-dart/example/toml_encoder]:
  https://github.com/just95/toml.dart/tree/main/example/toml_encoder
  "TOML Encoder Example | toml.dart"
[toml-dart/LICENSE]:
  https://github.com/just95/toml.dart/blob/main/LICENSE
  "MIT License | toml.dart"

[toml-spec/v1.0.0]:
  https://toml.io/en/v1.0.0
  "TOML: English v1.0.0"
[toml-spec/website]:
  https://toml.io/en/
  "TOML: Tom's Obvious, Minimal Language"

[toml-test]:
  https://github.com/BurntSushi/toml-test
  "A language agnostic test suite for TOML encoders and decoders."
