import 'package:flutter/material.dart';

import 'auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email = '';
  bool loading = false;
  String? msg;
  bool isError = false;

  void _reset() async {
    String clean = email.trim().toLowerCase();
    if (clean.isEmpty || !clean.contains('@') || !clean.contains('.')) {
      setState(() {
        isError = true;
        msg = 'Please enter a valid email address.';
      });
      return;
    }
    setState(() {
      loading = true;
      msg = null;
      isError = false;
    });
    String res = await AuthService().resetPassword(clean);
    if (!mounted) return;
    setState(() {
      loading = false;
      msg = res;
      isError = !res.contains('sent');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            Text('Forgot your password?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Enter your registered email to receive reset instructions.', style: TextStyle(fontSize: 14)),
            SizedBox(height: 24),
            TextField(
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onChanged: (value) {
                email = value;
              },
              decoration: InputDecoration(
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.email_outlined, color: Colors.black),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                onPressed: loading ? null : _reset,
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Send Reset Link'),
              ),
            ),
            if (msg != null) ...[
              SizedBox(height: 12),
              Text(
                msg!,
                style: TextStyle(color: isError ? Colors.red : Colors.green, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              if (!isError) ...[
                SizedBox(height: 6),
                Text(
                  'Please check your inbox and Spam/Junk folder.',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
