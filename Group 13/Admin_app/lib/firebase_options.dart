import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBaQUKAwYDDyMOiYusQQmWePhP_p8Xqj9A',
    appId: '1:56229629682:web:0de54de8af25bdd0a0ca6b',
    messagingSenderId: '56229629682',
    projectId: 'public-complaint-app-bbf5c',
    authDomain: 'public-complaint-app-bbf5c.firebaseapp.com',
    storageBucket: 'public-complaint-app-bbf5c.firebasestorage.app',
    measurementId: 'G-B1SHV4SGP1',
  );
}