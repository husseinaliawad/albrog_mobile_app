import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // ✅ مهم لـ Color
import '../services/api_service.dart';

class InvestmentController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Observables
  var isLoading = false.obs;
  var investmentProjects = <Map<String, dynamic>>[].obs;
  var totalInvestmentAmount = 0.0.obs;
  var selectedProjectIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInvestmentData();
  }

  /// ✅ Fetch data from real API
  Future<void> fetchInvestmentData() async {
    try {
      isLoading.value = true;

      // Example: Replace with your real endpoint and params
      final response = await _apiService.dio.get('/investments');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Example: Adjust keys to match your backend response
        totalInvestmentAmount.value = data['totalInvestment'] ?? 0.0;
        investmentProjects.value = List<Map<String, dynamic>>.from(
          data['projects'] ?? [],
        );
      } else {
        Get.snackbar('خطأ', 'فشل في تحميل البيانات من الخادم');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء الاتصال بالخادم');
      print('❌ [InvestmentController] fetchInvestmentData: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchInvestmentData();
  }

  Map<String, dynamic>? getProjectById(int id) {
    return investmentProjects.firstWhereOrNull((p) => p['id'] == id);
  }

  void selectProject(int index) {
    selectedProjectIndex.value = index;
  }

  double getInvestmentProgress(int projectId) {
    final project = getProjectById(projectId);
    return (project?['progress'] ?? 0).toDouble();
  }

  String getProjectStatus(int projectId) {
    final progress = getInvestmentProgress(projectId);
    if (progress >= 100) return 'مكتمل';
    if (progress >= 75) return 'المرحلة النهائية';
    if (progress >= 50) return 'قيد التنفيذ';
    if (progress >= 25) return 'البداية';
    return 'التخطيط';
  }

  Color getProjectStatusColor(int projectId) {
    final progress = getInvestmentProgress(projectId);
    if (progress >= 100) return Get.theme.colorScheme.primary;
    if (progress >= 75) return Get.theme.colorScheme.secondary;
    if (progress >= 50) return Get.theme.colorScheme.tertiary;
    if (progress >= 25) return Get.theme.colorScheme.surface;
    return Get.theme.colorScheme.error;
  }

  double get totalPortfolioValue {
    return investmentProjects.fold(
      0.0,
      (sum, p) => sum + (p['financialSummary']?['expectedReturn'] ?? 0.0),
    );
  }

  double get totalPaidAmount {
    return investmentProjects.fold(
      0.0,
      (sum, p) => sum + (p['financialSummary']?['paidAmount'] ?? 0.0),
    );
  }

  double get averageROI {
    if (investmentProjects.isEmpty) return 0.0;

    final rois = investmentProjects
        .map((p) => p['financialSummary']?['expectedROI'])
        .whereType<double>()
        .toList();

    return rois.isNotEmpty ? rois.reduce((a, b) => a + b) / rois.length : 0.0;
  }

  /// ✅ Send support message
  Future<void> contactSupport(String projectName, String message) async {
    try {
      final response = await _apiService.dio.post(
        '/support/contact',
        data: {
          'projectName': projectName,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'تم الإرسال',
          'تم إرسال رسالتك بنجاح. سيتم التواصل معك قريباً',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        throw Exception('فشل في الإرسال');
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إرسال الرسالة. حاول مرة أخرى',
        snackPosition: SnackPosition.TOP,
      );
      print('❌ [InvestmentController] contactSupport: $e');
    }
  }
}
