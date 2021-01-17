#!/bin/bash

# This script formats the source code in the `bin`, `lib` and `test` directories
# of all examples in the `example` directory with `dart format`. The script is
# used by the CI pipeline to check the formatting of the examples but can also
# be used for local testing.
#
# The script forwards all command line arguments to `dart format`.
# If the `--set-exit-if-changed` flag is specified and there is a file that
# has been formatted, the script exists with error code `1`.

# Change into the root directory of the package.
script=$(realpath "$0")
script_dir=$(dirname "$script")
root_dir=$(dirname "$script_dir")
cd "$root_dir"

# Find all examples with a `pubspec.yaml` file.
echo "Checking formatting of all examples..."
if ! dart format "$@" bin lib test | awk '{print " | " $0}'; then
  echo "------------------------------------------------------------------"
  echo "Error when checking formatting!" >&2
  exit 1
fi

echo "========================================================================"
echo "Formatted code of all examples successfully!"
