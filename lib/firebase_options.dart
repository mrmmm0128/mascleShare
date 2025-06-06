// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDePrpR8CD5xWf19828aGwdgVve5s4EYOc',
    appId: '1:362152912464:web:f9db4d3b46465d2903d355',
    messagingSenderId: '362152912464',
    projectId: 'muscleshare-b34dd',
    authDomain: 'muscleshare-b34dd.firebaseapp.com',
    storageBucket: 'muscleshare-b34dd.firebasestorage.app',
    measurementId: 'G-Y4KLX3P5WP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDBZJjV-rlL-QbUdjTmoTpQ_Lta52VJE1k',
    appId: '1:362152912464:android:d8249fdc3a65e47503d355',
    messagingSenderId: '362152912464',
    projectId: 'muscleshare-b34dd',
    storageBucket: 'muscleshare-b34dd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBqiNa-uKqFB96vmXmTx1wzyTOqmt1RnqI',
    appId: '1:362152912464:ios:74be6dd732e2206503d355',
    messagingSenderId: '362152912464',
    projectId: 'muscleshare-b34dd',
    storageBucket: 'muscleshare-b34dd.firebasestorage.app',
    iosBundleId: 'com.example.muscleshare',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBqiNa-uKqFB96vmXmTx1wzyTOqmt1RnqI',
    appId: '1:362152912464:ios:693cd25210cb6d2103d355',
    messagingSenderId: '362152912464',
    projectId: 'muscleshare-b34dd',
    storageBucket: 'muscleshare-b34dd.firebasestorage.app',
    iosBundleId: 'com.example.muscleShare',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDePrpR8CD5xWf19828aGwdgVve5s4EYOc',
    appId: '1:362152912464:web:a01d410c5ec4480803d355',
    messagingSenderId: '362152912464',
    projectId: 'muscleshare-b34dd',
    authDomain: 'muscleshare-b34dd.firebaseapp.com',
    storageBucket: 'muscleshare-b34dd.firebasestorage.app',
    measurementId: 'G-S0NTLGDTH1',
  );

}