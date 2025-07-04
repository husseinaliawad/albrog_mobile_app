import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_activity.dart';
import '../models/video_notification.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:dio/dio.dart';

class NotificationController extends GetxController {
  final ApiService _apiService = ApiService();
  final GetStorage _storage = GetStorage();
  final AuthService _authService = AuthService();

  // Observable variables
  var isLoading = false.obs;
  var activities = <UserActivity>[].obs;
  var videoNotifications = <VideoNotification>[].obs;
  var unreadCount = 0.obs;
  var videoUnreadCount = 0.obs;
  var currentUserId = 0; // 0 = لا يوجد مستخدم مسجل دخول
  var isUserLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // التحقق من حالة تسجيل الدخول أولاً
    checkAuthAndInitialize();
  }

  /// التحقق من المصادقة وتهيئة الإشعارات
  void checkAuthAndInitialize() {
    final wasLoggedIn = isUserLoggedIn.value;
    final previousUserId = currentUserId;
    
    isUserLoggedIn.value = _authService.isLoggedIn();

    if (isUserLoggedIn.value) {
      // المستخدم مسجل دخوله، يمكن تحميل الإشعارات
      final user = _authService.getUser();
      if (user != null && user.id > 0) {
        // ✅ استخدام ID المستخدم الحقيقي
        currentUserId = user.id;
        print('👤 Using authenticated user ID: $currentUserId (${user.name})');
        
        // إذا تغير المستخدم، مسح الإشعارات السابقة
        if (wasLoggedIn && previousUserId != currentUserId) {
          print('🔄 User changed from $previousUserId to $currentUserId, clearing old notifications');
          clearNotifications();
        }
      } else {
        print('❌ Invalid user data found, user needs to login again');
        // مسح البيانات التالفة وطلب تسجيل دخول جديد
        _authService.logout();
        isUserLoggedIn.value = false;
        clearNotifications();
        return;
      }

      loadUserActivities();
      loadUnreadCount();
      loadVideoNotifications();
      checkNewVideoNotifications();

      print('✅ Notifications initialized for user $currentUserId');
      debugPrintStatus();
    } else {
      // المستخدم غير مسجل دخوله، مسح جميع الإشعارات
      print('⚠️ User not logged in, clearing notifications');
      clearNotifications();
      currentUserId = 0; // لا يوجد مستخدم
    }
  }

  /// ✅ تمكين الإشعارات عند تسجيل الدخول - محدث
  void onUserLogin() {
    print('🔐 User logged in, refreshing notifications...');
    checkAuthAndInitialize();
  }
  
  /// ✅ دالة للاستدعاء عند تغيير المستخدم (للتوافق مع النسخة القديمة)
  void enableNotifications(int userId) {
    print('🔔 Enabling notifications for user $userId');
    onUserLogin(); // استخدام الدالة الجديدة
  }

  /// ✅ تعطيل الإشعارات عند تسجيل الخروج - محدث
  void onUserLogout() {
    print('🔐 User logged out, clearing all notifications');
    final oldUserId = currentUserId;
    
    isUserLoggedIn.value = false;
    currentUserId = 0;
    clearNotifications();
    
    print('✅ Cleared notifications for user $oldUserId');
  }
  
  /// ✅ دالة للتوافق مع النسخة القديمة
  void disableNotifications() {
    onUserLogout();
  }

  /// مسح جميع الإشعارات
  void clearNotifications() {
    activities.clear();
    videoNotifications.clear();
    unreadCount.value = 0;
    videoUnreadCount.value = 0;
  }

  /// Load user activities from API - محدث لاستخدام API الجديد
  Future<void> loadUserActivities({bool showLoading = true}) async {
    // التحقق من تسجيل الدخول أولاً
    if (!isUserLoggedIn.value || currentUserId <= 0) {
      print('⚠️ User not logged in or invalid user ID ($currentUserId), skipping activities load');
      activities.clear();
      unreadCount.value = 0;
      return;
    }

    try {
      if (showLoading) {
        isLoading.value = true;
      }

      print('🔄 Loading recent activities for user $currentUserId...');

      // ✅ استخدام ApiService بدلاً من Dio مباشرة
      final loadedActivities = await _apiService.getUserActivities(currentUserId, limit: 20);

      if (loadedActivities.isNotEmpty) {
        activities.assignAll(loadedActivities);
        updateUnreadCount();
        print('✅ Loaded ${loadedActivities.length} activities for user $currentUserId');
      } else {
        print('ℹ️ No activities found for user $currentUserId');
        activities.clear();
        unreadCount.value = 0;
      }
    } catch (e) {
      print('❌ Error loading user activities for user $currentUserId: $e');
      // لا نعرض snackbar في كل مرة، فقط نسجل الخطأ
      print('🔄 Will retry loading activities on next refresh');
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  /// تحديد نوع الأيقونة حسب نوع النشاط
  String _getIconTypeFromType(String? type) {
    switch (type) {
      case 'new_property':
        return 'view';
      case 'update':
        return 'favorite';
      case 'contact':
        return 'contact';
      case 'inquiry':
        return 'inquiry';
      default:
        return 'view';
    }
  }

  /// Refresh activities (pull to refresh)
  Future<void> refreshActivities() async {
    await loadUserActivities(showLoading: false);
  }

  /// Update unread count
  void updateUnreadCount() {
    // Get read activities from storage
    final readIds = getReadActivityIds();

    // Count unread activities
    final unread =
        activities.where((activity) => !readIds.contains(activity.id)).length;

    unreadCount.value = unread;
    print('📊 Unread activities count: $unread');
  }

  /// Mark activity as read - مع ربط بالمستخدم
  void markAsRead(int activityId) {
    final readIds = getReadActivityIds();
    if (!readIds.contains(activityId)) {
      readIds.add(activityId);
      _storage.write('read_activity_ids_$currentUserId', readIds);
      updateUnreadCount();
      print('✅ Marked activity $activityId as read for user $currentUserId');
    }
  }

  /// Mark all activities as read - مع ربط بالمستخدم  
  void markAllAsRead() {
    final allIds = activities.map((activity) => activity.id).toList();
    _storage.write('read_activity_ids_$currentUserId', allIds);
    unreadCount.value = 0;
    print('✅ Marked all activities as read for user $currentUserId');

    Get.snackbar(
      'تم',
      'تم وضع علامة مقروء على جميع الإشعارات',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 2),
    );
  }

  /// Get read activity IDs from storage - مخصص للمستخدم
  List<int> getReadActivityIds() {
    final stored = _storage.read('read_activity_ids_$currentUserId');
    if (stored is List) {
      return stored.cast<int>();
    }
    return [];
  }

  /// Load unread count from storage
  void loadUnreadCount() {
    updateUnreadCount();
  }

  /// Check if activity is read
  bool isActivityRead(int activityId) {
    return getReadActivityIds().contains(activityId);
  }

  /// Set current user ID (when user logs in)
  void setUserId(int userId) {
    if (currentUserId != userId) {
      final oldUserId = currentUserId;
      currentUserId = userId;
      print('👤 User changed from $oldUserId to $userId');
      
      // مسح الإشعارات الحالية
      clearNotifications();
      
      // إعادة تحميل الإشعارات للمستخدم الجديد
      loadUserActivities();
      loadVideoNotifications();
    }
  }

  /// Get filtered activities by type
  List<UserActivity> getActivitiesByType(String type) {
    return activities.where((activity) => activity.iconType == type).toList();
  }

  /// Get recent activities (last 7 days)
  List<UserActivity> getRecentActivities() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return activities
        .where((activity) => activity.createdAt.isAfter(sevenDaysAgo))
        .toList();
  }

  /// Clear all activities (for testing or logout)
  void clearActivities() {
    activities.clear();
    videoNotifications.clear();
    unreadCount.value = 0;
    videoUnreadCount.value = 0;
    print('🗑️ Cleared all activities');
  }

  /// مسح جميع البيانات المحفوظة للمستخدم الحالي
  void clearUserStoredData() {
    _storage.remove('read_activity_ids_$currentUserId');
    _storage.remove('read_video_ids_$currentUserId');
    print('🗑️ Cleared stored data for user $currentUserId');
    
    // إعادة حساب العداد
    updateUnreadCount();
    updateVideoUnreadCount();
  }

  /// وضع علامة مقروء على جميع إشعارات الفيديو
  void markAllVideoNotificationsAsRead() {
    final allVideoIds = videoNotifications.map((notif) => notif.id).toList();
    _storage.write('read_video_ids_$currentUserId', allVideoIds);
    videoUnreadCount.value = 0;
    print('✅ Marked all video notifications as read for user $currentUserId');

    Get.snackbar(
      'تم',
      'تم وضع علامة مقروء على جميع إشعارات الفيديو',
      backgroundColor: Colors.purple.shade100,
      colorText: Colors.purple.shade800,
      duration: const Duration(seconds: 2),
    );
  }

  /// Get activity icon based on type
  IconData getActivityIcon(UserActivity activity) {
    switch (activity.iconType) {
      case 'view':
        return Icons.visibility;
      case 'contact':
        return Icons.phone;
      case 'favorite':
        return Icons.favorite;
      case 'inquiry':
        return Icons.question_answer;
      default:
        return Icons.notifications;
    }
  }

  /// Get activity color based on type
  Color getActivityColor(UserActivity activity) {
    switch (activity.iconType) {
      case 'view':
        return Colors.blue;
      case 'contact':
        return Colors.green;
      case 'favorite':
        return Colors.red;
      case 'inquiry':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // 🎯 **الدوال الجديدة للفيديوهات**

  /// البحث عن فيديوهات جديدة
  Future<void> checkNewVideoNotifications({int hoursBack = 24}) async {
    try {
      isLoading.value = true;
      print('🎬 Checking for new video notifications...');

      final dio = Dio();
      final response = await dio.get(
        'https://albrog.com/youtube_notifications.php',
        queryParameters: {
          'hours_back': hoursBack,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        print('✅ Found ${response.data['count']} properties with videos');

        if (data != null && data is List) {
          // تحويل البيانات الجديدة إلى VideoNotification objects
          final newNotifications = <VideoNotification>[];

          // جلب الإشعارات المقروءة قبل إنشاء الإشعارات الجديدة
          final readVideoIds = getReadVideoIds();

          for (var property in data) {
            final propertyId = property['property_id'] ?? 0;
            final isRead = readVideoIds.contains(propertyId);

            final notification = VideoNotification(
              id: propertyId,
              propertyId: propertyId,
              title: property['title'] ?? '',
              message: "تم إضافة ${property['video_count']} فيديو جديد للمشروع",
              type: 'new_video',
              videoCount: property['video_count'] ?? 0,
              youtubeVideos: (property['videos'] as List?)
                      ?.map((video) => YouTubeVideo.fromJson(video))
                      .toList() ??
                  [],
              isRead: isRead, // استخدام الحالة المحفوظة
              createdAt: DateTime.tryParse(property['modified'] ?? '') ??
                  DateTime.now(),
            );

            newNotifications.add(notification);
          }

          videoNotifications.assignAll(newNotifications);
          updateVideoUnreadCount();

          // إظهار إشعار للمستخدم إذا وجدت فيديوهات جديدة
          if (newNotifications.isNotEmpty) {
            Get.snackbar(
              '🎬 فيديوهات جديدة',
              'تم العثور على ${newNotifications.length} مشروع بفيديوهات جديدة',
              backgroundColor: Colors.purple.shade100,
              colorText: Colors.purple.shade800,
              duration: const Duration(seconds: 4),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Error checking video notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب إشعارات الفيديو للمستخدم - تستخدم نفس API الفحص
  Future<void> loadVideoNotifications() async {
    // استخدام نفس دالة الفحص لتحميل الإشعارات
    await checkNewVideoNotifications(hoursBack: 168); // آخر أسبوع
  }

  /// تحديث عدد الإشعارات غير المقروءة للفيديوهات
  void updateVideoUnreadCount() {
    final readVideoIds = getReadVideoIds();
    final unread = videoNotifications.where((notif) => !readVideoIds.contains(notif.id)).length;
    videoUnreadCount.value = unread;
    print('📊 Video unread notifications count: $unread');
  }

  /// تحديد إشعار فيديو كمقروء - مع حفظ في التخزين المحلي
  Future<void> markVideoNotificationAsRead(int notificationId) async {
    try {
      // حفظ في التخزين المحلي
      final readVideoIds = getReadVideoIds();
      if (!readVideoIds.contains(notificationId)) {
        readVideoIds.add(notificationId);
        _storage.write('read_video_ids_$currentUserId', readVideoIds);
      }

      // تحديث الحالة محلياً
      final index =
          videoNotifications.indexWhere((notif) => notif.id == notificationId);
      if (index != -1) {
        final updatedNotification = VideoNotification(
          id: videoNotifications[index].id,
          propertyId: videoNotifications[index].propertyId,
          title: videoNotifications[index].title,
          message: videoNotifications[index].message,
          type: videoNotifications[index].type,
          videoCount: videoNotifications[index].videoCount,
          youtubeVideos: videoNotifications[index].youtubeVideos,
          isRead: true,
          createdAt: videoNotifications[index].createdAt,
        );

        videoNotifications[index] = updatedNotification;
        updateVideoUnreadCount();
      }

      print('✅ Marked video notification $notificationId as read for user $currentUserId');
    } catch (e) {
      print('❌ Error marking video notification as read: $e');
    }
  }

  /// الحصول على معرفات إشعارات الفيديو المقروءة
  List<int> getReadVideoIds() {
    final stored = _storage.read('read_video_ids_$currentUserId');
    if (stored is List) {
      return stored.cast<int>();
    }
    return [];
  }

  /// التحقق من قراءة إشعار فيديو
  bool isVideoNotificationRead(int notificationId) {
    return getReadVideoIds().contains(notificationId);
  }

  /// فتح فيديو يوتيوب
  void openYouTubeVideo(String videoId) {
    final url = 'https://www.youtube.com/watch?v=$videoId';
    // يمكنك استخدام url_launcher هنا
    print('🎬 Opening YouTube video: $url');

    Get.snackbar(
      'فيديو يوتيوب',
      'سيتم فتح الفيديو في المتصفح',
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 2),
    );
  }

  /// الحصول على إجمالي الإشعارات غير المقروءة
  int get totalUnreadCount => unreadCount.value + videoUnreadCount.value;

  /// دالة debug لطباعة حالة النظام
  void debugPrintStatus() {
    print('🔍 === NOTIFICATION SYSTEM DEBUG ===');
    print('👤 Current User ID: $currentUserId');
    print('🔓 Is Logged In: ${isUserLoggedIn.value}');
    print('📝 Total Activities: ${activities.length}');
    print('🎬 Total Video Notifications: ${videoNotifications.length}');
    print('📊 Unread Activities: ${unreadCount.value}');
    print('📊 Unread Videos: ${videoUnreadCount.value}');
    print('💾 Read Activity IDs: ${getReadActivityIds()}');
    print('💾 Read Video IDs: ${getReadVideoIds()}');
    print('🔍 === END DEBUG ===');
  }
}
