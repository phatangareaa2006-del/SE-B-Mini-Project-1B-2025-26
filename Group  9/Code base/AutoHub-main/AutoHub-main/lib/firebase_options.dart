import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS:     return ios;
      default: throw UnsupportedError('Platform not configured');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'AIzaSyAtVIj5EzwkT-bM4si9P8v282xO83_dKz4',
    appId:             '1:107248032103:android:f4ebb3af427fbfaa3537c2',
    messagingSenderId: '107248032103',
    projectId:         'autohub-651ec',
    storageBucket:     'autohub-651ec.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'AIzaSyAtVIj5EzwkT-bM4si9P8v282xO83_dKz4',
    appId:             '1:107248032103:android:92e7640b2913c1be3537c2',
    messagingSenderId: '107248032103',
    projectId:         'autohub-651ec',
    storageBucket:     'autohub-651ec.firebasestorage.app',
    iosClientId:       '107248032103-93iac3l4ub8vufj4lk88ie31oh21l74j.apps.googleusercontent.com',
    iosBundleId:       'com.example.autohub',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyAtVIj5EzwkT-bM4si9P8v282xO83_dKz4',
    appId:             '1:107248032103:android:f4ebb3af427fbfaa3537c2',
    messagingSenderId: '107248032103',
    projectId:         'autohub-651ec',
    storageBucket:     'autohub-651ec.firebasestorage.app',
    authDomain:        'autohub-651ec.firebaseapp.com',
  );
}