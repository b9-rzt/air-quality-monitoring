import 'package:flutter/material.dart';
import 'package:myapp/pages/home.dart';

void main() {
  runApp(const MyApp());
}

/// Root of the App
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Thingsboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Thingsboard Sensor Daten'),
    );
  }
}
