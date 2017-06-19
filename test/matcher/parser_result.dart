// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test.matcher.parser_result;

import 'package:test/test.dart';
import 'package:petitparser/petitparser.dart';

/// A matcher which tests whether a parser completes successfully or not.
class ParserResultMatcher extends Matcher {
  /// Expected value for [Result.isSuccess].
  final bool isSuccess;

  /// Creates a new matcher that expects a parser to complete successfully.
  ParserResultMatcher.success() : this.isSuccess = true;

  /// Creates a new matcher that expects a parser to failed.
  ParserResultMatcher.failure() : this.isSuccess = false;

  @override
  bool matches(dynamic item, Map matchState) =>
      item is Result && item.isSuccess == isSuccess;

  @override
  Description describe(Description description) =>
      description.add('${isSuccess ? 'successful' : 'failed'} parse result');
}

/// A matcher which tests whether a parser succeeded.
ParserResultMatcher isSuccess = new ParserResultMatcher.success();

/// A matcher which tests whether a parser failed.
ParserResultMatcher isFailure = new ParserResultMatcher.failure();
