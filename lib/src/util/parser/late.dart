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
  /// The lazily evaluated actual parser.
  Late<Parser<T>> _delegate;

  /// Creates a new parser that delegates to the parser built by the given
  /// function.
  LateParser(Thunk<Parser<T>> thunk) : _delegate = Late(thunk);

  /// Creates a new parser that delegates to the parser built by the given
  /// fixed point operation.
  ///
  /// In contrast to the default constructor, the function is given the
  /// created [LateParser] as an argument.
  ///
  /// This constructor only needs to be used when the [LateParser] is written
  /// to a local variable since local variables cannot be accessed within their
  /// initializer.
  factory LateParser.fix(Parser<T> Function(LateParser<T> self) fix) {
    LateParser<T>? result;
    return result = LateParser(() => fix(result!));
  }

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
    super.replace(source, target);
    if (_delegate.value == source) {
      _delegate = Late.eager(target as Parser<T>);
    }
  }
}
