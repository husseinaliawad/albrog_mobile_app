import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

// ✅ Helper function to get Base64 image data
Future<Uint8List?> getBase64ImageData(String imageUrl) async {
  try {
    final dio = Dio();
    final encodedUrl = Uri.encodeComponent(imageUrl);
    final apiUrl = 'https://albrog.com/image_base64.php?url=$encodedUrl';
    
    final response = await dio.get(apiUrl);
    
    if (response.statusCode == 200 && response.data['success'] == true) {
      final dataUrl = response.data['data_url'] as String;
      return Uri.parse(dataUrl).data!.contentAsBytes();
    }
    return null;
  } catch (e) {
    print('🚨 Error loading Base64 image: $e');
    return null;
  }
}

class WordPressImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const WordPressImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<WordPressImage> createState() => _WordPressImageState();
}

class _WordPressImageState extends State<WordPressImage> {
  Uint8List? _imageData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImageAsBase64();
  }

  Future<void> _loadImageAsBase64() async {
    if (widget.imageUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Empty URL';
      });
      return;
    }

    print('🔄 Loading image as Base64: ${widget.imageUrl}');
    
    final imageData = await getBase64ImageData(widget.imageUrl);
    
    setState(() {
      if (imageData != null) {
        _imageData = imageData;
        _isLoading = false;
        _error = null;
        print('✅ Base64 image loaded successfully');
      } else {
        _isLoading = false;
        _error = 'Failed to load image';
        print('🚨 Failed to load Base64 image');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.secondary),
              SizedBox(height: 8),
              Text(
                'جاري تحميل الصورة...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null || _imageData == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 50,
              color: AppColors.primary,
            ),
            SizedBox(height: 8),
            Text(
              'صورة العقار',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              'غير متاحة مؤقتاً',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      );
    }

    // عرض الصورة من Base64
    return Image.memory(
      _imageData!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        print('🚨 Memory Image Error: $error');
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.1),
              ],
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work_outlined,
                size: 50,
                color: AppColors.primary,
              ),
              SizedBox(height: 8),
              Text(
                'خطأ في الصورة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 