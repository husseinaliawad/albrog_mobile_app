import 'package:get/get.dart';
import '../models/property.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';
import '../screens/property_details_screen.dart';

class ClientDashboardController extends GetxController {
  /// ✅ الربط بالخدمات
  final ApiService _api = Get.find<ApiService>();
  final AuthController _auth = Get.find<AuthController>();

  /// ✅ بيانات المستخدم
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final userImage = ''.obs;
  final memberSince = ''.obs;

  /// ✅ الإحصائيات
  final favoritesCount = 0.obs;
  final savedSearchesCount = 0.obs;
  final visitsCount = 0.obs;
  final reviewsCount = 0.obs;
  final requestsCount = 0.obs;
  final notificationsCount = 0.obs;

  /// ✅ الأنشطة الحديثة
  final recentActivities = <Map<String, dynamic>>[].obs;

  /// ✅ قائمة العقارات
  final myProperties = <Property>[].obs;

  /// ✅ حالات التحميل
  final isLoading = false.obs;
  final isRefreshing = false.obs;

  /// ✅ عند التشغيل
  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    loadMyProperties();
  }

  /// ✅ جلب معرف المستخدم
  int? get userId => _auth.currentUser.value?.id;

  /// ✅ تحميل لوحة التحكم
  Future<void> loadDashboardData() async {
    if (userId == null) {
      Get.snackbar('خطأ', 'المستخدم غير مسجل دخول');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _api.dio.get(
        '/client_dashboard.php',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final profile = response.data['data']['profile'];
        final activities = response.data['data']['recent_activities'] ?? [];

        userName.value = profile['user_name'] ?? '';
        userEmail.value = profile['user_email'] ?? '';
        userPhone.value = profile['phone'] ?? '';
        userImage.value = profile['profile_image'] ?? '';
        memberSince.value = (profile['user_registered'] ?? '').split(' ').first;

        favoritesCount.value =
            int.tryParse('${profile['favorites_count']}') ?? 0;
        savedSearchesCount.value =
            int.tryParse('${profile['saved_searches_count']}') ?? 0;
        visitsCount.value = int.tryParse('${profile['visits_count']}') ?? 0;
        reviewsCount.value = int.tryParse('${profile['reviews_count']}') ?? 0;
        requestsCount.value = int.tryParse('${profile['requests_count']}') ?? 0;
        notificationsCount.value =
            int.tryParse('${profile['notifications_count']}') ?? 0;

        recentActivities.value = List<Map<String, dynamic>>.from(activities);
      } else {
        Get.snackbar('خطأ', 'فشل تحميل بيانات لوحة التحكم');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء الاتصال بالخادم');
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ تحميل العقارات وتحويلها لـ Property
  Future<void> loadMyProperties() async {
    if (userId == null) {
      Get.snackbar('خطأ', 'المستخدم غير مسجل دخول');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _api.dio.get(
        '/my_properties.php',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> props = response.data['data'] ?? [];
        myProperties.value = props.map((e) => Property.fromJson(e)).toList();
      } else {
        Get.snackbar('خطأ', 'فشل تحميل العقارات');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء الاتصال بالخادم');
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ تحديث الكل
  Future<void> refreshDashboard() async {
    isRefreshing.value = true;
    await loadDashboardData();
    await loadMyProperties();
    isRefreshing.value = false;
  }

  /// ✅ فتح تفاصيل العقار بـ Property كامل
  void goToPropertyDetails(Property property) {
    Get.to(() => PropertyDetailsScreen(property: property));
  }

  /// ✅ التنقلات الأخرى
  void goToFavorites() => Get.toNamed('/favorites');
  void goToSavedSearches() => Get.toNamed('/saved-searches');
  void goToVisits() => Get.toNamed('/visits');
  void goToRequests() => Get.toNamed('/requests');
  void goToReviews() => Get.toNamed('/reviews');
  void goToSettings() => Get.toNamed('/settings');
  void goToProfile() => Get.toNamed('/profile');
  void goToNotifications() => Get.toNamed('/notifications');
}
