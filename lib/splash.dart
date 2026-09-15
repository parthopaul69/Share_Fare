import 'package:flutter/material.dart';
import 'login.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });

    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image(
          image: AssetImage('assets/SFlogo.png'),
          width: 200,
        ),
      ),
    );
  }
}