import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('AUST', style: TextStyle(
            fontSize: 29, fontWeight: FontWeight.bold
          ),),
        ),
      ),
      title: 'AUST PROJECT',
    );
  }
}


