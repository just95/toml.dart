FROM dart:2.16

# Add files for `toml.dart`.
ADD ./pubspec.yaml /app/
ADD ./lib /app/lib

# Add files for `toml_to_json` example.
ADD ./example/toml_to_json/pubspec.yaml /app/example/toml_to_json/
ADD ./example/toml_to_json/bin /app/example/toml_to_json/bin

# Install dependencies.
WORKDIR /app/example/toml_to_json
RUN dart pub get

CMD []
ENTRYPOINT ["/usr/bin/dart", "bin/toml_to_json.dart"]
