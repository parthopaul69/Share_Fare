import 'package:flutter/material.dart';

import 'models.dart';
import 'ride_service.dart';
import 'auth_service.dart';
import 'home.dart';

class NewRide extends StatefulWidget {
  const NewRide({super.key});

  @override
  State<NewRide> createState() => _NewRideState();
}

class _NewRideState extends State<NewRide> {
  String origin = '';
  String dest = '';
  String vehicle = 'Car';
  String gender = 'Anyone';
  String notes = '';
  String price = '';
  String time = '';
  int finders = 1;
  bool posting = false;
  String? errMsg;

  int get maxFinders => vehicleMaxFinders(vehicle);

  void _pickTime() async {
    DateTime now = DateTime.now();
    DateTime? d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 30)),
    );
    if (d == null || !mounted) return;

    TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null || !mounted) return;

    int hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    String min = t.minute.toString().padLeft(2, '0');
    String period = t.period == DayPeriod.am ? 'AM' : 'PM';
    int diff = DateTime(d.year, d.month, d.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    String dayText = diff == 0 ? 'Today' : (diff == 1 ? 'Tomorrow' : '${d.day}/${d.month}');

    setState(() {
      time = '$dayText • $hour:$min $period';
    });
  }

  void _pickPlace(bool isOrigin) async {
    String? res = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => _PlacePicker(title: isOrigin ? 'Select Pickup' : 'Select Destination')),
    );
    if (res != null) {
      setState(() {
        if (isOrigin) {
          origin = res;
        } else {
          dest = res;
        }
      });
    }
  }

  void _err(String msg) {
    setState(() {
      errMsg = msg;
    });
  }

  void _publish() {
    if (origin.trim().isEmpty) {
      _err('Please enter your pickup location.');
      return;
    }
    if (dest.trim().isEmpty) {
      _err('Please enter your destination.');
      return;
    }
    if (origin.trim().toLowerCase() == dest.trim().toLowerCase()) {
      _err('Pickup and destination cannot be the same place.');
      return;
    }
    if (price.trim().isEmpty) {
      _err('Please enter the total ride cost.');
      return;
    }
    if (time.trim().isEmpty) {
      _err('Please select a departure time.');
      return;
    }

    double? p = double.tryParse(price.trim());
    if (p == null || p < 10) {
      _err('Please enter a valid total cost (minimum ৳10).');
      return;
    }

    AppUser? user = AuthService().currentUser;
    if (user == null) {
      _err('Please sign in to post a route.');
      return;
    }

    setState(() {
      posting = true;
    });

    RideService rs = RideService();
    RideOffer offer = RideOffer(
      id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
      creatorId: user.id,
      creatorName: user.name,
      creatorPhone: user.phone,
      creatorGender: user.gender,
      creatorRating: user.rating,
      origin: origin.trim(),
      destination: dest.trim(),
      departureTime: time.trim(),
      maxFinders: finders,
      totalPrice: p,
      genderPreference: gender,
      vehicleType: vehicle,
      notes: notes.trim(),
      riderPin: rs.generateUniquePin(),
    );

    rs.postRide(offer);
    setState(() {
      posting = false;
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => _SuccessScreen(offer: offer)));
  }

  Widget _placeTile(String label, String value, String hint, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.isEmpty ? hint : value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: value.isEmpty ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

