import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/property.dart';
import '../models/popular_area.dart';
import '../models/property_type.dart';
import '../services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();
  final GetStorage _storage = GetStorage();
  
  // Controllers
  final TextEditingController searchController = TextEditingController();
  
  // Observable variables
  var isLoading = false.obs;
  var featuredProperties = <Property>[].obs;
  var recentProperties = <Property>[].obs;
  var popularAreas = <PopularArea>[].obs;
  var propertyTypes = <PropertyType>[].obs;
  var favoriteIds = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadFavorites();
    loadData();
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  // Load initial data
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Load featured properties
      await loadFeaturedProperties();
      
      // Load recent properties
      await loadRecentProperties();
      
      // Load popular areas
      await loadPopularAreas();
      
      // Load property types
      await loadPropertyTypes();
      
    } catch (e) {
      print('Error loading data: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل البيانات',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load featured properties from API with retry mechanism
  Future<void> loadFeaturedProperties() async {
    int retryCount = 0;
    const maxRetries = 2;
    
    while (retryCount <= maxRetries) {
      try {
        print('🔄 Loading featured properties from API... (attempt ${retryCount + 1}/${maxRetries + 1})');
        print('🌐 API URL: ${_apiService.baseUrl}/featured.php');
        
        final properties = await _apiService.getFeaturedProperties(limit: 5);
        
        print('📊 Raw response count: ${properties.length}');
        
        if (properties.isNotEmpty) {
          print('✅ Loaded ${properties.length} featured properties from API');
          // طباعة تفاصيل العقار الأول للتأكد
          final firstProperty = properties.first;
          print('🏠 First property: ${firstProperty.title} - ${firstProperty.formattedPrice}');
          print('📷 Images count: ${firstProperty.images.length}');
          
          featuredProperties.assignAll(properties);
          print('🎯 featuredProperties.length after assignAll: ${featuredProperties.length}');
          return; // نجح، اخرج من الحلقة
        } else {
          print('⚠️ No featured properties found in API');
          featuredProperties.clear();
          return; // لا توجد بيانات، لا تحاول مرة أخرى
        }
      } catch (e, stackTrace) {
        print('❌ Error loading featured properties (attempt ${retryCount + 1}): $e');
        
        if (retryCount < maxRetries) {
          print('🔄 Retrying in 2 seconds...');
          await Future.delayed(const Duration(seconds: 2));
          retryCount++;
        } else {
          print('🔍 Final attempt failed. Stack trace: $stackTrace');
          featuredProperties.clear();
          
          // عرض snackbar فقط بعد فشل جميع المحاولات
          if (!e.toString().contains('FormatException') && !e.toString().contains('type')) {
            Get.snackbar(
              'خطأ في الاتصال',
              'لا يمكن تحميل العقارات المميزة. تحقق من الاتصال بالإنترنت',
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade800,
              duration: const Duration(seconds: 3),
            );
          }
          break;
        }
      }
    }
  }

  // Load recent properties from API only - NO MOCK DATA
  Future<void> loadRecentProperties() async {
    try {
      print('🔄 Loading recent properties from API...');
      print('🌐 API URL: ${_apiService.baseUrl}/recent.php');
      
      final properties = await _apiService.getRecentProperties(limit: 10);
      
      print('📊 Raw recent response count: ${properties.length}');
      
      if (properties.isNotEmpty) {
        print('✅ Loaded ${properties.length} recent properties from API');
        // طباعة تفاصيل العقار الأول للتأكد
        final firstProperty = properties.first;
        print('🏠 First recent property: ${firstProperty.title} - ${firstProperty.formattedPrice}');
        
        recentProperties.assignAll(properties);
        print('🎯 recentProperties.length after assignAll: ${recentProperties.length}');
      } else {
        print('⚠️ No recent properties found in API');
        recentProperties.clear();
      }
    } catch (e, stackTrace) {
      print('❌ Error loading recent properties: $e');
      print('🔍 Stack trace: $stackTrace');
      recentProperties.clear();
      
      // لا نعرض snackbar إذا كانت المشكلة في JSON parsing
      if (!e.toString().contains('FormatException') && !e.toString().contains('type')) {
        Get.snackbar(
          'خطأ في الاتصال',
          'لا يمكن تحميل العقارات الحديثة. تحقق من الاتصال بالإنترنت',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  // Load popular areas from API
  Future<void> loadPopularAreas() async {
    try {
      print('🔄 Loading popular areas from API...');
      print('🌐 API URL: ${_apiService.baseUrl}/popular_areas.php');
      
      final areas = await _apiService.getPopularAreas(limit: 6);
      
      print('📊 Raw areas response count: ${areas.length}');
      
      if (areas.isNotEmpty) {
        print('✅ Loaded ${areas.length} popular areas from API');
        // طباعة تفاصيل المنطقة الأولى للتأكد
        final firstArea = areas.first;
        print('🏙️ First area: ${firstArea.displayName} - ${firstArea.propertyCountText}');
        
        popularAreas.assignAll(areas);
        print('🎯 popularAreas.length after assignAll: ${popularAreas.length}');
      } else {
        print('⚠️ No popular areas found in API');
        popularAreas.clear();
      }
    } catch (e, stackTrace) {
      print('❌ Error loading popular areas: $e');
      print('🔍 Stack trace: $stackTrace');
      popularAreas.clear();
      
      // لا نعرض snackbar إذا كانت المشكلة في JSON parsing
      if (!e.toString().contains('FormatException') && !e.toString().contains('type')) {
        Get.snackbar(
          'خطأ في الاتصال',
          'لا يمكن تحميل المناطق الشائعة. تحقق من الاتصال بالإنترنت',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  // Load property types from API
  Future<void> loadPropertyTypes() async {
    try {
      print('🔄 Loading property types from API...');
      print('🌐 API URL: ${_apiService.baseUrl}/property_types.php');
      
      final types = await _apiService.getPropertyTypes(limit: 10);
      
      print('📊 Raw property types response count: ${types.length}');
      
      if (types.isNotEmpty) {
        print('✅ Loaded ${types.length} property types from API');
        // طباعة تفاصيل النوع الأول للتأكد
        final firstType = types.first;
        print('🏠 First type: ${firstType.displayName} - ${firstType.propertyCountText}');
        
        propertyTypes.assignAll(types);
        print('🎯 propertyTypes.length after assignAll: ${propertyTypes.length}');
      } else {
        print('⚠️ No property types found in API');
        propertyTypes.clear();
      }
    } catch (e, stackTrace) {
      print('❌ Error loading property types: $e');
      print('🔍 Stack trace: $stackTrace');
      propertyTypes.clear();
      
      // لا نعرض snackbar إذا كانت المشكلة في JSON parsing
      if (!e.toString().contains('FormatException') && !e.toString().contains('type')) {
        Get.snackbar(
          'خطأ في الاتصال',
          'لا يمكن تحميل أنواع العقارات. تحقق من الاتصال بالإنترنت',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }
  
  // Refresh data
  Future<void> refreshData() async {
    await loadData();
  }
  
  // Load favorites from storage
  void loadFavorites() {
    final savedFavorites = _storage.read<List>('favorites') ?? [];
    favoriteIds.assignAll(savedFavorites.cast<String>());
  }
  
  // Save favorites to storage
  void saveFavorites() {
    _storage.write('favorites', favoriteIds.toList());
  }
  
  // Toggle favorite status
  void toggleFavorite(Property property) {
    if (favoriteIds.contains(property.id)) {
      favoriteIds.remove(property.id);
      Get.snackbar(
        'تم الإزالة',
        'تم إزالة العقار من المفضلة',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        duration: const Duration(seconds: 2),
      );
    } else {
      favoriteIds.add(property.id);
      Get.snackbar(
        'تم الإضافة',
        'تم إضافة العقار إلى المفضلة',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 2),
      );
    }
    saveFavorites();
  }
  
  // Check if property is favorite
  bool isFavorite(String propertyId) {
    return favoriteIds.contains(propertyId);
  }
  
    // No mock data - API only mode
} 