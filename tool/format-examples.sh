#!/bin/bash

# This script formats the source code in the `bin`, `lib` and `test` directories
# of all examples in the `example` directory with `dart format`. The script is
# used by the CI pipeline to check the formatting of the examples but can also
# be used for local testing.
#
# The script forwards all command line arguments to `dart format`.
# If there
# fails analyzes the examples one after another and fails as soon as there are
# errors for one example.

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

  # Format the example's source code with `dart format`.
  echo "Analyzing code of '$example_name' example..."
  dart format "$@" bin lib test || exit 1
done
