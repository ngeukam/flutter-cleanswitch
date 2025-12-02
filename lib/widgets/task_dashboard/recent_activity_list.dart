import 'package:flutter/material.dart';
import 'package:cleanswitch_staff/widgets/constant/app_color.dart';

class RecentActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> recentTasks;
  final Function(String) onTaskTap;

  const RecentActivityList({
    super.key,
    required this.recentTasks,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recentTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 10,
              offset: Offset(-4, -4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No recent activities found',
            style: TextStyle(
              color: AppColor.subColor,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
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
      child: Column(
        children: recentTasks.map((task) {
          final statusColor = _getStatusColor(task['status']);
          final statusIcon = _getStatusIcon(task['status']);

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onTaskTap(task['id'].toString()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade100,
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
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  // --- Icon circle with neumorphic effect ---
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.15),
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // --- Task details ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['title'] ?? 'Untitled Task',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColor.appFont,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 12, color: AppColor.subColor),
                            const SizedBox(width: 4),
                            Text(
                              task['time_text'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.subColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- Chevron icon ---
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColor.subColor.withOpacity(0.8),
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'in_progress':
        return Icons.autorenew_rounded;
      case 'pending':
        return Icons.access_time_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
