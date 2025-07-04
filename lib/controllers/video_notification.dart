// models/video_notification.dart

import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // Assuming you have this package for YoutubePlayer.getThumbnail

class YouTubeVideo {
  final String id;
  final String title;
  final String thumbnailUrl;

  YouTubeVideo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ??
          YoutubePlayer.getThumbnail(videoId: json['id'] ?? ''),
    );
  }
}

class VideoNotification {
  final int id; // Assuming 'id' is int based on property_id
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
    this.isRead = false, // Default to false
    required this.createdAt,
  });

  factory VideoNotification.fromJson(Map<String, dynamic> json) {
    return VideoNotification(
      id: json['property_id'] ??
          0, // Using property_id as the unique ID for the notification
      propertyId: json['property_id'] ?? 0,
      title: json['title'] ?? 'فيديو جديد',
      message: json['message'] ??
          '', // Assuming there's a message field in API response
      type: json['type'] ?? 'new_video', // Default type
      videoCount: json['video_count'] ?? 0,
      youtubeVideos: (json['videos'] as List?)
              ?.map((videoJson) => YouTubeVideo.fromJson(videoJson))
              .toList() ??
          [],
      isRead: json['is_read'] == 1 ||
          json['is_read'] == true, // Handle boolean or int from API
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Add the copyWith method here to enable immutable updates
  VideoNotification copyWith({
    int? id,
    int? propertyId,
    String? title,
    String? message,
    String? type,
    int? videoCount,
    List<YouTubeVideo>? youtubeVideos,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return VideoNotification(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      videoCount: videoCount ?? this.videoCount,
      youtubeVideos: youtubeVideos ?? this.youtubeVideos,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
