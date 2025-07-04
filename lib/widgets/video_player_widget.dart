import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart'; // للتحقق من المنصة

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final double? height;
  final bool autoPlay;

  const VideoPlayerWidget({
    super.key, 
    required this.videoUrl,
    this.height,
    this.autoPlay = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late bool isYouTubeVideo;
  
  // For YouTube videos
  YoutubePlayerController? _youtubeController;
  
  // For direct video files
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  bool isWebPlatform = kIsWeb;

  @override
  void initState() {
    super.initState();
    print('🎬 VideoPlayerWidget initialized with URL: ${widget.videoUrl}');
    print('🌐 Platform: ${isWebPlatform ? 'Web' : 'Mobile'}');
    _initializePlayer();
  }

  /// ✅ تحديد نوع الفيديو وتهيئة المشغل المناسب
  Future<void> _initializePlayer() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });

      print('🔍 Analyzing video URL: ${widget.videoUrl}');
      
      // كشف ما إذا كان الرابط من يوتيوب
      isYouTubeVideo = _isYouTubeUrl(widget.videoUrl);
      
      print('📺 Video type detected: ${isYouTubeVideo ? 'YouTube' : 'Direct'}');
      
      // على منصة الويب، نُفضل YouTube على الفيديو المباشر
      if (isYouTubeVideo) {
        await _initializeYouTubePlayer();
      } else {
        // للفيديوهات المباشرة على الويب، نعرض خيار فتح في متصفح جديد
        if (isWebPlatform) {
          await _initializeWebVideoPlayer();
        } else {
          await _initializeDirectVideoPlayer();
        }
      }
      
      print('✅ Video player initialized successfully');
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error initializing video player: $e');
      
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'فشل في تحميل الفيديو: $e';
        });
      }
    }
  }

  /// ✅ فحص ما إذا كان الرابط من يوتيوب
  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || 
           url.contains('youtu.be') || 
           url.contains('m.youtube.com') ||
           url.contains('www.youtube.com');
  }

  /// ✅ تهيئة مشغل يوتيوب
  Future<void> _initializeYouTubePlayer() async {
    print('🔴 Initializing YouTube player...');
    
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    
    print('🆔 YouTube Video ID: $videoId');
    
    if (videoId == null) {
      throw Exception('رابط يوتيوب غير صالح');
    }

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: false,
        loop: false,
        hideControls: false,
        controlsVisibleAtStart: true,
        enableCaption: true,
        captionLanguage: 'ar',
        disableDragSeek: false,
        forceHD: false,
        useHybridComposition: isWebPlatform,
      ),
    );

    print('✅ YouTube player initialized with ID: $videoId');
  }

  /// ✅ تهيئة مشغل الفيديو للويب
  Future<void> _initializeWebVideoPlayer() async {
    print('🌐 Initializing web video player...');
    
    // على الويب، نُفضل إظهار نافذة أو iframe بدلاً من محاولة تشغيل الفيديو مباشرة
    // لأن الفيديوهات المباشرة قد لا تعمل بشكل صحيح على الويب
    
    print('ℹ️ Web platform detected - showing fallback option');
  }

  /// ✅ تهيئة مشغل الفيديو المباشر
  Future<void> _initializeDirectVideoPlayer() async {
    print('🎥 Initializing direct video player...');
    print('📎 Video URL: ${widget.videoUrl}');
    
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      
      // مراقبة الأخطاء
      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.hasError) {
          print('❌ Video player error: ${_videoPlayerController!.value.errorDescription}');
          
          if (mounted) {
            setState(() {
              hasError = true;
              errorMessage = 'خطأ في تشغيل الفيديو: ${_videoPlayerController!.value.errorDescription}';
            });
          }
        }
      });

      print('🔄 Initializing video controller...');
      await _videoPlayerController!.initialize();
      
      print('✅ Video controller initialized successfully');
      print('📊 Video info: ${_videoPlayerController!.value.size.width}x${_videoPlayerController!.value.size.height}');
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: widget.autoPlay,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          print('❌ Chewie error: $errorMessage');
          return _buildErrorWidget('فشل تحميل الفيديو: $errorMessage');
        },
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
      );
      
      print('✅ Chewie controller initialized');
      
    } catch (e) {
      print('❌ Error in direct video initialization: $e');
      throw e;
    }
  }

  @override
  void dispose() {
    print('🗑️ Disposing video player...');
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building video player widget - Loading: $isLoading, Error: $hasError');
    
    if (isLoading) {
      return _buildLoadingWidget();
    }
    
    if (hasError) {
      return _buildErrorWidget(errorMessage);
    }

    // للفيديوهات المباشرة على الويب، نعرض خيار بديل
    if (!isYouTubeVideo && isWebPlatform) {
      return _buildWebVideoFallback();
    }

    return Container(
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: isYouTubeVideo ? _buildYouTubePlayer() : _buildDirectVideoPlayer(),
    );
  }

  /// ✅ بناء مشغل يوتيوب
  Widget _buildYouTubePlayer() {
    if (_youtubeController == null) {
      return _buildErrorWidget('فشل في تهيئة مشغل يوتيوب');
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        bottomActions: [
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          RemainingDuration(),
          PlaybackSpeedButton(),
        ],
      ),
      builder: (context, player) {
        return Column(
          children: [
            Expanded(child: player),
          ],
        );
      },
    );
  }

  /// ✅ بناء مشغل الفيديو المباشر
  Widget _buildDirectVideoPlayer() {
    if (_chewieController == null) {
      return _buildErrorWidget('فشل في تهيئة مشغل الفيديو');
    }

    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) {
      return _buildErrorWidget('فشل في تهيئة مشغل الفيديو');
    }

    return Chewie(controller: _chewieController!);
  }

  /// ✅ بناء خيار بديل للفيديوهات على الويب
  Widget _buildWebVideoFallback() {
    return Container(
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'فيديو المشروع',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'انقر لمشاهدة الفيديو',
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Cairo',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(widget.videoUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'تشغيل الفيديو',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ واجهة التحميل
  Widget _buildLoadingWidget() {
    return Container(
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text(
              'جاري تحميل الفيديو...',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ واجهة الخطأ
  Widget _buildErrorWidget(String message) {
    return Container(
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _initializePlayer();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(widget.videoUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text(
                    isYouTubeVideo ? 'فتح في يوتيوب' : 'فتح الفيديو',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}