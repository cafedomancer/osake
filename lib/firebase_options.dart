// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCix1el-_mlntwCStEYG0KGwInlXXX2fZw',
    appId: '1:1065056604708:web:e4d7e346994dad4e10beb1',
    messagingSenderId: '1065056604708',
    projectId: 'osake-da012',
    authDomain: 'osake-da012.firebaseapp.com',
    storageBucket: 'osake-da012.appspot.com',
    measurementId: 'G-VM4EBMR55W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCXfLjFkZ8W47i-OnJeMrfhUUch-7u5Emw',
    appId: '1:1065056604708:android:5f49b385774faf1610beb1',
    messagingSenderId: '1065056604708',
    projectId: 'osake-da012',
    storageBucket: 'osake-da012.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCB3Or_mEW18mi01yzl3ex_3aPhWkGQJFc',
    appId: '1:1065056604708:ios:0f29af0cb4f87e8e10beb1',
    messagingSenderId: '1065056604708',
    projectId: 'osake-da012',
    storageBucket: 'osake-da012.appspot.com',
    iosClientId: '1065056604708-d2nesajsfitdr9a2jk18i2iidbt7qfhp.apps.googleusercontent.com',
    iosBundleId: 'com.cafedomancer.osake',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCB3Or_mEW18mi01yzl3ex_3aPhWkGQJFc',
    appId: '1:1065056604708:ios:0f29af0cb4f87e8e10beb1',
    messagingSenderId: '1065056604708',
    projectId: 'osake-da012',
    storageBucket: 'osake-da012.appspot.com',
    iosClientId: '1065056604708-d2nesajsfitdr9a2jk18i2iidbt7qfhp.apps.googleusercontent.com',
    iosBundleId: 'com.cafedomancer.osake',
  );
}