import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          'الملف الشخصي والإعدادات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildPersonalInfo(),
            const SizedBox(height: 16),
            _buildPreferences(),
            const SizedBox(height: 16),
            _buildNotifications(),
            const SizedBox(height: 16),
            _buildSecurity(),
            const SizedBox(height: 16),
            _buildSupport(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'أحمد محمد العلي',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ahmed@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'عميل موثق منذ 2023',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
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

  Widget _buildPersonalInfo() {
    return _buildSection(
      title: 'المعلومات الشخصية',
      icon: Icons.person,
      children: [
        _buildInfoItem(
          icon: Icons.person_outline,
          title: 'الاسم الكامل',
          value: 'أحمد محمد العلي',
          onTap: () => Get.snackbar('تعديل', 'تعديل الاسم'),
        ),
        _buildInfoItem(
          icon: Icons.email_outlined,
          title: 'البريد الإلكتروني',
          value: 'ahmed@example.com',
          onTap: () => Get.snackbar('تعديل', 'تعديل البريد الإلكتروني'),
        ),
        _buildInfoItem(
          icon: Icons.phone_outlined,
          title: 'رقم الهاتف',
          value: '+966501234567',
          onTap: () => Get.snackbar('تعديل', 'تعديل رقم الهاتف'),
        ),
        _buildInfoItem(
          icon: Icons.location_on_outlined,
          title: 'العنوان',
          value: 'الرياض، المملكة العربية السعودية',
          onTap: () => Get.snackbar('تعديل', 'تعديل العنوان'),
        ),
      ],
    );
  }

  Widget _buildPreferences() {
    return _buildSection(
      title: 'التفضيلات',
      icon: Icons.tune,
      children: [
        _buildSwitchItem(
          icon: Icons.home_work,
          title: 'إشعارات العقارات الجديدة',
          subtitle: 'تلقي إشعارات عن العقارات المطابقة لاهتماماتك',
          value: true,
        ),
        _buildSwitchItem(
          icon: Icons.trending_up,
          title: 'تحديثات الأسعار',
          subtitle: 'إشعارات عند تغيير أسعار العقارات المفضلة',
          value: true,
        ),
        _buildClickableItem(
          icon: Icons.location_city,
          title: 'المدن المفضلة',
          subtitle: 'الرياض، جدة، الدمام',
          onTap: () => Get.snackbar('المدن', 'تحديد المدن المفضلة'),
        ),
        _buildClickableItem(
          icon: Icons.attach_money,
          title: 'نطاق الأسعار المفضل',
          subtitle: '500,000 - 2,000,000 ريال',
          onTap: () => Get.snackbar('الأسعار', 'تحديد نطاق الأسعار'),
        ),
      ],
    );
  }

  Widget _buildNotifications() {
    return _buildSection(
      title: 'الإشعارات',
      icon: Icons.notifications,
      children: [
        _buildSwitchItem(
          icon: Icons.notifications_active,
          title: 'الإشعارات الفورية',
          subtitle: 'تلقي إشعارات فورية على الهاتف',
          value: true,
        ),
        _buildSwitchItem(
          icon: Icons.email,
          title: 'إشعارات البريد الإلكتروني',
          subtitle: 'تلقي نشرة أسبوعية بالعقارات الجديدة',
          value: false,
        ),
        _buildSwitchItem(
          icon: Icons.sms,
          title: 'رسائل نصية',
          subtitle: 'تلقي رسائل نصية للعروض المهمة',
          value: true,
        ),
      ],
    );
  }

  Widget _buildSecurity() {
    return _buildSection(
      title: 'الأمان والخصوصية',
      icon: Icons.security,
      children: [
        _buildClickableItem(
          icon: Icons.lock_outline,
          title: 'تغيير كلمة المرور',
          subtitle: 'آخر تغيير منذ 3 أشهر',
          onTap: () => Get.snackbar('الأمان', 'تغيير كلمة المرور'),
        ),
        _buildSwitchItem(
          icon: Icons.fingerprint,
          title: 'المصادقة الثنائية',
          subtitle: 'حماية إضافية للحساب',
          value: false,
        ),
        _buildSwitchItem(
          icon: Icons.visibility_off,
          title: 'وضع الخصوصية',
          subtitle: 'إخفاء نشاطك عن المستخدمين الآخرين',
          value: false,
        ),
      ],
    );
  }

  Widget _buildSupport() {
    return _buildSection(
      title: 'المساعدة والدعم',
      icon: Icons.help,
      children: [
        _buildClickableItem(
          icon: Icons.help_outline,
          title: 'الأسئلة الشائعة',
          subtitle: 'إجابات للأسئلة الأكثر شيوعاً',
          onTap: () => Get.snackbar('المساعدة', 'الأسئلة الشائعة'),
        ),
        _buildClickableItem(
          icon: Icons.support_agent,
          title: 'التواصل مع الدعم',
          subtitle: 'دردشة مباشرة أو مكالمة هاتفية',
          onTap: () => Get.snackbar('الدعم', 'التواصل مع فريق الدعم'),
        ),
        _buildClickableItem(
          icon: Icons.feedback,
          title: 'إرسال ملاحظات',
          subtitle: 'ساعدنا في تحسين التطبيق',
          onTap: () => Get.snackbar('الملاحظات', 'إرسال ملاحظات'),
        ),
        _buildClickableItem(
          icon: Icons.logout,
          title: 'تسجيل الخروج',
          subtitle: 'الخروج من الحساب الحالي',
          onTap: () => _showLogoutDialog(),
          textColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontFamily: 'Cairo',
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          fontFamily: 'Cairo',
        ),
      ),
      trailing: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          fontFamily: 'Cairo',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontFamily: 'Cairo',
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {},
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildClickableItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor ?? AppColors.textPrimary,
          fontFamily: 'Cairo',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontFamily: 'Cairo',
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: textColor ?? AppColors.textSecondary,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('تم', 'تم تسجيل الخروج');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
} 