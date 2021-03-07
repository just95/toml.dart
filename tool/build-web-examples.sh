#!/bin/bash

# This script compiles all examples in the `example` directory that have a
# `web` subdirectory using `webdev build`.

# Configure bash.
set -euo pipefail

# Change into the root directory of the package.
script=$(realpath "$0")
script_dir=$(dirname "$script")
root_dir=$(dirname "$script_dir")
cd "$root_dir"

# Find all examples with a `test-web.dart` file.
examples_dir="$root_dir/example"
for example in $(find "$examples_dir" -name pubspec.yaml); do
  example_dir=$(dirname "$example")
  example_name=$(basename "$example_dir")

  # Change into the example's root directory.
  cd "$example_dir"

  # Skip Flutter example.
  if [[ "$example_name" = "flutter_example" ]]; then
    echo "Skipping Flutter example!"
    continue
  fi

  # Compile example if it is a web example.
  if [ -d "web" ]; then
    # Install dependencies of the example with `pub get`.
    echo "Installing dependencies of '$example_name' example..."
    if ! dart pub get 2>&1 | awk '{print " | " $0}'; then
      echo "------------------------------------------------------------------"
      echo "Error when installing dependencies for '$example_name' example!" >&2
      exit 1
    fi

    echo "Building '$example_name' example..."
    if ! webdev build; then
      echo "------------------------------------------------------------------"
      echo "Error when building '$example_name' example!" >&2
      exit 1
    fi
  fi
done

echo "========================================================================"
echo "Built all web examples successfully!"
