# TOML Encoder Example

This example demonstrates how to encode a `Map` as a TOML document.

The example code in `./bin/example.dart` contains a global map `document` that contains an example TOML document.
The code of the `main` function uses the `TomlEncoder` to encode the map as a TOML document.
The resulting TOML document is printed to the console.

The `document` contains value of a custom type `Point`.
The class `Point` is an example for a `TomlEncodableValue`.
Objects whose classes implement the `TomlEncodableValue` interface are implicitly converted to a value that can be encoded by `TomlDocument.fromMap` using their `toTomlValue` method.

## Running Locally

All of the following commands have to be executed in the root directory of this example.

```bash
cd ./example/toml_encoder
```

Before you can execute the example, first download the required dependencies.

```bash
dart pub get
```

Now you can run the example as follows.

```bash
dart run example
```

The command above should print the following TOML document.

```toml
[shape]
type = 'rectangle'

[[shape.points]]
x = 1
y = 1

[[shape.points]]
x = 1
y = -1

[[shape.points]]
x = -1
y = -1

[[shape.points]]
x = -1
y = 1
```
