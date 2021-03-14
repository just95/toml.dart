# TOML to JSON example

This example contains an application for the conversion of TOML documents to JSON.

## Running locally

All of the following commands have to be executed in the root directory of this example.

```bash
cd ./example/toml_to_json
```

Before you can execute the example, first download the required dependencies.

```bash
dart pub get
```

Now you can run the example as follows.

```bash
dart run toml_to_json <INPUT-FILE...>
```

The given input file is converted to JSON and printed to the console.
If multiple input files are specified, the hash maps of all documents are merged as follows.

 - Two tables are merged by adding the keys from the second table to the first table.
   If the same key exists in both tables, it is overwritten in favor of the second value.
 - Arrays (including arrays of tables) are merged by adding the items of the second array to end of the first array.
 - If two values cannot be merged because they have different types, the value is overwritten in favor of the second document.
 - `DateTime`s are converted to strings.

## Installation

You can install this example application to your path with the following command.

```bash
dart pub global activate -s path .
```

Make sure that `~/.pub-cache/bin` is in your `PATH` and type `toml-to-json --help` to confirm that the installation was successful.

## Docker

You can also run this example application using Docker.
For example to convert a TOML document `input.toml` in the current working directory to JSON, type the following command.

```bash
docker run -it -v $PWD:/pwd just95/toml-to-json /pwd/input.toml
```

### Building Docker Image

To build the docker image run the following command in the **root directory of the `toml.dart` repository** rather than the example's root directory.

```bash
docker build -t just95/toml-to-json -f example/toml_to_json/Dockerfile .
```
