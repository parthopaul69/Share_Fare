import 'package:flutter/material.dart';
import 'successful_post.dart';

class NewRide extends StatelessWidget {
  const NewRide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('NEW RIDE'),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 300, child: TextField(decoration: InputDecoration(
              hint: Text('Start Location'), filled: true
            ),),),

            SizedBox(height: 20),

            SizedBox(width: 300, child: TextField(decoration: InputDecoration(
              hint: Text('Destination'), filled: true
            ),),),
            
            SizedBox(height: 20),
            
            SizedBox(width: 300, child: TextField(decoration: InputDecoration(
              hint: Text('Via (Optional)'), filled: true
            ),),),

            SizedBox(height: 20),
            
            ElevatedButton(onPressed:() {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessfulPost()));
            }, child: Text('POST RIDE'))
          ],
        ),
      ),
    );
  }
}
