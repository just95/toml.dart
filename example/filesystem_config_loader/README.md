# `dart:io` example

This example demonstrates how to load a configuration file in the Dart VM from the local filesystem.

The example in `./bin/example.dart` loads the configuration file `config.toml`.
If the configuration file is loaded successfully, the value of the key `table.array.key` of the first table of the array of tables `table.array` is printed to the console.

## Running locally

All of the following commands have to be executed in the root directory of this example.

```bash
cd ./example/filesystem_config_loader
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
