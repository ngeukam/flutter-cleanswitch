import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cleanswitch_staff/providers/auth_provider.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/app_button.dart';
import '../widgets/constant/app_color.dart';
import '../widgets/change_password_dialog.dart'; // Import the dialog

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.fullName == null) {
        authProvider.refreshUserData();
      }
    });
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _openChangePasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: const CustomAppBar(
            title: "My Profile",
            showBackButton: false,
          ),
          body: authProvider.isLoading && authProvider.fullName == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 30.h,
                  ),
                  child: Column(
                    children: [
                      // --- Avatar ---
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 10,
                              offset: const Offset(5, 5),
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              blurRadius: 10,
                              offset: Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55.r,
                          backgroundColor: AppColor.appBannerColor.withOpacity(0.15),
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColor.appBannerColor,
                            size: 60.r,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // --- Name ---
                      Text(
                        authProvider.fullName ?? 'Not Available',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.appFont,
                        ),
                      ),
                      Text(
                        '@${authProvider.userName ?? 'username'}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      SizedBox(height: 25.h),
                      Divider(color: Colors.grey.shade300),
                      SizedBox(height: 20.h),

                      _buildInfoCard(
                        "Role",
                        authProvider.userRole ?? 'Not defined',
                      ),
                      _buildInfoCard(
                        "Department",
                        authProvider.department ?? 'No department',
                      ),

                      SizedBox(height: 20.h),

                      _buildPropertiesSection(authProvider),

                      SizedBox(height: 40.h),
                      AppButton(
                        buttonText: "Change Password",
                        backgroundColor: AppColor.appBannerColor,
                        onPressed: _openChangePasswordDialog,
                      ),
                      SizedBox(height: 15.h),
                      AppButton(
                        buttonText: "Logout",
                        backgroundColor: Colors.redAccent,
                        onPressed: _logout,
                      ),
                      SizedBox(height: 20.h),
                      OutlinedButton(
                        onPressed: () => authProvider.refreshUserData(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColor.appBannerColor),
                        ),
                        child: Text(
                          'Refresh Profile Data',
                          style: TextStyle(color: AppColor.appBannerColor),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(3, 3),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 6,
            offset: Offset(-3, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColor.appBannerColor,
            ),
          ),
          const Spacer(),
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildPropertiesSection(AuthProvider authProvider) {
    if (authProvider.assignedProperties.isEmpty) {
      return Text(
        'No assigned properties',
        style: TextStyle(color: Colors.grey.shade600),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Assigned Properties",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColor.appBannerColor,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 10),
        ...authProvider.assignedProperties.map(
          (prop) => Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColor.appBannerColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.home_rounded, color: AppColor.appBannerColor),
                const SizedBox(width: 10),
                Expanded(child: Text(prop['name'].toString())),
              ],
            ),
          ),
        ),
      ],
    );
  }
}