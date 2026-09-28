import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ride_details.dart';
import 'new_ride.dart';
import 'login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('email');
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ShareFare'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_userEmail != null) ...[
                Text(
                  'Logged in as: $_userEmail',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
              ],
              const Text(
                'AVAILABLE RIDE',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'DMD -> GULSHAN',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const Text(
                'Today - 2:00 PM - 2 Seats',
                style: TextStyle(color: Colors.white),
              ),
              const Text(
                'Rafiul Hasan',
                style: TextStyle(color: Colors.white),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RideDetails()),
                  );
                },
                child: const Text('VIEW'),
              ),
              const SizedBox(height: 20),
              const Text(
                'AUST -> MIRPUR',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const Text(
                'Today - 4:30 PM - 3 Seats',
                style: TextStyle(color: Colors.white),
              ),
              const Text(
                'Nusrat Jahan',
                style: TextStyle(color: Colors.white),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RideDetails()),
                  );
                },
                child: const Text('View'),
              ),
              const SizedBox(height: 20),
              const Text(
                'TEJGAON -> DMD',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const Text(
                'Today - 7:30 PM - 2 Seats',
                style: TextStyle(color: Colors.white),
              ),
              const Text(
                'Nigesh Rif',
                style: TextStyle(color: Colors.white),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RideDetails()),
                  );
                },
                child: const Text('VIEW'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewRide()),
                  );
                },
                child: const Text('+  NEW RIDE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
