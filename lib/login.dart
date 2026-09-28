import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'home.dart';
import 'register.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String pass = '';
  bool hidePass = true;
  bool loading = false;
  String? errMsg;

  void _login() async {
    String clean = email.trim().toLowerCase();
    if (clean.isEmpty || !clean.contains('@') || !clean.contains('.')) {
      setState(() {
        errMsg = 'Please enter a valid email address.';
      });
      return;
    }
    if (pass.length < 6) {
      setState(() {
        errMsg = 'Password must be at least 6 characters.';
      });
      return;
    }

    setState(() {
      errMsg = null;
      loading = true;
    });

    AuthResult res = await AuthService().signIn(clean, pass);
    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (res.success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    } else {
      setState(() {
        errMsg = res.error;
      });
    }
  }

