import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toml/toml.dart';

void main() {
  runApp(MyApp());
}

/// The main widget of the example application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

/// The default route of [MyApp].
class MyHomePage extends StatelessWidget {
  /// Creates a [MyHomePage].
  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TOML example'),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/example.toml'),
        builder: (context, snapshot) {
          final text = snapshot.data;
          if (text == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final toml = TomlDocument.parse(text).toMap();
          return Center(
            child: Text(toml['str'] as String),
          );
        },
      ),
    );
  }
}
