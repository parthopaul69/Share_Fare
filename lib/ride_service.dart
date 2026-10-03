import 'package:flutter/material.dart';

import 'models.dart';

class RideService extends ChangeNotifier {
  static final RideService _instance = RideService._internal();
  factory RideService() => _instance;
  RideService._internal();

  static int _pin = 1000;
  String generateUniquePin() => (++_pin).toString();

  String? activeOfferId;
  String? activeUserId;
  bool isActiveAsRider = false;

  final List<TripHistoryItem> tripHistory = [
    const TripHistoryItem(
      id: 'TRIP-102',
      origin: 'Dhanmondi 27',
      destination: 'Gulshan 2 Circle',
      dateText: 'Today, 11:30 AM',
      fare: 150.0,
      vehicleName: 'Car',
      coTravelers: 'Rafiul Hasan',
    ),
    const TripHistoryItem(
      id: 'TRIP-101',
      origin: 'AUST Campus',
      destination: 'Mirpur 10',
      dateText: 'Yesterday, 5:15 PM',
      fare: 100.0,
      vehicleName: 'CNG',
      coTravelers: 'Nusrat Jahan',
    ),
    const TripHistoryItem(
      id: 'TRIP-100',
      origin: 'Tejgaon I/A',
      destination: 'Dhanmondi Lake',
      dateText: 'Sep 24, 8:00 PM',
      fare: 60.0,
      vehicleName: 'Rickshaw',
      coTravelers: 'Nigesh Rif',
    ),
  ];

  final List<RideOffer> availableOffers = [
    RideOffer(
      id: 'ride_1',
      creatorId: 'user_rafiul',
      creatorName: 'Rafiul Hasan',
      creatorPhone: '+880 1711-889900',
      creatorGender: 'Male',
      origin: 'Dhanmondi 27',
      destination: 'Gulshan 2 Circle',
      viaStops: 'Tejgaon Link Road',
      departureTime: 'Today • 2:00 PM',
      maxFinders: 3,
      totalPrice: 300.0,
      vehicleType: 'Car',
      notes: 'Going to Gulshan office. Looking for co-traveler.',
      riderPin: '7412',
    ),
    RideOffer(
      id: 'ride_2',
      creatorId: 'user_nusrat',
      creatorName: 'Nusrat Jahan',
      creatorPhone: '+880 1819-998877',
      creatorGender: 'Female',
      origin: 'Dhanmondi 27',
      destination: 'Gulshan 2 Circle',
      departureTime: 'Today • 3:30 PM',
      maxFinders: 1,
      totalPrice: 160.0,
      genderPreference: 'Girl',
      vehicleType: 'CNG',
      notes: 'Prefer female co-traveler.',
      riderPin: '5293',
    ),
    RideOffer(
      id: 'ride_3',
      creatorId: 'user_nigesh',
      creatorName: 'Nigesh Rif',
      creatorPhone: '+880 1777-445566',
      creatorGender: 'Male',
      origin: 'Tejgaon I/A',
      destination: 'Dhanmondi Lake',
      departureTime: 'Today • 5:30 PM',
      maxFinders: 1,
      totalPrice: 120.0,
      genderPreference: 'Boy',
      vehicleType: 'Rickshaw',
      notes: 'Regular route, safe and fast.',
      riderPin: '6184',
    ),
    RideOffer(
      id: 'ride_4',
      creatorId: 'user_kazi',
      creatorName: 'Kazi Farhan',
      creatorPhone: '+880 1912-334455',
      creatorGender: 'Male',
      origin: 'Banani',
      destination: 'Uttara Sector 7',
      departureTime: 'Today • 6:00 PM',
      maxFinders: 1,
      totalPrice: 200.0,
      genderPreference: 'Boy',
      vehicleType: 'CNG',
      notes: 'Fast route via Kuril flyover.',
      riderPin: '3917',
    ),
  ];

  RideOffer? getOfferById(String id) {
    for (RideOffer offer in availableOffers) {
      if (offer.id == id) {
        return offer;
      }
    }
    return null;
  }

  RideOffer? get activeOffer {
    if (activeOfferId != null) {
      return getOfferById(activeOfferId!);
    }
    return null;
  }

  bool hasActivePost(String userId) {
    for (RideOffer offer in availableOffers) {
      if (offer.creatorId == userId && !offer.isCompleted) {
        return true;
      }
    }
    return false;
  }


  bool hasActiveFinderRide(String userId) {
    if (activeOfferId != null && activeUserId == userId && !isActiveAsRider) {
      RideOffer? offer = getOfferById(activeOfferId!);
      return offer != null && !offer.isCompleted;
    }
    return false;
  }

  JoinedFinder? getMyFinderRecord(String offerId, String userId) {
    RideOffer? offer = getOfferById(offerId);
    if (offer == null) return null;
    for (JoinedFinder finder in offer.joinedFinders) {
      if (finder.userId == userId && !finder.hasCanceled) {
        return finder;
      }
    }
    return null;
  }

  bool isAlreadyJoined(String offerId, String userId) {
    return getMyFinderRecord(offerId, userId) != null;
  }

  void postRide(RideOffer offer) {
    availableOffers.add(offer);
    activeOfferId = offer.id;
    activeUserId = offer.creatorId;
    isActiveAsRider = true;
    notifyListeners();
  }

  bool acceptRide(String offerId, AppUser finder) {
    if (hasActivePost(finder.id) || hasActiveFinderRide(finder.id)) {
      return false;
    }
    RideOffer? offer = getOfferById(offerId);
    if (offer == null || offer.availableSeats <= 0 || offer.isCompleted) {
      return false;
    }
    if (!canAcceptGender(offer.genderPreference, finder.gender)) {
      return false;
    }

    offer.joinedFinders.add(
      JoinedFinder(
        userId: finder.id,
        userName: finder.name,
        userPhone: finder.phone,
        gender: finder.gender,
        finderPin: generateUniquePin(),
        joinedAt: DateTime.now(),
      ),
    );

    activeOfferId = offerId;
    activeUserId = finder.id;
    isActiveAsRider = false;
    notifyListeners();
    return true;
  }

  bool cancelAcceptance(String offerId, String userId) {
    RideOffer? offer = getOfferById(offerId);
    if (offer != null) {
      for (int i = offer.joinedFinders.length - 1; i >= 0; i--) {
        if (offer.joinedFinders[i].userId == userId) {
          if (!offer.joinedFinders[i].canCancel) {
            return false;
          }
          offer.joinedFinders.removeAt(i);
        }
      }
    }
    if (activeOfferId == offerId) {
      activeOfferId = null;
      activeUserId = null;
      isActiveAsRider = false;
    }
    notifyListeners();
    return true;
  }

  bool finderVerifyRider(String offerId, String finderId, String enteredPin) {
    RideOffer? offer = getOfferById(offerId);
    if (offer == null || enteredPin.trim() != offer.riderPin) {
      return false;
    }
    for (JoinedFinder finder in offer.joinedFinders) {
      if (finder.userId == finderId) {
        finder.finderVerifiedRider = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  bool riderVerifyFinder(String offerId, String enteredPin) {
    RideOffer? offer = getOfferById(offerId);
    if (offer == null) return false;
    for (JoinedFinder finder in offer.joinedFinders) {
      if (!finder.hasCanceled && finder.finderPin == enteredPin.trim()) {
        finder.riderVerifiedFinder = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  bool allVerified(String offerId) {
    RideOffer? offer = getOfferById(offerId);
    if (offer == null || offer.activeFinders.isEmpty) {
      return false;
    }
    for (JoinedFinder finder in offer.activeFinders) {
      if (!finder.bothVerified) {
        return false;
      }
    }
    return true;
  }

  void startRide(String offerId) {
    RideOffer? offer = getOfferById(offerId);
    if (offer != null) {
      offer.isRideStarted = true;
      notifyListeners();
    }
  }

  void finishRide(String offerId) {
    RideOffer? offer = getOfferById(offerId);
    if (offer == null) return;
    offer.isCompleted = true;

    List<JoinedFinder> active = offer.activeFinders;
    String names = 'Solo';
    if (active.isNotEmpty) {
      List<String> finderNames = [];
      for (JoinedFinder finder in active) {
        finderNames.add(finder.userName);
      }
      names = finderNames.join(', ');
    }

    tripHistory.insert(
      0,
      TripHistoryItem(
        id: 'TRIP-${tripHistory.length + 200}',
        userId: offer.creatorId,
        origin: offer.origin,
        destination: offer.destination,
        dateText: 'Today',
        fare: offer.splitFare,
        vehicleName: offer.vehicleType,
        coTravelers: names,
      ),
    );

    for (JoinedFinder finder in active) {
      tripHistory.insert(
        0,
        TripHistoryItem(
          id: 'TRIP-${tripHistory.length + 200}',
          userId: finder.userId,
          origin: offer.origin,
          destination: offer.destination,
          dateText: 'Today',
          fare: offer.splitFare,
          vehicleName: offer.vehicleType,
          coTravelers: offer.creatorName,
        ),
      );
    }

    if (activeOfferId == offerId) {
      activeOfferId = null;
      activeUserId = null;
    }
    notifyListeners();
  }

  void deleteRide(String offerId) {
    for (int i = 0; i < availableOffers.length; i++) {
      if (availableOffers[i].id == offerId) {
        availableOffers.removeAt(i);
        break;
      }
    }
    if (activeOfferId == offerId) {
      activeOfferId = null;
      activeUserId = null;
      isActiveAsRider = false;
    }
    notifyListeners();
  }

  List<TripHistoryItem> userTrips(String userId) {
    List<TripHistoryItem> list = [];
    for (TripHistoryItem trip in tripHistory) {
      if (trip.userId == userId) {
        list.add(trip);
      }
    }
    return list;
  }
}
