import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';
import '../models/user_activity.dart';
import '../models/video_notification.dart';
import '../widgets/video_notification_card.dart';
import '../constants/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Obx(() => Text(
            'الإشعارات (${controller.totalUnreadCount})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.refreshActivities();
                controller.checkNewVideoNotifications();
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Obx(() => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications),
                    const SizedBox(width: 8),
                    Text('عام'),
                    if (controller.unreadCount.value > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${controller.unreadCount.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
              Obx(() => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.video_library),
                    const SizedBox(width: 8),
                    Text('فيديوهات'),
                    if (controller.videoUnreadCount.value > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${controller.videoUnreadCount.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: General Notifications
            _buildGeneralNotifications(controller),
            // Tab 2: Video Notifications  
            _buildVideoNotifications(controller),
          ],
        ),
      ),
    );
  }

  // 🎯 **بناء تبويب الإشعارات العامة**
  Widget _buildGeneralNotifications(NotificationController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.activities.isEmpty) {
        return _buildEmptyState(
          icon: Icons.notifications_none,
          title: 'لا توجد إشعارات عامة',
          subtitle: 'سيتم عرض الإشعارات هنا عند توفرها',
          onRefresh: controller.refreshActivities,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshActivities,
        child: Column(
          children: [
            // Mark All as Read Button
            if (controller.unreadCount.value > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: controller.markAllAsRead,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('تحديد الكل كمقروء'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            // Notifications List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.activities.length,
                itemBuilder: (context, index) {
                  final activity = controller.activities[index];
                  final isRead = controller.isActivityRead(activity.id);
                  
                  return NotificationCard(
                    activity: activity,
                    isRead: isRead,
                    onTap: () {
                      controller.markAsRead(activity.id);
                      _showActivityDetails(context, activity);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // 🎯 **بناء تبويب إشعارات الفيديو**
  Widget _buildVideoNotifications(NotificationController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.videoNotifications.isEmpty) {
        return _buildEmptyState(
          icon: Icons.video_library_outlined,
          title: 'لا توجد إشعارات فيديو',
          subtitle: 'سيتم إشعارك عند إضافة فيديوهات جديدة للمشاريع',
          onRefresh: () => controller.checkNewVideoNotifications(),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.checkNewVideoNotifications(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.videoNotifications.length,
          itemBuilder: (context, index) {
            final notification = controller.videoNotifications[index];
            
            return VideoNotificationCard(
              notification: notification,
              onTap: () {
                // Navigate to property details
                Get.toNamed('/property/${notification.propertyId}');
              },
              onVideoTap: (videoId) {
                controller.openYouTubeVideo(videoId);
              },
              onMarkAsRead: !notification.isRead 
                  ? () => controller.markVideoNotificationAsRead(notification.id)
                  : null,
            );
          },
        ),
      );
    });
  }

  // 🎯 **بناء حالة فارغة موحدة**
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onRefresh,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(BuildContext context, UserActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.displayTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity.title.isNotEmpty) ...[
              Text('العنوان: ${activity.title}'),
              const SizedBox(height: 8),
            ],
            if (activity.subtitle.isNotEmpty) ...[
              Text('التفاصيل: ${activity.subtitle}'),
              const SizedBox(height: 8),
            ],
            if (activity.type.isNotEmpty) ...[
              Text('نوع النشاط: ${activity.type}'),
              const SizedBox(height: 8),
            ],
            Text('التوقيت: ${activity.time}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final UserActivity activity;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.activity,
    required this.isRead,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey.shade200 : Colors.blue.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Activity Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: controller.getActivityColor(activity).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    controller.getActivityIcon(activity),
                    color: controller.getActivityColor(activity),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Activity Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.displayTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (activity.displaySubtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          activity.displaySubtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        activity.formattedTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Unread Indicator
                if (!isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 