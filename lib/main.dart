import 'package:flutter/material.dart';
import 'package:gymbuddy/all_products_screen.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Api Usage',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home:  AllProductsScreen(),
    );
  }
}
