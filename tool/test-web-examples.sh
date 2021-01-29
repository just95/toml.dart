#!/bin/bash

# This script runs the `tool/test.sh` script of all examples in the `example`
# directory if it exists. The script is used by the CI pipeline to execute
# the examples.
#
# This script only fails when one of the example scripts exits with a
# non-zero status code. The example script has to validate the output
# of the example itself.
#
# The flutter and web examples do not have a `tool/test.sh` script and
# are therefore not executed.

# Change into the root directory of the package.
script=$(realpath "$0")
script_dir=$(dirname "$script")
root_dir=$(dirname "$script_dir")
cd "$root_dir"

# Find all examples with a `test.sh` file.
examples_dir="$root_dir/example"
for example in $(find "$examples_dir" -path \*/tool/test-web.dart); do
  example_dir=$(dirname $(dirname "$example"))
  example_name=$(basename "$example_dir")

  # Change into the example's root directory.
  cd "$example_dir"

  echo "Running '$example_name' example..."
  if ! dart ./tool/test-web.dart | awk '{print " | " $0}'; then
    echo "------------------------------------------------------------------"
    echo "Error when running web test for '$example_name' example!" >&2
    exit 1
  fi
done

echo "========================================================================"
echo "Tested all web examples successfully!"
