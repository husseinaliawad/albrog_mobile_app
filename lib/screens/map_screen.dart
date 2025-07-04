import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الخريطة'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text(
          'شاشة الخريطة قيد التطوير',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
