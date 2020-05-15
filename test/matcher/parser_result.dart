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

  ParserResultMatcher.success() : this.isSuccess = true;

  ParserResultMatcher.failure() : this.isSuccess = false;

  bool matches(item, Map matchState) =>
      item is Result && item.isSuccess == isSuccess;

  Description describe(Description description) =>
      description.add('${isSuccess ? 'successful' : 'failed'} parse result');
}

/// A matcher which tests whether a parser succeeded.
ParserResultMatcher isSuccess = ParserResultMatcher.success();

/// A matcher which tests whether a parser failed.
ParserResultMatcher isFailure = ParserResultMatcher.failure();
