import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constant/app_color.dart';

class AppButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed; // Add this line
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.buttonText,
    this.onPressed, // Add this
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0), // Adjust top margin as needed
      child: ElevatedButton(
        onPressed: onPressed, // Use the parameter here
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColor.appBannerColor,
          minimumSize: Size(double.infinity, 40.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
