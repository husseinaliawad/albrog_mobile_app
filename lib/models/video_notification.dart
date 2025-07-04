class VideoNotification {
  final int id;
  final int propertyId;
  final String title;
  final String message;
  final String type;
  final int videoCount;
  final List<YouTubeVideo> youtubeVideos;
  final bool isRead;
  final DateTime createdAt;

  VideoNotification({
    required this.id,
    required this.propertyId,
    required this.title,
    required this.message,
    required this.type,
    required this.videoCount,
    required this.youtubeVideos,
    required this.isRead,
    required this.createdAt,
  });

  factory VideoNotification.fromJson(Map<String, dynamic> json) {
    List<YouTubeVideo> videos = [];
    
    if (json['data'] != null && json['data']['youtube_ids'] != null) {
      final List<dynamic> videoIds = json['data']['youtube_ids'];
      videos = videoIds.map((video) => YouTubeVideo.fromJson(video)).toList();
    }

    return VideoNotification(
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      videoCount: json['data']?['video_count'] ?? 0,
      youtubeVideos: videos,
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'title': title,
      'message': message,
      'type': type,
      'video_count': videoCount,
      'youtube_videos': youtubeVideos.map((v) => v.toJson()).toList(),
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get timeAgo {
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
}

class YouTubeVideo {
  final String originalUrl;
  final String videoId;
  final String thumbnail;
  final String watchUrl;

  YouTubeVideo({
    required this.originalUrl,
    required this.videoId,
    required this.thumbnail,
    required this.watchUrl,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      originalUrl: json['original_url'] ?? '',
      videoId: json['video_id'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      watchUrl: json['watch_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_url': originalUrl,
      'video_id': videoId,
      'thumbnail': thumbnail,
      'watch_url': watchUrl,
    };
  }

  String get title => 'فيديو يوتيوب';
  
  String get description => 'انقر للمشاهدة على يوتيوب';
} 