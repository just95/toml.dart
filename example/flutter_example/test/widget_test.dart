// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Loads TOML file', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the TOML file to be loaded.
    await tester.pump(Duration(seconds: 1));

    // Verify that the expected value has been loaded from the TOML file.
    expect(find.text('Hello, World!'), findsOneWidget);
  });
}
