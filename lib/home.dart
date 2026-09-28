import 'package:flutter/material.dart';

import 'models.dart';
import 'ride_service.dart';
import 'auth_service.dart';
import 'activity.dart';
import 'account.dart';
import 'new_ride.dart';
import 'ride_details.dart';
import 'active_ride.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;

  @override
  void initState() {
    super.initState();
    RideService().addListener(_refresh);
  }

  @override
  void dispose() {
    RideService().removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    RideService rs = RideService();
    AppUser? user = AuthService().currentUser;
    bool hasPost = user != null && rs.hasActivePost(user.id);
    bool hasAccepted = user != null && rs.hasActiveFinderRide(user.id);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: tab,
              children: [
                HomeFeed(),
                ActivityScreen(),
                AccountScreen(),
              ],
            ),
          ),
          if (hasPost) _banner('Your Route Post is Active'),
          if (hasAccepted) _banner('Ride Accepted'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (int index) {
          setState(() {
            tab = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  Widget _banner(String text) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ActiveRideScreen()));
            },
            child: Text(
              'VIEW',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  String query = '';
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    RideService rs = RideService();
    AppUser? user = AuthService().currentUser;

    List<RideOffer> offers = [];
    for (RideOffer offer in rs.availableOffers) {
      if (offer.isCompleted) continue;
      if (offer.availableSeats <= 0 && (user == null || !rs.isAlreadyJoined(offer.id, user.id))) {
        continue;
      }
      if (query.isNotEmpty) {
        String q = query.toLowerCase();
        if (!offer.origin.toLowerCase().contains(q) && !offer.destination.toLowerCase().contains(q)) {
          continue;
        }
      }
      if (filter == 'Girl' && !offer.genderPreference.toLowerCase().contains('girl')) {
        continue;
      }
      if (filter == 'Boy' && !offer.genderPreference.toLowerCase().contains('boy')) {
        continue;
      }
      offers.add(offer);
    }

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('ShareFare', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(
            user != null ? 'Hello, ${user.name.split(' ').first}' : 'Dhaka Road Rides',
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 14),
          TextField(
            onChanged: (String value) {
              setState(() {
                query = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search pickup or destination...',
              prefixIcon: Icon(Icons.search, size: 20, color: Colors.black),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, size: 18, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          query = '';
                        });
                      },
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterBtn('All', Icons.tune),
                SizedBox(width: 8),
                _filterBtn('Boy', Icons.male),
                SizedBox(width: 8),
                _filterBtn('Girl', Icons.female),
              ],
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _actionCard('Post a Route', 'Find co-traveler, split fare', Icons.add_road, () async {
                  if (user != null && (rs.hasActivePost(user.id) || rs.hasActiveFinderRide(user.id))) {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => PostWarnScreen()));
                  } else {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => NewRide()));
                  }
                  if (mounted) {
                    setState(() {});
                  }
                }),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _actionCard('How It Works', 'Learn fare splitting', Icons.info_outline, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HowItWorksScreen()));
                }),
              ),
            ],
          ),
          SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Rides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${offers.length} found', style: TextStyle(fontSize: 12)),
            ],
          ),
          SizedBox(height: 10),
          if (offers.isEmpty)
            Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No rides found', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          else
            for (RideOffer offer in offers) _rideCard(offer, user, rs),
        ],
      ),
    );
  }

  Widget _filterBtn(String name, IconData icon) {
    bool sel = filter == name;
    return ChoiceChip(
      avatar: Icon(icon, size: 14, color: sel ? Colors.white : Colors.black),
      label: Text(
        name,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: sel ? Colors.white : Colors.black),
      ),
      selected: sel,
      selectedColor: Colors.black,
      backgroundColor: Colors.white,
      onSelected: (bool selected) {
        setState(() {
          filter = name;
        });
      },
    );
  }

  Widget _actionCard(String title, String desc, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.black,
              child: Icon(icon, color: Colors.white, size: 15),
            ),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(height: 2),
            Text(desc, style: TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _rideCard(RideOffer offer, AppUser? user, RideService rs) {
    bool isOwn = user != null && offer.creatorId == user.id;
    bool isJoined = user != null && rs.isAlreadyJoined(offer.id, user.id);

    return Card(
      margin: EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.black),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => RideDetails(offer: offer)));
          if (mounted) {
            setState(() {});
          }
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(offer.creatorName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      if (isOwn) ...[
                        SizedBox(width: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            'YOU',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ] else if (isJoined) ...[
                        SizedBox(width: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            'JOINED',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(offer.genderPreference, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Text(offer.vehicleType, style: TextStyle(fontSize: 11)),
              SizedBox(height: 8),
              Text('● ${offer.origin}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              SizedBox(height: 3),
              Text('📍 ${offer.destination}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '৳${offer.splitFare.round()} / person',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(offer.departureTime, style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  if (isOwn)
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      icon: Icon(Icons.delete_outline, size: 16),
                      label: Text('Delete Post', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        rs.deleteRide(offer.id);
                        setState(() {});
                      },
                    )
                  else if (isJoined)
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      icon: Icon(Icons.close, size: 16),
                      label: Text('Cancel Acceptance', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        rs.cancelAcceptance(offer.id, user.id);
                        setState(() {});
                      },
                    )
                  else
                    Icon(Icons.chevron_right, size: 20, color: Colors.black),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('How It Works')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Smart Road Rides & Shared Fares', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('ShareFare helps you split road travel costs in Dhaka safely.', style: TextStyle(fontSize: 13)),
          SizedBox(height: 16),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              child: Text('1', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
            title: Text('Post or Browse Routes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Find rides in your route or post your route.', style: TextStyle(fontSize: 12)),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              child: Text('2', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
            title: Text('Join & Connect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Accept a ride and coordinate with co-travelers.', style: TextStyle(fontSize: 12)),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              child: Text('3', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
            title: Text('Verify with 4-Digit PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Exchange secret PINs before starting the trip.', style: TextStyle(fontSize: 12)),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              child: Text('4', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
            title: Text('Split Fairly & Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Cost is divided equally between all travelers.', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class PostWarnScreen extends StatelessWidget {
  const PostWarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Active Post')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.black),
              SizedBox(height: 16),
              Text('Active Ride in Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                'You already have an active post or accepted ride. Please complete or cancel it first.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
