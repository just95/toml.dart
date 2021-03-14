#!/bin/bash

# This script is used by the CI pipeline to execute this example.

# Run the `bin/example.dart` script and remember output.
output=$(dart run example)
echo "$output"

# Compare output with expected output.
expected_output="\
[shape]
type = 'rectangle'

[[shape.points]]
x = 1
y = 1

[[shape.points]]
x = 1
y = -1

[[shape.points]]
x = -1
y = -1

[[shape.points]]
x = -1
y = 1"
if [[ "$output" != "$expected_output" ]]; then
  exit 1
fi
