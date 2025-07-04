import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text(
          'شاشة المفضلة قيد التطوير',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
