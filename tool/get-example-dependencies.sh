#!/bin/bash

# This script installs the dependencies of all examples in the `example`
# directory using `dart pub get`. The script is used by the CI pipeline
# when the source code of the examples is checked but can also be used
# for local testing.
#
# The dependencies of the Flutter example are not installed since the Flutter
# SDK is not available in the CI pipeline.

# Change into the root directory of the package.
script=$(realpath "$0")
script_dir=$(dirname "$script")
root_dir=$(dirname "$script_dir")
cd "$root_dir"

# Find all examples with a `pubspec.yaml` file.
examples_dir="$root_dir/example"
for example in $(find "$examples_dir" -name pubspec.yaml); do
  example_dir=$(dirname "$example")
  example_name=$(basename "$example_dir")

  # Skip Flutter example.
  if [[ "$example_name" = "flutter_example" ]]; then
    echo "Skipping Flutter example!"
    continue
  fi

  # Change into the example's root directory.
  cd "$example_dir"

  # Install dependencies of the example with `pub get`.
  echo "Installing dependencies of '$example_name' example..."
  if ! dart pub get 2>&1 | awk '{print " | " $0}'; then
    echo "------------------------------------------------------------------"
    echo "Error when installing dependencies for '$example_name' example!" >&2
    exit 1
  fi
done

echo "========================================================================"
echo "Installed dependencies of all examples successfully!"
