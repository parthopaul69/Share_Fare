import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'ride_service.dart';
import 'auth_service.dart';
import 'active_ride.dart';

class RideDetails extends StatefulWidget {
  final RideOffer? offer;
  const RideDetails({super.key, this.offer});

  @override
  State<RideDetails> createState() => _RideDetailsState();
}

class _RideDetailsState extends State<RideDetails> {
  String pin = '';
  bool pinErr = false;
  String? errMsg;

  @override
  Widget build(BuildContext context) {
    RideService rs = RideService();
    AppUser? user = AuthService().currentUser;

    RideOffer ride = widget.offer ?? rs.availableOffers[0];
    if (widget.offer != null) {
      RideOffer? fresh = rs.getOfferById(widget.offer!.id);
      if (fresh != null) {
        ride = fresh;
      }
    }

    bool isCreator = user != null && ride.creatorId == user.id;
    bool isJoined = user != null && rs.isAlreadyJoined(ride.id, user.id);
    JoinedFinder? myRec = user != null ? rs.getMyFinderRecord(ride.id, user.id) : null;
    bool isFull = ride.availableSeats <= 0 && !isJoined;
    bool done = ride.isCompleted;
    bool canJoin = user != null ? canAcceptGender(ride.genderPreference, user.gender) : true;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
        actions: [
          if (isCreator && !done)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                rs.deleteRide(ride.id);
                Navigator.pop(context);
              },
            ),
          if (isJoined && !done && myRec != null && myRec.canCancel)
            IconButton(
              icon: Icon(Icons.cancel_outlined, color: Colors.red),
              onPressed: () {
                rs.cancelAcceptance(ride.id, user.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            if (done) _alertBox('This ride has been completed.'),
            if (isFull && !done) _alertBox('This ride is full. No more finders can join.'),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Text(
                    ride.creatorName.isNotEmpty ? ride.creatorName[0] : 'R',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.creatorName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(ride.creatorGender, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Chip(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.black),
                  label: Text(
                    ride.genderPreference,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: Colors.black),
            Text('Route', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(ride.origin, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Pickup', style: TextStyle(fontSize: 11)),
            SizedBox(height: 8),
            Text(ride.destination, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Drop-off', style: TextStyle(fontSize: 11)),
            Divider(height: 24, color: Colors.black),
            Text('Ride Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            _row(Icons.schedule, 'Departure', ride.departureTime),
            _row(getVehicleIcon(ride.vehicleType), 'Vehicle', ride.vehicleType),
            _row(Icons.payments_outlined, 'Total Cost', '৳${ride.totalPrice.round()}'),
            _row(
              Icons.people_outline,
              'Seats Filled',
              '${ride.activeFinders.length}/${ride.maxFinders} finders joined',
            ),
            _row(
              Icons.calculate_outlined,
              'Your Share',
              '৳${ride.splitFare.round()} (split equally with ${ride.totalPeople} people)',
            ),
            if (ride.notes.isNotEmpty) _row(Icons.note_outlined, 'Note', ride.notes),
            Divider(height: 24, color: Colors.black),
            if (isCreator) ...[
              Text(
                'Joined Finders (${ride.activeFinders.length}/${ride.maxFinders})',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (ride.activeFinders.isEmpty)
                Text('No finders have joined yet. Waiting...', style: TextStyle(fontSize: 13))
              else
                for (JoinedFinder finder in ride.activeFinders)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text(
                        finder.userName.isNotEmpty ? finder.userName[0] : 'F',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(finder.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${finder.gender} • ${finder.userPhone}'),
                    trailing: Text(
                      finder.bothVerified ? 'Verified' : (finder.riderVerifiedFinder ? 'You verified' : 'Pending'),
                      style: TextStyle(
                        color: finder.bothVerified ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              Divider(height: 24, color: Colors.black),
            ],
            if (!isCreator && !done) ...[
              if (!isJoined && !isFull) ...[
                Text('Join This Ride', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  'You will pay ৳${ride.splitFare.round()} and share the ride from ${ride.origin} to ${ride.destination}.',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 10),
                if (!canJoin) ...[
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ride.genderPreference.toLowerCase().contains('girl')
                          ? 'Girl Ride — Only female accounts can accept this ride.'
                          : 'Boy Ride — Only male accounts can accept this ride.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canJoin ? Colors.black : Colors.white,
                      foregroundColor: canJoin ? Colors.white : Colors.black,
                      side: BorderSide(color: Colors.black),
                    ),
                    onPressed: () {
                      if (!canJoin) {
                        setState(() {
                          errMsg = 'Cannot accept: This ride is for ${ride.genderPreference}.';
                        });
                        return;
                      }
                      if (user == null) return;
                      if (rs.hasActivePost(user.id)) {
                        setState(() {
                          errMsg =
                              'You already have an active route post. You cannot accept another ride at the same time.';
                        });
                        return;
                      }
                      if (rs.hasActiveFinderRide(user.id)) {
                        setState(() {
                          errMsg = 'You already have an active accepted ride.';
                        });
                        return;
                      }
                      bool ok = rs.acceptRide(ride.id, user);
                      if (!ok) {
                        setState(() {
                          errMsg = 'Cannot accept this ride (${ride.genderPreference}).';
                        });
                        return;
                      }
                      setState(() {
                        errMsg = null;
                      });
                    },
                    child: Text(
                      canJoin
                          ? 'ACCEPT RIDE — ৳${ride.splitFare.round()} your share'
                          : '${ride.genderPreference.toUpperCase()} — CANNOT JOIN',
                    ),
                  ),
                ),
                if (errMsg != null) ...[
                  SizedBox(height: 8),
                  Text(errMsg!, style: TextStyle(color: Colors.red, fontSize: 13)),
                ],
              ],
              if (isJoined && myRec != null) ...[_joinedSection(ride, myRec, rs, user)],
              Divider(height: 24, color: Colors.black),
            ],
            if (isCreator && !done) ...[
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ActiveRideScreen()));
                  },
                  child: Text('MANAGE ACTIVE RIDE'),
                ),
              ),
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
                    rs.deleteRide(ride.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _joinedSection(RideOffer ride, JoinedFinder myRec, RideService rs, AppUser? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text('You have accepted this ride', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(
            myRec.canCancel
                ? 'You can cancel within ${myRec.cancelSecondsLeft ~/ 60}m ${myRec.cancelSecondsLeft % 60}s'
                : 'Cancellation window has passed (5 min limit)',
            style: TextStyle(fontSize: 11, color: myRec.canCancel ? Colors.red : Colors.black),
          ),
        ),
        SizedBox(height: 10),
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
              Text(ride.creatorPhone, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: ride.creatorPhone));
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
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your PIN — Share with Rider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              SizedBox(height: 4),
              Text(myRec.finderPin, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8)),
              SizedBox(height: 2),
              Text('Tell the rider this code to verify you.', style: TextStyle(fontSize: 11)),
              if (myRec.riderVerifiedFinder)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '✓ Rider has verified you',
                    style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 10),
        if (!myRec.finderVerifiedRider) ...[
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: pinErr ? Colors.red : Colors.black),
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
                      pin = value;
                      pinErr = false;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '0000',
                    counterText: '',
                    errorText: pinErr ? 'Incorrect PIN' : null,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                    onPressed: () {
                      if (user == null) return;
                      bool ok = rs.finderVerifyRider(ride.id, user.id, pin);
                      setState(() {
                        pinErr = !ok;
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
              'You verified the rider\'s PIN. Waiting for rider to verify yours.',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        if (myRec.bothVerified)
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
            child: Text(
              'Both PINs verified! Ride is ready to start.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _alertBox(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 13)),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black),
          SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
