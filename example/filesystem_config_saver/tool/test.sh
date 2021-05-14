#!/bin/bash

# This script is used by the CI pipeline to execute this example.

# Run the `bin/example.dart` script.
dart run example

# Compare output file .
output=$(cat config.toml)
expected_output=$(echo "key = 'Hello, World!'")
if [[ "$output" != "$expected_output" ]]; then
  exit 1
fi
