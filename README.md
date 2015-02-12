toml.dart
=========

This package provides an implementation of a TOML (Tom's Obvious, Minimal 
Language) parser and encoder for dart.
It can be used with the
[`dart_config`](https://pub.dartlang.org/packages/dart_config)
library which allows you to dynamically load configuration files.

It currently supports version
[v0.4.0](https://github.com/toml-lang/toml/blob/master/versions/en/toml-v0.4.0.md) 
of the TOML specification.

## Installation

To get started add `toml` as a dependency to your `pubspec.yaml` and run the 
`pub get` command.
```yaml
dependencies:
  toml: ">=0.2.0 <0.3.0"
```

## Usage

### With dart_config

If you want to use `dart_config` and your code is running in the **browser** 
add the following import directive:
```dart
import 'package:toml/browser.dart';
```
For command line and **server** side applications write:
```dart
import 'package:toml/server.dart';
```

Both imports define a `loadConfig` function which takes an optional path to
the configuration file (defaults to `'config.toml'`) and returns a `Future` of
the parsed document as an unmodifiable `Map`.
They use the default `ConfigHttpRequestLoader` and `ConfigFilesystemLoader`,
respectively.
```dart
loadConfig().then((Map document) {
  // ...
})
```

If you want to use a **custom** `ConfigLoader` add the following import instead:
```dart
import 'package:toml/config.dart';
```
There you will find the `TomlConfigParser` which implements the `ConfigParser` 
interface and can be used in conjunction with `dart_config`s `Config` class and 
your loader:
```dart
var config = new Config(filename,
  new MyConfigLoader(),
  new TomlConfigParser()
);
config.readConfig().then((Map document) {
  // ...
});
```

### Without dart_config

If you don't want to use `dart_config` at all, add:
```dart
import 'package:toml/toml.dart';
```
This library contains the actual `TomlParser` class whose `parse` method 
takes a `String` and returns a `Result` object. The results `value` property 
holds an unmodifiable `Map` of the parsed document.
```dart
var toml = '''
  # ...
''';
var parser = new TomlParser();
var document = parser.parse(toml).value;
```

### Encode

This package includes a TOML encoder. To use it simply import:
```dart
import 'package:toml/encoder.dart';
```
The library provides a `TomlEncoder` class whose `encode` method takes
a `Map` and returns a TOML encoded `String`.
All values of the map must be natively representable by TOML or implement the 
`TomlEncodable` interface.
```dart
var document = {
  // ...
};
var encoder = new TomlEncoder();
var toml = encoder.encode(document);
```
Classes which implement the `TomlEncodable` interface define a `toToml` method
whose return value can be represented by TOML in turn.

## Data Structure

TOML **documents** and **tables** as well as **inline tables** are represented 
through nested `UnmodifiableMapView` objects whose keys are `String`s and values
`dynamic` read-only representations of the corresponding TOML value or 
sub-table.
The contents of a table declared by:
```toml
[a.b.c]
key = 'value'
```
may be accessed using `[]`:
```dart
var table = document['a']['b']['c']; // ok
var value = table['key'];
```
The following, however, is invalid:
```dart
var table = document['a.b.c']; // error
table['key'] = value; // error
```

All kinds of **arrays** including **arrays of tables** are stored as 
`UnmodifiableListView` objects. Though the encoder accepts any `Iterable`.
The items of the list represent either a value or a table.
Given a document:
```toml
[[items]]
name = 'A'

[[items]]
name = 'B'

[[items]]
name = 'C'
```
One might iterate over the items of the list:
```dart
document['items'].forEach((Map item) { # ok
  print(item.name);
});
```
But it is not allowed to add, remove or modify its entries:
```dart
document['items'].add({ # error
  'name': 'D'
});
document['items'][0] = { # error
  'name': 'E'
};
```

All **string** variants produce regular dart `String`s.
These are therefore all equivalent:
```toml
str1 = "Hello World!"
str2 = 'Hello World!'
str3 = """
  Hello \
  World!\
"""
str4 = '''Hello World!'''
```

**Integers** are of type `int` and **float**ing point numbers are represented 
as `double`s.
When compiled to JavaScript these two types are not distinct. 
Thus a float without decimal places might accidentally be encoded as an
integer. This behavior would lead to the generation of invalid numeric 
arrays.
The `TomlEncoder` addresses this issue by analyzing the contents of numeric 
arrays first.
If any of its items cannot be represented as an integer all items will be
encoded as floats instead.
Encoding the following map:
```dart
var document = {
  'array': [1, 2.0, 3.141]
};
```
would throw an `MixedArrayTypesError` in the vm but yields this document when
compiled to JavaScript:
```toml
array = [1.0, 2.0, 3.141]
```
  
**Boolean** values are obviously of type `bool`. 

**Datetime** values are UTC `DateTime` objects.

## Examples

Check out the scripts located in the `'/example'` directory.

## License

toml.dart is licensed under the MIT license agreement.
See the LICENSE file for details.

