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

  Widget _btn(String name, IconData icon, bool sel, VoidCallback tap) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: sel ? Colors.black : Colors.white,
          foregroundColor: sel ? Colors.white : Colors.black,
          side: BorderSide(color: Colors.black),
          padding: EdgeInsets.symmetric(vertical: 8),
        ),
        onPressed: tap,
        child: Column(
          children: [
            Icon(icon, size: 18),
            SizedBox(height: 2),
            Text(name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post a Route')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text('Post a Route', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Set your route and let finders join to split the cost.', style: TextStyle(fontSize: 13)),
            SizedBox(height: 16),
            _placeTile('Pickup / Start Location', origin, 'e.g. Dhanmondi 27', () => _pickPlace(true)),
            SizedBox(height: 12),
            _placeTile('Destination', dest, 'e.g. Gulshan 2 Circle', () => _pickPlace(false)),
            SizedBox(height: 16),
            Text('Vehicle Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Row(
              children: [
                _btn('Car', Icons.directions_car, vehicle == 'Car', () {
                  setState(() {
                    vehicle = 'Car';
                  });
                }),
                SizedBox(width: 6),
                _btn('CNG', Icons.local_gas_station, vehicle == 'CNG', () {
                  setState(() {
                    vehicle = 'CNG';
                    if (finders > maxFinders) {
                      finders = maxFinders;
                    }
                  });
                }),
                SizedBox(width: 6),
                _btn('Rickshaw', Icons.electric_rickshaw, vehicle == 'Rickshaw', () {
                  setState(() {
                    vehicle = 'Rickshaw';
                    if (finders > maxFinders) {
                      finders = maxFinders;
                    }
                  });
                }),
              ],
            ),
            SizedBox(height: 16),
            Text('Who Can Join You?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Row(
              children: [
                _btn('Boy', Icons.male, gender == 'Boy', () {
                  setState(() {
                    gender = 'Boy';
                  });
                }),
                SizedBox(width: 4),
                _btn('Girl', Icons.female, gender == 'Girl', () {
                  setState(() {
                    gender = 'Girl';
                  });
                }),
                SizedBox(width: 4),
                _btn('Anyone', Icons.people, gender == 'Anyone', () {
                  setState(() {
                    gender = 'Anyone';
                  });
                }),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Co-travelers Needed', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('Max $maxFinders finders for $vehicle', style: TextStyle(fontSize: 11)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: Colors.black),
                      onPressed: finders > 1
                          ? () {
                              setState(() {
                                finders--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      '$finders Person${finders > 1 ? 's' : ''}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.black),
                      onPressed: finders < maxFinders
                          ? () {
                              setState(() {
                                finders++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Total Ride Cost', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text('Enter full fare (minimum ৳10). Split equally.', style: TextStyle(fontSize: 11)),
            SizedBox(height: 6),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                setState(() {
                  price = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'e.g. 300',
                prefixText: price.isEmpty ? null : '৳ ',
                prefixIcon: Icon(Icons.payments_outlined, size: 20, color: Colors.black),
              ),
            ),
            SizedBox(height: 16),
            _placeTile('Departure Time', time, 'Tap to select date & time', _pickTime),
            SizedBox(height: 16),
            Text('Notes (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            TextField(
              maxLines: 2,
              onChanged: (String value) {
                setState(() {
                  notes = value;
                });
              },
              decoration: InputDecoration(hintText: 'Any details: meeting spot, luggage, etc.'),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                onPressed: posting ? null : _publish,
                child: posting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('PUBLISH ROUTE POST'),
              ),
            ),
            if (errMsg != null) ...[
              SizedBox(height: 8),
              Text(
                errMsg!,
                style: TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PlacePicker extends StatefulWidget {
  final String title;
  const _PlacePicker({required this.title});

  @override
  State<_PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<_PlacePicker> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    List<String> filtered = [];
    String q = search.trim().toLowerCase();
    for (String place in kDhakaPlaces) {
      if (q.isEmpty || place.toLowerCase().contains(q)) {
        filtered.add(place);
      }
    }

    bool isPickup = widget.title.toLowerCase().contains('pickup');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                isPickup ? 'Choose where your ride starts in Dhaka' : 'Choose your ride destination in Dhaka',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                cursorColor: Colors.black,
                onChanged: (String value) {
                  setState(() {
                    search = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: isPickup ? 'Search pickup location...' : 'Search destination location...',
                  prefixIcon: Icon(Icons.search, size: 20, color: Colors.black),
                  suffixIcon: search.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, size: 18, color: Colors.black),
                          onPressed: () {
                            setState(() {
                              search = '';
                            });
                          },
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ),
            if (search.trim().isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.pop(context, search.trim()),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Icon(Icons.edit_location_alt, size: 20, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Use "${search.trim()}"',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text('Custom location', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 36, color: Colors.black),
                          SizedBox(height: 8),
                          Text('No Dhaka location found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Tap custom location above to use "$search"', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (BuildContext context, int index) {
                        String place = filtered[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => Navigator.pop(context, place),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.place_outlined, size: 20, color: Colors.black),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(place, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ),
                                  Icon(Icons.chevron_right, size: 18, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  final RideOffer offer;
  const _SuccessScreen({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Icon(Icons.check_circle, size: 52, color: Colors.green),
              SizedBox(height: 14),
              Text('Route Posted!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('${offer.origin} → ${offer.destination}', style: TextStyle(fontSize: 14)),
              SizedBox(height: 20),
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
                    Text('Your Rider PIN', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text(offer.riderPin, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8)),
                    SizedBox(height: 2),
                    Text('Finders will enter this PIN to verify you. Keep it safe.', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text('BACK TO HOME'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
