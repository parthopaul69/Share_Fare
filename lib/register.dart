import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String name = '';
  String email = '';
  String phone = '';
  String pass = '';
  String gender = '';
  bool hidePass = true;
  bool loading = false;
  String? errMsg;

  bool _checkPhone(String input) {
    String clean = input.trim();
    if (clean.length < 10) return false;
    for (int i = 0; i < clean.length; i++) {
      if (!'0123456789+- '.contains(clean[i])) return false;
    }
    return true;
  }

  void _register() async {
    if (gender.isEmpty) {
      setState(() {
        errMsg = 'Please select your gender to create an account.';
      });
      return;
    }
    if (name.trim().isEmpty) {
      setState(() {
        errMsg = 'Please enter your full name.';
      });
      return;
    }
    String cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      setState(() {
        errMsg = 'Please enter a valid email address.';
      });
      return;
    }
    if (!_checkPhone(phone)) {
      setState(() {
        errMsg = 'Please enter a valid phone number (e.g. 01712345678).';
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

    AuthResult res = await AuthService().signUp(
      name: name.trim(),
      email: cleanEmail,
      password: pass,
      phone: phone.trim(),
      gender: gender,
    );

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

  Widget _genderBtn(String opt) {
    bool sel = gender == opt;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: sel ? Colors.black : Colors.white,
          foregroundColor: sel ? Colors.white : Colors.black,
          side: BorderSide(color: Colors.black),
          elevation: 0,
        ),
        onPressed: () {
          setState(() {
            gender = opt;
          });
        },
        child: Text(opt, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Create Account')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Text('Create Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Join ShareFare to split road rides.', style: TextStyle(fontSize: 13)),
            SizedBox(height: 20),
            Row(children: [_genderBtn('Male'), SizedBox(width: 8), _genderBtn('Female')]),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                name = value;
              },
              decoration: InputDecoration(
                hintText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline, size: 20, color: Colors.black),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
              },
              decoration: InputDecoration(
                hintText: 'your@email.com',
                prefixIcon: Icon(Icons.email_outlined, size: 20, color: Colors.black),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                phone = value;
              },
              decoration: InputDecoration(
                hintText: 'Phone Number (e.g. 01712345678)',
                prefixIcon: Icon(Icons.phone_outlined, size: 20, color: Colors.black),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: hidePass,
              onChanged: (value) {
                pass = value;
              },
              decoration: InputDecoration(
                hintText: 'Password (min 6 chars)',
                prefixIcon: Icon(Icons.lock_outline, size: 20, color: Colors.black),
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
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                onPressed: loading ? null : _register,
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('CREATE ACCOUNT'),
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
          ],
        ),
      ),
    );
  }
}
