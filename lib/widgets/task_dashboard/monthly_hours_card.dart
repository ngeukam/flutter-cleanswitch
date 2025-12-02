import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cleanswitch_staff/widgets/constant/app_color.dart';

class MonthlyHoursCard extends StatelessWidget {
  final double currentHours;
  final double animatedHours;

  const MonthlyHoursCard({
    super.key,
    required this.currentHours,
    required this.animatedHours,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM').format(now);
    const targetHours = 180.0;

    // Calculate progress ratio (0.0 to 1.0)
    final progressRatio = currentHours / targetHours;
    final animatedProgressRatio = animatedHours / targetHours;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 8,
                            offset: const Offset(3, 3),
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            blurRadius: 8,
                            offset: Offset(-3, -3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade100,
                        child: Icon(
                          Icons.timer_rounded,
                          color: AppColor.appBannerColor,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Monthly Hours',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.appFont,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColor.appBannerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$monthName ${now.year}',
                    style: TextStyle(
                      color: AppColor.appBannerColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// --- Progress bar ---
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: animatedProgressRatio, // Use the calculated ratio here
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  animatedProgressRatio >= 1 ? Colors.green : AppColor.appBannerColor,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// --- Footer text ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentHours.toStringAsFixed(1)} hour(s)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.appBannerColor,
                  ),
                ),
                Text(
                  '$targetHours hrs target',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.subColor,
                  ),
                ),
              ],
            ),
            
            /// --- Progress percentage ---
            const SizedBox(height: 8),
            Text(
              '${(progressRatio * 100).toStringAsFixed(1)}% completed',
              style: TextStyle(
                fontSize: 12,
                color: AppColor.subColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}