import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthController authController;
  final RxBool obscurePassword = true.obs;

  @override
  void initState() {
    super.initState();
    // Initialize controller once and keep it during widget lifecycle
    authController = Get.put(AuthController(), permanent: true);
  }

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    obscurePassword.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo and Welcome Text
              _buildHeader(),

              const SizedBox(height: 60),

              // Login Form
              _buildLoginForm(),

              const SizedBox(height: 30),

              // Login Button
              _buildLoginButton(),

              const SizedBox(height: 30),

              // Divider
              _buildDivider(),

              const SizedBox(height: 30),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Company Logo
        Container(
          height: 140,
          width: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.business,
                    size: 70,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Welcome Text
        Text(
          'مرحباً بك',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontFamily: 'Cairo',
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'سجل دخولك للوصول إلى حسابك',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: authController.formKey,
      child: Column(
        children: [
          // Email Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: authController.emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: authController.validateEmail,
              onFieldSubmitted: (_) {
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.nextFocus();
                }
              },
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                hintText: 'أدخل بريدك الإلكتروني',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.tertiary,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textSecondary,
                ),
                hintStyle: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
                errorStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.error,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Password Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(() => TextFormField(
                  controller: authController.passwordController,
                  obscureText: obscurePassword.value,
                  textInputAction: TextInputAction.done,
                  validator: authController.validatePassword,
                  onFieldSubmitted: (_) => authController.login(),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    hintText: 'أدخل كلمة المرور',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.primary,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => obscurePassword.toggle(),
                      child: Icon(
                        obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.tertiary,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textSecondary,
                    ),
                    hintStyle: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                    errorStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.error,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: authController.isLoading.value
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.6),
                      AppColors.secondary.withOpacity(0.6),
                    ],
                  )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: authController.isLoading.value
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: authController.isLoading.value
                  ? null
                  : () => authController.login(),
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: authController.isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
              ),
            ),
          ),
        ));
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.tertiary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أو',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => authController.goToForgotPassword(),
          child: Text(
            'هل نسيت كلمة المرور؟',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'تطبيق البروج العقاري',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'الإصدار 1.0.0',
          style: TextStyle(
            color: AppColors.textLight.withOpacity(0.7),
            fontSize: 12,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
