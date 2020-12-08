// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.loader;

export 'loader/stub.dart'
    if (dart.library.io) 'loader/io.dart'
    if (dart.library.js) 'loader/js.dart';
