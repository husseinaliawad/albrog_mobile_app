import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../controllers/investment_controller.dart';

class InvestmentDashboardScreen extends StatefulWidget {
  const InvestmentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentDashboardScreen> createState() =>
      _InvestmentDashboardScreenState();
}

class _InvestmentDashboardScreenState extends State<InvestmentDashboardScreen> {
  final AuthController authController = Get.find<AuthController>();
  final InvestmentController investmentController =
      Get.find<InvestmentController>();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Row(
          children: [
            _buildSidebar(),
            Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'لوحة المستثمر',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        authController.currentUser.value?.name ?? 'مستثمر',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSidebarItem(Icons.dashboard_rounded, 'لوحة التحكم', 0,
                      selectedIndex == 0),
                  const SizedBox(height: 8),
                  _buildSidebarItem(
                      Icons.trending_up, 'استثماراتي', 1, selectedIndex == 1),
                  const SizedBox(height: 8),
                  _buildSidebarItem(
                      Icons.analytics, 'التقارير', 2, selectedIndex == 2),
                  const Spacer(),
                  _buildSidebarItem(Icons.logout, 'تسجيل الخروج', -1, false,
                      onTap: () {
                    authController.logout();
                    Get.offAllNamed('/login');
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title,
    int index,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () {
            setState(() {
              selectedIndex = index;
            });
          },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : Colors.grey[600],
                size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey[700],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Obx(() {
      if (investmentController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      switch (selectedIndex) {
        case 0:
          return _buildDashboardView();
        case 1:
          return _buildInvestmentsView();
        case 2:
          return _buildReportsView();
        default:
          return _buildDashboardView();
      }
    });
  }

  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildInvestmentAmountCard(),
          const SizedBox(height: 32),
          _buildProjectsSection(),
          const SizedBox(height: 16),
          Obx(() => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: investmentController.investmentProjects.length,
                itemBuilder: (_, i) => _buildProjectCard(
                    investmentController.investmentProjects[i]),
              )),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً بك في لوحة الاستثمار',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D29),
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 4),
            Text(
              'تابع استثماراتك العقارية وحالة مشاريعك',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.notifications_outlined,
              color: AppColors.secondary, size: 24),
        ),
      ],
    );
  }

  Widget _buildInvestmentAmountCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_wallet,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'إجمالي استثماراتك',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Cairo'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => Text(
                      '${investmentController.totalInvestmentAmount.value.toStringAsFixed(0)} ريال',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'مشاريعك الاستثمارية',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D29),
            fontFamily: 'Cairo',
          ),
        ),
        TextButton.icon(
          onPressed: () => setState(() => selectedIndex = 1),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text(
            'عرض الكل',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return GestureDetector(
      onTap: () => _showProjectDetails(project),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Icon(Icons.business, size: 48, color: Colors.grey),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  project['name'],
                  style: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentsView() {
    return Center(child: Text('استثماراتي'));
  }

  Widget _buildReportsView() {
    return const Center(
      child: Text('قسم التقارير قيد التطوير',
          style: TextStyle(fontFamily: 'Cairo')),
    );
  }

  void _showProjectDetails(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (context) => ProjectDetailsDialog(
        project: project,
        onContactSupport: () => _showContactSupportDialog(project),
      ),
    );
  }

  void _showContactSupportDialog(Map<String, dynamic> project) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            const Text('تواصل مع الدعم', style: TextStyle(fontFamily: 'Cairo')),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'رسالتك هنا...'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              investmentController.contactSupport(
                  project['name'], controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }
}

class ProjectDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onContactSupport;

  const ProjectDetailsDialog({
    Key? key,
    required this.project,
    required this.onContactSupport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(project['name']),
      content: Text(project['description']),
      actions: [
        TextButton(
            onPressed: onContactSupport, child: const Text('تواصل مع الدعم')),
      ],
    );
  }
}
