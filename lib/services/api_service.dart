// services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio_lib;
import 'package:get/get.dart';
import '../models/property.dart';
import '../models/popular_area.dart'; // <--- FIX IS HERE
import '../models/property_type.dart';
import '../models/search_filter.dart';
import '../models/user_activity.dart';
import '../models/video_notification.dart';

class ApiService extends GetxService {
  late dio_lib.Dio _dio;

  static const String baseUrlStatic = 'https://albrog.com';
  static const String wpBaseUrl = 'https://albrog.com/wp-json/wp/v2';

  String get baseUrl => baseUrlStatic;

  dio_lib.Dio get dio => _dio;

  ApiService() {
    _initializeDio();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = dio_lib.Dio(dio_lib.BaseOptions(
      baseUrl: baseUrlStatic,
      connectTimeout: const Duration(seconds: 60), // Increased timeout
      receiveTimeout: const Duration(seconds: 60), // Increased timeout
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(dio_lib.LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print(object),
    ));

    _dio.interceptors.add(dio_lib.InterceptorsWrapper(
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));
  }

  void _handleError(dio_lib.DioException error) {
    String message = 'حدث خطأ غير متوقع';

    switch (error.type) {
      case dio_lib.DioExceptionType.connectionTimeout:
      case dio_lib.DioExceptionType.sendTimeout:
      case dio_lib.DioExceptionType.receiveTimeout:
        message = 'انتهت مهلة الاتصال';
        break;
      case dio_lib.DioExceptionType.connectionError:
        message = 'لا يوجد اتصال بالإنترنت';
        break;
      case dio_lib.DioExceptionType.badResponse:
        if (error.response?.statusCode == 404) {
          message = 'الصفحة غير موجودة';
        } else if (error.response?.statusCode == 500) {
          message = 'خطأ في الخادم';
        } else {
          message = 'خطأ في الخادم: ${error.response?.statusCode}';
        }
        break;
      case dio_lib.DioExceptionType.cancel:
        message = 'تم إلغاء الطلب';
        break;
      case dio_lib.DioExceptionType.badCertificate:
        message = 'شهادة SSL غير صالحة';
        break;
      default:
        message = 'حدث خطأ في الشبكة';
    }

    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      colorText: Get.theme.colorScheme.error,
    );
  }

  Future<dio_lib.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio_lib.Options? options,
    dio_lib.CancelToken? cancelToken,
    dio_lib.ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<List<Property>> getMyProperties(int userId) async {
    try {
      print(
          '🚀 Making API call to: $baseUrl/my_properties.php?user_id=$userId');

      final response = await _dio.get(
        '/my_properties.php',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List<dynamic> propertiesList = data is List
            ? data
            : data['data'] is List
                ? data['data']
                : [];

        final properties =
            propertiesList.map((json) => Property.fromJson(json)).toList();

        print('✅ Loaded ${properties.length} properties for user $userId');
        return properties;
      }
      return [];
    } on dio_lib.DioException catch (e) {
      print('❌ Dio Error getting my properties: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error getting my properties: $e');
      return [];
    }
  }

  Future<List<Property>> getFeaturedProperties({int limit = 10}) async {
    try {
      print('🚀 Making API call to: $baseUrl/featured.php?limit=$limit');

      final response = await _dio.get(
        '/featured.php',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List<dynamic> propertiesList = data is List
            ? data
            : data['data'] is List
                ? data['data']
                : [];

        final properties =
            propertiesList.map((json) => Property.fromJson(json)).toList();

        if (properties.isNotEmpty) {
          print('🖼️ Sample thumbnail: ${properties.first.thumbnail}');
        }

        return properties;
      }
      return [];
    } on dio_lib.DioException catch (e) {
      print('❌ Dio Error getting featured properties: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error getting featured properties: $e');
      return [];
    }
  }

  Future<List<Property>> getRecentProperties({int limit = 10}) async {
    try {
      print('🚀 Making API call to: $baseUrl/recent.php?limit=$limit');

      final response = await _dio.get(
        '/recent.php',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List<dynamic> propertiesList = data is List
            ? data
            : data['data'] is List
                ? data['data']
                : [];

        final properties =
            propertiesList.map((json) => Property.fromJson(json)).toList();

        if (properties.isNotEmpty) {
          print('🖼️ Recent thumbnail: ${properties.first.thumbnail}');
          print('🏠 Recent title: ${properties.first.title}');
        }

        return properties;
      }
      return [];
    } on dio_lib.DioException catch (e) {
      print('❌ Dio Error getting recent properties: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error getting recent properties: $e');
      return [];
    }
  }

  Future<List<Property>> searchProperties(SearchFilter filter,
      {int page = 1, int limit = 20}) async {
    try {
      final queryParams = filter.toQueryParameters();
      queryParams.addAll({
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await _dio.get(
        '/search.php',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> propertiesList = data is List
            ? data
            : data['data'] is List
                ? data['data']
                : [];
        return propertiesList.map((json) => Property.fromJson(json)).toList();
      }
      return [];
    } on dio_lib.DioException catch (e) {
      print('❌ Dio Error searching properties: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error searching properties: $e');
      return [];
    }
  }

  Future<Property?> getPropertyById(int id) async {
    try {
      final response = await _dio.get(
        '/property.php',
        queryParameters: {'id': id},
      );

      if (response.statusCode == 200) {
        if (response.data != null && response.data['data'] != null) {
          return Property.fromJson(response.data['data']);
        }
      }
      return null;
    } on dio_lib.DioException catch (e) {
      print('❌ Dio Error getting property by ID: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error getting property: $e');
      return null;
    }
  }

  /// ✅ GET Popular Areas
  Future<List<PopularArea>> getPopularAreas({int limit = 6}) async {
    try {
      print('🚀 Making API call to: $baseUrl/popular_areas.php?limit=$limit');

      final response = await _dio.get(
        '/popular_areas.php',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> areasList = data is List
            ? data
            : data['data'] is List
                ? data['data']
                : [];

        final areas =
            areasList.map((json) => PopularArea.fromJson(json)).toList();
        print('✅ Successfully parsed ${areas.length} popular areas');
        return areas;
      }
      return [];
    } on dio_lib.DioException catch (e) {
      print('❌ Dio Error getting popular areas: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error getting popular areas: $e');
      return [];
    }
  }

  /// ✅ GET Property Types with counts
  Future<List<PropertyType>> getPropertyTypes({int limit = 10}) async {
    try {
      print('🚀 Making API call to: $baseUrl/property_types.php?limit=$limit');

      final response = await _dio.get(
        '/property_types.php',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> typesList = data is List
            ? data
            : data['data'] is List
                ? data['data']
                : [];

        final types =
            typesList.map((json) => PropertyType.fromJson(json)).toList();
        print('✅ Successfully parsed ${types.length} property types');
        return types;
      }
      return [];
    } on dio_lib.DioException catch (e) {
      print('❌ Dio Error getting property types: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error getting property types: $e');
      return [];
    }
  }

  /// ✅ GET property types (Legacy - returns strings only)
  Future<List<String>> getPropertyTypeNames() async {
    try {
      final types = await getPropertyTypes();
      return types.map((type) => type.displayName).toList();
    } catch (e) {
      print('Error getting property type names: $e');
      return [];
    }
  }

  /// ✅ WordPress properties (optional)
  Future<List<Property>> getWordPressProperties() async {
    try {
      final response = await http.get(
        Uri.parse('$wpBaseUrl/posts?categories=properties&per_page=20'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> posts = json.decode(response.body);
        return posts.map((post) => _convertWordPressPost(post)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching WordPress properties: $e');
      return [];
    }
  }

  /// ✅ Get all Properties with filters (search.php)
  Future<List<Property>> getProperties({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
    String? city,
    String? sortBy,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;
      if (city != null) queryParams['city'] = city;
      if (sortBy != null) queryParams['orderby'] = sortBy;

      final response = await _dio.get(
        '/search.php',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> propertiesList = data is List
            ? data
            : data['data'] is List
                ? data['data']
                : [];
        return propertiesList.map((json) => Property.fromJson(json)).toList();
      }
      return [];
    } on dio_lib.DioException catch (e) {
      print('❌ Dio Error getting properties: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error getting properties: $e');
      return [];
    }
  }

  Property _convertWordPressPost(Map<String, dynamic> post) {
    return Property(
      id: post['id'].toString(),
      title: post['title']['rendered'] ?? '',
      description: _stripHtml(post['content']['rendered'] ?? ''),
      price: _extractPrice(post['meta'] ?? {}),
      area: _extractArea(post['meta'] ?? {}),
      bedrooms: _extractBedrooms(post['meta'] ?? {}),
      bathrooms: _extractBathrooms(post['meta'] ?? {}),
      location: _extractLocation(post['meta'] ?? {}),
      thumbnail: _extractThumbnail(post),
      images: _extractImages(post),
      type: _extractType(post['meta'] ?? {}),
      status: _extractStatus(post['meta'] ?? {}),
      isFeatured: post['sticky'] ?? false,
      createdAt: DateTime.tryParse(post['date'] ?? '') ?? DateTime.now(),
      latitude: _extractLatitude(post['meta'] ?? {}),
      longitude: _extractLongitude(post['meta'] ?? {}),
      agent: _extractAgent(post['meta'] ?? {}),
    );
  }

  String _stripHtml(String html) => html.replaceAll(RegExp(r'<[^>]*>'), '');
  double _extractPrice(Map<String, dynamic> meta) =>
      (meta['property_price'] ?? 0).toDouble();
  double _extractArea(Map<String, dynamic> meta) =>
      (meta['property_area'] ?? 0).toDouble();
  int _extractBedrooms(Map<String, dynamic> meta) =>
      meta['property_bedrooms'] ?? 0;
  int _extractBathrooms(Map<String, dynamic> meta) =>
      meta['property_bathrooms'] ?? 0;
  String _extractLocation(Map<String, dynamic> meta) =>
      meta['property_location'] ?? '';

  String _extractThumbnail(Map<String, dynamic> post) {
    final featured = post['_embedded']?['wp:featuredmedia'];
    if (featured != null && featured is List && featured.isNotEmpty) {
      final sourceUrl = featured[0]['source_url'];
      if (sourceUrl != null && sourceUrl.toString().isNotEmpty) {
        return sourceUrl.toString();
      }
    }
    return 'https://albrog.com/wp-content/uploads/2025/default-property.jpg';
  }

  List<String> _extractImages(Map<String, dynamic> post) {
    final images = <String>[];
    final featured = post['_embedded']?['wp:featuredmedia'];
    if (featured != null && featured is List && featured.isNotEmpty) {
      final sourceUrl = featured[0]['source_url'];
      if (sourceUrl != null && sourceUrl.toString().isNotEmpty) {
        images.add(sourceUrl);
      }
    }
    final gallery = post['meta']?['property_gallery'];
    if (gallery != null && gallery is List) {
      images.addAll(gallery.whereType<String>());
    }
    return images;
  }

  String _extractType(Map<String, dynamic> meta) =>
      meta['property_type'] ?? 'apartment';
  String _extractStatus(Map<String, dynamic> meta) =>
      meta['property_status'] ?? 'for_sale';
  double _extractLatitude(Map<String, dynamic> meta) =>
      (meta['property_latitude'] ?? 0).toDouble();
  double _extractLongitude(Map<String, dynamic> meta) =>
      (meta['property_longitude'] ?? 0).toDouble();
  PropertyAgent _extractAgent(Map<String, dynamic> meta) {
    return PropertyAgent(
      id: meta['agent_id']?.toString() ?? '1',
      name: meta['agent_name'] ?? '',
      phone: meta['agent_phone'] ?? '',
      email: meta['agent_email'] ?? '',
    );
  }

  /// ✅ GET User Activities (Notifications)
  Future<List<UserActivity>> getUserActivities(int userId,
      {int limit = 20}) async {
    try {
      print(
          '🚀 Making API call to: $baseUrl/get_user_activities.php?user_id=$userId&limit=$limit');

      final response = await _dio.get(
        '/get_user_activities.php',
        queryParameters: {
          'user_id': userId,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> activitiesList =
              data['data'] is List ? data['data'] : [];

          final activities = activitiesList
              .map((json) => UserActivity.fromJson(json))
              .toList();

          print('✅ Successfully loaded ${activities.length} user activities');
          return activities;
        } else {
          print('⚠️ API returned success: false for user activities');
          return [];
        }
      }
      return [];
    } on dio_lib.DioException catch (e) {
      print('❌ Dio Error getting user activities: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error getting user activities: $e');
      return [];
    }
  }

  /// ✅ GET Video Notifications (YouTube videos related to properties)
  Future<List<VideoNotification>> getVideoNotifications(
      {int hoursBack = 168}) async {
    try {
      print(
          '🚀 Making API call to: $baseUrl/youtube_notifications.php?hours_back=$hoursBack');

      final response = await _dio.get(
        '/youtube_notifications.php',
        queryParameters: {
          'hours_back': hoursBack,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] is List) {
          final List<dynamic> videoDataList = data['data'];
          final notifications = videoDataList
              .map((json) => VideoNotification.fromJson(json))
              .toList();
          print(
              '✅ Successfully loaded ${notifications.length} video notifications.');
          return notifications;
        } else {
          print(
              '⚠️ API returned success: false or data is not a list for video notifications.');
          return [];
        }
      }
      return [];
    } on dio_lib.DioException catch (e) {
      print('❌ Dio Error getting video notifications: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected Error getting video notifications: $e');
      return [];
    }
  }

  /// ✅ إضافة إشعار عند رفع صور للعقار
  Future<bool> addPropertyImageNotification({
    required int propertyId,
    required int imageCount,
    String uploaderName = 'المشرف',
  }) async {
    try {
      print('🚀 Adding property image notification for property $propertyId');

      final response = await _dio.post(
        '/add_property_image_notification.php',
        data: {
          'property_id': propertyId,
          'image_count': imageCount,
          'uploader_name': uploaderName,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          print('✅ Image notification sent successfully: ${data['message']}');
          print('📤 Sent to: ${data['notifications_sent_to']}');
          return true;
        }
      }
      return false;
    } on dio_lib.DioException catch (e) {
      print('❌ Error adding image notification: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Error adding image notification: $e');
      return false;
    }
  }

  /// ✅ إضافة إشعار عند تحديث نسبة الإنجاز
  Future<bool> addProgressUpdateNotification({
    required int propertyId,
    required int oldProgress,
    required int newProgress,
    String notes = '',
    String updaterName = 'إدارة المشروع',
  }) async {
    try {
      print('🚀 Adding progress update notification for property $propertyId');

      final response = await _dio.post(
        '/add_progress_notification.php',
        data: {
          'property_id': propertyId,
          'old_progress': oldProgress,
          'new_progress': newProgress,
          'notes': notes,
          'updater_name': updaterName,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          print('✅ Progress notification sent successfully: ${data['message']}');
          print('📊 Progress: ${data['progress_update']['from']}% → ${data['progress_update']['to']}%');
          print('📤 Sent to: ${data['notifications_sent_to']}');
          return true;
        }
      }
      return false;
    } on dio_lib.DioException catch (e) {
      print('❌ Error adding progress notification: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Error adding progress notification: $e');
      return false;
    }
  }
}
