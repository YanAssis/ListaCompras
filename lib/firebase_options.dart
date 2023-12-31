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
    apiKey: 'AIzaSyBKEn7fz2BoddFyNr5-s05MNm3621ANUE8',
    appId: '1:445796810343:web:55b165c10b126b1ebedec2',
    messagingSenderId: '445796810343',
    projectId: 'projeto-yan-oguino0811',
    authDomain: 'projeto-yan-oguino0811.firebaseapp.com',
    storageBucket: 'projeto-yan-oguino0811.appspot.com',
    measurementId: 'G-1GMV3QTTXK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCXLvWznSNV2QqViYstPDfVdMZ-pAhc6MU',
    appId: '1:445796810343:android:d7e27ba9a6cc61c0bedec2',
    messagingSenderId: '445796810343',
    projectId: 'projeto-yan-oguino0811',
    storageBucket: 'projeto-yan-oguino0811.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJa_yacTmZGnPxmDyoN7UTMByQjItwrmM',
    appId: '1:445796810343:ios:15ef31f3a0f77ec8bedec2',
    messagingSenderId: '445796810343',
    projectId: 'projeto-yan-oguino0811',
    storageBucket: 'projeto-yan-oguino0811.appspot.com',
    iosClientId: '445796810343-m70ip2o3pfe4gg82k84a8t6n4kc7kfh3.apps.googleusercontent.com',
    iosBundleId: 'com.example.aula1',
  );
}
