library toml.test.matcher.parser_result;

import 'package:test/test.dart';
import 'package:petitparser/petitparser.dart';

/// A matcher which tests whether a parser completes successfully or not.
class ParserResultMatcher extends Matcher {
  /// Expected value for [Result.isSuccess].
  final bool isSuccess;

  /// Creates a new matcher that expects a parser to complete successfully.
  ParserResultMatcher.success() : isSuccess = true;

  /// Creates a new matcher that expects a parser to failed.
  ParserResultMatcher.failure() : isSuccess = false;

  @override
  bool matches(dynamic item, Map matchState) =>
      item is Result && item.isSuccess == isSuccess;

  @override
  Description describe(Description description) =>
      description.add('${isSuccess ? 'successful' : 'failed'} parse result');
}

/// A matcher which tests whether a parser succeeded.
ParserResultMatcher isSuccess = ParserResultMatcher.success();

/// A matcher which tests whether a parser failed.
ParserResultMatcher isFailure = ParserResultMatcher.failure();
