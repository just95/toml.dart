// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.exception;

/// Base class for all TOML related exceptions.
abstract class TomlException implements Exception {
  /// A human readable description of the error.
  String get message;

  @override
  String toString() => 'TOML exception: $message';
}
