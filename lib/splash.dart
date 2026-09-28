import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'login.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() async {
    await Future.delayed(Duration(milliseconds: 1800));
    if (!mounted) return;
    await AuthService().init();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthService().isAuthenticated ? Home() : LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/SFlogo.png',
              width: 90,
              height: 90,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.directions_car, size: 56, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'ShareFare',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Smart Road Rides & Shared Fares', style: TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
