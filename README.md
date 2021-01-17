# toml.dart

[![Dart CI](https://github.com/just95/toml.dart/workflows/Dart%20CI/badge.svg?branch=main)][toml-dart/actions/main]
[![Pub Package](https://img.shields.io/pub/v/toml.svg)][pub/toml]
[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)][toml-dart/LICENSE]

This package provides an implementation of a [TOML][toml-spec/website] parser and encoder for Dart.

It currently supports version [0.4.0][toml-spec/v0.4.0] of the TOML specification.

## Table of Contents

 1. [Installation](#installation)
 2. [Usage](#usage)
    1. [Loading TOML](#loading-toml)
    1. [Parsing TOML](#parsing-toml)
    3. [Decoding TOML](#decoding-toml)
    4. [Encoding TOML](#encoding-toml)
 3. [Data Structure](#data-structure)
 4. [Testing](#testing)
 5. [License](#license)

## Installation

To get started add `toml` as a dependency to your `pubspec.yaml` and run the
`dart pub get` or `flutter pub get` command.

```yaml
dependencies:
  toml: "^0.7.0"
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

If the TOML document is semantically invalid, `TomlException` is thrown.

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
Classes which implement those interfaces must define a `toTomlKey` or `toTomlValue` method, respectively, whose return value is either implements the interface itself or is natively encodable by TOML.
If an object cannot be encoded as a TOML key or value, a `TomlUnknownKeyTypeException` or `TomlUnknownValueTypeException` is thrown by `TomlDocument.fromMap`.

An example for using the encoder and the `TomlEncodableValue` interface to encode a `Map` can be found in [`./example/toml_encoder`][toml-dart/example/toml_encoder].

## Data Structure

TOML **documents** and **tables** as well as **inline tables** are represented through nested `Map` objects whose keys are `String`s and values `dynamic` representations of the corresponding TOML value or sub-table.
The contents of a table declared by

```toml
[a.b.c]
key = 'value'
```

may be accessed using `[]` as shown in the listing below.

```dart
var table = document['a']['b']['c']; // ok
```

The following, on the other hand, is invalid.

```dart
var table = document['a.b.c']; // error
```

All kinds of **arrays** including **arrays of tables** are stored as `List` objects.
The encoder accepts any `Iterable`, though.
The items of the list represent either a value or a table.
Consider the document that contains an array of tables.

```toml
[[items]]
name = 'A'

[[items]]
name = 'B'

[[items]]
name = 'C'
```

For example, it is possible to iterate over the tables in the array as follows.

```dart
document['items'].forEach((Map<String, dynamic> item) {
  print(item['name']);
});
```

All **string** variants produce regular dart `String`s.
All of the following are therefore equivalent.

```toml
str1 = "Hello World!"
str2 = 'Hello World!'
str3 = """\
  Hello \
  World!\
"""
str4 = '''
Hello World!'''
```

**Integers** are of type `int` and **float**ing point numbers are represented as `double`s.
When compiled to JavaScript these two types are not distinct.
Thus a float without decimal places might accidentally be encoded as an integer.
This behavior would lead to the generation of invalid numeric arrays.
The TOML encoder addresses this issue by analyzing the contents of numeric arrays first.
If any of its items cannot be represented as an integer, all items will be encoded as floats instead.
Encoding the following map, for example, would throw an `TomlMixedArrayTypesException` in the VM.

```dart
var document = {
  'array': [1, 2.0, 3.141]
};
```

However, in JavaScript, the encoder yields the following TOML document.

```toml
array = [1.0, 2.0, 3.141]
```

**Boolean** values are obviously of type `bool`.

**Datetime** values are UTC `DateTime` objects.

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

Unfortunately, some encoder tests from `toml-test` are failing at the moment because date times are always encoded as UTC and the encoder never generates inline tables.

## License

`toml.dart` is licensed under the MIT license agreement.
See the [LICENSE][toml-dart/LICENSE] file for details.

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

[toml-spec/v0.4.0]:
  https://toml.io/en/v0.4.0
  "TOML: English v0.4.0"
[toml-spec/website]:
  https://toml.io/en/
  "TOML: Tom's Obvious, Minimal Language"

[toml-test]:
  https://github.com/BurntSushi/toml-test
  "A language agnostic test suite for TOML encoders and decoders."
