library toml.src.util.parser.late;

import 'package:petitparser/petitparser.dart';

/// A function that is used by [LateParser] to build the underlying parser.
typedef _LateParserBuilder<T> = Parser<T> Function();

/// Container with a late reference to the parser built by a
/// [_LateParserBuilder].
class _LateParserProvider<T> {
  /// The function to build the [parser].
  final _LateParserBuilder<T> _builder;

  /// The parser that is built by the [_builder].
  late final Parser<T> parser = _builder();

  /// Creates a new container for the parser built by the given function.
  _LateParserProvider(this._builder);
}

/// Since Dart is a strict programming language, we cannot construct a
/// cyclic parsing expression. This class simulates non-strictness by
/// building a parser on demand. The underlying parser is built only once.
///
/// This class allows cyclic dependencies in parsing expressions since child
/// parsers can refer to the [LateParser] instance before the underlying
/// parser has been built.
class LateParser<T> extends Parser<T> {
  /// The function to build the underlying parser.
  final _LateParserProvider<T> _provider;

  /// Creates a new parser that delegates to the parser built by the given
  /// function.
  LateParser(_LateParserBuilder<T> _builder)
      : _provider = _LateParserProvider(_builder);

  /// Constructor used by [copy].
  LateParser._(this._provider);

  @override
  Result<T> parseOn(Context context) =>
      _provider.parser.cast<T>().parseOn(context);

  @override
  int fastParseOn(String buffer, int position) =>
      _provider.parser.fastParseOn(buffer, position);

  @override
  List<Parser> get children => [_provider.parser];

  @override
  LateParser<T> copy() => LateParser<T>._(_provider);

  @override
  void replace(Parser source, Parser target) {
    _provider.parser.replace(source, target);
  }
}
