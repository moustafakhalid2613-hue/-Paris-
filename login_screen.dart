import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'signup_screen.dart';
import '../main.dart' show ThemeProvider;
// import 'home_dashboard.dart'; // سيتم ربطها في الخطوة التالية

/// ============================================================
///  شاشة تسجيل الدخول - صالون Paris
///  - تسجيل الدخول عبر Firebase Auth (Email/Password)
///  - التحقق من حالة الحساب في Firestore (Pending/Approved)
/// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1) تسجيل الدخول عبر Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        // ملاحظة: لا يتم عمل trim() لكلمة المرور، لأن المسافات فيها
        // قد تكون جزءاً مقصوداً منها.
        password: _passwordCtrl.text,
      );

      final uid = credential.user!.uid;

      // 2) جلب بيانات المستخدم من Firestore والتحقق من حالته
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        setState(() {
          _errorMessage = 'لا يوجد بيانات مرتبطة بهذا الحساب.';
          _isLoading = false;
        });
        await _auth.signOut();
        return;
      }

      final status = userDoc.data()?['status'] as String? ?? 'Pending';

      if (status == 'Pending') {
        setState(() {
          _errorMessage =
              'حسابك قيد المراجعة من إدارة صالون Paris، برجاء الانتظار حتى تفعيل الحساب.';
          _isLoading = false;
        });
        await _auth.signOut();
        return;
      }

      if (status == 'Rejected' || status == 'Blocked') {
        setState(() {
          _errorMessage = 'تم رفض/إيقاف هذا الحساب. تواصل مع إدارة الصالون.';
          _isLoading = false;
        });
        await _auth.signOut();
        return;
      }

      // status == 'Approved' -> السماح بالدخول
      // تحديث آخر وقت دخول
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // TODO: التنقل إلى شاشة الداشبورد الرئيسية عند إضافتها
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الدخول بنجاح ✅')),
      );
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => const HomeDashboard()),
      // );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _mapAuthError(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ غير متوقع، حاول مرة أخرى.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة.';
      case 'too-many-requests':
        return 'محاولات كثيرة، برجاء الانتظار قليلاً ثم إعادة المحاولة.';
      default:
        return 'فشل تسجيل الدخول ($code).';
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل بريدك الإلكتروني أولاً')),
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _emailCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال رابط إعادة تعيين كلمة المرور')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapAuthError(e.code))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'تبديل الوضع الليلي/النهاري',
                      icon: Icon(
                        themeProvider.isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                      ),
                      onPressed: themeProvider.toggleTheme,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ---- شعار / اسم الصالون ----
                  CircleAvatar(
                    radius: 44,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    child: Icon(
                      Icons.content_cut_rounded,
                      size: 42,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Paris',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                  ),
                  Text(
                    'صالون التجميل والعناية',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // ---- حقل البريد الإلكتروني ----
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'برجاء إدخال البريد الإلكتروني';
                      }
                      final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!regex.hasMatch(value.trim())) {
                        return 'صيغة البريد الإلكتروني غير صحيحة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ---- حقل كلمة المرور ----
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'برجاء إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
                      }
                      return null;
                    },
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _isLoading ? null : _handleForgotPassword,
                      child: const Text('نسيت كلمة المرور؟'),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ---- زر تسجيل الدخول ----
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('تسجيل الدخول',
                            style: TextStyle(fontSize: 16)),
                  ),

                  const SizedBox(height: 24),

                  // ---- الانتقال لشاشة إنشاء حساب ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ليس لديك حساب؟'),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                              },
                        child: const Text('إنشاء حساب جديد'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
