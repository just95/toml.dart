#!/bin/bash

# This script analyzes the source code of all examples in the `example`
# directory with `dart analyze`. The script is used by the CI pipeline to
# analyze the examples but can also be used for local testing.
#
# The script fails analyzes the examples one after another and fails as soon
# as there are errors for one example.

# Change into the root directory of the package.
script=$(realpath "$0")
script_dir=$(dirname "$script")
root_dir=$(dirname "$script_dir")
cd "$root_dir"

# Find all examples with a `analysis_options.yaml` file.
examples_dir="$root_dir/example"
for example in $(find "$examples_dir" -name analysis_options.yaml); do
  example_dir=$(dirname "$example")
  example_name=$(basename "$example_dir")

  # Skip Flutter example.
  if [[ "$example_name" = "flutter_example" ]]; then
    echo "Skipping Flutter example!"
    continue
  fi

  # Change into the example's root directory.
  cd "$example_dir"

  # Analyze the example's source code `dart analyze`.
  echo "Analyzing code of '$example_name' example..."
  dart analyze || exit 1
done
