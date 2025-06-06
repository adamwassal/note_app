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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDtLUGa5PMcOrx0129z8CofkISzXRL_11A',
    appId: '1:337297048139:web:5b8a5518dd8779e64c03ce',
    messagingSenderId: '337297048139',
    projectId: 'note-app-cf7a6',
    authDomain: 'note-app-cf7a6.firebaseapp.com',
    storageBucket: 'note-app-cf7a6.firebasestorage.app',
    measurementId: 'G-KKBR13ZF91',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQiUvzCppfRNQGipZJO5OP_ZY2szk_N7s',
    appId: '1:337297048139:android:7eac99e2b7f8a64e4c03ce',
    messagingSenderId: '337297048139',
    projectId: 'note-app-cf7a6',
    storageBucket: 'note-app-cf7a6.firebasestorage.app',
  );
}
