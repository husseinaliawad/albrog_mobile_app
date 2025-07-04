import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// أداة تشخيص مشاكل الصور وإصلاحها
class ImageDiagnostic {
  
  /// اختبار صحة رابط الصورة
  static Future<ImageTestResult> testImageUrl(String url) async {
    if (url.isEmpty) {
      return ImageTestResult(
        isValid: false,
        error: 'الرابط فارغ',
        suggestion: 'استخدم رابط صورة صحيح',
      );
    }

    if (!url.startsWith('http')) {
      return ImageTestResult(
        isValid: false,
        error: 'الرابط لا يبدأ بـ http/https',
        suggestion: 'تأكد من أن الرابط يبدأ بـ https://',
      );
    }

    try {
      // تنظيف الرابط أولاً
      final cleanUrl = _cleanUrl(url);
      
      // اختبار الوصول للرابط
      final response = await http.head(Uri.parse(cleanUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        // التحقق من نوع المحتوى
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.startsWith('image/')) {
          return ImageTestResult(
            isValid: true,
            cleanUrl: cleanUrl,
            contentType: contentType,
            message: 'الصورة متاحة وصحيحة',
          );
        } else {
          return ImageTestResult(
            isValid: false,
            error: 'الرابط لا يشير إلى صورة',
            contentType: contentType,
            suggestion: 'تأكد من أن الرابط يشير إلى ملف صورة (jpg, png, gif, etc.)',
          );
        }
      } else {
        return ImageTestResult(
          isValid: false,
          error: 'خطأ في الوصول للصورة: ${response.statusCode}',
          suggestion: _getSuggestionForStatusCode(response.statusCode),
        );
      }
    } on SocketException {
      return ImageTestResult(
        isValid: false,
        error: 'لا يوجد اتصال بالإنترنت',
        suggestion: 'تحقق من اتصال الإنترنت',
      );
    } on HttpException catch (e) {
      return ImageTestResult(
        isValid: false,
        error: 'خطأ HTTP: ${e.message}',
        suggestion: 'تحقق من صحة الرابط أو اتصال الإنترنت',
      );
    } catch (e) {
      return ImageTestResult(
        isValid: false,
        error: 'خطأ غير متوقع: $e',
        suggestion: 'جرب رابط صورة آخر',
      );
    }
  }

  /// تنظيف وترميز الرابط
  static String _cleanUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final encodedPath = uri.pathSegments
          .map((segment) => Uri.encodeComponent(segment))
          .join('/');
      
      return '${uri.scheme}://${uri.host}/$encodedPath';
    } catch (e) {
      debugPrint('🚨 Error cleaning URL: $url - $e');
      return url;
    }
  }

  /// اقتراحات بناءً على رمز الخطأ
  static String _getSuggestionForStatusCode(int statusCode) {
    switch (statusCode) {
      case 404:
        return 'الصورة غير موجودة - تحقق من الرابط';
      case 403:
        return 'ممنوع الوصول للصورة - تحقق من الصلاحيات';
      case 500:
        return 'خطأ في الخادم - جرب لاحقاً';
      case 502:
      case 503:
        return 'الخادم غير متاح مؤقتاً - جرب لاحقاً';
      default:
        return 'خطأ غير معروف - جرب رابط آخر';
    }
  }

  /// اختبار قائمة من روابط الصور
  static Future<List<ImageTestResult>> testMultipleUrls(List<String> urls) async {
    final List<ImageTestResult> results = [];
    
    for (String url in urls) {
      final result = await testImageUrl(url);
      results.add(result);
    }
    
    return results;
  }

  /// طباعة تقرير تشخيصي
  static void printDiagnosticReport(List<ImageTestResult> results) {
    debugPrint('📊 تقرير تشخيص الصور:');
    debugPrint('=' * 50);
    
    int validCount = 0;
    int invalidCount = 0;
    
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      debugPrint('🔍 الصورة ${i + 1}:');
      
      if (result.isValid) {
        validCount++;
        debugPrint('✅ صحيحة - ${result.message}');
        if (result.contentType != null) {
          debugPrint('   النوع: ${result.contentType}');
        }
      } else {
        invalidCount++;
        debugPrint('❌ خطأ - ${result.error}');
        debugPrint('💡 الاقتراح: ${result.suggestion}');
      }
      debugPrint('');
    }
    
    debugPrint('📈 الملخص:');
    debugPrint('✅ صور صحيحة: $validCount');
    debugPrint('❌ صور بها أخطاء: $invalidCount');
    debugPrint('=' * 50);
  }
}

/// نتيجة اختبار الصورة
class ImageTestResult {
  final bool isValid;
  final String? error;
  final String? message;
  final String? suggestion;
  final String? cleanUrl;
  final String? contentType;

  ImageTestResult({
    required this.isValid,
    this.error,
    this.message,
    this.suggestion,
    this.cleanUrl,
    this.contentType,
  });

  @override
  String toString() {
    if (isValid) {
      return 'ImageTestResult(✅ Valid: $message)';
    } else {
      return 'ImageTestResult(❌ Invalid: $error - Suggestion: $suggestion)';
    }
  }
} 