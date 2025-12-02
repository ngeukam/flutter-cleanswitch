import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../widgets/common/custom_text.dart';
import '../widgets/common/app_button.dart';
import '../widgets/constant/app_color.dart';
import '../widgets/constant/app_image.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.appBannerColor,
              const Color(0xFF4A8EA0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeIn,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
              child: Column(
                children: [
                  _buildHeaderImage(),
                  SizedBox(height: 30.h),
                  _buildLoginCard(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Hero(
      tag: 'logoHero',
      child: Container(
        height: 150.h,
        width: 150.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(75.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(AppImages.houseCleaning),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomText(
              text: 'Welcome Back 👋',
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              textColor: AppColor.appBannerColor,
            ),
            SizedBox(height: 6.h),
            CustomText(
              text: 'Please sign in to continue',
              fontSize: 15.sp,
              textColor: AppColor.subColor,
            ),
            SizedBox(height: 30.h),

            // Username
            _buildTextField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.person_outline,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your username' : null,
            ),
            SizedBox(height: 20.h),

            // Password
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password';
                }
                if (value.length < 6) {
                  return 'Password must contain at least 6 characters';
                }
                return null;
              },
            ),

            SizedBox(height: 10.h),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _showForgotPasswordDialog,
                child: CustomText(
                  text: 'Forgot Password?',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  textColor: AppColor.appBannerColor,
                ),
              ),
            ),

            SizedBox(height: 30.h),

            // ✅ Using your AppButton here
            _buildLoginButton(context),

            SizedBox(height: 20.h),
            _buildErrorMessage(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: AppColor.appFont, fontSize: 15.sp),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColor.appBannerColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppColor.appBannerColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AppButton(
      buttonText: authProvider.isLoading ? 'Logging in...' : 'Login',
      onPressed: authProvider.isLoading
          ? null
          : () async {
              if (_formKey.currentState!.validate()) {
                final success = await authProvider.login(
                  _usernameController.text.trim(),
                  _passwordController.text.trim(),
                );
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login failed'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
      backgroundColor: AppColor.appBannerColor,
      textColor: Colors.white,
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.errorMessage == null) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent, size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              authProvider.errorMessage!,
              style: TextStyle(color: Colors.redAccent, fontSize: 13.sp),
            ),
          ),
          GestureDetector(
            onTap: () => authProvider.clearError(),
            child: Icon(Icons.close, color: Colors.redAccent, size: 18.w),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Forgot Password',
          style: TextStyle(
              color: AppColor.appBannerColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Feature coming soon. Please contact the administrator.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                  color: AppColor.appBannerColor,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
