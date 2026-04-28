import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Values extracted from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSY_8GIpn96Sb0cNmBriEBKqfF5MXbvzY',
    appId: '1:56229629682:android:4c93f560bfb704d7a0ca6b',
    messagingSenderId: '56229629682',
    projectId: 'public-complaint-app-bbf5c',
    storageBucket: 'public-complaint-app-bbf5c.firebasestorage.app',
  );

  // Web config — update if you add a web app in Firebase console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBSY_8GIpn96Sb0cNmBriEBKqfF5MXbvzY',
    appId: '1:56229629682:android:4c93f560bfb704d7a0ca6b',
    messagingSenderId: '56229629682',
    projectId: 'public-complaint-app-bbf5c',
    storageBucket: 'public-complaint-app-bbf5c.firebasestorage.app',
  );
}
