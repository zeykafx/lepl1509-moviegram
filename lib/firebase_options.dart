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
    apiKey: 'AIzaSyDR_GjhtZUQZNOWVPP1aA9WPq1k7LIxoAU',
    appId: '1:327250871577:web:1c143076cbcf0e67973188',
    messagingSenderId: '327250871577',
    projectId: 'lepl1509-moviegram',
    authDomain: 'lepl1509-moviegram.firebaseapp.com',
    storageBucket: 'lepl1509-moviegram.appspot.com',
    measurementId: 'G-9MZ3LGCG6P',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAVDPSqLkLzIfu773HztMCe8aarDxwoHo',
    appId: '1:327250871577:android:fdae04f072ef353d973188',
    messagingSenderId: '327250871577',
    projectId: 'lepl1509-moviegram',
    storageBucket: 'lepl1509-moviegram.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBnUbITFVYwn7nucggM_RzuCrn0u9lBePs',
    appId: '1:327250871577:ios:4fe672f3c6b02f2a973188',
    messagingSenderId: '327250871577',
    projectId: 'lepl1509-moviegram',
    storageBucket: 'lepl1509-moviegram.appspot.com',
    iosClientId:
        '327250871577-1l376k99gg0d21dht33ffu5r6uj5i0e5.apps.googleusercontent.com',
    iosBundleId: 'com.groupe17lepl1509.projetLepl1509Groupe17',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBnUbITFVYwn7nucggM_RzuCrn0u9lBePs',
    appId: '1:327250871577:ios:911e1fc12cda5e35973188',
    messagingSenderId: '327250871577',
    projectId: 'lepl1509-moviegram',
    storageBucket: 'lepl1509-moviegram.appspot.com',
    iosClientId:
        '327250871577-02i33tvftmvs8fud176fq16a1va13os9.apps.googleusercontent.com',
    iosBundleId: 'com.groupe17lepl1509.projetLepl1509Groupe17.RunnerTests',
  );
}
