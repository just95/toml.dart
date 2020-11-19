# `TomlParser` example

This example demonstrates how to parse a TOML document from a string.

The example code in `./bin/example.dart` contains a global `String` variable `toml` that contains an example TOML document.
The code of the `main` function uses the `TomlParser` to decode the contents of `toml`.
If the document is decoded successfully, the value of the key `table.array.key` of the first table of the array of tables `table.array` is printed to the console.

## Running locally

All of the following commands have to be executed in the root directory of this example.

```bash
cd ./example/toml_parser
```

Before you can execute the example, first download the required dependencies.

```bash
dart pub get
```

Now you can run the example as follows.

```bash
dart pub run example
```

The command above should print `Hello, World!`.
