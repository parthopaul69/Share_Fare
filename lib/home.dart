import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'ride_details.dart';
import 'new_ride.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('ShareFare'),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('AVAILABLE RIDE', style: TextStyle(fontSize: 30, color: Colors.white),),

            SizedBox(height: 20),

            Text('DMD -> GULSHAN', style: TextStyle(fontSize: 20, color: Colors.white),),
            Text('Today - 2:00 PM - 2 Seats', style: TextStyle(color: Colors.white),),
            Text('Rafiul Hasan', style: TextStyle(color: Colors.white),),
            ElevatedButton(onPressed:() {
              Navigator.push(context, MaterialPageRoute(builder: (context) => RideDetails()));
            }, child: Text('VIEW')),

            SizedBox(height: 20),

            Text('AUST -> MIRPUR', style: TextStyle(fontSize: 20, color: Colors.white),),
            Text('Today - 4:30 PM - 3 Seats', style: TextStyle(color: Colors.white),),
            Text('Nusrat Jahan', style: TextStyle(color: Colors.white),),
            ElevatedButton(onPressed:() {
              Navigator.push(context, MaterialPageRoute(builder: (context) => RideDetails()));
            }, child: Text('View')),

            SizedBox(height: 20),

            Text('TEJGAON -> DMD', style: TextStyle(fontSize: 20, color: Colors.white),),
            Text('Today - 7:30 PM - 2 Seats', style: TextStyle(color: Colors.white),),
            Text('Nigesh Rif', style: TextStyle(color: Colors.white),),
            ElevatedButton(onPressed:() {
              Navigator.push(context, MaterialPageRoute(builder: (context) => RideDetails()));
            }, child: Text('VIEW')),

            SizedBox(height: 20),

            ElevatedButton(onPressed:() {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NewRide()));
            }, child: Text('+  NEW RIDE')),
          ],
        ),
      ),
    );
  }
}

