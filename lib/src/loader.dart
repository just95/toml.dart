library toml.src.loader;

export 'loader/stub.dart'
    if (dart.library.io) 'loader/io.dart'
    if (dart.library.html) 'loader/html.dart';
