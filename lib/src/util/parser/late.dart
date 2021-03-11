library toml.src.util.parser.late;

import 'package:petitparser/petitparser.dart';

import '../container/late.dart';

/// Since Dart is a strict programming language, we cannot construct a
/// cyclic parsing expression. This class simulates non-strictness by
/// building a parser on demand. The underlying parser is built only once.
///
/// This class allows cyclic dependencies in parsing expressions since child
/// parsers can refer to the [LateParser] instance before the underlying
/// parser has been built.
class LateParser<T> extends Parser<T> {
  /// The lazily evaluared actual parser.
  final Late<Parser<T>> _delegate;

  /// Creates a new parser that delegates to the parser built by the given
  /// function.
  LateParser(Thunk<Parser<T>> thunk) : _delegate = Late(thunk);

  /// Constructor used by [copy].
  LateParser._(this._delegate);

  @override
  Result<T> parseOn(Context context) => _delegate.value.parseOn(context);

  @override
  int fastParseOn(String buffer, int position) =>
      _delegate.value.fastParseOn(buffer, position);

  @override
  List<Parser> get children => [_delegate.value];

  @override
  LateParser<T> copy() => LateParser<T>._(_delegate);

  @override
  void replace(Parser source, Parser target) {
    _delegate.value.replace(source, target);
  }
}
