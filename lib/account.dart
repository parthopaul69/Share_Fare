import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'login.dart';
import 'ride_service.dart';
import 'models.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  String _calcSaved(RideService rs, String? userId) {
    if (userId == null) return '0';
    double total = 0;
    for (TripHistoryItem item in rs.userTrips(userId)) {
      total += item.fare;
    }
    return total.round().toString();
  }

  Widget _tile(IconData icon, String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppUser? user = AuthService().currentUser;
    RideService rs = RideService();
    List<TripHistoryItem> trips = user != null ? rs.userTrips(user.id) : <TripHistoryItem>[];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text('Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 14),
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Text(
                      user != null && user.name.isNotEmpty ? user.name[0] : 'U',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(user?.email ?? '', style: TextStyle(fontSize: 12, color: Colors.white)),
                        Text(user?.gender ?? 'Male', style: TextStyle(fontSize: 11, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14),
            Text('ShareFare Wallet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(Icons.check_circle_outline, size: 20, color: Colors.black),
                      SizedBox(height: 4),
                      Text('${trips.length}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Trips', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  Container(width: 1, height: 32, color: Colors.black),
                  Column(
                    children: [
                      Icon(Icons.payments_outlined, size: 20, color: Colors.black),
                      SizedBox(height: 4),
                      Text('৳${_calcSaved(rs, user?.id)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Saved', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            _tile(Icons.info_outline, 'About ShareFare', 'Version 1.0 • Road Rides Only'),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  elevation: 0,
                ),
                icon: Icon(Icons.logout, size: 18),
                label: Text('Sign Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  NavigatorState nav = Navigator.of(context);
                  await AuthService().signOut();
                  nav.pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
