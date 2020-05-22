# `CustomConfigLoader` example

This example demonstrates how to extend the configuration file loading mechanism of `toml.dart` by supplying a custom instance of the `ConfigLoader` interface.

The example code in `./bin/example.dart` declares a `CustomConfigLoader` which implements the `ConfigLoader` interface.
The `loadConfig` method of the `CustomConfigLoader` simply looks up the contents of a configuration "file" from a map.
The `main` function configures the `toml.loader` library to use the `CustomConfigLoader` and prints the the value of the key `table.array.key` of the first table of the array of tables `table.array` to the console.

## Running locally

All of the following commands have to be executed in the root directory of this example.

```bash
cd ./example/custom_config_loader
```

Before you can execute the example, first download the required dependencies.

```bash
pub get
```

Now you can run the example as follows.

```bash
pub run example
```

The command above should print `Hello, World!`.
