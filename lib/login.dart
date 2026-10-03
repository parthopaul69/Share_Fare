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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            SizedBox(height: 40),
            Text('ShareFare', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('Sign in with your email to share road rides.', style: TextStyle(fontSize: 14)),
            SizedBox(height: 32),
            TextField(
              keyboardType: TextInputType.emailAddress,
              cursorColor: Colors.black,
              onChanged: (value) {
                email = value;
              },
              decoration: InputDecoration(
                hintText: 'your@email.com',
                prefixIcon: Icon(Icons.email_outlined, size: 20, color: Colors.black),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: hidePass,
              cursorColor: Colors.black,
              onChanged: (value) {
                pass = value;
              },
              decoration: InputDecoration(
                hintText: 'Enter Password',
                prefixIcon: Icon(Icons.lock_outline, size: 20, color: Colors.black),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePass = !hidePass;
                    });
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                },
                child: Text('Forgot password?', style: TextStyle(fontSize: 13, color: Colors.black)),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                onPressed: loading ? null : _login,
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('SIGN IN'),
              ),
            ),
            if (errMsg != null) ...[
              SizedBox(height: 12),
              Text(
                errMsg!,
                style: TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ", style: TextStyle(fontSize: 14)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                  },
                  child: Text(
                    'Create Account',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
