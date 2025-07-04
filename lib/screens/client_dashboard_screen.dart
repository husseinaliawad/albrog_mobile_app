import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../constants/app_colors.dart';
import '../controllers/client_dashboard_controller.dart';
import '../models/property.dart';
import '../screens/property_details_screen.dart';

class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({Key? key}) : super(key: key);

  /// ✅ جلب الصورة بصيغة Base64 من API
  Future<String> fetchBase64Image(String imageUrl) async {
    final response = await Dio().get(
      'https://albrog.com/image_base64.php',
      queryParameters: {'url': imageUrl},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data_url'];
    } else {
      throw Exception('❌ فشل تحميل الصورة');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientDashboardController());

    /// ✅ تأكد من التحميل مرة واحدة فقط
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.myProperties.isEmpty) {
        controller.loadMyProperties();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          'عقاراتي',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      body: Obx(() {
        if (controller.myProperties.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد عقارات حالياً',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myProperties.length,
          itemBuilder: (context, index) {
            final property = controller.myProperties[index];
            return _buildPropertyCard(property, controller);
          },
        );
      }),
    );
  }

  /// ✅ كرت العقار مع تمرير الـ Property مباشرة
  Widget _buildPropertyCard(
    Property property,
    ClientDashboardController controller,
  ) {
    final double completion = property.rating ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: _buildPropertyImage(property.thumbnail),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تاريخ الإضافة: ${property.createdAt.toString().split(' ').first}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'Cairo',
                  ),
                ),
                
                // Contribution Amount
                if (property.contributionAmount != null && property.contributionAmount! > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'مبلغ المساهمة: ${property.formattedContributionAmount}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نسبة الإنجاز',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: completion / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${completion.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      /// ✅ مرّر الـ Property كاملة
                      Get.to(() => PropertyDetailsScreen(property: property));
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text(
                      'عرض التفاصيل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ تحميل صورة Base64
  Widget _buildPropertyImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.red),
        ),
      );
    }

    return FutureBuilder<String>(
      future: fetchBase64Image(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Icon(Icons.error, size: 50, color: Colors.red),
            ),
          );
        } else {
          final base64Str = snapshot.data!.split(',').last;
          return Image.memory(
            base64Decode(base64Str),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          );
        }
      },
    );
  }
}
