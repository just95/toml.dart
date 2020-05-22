# `HttpConfigLoader` example

This example demonstrates how to load a configuration file in the browser from via HTTP.

The `./web/index.html` example loads the `./web/example.dart` script which requests the `./web/config.toml` configuration file.
If the configuration file is loaded successfully, the value of the key `table.array.key` of the first table of the array of tables `table.array` is displayed by the website.

## Requirements

This example contains a Dart web application.
You have to have [`webdev`][dart/webdev] installed and in your `PATH`.

```bash
pub global activate webdev
```

## Running locally

All of the following commands have to be executed in the root directory of this example.

```bash
cd ./example/http_config_loader
```

Before you can serve the example web application, first download the required dependencies.

```bash
pub get
```

Now you can start a local web server and compile the `./web/example.dart` code to JavaScript using the following command.

```bash
webdev serve
```

Now open a browser and navigate to <localhost:8080>.
You should see a simple web page that displays `Loading...` until the `./web/config.toml` file has been loaded and decoded.
Once the configuration file has been loaded successfully, the text should change to `Hello, World!`.

[dart/webdev]:
  https://dart.dev/tools/webdev
  "webdev | Dart"
