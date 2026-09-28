import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'ride_service.dart';
import 'models.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppUser? user = AuthService().currentUser;
    List<TripHistoryItem> trips = user != null ? RideService().userTrips(user.id) : [];

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Activity', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Your completed road trips', style: TextStyle(fontSize: 13)),
          SizedBox(height: 16),
          if (trips.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 56, color: Colors.black),
                    SizedBox(height: 12),
                    Text('No trips yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Completed trips will appear here.', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            for (TripHistoryItem item in trips)
              Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.black),
                ),
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(getVehicleIcon(item.vehicleName), size: 20, color: Colors.black),
                              SizedBox(width: 8),
                              Text(item.vehicleName, style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 6),
                              Text(item.dateText, style: TextStyle(fontSize: 11)),
                            ],
                          ),
                          Text('৳${item.fare.round()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('● ${item.origin}', style: TextStyle(fontSize: 13)),
                      SizedBox(height: 4),
                      Text('📍 ${item.destination}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      if (item.coTravelers.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text('Co-traveler: ${item.coTravelers}', style: TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
