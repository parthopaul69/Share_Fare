import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_fare/accepted.dart';
import 'package:share_fare/home.dart';
import 'package:share_fare/login.dart';
import 'package:share_fare/main.dart';
import 'package:share_fare/new_ride.dart';
import 'package:share_fare/ride_details.dart';
import 'package:share_fare/splash.dart';
import 'package:share_fare/successful_post.dart';

void main() {
  testWidgets('MyApp renders SplashScreen and navigates to LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome to ShareFare'), findsOneWidget);
  });

  testWidgets('LoginScreen renders email, password, and navigates to Home', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Welcome to ShareFare'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('LOGIN'), findsOneWidget);

    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.byType(Home), findsOneWidget);
    expect(find.text('ShareFare'), findsOneWidget);
  });

  testWidgets('Home renders available rides and navigates to RideDetails and NewRide', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    expect(find.text('AVAILABLE RIDE'), findsOneWidget);
    expect(find.text('DMD -> GULSHAN'), findsOneWidget);
    expect(find.text('AUST -> MIRPUR'), findsOneWidget);
    expect(find.text('TEJGAON -> DMD'), findsOneWidget);
    expect(find.text('+  NEW RIDE'), findsOneWidget);

    await tester.tap(find.text('+  NEW RIDE'));
    await tester.pumpAndSettle();
    expect(find.byType(NewRide), findsOneWidget);
  });

  testWidgets('Home navigates to RideDetails on VIEW tap', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    await tester.tap(find.text('VIEW').first);
    await tester.pumpAndSettle();

    expect(find.byType(RideDetails), findsOneWidget);
    expect(find.text('RIDE DETAILS'), findsOneWidget);
  });

  testWidgets('RideDetails renders information and navigates to Accepted', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RideDetails()));

    expect(find.text('RIDE DETAILS'), findsOneWidget);
    expect(find.text('Nigesh Rif'), findsOneWidget);
    expect(find.text('TEJGAON -> DMD'), findsOneWidget);
    expect(find.text('ACCEPT RIDE'), findsOneWidget);

    await tester.tap(find.text('ACCEPT RIDE'));
    await tester.pumpAndSettle();

    expect(find.byType(Accepted), findsOneWidget);
    expect(find.text('Ride Accepted!'), findsOneWidget);
    expect(find.text('The rider has been notified.'), findsOneWidget);
  });

  testWidgets('Accepted screen GO BACK button pops screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Accepted()));
            },
            child: const Text('Open Accepted'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Accepted'));
    await tester.pumpAndSettle();

    expect(find.byType(Accepted), findsOneWidget);
    await tester.tap(find.text('GO BACK'));
    await tester.pumpAndSettle();

    expect(find.byType(Accepted), findsNothing);
  });

  testWidgets('NewRide renders fields and navigates to SuccessfulPost', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewRide()));

    expect(find.text('NEW RIDE'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('POST RIDE'), findsOneWidget);

    await tester.tap(find.text('POST RIDE'));
    await tester.pumpAndSettle();

    expect(find.byType(SuccessfulPost), findsOneWidget);
    expect(find.text('Ride Posted!'), findsOneWidget);
    expect(find.text('Your ride is now available.'), findsOneWidget);
  });

  testWidgets('SuccessfulPost screen GO BACK button pops screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessfulPost()));
            },
            child: const Text('Open SuccessfulPost'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open SuccessfulPost'));
    await tester.pumpAndSettle();

    expect(find.byType(SuccessfulPost), findsOneWidget);
    await tester.tap(find.text('GO BACK'));
    await tester.pumpAndSettle();

    expect(find.byType(SuccessfulPost), findsNothing);
  });
}
