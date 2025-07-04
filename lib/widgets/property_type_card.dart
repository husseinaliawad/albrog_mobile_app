import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/property_type.dart';

class PropertyTypeCard extends StatelessWidget {
  final PropertyType propertyType;
  final VoidCallback? onTap;

  const PropertyTypeCard({
    Key? key,
    required this.propertyType,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 180, // ✅ إضافة ارتفاع ثابت
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getColorFromHex(propertyType.displayColor).withOpacity(0.1),
            _getColorFromHex(propertyType.displayColor).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getColorFromHex(propertyType.displayColor).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12), // ✅ تقليل padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // ✅ إضافة هذا
              children: [
                // أيقونة نوع العقار
                Container(
                  width: 50, // ✅ تقليل الحجم
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getColorFromHex(propertyType.displayColor).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16), // ✅ تقليل border radius
                  ),
                  child: Center(
                    child: propertyType.icon.isNotEmpty
                        ? Icon(
                            _getIconFromString(propertyType.icon),
                            size: 24, // ✅ تقليل حجم الأيقونة
                            color: _getColorFromHex(propertyType.displayColor),
                          )
                        : Text(
                            propertyType.displayIcon,
                            style: const TextStyle(fontSize: 24), // ✅ تقليل حجم emoji
                          ),
                  ),
                ),
                
                const SizedBox(height: 8), // ✅ تقليل المسافة
                
                // اسم نوع العقار
                Flexible( // ✅ جعله flexible
                  child: Text(
                    propertyType.displayName,
                    style: const TextStyle(
                      fontSize: 14, // ✅ تقليل حجم الخط
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 4), // ✅ تقليل المسافة
                
                // عدد العقارات مع النص
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // ✅ تقليل padding
                  decoration: BoxDecoration(
                    color: _getColorFromHex(propertyType.displayColor).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${propertyType.formattedPropertyCount} عقار', // ✅ دمج النص
                    style: TextStyle(
                      fontSize: 12, // ✅ تقليل حجم الخط
                      fontWeight: FontWeight.w600,
                      color: _getColorFromHex(propertyType.displayColor),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to convert hex color to Color
  Color _getColorFromHex(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppColors.secondary;
    }
  }

  // Helper function to convert string to IconData
  IconData _getIconFromString(String iconString) {
    final iconMap = {
      'apartment': Icons.apartment,
      'home': Icons.home,
      'business': Icons.business,
      'store': Icons.store,
      'landscape': Icons.landscape,
      'warehouse': Icons.warehouse,
      'building': Icons.business,
      'office': Icons.business,
      'shop': Icons.store,
      'land': Icons.landscape,
    };
    
    return iconMap[iconString.toLowerCase()] ?? Icons.home;
  }
}

// ✅ Grid version للاستخدام في الشبكة
class PropertyTypeGridCard extends StatelessWidget {
  final PropertyType propertyType;
  final VoidCallback? onTap;

  const PropertyTypeGridCard({
    Key? key,
    required this.propertyType,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getColorFromHex(propertyType.displayColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      propertyType.displayIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // اسم النوع
                Text(
                  propertyType.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 4),
                
                // عدد العقارات
                Text(
                  propertyType.formattedPropertyCount,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
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

  Color _getColorFromHex(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppColors.secondary;
    }
  }
} 