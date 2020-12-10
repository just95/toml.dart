library toml.src.parser.util.non_strict;

import 'package:petitparser/petitparser.dart';

/// A function that is used by [NonStrictParser] to build the underlying parser.
typedef NonStrictParserBuilder<T> = Parser<T> Function();

/// Since Dart is a strict programming language, we cannot construct a
/// cyclic parsing expression. This class simulates non-strictness by
/// building a parser on demand. The underlying parser is built only once.
///
/// This class allows cyclic dependencies in parsing expressions since child
/// parsers can refer to the [NonStrictParser] instance before the underlying
/// parser has been built.
class NonStrictParser<T> extends DelegateParser<T> {
  /// The function to build the underlying parser.
  ///
  /// If the [delegate] has been built already, the builder is set to `null`.
  NonStrictParserBuilder<T> _builder;

  /// Creates a new parser that delegates to the parser built by the given
  /// [NonStrictParserBuilder] function.
  NonStrictParser(this._builder)
      : super(failure<T>('non-strict parser not yet initialized'));

  /// Constructor used by [copy].
  NonStrictParser._(this._builder, Parser delegate) : super(delegate);

  /// Gets the [delegate] or invokes the builder for the delegate if it hasn't
  /// been built before.
  Parser getOrBuildDelegate() {
    if (_builder != null) {
      delegate = _builder();
      _builder = null;
    }
    return delegate;
  }

  @override
  Result<T> parseOn(Context context) =>
      getOrBuildDelegate().cast<T>().parseOn(context);

  @override
  int fastParseOn(String buffer, int position) =>
      getOrBuildDelegate().fastParseOn(buffer, position);

  @override
  NonStrictParser<T> copy() => NonStrictParser<T>._(_builder, delegate);
}
