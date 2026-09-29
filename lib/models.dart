import 'package:flutter/material.dart';

int vehicleMaxTotal(String type) {
  if (type == 'CNG') return 3;
  if (type == 'Rickshaw') return 2;
  return 4;
}

int vehicleMaxFinders(String type) {
  return vehicleMaxTotal(type) - 1;
}

IconData getVehicleIcon(String type) {
  if (type == 'CNG') return Icons.local_gas_station;
  if (type == 'Rickshaw') return Icons.electric_rickshaw;
  return Icons.directions_car;
}

bool canAcceptGender(String pref, String gender) {
  var p = pref.trim().toLowerCase();
  var g = gender.trim().toLowerCase();
  if (p == 'anyone' || p == 'any' || p.isEmpty) return true;
  if (p == 'boy' || p == 'boys' || p == 'male' || p == 'boys only') {
    return g == 'male' || g == 'boy';
  }
  if (p == 'girl' || p == 'girls' || p == 'female' || p == 'girls only') {
    return g == 'female' || g == 'girl';
  }
  return false;
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final double rating;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '+880 1712-345678',
    this.gender = 'Male',
    this.rating = 0.0,
  });
}

class JoinedFinder {
  final String userId;
  final String userName;
  final String userPhone;
  final String gender;
  final String finderPin;
  final DateTime joinedAt;
  bool finderVerifiedRider;
  bool riderVerifiedFinder;
  bool hasCanceled;

  JoinedFinder({
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.gender,
    required this.finderPin,
    required this.joinedAt,
    this.finderVerifiedRider = false,
    this.riderVerifiedFinder = false,
    this.hasCanceled = false,
  });

  bool get canCancel {
    return DateTime.now().difference(joinedAt).inMinutes < 5;
  }

  int get cancelSecondsLeft {
    var s = 300 - DateTime.now().difference(joinedAt).inSeconds;
    return s > 0 ? s : 0;
  }

  bool get bothVerified {
    return finderVerifiedRider && riderVerifiedFinder;
  }
}

class RideOffer {
  final String id;
  final String creatorId;
  final String creatorName;
  final String creatorPhone;
  final String creatorGender;
  final double creatorRating;
  final String origin;
  final String destination;
  final String? viaStops;
  final String departureTime;
  final int maxFinders;
  final double totalPrice;
  final String genderPreference;
  final String vehicleType;
  final String notes;
  final String riderPin;
  bool isCompleted;
  bool isRideStarted;
  final List<JoinedFinder> joinedFinders;

  RideOffer({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.creatorPhone,
    this.creatorGender = 'Male',
    this.creatorRating = 4.95,
    required this.origin,
    required this.destination,
    this.viaStops,
    required this.departureTime,
    required this.maxFinders,
    required this.totalPrice,
    this.genderPreference = 'Anyone',
    required this.vehicleType,
    this.notes = '',
    required this.riderPin,
    this.isCompleted = false,
    this.isRideStarted = false,
    List<JoinedFinder>? joinedFinders,
  }) : joinedFinders = joinedFinders ?? [];

  List<JoinedFinder> get activeFinders {
    List<JoinedFinder> list = [];
    for (var f in joinedFinders) {
      if (!f.hasCanceled) {
        list.add(f);
      }
    }
    return list;
  }

  int get availableSeats {
    return maxFinders - activeFinders.length;
  }

  int get totalPeople {
    return activeFinders.length + 1;
  }

  double get splitFare {
    return totalPrice / totalPeople;
  }
}

class TripHistoryItem {
  final String id;
  final String userId;
  final String origin;
  final String destination;
  final String dateText;
  final double fare;
  final String vehicleName;
  final String coTravelers;

  const TripHistoryItem({
    required this.id,
    this.userId = 'demo_user',
    required this.origin,
    required this.destination,
    required this.dateText,
    required this.fare,
    required this.vehicleName,
    this.coTravelers = '',
  });
}

const List<String> kDhakaPlaces = [
  'Adabor',
  'Agargaon',
  'Airport Road',
  'Ashulia',
  'AUST Campus',
  'Azimpur',
  'Badda',
  'Banani',
  'Banani 11',
  'Banasree',
  'Banglamotor',
  'Baridhara',
  'Baridhara DOHS',
  'Bashundhara City',
  'Bashundhara R/A',
  'Bijoynagar',
  'Bosila',
  'BUET Campus',
  'Cantonment',
  'Chasara',
  'Chawkbazar',
  'Demra',
  'Dhaka University',
  'Dhanmondi',
  'Dhanmondi 27',
  'Dhanmondi 32',
  'Dilkusha',
  'Farmgate',
  'Fatullah',
  'Gabtoli',
  'Gandaria',
  'Gazipur Bypass',
  'Gulshan 1',
  'Gulshan 2',
  'Hatirjheel',
  'Hazaribagh',
  'Jatrabari',
  'Joar Sahara',
  'Kafrul',
  'Kakrail',
  'Kalabagan',
  'Kalyanpur',
  'Kamalapur',
  'Karwan Bazar',
  'Kazipara',
  'Keraniganj',
  'Khilgaon',
  'Khilkhet',
  'Kuril Flyover',
  'Lalbagh',
  'Lalmatia',
  'Malibagh',
  'Mirpur 1',
  'Mirpur 2',
  'Mirpur 10',
  'Mirpur 11',
  'Mirpur 12',
  'Mirpur 14',
  'Mohammadpur',
  'Motijheel',
  'Mouchak',
  'Narayanganj',
  'New Market',
  'Niketan',
  'Old Dhaka',
  'Pallabi',
  'Paltan',
  'Panthapath',
  'Rampura',
  'Rayer Bazar',
  'Sadarghat',
  'Savar',
  'Sayedabad',
  'Shahbagh',
  'Shantinagar',
  'Shewrapara',
  'Shyamoli',
  'Signboard',
  'Sutrapur',
  'Tejgaon',
  'Tejgaon I/A',
  'Tongi',
  'TSC',
  'Uttara Sector 1',
  'Uttara Sector 3',
  'Uttara Sector 7',
  'Uttara Sector 10',
  'Uttara Sector 11',
  'Uttara Sector 14',
  'Vatara',
  'Wari',
  'Zigatola',
];
