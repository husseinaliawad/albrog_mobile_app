import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text(
          'شاشة الإعدادات قيد التطوير',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
