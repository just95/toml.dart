// TODO update to null-safety once dev dependencies are updated.
// @dart=2.9

import 'dart:io';

import 'package:webdriver/io.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

/// The output that is expected to be written to the element with id `text`.
const expectedOutput = 'Hello, World!';

/// The text that is displayed in the element with id `text` while the
/// configuration file is loading.
const outputPlaceholder = 'Loading...';

/// How often to test whether the [expectedOutput] has been written to the
/// output element (with a delay of one second each).
const maxTries = 5;

Future main() async {
  // Serve previously compiled `build` directory.
  final handler = shelf_static.createStaticHandler('./build', defaultDocument: 'index.html');
  shelf_io.serve(handler, InternetAddress.loopbackIPv4, 8080);

  // Load the example web site.
  final driver = await createDriver(spec: WebDriverSpec.JsonWire);
  await driver.get(Uri(
    scheme: 'http',
    host: server.address.host,
    port: server.port,
    path: 'index.html',
  ));

  // Wait for the configuration file to be loaded.
  var success = false;
  for (var i = 0; i < maxTries; i++) {
    print('Waiting for configuration file to be loaded...');
    sleep(Duration(seconds: 1));

    // Get element the output will be written to.
    final elem = await driver.findElement(By.id('text'));

    // Test whether the configuration file has been loaded successfully.
    final output = await elem.text;
    if (output == expectedOutput) {
      success = true;
      print('Found expected output!');
      break;
    } else if (output != outputPlaceholder) {
      print('Failed with output: $output');
      break;
    }
  }

  // Stop server for static resources.
  await server.close(force: true);

  // Exit with non-zero status code unless the expected output was found.
  exit(success ? 0 : 1);
}
