// file: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
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
    apiKey: 'AIzaSyBa0RFt793Xr7NJdGTkkWoAwz8JY6iRt3Y',
    appId: '1:339021894682:web:2a566d28828722a524eda3',
    messagingSenderId: '339021894682',
    projectId: 'myrestauranteflutter',
    authDomain: 'myrestauranteflutter.firebaseapp.com',
    storageBucket: 'myrestauranteflutter.firebasestorage.app',
    measurementId: 'G-C71JR84CJF',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCXJb4rLGN0FNoAHqUqgZorJ_2TI9P_gj0',
    appId: '1:339021894682:ios:5abcc41036c4f15c24eda3',
    messagingSenderId: '339021894682',
    projectId: 'myrestauranteflutter',
    storageBucket: 'myrestauranteflutter.firebasestorage.app',
    iosBundleId: 'com.example.clientApp',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCXJb4rLGN0FNoAHqUqgZorJ_2TI9P_gj0',
    appId: '1:339021894682:ios:5abcc41036c4f15c24eda3',
    messagingSenderId: '339021894682',
    projectId: 'myrestauranteflutter',
    storageBucket: 'myrestauranteflutter.firebasestorage.app',
    iosBundleId: 'com.example.clientApp',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5iyxERkvZaz7Qgs3CyMr-NT9iqjuxx2E',
    appId: '1:339021894682:android:d9431276bedb0e6524eda3',
    messagingSenderId: '339021894682',
    projectId: 'myrestauranteflutter',
    storageBucket: 'myrestauranteflutter.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBa0RFt793Xr7NJdGTkkWoAwz8JY6iRt3Y',
    appId: '1:339021894682:web:c634d5053e6a3ca024eda3',
    messagingSenderId: '339021894682',
    projectId: 'myrestauranteflutter',
    authDomain: 'myrestauranteflutter.firebaseapp.com',
    storageBucket: 'myrestauranteflutter.firebasestorage.app',
    measurementId: 'G-7WFWK6G1QE',
  );

}