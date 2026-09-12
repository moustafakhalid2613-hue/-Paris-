// ⚠️ ملف مؤقت (placeholder) فقط.
//
// هذا الملف لازم يتولّد تلقائياً باستخدام أداة FlutterFire CLI، ومينفعش
// يتسحب زي ما هو - القيم هنا وهمية ومش هتشتغل مع مشروع Firebase حقيقي.
//
// خطوات التوليد الصحيح:
//   1) dart pub global activate flutterfire_cli
//   2) flutterfire configure
//   3) اختار مشروع Firebase بتاعك، والمنصات المطلوبة (Android/iOS/Web)
//   4) هيتم استبدال هذا الملف بالكامل تلقائياً بالإعدادات الصحيحة
//
// لحد ما تعمل الخطوات دي، التطبيق مش هيقدر يتصل بـ Firebase فعلياً.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions لم يتم إعدادها لهذه المنصة - '
          'شغّل flutterfire configure أولاً.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    authDomain: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'REPLACE_ME',
  );
}
