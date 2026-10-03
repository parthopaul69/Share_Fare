import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'ride_service.dart';
import 'auth_service.dart';
import 'home.dart';

class ActiveRideScreen extends StatefulWidget {
  const ActiveRideScreen({super.key});

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  final Map<int, String> pins = {};
  final Map<int, bool> pinErrors = {};
  String riderPin = '';
  bool pinError = false;

  @override
  Widget build(BuildContext context) {
    RideService rs = RideService();
    AppUser? user = AuthService().currentUser;
    RideOffer? offer = rs.activeOffer;

    if (offer == null || user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Active Ride')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_car_outlined, size: 64, color: Colors.black),
              SizedBox(height: 16),
              Text('No active ride.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Post a route or accept a ride to see it here.', style: TextStyle(fontSize: 13)),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context),
                child: Text('GO BACK'),
              ),
            ],
          ),
        ),
      );
    }

    bool isRider = rs.isActiveAsRider && offer.creatorId == user.id;
    List<JoinedFinder> finders = offer.activeFinders;
    bool allVerified = rs.allVerified(offer.id);

    return Scaffold(
      appBar: AppBar(title: Text(isRider ? 'Manage Ride' : 'Your Accepted Ride')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(getVehicleIcon(offer.vehicleType), color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(offer.vehicleType, style: TextStyle(color: Colors.white, fontSize: 13)),
                      Spacer(),
                      Chip(
                        backgroundColor: Colors.black,
                        side: BorderSide(color: Colors.white),
                        label: Text(
                          offer.isRideStarted ? 'In Progress' : 'Waiting',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    offer.origin,
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '→ ${offer.destination}',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '৳${offer.splitFare.round()} / person • ${offer.departureTime}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (isRider) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Rider PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 4),
                    Text(offer.riderPin, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8)),
                    SizedBox(height: 2),
                    Text('Share with finders so they can verify you.', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              SizedBox(height: 14),
              Text('Co-Travelers (${finders.length})', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              if (finders.isEmpty)
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No co-travelers yet. Waiting for finders...', style: TextStyle(fontSize: 13)),
                )
              else
                for (int i = 0; i < finders.length; i++) _riderCard(finders[i], i, rs, offer.id),
              SizedBox(height: 14),
              if (finders.isNotEmpty && allVerified && !offer.isRideStarted)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                    onPressed: () {
                      rs.startRide(offer.id);
                      setState(() {});
                    },
                    child: Text('START RIDE'),
                  ),
                ),
              if (offer.isRideStarted)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () {
                      rs.finishRide(offer.id);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Text('FINISH TRIP'),
                  ),
                ),
              if (!offer.isRideStarted) ...[
                SizedBox(height: 8),
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
                    icon: Icon(Icons.delete_outline, size: 18),
                    label: Text('Delete Post', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      rs.deleteRide(offer.id);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ),
              ],
            ],
            if (!isRider) ...[_finderView(offer, user, rs)],
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _riderCard(JoinedFinder finder, int index, RideService rs, String offerId) {
    String cur = pins[index] ?? '';
    bool hasErr = pinErrors[index] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black,
                child: Text(
                  finder.userName.isNotEmpty ? finder.userName[0] : 'F',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(finder.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${finder.gender} • ${finder.userPhone}', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              if (finder.riderVerifiedFinder)
                Text(
                  'Verified',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                ),
            ],
          ),
          if (!finder.riderVerifiedFinder) ...[
            SizedBox(height: 8),
            Text(
              'Their PIN: ${finder.finderPin}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            SizedBox(height: 2),
            Text('Ask them for their PIN, then enter it here.', style: TextStyle(fontSize: 11)),
            SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    onChanged: (String value) {
                      setState(() {
                        pins[index] = value;
                        pinErrors[index] = false;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '0000',
                      counterText: '',
                      errorText: hasErr ? 'Wrong PIN' : null,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: () {
                    bool ok = rs.riderVerifyFinder(offerId, cur);
                    setState(() {
                      pinErrors[index] = !ok;
                    });
                  },
                  child: Text('Verify'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _finderView(RideOffer offer, AppUser user, RideService rs) {
    JoinedFinder? myRec = rs.getMyFinderRecord(offer.id, user.id);
    if (myRec == null) {
      return Text('No active ride found.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Finder PIN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(myRec.finderPin, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 8)),
              SizedBox(height: 4),
              Text('Tell the rider this code to verify you.', style: TextStyle(fontSize: 11)),
              if (myRec.riderVerifiedFinder)
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    '✓ Rider verified you!',
                    style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Text('Contact Rider', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(offer.creatorPhone, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: offer.creatorPhone));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Phone number copied')));
                },
                child: Text(
                  'Copy',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        if (!myRec.finderVerifiedRider) ...[
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: pinError ? Colors.red : Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter Rider\'s PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(height: 2),
                Text('Ask the rider for their 4-digit code.', style: TextStyle(fontSize: 11)),
                SizedBox(height: 6),
                TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  onChanged: (String value) {
                    setState(() {
                      riderPin = value;
                      pinError = false;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '0000',
                    counterText: '',
                    errorText: pinError ? 'Incorrect PIN' : null,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                    onPressed: () {
                      bool ok = rs.finderVerifyRider(offer.id, user.id, riderPin);
                      setState(() {
                        pinError = !ok;
                      });
                    },
                    child: Text('VERIFY RIDER PIN'),
                  ),
                ),
              ],
            ),
          ),
        ] else
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'You verified the rider\'s PIN.',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        if (myRec.bothVerified && offer.isRideStarted)
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
            child: Text(
              'Ride is in progress! Enjoy your trip.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        if (myRec.canCancel) ...[
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                elevation: 0,
              ),
              onPressed: () {
                bool ok = rs.cancelAcceptance(offer.id, user.id);
                if (ok) {
                  Navigator.pop(context);
                }
              },
              child: Text('Cancel Acceptance', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ],
    );
  }
}
