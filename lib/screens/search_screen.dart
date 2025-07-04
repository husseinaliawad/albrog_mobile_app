import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../models/property.dart';
import '../models/search_filter.dart';
import '../services/api_service.dart';
import '../widgets/property_card.dart';
import '../screens/property_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Property> searchResults = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreResults = true;
  int currentPage = 1;
  int totalResults = 0;
  
  // Filter variables
  String selectedType = '';
  String selectedStatus = '';
  double minPrice = 0;
  double maxPrice = 0;
  int minBedrooms = 0;
  int maxBedrooms = 0;
  int minBathrooms = 0;
  int maxBathrooms = 0;
  double minArea = 0;
  double maxArea = 0;
  String selectedCity = '';
  String selectedDistrict = '';
  String sortBy = 'date_desc';
  bool showFilters = false;
  
  // Property types
  final List<Map<String, String>> propertyTypes = [
    {'value': '', 'label': 'جميع الأنواع'},
    {'value': 'apartment', 'label': 'شقة'},
    {'value': 'villa', 'label': 'فيلا'},
    {'value': 'house', 'label': 'منزل'},
    {'value': 'office', 'label': 'مكتب'},
    {'value': 'shop', 'label': 'محل'},
    {'value': 'warehouse', 'label': 'مستودع'},
    {'value': 'land', 'label': 'أرض'},
    {'value': 'building', 'label': 'عمارة'},
  ];
  
  // Status options
  final List<Map<String, String>> statusOptions = [
    {'value': '', 'label': 'جميع الحالات'},
    {'value': 'for_sale', 'label': 'للبيع'},
    {'value': 'for_rent', 'label': 'للإيجار'},
    {'value': 'sold', 'label': 'تم البيع'},
    {'value': 'rented', 'label': 'تم التأجير'},
  ];
  
  // Sort options
  final List<Map<String, String>> sortOptions = [
    {'value': 'date_desc', 'label': 'الأحدث أولاً'},
    {'value': 'date_asc', 'label': 'الأقدم أولاً'},
    {'value': 'price_desc', 'label': 'الأغلى أولاً'},
    {'value': 'price_asc', 'label': 'الأرخص أولاً'},
    {'value': 'area_desc', 'label': 'الأكبر مساحة'},
    {'value': 'area_asc', 'label': 'الأصغر مساحة'},
    {'value': 'featured', 'label': 'المميزة أولاً'},
    {'value': 'alphabetical', 'label': 'ترتيب أبجدي'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!isLoadingMore && hasMoreResults) {
        _loadMoreResults();
      }
    }
  }

  Future<void> _performSearch({bool isNewSearch = true}) async {
    if (isNewSearch) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        searchResults.clear();
        hasMoreResults = true;
      });
    } else {
      setState(() {
        isLoadingMore = true;
      });
    }

    try {
      final response = await _apiService.dio.get('/advanced_search.php', queryParameters: {
        'keyword': _searchController.text,
        'type': selectedType,
        'status': selectedStatus,
        'min_price': minPrice > 0 ? minPrice : null,
        'max_price': maxPrice > 0 ? maxPrice : null,
        'min_bedrooms': minBedrooms > 0 ? minBedrooms : null,
        'max_bedrooms': maxBedrooms > 0 ? maxBedrooms : null,
        'min_bathrooms': minBathrooms > 0 ? minBathrooms : null,
        'max_bathrooms': maxBathrooms > 0 ? maxBathrooms : null,
        'min_area': minArea > 0 ? minArea : null,
        'max_area': maxArea > 0 ? maxArea : null,
        'city': selectedCity,
        'district': selectedDistrict,
        'sort_by': sortBy,
        'page': currentPage,
        'limit': 20,
      });

      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> propertiesData = response.data['data']['properties'];
        final List<Property> newProperties = propertiesData.map((json) => Property.fromJson(json)).toList();
        
        setState(() {
          if (isNewSearch) {
            searchResults = newProperties;
          } else {
            searchResults.addAll(newProperties);
          }
          
          totalResults = response.data['data']['pagination']['total_count'];
          hasMoreResults = response.data['data']['pagination']['current_page'] < 
                         response.data['data']['pagination']['total_pages'];
          
          if (!isNewSearch) {
            currentPage++;
          }
          
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      Get.snackbar('خطأ', 'حدث خطأ أثناء البحث');
    }
  }

  Future<void> _loadMoreResults() async {
    currentPage++;
    await _performSearch(isNewSearch: false);
  }

  void _clearFilters() {
    setState(() {
      selectedType = '';
      selectedStatus = '';
      minPrice = 0;
      maxPrice = 0;
      minBedrooms = 0;
      maxBedrooms = 0;
      minBathrooms = 0;
      maxBathrooms = 0;
      minArea = 0;
      maxArea = 0;
      selectedCity = '';
      selectedDistrict = '';
      sortBy = 'date_desc';
    });
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ترتيب النتائج',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...sortOptions.map((option) => RadioListTile<String>(
                  title: Text(option['label']!),
                  value: option['value']!,
                  groupValue: sortBy,
                  activeColor: AppColors.secondary,
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                    });
                    Navigator.pop(context);
                    _performSearch();
                  },
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text(
          'البحث',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _showSortModal,
            icon: const Icon(Icons.sort, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
            icon: Icon(
              showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن عقار...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.secondary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'بحث',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          // Filters Panel
          if (showFilters) _buildFiltersPanel(),
          
          // Results
          Expanded(
            child: _buildResultsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'فلاتر البحث',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  _clearFilters();
                  _performSearch();
                },
                child: const Text(
                  'مسح الفلاتر',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Type and Status Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    label: const Text('نوع العقار'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: propertyTypes.map((type) {
                    return DropdownMenuItem(
                      value: type['value'],
                      child: Text(type['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    label: const Text('الحالة'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status['value'],
                      child: Text(status['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Price Range
          const Text(
            'نطاق السعر (ريال)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    label: const Text('من'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    minPrice = double.tryParse(value) ?? 0;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    label: const Text('إلى'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    maxPrice = double.tryParse(value) ?? 0;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Bedrooms and Bathrooms
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    label: const Text('غرف النوم (من)'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    minBedrooms = int.tryParse(value) ?? 0;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    label: const Text('الحمامات (من)'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    minBathrooms = int.tryParse(value) ?? 0;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Apply Filters Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'تطبيق الفلاتر',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب تعديل معايير البحث',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Results Count
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تم العثور على $totalResults عقار',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_searchController.text.isNotEmpty)
                Text(
                  'البحث: "${_searchController.text}"',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        
        // Results List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: searchResults.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == searchResults.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: AppColors.secondary),
                  ),
                );
              }
              
              final property = searchResults[index];
              return PropertyCard(
                property: property,
                onTap: () => Get.to(() => PropertyDetailsScreen(property: property)),
                onFavorite: () {
                  // Handle favorite logic
                  Get.snackbar(
                    'المفضلة',
                    'تم إضافة العقار للمفضلة',
                    backgroundColor: AppColors.secondary,
                    colorText: Colors.white,
                  );
                },
                isFavorite: false,
              );
            },
          ),
        ),
      ],
    );
  }
}
