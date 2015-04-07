// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.test;

import 'value_test.dart' as value_test;
import 'document_test.dart' as document_test;
import 'config_test.dart' as config_test;
import 'encoder_test.dart' as encoder_test;

main() {
  value_test.main();
  document_test.main();
  config_test.main();
  encoder_test.main();
}
