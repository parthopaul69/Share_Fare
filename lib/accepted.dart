import 'package:flutter/material.dart';

class Accepted extends StatelessWidget {
  const Accepted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle, color: Colors.white,
              size: 80,
            ),

            Text('Ride Accepted!', style: TextStyle(fontSize: 25, color: Colors.white),),
            Text('The rider has been notified.', style: TextStyle(color: Colors.white),),

            SizedBox(height: 20),
            
            ElevatedButton(onPressed:() {
              Navigator.pop(context);
            }, child: Text('GO BACK'))
          ],
        ),
      ),
    );
  }
}
