# toml.dart Examples

This directory contains examples for the usage of the `toml.dart` package.

 - [`./custom_config_loader`][toml-dart/example/custom_config_loader] contains an example for how to extend the configuration file loading mechanism of `toml.dart` by supplying your own instance of the `ConfigLoader` interface.

 - [`./filesystem_config_loader`][toml-dart/example/filesystem_config_loader] contains an example for how to load a configuration file in the Dart VM from the local filesystem.

 - [`./http_config_loader`][toml-dart/example/http_config_loader] contains an example for how to load a configuration file in the browser via HTTP.

 - [`./toml_encoder`][toml-dart/example/toml_encoder] contains an example for how to use the `TomlEncoder` from the `toml.encoder` library to encode a `Map` as a TOML document.

 - [`./toml_parser`][toml-dart/example/toml_parser] contains an example for how to use the `TomlParser` from the `toml.decoder` library to decode a TOML document from a string.
 
 - [`./flutter_example`][toml-dart/example/flutter_example] contains a Flutter example for how to use the `toml.dart` library to decode a TOML document as an asset string.

[toml-dart/example/custom_config_loader]:
  https://github.com/just95/toml.dart/tree/master/example/custom_config_loader
  "CustomConfigLoader Example | toml.dart"

[toml-dart/example/filesystem_config_loader]:
  https://github.com/just95/toml.dart/tree/master/example/filesystem_config_loader
  "FilesystemConfigLoader Example | toml.dart"

[toml-dart/example/http_config_loader]:
  https://github.com/just95/toml.dart/tree/master/example/http_config_loader
  "HttpConfigLoader Example | toml.dart"

[toml-dart/example/toml_encoder]:
  https://github.com/just95/toml.dart/tree/master/example/toml_encoder
  "TomlEncoder Example | toml.dart"

[toml-dart/example/toml_parser]:
  https://github.com/just95/toml.dart/tree/master/example/toml_parser
  "TomlParser Example | toml.dart"
  
[toml-dart/example/flutter_example]:
  https://github.com/just95/toml.dart/tree/master/example/flutter_example
  "Flutter Example | toml.dart"
