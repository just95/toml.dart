FROM dart:stable AS build

# Resolve app dependencies.
COPY pubspec.* /app/
COPY ./example/toml_to_json/pubspec.* /app/example/toml_to_json/
WORKDIR /app/example/toml_to_json
RUN dart pub get

# Copy and compile app source code.
COPY . /app/
RUN mkdir -p build/bin/
RUN dart pub get --offline
RUN dart compile exe bin/toml_to_json.dart -o build/bin/toml-to-json

# Build minimal image from compiled binary and required system libraries and
# configuration files stored in `/runtime` from the `build` stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/example/toml_to_json/build/bin/toml-to-json /bin/

# Set the compiled binary as the entry point.
CMD []
ENTRYPOINT ["/bin/toml-to-json"]
