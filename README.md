# toml.dart

This package provides an implementation of a TOML (Tom's Obvious, Minimal
Language) parser and encoder for Dart.

It currently supports version [v0.4.0][] of the TOML specification.

## Installation

To get started add `toml` as a dependency to your `pubspec.yaml` and run the
`pub get` command.

```yaml
dependencies:
  toml: "^0.5.1"
```

## Usage

This package includes three libraries for loading, decoding and encoding TOML
documents, which are further described below.

If you want to use both the encoder and decoder, a single import suffices:

```dart
import 'package:toml/toml.dart';
```

### Load configuration files.

Before any configuration file can be parsed the library needs to know how
to load it. There are two default methods available, but you can easily
implement your own loading mechanism as further described below.

If your code is running in the **browser**, you probably want to use XHR to
fetch the file from the server. To do so import the `toml.loader.http` library
and call the static `HttpConfigLoader.use` method, e.g. from your `main`
function.

```dart
import 'package:toml/loader/http.dart';

void main() {
  HttpConfigLoader.use();
  // ...
}
```

If your code is running on the **server**, you can load configuration files from
the local file system. Simply import the `toml.loader.fs` library and call the
static `FilesystemConfigLoader.use` method, e.g. from your `main` function.

```dart
import 'package:toml/loader/fs.dart';

void main() {
  FilesystemConfigLoader.use();
  // ...
}
```

For convenience both libraries export the `loadConfig` function from the
`toml.loader` library. It optionally takes the path to the configuration file
as its only argument (defaults to `'config.toml'`) and returns a `Future` of
the parsed configuration options.

```dart
Future main() async {
  // ...
  var cfg = await loadConfig();
  // ...
}
```

### Implement a custom loader.

To create a custom loader which fits exactly your needs import the
`toml.loader` library, create a new class and implement the `ConfigLoader`
interface. You can use this code as a starting point:

```dart
library my.config.loader;

import 'package:toml/loader.dart';
export 'package:toml/loader.dart' show loadConfig;

class MyConfigLoader implements ConfigLoader {

  static void use() {
    ConfigLoader.use(new MyConfigLoader());
  }

  @override
  Future<String> loadConfig(String filename) {
    // ...
  }

}
```

In your `main` function invoke the `MyConfigLoader.use` method and call the
`loadConfig` function as usual.

### Decode TOML

If you only want to decode a string of TOML, add the following import directive
to your script:

```dart
import 'package:toml/decoder.dart';
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

### Encode TOML

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
through nested `UnmodifiableMapView` objects whose keys are `String`s and
values `dynamic` read-only representations of the corresponding TOML value or
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
document['items'].forEach((Map item) { // ok
  print(item.name);
});
```

But it is not allowed to add, remove or modify its entries:

```dart
document['items'].add({ // error
  'name': 'D'
});
document['items'][0] = { // error
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
If any of its items cannot be represented as an integer, all items will be
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

## Testing

To see whether everything is working correctly change into the root directory
of this package and run the included tests as follows:

```sh
pub run test
```

You may pass the `--platform` command line argument to test the package on
other platforms than the VM. Run `pub run test --help` for a list of all
available platforms.

Alternatively you can run [toml-test][] (again from the package root):

```sh
$GOPATH/bin/toml-test bin/decoder.dart
$GOPATH/bin/toml-test -encoder bin/encoder.dart
```

However, note that `toml-test` currently supports [v0.2.0][] only.
Thus a workaround is needed at the time to fix datetimes which have
changed slightly since then.

## License

toml.dart is licensed under the MIT license agreement.
See the LICENSE file for details.

[toml-test]: https://github.com/BurntSushi/toml-test
  "A language agnostic test suite for TOML encoders and decoders."

[v0.2.0]: https://github.com/toml-lang/toml/blob/master/versions/en/toml-v0.2.0.md
  "Tom's Obvious, Minimal Language v0.2.0"

[v0.4.0]: https://github.com/toml-lang/toml/blob/master/versions/en/toml-v0.4.0.md
  "Tom's Obvious, Minimal Language v0.4.0"
