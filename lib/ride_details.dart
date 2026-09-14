import 'package:flutter/material.dart';
import 'accepted.dart';

class RideDetails extends StatelessWidget {
  const RideDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('RIDE DETAILS'),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nigesh Rif', style: TextStyle(fontSize: 25, color: Colors.white),),
            Text('⭐  3.8', style: TextStyle(color: Colors.white),),

            SizedBox(height: 20),

            Text('TEJGAON -> DMD', style: TextStyle(fontSize: 22, color: Colors.white),),
            Text('Today - 7:30 PM', style: TextStyle(color: Colors.white),),
            Text('2 Seats', style: TextStyle(color: Colors.white),),
            Text('Ride Time: 35 Minutes', style: TextStyle(color: Colors.white),),

            SizedBox(height: 20),

            ElevatedButton(onPressed:() {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Accepted()));
            }, child: Text('ACCEPT RIDE')),
          ],
        ),
      ),
    );
  }
}
