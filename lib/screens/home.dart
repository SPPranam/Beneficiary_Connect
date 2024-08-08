import 'package:flutter/material.dart';
import 'package:login_signup/categories.dart';
import 'package:login_signup/screens/tabs.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TabsScreen(), // Display CategoriesScreen here
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(), // Display Home widget as the initial route
    );
  }
}
