import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';

// Helper extension to avoid conflicts between GetX and Easy Localization
extension AppTranslation on String {
  String get translate => this;
}

// Alternative helper function
String translate(String key) {
  return key;
}

class TranslationHelper {
  static const Map<String, Map<String, String>> _translations = {
    'ar': {
      'home': 'الرئيسية',
      'properties': 'العقارات',
      'favorites': 'المفضلة',
      'profile': 'الملف الشخصي',
      'search': 'البحث',
      'filter': 'تصفية',
      'price': 'السعر',
      'area': 'المساحة',
      'bedrooms': 'غرف النوم',
      'bathrooms': 'دورات المياه',
      'location': 'الموقع',
      'type': 'النوع',
      'status': 'الحالة',
      'for_sale': 'للبيع',
      'for_rent': 'للإيجار',
      'apartment': 'شقة',
      'villa': 'فيلا',
      'house': 'منزل',
      'office': 'مكتب',
      'shop': 'محل',
      'warehouse': 'مستودع',
      'land': 'أرض',
      'building': 'عمارة',
      'featured': 'مميز',
      'recent': 'الأحدث',
      'popular': 'الأكثر شيوعاً',
      'no_properties_found': 'لا توجد عقارات',
      'loading': 'جاري التحميل...',
      'error': 'حدث خطأ',
      'retry': 'إعادة المحاولة',
      'contact_agent': 'تواصل مع الوكيل',
      'call': 'اتصال',
      'whatsapp': 'واتساب',
      'email': 'بريد إلكتروني',
      'share': 'مشاركة',
      'save_to_favorites': 'حفظ في المفضلة',
      'remove_from_favorites': 'إزالة من المفضلة',
      'view_on_map': 'عرض على الخريطة',
      'property_details': 'تفاصيل العقار',
      'description': 'الوصف',
      'features': 'المميزات',
      'amenities': 'المرافق',
      'similar_properties': 'عقارات مشابهة',
      'agent_info': 'معلومات الوكيل',
      'notifications': 'الإشعارات',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'theme': 'المظهر',
      'about': 'حول التطبيق',
      'privacy_policy': 'سياسة الخصوصية',
      'terms_of_service': 'شروط الخدمة',
      'logout': 'تسجيل الخروج',
    },
    'en': {
      'home': 'Home',
      'properties': 'Properties',
      'favorites': 'Favorites',
      'profile': 'Profile',
      'search': 'Search',
      'filter': 'Filter',
      'price': 'Price',
      'area': 'Area',
      'bedrooms': 'Bedrooms',
      'bathrooms': 'Bathrooms',
      'location': 'Location',
      'type': 'Type',
      'status': 'Status',
      'for_sale': 'For Sale',
      'for_rent': 'For Rent',
      'apartment': 'Apartment',
      'villa': 'Villa',
      'house': 'House',
      'office': 'Office',
      'shop': 'Shop',
      'warehouse': 'Warehouse',
      'land': 'Land',
      'building': 'Building',
      'featured': 'Featured',
      'recent': 'Recent',
      'popular': 'Popular',
      'no_properties_found': 'No Properties Found',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'contact_agent': 'Contact Agent',
      'call': 'Call',
      'whatsapp': 'WhatsApp',
      'email': 'Email',
      'share': 'Share',
      'save_to_favorites': 'Save to Favorites',
      'remove_from_favorites': 'Remove from Favorites',
      'view_on_map': 'View on Map',
      'property_details': 'Property Details',
      'description': 'Description',
      'features': 'Features',
      'amenities': 'Amenities',
      'similar_properties': 'Similar Properties',
      'agent_info': 'Agent Information',
      'notifications': 'Notifications',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'about': 'About',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'logout': 'Logout',
    },
  };

  static String translate(String key, {String locale = 'ar'}) {
    return _translations[locale]?[key] ?? key;
  }

  static String get currentLocale {
    return PlatformDispatcher.instance.locale.languageCode == 'ar' ? 'ar' : 'en';
  }

  static bool get isRTL {
    return currentLocale == 'ar';
  }
}

// ✅ إضافة مساعد لمعالجة روابط الصور
class ImageUrlHelper {
  /// تنظيف وترميز رابط الصورة
  static String cleanImageUrl(String url) {
    if (url.isEmpty || !url.startsWith('http')) {
      return 'https://albrog.com/wp-content/uploads/2025/default-property.jpg';
    }
    
    try {
      // تحويل الرابط إلى URI وترميزه
      final uri = Uri.parse(url);
      final encodedPath = uri.pathSegments
          .map((segment) => Uri.encodeComponent(segment))
          .join('/');
      
      final cleanUrl = '${uri.scheme}://${uri.host}/$encodedPath';
      print('🔧 Image URL cleaned: $url -> $cleanUrl');
      return cleanUrl;
    } catch (e) {
      print('🚨 Error cleaning image URL: $url - $e');
      return 'https://albrog.com/wp-content/uploads/2025/default-property.jpg';
    }
  }
  
  /// التحقق من صحة رابط الصورة
  static bool isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }
  
  /// الحصول على رابط افتراضي للصورة
  static String getDefaultImageUrl() {
    return 'https://albrog.com/wp-content/uploads/2025/default-property.jpg';
  }
  
  /// قائمة بروابط الصور الافتراضية للاختبار
  static List<String> getPlaceholderImages() {
    return [
      'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1484154218962-a197022b5858?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    ];
  }
} 