import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBawbgHjZs2XBtkcBx-mrzK0cip8drDrwA',
    appId: '1:342829777413:android:ab288f314ce6cfc82c926c',
    messagingSenderId: '342829777413',
    projectId: 'sharefare-b3948',
    storageBucket: 'sharefare-b3948.firebasestorage.app',
  );
}
