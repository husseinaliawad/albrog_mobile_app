import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/property.dart';
import '../models/search_filter.dart';
import '../services/api_service.dart';

class PropertiesController extends GetxController {
  final ApiService _apiService = ApiService();
  final GetStorage _storage = GetStorage();

  // Controllers
  final TextEditingController searchController = TextEditingController();

  // Observable variables
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var properties = <Property>[].obs;
  var searchFilter = SearchFilter().obs;
  var favoriteIds = <String>[].obs;
  var isGridView = true.obs;
  var sortBy = 'newest'.obs;
  var hasMoreData = true.obs;
  var currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
    loadProperties();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Load properties
  Future<void> loadProperties({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
        properties.clear();
      }

      if (!hasMoreData.value) return;

      if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final newProperties = await _apiService.getProperties(
        page: currentPage.value,
        limit: 20,
        type: searchFilter.value.type,
        status: searchFilter.value.status,
        city: searchFilter.value.city,
        sortBy: sortBy.value,
      );

      if (newProperties.isNotEmpty) {
        if (refresh) {
          properties.assignAll(newProperties);
        } else {
          properties.addAll(newProperties);
        }
        currentPage.value++;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      print('Error loading properties: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل العقارات',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more properties
  Future<void> loadMore() async {
    if (!isLoadingMore.value && hasMoreData.value) {
      await loadProperties();
    }
  }

  // Refresh properties
  Future<void> refreshProperties() async {
    await loadProperties(refresh: true);
  }

  // Search properties
  void search(String query) {
    searchController.text = query;
    searchFilter.value = searchFilter.value.copyWith(query: query);
    applyFilters();
  }

  // Apply filters
  Future<void> applyFilters() async {
    try {
      isLoading.value = true;
      properties.clear();
      currentPage.value = 1;
      hasMoreData.value = true;

      final results = await _apiService.searchProperties(searchFilter.value);
      properties.assignAll(results);
    } catch (e) {
      print('Error applying filters: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء البحث',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update sort
  void updateSort(String? newSortBy) {
    if (newSortBy != null) {
      sortBy.value = newSortBy;
      refreshProperties();
    }
  }

  // Toggle view
  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  // Filter methods
  void setPropertyType(String? type) {
    searchFilter.value =
        searchFilter.value.copyWith(type: type, clearType: type == null);
  }

  void setPropertyStatus(String? status) {
    searchFilter.value = searchFilter.value
        .copyWith(status: status, clearStatus: status == null);
  }

  void setCity(String? city) {
    searchFilter.value =
        searchFilter.value.copyWith(city: city, clearCity: city == null);
  }

  void setDistrict(String? district) {
    searchFilter.value = searchFilter.value
        .copyWith(district: district, clearDistrict: district == null);
  }

  void setPriceRange(double? minPrice, double? maxPrice) {
    searchFilter.value = searchFilter.value.copyWith(
      minPrice: minPrice,
      maxPrice: maxPrice,
      clearPrice: minPrice == null && maxPrice == null,
    );
  }

  void setAreaRange(double? minArea, double? maxArea) {
    searchFilter.value = searchFilter.value.copyWith(
      minArea: minArea,
      maxArea: maxArea,
      clearArea: minArea == null && maxArea == null,
    );
  }

  void setBedrooms(int? bedrooms) {
    searchFilter.value = searchFilter.value
        .copyWith(bedrooms: bedrooms, clearBedrooms: bedrooms == null);
  }

  void setBathrooms(int? bathrooms) {
    searchFilter.value = searchFilter.value
        .copyWith(bathrooms: bathrooms, clearBathrooms: bathrooms == null);
  }

  void setFurnished(bool? furnished) {
    searchFilter.value = searchFilter.value
        .copyWith(furnished: furnished, clearFurnished: furnished == null);
  }

  void setFeatures(List<String>? features) {
    searchFilter.value = searchFilter.value
        .copyWith(features: features, clearFeatures: features == null);
  }

  void setAmenities(List<String>? amenities) {
    searchFilter.value = searchFilter.value
        .copyWith(amenities: amenities, clearAmenities: amenities == null);
  }

  // Clear all filters
  void clearFilters() {
    searchController.clear();
    searchFilter.value = SearchFilter();
    refreshProperties();
  }

  // Add missing filter management methods
  void removeFilter(String filterType) {
    switch (filterType) {
      case 'type':
        setPropertyType(null);
        break;
      case 'status':
        setPropertyStatus(null);
        break;
      case 'city':
        setCity(null);
        break;
      case 'price':
        setPriceRange(null, null);
        break;
      case 'area':
        setAreaRange(null, null);
        break;
      case 'bedrooms':
        setBedrooms(null);
        break;
      case 'bathrooms':
        setBathrooms(null);
        break;
    }
    applyFilters();
  }

  void updateFilter(String filterType, dynamic value) {
    switch (filterType) {
      case 'type':
        setPropertyType(value);
        break;
      case 'status':
        setPropertyStatus(value);
        break;
      case 'city':
        setCity(value);
        break;
      case 'minPrice':
        setPriceRange(value, searchFilter.value.maxPrice);
        break;
      case 'maxPrice':
        setPriceRange(searchFilter.value.minPrice, value);
        break;
      case 'minArea':
        setAreaRange(value, searchFilter.value.maxArea);
        break;
      case 'maxArea':
        setAreaRange(searchFilter.value.minArea, value);
        break;
      case 'minBedrooms':
        setBedrooms(value);
        break;
      case 'bathrooms':
        setBathrooms(value);
        break;
    }
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

  // Get filtered properties
  List<Property> get filteredProperties {
    return properties.where((property) {
      // Apply local filters if needed
      return true;
    }).toList();
  }

  // Get property types for filter
  List<String> get propertyTypes {
    return [
      'apartment',
      'villa',
      'office',
      'shop',
      'land',
      'warehouse',
    ];
  }

  // Get property statuses for filter
  List<String> get propertyStatuses {
    return [
      'for_sale',
      'for_rent',
    ];
  }

  // Get sort options
  List<String> get sortOptions {
    return [
      'newest',
      'oldest',
      'price_low_high',
      'price_high_low',
      'area_low_high',
      'area_high_low',
    ];
  }
}

// Extension for property type display
extension PropertyTypeExtension on String {
  String get displayName {
    switch (this) {
      case 'apartment':
        return 'شقة';
      case 'villa':
        return 'فيلا';
      case 'office':
        return 'مكتب';
      case 'shop':
        return 'محل تجاري';
      case 'land':
        return 'أرض';
      case 'warehouse':
        return 'مستودع';
      default:
        return this;
    }
  }
}

// Extension for property status display
extension PropertyStatusExtension on String {
  String get displayName {
    switch (this) {
      case 'for_sale':
        return 'للبيع';
      case 'for_rent':
        return 'للإيجار';
      default:
        return this;
    }
  }
}

// Extension for sort options display
extension SortOptionExtension on String {
  String get displayName {
    switch (this) {
      case 'newest':
        return 'الأحدث';
      case 'oldest':
        return 'الأقدم';
      case 'price_low_high':
        return 'السعر من الأقل للأعلى';
      case 'price_high_low':
        return 'السعر من الأعلى للأقل';
      case 'area_low_high':
        return 'المساحة من الأقل للأعلى';
      case 'area_high_low':
        return 'المساحة من الأعلى للأقل';
      default:
        return this;
    }
  }
}
