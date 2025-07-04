import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';
import '../controllers/client_dashboard_controller.dart';

class ClientProfileSettingsScreen extends StatelessWidget {
  const ClientProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientDashboardController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          'الملف الشخصي',
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
        actions: [
          IconButton(
            onPressed: _showEditProfileDialog,
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(controller),
            const SizedBox(height: 24),
            _buildPersonalInfo(controller),
            const SizedBox(height: 16),
            _buildPreferences(),
            const SizedBox(height: 16),
            _buildNotificationSettings(),
            const SizedBox(height: 16),
            _buildSecuritySettings(),
            const SizedBox(height: 16),
            _buildAppSettings(),
            const SizedBox(height: 16),
            _buildSupportSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ClientDashboardController controller) {
    return Obx(() => Container(
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
                    controller.userImage.value,
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
          Text(
            controller.userName.value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.userEmail.value,
            style: const TextStyle(
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'عميل موثق منذ ${controller.memberSince.value}',
                  style: const TextStyle(
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
    ));
  }

  Widget _buildPersonalInfo(ClientDashboardController controller) {
    return Obx(() => _buildSection(
      title: 'المعلومات الشخصية',
      icon: Icons.person,
      children: [
        _buildInfoItem(
          icon: Icons.person_outline,
          title: 'الاسم الكامل',
          value: controller.userName.value,
          onTap: () => _editField('name', controller.userName.value),
        ),
        _buildInfoItem(
          icon: Icons.email_outlined,
          title: 'البريد الإلكتروني',
          value: controller.userEmail.value,
          onTap: () => _editField('email', controller.userEmail.value),
        ),
        _buildInfoItem(
          icon: Icons.phone_outlined,
          title: 'رقم الهاتف',
          value: controller.userPhone.value,
          onTap: () => _editField('phone', controller.userPhone.value),
        ),
        _buildInfoItem(
          icon: Icons.location_on_outlined,
          title: 'العنوان',
          value: 'الرياض، المملكة العربية السعودية',
          onTap: () => _editField('address', 'الرياض، المملكة العربية السعودية'),
        ),
      ],
    ));
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
          onChanged: (value) {},
        ),
        _buildSwitchItem(
          icon: Icons.trending_up,
          title: 'تحديثات الأسعار',
          subtitle: 'إشعارات عند تغيير أسعار العقارات المفضلة',
          value: true,
          onChanged: (value) {},
        ),
        _buildClickableItem(
          icon: Icons.location_city,
          title: 'المدن المفضلة',
          subtitle: 'الرياض، جدة، الدمام',
          onTap: () => _showCityPreferences(),
        ),
        _buildClickableItem(
          icon: Icons.attach_money,
          title: 'نطاق الأسعار المفضل',
          subtitle: '500,000 - 2,000,000 ريال',
          onTap: () => _showPriceRange(),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSection(
      title: 'الإشعارات',
      icon: Icons.notifications,
      children: [
        _buildSwitchItem(
          icon: Icons.notifications_active,
          title: 'الإشعارات الفورية',
          subtitle: 'تلقي إشعارات فورية على الهاتف',
          value: true,
          onChanged: (value) {},
        ),
        _buildSwitchItem(
          icon: Icons.email,
          title: 'إشعارات البريد الإلكتروني',
          subtitle: 'تلقي نشرة أسبوعية بالعقارات الجديدة',
          value: false,
          onChanged: (value) {},
        ),
        _buildSwitchItem(
          icon: Icons.sms,
          title: 'رسائل نصية',
          subtitle: 'تلقي رسائل نصية للعروض المهمة',
          value: true,
          onChanged: (value) {},
        ),
        _buildClickableItem(
          icon: Icons.schedule,
          title: 'أوقات الإشعارات',
          subtitle: '8:00 ص - 8:00 م',
          onTap: () => _showNotificationTimes(),
        ),
      ],
    );
  }

  Widget _buildSecuritySettings() {
    return _buildSection(
      title: 'الأمان والخصوصية',
      icon: Icons.security,
      children: [
        _buildClickableItem(
          icon: Icons.lock_outline,
          title: 'تغيير كلمة المرور',
          subtitle: 'آخر تغيير منذ 3 أشهر',
          onTap: () => _showChangePassword(),
        ),
        _buildSwitchItem(
          icon: Icons.fingerprint,
          title: 'المصادقة الثنائية',
          subtitle: 'حماية إضافية للحساب',
          value: false,
          onChanged: (value) {},
        ),
        _buildSwitchItem(
          icon: Icons.visibility_off,
          title: 'وضع الخصوصية',
          subtitle: 'إخفاء نشاطك عن المستخدمين الآخرين',
          value: false,
          onChanged: (value) {},
        ),
        _buildClickableItem(
          icon: Icons.history,
          title: 'سجل النشاطات',
          subtitle: 'عرض تاريخ النشاطات والتسجيلات',
          onTap: () => _showActivityLog(),
        ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return _buildSection(
      title: 'إعدادات التطبيق',
      icon: Icons.settings,
      children: [
        _buildClickableItem(
          icon: Icons.language,
          title: 'اللغة',
          subtitle: 'العربية',
          onTap: () => _showLanguageOptions(),
        ),
        _buildClickableItem(
          icon: Icons.attach_money,
          title: 'العملة',
          subtitle: 'ريال سعودي (SAR)',
          onTap: () => _showCurrencyOptions(),
        ),
        _buildSwitchItem(
          icon: Icons.dark_mode,
          title: 'الوضع الليلي',
          subtitle: 'تفعيل المظهر الداكن',
          value: false,
          onChanged: (value) {},
        ),
        _buildClickableItem(
          icon: Icons.storage,
          title: 'إدارة التخزين',
          subtitle: 'تنظيف البيانات المؤقتة',
          onTap: () => _showStorageOptions(),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'المساعدة والدعم',
      icon: Icons.help,
      children: [
        _buildClickableItem(
          icon: Icons.help_outline,
          title: 'الأسئلة الشائعة',
          subtitle: 'إجابات للأسئلة الأكثر شيوعاً',
          onTap: () => _showFAQ(),
        ),
        _buildClickableItem(
          icon: Icons.support_agent,
          title: 'التواصل مع الدعم',
          subtitle: 'دردشة مباشرة أو مكالمة هاتفية',
          onTap: () => _contactSupport(),
        ),
        _buildClickableItem(
          icon: Icons.feedback,
          title: 'إرسال ملاحظات',
          subtitle: 'ساعدنا في تحسين التطبيق',
          onTap: () => _sendFeedback(),
        ),
        _buildClickableItem(
          icon: Icons.info_outline,
          title: 'حول التطبيق',
          subtitle: 'الإصدار 1.0.0',
          onTap: () => _showAbout(),
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
    required ValueChanged<bool> onChanged,
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
        onChanged: onChanged,
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

  // Dialog and action methods
  void _showEditProfileDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تعديل الملف الشخصي'),
        content: const Text('سيتم فتح شاشة تعديل شاملة للملف الشخصي'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('تم', 'تم فتح شاشة التعديل');
            },
            child: const Text('تعديل'),
          ),
        ],
      ),
    );
  }

  void _editField(String field, String currentValue) {
    Get.snackbar('تعديل', 'تعديل $field: $currentValue');
  }

  void _showCityPreferences() {
    Get.snackbar('المدن المفضلة', 'عرض قائمة المدن المتاحة');
  }

  void _showPriceRange() {
    Get.snackbar('نطاق الأسعار', 'تحديد نطاق الأسعار المفضل');
  }

  void _showNotificationTimes() {
    Get.snackbar('أوقات الإشعارات', 'تحديد أوقات تلقي الإشعارات');
  }

  void _showChangePassword() {
    Get.snackbar('تغيير كلمة المرور', 'فتح شاشة تغيير كلمة المرور');
  }

  void _showActivityLog() {
    Get.snackbar('سجل النشاطات', 'عرض سجل النشاطات');
  }

  void _showLanguageOptions() {
    Get.snackbar('اللغة', 'اختيار لغة التطبيق');
  }

  void _showCurrencyOptions() {
    Get.snackbar('العملة', 'اختيار عملة العرض');
  }

  void _showStorageOptions() {
    Get.snackbar('إدارة التخزين', 'خيارات إدارة التخزين');
  }

  void _showFAQ() {
    Get.snackbar('الأسئلة الشائعة', 'عرض الأسئلة الشائعة');
  }

  void _contactSupport() {
    Get.snackbar('الدعم الفني', 'التواصل مع فريق الدعم');
  }

  void _sendFeedback() {
    Get.snackbar('الملاحظات', 'إرسال ملاحظات حول التطبيق');
  }

  void _showAbout() {
    Get.snackbar('حول التطبيق', 'معلومات عن التطبيق والشركة');
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
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
} 