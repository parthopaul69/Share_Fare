import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: Scaffold(
        body: Center(
          child: Text('AUST', style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold
          ),),
        ),
      ),
    );
  }
}
