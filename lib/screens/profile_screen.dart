import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // User Info Card
              Obx(() => _buildUserInfoCard(authController)),
              
              const SizedBox(height: 30),
              
              // Change Password Option
              _buildChangePasswordTile(),
              
              const SizedBox(height: 20),
              
              // Logout Button
              _buildLogoutButton(authController),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(AuthController authController) {
    final user = authController.currentUser.value;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.person_outline,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // User Name
          Text(
            user?.name ?? 'غير محدد',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // User Email
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  user?.email ?? 'غير محدد',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.lock_outline,
            color: AppColors.secondary,
            size: 24,
          ),
        ),
        title: const Text(
          'تغيير كلمة المرور',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
        subtitle: const Text(
          'قم بتحديث كلمة المرور الخاصة بك',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontFamily: 'Cairo',
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () => _showChangePasswordDialog(),
      ),
    );
  }

  Widget _buildLogoutButton(AuthController authController) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade400,
            Colors.red.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(authController),
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final RxBool isLoading = false.obs;
    final RxBool showOldPassword = false.obs;
    final RxBool showNewPassword = false.obs;
    final RxBool showConfirmPassword = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text(
          'تغيير كلمة المرور',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Old Password
              Obx(() => TextField(
                controller: oldPasswordController,
                obscureText: !showOldPassword.value,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showOldPassword.value 
                        ? Icons.visibility 
                        : Icons.visibility_off,
                    ),
                    onPressed: () => showOldPassword.toggle(),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              )),
              
              const SizedBox(height: 16),
              
              // New Password
              Obx(() => TextField(
                controller: newPasswordController,
                obscureText: !showNewPassword.value,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showNewPassword.value 
                        ? Icons.visibility 
                        : Icons.visibility_off,
                    ),
                    onPressed: () => showNewPassword.toggle(),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              )),
              
              const SizedBox(height: 16),
              
              // Confirm Password
              Obx(() => TextField(
                controller: confirmPasswordController,
                obscureText: !showConfirmPassword.value,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showConfirmPassword.value 
                        ? Icons.visibility 
                        : Icons.visibility_off,
                    ),
                    onPressed: () => showConfirmPassword.toggle(),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value ? null : () {
              if (newPasswordController.text != confirmPasswordController.text) {
                Get.snackbar(
                  'خطأ',
                  'كلمات المرور غير متطابقة',
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                );
                return;
              }
              
              if (newPasswordController.text.length < 6) {
                Get.snackbar(
                  'خطأ',
                  'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                );
                return;
              }
              
              // Here you would typically call an API to change the password
              isLoading.value = true;
              
              // Simulate API call
              Future.delayed(const Duration(seconds: 2), () {
                isLoading.value = false;
                Get.back();
                Get.snackbar(
                  'نجح',
                  'تم تغيير كلمة المرور بنجاح',
                  backgroundColor: Colors.green.withOpacity(0.1),
                  colorText: Colors.green,
                );
              });
            },
            child: isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'تغيير',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
          )),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
