import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'https://albrog.com';
  static const String loginEndpoint = '$baseUrl/login.php';
  
  final GetStorage _storage = GetStorage();
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  /// تسجيل دخول المستخدم
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔄 Attempting login for: $email');
      print('🌐 API Endpoint: $loginEndpoint');
      
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'الخادم لم يرد بأي بيانات',
        };
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // حفظ بيانات المستخدم
        final user = User.fromJson(responseData['data']);
        await saveUser(user);
        
        return {
          'success': true,
          'message': responseData['message'],
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'خطأ في تسجيل الدخول',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم: $e',
      };
    }
  }

  /// حفظ بيانات المستخدم محلياً
  Future<void> saveUser(User user) async {
    await _storage.write(_userKey, user.toJson());
    await _storage.write(_tokenKey, DateTime.now().millisecondsSinceEpoch.toString());
  }

  /// استرجاع بيانات المستخدم المحفوظة
  User? getUser() {
    final userData = _storage.read(_userKey);
    if (userData != null) {
      return User.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  /// التحقق من تسجيل الدخول
  bool isLoggedIn() {
    final userData = _storage.read(_userKey);
    final token = _storage.read(_tokenKey);
    return userData != null && token != null;
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _storage.remove(_userKey);
    await _storage.remove(_tokenKey);
  }

  /// الحصول على رمز المصادقة
  String? getToken() {
    return _storage.read(_tokenKey);
  }
} 