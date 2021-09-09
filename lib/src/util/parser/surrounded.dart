library toml.src.util.parser.surrounded;

import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';

/// Extension for utility methods to construct [SurroundedParser]s.
extension SurroundedParserExtension<T> on Parser<T> {
  /// Returns a new parser for the sequence of the receiver and [other] parser
  /// that discards the result of the receiver.
  Parser<S> before<S>(Parser<S> other) => SurroundedParser(other, prefix: this);

  /// Returns a new parser for the sequence of the receiver and [other] parser
  /// that discards the result of the [other] parser.
  Parser<T> followedBy(Parser other) => SurroundedParser(this, suffix: other);

  /// Returns a new parser that parses the [prefix] before the receiver
  /// followed by the [suffix].
  ///
  /// The result of the returned parser is the result of the receiver. The
  /// result of the prefix and suffix are discarded.
  ///
  /// The [suffix] defaults to the [prefix].
  Parser<T> surroundedBy(Parser prefix, [Parser? suffix]) => SurroundedParser(
        this,
        prefix: prefix,
        suffix: suffix ?? prefix,
      );
}

/// A parser that delegates to a parser with an optional prefix and suffix.
///
/// The results of the prefix and suffix are discarded.
class SurroundedParser<T> extends DelegateParser<T, T> {
  /// The optional prefix parser.
  Parser? prefix;

  /// The optional suffix parser.
  Parser? suffix;

  /// Creates a new parser that accepts the sequence of the given [prefix],
  /// [delegate] and [suffix] but returns the result of the [delegate].
  SurroundedParser(Parser<T> delegate, {this.prefix, this.suffix})
      : super(delegate);

  @override
  Result<T> parseOn(Context context) {
    // Parse prefix if any.
    var prefix = this.prefix;
    if (prefix != null) {
      var prefixResult = prefix.parseOn(context);
      if (prefixResult.isFailure) {
        return prefixResult.failure(prefixResult.message);
      }
      context = prefixResult;
    }

    // Parse the delegate.
    var result = delegate.parseOn(context);
    if (result.isFailure) return result.failure(result.message);
    context = result;

    // Parse suffix if any.
    var suffix = this.suffix;
    if (suffix != null) {
      var suffixResult = suffix.parseOn(context);
      if (suffixResult.isFailure) {
        return suffixResult.failure(suffixResult.message);
      }
      context = suffixResult;
    }

    // Return the value of the delegate.
    return context.success(result.value);
  }

  @override
  int fastParseOn(String buffer, int position) {
    // Parse prefix if any.
    position = prefix?.fastParseOn(buffer, position) ?? position;
    if (position == -1) return position;

    // Parse delegate.
    position = delegate.fastParseOn(buffer, position);
    if (position == -1) return position;

    // Parse suffix if any.
    return suffix?.fastParseOn(buffer, position) ?? position;
  }

  @override
  List<Parser> get children =>
      [prefix, delegate, suffix].whereNotNull().toList();

  @override
  SurroundedParser<T> copy() => SurroundedParser<T>(
        delegate,
        prefix: prefix,
        suffix: suffix,
      );

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (source == prefix) {
      prefix = target;
    }
    if (source == suffix) {
      suffix = target;
    }
  }
}
