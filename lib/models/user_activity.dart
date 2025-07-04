class UserActivity {
  final int id;
  final String type;
  final String title;
  final String subtitle;
  final String time;
  final DateTime createdAt;

  UserActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.createdAt,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: _parseInt(json['activity_id']),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      time: json['time'] ?? '',
      createdAt: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
    );
  }

  static int _parseInt(dynamic raw, {int defaultValue = 0}) {
    if (raw == null) return defaultValue;
    if (raw is num) return raw.toInt();
    final parsed = int.tryParse(raw.toString());
    return parsed ?? defaultValue;
  }

  // Getters للواجهة
  String get displayTitle {
    if (title.isNotEmpty) {
      return title;
    }
    if (type.isNotEmpty) {
      return type;
    }
    return 'نشاط جديد';
  }

  String get displaySubtitle {
    if (subtitle.isNotEmpty) {
      return subtitle;
    }
    return 'لا توجد تفاصيل إضافية';
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  // تحديد نوع الأيقونة حسب النشاط
  String get iconType {
    final typeKey = type.toLowerCase();
    final titleKey = title.toLowerCase();
    
    if (typeKey.contains('view') || typeKey.contains('عرض') || 
        titleKey.contains('view') || titleKey.contains('عرض')) {
      return 'view';
    } else if (typeKey.contains('contact') || typeKey.contains('اتصال') || 
               titleKey.contains('contact') || titleKey.contains('اتصال')) {
      return 'contact';
    } else if (typeKey.contains('favorite') || typeKey.contains('مفضلة') || 
               titleKey.contains('favorite') || titleKey.contains('مفضلة')) {
      return 'favorite';
    } else if (typeKey.contains('inquiry') || typeKey.contains('استفسار') || 
               titleKey.contains('inquiry') || titleKey.contains('استفسار')) {
      return 'inquiry';
    }
    return 'general';
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'time': time,
    };
  }
} 