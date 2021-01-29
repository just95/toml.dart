#!/bin/bash

# Before running this script, make sure that a WebDriver is running with one
# of the following commands.
#
#     chromedriver --port=4444 --url-base=wd/hub --verbose
#     geckodriver --port=4444

dart tool/test.dart
exit $?
