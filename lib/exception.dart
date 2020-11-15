// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.exception;

/// Base class for all TOML related exceptions.
class TomlException implements Exception {
  final String message;

  TomlException(this.message);

  @override
  String toString() => 'TOML exception: $message';
}
