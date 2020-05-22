import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toml/toml.dart';

void main() {
  runApp(MyApp());
}

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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final tomlParser = TomlParser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TOML example'),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/example.toml'),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final String text = snapshot.data;
          final Map<String, dynamic> toml = tomlParser.parse(text.trim()).value;
          return Center(
            child: Text(toml['str'] as String),
          );
        },
      ),
    );
  }
}
