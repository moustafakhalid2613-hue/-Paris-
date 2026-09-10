import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================
///  شاشة إنشاء حساب جديد - صالون Paris
///  - إنشاء المستخدم عبر Firebase Auth
///  - تخزين بيانات العميل في Firestore بحالة "Pending"
///    (يتطلب موافقة إدارة الصالون قبل السماح بالدخول)
/// ============================================================
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1) إنشاء المستخدم في Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      final uid = credential.user!.uid;

      // 2) تحديث الاسم المعروض في Auth
      await credential.user!.updateDisplayName(_nameCtrl.text.trim());

      // 3) تخزين بيانات العميل في Firestore بحالة Pending
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'role': 'customer', // customer / staff / admin
        'status': 'Pending', // Pending / Approved / Rejected / Blocked
        'salon': 'Paris',
        'loyaltyPoints': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': null,
      });

      // 4) تسجيل الخروج فوراً لحين موافقة الإدارة على الحساب
      await _auth.signOut();

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('تم إنشاء الحساب بنجاح'),
          content: const Text(
            'حسابك الآن قيد المراجعة من إدارة صالون Paris. '
            'سيتم إعلامك فور تفعيل الحساب والسماح لك بتسجيل الدخول.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // إغلاق الـ Dialog
                Navigator.of(context).pop(); // الرجوع لشاشة الدخول
              },
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
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
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً.';
      default:
        return 'فشل إنشاء الحساب (${code}).';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'انضم إلى صالون Paris',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // ---- الاسم ----
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'الاسم بالكامل',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'برجاء إدخال الاسم';
                    }
                    if (value.trim().length < 3) {
                      return 'الاسم قصير جداً';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ---- رقم الهاتف ----
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف (للحجز والتذكير عبر واتساب)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'برجاء إدخال رقم الهاتف';
                    }
                    final regex = RegExp(r'^01[0-2,5]{1}[0-9]{8}$');
                    if (!regex.hasMatch(value.trim())) {
                      return 'رقم هاتف مصري غير صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ---- البريد الإلكتروني ----
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

                // ---- كلمة المرور ----
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
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
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
                const SizedBox(height: 16),

                // ---- تأكيد كلمة المرور ----
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  obscureText: _obscureConfirm,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_reset_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordCtrl.text) {
                      return 'كلمة المرور غير متطابقة';
                    }
                    return null;
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
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

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('إنشاء الحساب', style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 12),
                Text(
                  'ملاحظة: سيتم مراجعة حسابك من إدارة صالون Paris قبل تفعيله.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
