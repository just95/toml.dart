# Saving TOML documents example

This example demonstrates how to save a configuration file in the Dart VM from the local filesystem.

The example in `./bin/example.dart` creates a new TOML document from a map and saves the document to `config.toml`.

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
dart run example
```

The command above should print `Hello, World!`.
