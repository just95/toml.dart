#!/bin/bash

# This script analyzes the source code of all examples in the `example`
# directory with `dart analyze`. The script is used by the CI pipeline to
# analyze the examples but can also be used for local testing.
#
# The script forwards all command line arguments to `dart format`.
# The examples are analyzed one after another and the script fails as soon
# as there are errors for one example.
#
# The source code of the Flutter example is not analyzed because the Flutter
# SDK is not available in the CI pipeline.

# Configure bash.
set -euo pipefail

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
  if ! dart analyze "$@" 2>&1 | awk '{print " | " $0}'; then
    echo "------------------------------------------------------------------"
    echo "Error when analyzing code of '$example_name' example!" >&2
    exit 1
  fi
done

echo "========================================================================"
echo "Analyzed code of all examples successfully!"
