# Paris Salon — دليل الإعداد السريع

هذا الأرشيف يحتوي على الملفات المعدَّلة والجاهزة للمشروع. فك الضغط ودمج
المحتوى داخل مجلد مشروع Flutter موجود بالفعل (أو مشروع جديد باسم
`paris_salon`)، بنفس بنية المجلدات كما هي.

## البنية

```
lib/
├── main.dart
├── firebase_options.dart   ← ملف placeholder، لازم يتولّد من جديد (خطوة 2)
└── screens/
    ├── login_screen.dart
    └── signup_screen.dart
assets/
└── icons/
    └── app_icon.png        ← صورة أيقونة التطبيق
pubspec.yaml
```

## خطوات التشغيل

### 1) تثبيت الباكدجات
```bash
flutter pub get
```

### 2) ربط المشروع بـ Firebase (إلزامي)
ملف `lib/firebase_options.dart` المرفق هو **placeholder فقط** بقيم وهمية
(`REPLACE_ME`) — لازم يتولّد من جديد بالقيم الحقيقية:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
اختر مشروع Firebase بتاعك والمنصات المطلوبة (Android / iOS / Web)، وسيتم
استبدال الملف تلقائياً بالإعدادات الصحيحة.

### 3) توليد أيقونة التطبيق من الصورة
```bash
flutter pub run flutter_launcher_icons
```
هيولّد الأيقونة بكل الأحجام المطلوبة لـ Android وiOS وWeb وWindows
وmacOS تلقائياً من `assets/icons/app_icon.png`.

### 4) تشغيل المشروع
```bash
flutter run
```

## ملخص التعديلات المطبّقة
- إصلاح خطأ syntax في `main.dart` (`flimport` → `import`).
- ربط `Firebase.initializeApp` بـ `DefaultFirebaseOptions.currentPlatform`.
- إزالة `.trim()` من حقول كلمة المرور في تسجيل الدخول وإنشاء الحساب.
- تصحيح regex رقم الهاتف المصري في `signup_screen.dart`.
- تنظيم الملفات داخل `lib/screens/` لتطابق مسارات الـ imports.
- إضافة `flutter_launcher_icons` وإعداداته في `pubspec.yaml` لتوليد
  أيقونة التطبيق من `assets/icons/app_icon.png` على كل المنصات.
