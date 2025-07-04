import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import 'notification_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  /// حالة تسجيل الدخول
  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var currentUser = Rxn<User>();

  /// الحقول
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  /// مفتاح النموذج
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    checkLoginStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// تحقق من حالة الدخول الحاليّة
  void checkLoginStatus() {
    isLoggedIn.value = _authService.isLoggedIn();
    if (isLoggedIn.value) {
      currentUser.value = _authService.getUser();
    }
  }

  /// تنفيذ عملية تسجيل الدخول
  Future<void> login() async {
    if (isClosed || !formKey.currentState!.validate()) return;

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال البريد الإلكتروني وكلمة المرور',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (result['success']) {
        currentUser.value = result['user'];
        isLoggedIn.value = true;

        final userRole = result['user'].role?.toLowerCase() ?? 'client';

        // تفعيل الإشعارات إن وُجد NotificationController
        _enableNotifications(result['user'].id);

        Get.snackbar(
          'تم الدخول',
          result['message'],
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );

        // ✅ التوجيه للصفحة الرئيسية بعد تسجيل الدخول
        Get.offAllNamed('/main');

        clearForm();
      } else {
        Get.snackbar(
          'خطأ في تسجيل الدخول',
          result['message'] ?? 'حدث خطأ غير معروف',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          icon: const Icon(Icons.error, color: Colors.red),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _authService.logout();
    currentUser.value = null;
    isLoggedIn.value = false;

    _disableNotifications();

    Get.snackbar(
      'تم تسجيل الخروج',
      'تم تسجيل الخروج بنجاح',
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue,
      icon: const Icon(Icons.logout, color: Colors.blue),
    );

    Get.offAllNamed('/login');
  }

  /// مسح الحقول
  void clearForm() {
    emailController.clear();
    passwordController.clear();
  }

  /// تحقق من صحة البريد الإلكتروني
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!GetUtils.isEmail(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  /// تحقق من صحة كلمة المرور
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  /// الانتقال إلى صفحة استعادة كلمة المرور
  void goToForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  /// تفعيل الإشعارات إذا كانت متاحة
  void _enableNotifications(int userId) {
    try {
      final notificationController = Get.find<NotificationController>();
      notificationController.enableNotifications(userId);
    } catch (e) {
      debugPrint('⚠️ NotificationController not found: $e');
    }
  }

  /// تعطيل الإشعارات عند الخروج
  void _disableNotifications() {
    try {
      final notificationController = Get.find<NotificationController>();
      notificationController.disableNotifications();
    } catch (e) {
      debugPrint('⚠️ NotificationController not found: $e');
    }
  }
}
