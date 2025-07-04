import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';
import '../controllers/properties_controller.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';
import '../widgets/section_header.dart';
import '../screens/property_details_screen.dart';

class EnhancedFavoritesScreen extends StatelessWidget {
  const EnhancedFavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropertiesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          'العقارات المفضلة',
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
          Obx(() => controller.favoriteProperties.isNotEmpty
              ? IconButton(
                  onPressed: _showSortOptions,
                  icon: const Icon(Icons.sort, color: Colors.white),
                )
              : const SizedBox.shrink()),
          Obx(() => controller.favoriteProperties.isNotEmpty
              ? IconButton(
                  onPressed: _showFilterOptions,
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() => controller.favoriteProperties.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                _buildStatsHeader(controller),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildFavoritesList(controller),
                ),
              ],
            )),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.favorite_outline,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد عقارات مفضلة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اكتشف العقارات وأضفها للمفضلة\nلتتمكن من العودة إليها لاحقاً',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontFamily: 'Cairo',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.offAllNamed('/main'),
            icon: const Icon(Icons.search),
            label: const Text('استكشف العقارات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(PropertiesController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${controller.favoriteProperties.length} عقار مفضل',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getLastAddedText(controller),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _shareAllFavorites,
            icon: const Icon(
              Icons.share,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(PropertiesController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: controller.favoriteProperties.length,
        itemBuilder: (context, index) {
          final property = controller.favoriteProperties[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: PropertyCard(
              property: property,
              onTap: () => Get.to(
                () => PropertyDetailsScreen(property: property),
                transition: Transition.rightToLeft,
              ),
              onFavorite: () => controller.toggleFavorite(property),
              isFavorite: true,
              showRemoveAnimation: true,
            ),
          );
        },
      ),
    );
  }

  String _getLastAddedText(PropertiesController controller) {
    if (controller.favoriteProperties.isEmpty) return '';

    // For demo purposes - in real app, you'd track actual add dates
    return 'آخر إضافة: اليوم';
  }

  void _showSortOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ترتيب حسب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            _buildSortOption('تاريخ الإضافة - الأحدث أولاً', Icons.schedule),
            _buildSortOption('تاريخ الإضافة - الأقدم أولاً', Icons.history),
            _buildSortOption('السعر - من الأقل للأعلى', Icons.arrow_upward),
            _buildSortOption('السعر - من الأعلى للأقل', Icons.arrow_downward),
            _buildSortOption('المساحة - من الأكبر للأصغر', Icons.square_foot),
            _buildSortOption('النوع', Icons.category),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar('تم', 'تم تطبيق الترتيب');
                    },
                    child: const Text('تطبيق'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Cairo',
        ),
      ),
      onTap: () {
        // Handle sort option selection
      },
    );
  }

  void _showFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'فلترة العقارات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('نوع العقار', Icons.home_work),
            _buildFilterOption('نطاق السعر', Icons.attach_money),
            _buildFilterOption('المدينة', Icons.location_city),
            _buildFilterOption('عدد الغرف', Icons.bed),
            _buildFilterOption('المساحة', Icons.square_foot),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('إعادة تعيين'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar('تم', 'تم تطبيق الفلاتر');
                    },
                    child: const Text('تطبيق'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Cairo',
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Handle filter option selection
      },
    );
  }

  void _shareAllFavorites() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'مشاركة المفضلات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.link, color: AppColors.primary),
              title: const Text('نسخ الرابط'),
              onTap: () {
                Get.back();
                Get.snackbar('تم', 'تم نسخ الرابط');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.primary),
              title: const Text('مشاركة مع الأصدقاء'),
              onTap: () {
                Get.back();
                // Share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.primary),
              title: const Text('إرسال بالإيميل'),
              onTap: () {
                Get.back();
                // Email functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
